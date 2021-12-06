import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:search_choices/search_choices.dart';
import 'package:tennisballpacking/loginpage.dart';
import 'package:qr_mobile_vision/qr_camera.dart';


// enum RadioSel { code, description }

var camState;
var camState1;

class TennisBallPacking extends StatefulWidget {
  const TennisBallPacking({Key? key}) : super(key: key);

  @override
  _TennisBallPackingState createState() => _TennisBallPackingState();
}

class _TennisBallPackingState extends State<TennisBallPacking> {
  var txtskucode = TextEditingController();
  var txtparentbox = TextEditingController();
  // RadioSel? _sel = RadioSel.code;
  var lastScannedBarcode;
  var apiskucode = TextEditingController();
  var apiparentbox = TextEditingController();
  var myController = TextEditingController();
  var databaseskucode;
  var databaseparentbox;
  var apiskuid;
  var apiboxid;
  late FocusNode focusparentbarcode;
  late FocusNode focuschildbarcode;
  String? _dropskucode;
  String? _dropparentbox;
  List dropitem = [];
  List dropitem1 = [];
  List inidropitem = [];
  var inival;
  var parbarcode = TextEditingController();
  var childbarcode = TextEditingController();
  var childbox = TextEditingController();
  String? actualQty = "-";
  String? scannedQty = "-";
  String? balanceQty = "-";
  bool parfill = false;
  String? skudesc = "-";
  String? result;
  String? result1;
  String? skures;
  String? skures1;
  String? childBox = "-";
  bool skucodedd = true;
  bool parbox = true;
  bool initialvalueexists = false;
  var currentUser;
  final databaseReference = FirebaseDatabase.instance.reference();

  initialcheck() async {
    var url =
        "http://mvplapi.larch.in/HOme/GridFetch?SKUId=0&BoxId=0&ParentBarcode=&CreatedBy=$umid";
    var response = await http.get(Uri.parse(url));
    var data = jsonDecode(response.body);
    for (int i = 0; i < data.length; i++) {
      if(data[i]['Id'] == ''){
        initialvalueexists = false;
      }
      else {
        if (data[i]['ActualQty'] != data[i]['ScannedQty']) {
          setState(() {
            initialvalueexists = true;
            inidropitem = data;
          });
        setState(() {
          apiskucode.text = data[0]['SKUName'];
          apiparentbox.text = data[0]['BoxName'];
          parbarcode.text = data[0]['BoxQrCode'];
          childBox = data[0]['ChildBoxName'];
          actualQty = data[0]['ActualQty'];
          scannedQty = data[0]['ScannedQty'];
          balanceQty = data[0]['BalanceQty'];
          apiskuid = data[0]['SKUId'];
          apiboxid = data[0]['BoxId'];
          focuschildbarcode.requestFocus();
        });
      } else{
          initialvalueexists = false;
        }
      }
    }
    print(apiskuid);
    var url1 =
        "http://mvplapi.larch.in/HOme/FetchSKUCode?Id=$apiskuid";
    var response1 = await http.get(Uri.parse(url1));
    var data1 = jsonDecode(response1.body);
    for (int i = 0; i < data1.length; i++) {
      setState(() {
        skudesc = data1[i]['SKUDes'];
      });
    }
  }

  Validate() {
    if (actualQty == scannedQty) {
      setState(() {
        skucodedd = true;
        parbox = true;
      });
    } else {
      skucodedd = false;
      parbox = false;
    }
  }

  Future _Parentscan() async {
    await Permission.camera.request();
    String? barcode = await scanner.scan();
    if (barcode == null) {
      print('nothing return.');
    } else {
      setState(() {
        parbarcode.text = barcode;
      });
      checkparBar();
    }
  }

  Future _Childscan() async {
    await Permission.camera.request();
    String? barcode = await scanner.scan();
    if (barcode == null) {
      print('nothing return.');
    } else {
      this.childbarcode.text = barcode;
    }
    if(initialvalueexists != true){
      checkchildBar();
    }
    else{
      inicheckchildbarcode();
    }
  }

  fetchSKUCode() async {
    var url = "http://mvplapi.larch.in/HOme/FetchSKUCode?Id=0";
    var response = await http.get(Uri.parse(url));
    var data = jsonDecode(response.body);
    setState(() {
      dropitem = data;
      inival = data[0]['SKUCode'];
    });
  }

