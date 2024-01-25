import 'package:flutter/material.dart';

class addPostButton extends StatelessWidget {
  const addPostButton({
    required this.onTap,
    Key? key,
  }) : super(key: key);

  final VoidCallback onTap;//add関数

  @override
  Widget build(BuildContext context) {
    //投稿ボタン
    return FloatingActionButton.extended(
      onPressed: onTap,
      foregroundColor: Colors.white,
      backgroundColor: Colors.pink,
      isExtended: true,
      label: const Text('投稿'),
      icon: const Icon(Icons.thumb_up_alt),
    );
  }
}