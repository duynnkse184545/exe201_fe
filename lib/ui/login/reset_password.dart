import 'package:flutter/material.dart';
import '../../service/api/user_service.dart';
import '../extra/custom_field.dart';
import '../extra/field_animation.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  final String verificationCode;
  
  const ResetPasswordPage({
    super.key, 
    required this.email,
    required this.verificationCode,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> with TickerProviderStateMixin {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final UserService _userService = UserService();

  late AnimationController _newPasswordShakeController;
  late AnimationController _confirmPasswordShakeController;
  late Animation<double> _newPasswordShake;
  late Animation<double> _confirmPasswordShake;

  String? _newPasswordError;
  String? _confirmPasswordError;
  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();

    _newPasswordShakeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _confirmPasswordShakeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _newPasswordShake = buildShakeAnimation(_newPasswordShakeController);
    _confirmPasswordShake = buildShakeAnimation(_confirmPasswordShakeController);
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
              'Reset Your Password',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),

            Text(
              'Enter your new password for\n${widget.email}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            SizedBox(height: 40),

            AnimatedBuilder(
              animation: _newPasswordShake,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_newPasswordShake.value, 0),
                  child: TextFormField(
                    controller: _newPasswordController,
                    obscureText: _obscureNewPassword,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      errorText: _newPasswordError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),

            AnimatedBuilder(
              animation: _confirmPasswordShake,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_confirmPasswordShake.value, 0),
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      errorText: _confirmPasswordError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 40),

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
                'Reset Password',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

    String newPassword = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    setState(() {
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    bool hasError = false;

    if (newPassword.isEmpty) {
      setState(() => _newPasswordError = 'New password is required');
      _triggerShake(_newPasswordShakeController);
      hasError = true;
    } else if (newPassword.length < 6) {
      setState(() => _newPasswordError = 'Password must be at least 6 characters');
      _triggerShake(_newPasswordShakeController);
      hasError = true;
    }

    if (confirmPassword.isEmpty) {
      setState(() => _confirmPasswordError = 'Please confirm your new password');
      _triggerShake(_confirmPasswordShakeController);
      hasError = true;
    } else if (newPassword != confirmPassword) {
      setState(() => _confirmPasswordError = 'Passwords do not match');
      _triggerShake(_confirmPasswordShakeController);
      hasError = true;
    }

    if (hasError) return;

    setState(() => _isLoading = true);

    try {
      // Call the actual password reset API with code
      final message = await _userService.resetPasswordWithCode(
        widget.email,
        widget.verificationCode,
        newPassword,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate back to login
      Navigator.of(context).popUntil((route) => route.isFirst);
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reset password. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newPasswordShakeController.dispose();
    _confirmPasswordShakeController.dispose();
    super.dispose();
  }
}