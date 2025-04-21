import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'notes_screen.dart';

class EmotionScreen extends StatefulWidget {
  final String emotion;
  final String imagePath;
  final String motivationalText;

  EmotionScreen({
    required this.emotion,
    required this.imagePath,
    required this.motivationalText,
  });

  @override
  _EmotionScreenState createState() => _EmotionScreenState();
}

class _EmotionScreenState extends State<EmotionScreen> {
  File? _selectedImage;
  Uint8List? _webImage;
  String? _imageUrl;
  String? _deviceId;
  bool _isUploading = false;
  TextEditingController _noteController = TextEditingController();
  String? _suggestedActivity;


  Map<String, List<String>> activitySuggestions = {
    "Desagrado": [
      "Prueba la respiración 4-7-8.",
      "Escribe lo que sientes en un papel y luego rómpelo.",
      "Camina por 10 minutos en un parque o zona tranquila.",
      "Escucha música relajante.",
      "Habla con alguien de confianza."
    ],
    "Ansiedad": [
      "Prueba la técnica de mindfulness: enfócate en tu respiración.",
      "Realiza 5 minutos de estiramientos.",
      "Escribe en un diario cómo te sientes.",
      "Sal a tomar aire fresco.",
      "Medita con una app guiada."
    ],
    "Felicidad": [
      "Disfruta tu canción favorita.",
      "Comparte una buena noticia con alguien.",
      "Haz una lista de 3 cosas por las que estás agradecido.",
      "Sonríe frente al espejo durante 30 segundos.",
      "Planea una actividad divertida para la semana."
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadDeviceId();
    _suggestRandomActivity();
  }

  Future<void> _loadDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString("device_id");
    if (deviceId == null) {
      deviceId = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString("device_id", deviceId);
    }
    setState(() {
      _deviceId = deviceId;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null) {
        setState(() {
          _webImage = result.files.first.bytes;
        });
      }
    } else {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    }
  }

  Future<String?> _uploadImage() async {
    try {
      setState(() {
        _isUploading = true;
      });

      String fileName = "images/${DateTime.now().millisecondsSinceEpoch}.jpg";
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask;

      if (kIsWeb && _webImage != null) {
        uploadTask = ref.putData(_webImage!);
      } else if (_selectedImage != null) {
        uploadTask = ref.putFile(_selectedImage!);
      } else {
        setState(() {
          _isUploading = false;
        });
        return null;
      }

      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      setState(() {
        _isUploading = false;
      });

      return imageUrl;
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error al subir imagen: $e")),
      );
      return null;
    }
  }

  Future<void> _saveNote() async {
    if (_deviceId == null) return;

    String? imageUrl;
    if (_selectedImage != null || _webImage != null) {
      imageUrl = await _uploadImage();
    }

    String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    FirebaseFirestore.instance.collection("notas").add({
      "device_id": _deviceId,
      "emocion": widget.emotion,
      "nota": _noteController.text.trim(),
      "imagen": imageUrl ?? "",
      "timestamp": Timestamp.now(),
      "fecha": formattedDate,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Nota guardada con éxito!")),
    );

    _noteController.clear();
    setState(() {
      _selectedImage = null;
      _webImage = null;
      _suggestRandomActivity();
    });
  }

  void _suggestRandomActivity() {
    List<String>? activities = activitySuggestions[widget.emotion];
    if (activities != null && activities.isNotEmpty) {
      setState(() {
        _suggestedActivity = (activities..shuffle()).first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.emotion)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(widget.imagePath, height: 150),
            SizedBox(height: 20),
            Text(
              widget.motivationalText,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

           
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotesScreen(
                      emotion: widget.emotion,
                      deviceId: _deviceId ?? "",
                    ),
                  ),
                );
              },
              icon: Icon(Icons.list_alt),
              label: Text("Ver todas las notas"),
            ),

            SizedBox(height: 10),

       
            if (_suggestedActivity != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Card(
                  color: Colors.blueGrey[900],
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "🔥 Actividad recomendada:\n$_suggestedActivity",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            SizedBox(height: 10),

            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: "¿Cómo te sientes hoy?",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            if (_selectedImage != null) Image.file(_selectedImage!, height: 150),
            if (_webImage != null) Image.memory(_webImage!, height: 150),
            if (_isUploading) CircularProgressIndicator(),
            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  child: Text("Galería"),
                ),
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  child: Text("Cámara"),
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveNote,
              child: Text("Guardar Nota"),
            ),
          ],
        ),
      ),
    );
  }
}
