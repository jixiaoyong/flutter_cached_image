import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

/**
 * @author : jixiaoyong
 * @description ： TODO
 * @email : jixiaoyong1995@gmail.com
 * @date : 9/22/2022
 */
class ResizeTask {
  ResizeTask(this.url, this.originPath, this.widgetSize,
      {String? outputPath, this.minSize}) {
    if (outputPath != null) {
      this.outputPath = outputPath;
      outputName = outputPath.substring(outputPath.lastIndexOf("/"));
    } else {
      var fileExt = originPath.substring(0, originPath.lastIndexOf("/"));
      outputName = "${const Uuid().v1()}.jpg";
      this.outputPath = fileExt + "/" + outputName;
    }
  }

  final String url;
  final String originPath;
  late final String outputPath;
  late final String outputName;
  Size? minSize;
  Size widgetSize;

  get key {
    return "resized_w${widgetSize.width.toInt()}_h${widgetSize.height.toInt()}_${url}";
  }
}
