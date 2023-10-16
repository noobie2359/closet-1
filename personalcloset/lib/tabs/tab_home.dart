// tabs/tab_home.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:personalcloset/calendar/calendar_ImagePage.dart';

class TabHome extends StatefulWidget {
  const TabHome({super.key});

  @override
  State<TabHome> createState() => _CalendarState();
}

//캘린더 클래스
class _CalendarState extends State<TabHome> {
  DateTime today = DateTime.now();

  void _onDaySelected(DateTime day, DateTime focusedDay) async {
    setState(() {
      today = day;
    });

    DocumentSnapshot snapshot = await _getData(day);
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

    if (snapshot.exists && data != null && data.containsKey('imageUrl')) {
      String imageUrl = data['imageUrl'];
      // 가져온 이미지 URL을 이용해 이미지를 출력하거나 다른 방식으로 활용할 수 있습니다.
      print(imageUrl);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePage(
            imageUrl: imageUrl,
            date: today,
          ),
        ),
      );
    } else {
      // 선택한 날짜에 대한 이미지가 없는 경우 처리
      print('No image found for the selected date.');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePage(
            imageUrl: null,
            date: today,
          ),
        ),
      );
    }
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

  //캘린더 위젯
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: TableCalendar(
            locale: "en_US",
            rowHeight: 43,
            headerStyle:
                HeaderStyle(formatButtonVisible: false, titleCentered: true),
            availableGestures: AvailableGestures.all,
            selectedDayPredicate: (day) => isSameDay(day, today),
            focusedDay: today,
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 1, 1),
            onDaySelected: _onDaySelected,
          ),
        ),
        SizedBox(height: 16),
        Center(
          child: FutureBuilder<DocumentSnapshot>(
              future: _getData(today),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  Map<String, dynamic>? data =
                      snapshot.data?.data() as Map<String, dynamic>?;
                  if (snapshot.hasData &&
                      data != null &&
                      data.containsKey('imageUrl')) {
                    return ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImagePage(
                              imageUrl: data['imageUrl'],
                              date: today,
                            ),
                          ),
                        );
                      },
                      child: Text('데일리룩 정보 수정'),
                    );
                  } else {
                    return ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImagePage(
                              imageUrl: null,
                              date: today,
                            ),
                          ),
                        );
                      },
                      child: Text('데일리룩을 업데이트 해주세요.'),
                    );
                  }
                } else {
                  return CircularProgressIndicator();
                }
              }),
        ),
      ],
    );
  }
}
