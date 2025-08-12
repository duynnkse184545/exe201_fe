import 'package:flutter/material.dart';
import '../extra/header.dart';
import 'widgets/dashboard_cards.dart';
import 'widgets/action_buttons.dart';
import 'widgets/chart_calendar_slider.dart';
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

                          // Chart and Calendar Slider Section
                          const ChartCalendarSlider(),
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

