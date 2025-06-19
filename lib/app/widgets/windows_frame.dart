import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowsFrame extends StatelessWidget {
  final Widget child;
  final double titleBarHeight;

  const WindowsFrame({
    super.key,
    required this.child,
    this.titleBarHeight = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    if (!Platform.isWindows) {
      return Scaffold(body: child);
    }

    return Scaffold(
      body: Column(
        children: [
          _buildTitleBar(context),
          Flexible(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
      padding: const EdgeInsets.all(4.0),
      child: ClipRRect(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        borderRadius: BorderRadius.circular(8), // 圆角半径
        child: child,
      ),
    );
  }

  Widget _buildTitleBar(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: DragToMoveArea(child: Container(height: titleBarHeight)),
          ),
          SizedBox(
            width: 138,
            height: titleBarHeight,
            child: WindowCaption(
              brightness: Theme.of(context).brightness,
              backgroundColor: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
