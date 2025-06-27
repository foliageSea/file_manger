import 'package:file_manger/app/utils/theme_color_util.dart';
import 'package:flutter/material.dart';

class CustomIndicator extends StatelessWidget {
  final double value;

  const CustomIndicator({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 10,
      height: 10,
      child: CircularProgressIndicator(
        value: value,
        backgroundColor: Colors.grey[300],
        valueColor: AlwaysStoppedAnimation<Color>(
          ThemeColorUtil.getPrimaryColor(context),
        ),
        strokeWidth: 3.0,
      ),
    );
  }
}
