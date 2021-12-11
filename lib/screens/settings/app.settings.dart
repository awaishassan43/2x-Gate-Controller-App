import 'package:flutter/material.dart';
import 'package:iot/components/button.component.dart';
import 'package:iot/components/loader.component.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:iot/enum/route.enum.dart';
import 'package:iot/models/profile.model.dart';
import 'package:iot/screens/settings/components/item.component.dart';
import 'package:iot/screens/settings/components/section.component.dart';
import 'package:iot/screens/settings/subscreens/selector.screen.dart';
import 'package:iot/util/constants.util.dart';
import 'package:iot/util/functions.util.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class AppSettings extends StatelessWidget {
  const AppSettings({Key? key}) : super(key: key);

  Future<void> onTimeFormatUpdated(BuildContext context, bool value) async {
    final UserController controller = Provider.of<UserController>(context, listen: false);
    final Profile profile = controller.profile!;

    final bool previousValue = profile.is24Hours;

    try {
      controller.isLoading = true;

      controller.profile!.is24Hours = value;
      await controller.updateProfile();

      showMessage(context, "Profile updated successfully!");
    } catch (e) {
      profile.is24Hours = previousValue;
      showMessage(context, e.toString());
    }

    controller.isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    final UserController controller = Provider.of<UserController>(context, listen: false);
    final Profile profile = controller.profile!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("App Settings"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Section(
                  header: "Profile",
                  children: [
                    SectionItem(
                      title: "Email",
                      trailingText: profile.email,
                    ),
                    Selector<UserController, String>(
                      selector: (context, controller) => controller.profile!.name,
                      builder: (context, name, __) {
                        return SectionItem(
                          title: "Name",
                          trailingText: name,
                          showEditIcon: true,
                          onTap: () {
                            Navigator.pushNamed(context, Screen.editName);
                          },
                        );
                      },
                    ),
                    Selector<UserController, Tuple2<String, String>>(
                      selector: (context, controller) => Tuple2(controller.profile!.code, controller.profile!.phone),
                      builder: (context, values, _) {
                        final String code = values.item1;
                        final String phone = values.item2;
                        return SectionItem(
                          title: "Phone",
                          onTap: () {
                            Navigator.pushNamed(context, Screen.editPhone);
                          },
                          showEditIcon: true,
                          trailingText: "+" + code + " " + phone,
                        );
                      },
                    ),
                    SectionItem(
                      title: "Password",
                      showChevron: true,
                      onTap: () {
                        Navigator.pushNamed(context, Screen.resetPassword);
                      },
                      showSeparator: false,
                    ),
                  ],
                ),
                Section(
                  header: "Upgrade",
                  children: [
                    SectionItem(
                      title: "Upgrade to Premium",
                      subtitleText: "Add multiple devices, Activate multiple features",
                      showChevron: true,
                      onTap: () {},
                      showSeparator: false,
                    ),
                  ],
                ),
                Section(
                  header: "Settings",
                  children: [
                    Selector<UserController, String>(
                      selector: (context, controller) => controller.profile!.temperatureUnit,
                      builder: (context, unit, __) {
                        return SectionItem(
                          title: "Temperature Unit",
                          trailingText: temperatureUnits[unit],
                          showChevron: true,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return SelectorScreen(
                                title: "Temperature Unit",
                                items: temperatureUnits.keys.toList(),
                                selectedItem: unit,
                                mapKey: 'temperatureUnit',
                                isProfileKey: true,
                                isTime: false,
                              );
                            }));
                          },
                        );
                      },
                    ),
                    Selector<UserController, bool>(
                      selector: (context, controller) => controller.profile!.is24Hours,
                      builder: (context, is24Hours, __) {
                        return SectionItem(
                          title: "24-Hour Time",
                          trailing: Switch(
                            value: is24Hours,
                            onChanged: (bool value) {
                              onTimeFormatUpdated(context, value);
                            },
                          ),
                          onTap: () {
                            onTimeFormatUpdated(context, !is24Hours);
                          },
                          showSeparator: false,
                        );
                      },
                    ),
                  ],
                ),
                Section(
                  header: "Share",
                  subHeader: "[Premium Feature]",
                  children: [
                    SectionItem(
                      title: "Family",
                      trailingText: "View",
                      showChevron: true,
                      onTap: () {},
                    ),
                    SectionItem(
                      title: "Guest",
                      trailingText: "View",
                      onTap: () {},
                      showChevron: true,
                    ),
                    SectionItem(
                      title: "Add User",
                      showChevron: true,
                      onTap: () {},
                      showSeparator: false,
                    ),
                  ],
                ),
                Section(
                  children: [
                    SectionItem(
                      title: "Terms of Use",
                      onTap: () {},
                      trailingText: "View",
                      showChevron: true,
                    ),
                    SectionItem(
                      title: "Privacy Policy",
                      onTap: () {},
                      showChevron: true,
                      trailingText: "View",
                    ),
                    SectionItem(
                      title: "Faq",
                      onTap: () {},
                      showChevron: true,
                    ),
                    SectionItem(
                      title: "Feedback",
                      onTap: () {
                        Navigator.pushNamed(context, Screen.feedback);
                      },
                      showChevron: true,
                    ),
                    FutureBuilder(
                      future: PackageInfo.fromPlatform(),
                      builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
                        return SectionItem(
                          title: "App Version",
                          onTap: () {},
                          trailingText: snapshot.connectionState != ConnectionState.done
                              ? "Loading..."
                              : !snapshot.hasData || snapshot.hasError || snapshot.data == null
                                  ? ""
                                  : "v${snapshot.data!.version}",
                          showSeparator: false,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                CustomButton(
                  text: "Sign Out",
                  onPressed: () async {
                    try {
                      controller.isLoading = true;

                      await Provider.of<UserController>(context, listen: false).logout();
                      Navigator.pushNamedAndRemoveUntil(context, Screen.login, (route) => false);
                    } catch (e) {
                      showMessage(context, "Failed to logout");
                    }
                  },
                  textColor: Colors.blue,
                  backgroundColor: Colors.white,
                  disableElevation: true,
                ),
              ],
            ),
          ),
          Selector<UserController, bool>(
            selector: (context, controller) => controller.isLoading,
            builder: (context, isLoading, _) {
              if (isLoading) return const Loader(message: "Updating profile");

              return Container();
            },
          ),
        ],
      ),
    );
  }
}
