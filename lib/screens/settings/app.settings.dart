import 'package:flutter/material.dart';
import 'package:iot/screens/settings/subscreens/editor.screen.dart';
import '/components/button.component.dart';
import '/components/loader.component.dart';
import '/controllers/user.controller.dart';
import '/enum/route.enum.dart';
import '/models/profile.model.dart';
import '/screens/settings/components/item.component.dart';
import '/screens/settings/components/section.component.dart';
import '/screens/settings/subscreens/selector.screen.dart';
import '/util/constants.util.dart';
import '/util/functions.util.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class AppSettings extends StatelessWidget {
  const AppSettings({Key? key}) : super(key: key);

  Future<void> updateProfile(BuildContext context, String key, dynamic value) async {
    try {
      final UserController controller = Provider.of<UserController>(context, listen: false);
      final Map<String, dynamic> mappedData = controller.profile!.toJSON();
      mappedData[key] = value;

      controller.profile = Profile.fromMap(mappedData);
      await controller.updateProfile();
    } catch (e) {
      showMessage(context, e.toString());
    }
  }

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Settings"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Selector<UserController, Profile?>(
            selector: (context, controller) => controller.profile,
            builder: (context, profile, _) {
              if (profile == null) {
                return Container();
              }

              return SingleChildScrollView(
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
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditorScreen(
                                    initialValue: name,
                                    onSubmit: (value, _) => updateProfile(context, 'name', value),
                                    title: "Update name",
                                    icon: Icons.person,
                                    isEditingDevice: false,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Selector<UserController, Tuple2<String?, String?>>(
                          selector: (context, controller) => Tuple2(controller.profile?.code, controller.profile?.phone),
                          builder: (context, values, _) {
                            final String? code = values.item1;
                            final String? phone = values.item2;
                            return code == null || phone == null
                                ? Container()
                                : SectionItem(
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
                        Selector<UserController, String?>(
                          selector: (context, controller) => controller.profile?.temperatureUnit,
                          builder: (context, unit, __) {
                            return SectionItem(
                              title: "Temperature Unit",
                              trailingText: temperatureUnits[unit],
                              showChevron: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return SelectorScreen(
                                        title: "Temperature Unit",
                                        items: temperatureUnits.keys.toList(),
                                        selectedItem: unit,
                                        isTime: false,
                                        mapKey: 'temperatureUnit',
                                        updateProfile: true,
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        Selector<UserController, bool?>(
                          selector: (context, controller) => controller.profile?.is24Hours,
                          builder: (context, is24Hours, __) {
                            return is24Hours == null
                                ? Container()
                                : SectionItem(
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
                          onTap: () => Navigator.pushNamed(context, Screen.family),
                        ),
                        SectionItem(
                          title: "Guest",
                          trailingText: "View",
                          onTap: () => Navigator.pushNamed(context, Screen.guests),
                          showChevron: true,
                        ),
                        SectionItem(
                          title: "Add User",
                          showChevron: true,
                          onTap: () => Navigator.pushNamed(context, Screen.addUser),
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
                        final UserController controller = Provider.of<UserController>(context, listen: false);

                        try {
                          controller.isLoading = true;

                          await controller.logout();
                          showMessage(context, "Logged out successfully!");

                          controller.isLoading = false;
                          await Navigator.pushNamedAndRemoveUntil(context, Screen.login, (route) => false);
                        } catch (e) {
                          controller.isLoading = false;
                          showMessage(context, "Failed to logout");
                        }
                      },
                      textColor: Colors.blue,
                      backgroundColor: Colors.white,
                      disableElevation: true,
                    ),
                  ],
                ),
              );
            },
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
