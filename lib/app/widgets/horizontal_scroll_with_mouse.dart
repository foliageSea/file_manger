import 'package:flutter/material.dart';

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
