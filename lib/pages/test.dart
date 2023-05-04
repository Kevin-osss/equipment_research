import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../api/Dioutils.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  //* 创建 ApiService 实例
  final Api = ApiService();
  // * 网络图片路径列表
  List<String> urls = [
    'https://avatars.githubusercontent.com/u/958063?v=4&s=120',
    'https://avatars.githubusercontent.com/u/18072932?v=4&s=120',
    'https://avatars.githubusercontent.com/u/3118295?v=4&s=120',
    'https://avatars.githubusercontent.com/u/27003009?v=4&s=120'
  ];
  // * 图片缓存到本地的路径
  List localImageUrls = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // * 调用缓存图片的方法
    precacheImages();

    setState(() {
      localImageUrls = getImageList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (localImageUrls.length != 0) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('测试页面'),
        ),
        body: Column(
          children: imageList(),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('测试页面'),
        ),
        body: const Center(
          child: Text('暂无图片'),
        ),
      );
    }
  }

  //* 缓存网络图片的方法
  /*
    CachedNetworkImageProvider(url) 方法创建一个 CachedNetworkImageProvider 对象，该对象表示从给定的URL加载图像。然后，我们调用 resolve(ImageConfiguration()) 方法来解析并下载图像
   */
  void precacheImages() async {
    for (String url in urls) {
      await CachedNetworkImageProvider(url).resolve(ImageConfiguration());
    }
  }

  // * 获取图片缓存的本地信息
  _getImageLocalInfo(String url) {
    // 获取本地图片缓存
    CachedNetworkImageProvider provider =
        CachedNetworkImageProvider(url); //* yrl这里使用你要获取的网络图片地址
    return provider;
  }

  // * 循环遍历图片
  List<Widget> imageList() {
    List<Widget> list = [];
    for (var i = 0; i < localImageUrls.length; i++) {
      list.add(Image(image: localImageUrls[i]));
    }
    return list;
  }

  getImageList() {
    List list = [];
    for (var i = 0; i < urls.length; i++) {
      var res = _getImageLocalInfo(urls[i]);
      list.add(res);
    }
    return list;
  }
}
