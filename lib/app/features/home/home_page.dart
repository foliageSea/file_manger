import 'package:core/core.dart';
import 'package:file_manger/app/features/home/widgets/actions_dialog.dart';
import 'package:file_manger/app/features/home/widgets/add_dialog.dart';
import 'package:file_manger/app/features/home/widgets/files_page.dart';
import 'package:file_manger/app/utils/theme_color_util.dart';
import 'package:flutter/material.dart';
import 'package:file_manger/app/layouts/base_layout.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: 'File Manger',
      actions: [
        IconButton(
          onPressed: () async {
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return const AddDialog();
              },
            );
          },
          icon: const Icon(Icons.add),
        ),
      ],
      child: Obx(() => _buildServers()),
    );
  }

  Widget _buildServers() {
    var servers = controller.servers;

    if (servers.isEmpty) {
      return const Center(child: Icon(LucideIcons.folderMinus));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AlignedGridView.count(
        itemCount: servers.length,
        crossAxisCount: 4,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,

        itemBuilder: (context, index) {
          var server = servers[index];
          return Ink(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              highlightColor: ThemeColorUtil.getPrimaryColorWithAlpha(context),
              onTap: () {
                Get.to(FilesPage(serverModel: server));
              },
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ActionsDialog(serverModel: server);
                  },
                );
              },
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: ThemeColorUtil.getPrimaryColorWithAlpha(context),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.server, size: 30),
                    Text(server.name),
                    Text(
                      server.username,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ].insertSizedBoxBetween(height: 4),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
