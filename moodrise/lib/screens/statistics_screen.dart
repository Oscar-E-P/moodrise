import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatefulWidget {
  final String deviceId;

  StatisticsScreen({required this.deviceId});

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  Map<String, int> emotionCounts = {"Desagrado": 0, "Ansiedad": 0, "Felicidad": 0};
  List<Map<String, dynamic>> records = [];

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection("notas")
          .where("device_id", isEqualTo: widget.deviceId)
          .get();

      Map<String, int> counts = {"Desagrado": 0, "Ansiedad": 0, "Felicidad": 0};
      List<Map<String, dynamic>> tempRecords = [];

      for (var doc in snapshot.docs) {
        var data = doc.data();
        if (data.containsKey("emocion") && data.containsKey("fecha")) {
          String emocion = data["emocion"];
          counts[emocion] = (counts[emocion] ?? 0) + 1;

          tempRecords.add({
            "emocion": emocion,
            "fecha": data["fecha"], 
          });
        }
      }

      setState(() {
        emotionCounts = counts;
        records = tempRecords;
      });

    } catch (e) {
      print("❌ Error al cargar estadísticas: $e");
    }
  }

  List<PieChartSectionData> _generatePieChartData() {
    return [
      PieChartSectionData(
        color: Colors.orange,
        value: emotionCounts["Desagrado"]!.toDouble(),
        title: "😡 ${emotionCounts["Desagrado"]}",
      ),
      PieChartSectionData(
        color: Colors.blue,
        value: emotionCounts["Ansiedad"]!.toDouble(),
        title: "😰 ${emotionCounts["Ansiedad"]}",
      ),
      PieChartSectionData(
        color: Colors.green,
        value: emotionCounts["Felicidad"]!.toDouble(),
        title: "😊 ${emotionCounts["Felicidad"]}",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Estadísticas")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Frecuencia de emociones",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            if (emotionCounts.values.every((count) => count == 0))
              Center(child: Text("No hay datos suficientes para mostrar estadísticas."))
            else
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: PieChart(
                        PieChartData(
                          sections: _generatePieChartData(),
                          borderData: FlBorderData(show: false),
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          _buildEmotionRow("😡 Desagrado", emotionCounts["Desagrado"]!),
                          _buildEmotionRow("😰 Ansiedad", emotionCounts["Ansiedad"]!),
                          _buildEmotionRow("😊 Felicidad", emotionCounts["Felicidad"]!),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 20),

       
            Text(
              "Historial de emociones",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: records.length,
                itemBuilder: (context, index) {
                  var record = records[index];
                  return Card(
                    child: ListTile(
                      leading: _getEmotionIcon(record["emocion"]),
                      title: Text("${record["emocion"]}"),
                      subtitle: Text("${record["fecha"]}"), // 📌 Solo fecha/hora
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionRow(String text, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: TextStyle(fontSize: 16)),
          Text("$count", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _getEmotionIcon(String emotion) {
    switch (emotion) {
      case "Desagrado":
        return Icon(Icons.sentiment_very_dissatisfied, color: Colors.orange);
      case "Ansiedad":
        return Icon(Icons.sentiment_neutral, color: Colors.blue);
      case "Felicidad":
        return Icon(Icons.sentiment_very_satisfied, color: Colors.green);
      default:
        return Icon(Icons.sentiment_satisfied, color: Colors.grey);
    }
  }
}
