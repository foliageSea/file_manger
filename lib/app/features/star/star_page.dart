import 'package:core/core.dart';
import 'package:file_manger/app/features/star/star_controller.dart';
import 'package:file_manger/app/layouts/base_layout.dart';
import 'package:file_manger/app/utils/file_icon_generator.dart';
import 'package:file_manger/app/utils/theme_color_util.dart';
import 'package:file_manger/db/services/star_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home/widgets/files_page.dart';

class StarPage extends StatefulWidget {
  const StarPage({super.key});

  @override
  State<StarPage> createState() => _StarPageState();
}

class _StarPageState extends State<StarPage> {
  final controller = Get.put(StarController());

  @override
  Widget build(BuildContext context) {
    var starList = controller.starList;
    return BaseLayout(
      title: '收藏',
      actions: [
        IconButton(
          onPressed: () {
            controller.getStarList();
          },
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: Obx(
        () => CustomListView(
          itemCount: starList.length,
          itemBuilder: (BuildContext context, int index) {
            var item = starList[index];
            var name = item.star.name;
            return ListTile(
              leading: FileIconGenerator.getIcon(name, true),
              onTap: () {
                var server = item.server;
                var path = item.star.path;
                Get.to(FilesPage(serverModel: server, path: path));
              },
              title: Text(
                item.star.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: _buildSubTitle(item),
              trailing: IconButton(
                onPressed: () async {
                  await controller.deleteStar(item.star);
                },
                icon: const Icon(Icons.star),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSubTitle(StarFullItem item) {
    var name = item.server.name;
    var path = item.star.path;
    return Row(
      children: [tag(name), tag(path)].insertSizedBoxBetween(width: 8),
    );
  }

  Widget tag(String data) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColorUtil.getPrimaryColor(context).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Text(
        data,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
