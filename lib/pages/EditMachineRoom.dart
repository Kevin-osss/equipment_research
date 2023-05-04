import 'dart:convert';
import 'package:flutter/material.dart';
//* 引入自定义适配屏幕类，进行rpx适配
import '../utils/HYSizeFit.dart';
//* 引入flutter_form_builder
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
//* 引入OKToast插件
import 'package:oktoast/oktoast.dart';
//* 引入自定义成功Toast
import '../utils/Toast/SuccessWidget.dart';
//* 引入自定义失败Toast
import '../utils/Toast/MyErrorWidget.dart';
//* 引入image_picker插件来获取图片
import 'package:image_picker/image_picker.dart';
//* 引入io库可以请求接口
import 'dart:io';
// * 引入SQLite数据库
import 'package:cn_ec_lianjiev5_research/dao/database.dart';
// * 引入封装接口请求类
import '../api/Dioutils.dart';
// * 引入请求体封装类
import '../api/AddroomReq.dart';
//引入加载动画库
import 'package:flutter_spinkit/flutter_spinkit.dart';

class EditRoom extends StatefulWidget {
  final int projectId;
  final int machineRoomId;

  EditRoom({Key? key, this.projectId = 0, this.machineRoomId = 0})
      : super(key: key);

  @override
  State<EditRoom> createState() => _EditRoomState();
}

class _EditRoomState extends State<EditRoom> {
  //* 存放选择图片的路径
  File? _image;
  //* 图片路径
  String? photo;
  //* 创建 ApiService 实例
  final Api = ApiService();
  //* 查询到的机房信息
  late Map<String, dynamic> machineRoomData;
  //* 存储机房信息变量
  late Map<String, dynamic> machineRoomInfo;
  //* 是否正在加载 true 加载中 false加载完毕
  bool loading = true;
  //* 判断修改的数据属于本地刚刚添加或者是直接对云端的数据进行修改
  int? operateType;

  bool autoValidate = true;
  bool readOnly = false;
  bool showSegmentedControl = true;
  final _formKey = GlobalKey<FormBuilderState>();
  bool _room_nameHasError = false; //* 机房名称验证字段
  bool _building_nameHasError = false; //* 楼宇名称验证字段
  bool _floor_numberHasError = false; //* 楼层号称验证字段
  bool _operatorHasError = false; //* 运营商验证字段
  bool _signalHasError = false; //* 信号强度验证字段
  bool _cooling_range_nameHasError = false; //* 供冷范围验证字段
  bool _duty_situationHasError = false; //* 值班情况验证字段
  var operatorOptions = ['移动', '联通', '电信']; //* 运营商选项列表
  var signalOptions = ['强', '中', '弱']; //* 信号强度选项列表
  var DutySituationOptions = ['无人值守', '工程兼管', '专人值守']; //* 值班情况选项列表

