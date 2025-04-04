import 'package:flutter/material.dart';
import '../../../utilities/components/switch/custom_switch.dart';

class generalTab extends StatefulWidget {
  @override
  _generalTabState createState() => _generalTabState();
}

class _generalTabState extends State<generalTab> {
  bool isDarkMode = false;
  bool notificationsEnabled = false;
  bool aboutUsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Dark Mode Switch
        ListTile(
          leading: const Icon(Icons.brightness_6, color: Colors.blue),
          title: const Text("Dark Mode"),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          trailing: CustomSwitch(
            value: isDarkMode,
            onChanged: (newValue) {
              setState(() => isDarkMode = newValue);
            },
          ),
        ),

        // Notifications Toggle
        ListTile(
          leading: const Icon(Icons.notifications, color: Colors.blue),
          title: const Text("Notifications"),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          trailing: CustomSwitch(
            value: notificationsEnabled,
            onChanged: (newValue) {
              setState(() => notificationsEnabled = newValue);
            },
          ),
        ),

        if (notificationsEnabled) ...[
          _settingsTile(Icons.alarm, "Reminder Frequency", "Daily"),
          _settingsTile(Icons.volume_up, "Notification Sound", "Default"),
        ],

        // About Us Section
        Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ExpansionTile(
            leading: const Icon(Icons.info, color: Colors.blue),
            title: const Text("About Us"),
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  "This is Journal AI, your personal journaling companion. "
                  "Store memories, track habits, and share moments securely.",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ],
            onExpansionChanged: (expanded) =>
                setState(() => aboutUsExpanded = expanded),
          ),
        ),

        // Reset to Defaults
        ListTile(
          leading: const Icon(Icons.refresh, color: Colors.blue),
          title: const Text("Reset to Defaults"),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _settingsTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }
}
