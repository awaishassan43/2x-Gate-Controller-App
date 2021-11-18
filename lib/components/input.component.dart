import 'package:flutter/material.dart';

class CustomInput extends StatefulWidget {
  final IconData? icon;
  final String label;
  final TextEditingController controller;
  final Widget? action;
  final bool isPassword;
  final bool autoFocus;
  final String error;
  final void Function()? onDone;
  const CustomInput({
    Key? key,
    this.icon,
    required this.label,
    required this.controller,
    this.error = '',
    this.action,
    this.isPassword = false,
    this.autoFocus = false,
    this.onDone,
  })  : assert((action == null && isPassword) || (action != null && !isPassword) || (action == null && !isPassword)),
        super(key: key);

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  late bool isHidden;

  @override
  void initState() {
    super.initState();
    isHidden = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: widget.controller,
          autofocus: widget.autoFocus,
          obscureText: isHidden,
          onEditingComplete: widget.onDone,
          textInputAction: widget.onDone != null ? TextInputAction.done : TextInputAction.next,
          style: const TextStyle(
            fontSize: 14,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(widget.icon == null ? 12.5 : 0),
            border: InputBorder.none,
            prefixIcon: widget.icon != null
                ? Icon(
                    widget.icon,
                    size: 20.0,
                  )
                : null,
            hintText: widget.label,
            suffixIcon: widget.action ??
                (widget.isPassword
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            isHidden = !isHidden;
                          });
                        },
                        icon: Icon(
                          isHidden ? Icons.visibility : Icons.visibility_off,
                          size: 22.0,
                        ),
                      )
                    : null),
          ),
        ),
        if (widget.error != '')
          Padding(
            padding: const EdgeInsets.only(top: 2.5),
            child: Text(
              widget.error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          )
      ],
    );
  }
}
