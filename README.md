<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

这个仓库基于[FlutterCacheNetworkImage](https://github.com/Baseflow/flutter_cached_network_image)，在其基础上增加了：
* 下载线程管理（优先当前可视的图片、如果压力过大则自动丢弃最开始的下载任务）
* 图片缓存压缩
* 自动释放不可见图片资源
* ~~后台删除原始图片资源~~


