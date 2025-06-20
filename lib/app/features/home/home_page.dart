import 'package:core/core.dart';
import 'package:file_manger/app/interfaces/file_storage.dart';
import 'package:file_manger/app/utils/common_utils.dart';
import 'package:file_manger/app/utils/file_icon_generator.dart';
import 'package:file_manger/app/utils/theme_color_util.dart';
import 'package:flutter/material.dart';
import 'package:file_manger/app/layouts/base_layout.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
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
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.init().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void reload() {
    var currentFile = controller.currentFile;
    controller.future = controller.readDir(currentFile);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: 'File Manger',
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Obx(() => _buildPath()),
            Flexible(child: _buildFileListFutureBuilder()),
          ],
        ),
      ),
    );
  }

  Widget _buildFileListFutureBuilder() {
    var errorWidget = CustomFutureBuilder.buildRefreshButton(
      label: '重新加载',
      onPressed: reload,
    );

    return CustomFutureBuilder<List<StorageFileItem>>(
      future: controller.future,
      errorWidget: errorWidget,
      builder: (context, snapshot) {
        return _buildFilesList();
      },
    );
  }

  Widget _buildFilesList() {
    var files = controller.files;
    return Obx(
      () => CustomListView(
        emptyWidget: const Center(child: Icon(LucideIcons.folderMinus)),
        itemCount: files.length,
        itemBuilder: (BuildContext context, int index) {
          var file = files[index];
          return ListTile(
            leading: FileIconGenerator.getIcon(file.name!, file.isDir ?? false),
            title: Text('${file.name}'),
            subtitle: _buildSubtitle(file),
            onTap: () async {
              if (file.isDir == true) {
                controller.future = controller.readDir(file);
                setState(() {});
                return;
              }

              await controller.openFile(file);
            },
          );
        },
      ),
    );
  }

  Widget _buildPath() {
    var history = controller.history;
    if (history.isEmpty) {
      return Container();
    }
    return Container(
      width: double.infinity,
      height: 50,
      padding: const EdgeInsets.only(left: 8, right: 8),
      decoration: BoxDecoration(
        color: ThemeColorUtil.getPrimaryColorWithAlpha(context),
        borderRadius: BorderRadius.circular(4),
      ),
      child: HorizontalScrollWithMouse(
        scrollController: scrollController,
        child: BreadCrumb.builder(
          itemCount: history.length,
          builder: (index) {
            var item = history[index];
            return BreadCrumbItem(
              content: item.path == '主页'
                  ? const Icon(Icons.home, size: 16)
                  : Row(
                      children: [
                        const Icon(LucideIcons.folder, size: 16),
                        Text(item.path),
                      ].insertSizedBoxBetween(width: 4),
                    ),
              textColor: Colors.white,
              borderRadius: BorderRadius.circular(4),
              padding: const EdgeInsets.all(8),
              onTap: () {
                controller.jumpToDir(index);
              },
            );
          },
          divider: const Icon(Icons.chevron_right),
          overflow: ScrollableOverflow(
            keepLastDivider: false,
            reverse: false,
            direction: Axis.horizontal,
            controller: scrollController,
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle(StorageFileItem file) {
    var style = const TextStyle(fontSize: 12);
    if (file.isDir == true) {
      return Text('目录', style: style);
    } else {
      return Text(calFileSize(file.size), style: style);
    }
  }
}

class HorizontalScrollWithMouse extends StatefulWidget {
  final ScrollController scrollController;
  final Widget child;

  const HorizontalScrollWithMouse({
    super.key,
    required this.scrollController,
    required this.child,
  });
  @override
  State<HorizontalScrollWithMouse> createState() =>
      _HorizontalScrollWithMouseState();
}

class _HorizontalScrollWithMouseState extends State<HorizontalScrollWithMouse> {
  late ScrollController _scrollController;

  double _dragStartX = 0;

  @override
  void initState() {
    _scrollController = widget.scrollController;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        _dragStartX = event.position.dx; // 记录拖拽起始位置
      },
      onPointerMove: (event) {
        // 计算水平位移，反向滚动（因为手指拖拽方向与滚动方向相反）
        double delta = _dragStartX - event.position.dx;
        _scrollController.jumpTo(_scrollController.offset + delta);
        _dragStartX = event.position.dx; // 更新起始位置
      },
      child: widget.child,
    );
  }
}
