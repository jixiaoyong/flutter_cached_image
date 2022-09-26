import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

import 'cancelable_cache_manage.dart';
import 'img/cached_image_info.dart';

/**
 * @author : jixiaoyong
 * @description ： 这里的CachedImageInfo会逐渐被清除
 * @email : jixiaoyong1995@gmail.com
 * @date : 9/22/2022
 */
class ImageCacheQueueManage {
  static const String DEFAULT_QUEUE_NAME = "DefaultQueueName";
  static const int MAX_IMAGE_FILE_SIZE_BYTE = 50 * 1024 * 1024; //50mb
  static const int MAX_IMAGE_PENDING_COUNT = 10;

  static ImageCacheQueueManage _instance = ImageCacheQueueManage._();

  static get instance => _instance;

  ImageCacheQueueManage._();

  final Map<String, Queue<CachedImageInfo>> queueMap = {};
  final Map<String, int> queueSizeMap = {};
  CachedImageInfo? currentInfo;

  addCacheInfo(CachedImageInfo cacheInfo, {String? key}) {
    var keyOfQueue = key ?? DEFAULT_QUEUE_NAME;
    var queue =
        queueMap.putIfAbsent(keyOfQueue, () => Queue<CachedImageInfo>());
    queue.add(cacheInfo);

    int queueSize =
        queueSizeMap.putIfAbsent(keyOfQueue, () => 0) + cacheInfo.memorySize;
    queueSizeMap.update(keyOfQueue, (value) => queueSize);
    _checkQueue(queue, totalMemorySize: queueSize);
  }

  removeCacheInfo(CachedImageInfo cacheInfo, {String? key}) {
    var keyOfQueue = key ?? DEFAULT_QUEUE_NAME;
    var queue =
        queueMap.putIfAbsent(keyOfQueue, () => Queue<CachedImageInfo>());
    var isRemoved = queue.remove(cacheInfo);
    int queueSize = queueSizeMap.putIfAbsent(keyOfQueue, () => 0);
    if (isRemoved) {
      queueSize -= cacheInfo.memorySize;
      if (queueSize < 0) {
        queueSize = 0;
      }
      queueSizeMap.update(keyOfQueue, (value) => queueSize);
    }

    _checkQueue(queue, totalMemorySize: queueSize);
  }

  cleanQueue({String? key}) {
    var keyOfQueue = key ?? DEFAULT_QUEUE_NAME;
    var queue =
        queueMap.putIfAbsent(keyOfQueue, () => Queue<CachedImageInfo>());
    _checkQueue(queue, cleanAll: true);
  }

  _checkQueue(Queue<CachedImageInfo> cacheImageQueue,
      {bool cleanAll = false, int totalMemorySize = 0}) async {
    if ((!cleanAll &&
            cacheImageQueue.length < MAX_IMAGE_PENDING_COUNT &&
            totalMemorySize < MAX_IMAGE_FILE_SIZE_BYTE) ||
        currentInfo != null) {
      return;
    }
    currentInfo = cacheImageQueue.removeFirst();
    var delayMs = 3000;
    if (cacheImageQueue.length > 50 || cleanAll) {
      delayMs = 1000;
    }
    await Future.delayed(Duration(milliseconds: delayMs));
    try {
      // 因为图片可能还没有加载完毕，所以这里可能还没有图片，所以可能会出错
      var url = currentInfo?.url;
      var size = currentInfo?.widgetSize;

      if (currentInfo == null || url == null || size == null) {
        return;
      }
      var isRemoved = await CachedNetworkImage.evictFromCache(url,
          cacheKey: currentInfo!.key,
          onlyCache: true,
          cacheManager: CancelableCacheManage.instance());
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
        print("_checkQueue ${url} evict result: $result");
      } else {
        print("_checkQueue ${url} evict result: $isRemoved");
      }
    } on Exception catch (e) {
      // do nothing
    } finally {
      currentInfo = null;
    }
  }
}
