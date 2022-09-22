import 'package:flutter/material.dart';

/**
 * @author : jixiaoyong
 * @description ： TODO
 * @email : jixiaoyong1995@gmail.com
 * @date : 9/22/2022
 */
class CachedImageInfo {
  CachedImageInfo( this.url, this.widgetSize,{this.key,});

  String url;
  String? key;
  Size widgetSize;
}
