import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../model/models.dart';
import '../../../provider/providers.dart';
import '../../extra/custom_field.dart';
import '../../extra/theme_extensions.dart';

class UserManagementDialog extends ConsumerStatefulWidget {
  final User? user; // null for create, User object for update
  final bool isCreate;

  const UserManagementDialog({
    super.key,
    this.user,
    required this.isCreate,
  });

  @override
  ConsumerState<UserManagementDialog> createState() => _UserManagementDialogState();
}

class _UserManagementDialogState extends ConsumerState<UserManagementDialog> {
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _userId;
  DateTime? _selectedDate;
  File? _selectedImage;
  String? _currentImageUrl;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _selectedRoleId = 2; // Default to user role
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isCreate && widget.user != null) {
      _loadUserData();
    }
  }

  void _loadUserData() {
    final user = widget.user!;
    print('user $user');
    setState(() {
      _userId = user.userId;
      _fullNameController.text = user.fullName;
      _usernameController.text = user.userName;
      _emailController.text = user.email;
      _selectedDate = user.doB;
      _currentImageUrl = user.img;
      _selectedRoleId = user.roleId;
      _isVerified = user.isVerified ?? false;
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: context.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  bool _validateForm() {
    if (_fullNameController.text.trim().isEmpty) {
      _showError('Full name is required');
      return false;
    }

    if (_usernameController.text.trim().isEmpty) {
      _showError('Username is required');
      return false;
    }

    if (_emailController.text.trim().isEmpty ||
        !RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim())) {
      _showError('Please enter a valid email');
      return false;
    }

    if (widget.isCreate) {
      if (_passwordController.text.trim().isEmpty) {
        _showError('Password is required');
        return false;
      }

      if (_passwordController.text.length < 6) {
        _showError('Password must be at least 6 characters');
        return false;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        _showError('Passwords do not match');
        return false;
      }
    }

    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showRoleSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Admin'),
              leading: Radio<int>(
                value: 1,
                groupValue: _selectedRoleId,
                onChanged: (value) {
                  setState(() {
                    _selectedRoleId = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('User'),
              leading: Radio<int>(
                value: 2,
                groupValue: _selectedRoleId,
                onChanged: (value) {
                  setState(() {
                    _selectedRoleId = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleVerification() {
    setState(() {
      _isVerified = !_isVerified;
    });
  }

  Future<void> _saveUser() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.isCreate) {
        // Create new user
        final userRequest = UserRequest(
          fullName: _fullNameController.text.trim(),
          userName: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          passwordHash: _passwordController.text.trim(),
          doB: _selectedDate,
          roleId: _selectedRoleId,
        );

        final userService = ref.read(userServiceProvider);
        await userService.createUser(userRequest);
        
        _showSuccess('User created successfully!');
      } else {
        // Update existing user
        final userRequest = UserRequest(
          userId: _userId,
          fullName: _fullNameController.text.trim(),
          userName: _usernameController.text.trim(),
          email: null,
          passwordHash: widget.user!.passwordHash,
          doB: _selectedDate,
          img: _selectedImage,
          roleId: _selectedRoleId,
        );
        print('userRequest $userRequest');
        final userService = ref.read(userServiceProvider);
        await userService.updateUser(userRequest);
        
        _showSuccess('User updated successfully!');
      }

      // Refresh the users list
      ref.invalidate(adminUsersNotifierProvider);
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showError('Failed to ${widget.isCreate ? 'create' : 'update'} user: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  widget.isCreate ? Icons.person_add : Icons.edit,
                  color: context.primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.isCreate ? 'Create New User' : 'Update User',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if(!widget.isCreate)...[
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: context.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: context.primaryColor.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: _selectedImage != null
                              ? ClipOval(
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                            ),
                          )
                              : _currentImageUrl != null &&
                              _currentImageUrl!.isNotEmpty
                              ? ClipOval(
                            child: Image.network(
                              _currentImageUrl!,
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.add_a_photo,
                                  color: context.primaryColor,
                                  size: 40,
                                );
                              },
                            ),
                          )
                              : Icon(
                            Icons.add_a_photo,
                            color: context.primaryColor,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to ${_selectedImage != null ||
                            (_currentImageUrl?.isNotEmpty ?? false)
                            ? 'change'
                            : 'add'} photo',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    // Full Name
                    buildFormField(
                      label: 'Full Name',
                      controller: _fullNameController,
                    ),
                    const SizedBox(height: 16),

                    // Username
                    buildFormField(
                      label: 'Username',
                      controller: _usernameController,
                    ),
                    const SizedBox(height: 16),

                    if(!widget.isCreate)
                    buildFormField(
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Password fields (only for create)
                    if (widget.isCreate) ...[
                      buildFormField(
                        label: 'Password',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        showToggle: true,
                        onToggle: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      buildFormField(
                        label: 'Confirm Password',
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        showToggle: true,
                        onToggle: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Date of Birth
                    GestureDetector(
                      onTap: _selectDate,
                      child: buildFormField(
                        label: 'Date of Birth (Optional)',
                        controller: TextEditingController(
                          text: _selectedDate != null
                              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                              : '',
                        ),
                        enabled: false,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Role Selection
                    GestureDetector(
                      onTap: _showRoleSelector,
                      child: buildFormField(
                        label: 'Role',
                        controller: TextEditingController(
                          text: _selectedRoleId == 1 ? 'Admin' : 'User',
                        ),
                        enabled: false,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Verification Status (only for update)
                    if (!widget.isCreate) ...[
                      GestureDetector(
                        onTap: _toggleVerification,
                        child: buildFormField(
                          label: 'Verification Status',
                          controller: TextEditingController(
                            text: _isVerified ? 'Verified' : 'Not Verified',
                          ),
                          enabled: false,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(widget.isCreate ? 'Create User' : 'Update User'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}