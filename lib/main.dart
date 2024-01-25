import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:Thrometory/src/component/component.dart';

import 'package:geolocator/geolocator.dart';

import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thrometory',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Thrometory'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

var _userName = TextEditingController();
var _userPost = TextEditingController();


class _MyHomePageState extends State<MyHomePage> {

  double latitude = 153.9807; //緯度
  double longitude = 24.2867; //経度
  num heading = 0;
  List<Sentence> _ret = [];
  List<bool> _isSelected = [true,false];

  List<List<Comments>> _comment = [];

  Future<void> getLocation() async {
    if(_isSelected[0] == true) {
      // 現在の位置を返す
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      // 北緯がプラス。南緯がマイナス
      latitude = position.latitude.toDouble();
      // 東経がプラス、西経がマイナス
      longitude = position.longitude.toDouble();
      //進行方向
      heading = position.heading.toDouble();
    }
    latitude = 153.9807; //緯度
    longitude = 24.2867; //経度
    return;
  }

  double _getrotate(int index) {
    Map<dynamic, dynamic> ret_map = _ret[index].location;
    double latitude2 = ret_map['latitude'].toDouble();
    double longitude2 = ret_map['longitude'].toDouble();
    return(
        Geolocator.bearingBetween(latitude, longitude, latitude2, longitude2) * pi / 180 + heading
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 位置情報サービスが有効かどうかをテストします。
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 位置情報サービスが有効でない場合、続行できません。
      // 位置情報にアクセスし、ユーザーに対して
      // 位置情報サービスを有効にするようアプリに要請する。
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // ユーザーに位置情報を許可してもらうよう促す
      // showAlert(context);
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 拒否された場合エラーを返す
        return Future.error('Location permissions are denied');
      }
    }