  void _onChanged(dynamic val) => debugPrint(val.toString());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // 查询数据，并赋值
    searchMachineRoomData(widget.projectId, widget.machineRoomId).then((res) {
      setState(() {
        loading = false;
      });
    });
  }

  // 根据项目ID 机房ID 设备类型（1） 查询机房的信息
  searchMachineRoomData(int project_id, int machineRoom_id) async {
    List<Map<String, dynamic>> res =
        await MainDBHelper.getDeviceList(project_id, machineRoom_id);
    setState(() {
      machineRoomData = res[0];
      machineRoomInfo = jsonDecode(machineRoomData['base_info']);
    });
    int _operateType = res[0]['operate_type'];
    if (_operateType == 1) {
      // 本地刚添加的机房 对其进行修改 作为添加来进行
      setState(() {
        operateType = 1;
      });
    } else {
      // 其他类型都作为修改来进行
      setState(() {
        operateType = 2;
      });
    }
    return res;
  }

  // 根据项目ID 机房ID 机房类型（1） 更新机房的信息
  updatesearchMachineRoomData(Map<String, dynamic> data) async {
    int res = await MainDBHelper.updateMachineRoom(data);
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
          title:
              Text('修改机房', style: TextStyle(fontSize: HYSizeFit.setPx(20.0))),
          centerTitle: true,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.fromLTRB(HYSizeFit.setPx(10),
                                  0, HYSizeFit.setPx(10), HYSizeFit.setPx(10)),
                              child: FormBuilder(
                                key: _formKey,
                                onChanged: () {
                                  _formKey.currentState!.save(); //* 来保存表单的当前值
                                  // debugPrint(_formKey.currentState!.value
                                  //     .toString()); //* 来输出表单的当前值
                                },
                                autovalidateMode: AutovalidateMode
                                    .disabled, //* 表示表单禁用自动验证表单项。因此，当用户输入数据时，表单不会自动验证表单项，而是等到用户手动提交表单时，才会进行表单验证。
                                //* 表单项默认值
                                initialValue: {
                                  'name': machineRoomInfo['name'], //* 机房名称初始值为空
                                  'building_name': machineRoomInfo[
                                      'building_name'], //* 楼宇名称初始值为空
                                  'floor':
                                      machineRoomInfo['floor'], //* 楼层号初始值为空
                                  'system_id':
                                      machineRoomInfo['system_id'].toString(),
                                  'operator':
                                      machineRoomInfo['operator'], //* 运营商初始值为空
                                  'signal_strength': machineRoomInfo[
                                      'signal_strength'], //* 信号强度初始值为空
                                  'using_season': null, // * 用途
                                  'heating_range': machineRoomInfo[
                                      'heating_range'], //*供冷/热范围
                                  'duty_situation': machineRoomInfo[
                                      'duty_situation'], //* 值班情况初始值为空
                                  'note': machineRoomInfo['note'], //* 备注初始值为空
                                },
                                skipDisabled: true, //* 用于指定是否跳过已禁用（disabled）的选项
                                child: Column(
                                  children: <Widget>[
                                    //* 机房名称表单项
                                    FormBuilderTextField(
                                      autovalidateMode: AutovalidateMode
                                          .always, //* 表示始终在表单控件失去焦点或变化时进行自动验证
                                      name: 'name',
                                      decoration: InputDecoration(
                                        labelText: '机房名称',
                                        suffixIcon: _room_nameHasError
                                            ? const Icon(Icons.error,
                                                color: Colors.red)
                                            : const Icon(Icons.check,
                                                color: Colors.green),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          _room_nameHasError = !(_formKey
                                                  .currentState?.fields['name']
                                                  ?.validate() ??
                                              false);
                                        });
                                      },
                                      validator: FormBuilderValidators.compose(
                                        [
                                          FormBuilderValidators.required(
                                              errorText: '机房名称不能为空'),
                                        ],
                                      ),
                                      textInputAction: TextInputAction
                                          .next, //* 用户点击下一步跳转至下一个表单项
                                    ),
                                    //* 楼宇名称
                                    FormBuilderTextField(
                                      autovalidateMode: AutovalidateMode.always,
                                      name: 'building_name',
                                      decoration: InputDecoration(
                                        labelText: '楼宇名称',
                                        suffixIcon: _building_nameHasError
                                            ? const Icon(Icons.error,
                                                color: Colors.red)
                                            : const Icon(Icons.check,
                                                color: Colors.green),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          _building_nameHasError = !(_formKey
                                                  .currentState
                                                  ?.fields['building_name']
                                                  ?.validate() ??
                                              false);
                                        });
                                      },
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.required(
                                            errorText: '楼宇名称不能为空'),
                                      ]),
                                      textInputAction: TextInputAction.next,
                                    ),
                                    //* 楼层号
                                    FormBuilderTextField(
                                      autovalidateMode: AutovalidateMode.always,
                                      name: 'floor',
                                      decoration: InputDecoration(
                                        labelText: '楼层号',
                                        suffixIcon: _floor_numberHasError
                                            ? const Icon(Icons.error,
                                                color: Colors.red)
                                            : const Icon(Icons.check,
                                                color: Colors.green),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          _floor_numberHasError = !(_formKey
                                                  .currentState?.fields['floor']
                                                  ?.validate() ??
                                              false);
                                        });
                                      },
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.required(
                                            errorText: '楼层号不能为空'),
                                        // FormBuilderValidators
                                        //     .numeric(), //* 限制用户只能输入数字
                                        // FormBuilderValidators.max(
                                        //     100), //* 限制用户输入数字的最大值为100
                                      ]),
                                      keyboardType:
                                          TextInputType.number, //* 直接调用手机的数字键盘
                                      textInputAction: TextInputAction
                                          .next, //* 用户点击下一步跳转至下一个表单项
                                    ),
                                    // 机房类型
                                    FormBuilderRadioGroup<String>(
                                      decoration: const InputDecoration(
                                        labelText: '请选择机房类型',
                                      ),
                                      initialValue: null,
                                      name: 'system_id',
                                      onChanged: _onChanged,
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.required(
                                            errorText: '机房类型不能为空')
                                      ]),
                                      options: const [
                                        FormBuilderFieldOption(
                                            value: '1', child: Text('冷冻站')),
                                        FormBuilderFieldOption(
                                            value: '2', child: Text('热源站')),
                                        FormBuilderFieldOption(
                                            value: '3', child: Text('换热/冷间')),
                                        FormBuilderFieldOption(
                                            value: '4', child: Text('楼内设备')),
                                        FormBuilderFieldOption(
                                            value: '5', child: Text('控制系统')),
                                        FormBuilderFieldOption(
                                            value: '6', child: Text('配电间')),
                                      ],
                                      controlAffinity: ControlAffinity.trailing,
                                    ),
                                    //* 运营商表单项
                                    FormBuilderDropdown<String>(
                                      name: 'operator',
                                      decoration: InputDecoration(
                                        labelText: '运营商',
                                        suffix: _operatorHasError
                                            ? const Icon(Icons.error)
                                            : const Icon(Icons.check),
                                        hintText: '请选择运营商',
                                      ),
                                      validator: FormBuilderValidators.compose(
                                        [
                                          FormBuilderValidators.required(
                                              errorText: '运营商不能为空'),
                                        ],
                                      ),
                                      items: operatorOptions
                                          .map((item) => DropdownMenuItem(
                                                alignment:
                                                    AlignmentDirectional.center,
                                                value: item,
                                                child: Text(item),
                                              ))
                                          .toList(),
                                      onChanged: (val) {
                                        setState(
                                          () {
                                            _operatorHasError = !(_formKey
                                                    .currentState
                                                    ?.fields['operator']
                                                    ?.validate() ??
                                                false);
                                          },
                                        );
                                      },
                                      valueTransformer: (val) => val
                                          ?.toString(), //* 将输入框中的文本内容转换为字符串类型
                                    ),
                                    //* 信号强度表单项
                                    FormBuilderDropdown<String>(
                                      name: 'signal_strength',
                                      decoration: InputDecoration(
                                        labelText: '信号强度',
                                        suffix: _signalHasError
                                            ? const Icon(Icons.error)
                                            : const Icon(Icons.check),
                                        hintText: '请选择信号强度',
                                      ),
                                      validator: FormBuilderValidators.compose(
                                        [
                                          FormBuilderValidators.required(
                                              errorText: '信号强度不能为空'),
                                        ],
                                      ),
                                      items: signalOptions
                                          .map((item) => DropdownMenuItem(
                                                alignment:
                                                    AlignmentDirectional.center,
                                                value: item,
                                                child: Text(item),
                                              ))
                                          .toList(),
                                      onChanged: (val) {
                                        setState(
                                          () {
                                            _signalHasError = !(_formKey
                                                    .currentState
                                                    ?.fields['signal_strength']
                                                    ?.validate() ??
                                                false);
                                          },
                                        );
                                      },
                                      valueTransformer: (val) =>
                                          val?.toString(),
                                    ),
                                    //* 用途表单项
                                    FormBuilderCheckboxGroup<int>(
                                      name: 'using_season',
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      decoration: const InputDecoration(
                                          labelText: '用途'),
                                      options: const [
                                        FormBuilderFieldOption(
                                          child: Text('制冷'),
                                          value: 1,
                                        ),
                                        FormBuilderFieldOption(
                                          child: Text('采暖'),
                                          value: 2,
                                        ),
                                        FormBuilderFieldOption(
                                          child: Text('生活用水'),
                                          value: 3,
                                        ),
                                      ],
                                      onChanged: (val) {
                                        print(val?.join(',') is String);
                                      },
                                      separator: const VerticalDivider(
                                        width: 10,
                                        thickness: 5,
                                        color: Colors.red,
                                      ),
                                      validator: FormBuilderValidators.required(
                                          errorText: '用途不能为空'),
                                    ),
                                    //* 供冷范围
                                    FormBuilderTextField(
                                      autovalidateMode: AutovalidateMode.always,
                                      name: 'heating_range',
                                      decoration: InputDecoration(
                                        labelText: '供冷范围',
                                        suffixIcon: _cooling_range_nameHasError
                                            ? const Icon(Icons.error,
                                                color: Colors.red)
                                            : const Icon(Icons.check,
                                                color: Colors.green),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          _cooling_range_nameHasError =
                                              !(_formKey.currentState
                                                      ?.fields['heating_range']
                                                      ?.validate() ??
                                                  false);
                                        });
                                      },
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.required(
                                            errorText: '供冷范围不能为空'),
                                      ]),
                                      textInputAction: TextInputAction.next,
                                    ),
                                    //* 值班情况
                                    FormBuilderDropdown<String>(
                                      name: 'duty_situation',
                                      decoration: InputDecoration(
                                        labelText: '值班情况',
                                        suffix: _duty_situationHasError
                                            ? const Icon(Icons.error)
                                            : const Icon(Icons.check),
                                        hintText: '请选择值班情况',
                                      ),
                                      validator: FormBuilderValidators.compose(
                                        [
                                          FormBuilderValidators.required(
                                              errorText: '值班情况不能为空'),
                                        ],
                                      ),
                                      items: DutySituationOptions.map(
                                          (item) => DropdownMenuItem(
                                                alignment:
                                                    AlignmentDirectional.center,
                                                value: item,
                                                child: Text(item),
                                              )).toList(),
                                      onChanged: (val) {
                                        setState(
                                          () {
                                            _duty_situationHasError = !(_formKey
                                                    .currentState
                                                    ?.fields['duty_situation']
                                                    ?.validate() ??
                                                false);
                                          },
                                        );
                                      },
                                      valueTransformer: (val) =>
                                          val?.toString(),
                                    ),
                                    //* 备注
                                    FormBuilderTextField(
                                      autovalidateMode: AutovalidateMode.always,
                                      name: 'note',
                                      maxLines: 2, // 设置最大行数为3
                                      decoration: const InputDecoration(
                                        labelText: '备注',
                                        border: InputBorder.none, // 去除输入框下划线
                                      ),
                                      keyboardType: TextInputType
                                          .multiline, // 设置输入类型为多行文本
                                      textInputAction: TextInputAction
                                          .newline, // 设置输入完成后自动换行
                                      // validator: FormBuilderValidators.compose([
                                      //   FormBuilderValidators.required(),
                                      // ]),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(HYSizeFit.setPx(10.0)),
                              width: double.infinity,
                              height: HYSizeFit.setPx(200),
                              color: const Color.fromRGBO(244, 244, 244, 1),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {},
                                    child: const Text('拍照'),
                                  ),
                                  SizedBox(
                                    width: HYSizeFit.setPx(10.0),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      // 从相册获取照片
                                      final pickedFile = await ImagePicker()
                                          .pickImage(
                                              source: ImageSource.gallery);
                                      setState(() {
                                        // 如果用户选择了照片，则更新_image变量以显示照片
                                        if (pickedFile != null) {
                                          _image = File(pickedFile.path);
                                        } else {
                                          print('No image selected.');
                                        }
                                      });
                                    },
                                    child: const Text('相册'),
                                  ),
                                ],
                              ),
                            ),
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
                                    // 时间戳 创建时间
                                    DateTime now = DateTime.now();
                                    int updateTime =
                                        now.millisecondsSinceEpoch ~/ 1000;

                                    if (_formKey.currentState
                                            ?.saveAndValidate() ??
                                        false) {
                                      //* 表单数据不为空
                                      var formData =
                                          _formKey.currentState?.value;
                                      // * 用户填写表单存储的数据
                                      final newFormData = {
                                        ...?formData,
                                        'building_id':
                                            widget.projectId, // 对应项目ID
                                        'system_id': int.parse(formData?[
                                            'system_id']), //系统id tab分类
                                        'photos': photo, // 照片
                                        'using_season':
                                            formData?['using_season'].join(','),
                                        'update_by': 1,
                                        'update_time': updateTime
                                      };
                                      if (operateType == 1) {
                                        // 对本地刚刚添加的项目进行修改   operate_type仍然属于添加
                                        Map<String, dynamic> updatedData = {
                                          'project_id': widget.projectId,
                                          'machineRoom_id':
                                              widget.machineRoomId,
                                          'type': 1, // 机房1 设备2
                                          'table_name':
                                              't_device_add_water_system',
                                          'operate_type': 1, // 修改2 增加1 删除3
                                          'base_info': jsonEncode(newFormData),
                                          'update_time': updateTime,
                                        };
                                        // 调用方法向本地SQLite更新机房信息
                                        updatesearchMachineRoomData(updatedData)
                                            .then((res) {
                                          if (res != null) {
                                            showToastWidget(
                                                SuccessWidget(text: '修改成功'));
                                            Navigator.of(context).pop();
                                          } else {
                                            showToastWidget(
                                                MyErrorWidget(text: '修改失败'));
                                          }
                                        });
                                      } else {
                                        Map<String, dynamic> updatedData = {
                                          'project_id': widget.projectId,
                                          'machineRoom_id':
                                              widget.machineRoomId,
                                          'type': 1, // 机房1 设备2
                                          'table_name':
                                              't_device_add_water_system',
                                          'operate_type': 2, // 修改2 增加1 删除3
                                          'base_info': jsonEncode(newFormData),
                                          'update_time': updateTime,
                                        };
                                        // 调用方法向本地SQLite更新机房信息
                                        updatesearchMachineRoomData(updatedData)
                                            .then((res) {
                                          if (res != null) {
                                            showToastWidget(
                                                SuccessWidget(text: '修改成功'));
                                            Navigator.of(context).pop();
                                          } else {
                                            showToastWidget(
                                                MyErrorWidget(text: '修改失败'));
                                          }
                                        });
                                      }
                                    } else {
                                      //* 表单数据为空
                                      showToast('请先填写机房信息');
                                    }
                                  },
                                  child: Text(
                                    '提交',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: HYSizeFit.setPx(14),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    _formKey.currentState?.reset();
                                    showToastWidget(
                                      SuccessWidget(
                                        text: '重置成功',
                                      ),
                                    );
                                  },
                                  child: Text(
                                    '重置',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: HYSizeFit.setPx(14),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
