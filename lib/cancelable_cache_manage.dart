import 'dart:async';
import 'dart:collection';
import 'dart:io' as io;
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'cancelable_file_service.dart';
import 'resize_task.dart';

/**
 * @author : jixiaoyong
 * @description ： TODO
 * @email : jixiaoyong1995@gmail.com
 * @date : 9/21/2022
 */
class CancelableCacheManage extends CacheManager with ImageCacheManager {
  static const key = 'libCancelableCacheManage';

  static final CancelableCacheManage _cacheManage = CancelableCacheManage._();

  factory CancelableCacheManage.instance() => _cacheManage;

  static final CancelableHttpFileService _fileService =
      CancelableHttpFileService();

  CancelableCacheManage._() : super(Config(key, fileService: _fileService));

  /// Returns a resized image file to fit within maxHeight and maxWidth. It
  /// tries to keep the aspect ratio. It stores the resized image by adding
  /// the size to the key or url. For example when resizing
  /// https://via.placeholder.com/150 to max width 100 and height 75 it will
  /// store it with cacheKey resized_w100_h75_https://via.placeholder.com/150.
  ///
  /// When the resized file is not found in the cache the original is fetched
  /// from the cache or online and stored in the cache. Then it is resized
  /// and returned to the caller.
  Stream<FileResponse> getImageFile(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
    int? maxHeight,
    int? maxWidth,
  }) async* {
    if (maxHeight == null && maxWidth == null) {
      yield* getFileStream(url,
          key: key, headers: headers, withProgress: withProgress);
      return;
    }
    key ??= url;
    var resizedKey = 'resized';
    if (maxWidth != null) resizedKey += '_w$maxWidth';
    if (maxHeight != null) resizedKey += '_h$maxHeight';
    resizedKey += '_$key';

    // 先尝试从缓存中读取压缩过的图片
    var fromCache = await getFileFromCache(resizedKey);
    if (fromCache != null) {
      yield fromCache;
      if (fromCache.validTill.isAfter(DateTime.now())) {
        return;
      }
      withProgress = false;
    }
    // 如果没有的话就从cache或者网络获取未压缩的图片
    var runningResize = _runningResizes[resizedKey];
    if (runningResize == null) {
      runningResize = _fetchedResizedFile(
        url,
        key,
        resizedKey,
        headers,
        withProgress,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      ).asBroadcastStream();
      _runningResizes[resizedKey] = runningResize;
    }
    yield* runningResize;
    _runningResizes.remove(resizedKey);
  }

  final Map<String, Stream<FileResponse>> _runningResizes = {};
  final Queue<ResizeTask> _resizeQueue = Queue();
  ResizeTask? currentResizeTask = null;

  Future<FileInfo> _resizeImageFile(
    FileInfo originalFile,
    String key,
    int? maxWidth,
    int? maxHeight,
  ) async {
    var originalFileName = originalFile.file.path;
    var fileExtension = originalFileName.split('.').last;
    if (!supportedFileNames.contains(fileExtension) ||
        (maxWidth == null && maxHeight == null)) {
      return originalFile;
    }

    var resizeTask = ResizeTask(originalFile.originalUrl, originalFileName,
        Size(maxWidth?.toDouble() ?? 0, maxHeight?.toDouble() ?? 0));
    _resizeQueue.add(resizeTask);
    _checkResizeQueue();

    return originalFile;
  }

  Stream<FileResponse> _fetchedResizedFile(
    String url,
    String originalKey,
    String resizedKey,
    Map<String, String>? headers,
    bool withProgress, {
    int? maxWidth,
    int? maxHeight,
  }) async* {
    await for (var response in getFileStream(
      url,
      key: originalKey,
      headers: headers,
      withProgress: withProgress,
    )) {
      if (response is DownloadProgress) {
        yield response;
      }
      if (response is FileInfo) {
        yield await _resizeImageFile(
          response,
          resizedKey,
          maxWidth,
          maxHeight,
        );
      }
    }
  }

  tryCancelHttpRequest(String url,
      {Map<String, String>? headers, String? requestKey}) {
    _fileService.abortRequest(url, headers: headers, requestKey: requestKey);
  }

  Future<void> _checkResizeQueue() async {
    if (_resizeQueue.isEmpty || currentResizeTask != null) {
      return;
    }
    // background delay
    // await Future.delayed(const Duration(milliseconds: 500));
    // try {
    //   currentResizeTask = _resizeQueue.removeFirst();
    // } catch (e) {
    //   // do nothing here
    // }
    // if (currentResizeTask != null) {
    //   await _composeImageFile(currentResizeTask!);
    // }
  }

  _composeImageFile(ResizeTask task) async {
    cacheLogger.log("compress image:${task.originPath} to ${task.widgetSize}",
        CacheManagerLogLevel.verbose);
    var size = task.widgetSize;

    var file = await FlutterImageCompress.compressAndGetFile(
      task.originPath,
      task.outputPath,
      minHeight: size.height.toInt(),
      minWidth: size.width.toInt(),
    );
    if (file != null) {
      var fileLength = await file.length();
      await updateCacheFilePath(
        task.url,
        task.outputName,
        fileLength,
        key: task.key,
      );
      try {
        // var originPath = io.File(task.originPath);
        // await originPath.delete();
      } on Exception catch (e) {
        // ignore exception
      }
      file = null;
    }
    currentResizeTask = null;
    _checkResizeQueue();
  }
}
