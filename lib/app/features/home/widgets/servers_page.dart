import 'package:core/core.dart';
import 'package:file_manger/app/features/history/history_page.dart';
import 'package:file_manger/app/features/star/star_page.dart';
import 'package:file_manger/app/layouts/base_layout.dart';
import 'package:file_manger/app/utils/theme_color_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../home_controller.dart';
import 'actions_dialog.dart';
import 'add_dialog.dart';
import 'files_page.dart';

class ServersPage extends StatefulWidget {
  const ServersPage({super.key});

  @override
  State<ServersPage> createState() => _ServersPageState();
}

class _ServersPageState extends State<ServersPage> {
  HomeController controller = Get.find();

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
        IconButton(
          onPressed: () async {
            await Get.to(const StarPage());
          },
          icon: const Icon(Icons.star_border),
        ),
        IconButton(
          onPressed: () async {
            await Get.to(const HistoryPage());
          },
          icon: const Icon(Icons.history),
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

    var primaryColor = ThemeColorUtil.getPrimaryColor(context);

    var crossAxisCount = MediaQuery.of(context).size.width > 768 ? 2 : 1;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AlignedGridView.count(
        itemCount: servers.length,
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemBuilder: (context, index) {
          var server = servers[index];
          return card(
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
            children: [
              Icon(LucideIcons.server, size: 36, color: primaryColor),
              Text(
                server.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                server.username,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget card({
    void Function()? onTap,
    void Function()? onLongPress,
    List<Widget> children = const <Widget>[],
  }) {
    return Ink(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        highlightColor: ThemeColorUtil.getPrimaryColorWithAlpha(context),
        hoverColor: ThemeColorUtil.getPrimaryColorWithAlpha(context),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: ThemeColorUtil.getPrimaryColorWithAlpha(context),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children.insertSizedBoxBetween(height: 4),
          ),
        ),
      ),
    );
  }
}
