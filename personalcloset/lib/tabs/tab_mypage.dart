import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:personalcloset/screens/screen_ask.dart';
import 'package:personalcloset/screens/screen_notice.dart';
import 'package:personalcloset/screens/statistic_screen.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  String _nickname = ""; // Define _nickname here
  String _email = "";
  final ImagePicker _imagePicker = ImagePicker();
  File? _profileImage; // Define _profileImage here

  final TextStyle _titleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  final ButtonStyle _buttonStyle = ElevatedButton.styleFrom(
    primary: Colors.green[500],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0),
    ),
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  );

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _user = user;
    });

    if (user != null) {
      try {
        DocumentSnapshot userInfo = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userInfo.exists) {
          setState(() {
            _nickname = userInfo['nickname'] ?? "로딩 중...";
            _email = user.email ?? "";
          });
        }
      } catch (e) {
        print('Firestore 데이터 가져오기 오류: $e');
      }
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await _imagePicker.getImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '  마이페이지',
          style: TextStyle(color: Colors.black), // 제목 텍스트 색상 설정
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black), // 아이콘 색상 설정
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Center(
        child: _user != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _buildProfileImage(),
                  SizedBox(height: 20),
                  _buildProfileInfo(),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StatisticsPage(),
                        ),
                      );
                    },
                    style: _buttonStyle,
                    icon: Icon(Icons.insert_chart, color: Colors.white),
                    label: Text('스타일 통계', style: _titleStyle),
                  ),
                ],
              )
            : CircularProgressIndicator(),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (builder) => _buildBottomSheet(),
        );
      },
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey,
        child: _profileImage != null // Check if _profileImage is not null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.file(
                  _profileImage!, // Use the non-null _profileImage
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              )
            : Icon(Icons.person), // Fallback if _profileImage is null
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      constraints: BoxConstraints(maxWidth: 220),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(_nickname, style: _titleStyle), // Use _nickname here
            Divider(thickness: 1),
            Text('${_user!.email}', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NoticePage()),
              );
            },
            child: Text('공지사항'),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Askpage()),
              );
            },
            child: Text('문의하기'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      height: 200,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Text('Choose Profile photo', style: _titleStyle),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildSheetButton(Icons.camera, 'Camera', ImageSource.camera),
                _buildSheetButton(
                    Icons.photo_library, 'Gallery', ImageSource.gallery),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSheetButton(IconData icon, String label, ImageSource source) {
    return TextButton.icon(
      icon: Icon(icon, size: 50),
      onPressed: () => _getImage(source),
      label: Text(label, style: TextStyle(fontSize: 20)),
    );
  }
}
