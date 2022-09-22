import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

import 'img/cached_image_info.dart';

/**
 * @author : jixiaoyong
 * @description ： 这里的CachedImageInfo会逐渐被清除
 * @email : jixiaoyong1995@gmail.com
 * @date : 9/22/2022
 */
class ImageCacheQueueManage {
  static const String DEFAULT_QUEUE_NAME = "DefaultQueueName";

  static ImageCacheQueueManage _instance = ImageCacheQueueManage._();

  static get instance => _instance;

  ImageCacheQueueManage._();

  final Map<String, Queue<CachedImageInfo>> queueMap = {};
  CachedImageInfo? currentInfo;

  addCacheInfo(CachedImageInfo cacheInfo, {String? key}) {
    var keyOfQueue = key ?? DEFAULT_QUEUE_NAME;
    var queue =
        queueMap.putIfAbsent(keyOfQueue, () => Queue<CachedImageInfo>());
    queue.add(cacheInfo);
    _checkQueue(queue);
  }

  removeCacheInfo(CachedImageInfo cacheInfo, {String? key}) {
    var keyOfQueue = key ?? DEFAULT_QUEUE_NAME;
    var queue =
        queueMap.putIfAbsent(keyOfQueue, () => Queue<CachedImageInfo>());
    queue.remove(cacheInfo);
    _checkQueue(queue);
  }

  cleanQueue({String? key}) {
    var keyOfQueue = key ?? DEFAULT_QUEUE_NAME;
    var queue =
        queueMap.putIfAbsent(keyOfQueue, () => Queue<CachedImageInfo>());
    _checkQueue(queue, cleanAll: true);
  }

  _checkQueue(Queue<CachedImageInfo> cacheImageQueue,
      {bool cleanAll = false}) async {
    if ((!cleanAll && cacheImageQueue.length < 10) || currentInfo != null) {
      return;
    }
    currentInfo = cacheImageQueue.removeFirst();
    var delayMs = 200;
    if (cacheImageQueue.length > 50 || cleanAll) {
      delayMs = 10;
    }
    await Future.delayed(Duration(milliseconds: delayMs));
    try {
      // 因为图片可能还没有加载完毕，所以这里可能还没有图片，所以可能会出错
      var url = currentInfo?.url;
      var size = currentInfo?.widgetSize;

      if (url == null || size == null) {
        return;
      }
      var isRemoved =
          await CachedNetworkImage.evictFromCache(url, onlyCache: true);
      if (!isRemoved) {
        var result = await ResizeImage(
                CachedNetworkImageProvider(
                  url,
                  maxWidth: size.width.toInt(),
                  maxHeight: size.height.toInt(),
                ),
                width: size.width.toInt(),
                height: size.height.toInt())
            .evict();
        print("${url} evict result: $result");
      } else {
        print("${url} evict result: $isRemoved");
      }
    } on Exception catch (e) {
      // do nothing
    } finally {
      currentInfo = null;
    }
  }
}
