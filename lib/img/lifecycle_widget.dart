import 'package:flutter/widgets.dart';

import 'cached_image_info.dart';

/**
 * @author : jixiaoyong
 * @description ： TODO
 * @email : jixiaoyong1995@gmail.com
 * @date : 9/22/2022
 */

class LifecycleWidget extends StatefulWidget {
  LifecycleWidget(
      {Key? key,
        required this.child,
        required this.imageSize,
        required this.onDispose,
        required this.onLoad,
        required this.url})
      : super(key: key);

  final Widget child;
  final Size imageSize;
  final String url;

  ValueChanged<CachedImageInfo> onLoad;
  ValueChanged<CachedImageInfo> onDispose;

  @override
  State<LifecycleWidget> createState() => _LifecycleWidgetState();
}

class _LifecycleWidgetState extends State<LifecycleWidget> {
  late CachedImageInfo cachedImageInfo;

  @override
  void initState() {
    super.initState();
    print("$this on init");
    cachedImageInfo = CachedImageInfo(widget.url, widget.imageSize);
    widget.onLoad(cachedImageInfo);
  }

  @override
  void dispose() {
    super.dispose();
    print("$this dispose");
    widget.onDispose(cachedImageInfo);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.child,
    );
  }
}