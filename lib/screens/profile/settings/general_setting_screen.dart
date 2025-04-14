import 'package:flutter/material.dart';
import '../../../utilities/components/switch/custom_switch.dart';

final String darkModeButtonText = "Dark Mode";
final String notificationSwitchText = "Notifications";
final String aboutUsButtonText = "About Us";
final String resetButtonText = "Reset to Defaults";
final String reminderText = "Reminder Frequency";
final String reminderSubText = "Daily";
final String notificationText = "Notification Sound";
final String notificationSubText = "Default";

final double horizontalPadding = 16.0;
final double verticalPadding = 8.0;
final double rightArrowIconSize = 16.0;

final Color iconColor = Color(0xFF4EABCC);

final buttonTextStyle = TextStyle(
  fontSize: 15.0,
  fontFamily: 'Hind',
  fontWeight: FontWeight.w500,
  color: Color(0xFF1F1F1F),
);

final aboutUsTextStyle = TextStyle(
  fontSize: 14.0,
  fontFamily: 'Hind',
  fontWeight: FontWeight.w400,
  color: Colors.grey,
);

class generalTab extends StatefulWidget {
  @override
  GeneralTabState createState() => GeneralTabState();
}

class GeneralTabState extends State<generalTab> {
  bool isDarkMode = false;
  bool notificationsEnabled = false;
  bool aboutUsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: Icon(Icons.brightness_6, color: iconColor),
          title: Text(
            darkModeButtonText,
            style: buttonTextStyle,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          trailing: CustomSwitch(
            value: isDarkMode,
            onChanged: (newValue) {
              setState(() => isDarkMode = newValue);
            },
          ),
        ),
        ListTile(
          leading: Icon(Icons.notifications, color: iconColor),
          title: Text(
            notificationSwitchText,
            style: buttonTextStyle,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          trailing: CustomSwitch(
            value: notificationsEnabled,
            onChanged: (newValue) {
              setState(() => notificationsEnabled = newValue);
            },
          ),
        ),
        if (notificationsEnabled) ...[
          generalSettingTile(
            Icons.alarm,
            reminderText,
            reminderSubText,
          ),
          generalSettingTile(
              Icons.volume_up, notificationText, notificationSubText),
        ],
        Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ExpansionTile(
            leading: Icon(Icons.info, color: iconColor),
            title: Text(
              aboutUsButtonText,
              style: buttonTextStyle,
            ),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding, vertical: verticalPadding),
                child: Text(
                  "This is Journal AI, your personal journaling companion. "
                  "Store memories, track habits, and share moments securely.",
                  style: aboutUsTextStyle,
                ),
              ),
            ],
            onExpansionChanged: (expanded) =>
                setState(() => aboutUsExpanded = expanded),
          ),
        ),
        ListTile(
          leading: Icon(Icons.refresh, color: iconColor),
          title: Text(
            resetButtonText,
            style: buttonTextStyle,
          ),
          onTap: () {},
        ),
      ],
    );
  }

  Widget generalSettingTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: buttonTextStyle,
      ),
      subtitle: Text(
        subtitle,
        style: buttonTextStyle.copyWith(
          color: Color(0xFF80858D),
          fontSize: 13.5,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: rightArrowIconSize),
      onTap: () {},
    );
  }
}
