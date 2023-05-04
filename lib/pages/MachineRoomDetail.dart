import 'dart:convert';

import 'package:flutter/material.dart';
//* 引入自定义适配屏幕工具类，进行rpx适配
import '../utils/HYSizeFit.dart';
// * 引入SQLite数据库
import 'package:cn_ec_lianjiev5_research/dao/database.dart';
//引入加载动画库
import 'package:flutter_spinkit/flutter_spinkit.dart';
// 引入修改机房页面
import './EditMachineRoom.dart';
//* 引入OKToast插件
import 'package:oktoast/oktoast.dart';
//* 引入自定义成功Toast
import '../utils/Toast/SuccessWidget.dart';
//* 引入自定义失败Toast
import '../utils/Toast/MyErrorWidget.dart';
import './MachineRoomList.dart';

class DeviceList extends StatefulWidget {
  final int projectId;
  final int machineRoomId;

  const DeviceList({Key? key, this.projectId = 0, this.machineRoomId = 0})
      : super(key: key);

  @override
  State<DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  //* 查询到的机房信息
  late Map<String, dynamic> machineRoomData;
  //* 存储机房信息变量
  late Map<String, dynamic> machineRoomInfo;
  //* 是否正在加载 true 加载中 false加载完
  bool loading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // 查询数据，并赋值
    searchDeviceData(widget.projectId, widget.machineRoomId).then((res) {
      setState(() {
        loading = false;
      });
    });
  }

  // 根据项目ID 机房ID 设备类型（2） 查询机房下设备列表的信息
  searchDeviceData(int project_id, int machineRoom_id) async {
    List<Map<String, dynamic>> res =
        await MainDBHelper.getDeviceList(project_id, machineRoom_id);
    setState(() {
      machineRoomData = res[0];
      machineRoomInfo = jsonDecode(machineRoomData['base_info']);
    });
    return res;
    //machineRoomInfo['base_info']为String型，需要转换为Map才能直接使用
    // print(jsonDecode(machineRoomData['base_info']));
  }

  //根据项目ID 机房ID 机房类型（1） 删除机房
  deleteMachineRoom(int project_id, int machineRoom_id) async {
    int res = await MainDBHelper.deleteMachineRoom(project_id, machineRoom_id);
    return res;
  }

  @override
  Widget build(BuildContext context) {
    //* 获取屏幕的宽度和高度
    final size = MediaQuery.of(context).size;
    if (loading == false) {
      //加载完成
      return Scaffold(
        appBar: AppBar(
          title: Text(
            machineRoomInfo['name'],
            style: TextStyle(fontSize: HYSizeFit.setPx(20.0)),
          ),
          centerTitle: true,
          actions: [
            ElevatedButton.icon(
                onPressed: () {
                  // * 路由跳转
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 500),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          EditRoom(
                        projectId: widget.projectId,
                        machineRoomId: widget.machineRoomId,
                      ),
                      transitionsBuilder: (_, animation, __, child) {
                        return ScaleTransition(
                          scale: animation,
                          alignment: Alignment.bottomRight,
                          child: child,
                        );
                      },
                    ),
                  ).then((value) {
                    searchDeviceData(widget.projectId, widget.machineRoomId);
                  });
                },
                icon: const Icon(Icons.edit),
                label: const Text('修改'))
          ],
        ),
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.all(HYSizeFit.setPx(10.0)),
              child: ListView(
                children: [
                  // 机房名称
                  Container(
                    height: HYSizeFit.setPx(45.0),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                          '机房名称',
                          style: TextStyle(fontSize: HYSizeFit.setPx(16.0)),
                        )),
                        Expanded(
                          flex: 1,
                          child: Text(
                            machineRoomInfo['name'] == null ||
                                    machineRoomInfo['name'] == ''
                                ? '暂无信息'
                                : machineRoomInfo['name'],
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: HYSizeFit.setPx(14.0)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: HYSizeFit.setPx(1.0),
                    color: Colors.grey,
                  ),
                  // 楼宇名称
                  Container(
                    height: HYSizeFit.setPx(45.0),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                          '楼宇名称',
                          style: TextStyle(fontSize: HYSizeFit.setPx(16.0)),
                        )),
                        Expanded(
                          flex: 1,
                          child: Text(
                            machineRoomInfo['building_name'] == null ||
                                    machineRoomInfo['building_name'] == ''
                                ? '暂无信息'
                                : machineRoomInfo['building_name'],
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: HYSizeFit.setPx(14.0)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: HYSizeFit.setPx(1.0),
                    color: Colors.grey,
                  ),
                  // 楼层号
                  Container(
                    height: HYSizeFit.setPx(45.0),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                          '楼层号',
                          style: TextStyle(fontSize: HYSizeFit.setPx(16.0)),
                        )),
                        Expanded(
                          flex: 1,
                          child: Text(
                            machineRoomInfo['floor'] == null ||
                                    machineRoomInfo['floor'] == ''
                                ? '暂无信息'
                                : machineRoomInfo['floor'],
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: HYSizeFit.setPx(14.0)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: HYSizeFit.setPx(1.0),
                    color: Colors.grey,
                  ),
                  // 运营商
                  Container(
                    height: HYSizeFit.setPx(45.0),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                          '运营商',
                          style: TextStyle(fontSize: HYSizeFit.setPx(16.0)),
                        )),
                        Expanded(
                          flex: 1,
                          child: Text(
                            machineRoomInfo['operator'] == null ||
                                    machineRoomInfo['operator'] == ''
                                ? '暂无信息'
                                : machineRoomInfo['operator'],
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: HYSizeFit.setPx(14.0)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: HYSizeFit.setPx(1.0),
                    color: Colors.grey,
                  ),
                  // 信号强度
                  Container(
                    height: HYSizeFit.setPx(45.0),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                          '信号强度',
                          style: TextStyle(fontSize: HYSizeFit.setPx(16.0)),
                        )),
                        Expanded(
                          flex: 1,
                          child: Text(
                            machineRoomInfo['signal_strength'] == null ||
                                    machineRoomInfo['signal_strength'] == ''
                                ? '暂无信息'
                                : machineRoomInfo['signal_strength'],
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: HYSizeFit.setPx(14.0)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: HYSizeFit.setPx(1.0),
                    color: Colors.grey,
                  ),
                  // 用途
                  Container(
                    height: HYSizeFit.setPx(45.0),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                          '用途',
                          style: TextStyle(fontSize: HYSizeFit.setPx(16.0)),
                        )),
                        Expanded(
                          flex: 1,
                          child: Text(
                            machineRoomInfo['using_season'] == null ||
                                    machineRoomInfo['using_season'] == ''
                                ? '暂无信息'
                                : machineRoomInfo['using_season'],
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: HYSizeFit.setPx(14.0)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: HYSizeFit.setPx(1.0),
                    color: Colors.grey,
                  ),
                  // 供冷供热范围
                  Container(
                    height: HYSizeFit.setPx(45.0),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                          '供冷/热范围',
                          style: TextStyle(fontSize: HYSizeFit.setPx(16.0)),
                        )),
                        Expanded(
                          flex: 1,
                          child: Text(
                            machineRoomInfo['heating_range'] == null ||
                                    machineRoomInfo['heating_range'] == ''
                                ? '暂无信息'
                                : machineRoomInfo['heating_range'],
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: HYSizeFit.setPx(14.0)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: HYSizeFit.setPx(1.0),
                    color: Colors.grey,
                  ),
                  // 值班情况
                  Container(
                    height: HYSizeFit.setPx(45.0),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                          '值班情况',
                          style: TextStyle(fontSize: HYSizeFit.setPx(16.0)),
                        )),
                        Expanded(
                          flex: 1,
                          child: Text(
                            machineRoomInfo['duty_situation'] == null ||
                                    machineRoomInfo['duty_situation'] == ''
                                ? '暂无信息'
                                : machineRoomInfo['duty_situation'],
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: HYSizeFit.setPx(14.0)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: HYSizeFit.setPx(1.0),
                    color: Colors.grey,
                  ),
                  // 备注
                  Container(
                    height: HYSizeFit.setPx(45.0),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                          '备注',
                          style: TextStyle(fontSize: HYSizeFit.setPx(16.0)),
                        )),
                        Expanded(
                          flex: 1,
                          child: Text(
                            machineRoomInfo['duty_situation'] == null ||
                                    machineRoomInfo['duty_situation'] == ''
                                ? '暂无备注'
                                : machineRoomInfo['duty_situation'],
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: HYSizeFit.setPx(14.0)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: HYSizeFit.setPx(1.0),
                    color: Colors.grey,
                  ),
                  // 系统原理图
                  Container(
                    // height: HYSizeFit.setPx(100.0),
                    // color: Colors.yellow,
                    margin: EdgeInsets.only(top: HYSizeFit.setPx(10.0)),
                    child: Column(
                      children: [
                        Container(
                          height: HYSizeFit.setPx(45.0),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(
                                '系统原理图',
                                style:
                                    TextStyle(fontSize: HYSizeFit.setPx(16.0)),
                              ))
                            ],
                          ),
                        ),
                        Container(
                          height: HYSizeFit.setPx(45.0),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(
                                '暂无照片',
                                style: TextStyle(
                                    fontSize: HYSizeFit.setPx(14.0),
                                    color: Colors.grey),
                              ))
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              width: size
                  .width, //需要给Position加上宽度和高度（此处的宽度和高度指的是Position的子组件的宽度和高度）,否则定位无法实现   宽度和高度没有办法使用double.infinity
              height: HYSizeFit.setPx(60),
              child: Container(
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // 用户模态框
                          showDialog(
                            context: context,
                            barrierDismissible:
                                false, // 设置该参数为false，禁止点击遮罩层关闭模态框
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('警告'),
                                content: Text('您确定要删除这个机房吗？'),
                                actions: <Widget>[
                                  ElevatedButton(
                                    child: Text('取消'),
                                    onPressed: () {
                                      Navigator.of(context).pop(); // 关闭弹窗
                                    },
                                  ),
                                  ElevatedButton(
                                    child: Text('确定'),
                                    onPressed: () {
                                      searchDeviceData(widget.projectId,widget.machineRoomId).then((res){
                                        print(res);
                                      });
                                      // deleteMachineRoom(widget.projectId,
                                      //         widget.machineRoomId)
                                      //     .then((res) {
                                      //   if (res != null) {
                                      //     Navigator.of(context).pop();
                                      //     showToastWidget(
                                      //         SuccessWidget(text: '删除成功'));
                                      //     // * 路由跳转
                                      //     Navigator.pushAndRemoveUntil(
                                      //       context,
                                      //       PageRouteBuilder(
                                      //         transitionDuration:
                                      //             const Duration(
                                      //                 milliseconds: 500),
                                      //         pageBuilder: (context, animation,
                                      //                 secondaryAnimation) =>
                                      //             ComputerRoomList(
                                      //                 projectId:
                                      //                     widget.projectId),
                                      //         transitionsBuilder:
                                      //             (_, animation, __, child) {
                                      //           return ScaleTransition(
                                      //             scale: animation,
                                      //             alignment:
                                      //                 Alignment.bottomRight,
                                      //             child: child,
                                      //           );
                                      //         },
                                      //       ),
                                      //       (Route<dynamic> route) =>
                                      //           route.isFirst,
                                      //     );
                                      //   } else {
                                      //     showToastWidget(
                                      //         MyErrorWidget(text: '修改失败'));
                                      //   }
                                      // });
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text(
                          '删除',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: HYSizeFit.setPx(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      );
    } else {
      //加载未完成
      return Scaffold(
        appBar: AppBar(
          title: Text(
            '机房信息',
            style: TextStyle(fontSize: HYSizeFit.setPx(20.0)),
          ),
          centerTitle: true,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: const SpinKitFadingCircle(
            color: Colors.blue,
            size: 50.0,
          ),
        ),
      );
    }
  }
}
