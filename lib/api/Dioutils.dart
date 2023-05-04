import 'package:dio/dio.dart';

class ApiService {
  String baseUrl = 'http://172.16.70.9:8106';
  String token =
      'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhaW90djVzZXJ2ZXIiLCJqdGkiOiIyNTMiLCJpYXQiOjE2ODE5NzMwMjksImV4cCI6MTY4NDU2NTAyOX0.omXtcofa2AOSVCaFGQdGIj5xpr5ma5GKlKntFq2f-Vc';

  Future require(String path, req) async {
    return await Dio().post(
      baseUrl + path,
      data: req,
      options: Options(
        headers: {'token': token},
      ),
    );
  }

  bool isOK(int code) {
    if (code == 200) {
      return true;
    } else {
      return false;
    }
  }
}
