import 'package:flutter/material.dart';
import 'package:tennisballpacking/loginpage.dart';

import 'auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  var authHandler = new Auth();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: const Text('Register Here...',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30.0),),
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
                //       authHandler.handlesignup(_emailController.text,_passwordController.text)
                //           .then((user) {
                //         Navigator.push(context, new MaterialPageRoute(builder: (context) => new NextPage()));
                //       }).catchError((e) => print(e));
                //     },
                //     child: const Text('Submit'),
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
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  alignment: Alignment.center,
                  child: RaisedButton(
                    onPressed: () async {
                      authHandler.handlesignup(_emailController.text,_passwordController.text)
                          .then((user) {
                        Widget okbutton = FlatButton(
                            onPressed: () {
                              Navigator.push(context, new MaterialPageRoute(builder: (context) => new NextPage()));
                            },
                            child: Text('OK'));
                        AlertDialog _alert = AlertDialog(
                          title: Text('Success'),
                          content: Text('Registration Successfull'),
                          actions: [okbutton],
                        );
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return _alert;
                            });
                      }).catchError((e) {
                        Widget okbutton = FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'));
                        AlertDialog _alert = AlertDialog(
                          title: Text('Error'),
                          content: Text('$e'),
                          actions: [okbutton],
                        );
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return _alert;
                            });
                      });
                    },
                    child: const Text('Register'),
                    color: Colors.green,
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}