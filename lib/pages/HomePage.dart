import 'package:flutter/material.dart';
//* 引入自定义适配屏幕工具类，进行rpx适配
import '../utils/HYSizeFit.dart';
import 'dart:async';
// * 引入封装好的娥节流函数
import '../utils/ThrottledFunction.dart';
// * 引入判断网络状态的插件
import 'package:connectivity_plus/connectivity_plus.dart';
// * 引入SQLite数据库
import '../dao/database.dart';
// * 引入封装接口请求类
import '../api/Dioutils.dart';
// * 引入OKToast
import 'package:oktoast/oktoast.dart';
import '../utils/Toast/MyErrorWidget.dart';
import '../utils/Toast/SuccessWidget.dart';
// * 引入Provider  并引入创建的全局变量类
import 'package:provider/provider.dart';
import '../store/GlobalStore.dart';
// * 引入点击震动依赖
import 'package:vibration/vibration.dart';
// * 引入机房列表
import 'MachineRoomList.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //* 创建 Connectivity 实例
  final Connectivity _connectivity = Connectivity();
  //* 创建 ApiService 实例
  final Api = ApiService();
  // * 创建DateTime实例
  DateTime now = DateTime.now();
  // * 输入框控制器
  var _searchController = TextEditingController();
  // * 创建一个Throttle实例
  Throttle _throttle = Throttle(Duration(milliseconds: 500));
  // * 点击非输入框区域时，收起键盘
  FocusNode userFocusNode = FocusNode();
  // * 输入框删除图标是否显示的标识 默认不显示
  bool _showSuffixIcon = false;
  // * 展示列表区域的项目列表的数据
  List _objectData = [];
  // * 搜索的所有数据
  List _totalSearchData = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //* 进入APP查询数据库
    _mainSearchData().then(
      (res) {
        if (res.length == 0) {
          showToast("如果没有你所需的项目,请点击同步按钮后查看");
        } else {
          setState(() {
            _objectData = res;
            _totalSearchData = res;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final globalStore = Provider.of<GlobalStore>(context, listen: false);
    return GestureDetector(
      onTap: () {
        // * 点击非输入框区域时，收起键盘
        userFocusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '项目列表',
            style: TextStyle(fontSize: HYSizeFit.setPx(20.0)),
          ),
          centerTitle: true,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.fromLTRB(HYSizeFit.setPx(10.0),
              HYSizeFit.setPx(10.0), HYSizeFit.setPx(10.0), 0),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: HYSizeFit.setPx(10.0)),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '请输入查询条件',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    hintStyle: TextStyle(
                        fontSize: HYSizeFit.setPx(16.0), color: Colors.grey),
                    suffixIcon: Visibility(
                      visible: _showSuffixIcon,
                      child: IconButton(
                        onPressed: () {
                          // * 点击之后清空输入框输入的数据
                          _searchController.clear();
                          // * 点击之后删除图标消失
                          setState(() {
                            _showSuffixIcon = _searchController.text.isNotEmpty;
                            _objectData = _totalSearchData;
                          });
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  ),
                  controller: _searchController,
                  focusNode: userFocusNode, // * 点击非输入框区域时，收起键盘
                  onChanged: (query) {
                    // * 删除图标消失
                    setState(() {
                      _showSuffixIcon = _searchController.text.isNotEmpty;
                    });
                    // * 搜索数据
                    if (query == '') {
                      setState(() {
                        _objectData = _totalSearchData;
                      });
                    } else {
                      List filteredData = _totalSearchData
                          .where((item) => item['name'].contains(query))
                          .toList();
                      setState(() {
                        _objectData = filteredData;
                      });
                    }
                  },
                ),
              ),
              _objectData.length > 0
                  ? Expanded(
                      flex: 1,
                      child: ListView.builder(
                        itemCount: _objectData.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              // * 点击添加震动效果
                              // Vibration.vibrate(duration: 200);
                              // * 将每个项目的id和name存起来
                              String _name = _objectData[index]['name'];
                              int _id = _objectData[index]['id'];
                              // * 路由跳转
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  transitionDuration:
                                      const Duration(milliseconds: 300),
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      ComputerRoomList(
                                    projectId: _id,
                                  ),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    var begin = Offset(1.0, 0.0);
                                    var end = Offset.zero;
                                    var tween = Tween(begin: begin, end: end);
                                    var offsetAnimation =
                                        animation.drive(tween);
                                    return SlideTransition(
                                      position: offsetAnimation,
                                      child: child,
                                    );
                                  },
                                ),
                              );
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
                                    borderRadius: BorderRadius.circular(
                                        HYSizeFit.setPx(10.0)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _objectData[index]['name']
                                          .substring(0, 2),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: HYSizeFit.setPx(14.0),
                                        letterSpacing: HYSizeFit.setPx(2.0),
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  _objectData[index]['name'],
                                  style: TextStyle(
                                    fontSize: HYSizeFit.setPx(18.0),
                                  ),
                                  maxLines: 1, // * 文字只显示一行,超出显示省略号
                                  overflow: TextOverflow
                                      .ellipsis, // * 文字只显示一行,超出显示省略号
                                ),
                                trailing: Icon(Icons.chevron_right),
                                // subtitle: Divider(color: Colors.grey),   //* 下划线
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          '项目列表为空',
                          style: TextStyle(fontSize: HYSizeFit.setPx(22.0)),
                        ),
                      ),
                    )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // * 先判断有没有网络，有网络可以同步，但是需要每三分钟同步一次
            // * 获取用户点击同步按钮时的时间戳，记录为最近同步时间
            int syncDate = now.microsecondsSinceEpoch;
            // * 调用方法 判断网络状态
            isInternetConnected().then(
              (res) {
                if (res == true) {
                  // * 网络良好    请求数据存入SQLite
                  showToastWidget(
                    SuccessWidget(text: '网络畅通'),
                    duration: const Duration(seconds: 2),
                  );
                  // * 请求项目列表的数据
                  _getProjectListData().then(
                    (res) {
                      // * 声明一个变量用来存储后端返回的数据，方便后续操作
                      List dataList = res.data['data']['projectList'];
                      // * 对后端返回的数据进行处理，返回符合格式要求的数据
                      List updatedDataList = dataList.map((data) {
                        var projectCode = data.remove('projectCode');
                        return {
                          ...data,
                          'project_code': projectCode,
                          'sync_date': syncDate
                        };
                      }).toList();
                      _clearProjectData(); //* 清空项目表中的所有数据
                      // * 利用for循环将数据存入SQLite
                      for (var i = 0; i < updatedDataList.length; i++) {
                        // * 将<dynamic, dynamic>转换为<String, dynamic>
                        var updatedData =
                            updatedDataList[i].cast<String, dynamic>();
                        // * 调用方法存入SQLite
                        _mainInsertProjectData(updatedData);
                      }
                      // * 同时将数据存入全局变量
                      Provider.of<GlobalStore>(context, listen: false)
                          .setProjectList(updatedDataList);
                      // *  将后台接口赋值给页面列表展示数据
                      setState(() {
                        _objectData = updatedDataList;
                        _totalSearchData = updatedDataList;
                      });
                    },
                  );

                  // * 请求其他数据
                  _getOtherListData().then((res) {
                    List oldDataList = res.data['data']['deviceDataList'];
                    List updatedDataList = oldDataList.map((data) {
                      var projectId = data.remove('projectId');
                      var machineRoomId = data.remove('machineRoomId');
                      var deviceId = data.remove('deviceId');
                      var tableName = data.remove('tableName');
                      var operateType = data.remove('operateType');
                      var baseInfo = data.remove('baseInfo');
                      return {
                        ...data,
                        'project_id': projectId,
                        'machineRoom_id': machineRoomId,
                        'device_id': deviceId,
                        'table_name': tableName,
                        'operate_type': operateType,
                        'base_info': baseInfo,
                        'update_time': syncDate
                      };
                    }).toList();
                    _clearDataTable();
                    for (var i = 0; i < updatedDataList.length; i++) {
                      var updatedData =
                          updatedDataList[i].cast<String, dynamic>();
                      _mainInsertDataTable(updatedData);
                    }
                  });
                } else {
                  // 网络故障
                  showToast("请前往网络通畅的地方同步项目");
                }
              },
            );
          },
          child: Icon(
            Icons.sync,
            size: HYSizeFit.setPx(22.0),
          ),
        ),
      ),
    );
  }

  // *封装检测设备网络状态方法
  Future<bool> isInternetConnected() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    } else {
      return true;
    }
  }

  // * 封装向数据库中项目表插入数据的方法
  _mainInsertProjectData(Map<String, dynamic> project) async {
    await MainDBHelper.addProject(project);
  }

  // * 封装向数据库中数据表插入数据的方法
  _mainInsertDataTable(Map<String, dynamic> data) async {
    await MainDBHelper.addData(data);
  }

  // * 封装查询数据库中项目表中所有数据的方法
  _mainSearchData() async {
    List<Map<String, dynamic>> res = await MainDBHelper.getAllProjects();
    return res;
  }

  _mainSearchDataTable() async {
    List<Map<String, dynamic>> res = await MainDBHelper.getAllDatas();
    return res;
  }

  // * 封装清空数据库中项目表中所有数据的方法
  _clearProjectData() async {
    await MainDBHelper.clearProjectTable();
  }

  _clearDataTable() async {
    await MainDBHelper.clearDataTable();
  }

  //* 请求项目列表数据
  _getProjectListData() async {
    var res = await Api.require('/adm/device-research/data-synchronous', {});
    return res;
  }

  //* 请求其他数据
  _getOtherListData() async {
    var res = await Api.require('/adm/device-research/data-synchronous', {});
    return res;
  }
}
