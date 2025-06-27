import 'package:flutter/material.dart';

class CustomIndicator extends StatelessWidget {
  final double value;

  const CustomIndicator({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Text('[已播放: ${(value * 100).toStringAsFixed(0)}%]');
  }
}
