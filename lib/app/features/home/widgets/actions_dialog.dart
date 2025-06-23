import 'package:file_manger/db/models/server_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home_controller.dart';

class ActionsDialog extends StatefulWidget {
  final ServerModel serverModel;

  const ActionsDialog({super.key, required this.serverModel});

  @override
  State<ActionsDialog> createState() => _ActionsDialogState();
}

class _ActionsDialogState extends State<ActionsDialog> {
  final controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.serverModel.name),
      content: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('删除'),
              onTap: () async {
                await controller.deleteServer(widget.serverModel);
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