    // 永久に拒否されている場合のエラーを返す
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // ここまでたどり着くと、位置情報に対しての権限が許可されているということなので
    // デバイスの位置情報を返す。
    return await Geolocator.getCurrentPosition();
  }

  void showAlert(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('このアプリを利用するには位置情報取得許可が必要です。'),
            content: Text("位置情報を利用します"),
            actions: <Widget>[
              TextButton(
                child: Text("キャンセル"),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text("設定"),
                onPressed: () async {
                  openAppSettings();
                },
              ),
            ],
          );
        });
  }

  void _GETposts() async {
    _determinePosition();
    getLocation();
    var url = Uri.parse(
        "https://geo-sns-400715.an.r.appspot.com/posts/location?latitude=$latitude&longitude=$longitude");
    var res = await http.get(
      url,
    );
    setState(() {
      final List<dynamic> ret = convert.jsonDecode(res.body);
      _ret = ret.map((ret) => Sentence.fromJson(ret)).toList();
      // print(ret);
    });
    print(latitude);
  }

  List<Map<String, dynamic>> _comments = [{}];
  Map<String, dynamic> _commentRet = {};
  void _GETcomment(index) async {
    String id = _ret[index].id.toString();
    var url = Uri.parse(
        "https://geo-sns-400715.an.r.appspot.com/comments?postId=$id&cursor=");
    var res = await http.get(
      url,
    );
    setState(() {
      _commentRet = convert.jsonDecode(res.body);
      // _comment[index] = ret.map((ret) => Comments.fromJson(ret)).toList();
      _commentRet.addAll({"index":index});
      _comments.addAll([_commentRet]);
      print(_comments.toSet().toList());
    });
    // print(index);
  }

  // void getFirstComments(int index) async{
  //   String id = _ret[index].id.toString();
  //   var url = Uri.parse(
  //       "https://geo-sns-400715.an.r.appspot.com/comments?postId=$id&cursor=");
  //   var res = await http.get(
  //     url,
  //   );
  //   setState(() {
  //     final List<dynamic> ret = convert.jsonDecode(res.body);
  //     _comment = ret.map((ret) => comments.fromJson(ret)).toList();
  //   });
  // }

  // void _addpost(userName, userPost, latitude, longitude, postUrl) async {
  //   await http.post(postUrl,
  //       body: convert.jsonEncode({
  //         'name': userName.text,
  //         'text': userPost.text,
  //         'location': {
  //           'latitude': latitude, // 緯度
  //           'longitude': longitude // 経度
  //         }
  //       }));
  // }

  // class AlertDialog extends StatelessWidget{
  //   const AlertDialog({Key? key}) : super(key: key);
  // }
  // @override
  //   Widget build(BuildContext context) {
  //     return AlertDialog(
  //       title: Text('次の内容を投稿してもよろしいでしょうか？'),
  //       content: Text("name:" + _userName.text + "\npost:" + _userPost.text),
  //       actions: <Widget>[
  //         GestureDetector(
  //           child: Text('いいえ'),
  //           onTap: () {
  //             Navigator.pop(context);
  //           },
  //         ),
  //         GestureDetector(
  //           child: Text('はい'),
  //           onTap: () {
  //             _addpost;
  //           },
  //         )
  //       ],
  //     );
  //   }

  var postUrl = Uri.parse("https://geo-sns-400715.an.r.appspot.com/posts");
  // void _addPost() async{
  //   addpost(_userName, _userPost, latitude, longitude, postUrl);
  // }


  // Future<void> _showMyDialog() async {
  //   return showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       /*
  //           一般的な使い方ではないかもしれないが、デフォルトのパディングを無効化してtitleプロパティにColumnでウィジェットを並べる方法をよく使っている。
  //           こうすることでデフォルトの余白などに邪魔されず、自由にUI作成が出来るため
  //           insetPaddingとMediaQuery.of(context).size.widthの組み合わせにより、画面両端からダイアログまでの余白を定義できる。
  //           */
  //       return SimpleDialog(
  //         title: SizedBox(
  //           width: MediaQuery.of(context).size.width,
  //           height: 300,
  //           child: Padding(
  //             padding: const EdgeInsets.all(10),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 const Center(
  //                   child: Text('入力画面'),
  //                 ),
  //                 TextField(
  //                     controller: _userPost,
  //                     decoration: const InputDecoration(
  //                         labelText: 'postを入力してください',
  //                         labelStyle: TextStyle(
  //                           color: Colors.teal,
  //                         ),
  //                         floatingLabelStyle: TextStyle(
  //                           color: Colors.red,
  //                         ),
  //                         prefixIcon: Icon(Icons.email),
  //                         focusedBorder: UnderlineInputBorder(
  //                             borderSide: BorderSide(
  //                           color: Colors.indigoAccent,
  //                         )))),
  //                 Row(
  //                   children: [
  //                     addPostButton(onTap: _addPost),
  //                     SizedBox(
  //                       child: FloatingActionButton.extended(
  //                         onPressed: () {},
  //                         foregroundColor: Colors.white,
  //                         backgroundColor: Colors.pink,
  //                         isExtended: true,
  //                         label: const Text('キャンセル'),
  //                         icon: const Icon(Icons.thumb_up_alt),
  //                       ),
  //                     )
  //                   ],
  //                 )
  //               ],
  //             ),
  //           ),
  //         ),
  //         titlePadding: EdgeInsets.zero,
  //         contentPadding: EdgeInsets.zero,
  //         insetPadding: const EdgeInsets.symmetric(horizontal: 20),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;
    final bottomSpace = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: _GETposts,
            icon: Icon(
              Icons.autorenew,
            ),
          ),
          ToggleButtons(
            color: Colors.grey,
            children: <Widget>[Icon(Icons.gps_off), Icon(Icons.gps_fixed)],
            isSelected: _isSelected,
            onPressed: (int index) {
              setState(() {
                for (int buttonIndex = 0; buttonIndex < _isSelected.length; buttonIndex++) {
                  if (buttonIndex == index) {
                    _isSelected[buttonIndex] = true;
                  } else {
                    _isSelected[buttonIndex] = false;
                  }
                }
              });
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: _ret.length,
        itemBuilder: (BuildContext context, int index) {
          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: deviceWidth * 0.9,
                  // height: 80,
                  margin: EdgeInsets.only(top: 10),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: deviceWidth * 0.9,
                          // height: 80,
                          clipBehavior: Clip.antiAlias,
                          padding: EdgeInsets.only(left: 16),
                          decoration: ShapeDecoration(
                            color: Color(0xFFF7F2FA),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            shadows: [
                              BoxShadow(
                                color: Color(0x26000000),
                                blurRadius: 3,
                                offset: Offset(0, 1),
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              postView(
                                  deviceWidth: deviceWidth,
                                  ret: _ret,
                                  index: index,
                                  commentRet: "aaa",
                              ),
                              TextButton(
                                onPressed: () => _GETcomment(index),
                                child: const Text("reply"),
                                  ),
                              Transform.rotate(
                                angle: _getrotate(index),
                                // angle: 1/2*pi,
                                child: Icon(
                                Icons.arrow_upward,
                              ),)
                            ],
                          )),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        width: deviceWidth,
        height: 100 + bottomSpace,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: deviceWidth,
              height: 50,
              // color: Colors.deepOrange,
              child: TextField(
                  controller: _userName,
                  decoration: const InputDecoration(
                      labelText: 'name',
                      labelStyle: TextStyle(
                        color: Colors.teal,
                      ),
                      floatingLabelStyle: TextStyle(
                        color: Colors.teal,
                      ),
                      prefixIcon: Icon(Icons.edit),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.indigoAccent,
                      )))),
            ),
            Container(
              width: deviceWidth,
              height: 50,
              // color: Colors.cyan,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: deviceWidth - 50,
                    height: 50,
                    // color: Colors.lightGreen,
                    child: TextField(
                        controller: _userPost,
                        decoration: const InputDecoration(
                            labelText: 'post',
                            labelStyle: TextStyle(
                              color: Colors.teal,
                            ),
                            floatingLabelStyle: TextStyle(
                              color: Colors.teal,
                            ),
                            prefixIcon: Icon(Icons.edit),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                              color: Colors.indigoAccent,
                            )))),
                  ),
                  IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) {
                            // return AlertDialogSample();
                            return postAlertDialog(
                                userName: _userName,
                                userPost: _userPost,
                              latitude: latitude,
                              longitude: longitude,
                              postUrl: postUrl,
                            );
                          },
                        );
                      },
                      icon: Icon(Icons.send))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
