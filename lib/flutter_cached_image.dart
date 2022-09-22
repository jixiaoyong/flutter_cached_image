library flutter_cached_image;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cached_image/img/lifecycle_widget.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'cancelable_cache_manage.dart';
import 'image_cache_queue_manage.dart';
import 'img/cached_image_info.dart';

class FlutterCachedImage extends StatefulWidget {
  FlutterCachedImage(
      {Key? key,
      required this.imgUrl,
      required this.imageSize,
      this.placeholder,
      this.cacheKey,
      this.progressIndicatorBuilder,
      this.errorWidget})
      : super(key: key);

  /// 属于同一个cacheKey的FlutterCachedImage对应的imageCache中缓存会被一起处理（删除）
  /// [ImageCacheQueueManage.cleanQueue([cacheKey])]
  final String? cacheKey;

  final String imgUrl;

  final Size imageSize;

  /// Widget displayed while the target [imageUrl] is loading.
  final PlaceholderWidgetBuilder? placeholder;

  /// Widget displayed while the target [imageUrl] is loading.
  final ProgressIndicatorBuilder? progressIndicatorBuilder;

  /// Widget displayed while the target [imageUrl] failed loading.
  final LoadingErrorWidgetBuilder? errorWidget;

  @override
  State<FlutterCachedImage> createState() => _FlutterCachedImageState();
}

class _FlutterCachedImageState extends State<FlutterCachedImage> {
  late Size imageSizePx;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    imageSizePx = widget.imageSize * MediaQuery.of(context).devicePixelRatio;
  }

  @override
  Widget build(BuildContext context) {
    var imageSize = widget.imageSize;
    return LifecycleWidget(
      child: VisibilityDetector(
        key: UniqueKey(),
        onVisibilityChanged: (VisibilityInfo info) {
          if (info.visibleBounds == Rect.zero) {
            print("try cancel httpRequest");
            CancelableCacheManage.instance()
                .tryCancelHttpRequest(widget.imgUrl);
          }
        },
        child: CachedNetworkImage(
          width: imageSize.width,
          height: imageSize.height,
          fit: BoxFit.cover,
          progressIndicatorBuilder: widget.progressIndicatorBuilder,
          errorWidget: widget.errorWidget,
          placeholder: widget.placeholder,
          imageUrl: widget.imgUrl,
          cacheManager: CancelableCacheManage.instance(),
          maxWidthDiskCache: imageSizePx.width.toInt(),
          maxHeightDiskCache: imageSizePx.height.toInt(),
          memCacheHeight: imageSizePx.width.toInt(),
          memCacheWidth: imageSizePx.height.toInt(),
        ),
      ),
      imageSize: imageSize,
      onDispose: onDispose,
      onLoad: onLoad,
      url: widget.imgUrl,
    );
  }

  onDispose(CachedImageInfo info) {
    ImageCacheQueueManage.instance.addCacheInfo(info, key: widget.cacheKey);
  }

  onLoad(CachedImageInfo info) {
    ImageCacheQueueManage.instance.removeCacheInfo(info, key: widget.cacheKey);
  }
}
