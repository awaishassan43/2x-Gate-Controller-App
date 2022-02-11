import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final String? message;
  final bool stretched;
  const Loader({
    Key? key,
    this.message,
    this.stretched = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget renderLoader() {
      return Container(
        color: Colors.white70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              margin: const EdgeInsets.only(top: 50, left: 20, right: 20),
              shape: RoundedRectangleBorder(
                borderRadius: message == null ? BorderRadius.circular(50) : BorderRadius.circular(15),
              ),
              child: Padding(
                padding: message == null ? const EdgeInsets.all(10) : const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                        strokeWidth: 2,
                      ),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        message!,
                        textAlign: TextAlign.center,
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return stretched ? Positioned.fill(child: renderLoader()) : renderLoader();
  }
}
