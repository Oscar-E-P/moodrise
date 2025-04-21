import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/emotion_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/disclaimer_screen.dart';
import 'firebase_options.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MoodRiseApp());
}

class MoodRiseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _deviceId;

  @override
  void initState() {
    super.initState();
    _loadDeviceId();
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

  List<Widget> _screens(String deviceId) => [
        HomeScreenContent(),
        StatisticsScreen(deviceId: deviceId),
        CalendarScreen(deviceId: deviceId),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showSupportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.grey[900],
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("¿Necesitas ayuda profesional?",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Recuerda que esta app no sustituye el apoyo de un profesional de la salud mental.",
                textAlign: TextAlign.center),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.phone),
              label: Text("Llamar a 800 911 2000"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              onPressed: () async {
                final Uri tel = Uri.parse("tel:8009112000");
                if (await canLaunchUrl(tel)) {
                  await launchUrl(tel);
                }
              },
           
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6A1B9A),
        title: Text("MoodRise", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.support_agent),
            onPressed: () => _showSupportOptions(context),
            tooltip: "Ayuda profesional",
          )
        ],
      ),
      body: _deviceId == null
          ? Center(child: CircularProgressIndicator())
          : _screens(_deviceId!)[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.purpleAccent,
        unselectedItemColor: Colors.white60,
        backgroundColor: Colors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Emociones"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Estadísticas"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Calendario"),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1F1C2C), Color(0xFF928DAB)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "¿Cómo te sientes hoy?",
            style: GoogleFonts.quicksand(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 30),
          Expanded(
            child: GridView.builder(
              physics: BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: emotionsData.length,
              itemBuilder: (context, index) {
                String emotion = emotionsData.keys.elementAt(index);
                return TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 600 + index * 150),
                  builder: (context, value, child) => Transform.scale(
                    scale: value,
                    child: Opacity(opacity: value, child: child),
                  ),
                  child: EmotionButton(emotion, emotionsData[emotion]!['image']!, context),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Map<String, Map<String, String>> emotionsData = {
  "Desagrado": {
    "image": "assets/Desagrado/Emoji.Desagrado.png",
    "text": "Es un mal día, pero no una mala vida.",
  },
  "Ansiedad": {
    "image": "assets/Ansiedad/Emoji.Ansiedad.png",
    "text": "Respira hondo, todo pasará.",
  },
  "Felicidad": {
    "image": "assets/Felicidad/Emoji.Felicidad.png",
    "text": "Disfruta el momento, es único.",
  },
};

Widget EmotionButton(String text, String imagePath, BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EmotionScreen(
            emotion: text,
            imagePath: imagePath,
            motivationalText: emotionsData[text]!['text']!,
          ),
        ),
      );
    },
    child: Card(
      color: Colors.black.withOpacity(0.4),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
        ),
      ),
    ),
  );
}

