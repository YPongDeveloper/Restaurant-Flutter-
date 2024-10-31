import 'package:employee/screens/home/login_screen.dart';
import 'package:flutter/material.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // ตั้งค่า Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // เรียกฟังก์ชันโหลดข้อมูล
    fetchData();
  }

  // ฟังก์ชันที่ใช้ในการโหลดข้อมูลจาก API
  Future<void> fetchData() async {
    // จำลองการโหลดข้อมูล
    await Future.delayed(Duration(seconds: 3));

    // เมื่อโหลดเสร็จให้ค่อยๆเปลี่ยนไปที่ HomeScreen ด้วยเอฟเฟกต์ fade
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: Duration(seconds: 1), // ตั้งค่าเวลาในการ fade ไปหน้าใหม่
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Image.asset('lib/assets/logo.png', width: 200, height: 200), // แอนิเมชันโลโก้
        ),
      ),
    );
  }
}
