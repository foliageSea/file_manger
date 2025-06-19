import 'package:flutter/material.dart';
import 'package:file_manger/app/layouts/base_layout.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(title: 'File Manger', child: Container());
  }
}
