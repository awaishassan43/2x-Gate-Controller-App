//State update from Device
const functions = require('firebase-functions');
const {
  db,
  config,
  admin
} = require('../admin');

const MAX_LOG_COUNT = 100;
/**
 * Cloud Function: Handle device state updates
 */
module.exports = functions.pubsub.topic('device-events').onPublish(async (message) => { //'device-events' is topic config in cloud
  const deviceId = message.attributes.deviceId;
  //https://firebase.google.com/docs/functions/pubsub-events?authuser=0#access_message_attributes
  //https://cloud.google.com/iot/docs/how-tos/mqtt-bridge#publishing_telemetry_events

  // Write the device state

  //  const messageBody = message.data ? Buffer.from(message.data, 'base64').toString() : null;
  //Need check is json or text
  const deviceRef = db.ref(`devices/${deviceId}`);
  const deviceLogPushRef = db.ref(`deviceStateLogs/${deviceId}`);
  const deviceCommandRef = db.ref(`deviceCommands/${deviceId}`);
  const deviceSettingsRef = db.ref(`deviceSettings/${deviceId}`);

  const usersRef = db.ref('users');
  const deviceAccessRef = db.ref('deviceAccess');

  try {
    /**
     * Getting initial state before saving the new state
     */
    const initialStateData = await deviceRef.get();
    const initialState = initialStateData.val();

    // Ensure the device is also marked as 'online' when state is updated
    await deviceRef.update({
      'state': message.json, //update lastest state
      'timestamp': admin.database.ServerValue.TIMESTAMP,
      'online': true
    });

    var d = new Date();
    var timeStr = d.toISOString(); // d.toUTCString();

    if (message.json.mqttPublishType === 'ALERT') { //add to Log

      const snapshot = await deviceLogPushRef.once('value'); //Kiem tra snapshot khac null
      if (snapshot.exists()) {
        if (snapshot.numChildren() >= MAX_LOG_COUNT) {
          let childCount = 0;
          const updates = {};
          snapshot.forEach((child) => {
            if (++childCount <= snapshot.numChildren() - MAX_LOG_COUNT) {
              updates[child.key] = null;
            }
          });
          await deviceLogPushRef.update(updates);
        }
      }

      await deviceLogPushRef.push().set({
        "deviceId": deviceId,
        "state": message.json,
        "published_at": timeStr,
        "timestamp": admin.database.ServerValue.TIMESTAMP
      });

    } else if (message.json.mqttPublishType === 'RESPONSE') { //update command execute
      await deviceCommandRef.child("response").update({
        'reqId': message.json.reqId,
        'timestamp': admin.database.ServerValue.TIMESTAMP
      });

    }

    console.log(`State updated for ${deviceId}`);


    /**********************************************************************************
     * 1. getting the settings of the device
     * 2. verifying that the state changed or the temperature has hit the alert value set
     * 3. getting the users from the db that have the device id
     * 4. getting each user's fcm
     * 5. sending notification to each user
     */


    const deviceSettingsData = await deviceSettingsRef.get();
    const deviceSettings = deviceSettingsData.val();

    const isOpenAlertEnabled = deviceSettings.value.alertOnOpen;
    const isClosedAlertEnabled = deviceSettings.value.alertOnClose;
    const temperatureAlert = deviceSettings.value.temperatureAlert;
    const nightAlert = deviceSettings.value.nightAlert;

    console.log("Are alerts enabled: ", {
      isClosedAlertEnabled,
      isOpenAlertEnabled,
      temperatureAlert,
      nightAlert,
    });

    /**
     * If none of the alerts is enabled, then don't execute the following block
     */
    if (!isOpenAlertEnabled && !isClosedAlertEnabled && temperatureAlert === null && nightAlert === null) {
      return;
    }

    const initialStateForRelay1 = initialState.state.payload.state1;
    const newStateForRelay1 = message.json.payload.state1;
    const initialStateForRelay2 = initialState.state.payload.state2;
    const newStateForRelay2 = message.json.payload.state2;
    const currentTemperature = message.json.payload.Temp;

    let nightAlertTime;

    if (nightAlert) {
      const splitNightTime = nightAlert.split(':');
      const nightDate = new Date();
      nightDate.setHours(parseInt(splitNightTime[0]), parseInt(splitNightTime[1]));

      nightAlertTime = nightDate.getTime();
    }

    /**
     * Getting current time and date from the device and then parsing that to JS date object
     */
    const deviceRawDate = message.json.payload.date.split('/');
    const deviceRawTime = message.json.payload.time.split(':');

    const deviceDate = new Date();
    deviceDate.setFullYear(parseInt(deviceRawDate[2]), parseInt(deviceRawDate[1]), parseInt(deviceRawDate[0]));
    deviceDate.setHours(parseInt(deviceRawTime[0]), parseInt(deviceRawTime[1]));

    const deviceTime = deviceDate.getTime();

    // Night alert needs to run only once after 

    const currentDate = new Date();
    const currentTime = currentDate.getHours();

    console.log("Device state: ", {
      initialStateForRelay1,
      newStateForRelay1,
      initialStateForRelay2,
      newStateForRelay2,
    });

    /**
     * Check if the states changed and doors are currently open
     */
    const hasStateChangedForRelay1 = initialStateForRelay1 !== newStateForRelay1;
    const hasStateChangedForRelay2 = initialStateForRelay2 !== newStateForRelay2;
    const hasTemperatureExceededAlertValue = temperatureAlert !== null && currentTemperature > temperatureAlert;
    const isDoorOpenAtNight = isNightAlertEnabled && (newStateForRelay1 || newStateForRelay2) && currentTime > 18;

    console.log("Has state changed: ", {
      hasStateChangedForRelay1,
      hasStateChangedForRelay2,
      hasTemperatureExceededAlertValue,
      isDoorOpenAtNight,
    });

    /**
     * if none of the state has changed then return and don't run the subsequent code
     */
    if (!hasStateChangedForRelay1 && !hasStateChangedForRelay2 && !hasTemperatureExceededAlertValue && !isDoorOpenAtNight) {
      return;
    }

    console.log("Getting users with access to the device: ", deviceId);

    /**
     * Get the list of the users that have access to this device irrespective of their access type,
     * i.e. whether they are owner, family or guest
     */
    const accessData = await deviceAccessRef.orderByChild("deviceID").equalTo(deviceId).get();
    const accessList = accessData.val();

    if (!accessList) {
      console.log(`No user has access to ${deviceId}`);
      return;
    }

    console.log("Translating the access to users list");

    const usersList = new Set();
    for (let access of Object.values(accessList)) {
      if (access.userID) {
        usersList.add(access.userID);
      }
    }

    /**
     * Get the fcm token for each user
     */
    const usersDataList = [];
    for (let userID of [...usersList]) {
      const userData = await usersRef.child(userID).get();
      const user = userData.val();

      usersDataList.push(user);
    }

    const tokensList = usersDataList.map((user) => user.fcmToken);
    console.log("Will send notifications to following tokens: ", tokensList);

    /**
     * Check for each case
     */
    if (hasStateChangedForRelay1) {
      console.log("Sending fcm for relay state 1 update");
      admin.messaging().sendMulticast({
        tokens: tokensList,
        notification: {
          body: `${deviceSettings.value.Relay1.Name} was ${newStateForRelay1 === 1 ? 'opened' : 'closed'} on ${currentDate.toString()}`,
        }
      });
    }

    if (hasStateChangedForRelay2) {
      console.log("Sending fcm for relay state 2 update");
      admin.messaging().sendMulticast({
        tokens: tokensList,
        notification: {
          body: `${deviceSettings.value.Relay2.Name} was ${newStateForRelay2 === 1 ? 'opened' : 'closed'} on ${currentDate.toString()}`,
        }
      });
    }

    if (temperatureAlert !== null && currentTemperature > temperatureAlert) {
      console.log("Sending fcm for temperature alert");

      /**
       * Check if all units are same, then use send all method, otherwise, loop over each user... and send each notification individually
       */
      const tempUnitList = new Set();
      for (let user in usersDataList) {
        tempUnitList.add(user.temperatureUnit);
      }

      if ([...tempUnitList].length > 1) {
        console.log("Sending temperature fcm to each user individually");
        for (let user in usersDataList) {
          const tempUnit = user.temperatureUnit;

          let temperature = currentTemperature;

          // If current temperature is F, then update the temperature to farenheit based unit, otherwise leave it
          if (tempUnit === "F") {
            temperature = ((temperature * 9) / 5) + 32;
          }

          admin.messaging().send({
            token: user.fcmToken,
            notification: {
              body: `Temperature of ${initialState.name} has reached ${temperature}°${tempUnit}`,
            }
          });
        }
      } else {
        console.log("Sending temperature alert fcm using multicast");

        admin.messaging().sendMulticast({
          tokens: [...tokensList],
          notification: {
            body: `Temperature of ${initialState.name} has reached ${currentTemperature}°${[...tempUnitList][0]}`,
          }
        });
      }
    }
  } catch (error) {
    console.error(`${deviceId} update state error`, error);
  }
});
