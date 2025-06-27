import 'package:core/core.dart';
import 'package:file_manger/app/constants/constants.dart';
import 'package:file_manger/app/features/home/home_controller.dart';
import 'package:file_manger/app/interfaces/file_storage.dart';
import 'package:file_manger/app/layouts/base_layout.dart';
import 'package:file_manger/app/utils/common_utils.dart';
import 'package:file_manger/app/utils/file_icon_generator.dart';
import 'package:file_manger/app/utils/theme_color_util.dart';
import 'package:file_manger/app/widgets/horizontal_scroll_with_mouse.dart';
import 'package:file_manger/db/models/server_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class FilesPage extends StatefulWidget {
  final ServerModel serverModel;
  final String? path;

  const FilesPage({super.key, required this.serverModel, this.path});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  HomeController controller = Get.find();
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    controller
        .init(widget.serverModel, widget.path)
        .then((_) => setState(() {}));
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void reload() {
    var currentFile = controller.currentFile;
    if (currentFile == null) {
      return;
    }
    controller.future = controller.readDir(currentFile);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var result = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('提示'),
              content: const Text('是否返回?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('确定'),
                ),
              ],
            );
          },
        );
        return result ?? false;
      },
      child: BaseLayout(
        title: widget.serverModel.name,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Obx(() => _buildPath()),
              Flexible(child: _buildFileListFutureBuilder()),
              _buildTools(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileListFutureBuilder() {
    var errorWidget = CustomFutureBuilder.buildRefreshButton(
      label: '重新加载',
      onPressed: reload,
    );

    return CustomFutureBuilder<List<FileItem>>(
      future: controller.future,
      errorWidget: errorWidget,
      builder: (context, snapshot) {
        return Obx(() => _buildFilesList());
      },
    );
  }

  Widget _buildFilesList() {
    var files = controller.files;
    var sortBy = controller.sortBy;
    var sortOrder = controller.sortOrder;

    if (sortBy.value == SortBy.name) {
      files.sort((a, b) {
        var result = a.name!.compareTo(b.name!);
        return sortOrder.value == SortOrder.asc ? result : -result;
      });
    }
    if (sortBy.value == SortBy.size) {
      files.sort((a, b) {
        var result = a.size!.compareTo(b.size!);
        return sortOrder.value == SortOrder.asc ? result : -result;
      });
    }

    if (sortBy.value == SortBy.lastModified) {
      files.sort((a, b) {
        var result = a.mTime!.compareTo(b.mTime!);
        return sortOrder.value == SortOrder.asc ? result : -result;
      });
    }

    return CustomListView(
      emptyWidget: const Center(child: Icon(LucideIcons.folderMinus)),
      itemCount: files.length,
      itemBuilder: (BuildContext context, int index) {
        var file = files[index];
        return ListTile(
          leading: FileIconGenerator.getIcon(file.name!, file.isDir ?? false),
          trailing: _buildActions(file),
          title: Text('${file.name}'),
          subtitle: _buildSubtitle(file),
          onTap: () async {
            if (file.isDir == true) {
              controller.future = controller.readDir(file);
              setState(() {});
              return;
            }

            await controller.openFile(file, server: widget.serverModel);
          },
        );
      },
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
        // color: ThemeColorUtil.getPrimaryColorWithAlpha(context),
        borderRadius: BorderRadius.circular(4),
      ),
      child: HorizontalScrollWithMouse(
        scrollController: scrollController,
        child: BreadCrumb.builder(
          itemCount: history.length,
          builder: (index) {
            var item = history[index];
            return BreadCrumbItem(
              content: _buildPathItem(item),
              textColor: Colors.white,
              borderRadius: BorderRadius.circular(4),
              padding: const EdgeInsets.all(8),
              onTap: () {
                controller.jumpToDir(index).then((_) {
                  setState(() {});
                });
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

  Widget _buildPathItem(FilesHistory item) {
    return item.path == '/'
        ? const Icon(Icons.home, size: 16)
        : Row(
            children: [
              const Icon(LucideIcons.folder, size: 16),
              Text(
                item.name,
                style: TextStyle(color: ThemeColorUtil.getTextColor(context)),
              ),
            ].insertSizedBoxBetween(width: 4),
          );
  }

  Widget _buildSubtitle(FileItem file) {
    var style = const TextStyle(fontSize: 12);
    if (file.isDir == true) {
      return Text('目录', style: style);
    } else {
      var histories = controller.histories;
      final his = histories.firstWhereOrNull(
        (element) => element.path == file.path,
      );
      if (his != null) {
        return Text(
          '${calFileSize(file.size)} [已播放: ${formatDuration(his.duration)}]',
          style: style,
        );
      }

      return Text(calFileSize(file.size), style: style);
    }
  }

  Widget _buildTools() {
    var sortBy = controller.sortBy;
    var sortOrder = controller.sortOrder;

    Widget fileNameOrder() {
      return sortBy.value == SortBy.name
          ? sortOrder.value == SortOrder.asc
                ? const Icon(Icons.arrow_upward_rounded)
                : const Icon(Icons.arrow_downward_rounded)
          : Container(width: 20);
    }

    Widget fileSizeOrder() {
      return sortBy.value == SortBy.size
          ? sortOrder.value == SortOrder.asc
                ? const Icon(Icons.arrow_upward_rounded)
                : const Icon(Icons.arrow_downward_rounded)
          : Container(width: 20);
    }

    Widget lastModifiedOrder() {
      return sortBy.value == SortBy.lastModified
          ? sortOrder.value == SortOrder.asc
                ? const Icon(Icons.arrow_upward_rounded)
                : const Icon(Icons.arrow_downward_rounded)
          : Container(width: 20);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        PopupMenuButton(
          tooltip: '排序',
          menuPadding: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.sort_rounded),
          // clipBehavior: Clip.hardEdge,
          constraints: const BoxConstraints(minWidth: 200),
          itemBuilder: (BuildContext context) {
            return [
              _buildPopupMenuItem(
                '文件大小',
                trailing: Obx(() => fileSizeOrder()),
                onTap: () async {
                  await controller.updateOrder(SortBy.size);
                },
              ),
              _buildPopupMenuItem(
                '文件名称',
                trailing: Obx(() => fileNameOrder()),
                onTap: () async {
                  await controller.updateOrder(SortBy.name);
                },
              ),
              _buildPopupMenuItem(
                '修改时间',
                trailing: Obx(() => lastModifiedOrder()),
                onTap: () async {
                  await controller.updateOrder(SortBy.lastModified);
                },
              ),
            ];
          },
        ),
      ],
    );
  }

  PopupMenuItem _buildPopupMenuItem(
    String title, {
    Widget? trailing,
    void Function()? onTap,
  }) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: kMinInteractiveDimension,
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(title), trailing ?? Container()],
          ),
        ),
      ),
    );
  }

  Widget? _buildActions(FileItem file) {
    Widget buildStarButton() {
      var stars = controller.stars;

      final isStar = stars.any((element) => element.path == file.path);

      return IconButton(
        onPressed: () async {
          await controller.toggleStarDir(file);
        },
        icon: Icon(isStar ? Icons.star : Icons.star_border),
      );
    }

    if (file.isDir == true) {
      return Obx(() => buildStarButton());
    }

    return null;
  }
}
