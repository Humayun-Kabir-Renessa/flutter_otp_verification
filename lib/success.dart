import 'package:flutter/material.dart';
import 'package:otp_verification/components/otpVerification.dart';

class Success extends StatelessWidget {
  const Success({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Success'),
      ),
      body: Center(
        child: TextButton(

          onPressed: (){
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => OTPVerification()));
          },
          style: ButtonStyle(

              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                      side: BorderSide(color: Colors.red)
                  )
              )
          ),
          child: Text("Go Back"),
        ),
      ),
    );
  }
}
