import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceStorage {
  static Future<String> getDeviceId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString("device_id");

    if (deviceId == null) {
      deviceId = const Uuid().v4(); 
      await prefs.setString("device_id", deviceId);
    }

    return deviceId;
  }
}
