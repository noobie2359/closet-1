import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ImagePage extends StatefulWidget {
  final String? imageUrl;
  final DateTime? date;

  ImagePage({required this.imageUrl, required this.date});

  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  late String formattedDate;
  File? _image;

  // 이미지피커
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile!.path);
    });
  }

  // 파이어베이스에서 데이터 불러오는 함수
  Future<DocumentSnapshot> _getData(DateTime date) async {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(date);

    final DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('images')
        .doc(formatted)
        .get();

    return snapshot;
  }

  // 파이어베이스에 이미지 업로드
  Future<void> _uploadImage(DateTime date) async {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(date);

    final Reference storageRef =
        FirebaseStorage.instance.ref().child('images/$formatted.jpg');
    final TaskSnapshot snapshot = await storageRef.putFile(_image!);
    final String downloadUrl = await snapshot.ref.getDownloadURL();

    final DocumentReference documentRef =
        FirebaseFirestore.instance.collection('images').doc(formatted);

    await documentRef.set({
      'imageUrl': downloadUrl,
      'date': formatted,
    });

    // 이미지 업로드가 완료되면 setState 메소드 호출 ,
    // _image 변수를 null로 초기화하고 문구 출력
    setState(() {
      _image = null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('데일리룩이 업로드 되었습니다!'),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    formattedDate = formatter.format(widget.date!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(formattedDate),
      ),
      body: _image != null
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 99, vertical: 30),
              child: Image.file(_image!),
            )
          : widget.imageUrl != null
              ? Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 99, vertical: 30),
                  child: Image.network(widget.imageUrl!),
                )
              : Center(child: Text('이 날짜에는 업로드된 데일리룩이 없습니다.')),
      bottomNavigationBar: _image == null
          ? BottomAppBar(
              child: ElevatedButton(
                onPressed: _pickImage,
                child: Text('이미지를 선택해주세요'),
              ),
            )
          : BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _image = null;
                      });
                    },
                    child: Text('다시 선택'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _uploadImage(widget.date!);
                    },
                    child: Text('Upload image'),
                  ),
                ],
              ),
            ),
    );
  }
}
