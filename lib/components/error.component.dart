import 'package:flutter/material.dart';

import 'button.component.dart';

class ErrorMessage extends StatelessWidget {
  final String? message;
  final void Function()? onRetry;
  const ErrorMessage({
    Key? key,
    this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_rounded,
            color: Colors.orange,
            size: 50,
          ),
          const SizedBox(height: 20),
          Text(
            message != null ? message! : 'Something went wrong while loading the list of tables',
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 40),
            CustomButton(
              onPressed: onRetry!,
              text: "Retry",
            ),
          ],
        ],
      ),
    );
  }
}
