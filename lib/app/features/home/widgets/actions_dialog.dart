import 'package:file_manger/app/features/home/widgets/edit_dialog.dart';
import 'package:file_manger/db/models/server_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../home_controller.dart';

class ActionsDialog extends StatefulWidget {
  final ServerModel serverModel;

  const ActionsDialog({super.key, required this.serverModel});

  @override
  State<ActionsDialog> createState() => _ActionsDialogState();
}

class _ActionsDialogState extends State<ActionsDialog> {
  HomeController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.serverModel.name),
      content: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(LucideIcons.pencil),
              title: const Text('编辑'),
              onTap: () async {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return EditDialog(serverModel: widget.serverModel);
                  },
                );
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.trash),
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
