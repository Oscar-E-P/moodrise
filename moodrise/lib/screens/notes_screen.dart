import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class NotesScreen extends StatelessWidget {
  final String emotion;
  final String deviceId;

  NotesScreen({required this.emotion, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notas de $emotion", style: GoogleFonts.poppins()),
        backgroundColor: Color(0xFF6A1B9A),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("notas")
            .where("device_id", isEqualTo: deviceId)
            .where("emocion", isEqualTo: emotion)
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Text(
                "No hay notas guardadas.",
                style: GoogleFonts.quicksand(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              Timestamp timestamp = data["timestamp"];
              String formattedDate = DateFormat('dd/MM/yyyy - HH:mm').format(timestamp.toDate());

              return Card(
                color: Colors.deepPurple[50],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: data["imagen"] != ""
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            data["imagen"],
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(Icons.note_alt_outlined, color: Colors.deepPurple, size: 40),
                  title: Text(
                    data["nota"] ?? "Sin nota",
                    style: GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "🕒 $formattedDate",
                      style: GoogleFonts.quicksand(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