  fetchSKUDecp() async {
    skures = _dropskucode!.substring(0, _dropskucode!.indexOf('#'));
    print(skures);
    var url =
        "http://mvplapi.larch.in/HOme/FetchSKUCode?Id=$skures";
    var response = await http.get(Uri.parse(url));
    var data = jsonDecode(response.body);
    for (int i = 0; i < data.length; i++) {
      setState(() {
        skudesc = data[i]['SKUDes'];
      });
    }
  }

  fetchParentBoxDD() async {
    var url =
        "http://mvplapi.larch.in/HOme/FetchParentBox?SkuId=$skures";
    var response = await http.get(Uri.parse(url));
    var data = jsonDecode(response.body);
    setState(() {
      dropitem1 = data;
    });
  }

  fetchchildBox() async {
    result1 = _dropparentbox!.substring(0, _dropparentbox!.indexOf('#'));
    var url =
        "http://mvplapi.larch.in/HOme/ChildBoxWithQty?SKUId=$skures&BoxId=$result1";
    var response = await http.get(Uri.parse(url));
    var data = jsonDecode(response.body);
    for (int i = 0; i < data.length; i++) {
      setState(() {
        childBox = data[i]['PackBoxName'];
        actualQty = data[i]['SKUQty'];
        balanceQty = data[i]['SKUQty'];
        scannedQty = '0';
      });
    }
    print(_dropparentbox);
  }

  getPrefix() {
    setState(() {
      result = _dropparentbox!
          .substring(_dropparentbox!.indexOf("#") + 1, _dropparentbox!.length);
      txtparentbox.text = result!;
      skures1 = _dropskucode!
          .substring(_dropskucode!.indexOf("#") + 1, _dropskucode!.length);
      txtskucode.text = skures1!;
    });
  }

