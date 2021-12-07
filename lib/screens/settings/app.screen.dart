import 'package:flutter/material.dart';
import 'package:iot/components/button.component.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:iot/enum/route.enum.dart';
import 'package:iot/models/profile.model.dart';
import 'package:iot/screens/settings/components/item.component.dart';
import 'package:iot/screens/settings/components/section.component.dart';
import 'package:iot/util/functions.util.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({Key? key}) : super(key: key);

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  bool isLoading = false;
  String error = '';

  @override
  Widget build(BuildContext context) {
    final UserController controller = Provider.of<UserController>(context);
    final Profile profile = controller.profile!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("App Settings"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                SectionItem(
                  title: "Name",
                  trailingText: profile.name,
                  onEdit: (String value) async {
                    try {
                      await controller.updateProfile("name", value);
                    } catch (e) {}
                  },
                ),
                SectionItem(
                  title: "Phone",
                  onEdit: (String value) {},
                  onTap: () {
                    Navigator.pushNamed(context, Screen.editPhone, arguments: {
                      "code": profile.code,
                      "phone": profile.phone,
                    });
                  },
                  trailingText: "+" + profile.code + " " + profile.phone,
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
                SectionItem(
                  title: "Temperature Unit",
                  trailingText: "Celcius",
                  showChevron: true,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Screen.selector,
                    );
                  },
                ),
                SectionItem(
                  title: "24-Hour Time",
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {},
                  ),
                  showSeparator: false,
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
    );
  }
}
