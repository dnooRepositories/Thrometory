import 'package:flutter/material.dart';
import 'package:Thrometory/src/component/conect.dart';
import 'package:Thrometory/src/component/sentence.dart';

//post表示ウィジェット
class postView extends StatelessWidget {
  const postView({
    required this.deviceWidth,
    required this.ret,
    required this.index,
    required this.commentRet,
    Key? key,
  }) : super(key: key);

  final double deviceWidth;
  final List<Sentence> ret;
  final int index;
  final String commentRet;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: deviceWidth * 0.9 - 120,
      // height: Autofill,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ret[index].name,
            style: TextStyle(
              color: Color(0xFF1D1B20),
              fontSize: 16,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            ret[index].text,
            style: TextStyle(
              color: Color(0xFF1D1B20),
              fontSize: 14,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
            ),
          ),
          // comentText(commentRet, index)
          // Text(
          //   ">"+comment[index][0],
          //   // ret[index].id.toString(),
          //   style: TextStyle(
          //     color: Color(0xFF1D1B20),
          //     fontSize: 14,
          //     fontFamily: 'Roboto',
          //     fontWeight: FontWeight.w400,
          //   ),
          // ),
          // ListView.builder(
          //     itemCount: comment[index].length,
          //     itemBuilder: (BuildContext context, int ind) {
          //       return Center(
          //           child: Row(
          //             children: [
          //               Text(comment[index][ind])
          //             ],
          //           )
          //       );
          //     })
        ],
      ),
    );
  }
  
  Widget comentText(comment, index){
    if(comment["comment"].length >= 0){
      return Text("");
    }
    else{
      return const Text("");
    }
  }
}

//投稿確認
class postAlertDialog extends StatelessWidget {
  const postAlertDialog(
      {required this.userName,
      required this.userPost,
      required this.latitude,
      required this.longitude,
      required this.postUrl,
      Key? key})
      : super(key: key);

  final userName;
  final userPost;
  final num latitude; //緯度
  final num longitude; //経度
  final postUrl;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('次の内容を投稿してもよろしいでしょうか？'),
      content: Text("name:" + userName.text + "\npost:" + userPost.text),
      actions: <Widget>[
        GestureDetector(
          child: Text('いいえ'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        GestureDetector(
          child: Text('はい'),
          onTap: () {
            addpost(userName, userPost, latitude, longitude, postUrl);
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}
