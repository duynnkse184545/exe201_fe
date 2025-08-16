import 'package:flutter/material.dart';
import '../nav_bar.dart';
import '../service/storage/token_storage.dart';
import 'login/login_ui.dart';
import 'admin/admin_dashboard.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final TokenStorage _tokenStorage = TokenStorage();
  bool _isLoading = true;
  bool _isAuthenticated = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      // Check if token exists and is valid
      final isValid = await _tokenStorage.isTokenValid();
      
      if (isValid) {
        // Check if user is admin
        final isAdmin = await _tokenStorage.isAdmin();
        
        // Optional: Log user info for debugging
        final userId = await _tokenStorage.getUserId();
        final username = await _tokenStorage.getUsername();
        final roleId = await _tokenStorage.getUserRoleId();
        print('Auto-login successful - User ID: $userId, Username: $username, Role: $roleId, IsAdmin: $isAdmin');
        
        setState(() {
          _isAuthenticated = isValid;
          _isAdmin = isAdmin;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isAuthenticated = false;
          _isAdmin = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error checking auth status: $e');
      setState(() {
        _isAuthenticated = false;
        _isAdmin = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 60,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 30),
              
              // Loading indicator
              CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
              SizedBox(height: 20),
              
              // Loading text
              Text(
                'Checking authentication...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Navigate based on authentication status and role
    if (!_isAuthenticated) {
      return LoginPage();
    }
    
    // If user is admin (role = 1), show admin dashboard
    if (_isAdmin) {
      return AdminDashboard();
    }
    
    // Otherwise show normal user interface
    return BottomTab();
  }
}