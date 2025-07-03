import 'package:exe201/extra/custom_field.dart';
import 'package:flutter/material.dart';
import '../Extra/custom_dialog.dart';
import '../extra/header.dart';

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
    return Scaffold(
        backgroundColor: Color(0xFFF3F4F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              buildHeader(Colors.black87, true),
              SizedBox(height: 24),

              // Cards Section
              _buildCardsSection(),
              SizedBox(height: 24),

              // Action Buttons
              _buildActionButtons(),
              SizedBox(height: 24),

              // Chart Section
              _buildChart(),
              SizedBox(height: 24),

              // Gaming Card
              _buildGamingCard(),
              SizedBox(height: 100), // Space for bottom navigation
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardsSection() {
    return Row(
      children: [
        // Budget Tracker Card
        Expanded(
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Budget Tracker',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Balance',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      '2,875.000d',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Today\'s Expenses',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      '-125.000d',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 16),

        // Study Planner Card
        Expanded(
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFF97316)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Study Planner',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          '9am - 10am',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        Spacer(),
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '8pm - 10pm',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        Spacer(),
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () => _showAddTransactionDialog(context),
          icon: Icon(Icons.add, size: 18),
          label: Text('Add Transaction'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[600],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => _showStartTimerDialog(context),
          icon: Icon(Icons.play_arrow, size: 18),
          label: Text('Start Timer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFEF4444),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
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

  // Add Transaction Dialog
  void _showAddTransactionDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    showCustomBottomSheet<Map<String, dynamic>>(
      context: context,
      title: 'Add Transaction',
      actionText: 'DONE',
      actionColor: Color(0xff7583ca),
      content: Column(
        children: [
          buildFormField(
            label: 'Name',
            controller: nameController,
          ),
          SizedBox(height: 16,),

          buildFormField(
              label: 'Amount',
              controller: amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true)
          ),
        ],
      ),
      onActionPressed: () async{
        final name = nameController.text.trim();
        final amountText = amountController.text.trim();
        if (name.isEmpty || amountText.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Please fill in all fields')));
          return;
        }
        final amount = double.tryParse(amountText);
        if (amount == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter a valid amount')),
          );
          return;
        }
        Navigator.of(context).pop({'name': name, 'amount': amount});
      },
    );
  }

  // Start Timer Dialog
  void _showStartTimerDialog(BuildContext context) {
    showCustomBottomSheet(
      context: context,
      title: 'Start Timer',
      actionText: 'LET\'S DO IT',
      actionColor: Color(0xFFEF4444),
      content: Column(
        children: [
          Text(
            'Task: EXE Figma',
            style: TextStyle(
              color: Color(0xFFEF4444),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '2 hours',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      onActionPressed: () async{
        // Add logic for starting the timer if needed
        Navigator.of(context).pop();
      },
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
