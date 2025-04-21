import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  final String deviceId;

  CalendarScreen({required this.deviceId});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<DateTime, String> selectedEmotions = {}; 
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadEmotionsFromFirestore();
  }

  Future<void> _loadEmotionsFromFirestore() async {
    var snapshot = await FirebaseFirestore.instance
        .collection("notas")
        .where("device_id", isEqualTo: widget.deviceId)
        .get();

    Map<DateTime, Map<String, int>> emotionsCount = {};

    for (var doc in snapshot.docs) {
      var data = doc.data();
      if (data.containsKey("timestamp") && data.containsKey("emocion")) {
        Timestamp timestamp = data["timestamp"];
        DateTime date = timestamp.toDate();
        DateTime dayOnly = DateTime(date.year, date.month, date.day);

        String emotion = data["emocion"];

        if (!emotionsCount.containsKey(dayOnly)) {
          emotionsCount[dayOnly] = {"Desagrado": 0, "Ansiedad": 0, "Felicidad": 0};
        }
        emotionsCount[dayOnly]![emotion] = (emotionsCount[dayOnly]![emotion] ?? 0) + 1;
      }
    }
    Map<DateTime, String> emotionPerDay = {};
    emotionsCount.forEach((date, emotions) {
      String dominantEmotion = emotions.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      emotionPerDay[date] = dominantEmotion;
    });

    setState(() {
      selectedEmotions = emotionPerDay;
    });
  }

  Color _getEmotionColor(String? emotion) {
    switch (emotion) {
      case "Desagrado":
        return Colors.orange;
      case "Ansiedad":
        return Colors.blue;
      case "Felicidad":
        return Colors.green;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Calendario de Emociones")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                String? emotion = selectedEmotions[DateTime(day.year, day.month, day.day)];
                if (emotion == null) return null;

                return Container(
                  width: 35,
                  height: 35,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _getEmotionColor(emotion),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
