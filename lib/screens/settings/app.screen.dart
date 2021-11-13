import 'package:flutter/material.dart';
import 'package:iot/components/button.component.dart';
import 'package:iot/screens/settings/components/item.component.dart';
import 'package:iot/screens/settings/components/section.component.dart';

class AppSettings extends StatelessWidget {
  const AppSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                const SectionItem(
                  title: "Email",
                  trailingText: "google@gmail.com",
                ),
                SectionItem(
                  title: "Name",
                  trailingText: "Tom Cruise",
                  onEdit: () {},
                ),
                SectionItem(
                  title: "Phone",
                  onEdit: () {},
                  trailingText: "+1 0123456789",
                ),
                SectionItem(
                  title: "Password",
                  showChevron: true,
                  onTap: () {},
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
                  onTap: () {},
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
                  onTap: () {},
                  showChevron: true,
                ),
                SectionItem(
                  title: "App Version",
                  onTap: () {},
                  trailingText: "v1.2",
                  showSeparator: false,
                  showChevron: true,
                ),
              ],
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: "Sign Out",
              onPressed: () {},
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
