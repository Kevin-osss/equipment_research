import 'package:flutter/material.dart';

class GlobalStore extends ChangeNotifier {
  List _projectList = []; //* 保存全局共享数据 项目列表

  // * 定义了一个名为myValue的公共getter，该getter可以用于获取_myValue的当前值
  List get projectList => _projectList;

  // * 提供了一个名为setProjectList的公共方法，该方法可以用于设置_projectList变量的值
  void setProjectList(List value) {
    _projectList = value;
    notifyListeners();
  }
}
