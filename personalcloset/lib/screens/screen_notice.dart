import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personalcloset/tabs/tab_closet.dart';
import 'package:personalcloset/tabs/tab_home.dart';
import 'package:personalcloset/tabs/tab_mypage.dart';
import 'package:personalcloset/tabs/tab_market.dart';

class NoticePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('공지사항'),
      ),
      body: Center(
        child: Text('이 부분에 공지사항 내용을 표시하세요.'),
      ),
    );
  }
}
