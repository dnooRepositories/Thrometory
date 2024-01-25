import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:Thrometory/src/component/component.dart';

class addpost{
  var userName = TextEditingController();
  var userPost = TextEditingController();
  num latitude = 153.9807; //緯度
  num longitude = 24.2867; //経度
  var postUrl;

  addpost(this.userName, this.userPost, this.latitude, this.longitude,
      this.postUrl){
    http.post(postUrl,
        body: convert.jsonEncode({
          'name': userName.text,
          'text': userPost.text,
          'location': {
            'latitude': latitude, // 緯度
            'longitude': longitude // 経度
          }
        }));
  }
}

// class getcomments{
//   Future<List<comments>> getcomments(this.id) async{
//     var url = Uri.parse(
//         "https://geo-Thrometory-400715.an.r.appspot.com/comments?postId=$id&cursor=");
//     var res = await http.get(
//       url,
//     );
//
//       final ret = convert.jsonDecode(res.body);
//       for(var data in ret["text"]) {
//         _ret.add(comments.fromJson(data));
//       }
//       return _ret;
//
//   }
// }
// class UserService {
//   Future<List<comments>> getUsers() async {
//     try {
//       final response = await http.get(
//         Uri.parse("https://geo-Thrometory-400715.an.r.appspot.com/comments?postId=$id&cursor="),
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final List<comments> userList = [];
//
//         for (var entry in data['results']) {
//           userList.add(comments.fromJson(entry));
//         }
//
//         return userList;
//       } else {
//         throw Exception('Failed to load users. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to connect to the server. Error: $e');
//     }
//   }
// }

