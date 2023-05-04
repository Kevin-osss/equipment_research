import 'package:flutter/material.dart';
import '../HYSizeFit.dart';

class SuccessWidget extends StatelessWidget {
  String text;

  SuccessWidget({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        width: HYSizeFit.setPx(120),
        height: HYSizeFit.setPx(120),
        color: Color.fromRGBO(76, 76, 76, 1),
        child: Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.done,
              size: HYSizeFit.setPx(45),
              color: Colors.white,
            ),
            SizedBox(
              height: HYSizeFit.setPx(5.0),
            ),
            Text(
              text,
              style: TextStyle(
                fontSize: HYSizeFit.setPx(18.0),
              ),
            )
          ],
        ),
      ),
    );
  }
}
