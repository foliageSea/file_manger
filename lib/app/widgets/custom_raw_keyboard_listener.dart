import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomRawKeyboardListener extends StatefulWidget {
  final Widget child;
  final Function(LogicalKeyboardKey key)? onKey;

  const CustomRawKeyboardListener({super.key, required this.child, this.onKey});

  @override
  State<CustomRawKeyboardListener> createState() =>
      _CustomRawKeyboardListenerState();
}

class _CustomRawKeyboardListenerState extends State<CustomRawKeyboardListener> {
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    focusNode.requestFocus();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: focusNode,
      onKey: _onKey,
      child: widget.child,
    );
  }

  void _onKey(RawKeyEvent event) async {
    if (event.runtimeType == RawKeyDownEvent) {
      if (event.data is RawKeyEventDataWindows) {
        final data = event.data as RawKeyEventDataWindows;
        widget.onKey?.call(data.logicalKey);
      }
    }
  }
}
