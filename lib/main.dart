import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
//* 引入自定义适配屏幕工具类，进行rpx适配
import './utils/HYSizeFit.dart';
//* 引入首页
import './pages/HomePage.dart';
// * 引入机房列表页面
import 'pages/MachineRoomList.dart';
// * 引入设备列表页面
import 'pages/MachineRoomDetail.dart';
// * 测试页面
import './pages/test.dart';
// * 添加机房页面
import 'pages/AddMachineRoom.dart';
// * 修改机房页面
import './pages/EditMachineRoom.dart';
// * 引入Provider
import 'package:provider/provider.dart';
import '../store/GlobalStore.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //* 初始化适配文件
    HYSizeFit.initialize(context);
    //* 路由表
    final Map<String, WidgetBuilder> routes = {
      '/computerRoomListPage': (context) => ComputerRoomList(),
      '/testPage': (context) => const TestPage(),
      '/deviceListPage': (context) => DeviceList(),
      '/addComputerRoomPage': (context) => AddRoom(),
      '/editMachineRoomPage': (context) => EditRoom(),
    };

    return OKToast(
      child: ChangeNotifierProvider<GlobalStore>(
        create: (_) => GlobalStore(),
        child: Scaffold(
          body: MaterialApp(
            title: '技术调研',
            // initialRoute: '/testPage',
            routes: routes,
            theme: ThemeData(primarySwatch: Colors.blue),
            home: const HomePage(),
          ),
        ),
      ),
    );
  }
}
