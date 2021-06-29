import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:otp_verification/success.dart';

//REST API base URL
const baseURL = 'https://renessainfosystems.com/API/eCommerce/';

class OTPVerification extends StatefulWidget {
  const OTPVerification({Key? key}) : super(key: key);

  @override
  _OTPVerificationState createState() => _OTPVerificationState();
}

class _OTPVerificationState extends State<OTPVerification>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  static const int kStartValue = 46; // 46 seconds count down
  bool isCountDownVisible = false;
  bool isMobileVisible = true;
  final _formKey = GlobalKey<FormState>();
  final otpController = TextEditingController();
  final mobileController = TextEditingController();
  //Profile localProfile = Profile();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  double textBoxWidth = 0.0;
  double containerHeight = 0.0;
  double containerWidth = 0.0;
  //OrderSendToServer tempOrderData;
  String mobile = '';
  var pin = 0;
  String rPinText = "";
  var randomNumber = 0;
  var _isExist = false;

  @override
  void dispose() {
    mobileController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controller = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: kStartValue),
    );
    super.initState();
  }

// This method shows count down timer
  _countDownStart() {
    rPinText = "RESEND PIN IN ";
    isCountDownVisible = true; //show count down
    _controller.addStatusListener((status) {
      // enable or show "resend pin" button when timer completed
      if (status == AnimationStatus.completed) {
        print('timer ends');
        setState(() {
          rPinText = "RESEND PIN";
          isCountDownVisible = false; //hide count down
        });
      }
    });
    _controller.forward(from: 0.0);
  }

// This method is used to send random number to server
// server php file will send random number as OTP using SMS gateway
  void _sendOTP(String mobile) async {
    var url = baseURL + "send_otp.php"; //send_otp.php will send otp to user
    //SharedPreferences preferences = await SharedPreferences.getInstance();
    //var userId = preferences.getInt('userid').toString();
    var response = await http.post(Uri.parse(url),
        body: {"mobile": mobile, "otp": randomNumber.toString()});
    if (response.statusCode == 200) {
      //TODO: add code when server returns success
    } else {
      //TODO: add code when server returns failure
    }
  }

// This method is called when user input correct OTP
// Any task after successful OTP verification , can be done here
  void _otpPass(String mobile) async {
    _controller.dispose(); //Dismiss Timer
    FocusScope.of(context).unfocus(); //Dismiss keyboard

    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => Success()));

