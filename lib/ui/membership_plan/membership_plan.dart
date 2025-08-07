import 'dart:convert';
import 'package:exe201/service/storage/token_storage.dart';
import 'package:http/http.dart' as http;
import 'package:exe201/model/membership_plan.dart';
import 'package:exe201/service/api/membership_plan_service.dart';
import 'package:flutter/material.dart';
import 'package:exe201/ui/membership_plan/widgets/plan_card_widget.dart';
import 'package:url_launcher/url_launcher.dart';


class MemberPlan extends StatefulWidget {
  const MemberPlan({super.key});

  @override
  State<MemberPlan> createState() => _MemberPlanState();
}

class _MemberPlanState extends State<MemberPlan> {
  final MembershipPlanService _planService = MembershipPlanService();
  List<MembershipPlan> _plans = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _planService.getAllPlans();
      
      if (response.success && response.data != null) {
        setState(() {
          _plans = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Không thể tải danh sách gói';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi kết nối: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chọn gói thành viên',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadPlans,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPlans,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorState();
    }

    if (_plans.isEmpty) {
      return _buildEmptyState();
    }

    return _buildPlansList();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B68EE)),
          ),
          SizedBox(height: 16),
          Text(
            'Đang tải danh sách gói...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            SizedBox(height: 16),
            Text(
              'Lỗi tải dữ liệu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPlans,
              icon: Icon(Icons.refresh),
              label: Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7B68EE),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Không có gói nào',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Hiện tại chưa có gói thành viên nào khả dụng',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPlans,
              icon: Icon(Icons.refresh),
              label: Text('Tải lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7B68EE),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlansList() {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          SizedBox(height: 20),

          // Header Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF7B68EE), Color(0xFF9B59B6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.workspace_premium,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Nâng cấp Premium',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Trải nghiệm tính năng cao cấp và không giới hạn',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          SizedBox(height: 30),

          // Plans List
          ..._plans.map((plan) => PlanCard(
            planName: plan.planName,
            price: plan.formattedPrice,
            duration: plan.durationText,
            primaryColor: Color(plan.colorValue),
            isPopular: plan.isPopular,
            features: plan.features,
            onTap: () => _selectPlan(context, plan),
          )).toList(),

          SizedBox(height: 30),

          // Special Offer (chỉ hiển thị khi có plans)
          if (_plans.isNotEmpty) ...[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.white,
                    size: 30,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ưu đãi đặc biệt!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Giảm 50% cho 3 tháng đầu tiên',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Terms and Conditions
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Bằng cách đăng ký, bạn đồng ý với Điều khoản dịch vụ và Chính sách bảo mật của chúng tôi. Có thể hủy bất cứ lúc nào.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          SizedBox(height: 40),
        ],
      ),
    );
  }

  void _selectPlan(BuildContext context, MembershipPlan plan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Color(0xFF4CAF50),
                size: 28,
              ),
              SizedBox(width: 8),
              Text('Xác nhận đăng ký'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bạn có muốn đăng ký gói ${plan.planName} không?'),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chi tiết gói:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text('Tên gói: ${plan.planName}'),
                    Text('Giá: ${plan.formattedPrice}'),
                    Text('Thời hạn: ${plan.durationDays} ngày'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Hủy',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _processPurchase(plan);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(plan.colorValue),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processPurchase(MembershipPlan plan) async {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(plan.colorValue))),
            SizedBox(height: 16),
            Text('Đang tạo liên kết thanh toán...'),
          ],
        ),
      ),
    );

    try {
      final paymentResponse = await _createPaymentLink(plan);
      if (!mounted) return;

      Navigator.of(context).pop(); // Close progress dialog

      if (paymentResponse['isSuccess'] == true) {
        final paymentUrl = paymentResponse['data']['paymentUrl'];
        debugPrint('Payment URL: $paymentUrl');
        _showPaymentSuccessDialog(plan, paymentUrl);
      } else {
        _showErrorDialog(paymentResponse['message'] ?? 'Không thể tạo liên kết thanh toán');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _showErrorDialog('Lỗi kết nối: ${e.toString()}');
    }
  }

// Method to call PayOS API
  Future<Map<String, dynamic>> _createPaymentLink(MembershipPlan plan) async {
    final url = Uri.parse('https://exe2yuni.runasp.net/api/PayOs/create-payment-link');
    
    // You'll need to get the actual userId from your authentication service
    // This is just a placeholder - replace with actual user ID
    // final String userId = "your-user-id-here"; // TODO: Get from auth service
    final tokenStorage = TokenStorage();
    final userId = await tokenStorage.getUserId();

    if (userId == null) {
      throw Exception('User ID not found. Please log in again.');
    }
    
    final requestBody = {
      "userId": userId,
      "membershipPlanId": plan.mPid, // Assuming this is the plan ID
      "amount": plan.price, // Assuming plan has a price property
      "productName": plan.planName,
      "description": "Register Y-Uni ${plan.planName}",
      "returnUrl": "https://exe2yuni.runasp.net/success",
      "cancelUrl": "https://exe2yuni.runasp.net/cancel"
    };
    debugPrint('Request Body: $requestBody');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        // Add authorization header if required
        // 'Authorization': 'Bearer your-token-here',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create payment link: ${response.statusCode}');
    }
  }

  void _showPaymentSuccessDialog(MembershipPlan plan, String paymentUrl) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: const [
            Icon(Icons.payment, color: Color(0xFF4CAF50), size: 28),
            SizedBox(width: 8),
            Text('Thanh toán'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Liên kết thanh toán đã được tạo thành công!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chi tiết thanh toán:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Gói: ${plan.planName}'),
                  Text('Giá: ${plan.formattedPrice}'),
                  Text('Thời hạn: ${plan.durationText}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Nhấn "Tiến hành thanh toán" để chuyển đến trang thanh toán PayOS.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Hủy', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _launchPaymentUrl(paymentUrl);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(plan.colorValue),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Tiến hành thanh toán'),
          ),
        ],
      ),
    );
  }

// Method to launch payment URL
  Future<void> _launchPaymentUrl(String paymentUrl) async {
    final Uri url = Uri.parse(paymentUrl);
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication, // Opens in browser
        );
      } else {
        throw Exception('Could not launch payment URL');
      }
    } catch (e) {
      // Handle error - maybe show a dialog with the payment URL for manual copy
      print('Error launching URL: $e');
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Lỗi thanh toán'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7B68EE),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

}