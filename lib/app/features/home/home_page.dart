import 'package:file_manger/app/features/home/widgets/servers_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return const ServersPage();
  }
}
