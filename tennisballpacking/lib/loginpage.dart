import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tennisballpacking/tennisballpacking.dart';

import 'auth.dart';

var umid;

class NextPage extends StatefulWidget {
  const NextPage({Key? key}) : super(key: key);

  @override
  _NextPageState createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool? _success;
  String? _userEmail;
  var authHandler = new Auth();

  checkUser(va_api) async {
    var response = await http.get(Uri.parse(va_api));
    var data = jsonDecode(response.body);
    for(int i=0;i<data.length;i++){
      if(data[i]['Success'] == ''){
        Widget okbutton = FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'));
        AlertDialog _alert = AlertDialog(
          title: Text('Error'),
          content: Text('${data[i]['Error']}'),
          actions: [okbutton],
        );
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return _alert;
            });
      }
      else{
        setState(() {
          umid = data[i]['um_iId'];
          camState = false;
          camState1 = false;
        });
        Navigator.push(context, MaterialPageRoute(builder: (context)=>TennisBallPacking()));
      }
    }
  }

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async => false,child: Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: const Text('Login Here...',style: TextStyle(fontSize: 30.0,fontWeight: FontWeight.bold),),
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                ),
                // TextFormField(
                //   controller: _emailController,
                //   decoration: const InputDecoration(labelText: 'Email'),
                // ),
                // TextFormField(
                //   controller: _passwordController,
                //   decoration: const InputDecoration(labelText: 'Password'),
                // ),
                // Container(
                //   padding: const EdgeInsets.symmetric(vertical: 16.0),
                //   alignment: Alignment.center,
                //   child: RaisedButton(
                //     onPressed: () async {
                //       authHandler.handlesignin(_emailController.text,_passwordController.text)
                //           .then((user) {
                //         Navigator.push(context, new MaterialPageRoute(builder: (context) => new TennisBallPacking()));
                //       }).catchError((e) => print(e));
                //     },
                //     child: const Text('Submit'),
                //   ),
                // ),
                // Container(
                //   padding: const EdgeInsets.symmetric(vertical: 16.0),
                //   alignment: Alignment.center,
                //   child: RaisedButton(
                //     onPressed: (){
                //       Navigator.push(context, new MaterialPageRoute(builder: (context) => RegisterPage()));
                //     },
                //     child: const Text('Register'),
                //   ),
                // ),
                Container(
                  padding: EdgeInsets.fromLTRB(30, 0, 40, 20),
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Enter Email :',
                    style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ),
                ),
                Container(
                    padding: EdgeInsets.fromLTRB(30, 0, 30, 20),
                    child: TextFormField(
                      autofocus: true,
                      controller: _emailController,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(20.0)))),
                      keyboardType: TextInputType.emailAddress,)),
                Container(
                  padding: EdgeInsets.fromLTRB(30, 0, 40, 20),
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Enter Password :',
                    style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ),
                ),
                Container(
                    padding: EdgeInsets.fromLTRB(30, 0, 30, 20),
                    child: TextFormField(
                      obscureText: true,
                      autofocus: true,
                      controller: _passwordController,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(20.0)))),
                      keyboardType: TextInputType.visiblePassword,)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      alignment: Alignment.center,
                      child: RaisedButton(
                        onPressed: () {
                          var url = "https://13.233.23.219:85/HOme/FetchLoginDetails?LoginId=${_emailController.text}&Password=${_passwordController.text}";
                          // var url = "http://mvplapi.larch.in/HOme/FetchLoginDetails?LoginId=mvpl&Password=mvpl";
                          checkUser(url);
                        },
                        child: const Text('Login'),
                        textColor: Colors.white,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(width: 5.0,),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ), );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
