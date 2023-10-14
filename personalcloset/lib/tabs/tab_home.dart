import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:personalcloset/calendar/calendar_ImagePage.dart';

class TabHome extends StatefulWidget {
  const TabHome({Key? key});

  @override
  State<TabHome> createState() => _CalendarState();
}

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

  Future<DocumentSnapshot> _getData(DateTime date) async {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(date);

    final DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('images')
        .doc(formatted)
        .get();

    return snapshot;
  }

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
                  return ElevatedButton.icon(
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
                    icon: Icon(Icons.accessibility),
                    label: Text('데일리룩을 업데이트'),
                  );
                }
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
        ),
        SizedBox(height: 16), // 버튼 위 추가 간격

        // "통계 보기" 버튼 추가
        ElevatedButton.icon(
          onPressed: () {
            // 통계 페이지로 이동
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StatisticsPage(),
              ),
            );
          },
          icon: Icon(Icons.insert_chart),
          label: Text('통계 보기'),
        ),
      ],
    );
  }
}

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<Map<String, dynamic>> statistics = [];

  @override
  void initState() {
    super.initState();
    fetchStatisticsData();
  }

  Future<void> fetchStatisticsData() async {
    try {
      // Fetch monthly statistics data from Firestore
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('images').get();

      List<Map<String, dynamic>> tempStatistics = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic>? data = doc.data() as Map<String,
            dynamic>?; // Explicitly cast to Map<String, dynamic>?
        if (data != null &&
            data['imageUrl'] != null &&
            data['date'] != null &&
            data['items'] != null) {
          String? imageUrl = data['imageUrl'] as String?; // Change to String?
          String? date = data['date'] as String?; // Change to String?
          Iterable<dynamic>? items = data['items']
              as Iterable<dynamic>?; // Change to Iterable<dynamic>?

          if (imageUrl != null && date != null && items != null) {
            List<String> itemList = items
                .map((dynamic item) => item.toString())
                .toList(); // Explicitly cast each item to String
            tempStatistics.add({
              'imageUrl': imageUrl,
              'date': date,
              'items': itemList,
            });
          }
        }
      }

      setState(() {
        statistics = tempStatistics;
      });
    } catch (e) {
      print('Failed to fetch statistics data: $e');
    }
  }

  List<Map<String, dynamic>> calculateMonthlyStatistics() {
    // Implement logic to calculate monthly statistics
    // based on the 'statistics' list, and return the result

    // Example: Calculate item frequency
    Map<String, int> itemFrequency = {};
    for (var data in statistics) {
      List<String>? items = data['items']; // Change to List<String>?
      if (items != null) {
        for (var item in items) {
          itemFrequency[item] = (itemFrequency[item] ?? 0) + 1;
        }
      }
    }

    // Sort the statistics data
    List<MapEntry<String, int>> sortedEntries = itemFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Return the sorted data
    List<Map<String, dynamic>> monthlyStatistics = sortedEntries
        .map((entry) => {
              'item': entry.key,
              'frequency': entry.value,
            })
        .toList();

    return monthlyStatistics;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> monthlyStatistics = calculateMonthlyStatistics();

    return Scaffold(
      appBar: AppBar(
        title: Text('월별 통계'),
      ),
      body: ListView.builder(
        itemCount: monthlyStatistics.length,
        itemBuilder: (BuildContext context, int index) {
          Map<String, dynamic> statistic = monthlyStatistics[index];
          String item = statistic['item'];
          int frequency = statistic['frequency'];
          String? imageUrl = statistic['imageUrl'];

          return ListTile(
            leading: imageUrl != null
                ? Image.network(
                    imageUrl,
                    width: 80,
                    height: 80,
                  )
                : FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('shopping_list')
                        .doc(
                            'placeholder_category') // Replace with the actual selectedCategory value
                        .collection('items')
                        .doc(item)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Icon(Icons.error);
                      } else {
                        if (snapshot.data != null && snapshot.data!.exists) {
                          Map<String, dynamic>? data = snapshot.data!.data() as Map<
                              String,
                              dynamic>?; // Explicitly cast to Map<String, dynamic>?
                          String? imageUrl = data?['imageUrl'];
                          if (imageUrl != null) {
                            return Image.network(
                              imageUrl,
                              width: 80,
                              height: 80,
                            );
                          }
                        }
                        return Icon(Icons.image_not_supported);
                      }
                    },
                  ),
            title: Text(item),
            subtitle: Text('착용 빈도: $frequency'),
          );
        },
      ),
    );
  }
}
