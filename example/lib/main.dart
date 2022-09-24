import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cached_image/flutter_cached_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

void main() {
  CacheManager.logLevel = CacheManagerLogLevel.verbose;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String imgUrl = "http://10.30.61.112:8080/port-7418239.jpg";
  var size = const Size(250, 200);
  late Size sizePx;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizePx = size * MediaQuery.of(context).devicePixelRatio;
    print("MediaQuery.of(context).devicePixelRatio;${MediaQuery.of(context).devicePixelRatio};");

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("flutter cached image"),
      ),
      body: ListView.builder(itemBuilder: (context, index) {
        return Stack(
          children: [
            // FlutterCachedImage(
            //   imageUrl: "$imgUrl?$index",
            //   imageSize: const Size(250, 200 ),
            //   fit: BoxFit.fill,
            // ),
            Image.network(
              "$imgUrl?$index",
              height: 200,
              width: 250,
              fit: BoxFit.fill,
              cacheHeight: sizePx.height.toInt(),
              cacheWidth: sizePx.width.toInt(),
            ),
            Text(
              "index$index",
              style: TextStyle(color: Colors.redAccent, fontSize: 30),
            ),
          ],
        );
      }), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