// _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text("Mobile Verification Success !!", textAlign: TextAlign.center,), ));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      "Mobile Verification Success !!",
      textAlign: TextAlign.center,
    )));
  }

  @override
  Widget build(BuildContext context) {
    containerHeight = MediaQuery.of(context).size.height * 0.45;
    containerWidth = MediaQuery.of(context).size.width;
    textBoxWidth = containerWidth * 0.6;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text('OTP Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 50.0),
        child: Container(
          height: containerHeight,
          width: containerWidth,
          decoration: BoxDecoration(
            color: Colors.lightGreen[100],
            border: Border.all(color: Colors.green[900]!),
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          child: Form(
            key: _formKey,
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 15.0, right: 15.0, top: 50.0),
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                //crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  //SizedBox(height: 77.0),
                  Visibility(
                    visible: isMobileVisible,
                    child: Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Center(
                            child: Text('Enter your mobile number to verify'))),
                  ),
                  Visibility(
                    visible: !isMobileVisible,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[

                          Text('We\'ve sent a PIN number to '),
                          Text(
                            mobile,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Visibility(
                            visible: !isCountDownVisible,
                            child: InkWell(
                                onTap: () {
                                  mobileController.clear();
                                  setState(() {
                                    isMobileVisible = true;
                                  });
                                },
                                child: Icon(
                                  Icons.edit,
                                  size: 20.0,
                                  color: Colors.blue,
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: isMobileVisible,
                    child: SizedBox(
                      //width: textBoxWidth,
                      height: 70.0,
                      child: TextFormField(
                        //enabled:_verifiedMobile ? false : _isTextFieldEnable,
                        controller: mobileController,
                        keyboardType: TextInputType.number,
                        maxLength: 11,
                        decoration: InputDecoration(
                          labelText: 'Your Mobile',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty || value.length < 11) {
                            return 'Pls enter valid mobile i.e 01612426024';
                          }
                          return null;
                        },
                        onSaved: (val) => mobile = val!,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !isMobileVisible,
                    child: SizedBox(
                      //width: textBoxWidth,
                      height: 70.0,
                      child: TextFormField(
                        //enabled:_verifiedMobile ? false : _isTextFieldEnable,
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        decoration: InputDecoration(
                          labelText: 'Enter 4 digit OTP',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          //check if otp entered is null or less than 4 digits
                          if (value!.isEmpty || value.length < 4) {
                            return 'Pls enter 4 digit PIN sent to your mobile';
                          }
                          //check if entered otp is wrong
                          if (value != randomNumber.toString()) {
                            return 'Opps! wrong PIN';
                          }
                          return null;
                        },
                        onSaved: (val) => pin = int.parse(val!),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Visibility(
                    visible: isMobileVisible,
                    child: Container(
                      height: 40.0,
                      decoration: BoxDecoration(
                          border: Border.all(),
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(30.0)),
                      child: InkWell(
                        onTap: () {
                          int min =
                              1000; //min and max values act as your 4 digit range
                          int max = 9999;
                          var randomizer = new Random();
                          randomNumber = min + randomizer.nextInt(max - min);
                          debugPrint('random number =${randomNumber}');
                          otpController.clear();
                          final form = _formKey.currentState;
                          if (form!.validate()) {
                            form.save();
                            //_sendOTP(mobile);
                            setState(() {
                              _countDownStart();
                              isMobileVisible = false;
                            });
                          }
                        },
                        child: Center(
                          child: Text('SEND PIN',
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !isMobileVisible,
                    child: Container(
                      height: 40.0,
                      decoration: BoxDecoration(
                          border: Border.all(),
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(30.0)),
                      child: InkWell(
                        onTap: () {
                          final form = _formKey.currentState;
                          if (form!.validate()) {
                            form.save();
                            debugPrint(
                                'randomNumber = ${randomNumber} pin = ${pin}');
                            pin == randomNumber
                                ? _otpPass(mobile)
                                : debugPrint('otp failed');
                          }
                        },
                        child: Center(
                          child: Text('VERIFY PIN',
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !isMobileVisible,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Didn\'t receive any PIN ?',
                            style: TextStyle(color: Colors.red),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Visibility(
                                visible: !isCountDownVisible,
                                child: InkWell(
                                  child: Text(
                                    rPinText,
                                    style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: Colors.blue),
                                  ),
                                  onTap: () {
                                    int min =
                                        1000; //min and max values act as your 6 digit range
                                    int max = 9999;
                                    var randomizer = new Random();
                                    randomNumber =
                                        min + randomizer.nextInt(max - min);
                                    debugPrint(
                                        'random number =${randomNumber}');
                                    otpController.clear();
                                    setState(() {
                                      _countDownStart();
                                    });
                                  },
                                ),
                              ),
                              Visibility(
                                visible: isCountDownVisible,
                                child: Text(
                                  rPinText,
                                ),
                              ),

                              //child 2
                              Visibility(
                                visible: isCountDownVisible,
                                child: Countdown(
                                  animation: new StepTween(
                                    begin: kStartValue,
                                    end: 0,
                                  ).animate(_controller),
                                ),
                              ),

                            ],
                          ),
                          //here OTP is showing for development purpose,
                          //it will be removed at production phase
                          SizedBox(height: 15.0,),
                          Text('OTP is: $randomNumber'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Countdown extends AnimatedWidget {
  Countdown({Key? key, required this.animation})
      : super(key: key, listenable: animation);
  final Animation<int> animation;

  @override
  build(BuildContext context) {
    return new Text(
      animation.value.toString() + ' SECONDS',
    );
  }
}
