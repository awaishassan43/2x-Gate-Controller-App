import 'package:flutter/material.dart';

class SectionItem extends StatelessWidget {
  final String title;
  final String? subtitleText;
  final Widget? subtitle;
  final Widget? trailing;
  final String? trailingText;
  final void Function()? onTap;
  final bool showSeparator;
  final bool showChevron;
  final bool showEditIcon;
  final bool isDisabled;
  final bool showSwitch;
  final bool? switchValue;
  final void Function(bool value)? onSwitchPressed;

  const SectionItem({
    Key? key,
    required this.title,
    this.subtitle,
    this.subtitleText,
    this.trailing,
    this.onTap,
    this.trailingText,
    this.showSeparator = true,
    this.showChevron = false,
    this.showEditIcon = false,
    this.showSwitch = false,
    this.switchValue,
    this.onSwitchPressed,
    this.isDisabled = false,
  })  :

        /// Only show trailing widget or trailingText or show none
        assert((trailing != null || trailingText != null) || (trailing == null && trailingText == null)),

        /// Only show chevron or edit icon or show none
        assert((showChevron != true || showEditIcon != true) || (showChevron == false && showEditIcon == false)),

        /// Only show switch or trailing widget or show none
        assert((trailing != null || showSwitch) || (trailing == null && !showSwitch)),

        /// In case if switch is shown, then make sure to provide a non-null switch value and an onSwitchPressed function
        assert((!showSwitch) || (showSwitch && switchValue != null && onSwitchPressed != null)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        /**
         * Section item wrapper
         */
        MaterialButton(
          onPressed: isDisabled ? null : onTap,
          height: 50,
          elevation: 0,
          focusElevation: 0,
          disabledElevation: 0,
          highlightElevation: 0,
          hoverElevation: 0,
          disabledColor: Colors.blueGrey.withOpacity(0.1),
          padding: const EdgeInsets.all(0),
          child: Padding(
            padding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 12.5, right: trailing != null ? 5 : 12.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /**
                 * Left Section
                 */
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                          color: Color(0xFF141414),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 5),
                        subtitle!,
                      ],
                      if (subtitleText != null) ...[
                        const SizedBox(height: 5),
                        Text(
                          subtitleText!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.black26,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                /**
                 * End of left section
                 */

                const SizedBox(width: 5),

                /**
                 * Right section
                 */
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (trailingText != null)
                      Text(
                        trailingText!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    if (trailing != null) trailing!,
                    if (showSwitch)
                      Switch(
                        onChanged: isDisabled ? null : onSwitchPressed,
                        value: switchValue!,
                      ),
                    if (showChevron || showEditIcon) ...[
                      if (showEditIcon) const SizedBox(width: 5),
                      Icon(
                        showChevron ? Icons.chevron_right_rounded : Icons.edit,
                        size: showChevron ? 28 : 20,
                        color: Colors.black45,
                      ),
                    ],
                  ],
                ),
                /**
                 * End of right section
                 */
              ],
            ),
          ),
        ),
        /**
         * End of section item wrapper
         */
        if (showSeparator)
          Container(
            height: 0.75,
            color: Colors.black12,
          ),
      ],
    );
  }
}
