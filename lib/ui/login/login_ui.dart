import 'package:exe201/nav_bar.dart';
import 'package:exe201/service/api/auth_service.dart';
import 'package:exe201/service/api/exceptions/auth_exceptions.dart';
import 'package:exe201/ui/auth_wrapper.dart';
import 'package:flutter/material.dart';

import '../extra/custom_field.dart';
import '../extra/field_animation.dart';
import '../../service/api/dto/auth_request.dart';
import '../../service/google_sign_in_service.dart';
import '../../service/api/user_service.dart';
import 'password_reset.dart';
import 'sign_up.dart';
import 'email_verification.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _usernameShakeController;
  late AnimationController _passwordShakeController;
  late Animation<double> _usernameShake;
  late Animation<double> _passwordShake;

  String? _usernameError;
  String? _passwordError;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    _usernameShakeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _passwordShakeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _usernameShake = buildShakeAnimation(_usernameShakeController);
    _passwordShake = buildShakeAnimation(_passwordShakeController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Image.asset(
              'assets/yuni-logo.png',
              height: 150,
              width: 150,
            ),
            SizedBox(height: 10),

            Text(
              'Welcome Back!',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 30),

            buildFormField(
              label: 'Username',
              controller: _usernameController,
              errorText: _usernameError,
              animation: _usernameShake,
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
            ),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                  );
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Color(0xff7583ca),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),


            ElevatedButton(
              onPressed: _isLoading ? null : _login,
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
                'Sign in',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 30),

            Text(
              '- Or -',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 20),

            // Google Sign In Button
            ElevatedButton(
              onPressed: _isLoading ? null : _signInWithGoogle,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                minimumSize: Size(double.infinity, 48),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/google.png',
                    height: 20,
                    width: 20,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Sign in with Google',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),

            // Sign up link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  },
                  child: Text(
                    'Sign up',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
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


  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameShakeController.dispose();
    _passwordShakeController.dispose();
    super.dispose();
  }

  void _triggerShake(AnimationController controller) {
    controller.forward(from: 0);
  }

  void _login() async {
    FocusScope.of(context).unfocus();

    final authService = AuthService();
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    setState(() {
      _usernameError = null;
      _passwordError = null;
    });

    bool valid = true;

    if (username.isEmpty) {
      setState(() => _usernameError = 'Please enter username');
      _triggerShake(_usernameShakeController);
      valid = false;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = 'Please enter password');
      _triggerShake(_passwordShakeController);
      valid = false;
    }

    if (!valid) return;

    setState(() => _isLoading = true);

    await Future.delayed(Duration(seconds: 1));

    try {
      await authService.login(
        AuthRequest(username: username, password: password),
      );

      if (!mounted) return;

      // Login successful - navigate to main app
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AuthWrapper()),
      );
    } on UnverifiedEmailException catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      // Show message and navigate to email verification page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please verify your email to continue'),
          backgroundColor: Colors.orange,
        ),
      );

      // Navigate to email verification page
      final verified = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EmailVerificationPage(),
        ),
      );

      if (verified == true) {
        // Try login again after verification
        _login();
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _usernameError = 'Invalid username or password';
        _passwordError = 'Invalid username or password';
        _isLoading = false; // Reset loading state on error
      });
      _triggerShake(_usernameShakeController);
      _triggerShake(_passwordShakeController);
    }
  }

  void _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      // Get Google ID token
      final String? idToken = await GoogleSignInService.signIn();
      
      if (idToken == null) {
        // User cancelled sign-in
        setState(() => _isLoading = false);
        return;
      }

      // Login with backend using the ID token
      final userService = UserService();
      await userService.loginWithGoogle(idToken);

      if (!mounted) return;

      // Login successful - navigate to main app
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BottomTab()),
      );
    } catch (e) {
      if (!mounted) return;
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google sign-in failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      
      setState(() => _isLoading = false);
    }
  }

}
