import 'package:flutter/material.dart';
//* 引入自定义适配屏幕工具类，进行rpx适配
import '../utils/HYSizeFit.dart';
// * 引入SQLite数据库
import 'package:cn_ec_lianjiev5_research/dao/database.dart';
// * 引入点击震动依赖
import 'package:vibration/vibration.dart';
// * 引入设备列表页面
import 'MachineRoomDetail.dart';
// * 引入封装接口请求类
import '../api/Dioutils.dart';
//dart内置库
import 'dart:convert';
import 'dart:async';
//
import 'AddMachineRoom.dart';
//引入加载动画库
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ComputerRoomList extends StatefulWidget {
  final int projectId;

  //* 构造函数
  /*
    将 projectId 的默认值设置为 0，这样即使在创建 ComputerRoomList Widget 时不传递 projectId 参数，它也不会是 null
  */
  ComputerRoomList({Key? key, this.projectId = 0}) : super(key: key);

  @override
  State<ComputerRoomList> createState() => _ComputerRoomListState();
}

class _ComputerRoomListState extends State<ComputerRoomList> {
  //* 创建 ApiService 实例
  final Api = ApiService();
  // * 机房列表
  List machineRoomList = [];
  //* 加载动画是否显示    true 显示 false不显示
  bool loading = true;

  Future<void>? _searchProjectInfoFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    searchProjectInfo(widget.projectId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  // * 封装根据项目id查询项目下的具体信息方法
  searchProjectInfo(int id) async {
    // 查询SQLite返回的数据
    List<Map<String, dynamic>> res = await MainDBHelper.getMachineRoomList(id);
    // 对返回的数据进行过滤，返回有用的字段
    List<Map<String, dynamic>> filteredData = res
        .map((e) => {
              'project_id': e['project_id'],
              'machineRoom_id': e['machineRoom_id'],
              'base_info': jsonDecode(e['base_info'])
            })
        .toList();
    // 赋值
    setState(() {
      machineRoomList =
          filteredData; // res 中的base_info为String类型 需要使用json.decode转换为Map类型
      loading = false;
    });
    return res;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      // 正在加载中
      return Scaffold(
        appBar: AppBar(
          title:
              Text('机房列表', style: TextStyle(fontSize: HYSizeFit.setPx(20.0))),
          centerTitle: true,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.fromLTRB(HYSizeFit.setPx(10.0),
              HYSizeFit.setPx(10.0), HYSizeFit.setPx(10.0), 0),
          // color: Colors.amber,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: const SpinKitFadingCircle(
              color: Colors.blue,
              size: 50.0,
            ),
          ),
        ),
      );
    } else {
      // 加载完毕  如果有数据显示数据 没有数据显示暂无数据
      if (machineRoomList.length == 0) {
        return Scaffold(
          appBar: AppBar(
            title:
                Text('机房列表', style: TextStyle(fontSize: HYSizeFit.setPx(20.0))),
            centerTitle: true,
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.fromLTRB(HYSizeFit.setPx(10.0),
                HYSizeFit.setPx(10.0), HYSizeFit.setPx(10.0), 0),
            // color: Colors.amber,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Text(
                '暂时没有机房',
                style: TextStyle(fontSize: HYSizeFit.setPx(20.0)),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            // 跳转添加机房页面   传递项目ID
            onPressed: () {
              int _projectId = widget.projectId; // 项目ID
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 300),
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      AddRoom(projectId: _projectId),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    var begin = Offset(1.0, 0.0);
                    var end = Offset.zero;
                    var tween = Tween(begin: begin, end: end);
                    var offsetAnimation = animation.drive(tween);
                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ),
              ).then((value){
                searchProjectInfo(widget.projectId).then((res){
                  print(res);
                });
              });
            },
            child: Icon(
              Icons.add,
              size: HYSizeFit.setPx(22.0),
            ),
          ),
        );
      } else {
        return Scaffold(
          appBar: AppBar(
            title:
                Text('机房列表', style: TextStyle(fontSize: HYSizeFit.setPx(20.0))),
            centerTitle: true,
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.only(top: HYSizeFit.setPx(10.0)),
            child: ListView.builder(
              itemCount: machineRoomList.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    // 点击对应机房跳转至机房详情 传递项目ID和机房ID
                    int _projectId = widget.projectId; // 项目ID
                    int _machineRoomId =
                        machineRoomList[index]['machineRoom_id']; // 机房ID
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 300),
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            DeviceList(
                                projectId: _projectId,
                                machineRoomId: _machineRoomId),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          var begin = Offset(1.0, 0.0);
                          var end = Offset.zero;
                          var tween = Tween(begin: begin, end: end);
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                    ).then((value){
                      searchProjectInfo(widget.projectId);
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      bottom: HYSizeFit.setPx(10.0),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: HYSizeFit.setPx(50.0),
                        height: HYSizeFit.setPx(50.0),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius:
                              BorderRadius.circular(HYSizeFit.setPx(10.0)),
                        ),
                        child: Center(
                          child: Text(
                            machineRoomList[index]['base_info']['name']
                                .substring(0, 1),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: HYSizeFit.setPx(14.0),
                              letterSpacing: HYSizeFit.setPx(2.0),
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        machineRoomList[index]['base_info']['name'],
                        style: TextStyle(
                          fontSize: HYSizeFit.setPx(18.0),
                        ),
                        maxLines: 1, // * 文字只显示一行,超出显示省略号
                        overflow: TextOverflow.ellipsis, // * 文字只显示一行,超出显示省略号
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      // subtitle: Divider(color: Colors.grey),   //* 下划线
                    ),
                  ),
                );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            // 跳转添加机房页面   传递项目ID
            onPressed: () {
              int _projectId = widget.projectId; // 项目ID
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 300),
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      AddRoom(projectId: _projectId),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    var begin = Offset(1.0, 0.0);
                    var end = Offset.zero;
                    var tween = Tween(begin: begin, end: end);
                    var offsetAnimation = animation.drive(tween);
                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ),
              ).then((value) {
                searchProjectInfo(widget.projectId);
              });
            },
            child: Icon(
              Icons.add,
              size: HYSizeFit.setPx(22.0),
            ),
          ),
        );
      }
    }
  }
}
