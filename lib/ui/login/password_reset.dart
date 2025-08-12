import 'package:flutter/material.dart';

import '../../service/api/user_service.dart';
import '../extra/custom_field.dart';
import '../extra/field_animation.dart';
import '../extra/pin_verification_dialog.dart';
import 'reset_password.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final UserService _userService = UserService();

  late AnimationController _emailShakeController;
  late Animation<double> _emailShake;

  String? _emailError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _emailShakeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _emailShake = buildShakeAnimation(_emailShakeController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_circle_left_outlined, size: 40, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 60),

            Icon(
              Icons.lock_reset,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 30),

            Text(
              'Forgot Password?',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),

            Text(
              'Enter your email address and we\'ll send you a verification code to reset your password.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            SizedBox(height: 50),

            buildFormField(
              label: 'Email',
              controller: _emailController,
              errorText: _emailError,
              animation: _emailShake,
            ),
            SizedBox(height: 30),

            ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                minimumSize: Size(double.infinity, 48),
                elevation: 0,
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : Text(
                'Send Verification Code',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 30),

            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                'Back to Sign in',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _triggerShake(AnimationController controller) {
    controller.forward(from: 0);
  }

  void _resetPassword() async {
    FocusScope.of(context).unfocus();

    String email = _emailController.text.trim();

    setState(() {
      _emailError = null;
    });

    if (!email.contains('@') || !email.contains('.') || email.length <= 5) {
      setState(() => _emailError = 'Enter a valid email');
      _triggerShake(_emailShakeController);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final message = await _userService.sendForgotPasswordCode(email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );

      // Show PIN verification dialog
      PinVerificationDialog.show(
        context: context,
        email: email,
        title: 'Verify Your Email',
        onVerificationComplete: (success, verificationCode) {
          if (success && verificationCode != null) {
            // Navigate to reset password page with verification code
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ResetPasswordPage(
                  email: email,
                  verificationCode: verificationCode,
                ),
              ),
            );
          }
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _emailError = 'Failed to send verification code. Please try again.');
      _triggerShake(_emailShakeController);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  @override
  void dispose() {
    _emailController.dispose();
    _emailShakeController.dispose();
    super.dispose();
  }
}