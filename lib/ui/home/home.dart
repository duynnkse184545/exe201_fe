import 'package:exe201/ui/home/demo.dart';
import 'package:flutter/material.dart';
import '../extra/header.dart';
import 'widgets/dashboard_cards.dart';
import 'widgets/action_buttons.dart';
import '../../service/storage/token_storage.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeTabPage();
  }
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: FutureBuilder<String?>(
          future: TokenStorage().getUserId(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Unable to load user data',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please log in again',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            final userId = snapshot.data!;

            return LayoutBuilder(
              builder: (context, constraints) {
                return SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 48, // Account for padding
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Section
                          buildHeader(color: Colors.black87, subtitle: "Here is today\'s overview" ),
                          SizedBox(height: 24),

                          // Cards Section
                          DashboardCards(userId: userId),
                          SizedBox(height: 20),

                          // Action Buttons
                          ActionButtons(userId: userId),
                          SizedBox(height: 24),

                          // Chart Section
                          CalendarSummary(),
                          SizedBox(height: 24),

                          // Gaming Card
                          _buildGamingCard(),
                          SizedBox(height: 100), // Space for bottom navigation
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        )
    );
  }



  Widget _buildChart() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: EdgeInsets.all(20),
      child: CustomPaint(
        painter: ChartPainter(),
        size: Size(double.infinity, 100),
      ),
    );
  }

  Widget _buildGamingCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF059669),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'VCB DREAMHACK',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'NGOẠI HẠNG ANH GỢP HỘI',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

}

class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF6366F1)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.4,
      size.width * 0.5,
      size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.2,
      size.width,
      size.height * 0.5,
    );

    canvas.drawPath(path, paint);

    // Fill area under curve
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Color(0xFF6366F1).withValues(alpha: 0.3),
          Color(0xFF6366F1).withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
