import 'package:core/core.dart';
import 'package:file_manger/app/interfaces/file_storage.dart';
import 'package:file_manger/app/layouts/base_layout.dart';
import 'package:file_manger/app/utils/common_utils.dart';
import 'package:file_manger/app/utils/theme_color_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path/path.dart' show basename;

import '../video/video_page.dart';
import 'history_page_controller.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final controller = Get.put(HistoryPageController());

  @override
  Widget build(BuildContext context) {
    var history = controller.history;
    return BaseLayout(
      title: '历史记录',
      child: Obx(
        () => CustomListView(
          itemCount: history.length,
          itemBuilder: (BuildContext context, int index) {
            var item = history[index];
            var his = item.history;
            var server = item.server;
            var path = his.path;
            var fileName = basename(path);
            var duration = his.duration;
            var name = server.name;
            return ListTile(
              title: Text(
                fileName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('已播放: ${formatDuration(duration)}'),
                  Row(
                    children: [
                      tag(name),
                      Text(path, style: const TextStyle(fontSize: 12)),
                    ].insertSizedBoxBetween(width: 4),
                  ),
                ].insertSizedBoxBetween(height: 4),
              ),
              trailing: IconButton(
                onPressed: () async {
                  await controller.deleteHistory(his);
                },
                icon: const Icon(LucideIcons.trash),
              ),
              onTap: () async {
                var url = item.history.url;
                var token = item.history.token;

                FileItem file = FileItem()
                  ..path = path
                  ..name = fileName;

                await Get.to(
                  VideoPage(
                    url: url,
                    token: token,
                    title: fileName,
                    server: server,
                    fileItem: file,
                  ),
                );
              },
            );
          },
        ),
      ),
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