  checkparBar() async {
    var url =
        "http://mvplapi.larch.in/Home/ParentBarcodeCheck?SKUId=$skures&BoxId=$result1&ParentBarcode=${parbarcode.text}";
    var response = await http.get(Uri.parse(url));
    var data = jsonDecode(response.body);
    for (int i = 0; i < data.length; i++) {
      if (data[i]['Success'] == '') {
        var url1 = "http://mvplapi.larch.in/Home/GridFetch?SKUId=$skures&BoxId=$result1&ParentBarcode=${parbarcode.text}&CreatedBy=$umid";
        var response1 = await http.get(Uri.parse(url1));
        var data1 = jsonDecode(response1.body);
        for(int i=0;i<data1.length;i++){
          setState(() {
            actualQty = data1[i]['ActualQty'];
            scannedQty = data1[i]['ScannedQty'];
            balanceQty = data1[i]['BalanceQty'];
          });
        }
        Widget okbutton = FlatButton(
            onPressed: () {
              setState(() {
                camState = true;
              });
              parbarcode.text = '';
              focusparentbarcode.requestFocus();
              Navigator.pop(context);
              // _Parentscan();
            },
            child: Text('OK'));
        AlertDialog _alert = AlertDialog(
          title: Text('Wrong Barcode'),
          content: Text('${data[i]['Error']}'),
          actions: [okbutton],
        );
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return _alert;
            });
      }
      else {
        focuschildbarcode.requestFocus();
        // _Childscan();
        setState(() {
          camState1 = true;
        });
      }
    }
  }

  checkchildBar() async {
    var url =
        "http://mvplapi.larch.in/Home/ChildBarcodeCheck?SKUId=$skures&BoxId=$result1&ChildBarcode=${childbarcode.text}";
    var response = await http.get(Uri.parse(url));
    var data = jsonDecode(response.body);
    for (int i = 0; i < data.length; i++) {
      if (data[i]['Success'] == '') {
        Widget okbutton = FlatButton(
            onPressed: () {
              Navigator.pop(context);
              // _Childscan();
              setState(() {
                camState1 = true;
              });
            },
            child: Text('OK'));
        AlertDialog _alert = AlertDialog(
          title: Text('Wrong Barcode'),
          content: Text('${data[i]['Error']}'),
          actions: [okbutton],
        );
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return _alert;
            });
      } else {
        var url1 =
            "http://mvplapi.larch.in/Home/InsertData?SKUId=$skures&BoxId=$result1&ParentBarcode=${parbarcode.text}&ChildBarcode=${childbarcode.text}&CreatedBy=$umid";
        var response1 = await http.get(Uri.parse(url1));
        var data1 = jsonDecode(response1.body);
        for (int i = 0; i < data1.length; i++) {
          if (data1[i]['Success'] == '') {
            Widget okbutton = FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  focuschildbarcode.requestFocus();
                  // _Childscan();
                  setState(() {
                    camState1 = true;
                  });
                },
                child: Text('OK'));
            AlertDialog _alert = AlertDialog(
              title: Text('Validation'),
              content: Text('${data1[i]['Error']}'),
              actions: [okbutton],
            );
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return _alert;
                });
          } else {
            var url2 =
                "http://mvplapi.larch.in/Home/GridFetch?SKUId=0&BoxId=0&ParentBarcode=&CreatedBy=$umid";
            var response2 = await http.get(Uri.parse(url2));
            var data2 = jsonDecode(response2.body);
            for (int i = 0; i < data2.length; i++) {
              setState(() {
                actualQty = data2[i]['ActualQty'];
                scannedQty = data2[i]['ScannedQty'];
                balanceQty = data2[i]['BalanceQty'];
              });
            }
            if(actualQty != scannedQty){
              // _Childscan();
              setState(() {
                camState1 = true;
              });
            }
          }
        }
      }
    }
    Validate();
    childbarcode.text = '';
    focuschildbarcode.requestFocus();
    if (actualQty == scannedQty) {
      parbarcode.text = '';
      focusparentbarcode.requestFocus();
      setState(() {
        initialvalueexists = false;
      });
    }
  }

  inicheckchildbarcode() async {
    var url =
        "http://mvplapi.larch.in/Home/ChildBarcodeCheck?SKUId=$apiskuid&BoxId=$apiboxid&ChildBarcode=${childbarcode.text}";
    var response = await http.get(Uri.parse(url));
    var data = jsonDecode(response.body);
    for (int i = 0; i < data.length; i++) {
      if (data[i]['Success'] == '') {
        Widget okbutton = FlatButton(
            onPressed: () {
              Navigator.pop(context);
              focuschildbarcode.requestFocus();
              // _Childscan();
              setState(() {
                camState1 = true;
              });
            },
            child: Text('OK'));
        AlertDialog _alert = AlertDialog(
          title: Text('Wrong Barcode'),
          content: Text('${data[i]['Error']}'),
          actions: [okbutton],
        );
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return _alert;
            });
      } else {
        var url1 =
            "http://mvplapi.larch.in/Home/InsertData?SKUId=$apiskuid&BoxId=$apiboxid&ParentBarcode=${parbarcode.text}&ChildBarcode=${childbarcode.text}&CreatedBy=$umid";
        var response1 = await http.get(Uri.parse(url1));
        var data1 = jsonDecode(response1.body);
        for (int i = 0; i < data1.length; i++) {
          if (data1[i]['Success'] == '') {
            Widget okbutton = FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  focuschildbarcode.requestFocus();
                  // _Childscan();
                  setState(() {
                    camState1 = true;
                  });
                },
                child: Text('OK'));
            AlertDialog _alert = AlertDialog(
              title: Text('Validation'),
              content: Text('${data1[i]['Error']}'),
              actions: [okbutton],
            );
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return _alert;
                });
          } else {
            var url2 =
                "http://mvplapi.larch.in/Home/GridFetch?SKUId=0&BoxId=0&ParentBarcode=&CreatedBy=$umid";
            var response2 = await http.get(Uri.parse(url2));
            var data2 = jsonDecode(response2.body);
            for (int i = 0; i < data2.length; i++) {
              setState(() {
                actualQty = data2[i]['ActualQty'];
                scannedQty = data2[i]['ScannedQty'];
                balanceQty = data2[i]['BalanceQty'];
              });
            }
            if(actualQty != scannedQty){
              // _Childscan();
              setState(() {
                camState1 = true;
              });
            }
          }
        }
      }
    }
    Validate();
    childbarcode.text = '';
    focuschildbarcode.requestFocus();
    if (actualQty == scannedQty) {
      parbarcode.text = '';
      skudesc = '';
      childBox = '';
      focusparentbarcode.requestFocus();
      setState(() {
        initialvalueexists = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    focusparentbarcode = FocusNode();
    focuschildbarcode = FocusNode();
    initialcheck();
    fetchSKUCode();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Packing Tool'),
            Spacer(),
            FlatButton(onPressed: (){
              setState(() {
                camState = false;
                camState1 = false;
              });
              Navigator.push(context, MaterialPageRoute(builder: (context)=>NextPage()));
            }, child: Row(
              children: [
                Icon(Icons.person),
                Text('Logout')
              ],
            ))
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
                margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                      bottomLeft: Radius.circular(0),
                    )),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Text('SKU Code:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    initialvalueexists == false
                        ? skucodedd == true
                        ? Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: SearchChoices.single(
                        items: dropitem.map((e) {
                          return DropdownMenuItem(
                            child: Text('${e["SKUCodeDesc"]}'),
                            value: e['Id'] + '#' + e['SKUCodeDesc'],
                          );
                        }).toList(),
                        value: _dropskucode,
                        hint: "Select one",
                        searchHint: "Select one",
                        onChanged: (value) {
                          setState(() {
                            _dropskucode = value;
                            camState = false;
                            camState1 = false;
                            _dropparentbox = null;
                          });
                          childBox = '';
                          fetchSKUDecp();
                          fetchParentBoxDD();
                          parbarcode.text = '';
                          childbarcode.text = '';
                          getPrefix();
                        },
                        isExpanded: true,
                      ),

                      // DropdownButton<String>(
                      //   value: _dropskucode,
                      //   items:  dropitem.map((e) {
                      //           return DropdownMenuItem<String>(
                      //             child: Text(
                      //                 '${e['SKUCodeDesc']}'),
                      //             value: e['Id'] + '#' + e['SKUCode'],
                      //           );
                      //         }).toList(),
                      //   onChanged: (value) {
                      //     setState(() {
                      //       _dropskucode = value;
                      //     });
                      //     fetchSKUDecp();
                      //     fetchParentBoxDD();
                      //     parbarcode.text = '';
                      //     childbarcode.text = '';
                      //     getPrefix();
                      //   },
                      //   isExpanded: true,
                      // ),
                    ):
                    Container(
                        height: 50,
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: TextFormField(
                          readOnly: true,
                          controller: txtskucode,
                          decoration:
                          InputDecoration(border: OutlineInputBorder()),
                        ))
                        : Container(
                        height: 50,
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: TextFormField(
                          readOnly: true,
                          controller: apiskucode,
                          decoration:
                          InputDecoration(border: OutlineInputBorder()),
                        )),

                    Container(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: Text(
                          '$skudesc',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0,
                              color: Colors.green),
                        )),
                  ],
                )),
            Container(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Text(
                'Parent Box',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            initialvalueexists == false
                ? parbox == true
                ?Container(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: DropdownButton<String>(
                items:  dropitem1.map((e) {
                  return DropdownMenuItem<String>(
                    child: Text('${e['BoxName']}'),
                    value: e['Id'] + '#' + e['BoxName'],
                  );
                }).toList(),
                value: _dropparentbox,
                onChanged: (value) {
                  setState(() {
                    _dropparentbox = value;
                  });
                  getPrefix();
                  fetchchildBox();
                  if (scannedQty == '0' && childBox != null) {
                    // _Parentscan();
                    setState(() {
                      camState = true;
                    });
                  } else if (scannedQty == actualQty && childBox != null) {
                    // _Parentscan();
                    setState(() {
                      camState = true;
                    });
                  }
                },
                isExpanded: true,
              ),
            ) :
            Container(
                height: 50,
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: TextFormField(
                  readOnly: true,
                  controller: txtparentbox,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                ))
                : Container(
                height: 50,
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: TextFormField(
                  readOnly: true,
                  controller: apiparentbox,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                )),
            Container(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Text('Child Box',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Text('$childBox')),
            Container(
              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                    bottomLeft: Radius.circular(0),
                  )),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Parent Barcode Scanning',
                        style: TextStyle(color: Colors.blue, fontSize: 20.0),
                      )),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    child: _dropparentbox == null
                        ? Text('QR Code : ')
                        : Text('$result QRCode :'),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  camState
                      ? Center(
                    child: SizedBox(
                      width: 300.0,
                      height: 300.0,
                      child: QrCamera(
                        onError: (context, error) => Text(
                          error.toString(),
                          style: TextStyle(color: Colors.red),),
                        qrCodeCallback: (code) {
                          setState(() {
                            parbarcode.text = code!;
                            camState = false;
                            checkparBar();
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                                color: Colors.orange,
                                width: 10.0,
                                style: BorderStyle.solid),
                          ),
                        ),
                      ),
                    ),
                  )
                      : Center(child: Text(" ")),
                  SizedBox(height: 5.0,),
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: TextFormField(
                      focusNode: focusparentbarcode,
                      readOnly: true,
                      showCursor: true,
                      controller: parbarcode,
                      decoration: InputDecoration(
                        suffixIcon: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                if(_dropskucode == null || _dropparentbox == null){
                                  Widget okbutton = FlatButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('OK'));
                                  AlertDialog _alert = AlertDialog(
                                    title: Text('Validation'),
                                    content: Text('Please Choose SKUCode and ParentBox'),
                                    actions: [okbutton],
                                  );
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return _alert;
                                      });
                                }
                                else if (_dropskucode != null && _dropparentbox != null && scannedQty == '0' && childBox != null) {
                                  // _Parentscan();
                                  setState(() {
                                    camState = true;
                                  });
                                } else if (_dropskucode != null && _dropparentbox != null && scannedQty == actualQty && childBox != null) {
                                  // _Parentscan();
                                  setState(() {
                                    camState = true;
                                  });
                                }
                              },
                              icon: Icon(Icons.qr_code_scanner),
                            ),
                          ],
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Text('Scan Barcode'),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                    bottomLeft: Radius.circular(0),
                  )),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Child Barcode Scanning',
                        style: TextStyle(color: Colors.blue, fontSize: 20.0),
                      )),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                      alignment: Alignment.topLeft,
                      child: childbox.text == null
                          ? Text('Barcode : ')
                          : Text('$childBox Barcode : ')),
                  SizedBox(
                    height: 10.0,
                  ),
                  camState1
                      ? Center(
                    child: SizedBox(
                      width: 300.0,
                      height: 300.0,
                      child: QrCamera(
                        onError: (context, error) => Text(
                          error.toString(),
                          style: TextStyle(color: Colors.red),),
                        qrCodeCallback: (code) {
                          setState(() {
                            childbarcode.text = code!;
                            camState1 = false;
                            if(initialvalueexists != true){
                              checkchildBar();
                            }
                            else{
                              inicheckchildbarcode();
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                                color: Colors.orange,
                                width: 10.0,
                                style: BorderStyle.solid),
                          ),
                        ),
                      ),
                    ),
                  )
                      : Center(child: Text(" ")),
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: TextFormField(
                      focusNode: focuschildbarcode,
                      readOnly: true,
                      showCursor: true,
                      controller: childbarcode,
                      decoration: InputDecoration(
                          suffixIcon: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween, // added line
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  if(parbarcode.text == ''){
                                    Widget okbutton = FlatButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('OK'));
                                    AlertDialog _alert = AlertDialog(
                                      title: Text('Validation'),
                                      content: Text('Please Scan Parent Barcode'),
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
                                      camState1 = true;
                                    });
                                  }
                                },
                                icon: Icon(Icons.qr_code_scanner),
                              ),
                              // IconButton(
                              //   onPressed: () {
                              //     checkchildBar();
                              //   },
                              //   icon: Icon(Icons.arrow_right_alt_rounded),
                              // ),
                            ],
                          ),
                          border: OutlineInputBorder()),
                    ),
                  ),
                  Text('Scan Barcode'),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                    bottomLeft: Radius.circular(0),
                  )),
              child: Column(
                children: [
                  Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Summary',
                        style: TextStyle(color: Colors.blue, fontSize: 20.0),
                      )),
                  SizedBox(
                    height: 5.0,
                  ),
                  Container(
                    margin: EdgeInsets.all(20),
                    child: Table(
                      columnWidths: {
                        0: FlexColumnWidth(3),
                        1: FlexColumnWidth(3),
                        2: FlexColumnWidth(3),
                      },
                      children: [
                        TableRow(children: [
                          Column(children: [
                            Text('Actual Qty',
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold))
                          ]),
                          Column(children: [
                            Text('Scanned Qty',
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold))
                          ]),
                          Column(children: [
                            Text('Balance Qty',
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold))
                          ]),
                        ]),
                        TableRow(children: [
                          Column(children: [
                            Text(
                              '$actualQty',
                              style: TextStyle(
                                  fontSize: 25.0, color: Colors.green),
                            )
                          ]),
                          Column(children: [
                            Text('$scannedQty',
                                style: TextStyle(
                                    fontSize: 25.0, color: Colors.blue))
                          ]),
                          Column(children: [
                            Text('$balanceQty',
                                style: TextStyle(
                                    fontSize: 25.0, color: Colors.red))
                          ]),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: Container(
          height: 50,
          child: Row(
            children: [
              Spacer(),
              Text(
                'Support : +91 9884164415',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(width: 10.0,)
            ],
          ),
        ),
      ),
    ), onWillPop: () async => false );
  }
}