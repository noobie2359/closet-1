import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personalcloset/models/model_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class TabMypage extends StatefulWidget {
  @override
  _TabMypageState createState() => _TabMypageState();
}

class _TabMypageState extends State<TabMypage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("closet mypage"),
          LoginOutButton(),
        ],
      ),
    );
  }
}

class LoginOutButton extends StatefulWidget {
  @override
  _LoginOutButtonState createState() => _LoginOutButtonState();
}

class _LoginOutButtonState extends State<LoginOutButton> {
  @override
  Widget build(BuildContext context) {
    final authClient =
        Provider.of<FirebaseAuthProvider>(context, listen: false);
    return TextButton(
        onPressed: () async {
          await authClient.logout();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text('logout!')));
          Navigator.of(context).pushReplacementNamed('/login');
        },
        child: Text('logout'));
  }
}
