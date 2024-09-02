import 'package:flutter/material.dart';
import 'package:app/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _navigateToLogin();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 3), () {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LogIn()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2193b0),
              Color(0xFF6dd5ed),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(150, 150),
                    painter: WaterDropPainter(_animation.value),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'PlariDeals',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WaterDropPainter extends CustomPainter {
  final double progress;

  WaterDropPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final double height = size.height;
    final double fillLevel = height * progress;

    // Paint for the drop outline
    final Paint outlinePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    // Paint for the water fill
    final Paint fillPaint = Paint()
      ..color = progress < 1.0 ? Colors.blue.withOpacity(progress) : Colors.blue
      ..style = PaintingStyle.fill;

    // Define the path for the water drop shape
    Path path = Path();
    path.moveTo(size.width / 2, size.height * 0.1);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.35, size.width / 2, size.height);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.35,
        size.width / 2, size.height * 0.1);
    path.close();

    // Clip the path to create the filling effect
    Path fillPath = Path.from(path);
    fillPath.addRect(
      Rect.fromLTRB(0, fillLevel, size.width, size.height),
    );

    // Draw the filling water
    canvas.drawPath(fillPath, fillPaint);

    // Draw the outline of the drop
    canvas.drawPath(path, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
