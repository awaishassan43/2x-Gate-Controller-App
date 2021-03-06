import 'package:flutter/material.dart';
import '/util/themes.util.dart';

class LargeButton extends StatelessWidget {
  final String? text;
  final IconData icon;
  final void Function()? onPressed;
  final String? label;
  final String? bottomText;
  final Color outerColor;
  final Color innerColor;
  final Color iconColor;
  final double iconSize;
  final double outerSize;
  final double innerSize;
  final bool disableElevation;
  final bool isDisabled;

  const LargeButton({
    Key? key,
    required this.icon,
    this.text,
    this.onPressed,
    this.label,
    this.bottomText,
    this.outerColor = const Color(0xFFf8f8f8),
    this.innerColor = Colors.white,
    this.iconColor = textColor,
    this.iconSize = 80,
    this.outerSize = 200,
    this.innerSize = 115,
    this.disableElevation = true,
    this.isDisabled = false,
  })  : assert(outerSize > innerSize && innerSize > iconSize),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<BoxShadow> shadow = [
      BoxShadow(
        color: Colors.black26,
        spreadRadius: 0,
        blurRadius: disableElevation ? 2.5 : 7.5,
      ),
    ];

    /**
     * Note: I know a clipoval would have worked way better than border radius, but the clip oval
     * clips the shadow as well.... I tried adding margin surrounding clip oval but i can't remember
     * why i discarded the idea....
     */
    return Column(
      children: [
        Container(
          constraints: BoxConstraints(
            maxHeight: outerSize,
            maxWidth: outerSize,
          ),
          decoration: BoxDecoration(
            color: outerColor,
            boxShadow: shadow,
            borderRadius: BorderRadius.circular(5000),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  // padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: innerColor,
                    boxShadow: shadow,
                    borderRadius: BorderRadius.circular(999999),
                  ),
                  height: innerSize,
                  width: innerSize,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: iconSize,
                        color: iconColor,
                      ),
                      if (label != null)
                        Text(
                          label!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black38,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: MaterialButton(
                  disabledColor: isDisabled ? Colors.black.withOpacity(0.5) : null,
                  onPressed: isDisabled ? null : onPressed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5000),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (bottomText != null) ...[
          const SizedBox(height: 10),
          Text(
            bottomText!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ],
      ],
    );
  }
}
