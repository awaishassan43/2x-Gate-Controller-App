import 'package:flutter/material.dart';

class CustomInput extends StatefulWidget {
  final IconData? icon;
  final String label;
  final TextEditingController controller;
  final Widget? action;
  final bool isPassword;
  final bool autoFocus;
  const CustomInput({
    Key? key,
    this.icon,
    required this.label,
    required this.controller,
    this.action,
    this.isPassword = false,
    this.autoFocus = false,
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
    return TextFormField(
      controller: widget.controller,
      autofocus: widget.autoFocus,
      obscureText: isHidden,
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
    );
  }
}
