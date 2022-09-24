import 'package:flutter/material.dart';

/**
 * @author : jixiaoyong
 * @description ： TODO
 * @email : jixiaoyong1995@gmail.com
 * @date : 9/22/2022
 */
class CachedImageInfo {
  const CachedImageInfo(
    this.url,
    this.widgetSize, {
    String? key,
  }) : _key = key;

  final String url;
  final String? _key;
  final Size widgetSize;

  @override
  bool operator ==(dynamic other) {
    if (other is CachedImageInfo) {
      return other.url == url &&
          other.widgetSize == widgetSize &&
          other._key == _key;
    }
    return false;
  }

  get key {
    return _key ??
        "resized_w${widgetSize.width.toInt()}_h${widgetSize.height.toInt()}_${url}";
  }

  int get memorySize {
    return (widgetSize.width * widgetSize.height * 4).toInt();
  }
}
