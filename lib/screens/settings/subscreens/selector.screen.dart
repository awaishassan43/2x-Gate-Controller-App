import 'package:flutter/material.dart';
import 'package:iot/components/loader.component.dart';
import 'package:iot/controllers/device.controller.dart';
import 'package:iot/components/selector.component.dart';
import 'package:provider/provider.dart';

class SelectorScreen extends StatefulWidget {
  final String title;
  final CustomSelector selector;

  const SelectorScreen({
    Key? key,
    required this.title,
    required this.selector,
  }) : super(key: key);

  @override
  State<SelectorScreen> createState() => _SelectorScreenState();
}

class _SelectorScreenState extends State<SelectorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                widget.selector,
              ],
            ),
          ),
          Selector<DeviceController, bool>(
            selector: (context, controller) => controller.isLoading,
            builder: (context, isLoading, _) {
              if (isLoading) return const Loader(message: "Updating controller");
              return Container();
            },
          ),
        ],
      ),
    );
  }
}
