import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MonthlyStatisticsPage extends StatefulWidget {
  @override
  _MonthlyStatisticsPageState createState() => _MonthlyStatisticsPageState();
}

class _MonthlyStatisticsPageState extends State<MonthlyStatisticsPage> {
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
          title: Text('Monthly Statistics'),
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
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Icon(Icons.error);
                          } else {
                            if (snapshot.data != null &&
                                snapshot.data!.exists) {
                              Map<String, dynamic>? data = snapshot.data!.data()
                                  as Map<String,
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
                subtitle: Text('Frequency: $frequency'),
              );
            }));
  }
}
