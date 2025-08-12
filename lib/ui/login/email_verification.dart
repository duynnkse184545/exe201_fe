import 'package:flutter/material.dart';
import '../../service/api/user_service.dart';
import '../extra/pin_verification_dialog.dart';

class EmailVerificationPage extends StatefulWidget {
  final String? email;
  
  const EmailVerificationPage({super.key, this.email});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final UserService _userService = UserService();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _codeSent = false;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    // Pre-fill email if provided
    if (widget.email != null) {
      _emailController.text = widget.email!;
      // Automatically send verification code when email is pre-filled from login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendVerificationCode();
      });
    }
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
              Icons.email_outlined,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 30),

            Text(
              'Verify Your Email',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),

            Text(
              _codeSent 
                ? 'Enter the verification code sent to your email'
                : 'Enter your email address to receive a verification code',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            SizedBox(height: 40),

            // Email Input Field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              enabled: !_codeSent, // Disable if code already sent
              decoration: InputDecoration(
                labelText: 'Email Address',
                errorText: _emailError,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                ),
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            SizedBox(height: 30),

            // Send/Enter Code Button
            ElevatedButton(
              onPressed: _isLoading ? null : (_codeSent ? _showPinDialog : _sendVerificationCode),
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
                      _codeSent ? 'Enter Verification Code' : 'Send Verification Code',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),

            if (_codeSent) ...[
              SizedBox(height: 20),
              TextButton(
                onPressed: _isLoading ? null : _resendCode,
                child: Text(
                  'Didn\'t receive the code? Resend',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],

            SizedBox(height: 30),

            // Help Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _codeSent 
                        ? 'Check your spam folder if you don\'t see the email in your inbox.'
                        : 'Make sure to enter a valid email address to receive the verification code.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendVerificationCode() async {
    String email = _emailController.text.trim();

    setState(() {
      _emailError = null;
    });

    if (!email.contains('@') || !email.contains('.') || email.length <= 5) {
      setState(() => _emailError = 'Enter a valid email address');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final message = await _userService.resendVerificationCode(email);

      if (!mounted) return;

      setState(() {
        _codeSent = true;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _emailError = 'Failed to send verification code. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _showPinDialog() {
    final email = _emailController.text.trim();
    
    PinVerificationDialog.show(
      context: context,
      email: email,
      title: 'Enter Verification Code',
      onVerificationComplete: (success, code) {
        if (success) {
          Navigator.pop(context, true); // Return success to previous page
        }
      },
    );
  }

  void _resendCode() async {
    final email = _emailController.text.trim();
    setState(() => _isLoading = true);

    try {
      final message = await _userService.resendVerificationCode(email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to resend code. Please try again.'),
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
    _emailController.dispose();
    super.dispose();
  }
}