import 'package:flutter/material.dart';

import '../../model/user.dart';
import '../../service/api/user_service.dart';
import '../extra/custom_field.dart';
import '../extra/field_animation.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AnimationController _usernameShakeController;
  late AnimationController _emailShakeController;
  late AnimationController _passwordShakeController;
  late AnimationController _confirmPasswordShakeController;
  late Animation<double> _usernameShake;
  late Animation<double> _emailShake;
  late Animation<double> _passwordShake;
  late Animation<double> _confirmPasswordShake;

  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Validation states
  bool _isUsernameValid = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;

  @override
  void initState() {
    super.initState();

    _usernameShakeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _emailShakeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _passwordShakeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _confirmPasswordShakeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _usernameShake = buildShakeAnimation(_usernameShakeController);
    _emailShake = buildShakeAnimation(_emailShakeController);
    _passwordShake = buildShakeAnimation(_passwordShakeController);
    _confirmPasswordShake = buildShakeAnimation(_confirmPasswordShakeController);

    // Add listeners to validate fields in real-time
    _usernameController.addListener(_validateUsername);
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);
  }

  void _validateUsername() {
    String username = _usernameController.text.trim();
    setState(() {
      _isUsernameValid = username.length >= 3 && username.isNotEmpty;
    });
  }

  void _validateEmail() {
    String email = _emailController.text.trim();
    setState(() {
      _isEmailValid = email.contains('@') && email.contains('.') && email.length > 5;
    });
  }

  void _validatePassword() {
    String password = _passwordController.text;
    setState(() {
      _isPasswordValid = password.length >= 6;
    });
    // Also revalidate confirm password when password changes
    _validateConfirmPassword();
  }

  void _validateConfirmPassword() {
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;
    setState(() {
      _isConfirmPasswordValid = confirmPassword.isNotEmpty && password == confirmPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_circle_left_outlined, size: 40, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Color(0xff7583ca),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),

            Text(
              'Create your Account',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 50),

            buildFormField(
              label: 'Username',
              controller: _usernameController,
              errorText: _usernameError,
              animation: _usernameShake,
              isValid: _isUsernameValid,
            ),
            SizedBox(height: 20),

            buildFormField(
              label: 'Email',
              controller: _emailController,
              errorText: _emailError,
              animation: _emailShake,
              isValid: _isEmailValid,
            ),
            SizedBox(height: 20),

            buildFormField(
              label: 'Password',
              controller: _passwordController,
              obscureText: _obscurePassword,
              showToggle: true,
              onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
              errorText: _passwordError,
              animation: _passwordShake,
              isValid: _isPasswordValid,
            ),
            SizedBox(height: 20),

            buildFormField(
              label: 'Confirm Password',
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              showToggle: true,
              onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              errorText: _confirmPasswordError,
              animation: _confirmPasswordShake,
              isValid: _isConfirmPasswordValid,
            ),
            SizedBox(height: 30),

            ElevatedButton(
              onPressed: _isLoading ? null : _signUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff7583ca),
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
                'Sign up',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 30),

            Text(
              '- Or sign up with -',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSocialButton(
                  onPressed: () {},
                  child: Image.asset(
                    'assets/google.png',
                    height: 24,
                    width: 24,
                  ),
                ),
                _buildSocialButton(
                  onPressed: () {},
                  child: Icon(Icons.facebook, color: Color(0xFF1877F2), size: 28),
                ),
                _buildSocialButton(
                  onPressed: () {},
                  child: Icon(Icons.flutter_dash, color: Color(0xFF1DA1F2), size: 24),
                ),
              ],
            ),
            SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account? ",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    'Sign in',
                    style: TextStyle(
                      color: Color(0xff7583ca),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onPressed,
    required Widget child,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Center(child: child),
        ),
      ),
    );
  }


  void _triggerShake(AnimationController controller) {
    controller.forward(from: 0);
  }

  void _signUp() async {
    FocusScope.of(context).unfocus();

    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    setState(() {
      _usernameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    bool valid = true;

    if (username.length < 3) {
      setState(() => _usernameError = 'Username must be at least 3 characters');
      _triggerShake(_usernameShakeController);
      valid = false;
    }

    if (!email.contains('@') || !email.contains('.') || email.length <= 5) {
      setState(() => _emailError = 'Enter a valid email');
      _triggerShake(_emailShakeController);
      valid = false;
    }

    if (password.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      _triggerShake(_passwordShakeController);
      valid = false;
    }

    if (password != confirmPassword) {
      setState(() => _confirmPasswordError = 'Passwords do not match');
      _triggerShake(_confirmPasswordShakeController);
      valid = false;
    }

    if (!valid) return;

    setState(() => _isLoading = true);

    try {
      final userService = UserService();

      final userCreate = User(
        fullName: "",
        userName: username,
        email: email,
        doB: null,
        passwordHash: password,
      );

      await userService.createUser(userCreate);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account created successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-up failed: $e')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_validateUsername);
    _emailController.removeListener(_validateEmail);
    _passwordController.removeListener(_validatePassword);
    _confirmPasswordController.removeListener(_validateConfirmPassword);

    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameShakeController.dispose();
    _emailShakeController.dispose();
    _passwordShakeController.dispose();
    _confirmPasswordShakeController.dispose();
    super.dispose();
  }
}