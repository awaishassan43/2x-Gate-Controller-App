import 'package:flutter/material.dart';
import 'package:iot/screens/editor/editor.screen.dart';

class SectionItem extends StatelessWidget {
  final String title;
  final String? subtitleText;
  final Widget? subtitle;
  final Widget? trailing;
  final String? trailingText;
  final void Function()? onEdit;
  final void Function()? onTap;
  final bool showSeparator;
  final bool showChevron;
  const SectionItem({
    Key? key,
    required this.title,
    this.subtitle,
    this.subtitleText,
    this.trailing,
    this.onEdit,
    this.onTap,
    this.trailingText,
    this.showSeparator = true,
    this.showChevron = false,
  })  : assert((trailing != null || trailingText != null) || (trailing == null && trailingText == null)),
        assert((trailing != null || trailingText != null) || (trailing == null && trailingText == null)),
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
          onPressed: onTap,
          height: 50,
          elevation: 0,
          focusElevation: 0,
          disabledElevation: 0,
          highlightElevation: 0,
          hoverElevation: 0,
          padding: const EdgeInsets.all(0),
          child: Padding(
            padding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 12.5, right: onEdit != null || trailing != null ? 5 : 12.5),
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
                    if (onEdit != null)
                      IconButton(
                        onPressed: () {
                          if (trailingText == null) {
                            return;
                          }

                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return EditorScreen(initialValue: trailingText!, heading: title);
                          }));
                        },
                        constraints: const BoxConstraints(
                          maxHeight: 40,
                          maxWidth: 40,
                        ),
                        icon: const Icon(
                          Icons.edit,
                          size: 20,
                        ),
                      ),
                    if (showChevron)
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 28,
                        color: Colors.black45,
                      ),
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
