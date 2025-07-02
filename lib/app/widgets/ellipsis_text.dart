import 'package:flutter/cupertino.dart';

class EllipsisText extends Text {
  const EllipsisText(super.data, {super.key, super.style})
    : super(overflow: TextOverflow.ellipsis, maxLines: 1);
}
