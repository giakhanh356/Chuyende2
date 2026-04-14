import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameSettingsScreen(),
    );
  }
}

class GameSettingsScreen extends StatefulWidget {
  @override
  _GameSettingsScreenState createState() => _GameSettingsScreenState();
}

class _GameSettingsScreenState extends State<GameSettingsScreen> {
  bool _isSoundOn = true;
  bool _isAutoSaveOn = true;
  double _volume = 0.5;
  int _highScore = 3500;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Tải dữ liệu cũ lên giao diện
  _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSoundOn = prefs.getBool('isSoundOn') ?? true;
      _isAutoSaveOn = prefs.getBool('isAutoSaveOn') ?? true;
      _volume = prefs.getDouble('volume') ?? 0.5;
    });
  }

  // Hàm này sẽ được gọi khi nhấn nút "Lưu cấu hình"
  _handleSave() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSoundOn', _isSoundOn);
    await prefs.setBool('isAutoSaveOn', _isAutoSaveOn);
    await prefs.setDouble('volume', _volume);

    // Hiển thị thông báo đã lưu thành công
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu cấu hình thành công!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Cấu hình game đố vui',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingRow(
              label: 'Âm thanh',
              child: Checkbox(
                value: _isSoundOn,
                onChanged: (val) => setState(() => _isSoundOn = val!),
              ),
            ),
            const SizedBox(height: 10),
            _buildSettingRow(
              label: 'Điểm cao nhất',
              child: Text('$_highScore', style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 10),
            _buildSettingRow(
              label: 'Tự động lưu game',
              child: Checkbox(
                value: _isAutoSaveOn,
                onChanged: (val) => setState(() => _isAutoSaveOn = val!),
              ),
            ),
            const SizedBox(height: 30),
            const Text('Volume', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Slider(
              value: _volume,
              activeColor: Colors.black,
              inactiveColor: Colors.grey[300],
              onChanged: (val) => setState(() => _volume = val),
            ),
            
            const Spacer(), // Đẩy nút Lưu xuống cuối màn hình

            // NÚT LƯU CẤU HÌNH
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Màu nút
                  foregroundColor: Colors.white, // Màu chữ
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'LƯU CẤU HÌNH',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow({required String label, required Widget child}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        child,
      ],
    );
  }
}