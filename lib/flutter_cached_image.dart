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
      required this.imageUrl,
      required this.imageSize,
      this.placeholder,
      this.cacheQueueKey,
      this.fit,
      this.fadeInDuration = const Duration(milliseconds: 500),
      this.fadeOutDuration = const Duration(milliseconds: 1000),
      this.filterQuality = FilterQuality.low,
      this.progressIndicatorBuilder,
      this.errorWidget})
      : super(key: key);

  /// 属于同一个cacheKey的FlutterCachedImage对应的imageCache中缓存会被一起处理（删除）
  /// [ImageCacheQueueManage.cleanQueue([cacheQueueKey])]
  final String? cacheQueueKey;

  final String imageUrl;

  final Size imageSize;

  /// How to inscribe the image into the space allocated during layout.
  ///
  /// The default varies based on the other fields. See the discussion at
  /// [paintImage].
  final BoxFit? fit;

  /// Widget displayed while the target [imageUrl] is loading.
  final PlaceholderWidgetBuilder? placeholder;

  /// Widget displayed while the target [imageUrl] is loading.
  final ProgressIndicatorBuilder? progressIndicatorBuilder;

  /// Widget displayed while the target [imageUrl] failed loading.
  final LoadingErrorWidgetBuilder? errorWidget;

  /// The duration of the fade-in animation for the [imageUrl].
  final Duration fadeInDuration;

  /// The duration of the fade-out animation for the [placeholder].
  final Duration? fadeOutDuration;

  /// Target the interpolation quality for image scaling.
  ///
  /// If not given a value, defaults to FilterQuality.low.
  final FilterQuality filterQuality;

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
                .tryCancelHttpRequest(widget.imageUrl);
          }
        },
        child: CachedNetworkImage(
          width: imageSize.width,
          height: imageSize.height,
          fit: widget.fit,
          progressIndicatorBuilder: widget.progressIndicatorBuilder,
          errorWidget: widget.errorWidget,
          placeholder: widget.placeholder,
          imageUrl: widget.imageUrl,
          cacheManager: CancelableCacheManage.instance(),
          maxWidthDiskCache: imageSizePx.width.toInt(),
          maxHeightDiskCache: imageSizePx.height.toInt(),
          memCacheHeight: imageSizePx.height.toInt(),
          memCacheWidth: imageSizePx.width.toInt(),
          fadeInDuration: widget.fadeInDuration,
          fadeOutDuration: widget.fadeOutDuration,
          filterQuality: widget.filterQuality,
        ),
      ),
      imageSizePx: imageSizePx,
      onDispose: onDispose,
      onLoad: onLoad,
      url: widget.imageUrl,
    );
  }

  onDispose(CachedImageInfo info) {
    ImageCacheQueueManage.instance.addCacheInfo(info, key: widget.cacheQueueKey);
  }

  onLoad(CachedImageInfo info) {
    ImageCacheQueueManage.instance.removeCacheInfo(info, key: widget.cacheQueueKey);
  }
}
