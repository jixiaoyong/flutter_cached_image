import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cached_image/flutter_cached_image.dart';

void main() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("flutter cached image"),
      ),
      body: ListView.builder(itemBuilder: (context, index) {
        return FlutterCachedImage(
            imgUrl: "$imgUrl?$index", imageSize: const Size(100, 100));
      }), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
