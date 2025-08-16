import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../extra/theme_extensions.dart';
import '../../../model/models.dart';
import '../../../provider/providers.dart';
import 'user_management_dialog.dart';

class RealUserManagement extends ConsumerStatefulWidget {
  const RealUserManagement({super.key});

  @override
  ConsumerState<RealUserManagement> createState() => _RealUserManagementState();
}

class _RealUserManagementState extends ConsumerState<RealUserManagement> {
  String searchQuery = '';
  String selectedFilter = 'All';
  int currentPage = 1;
  static const int pageSize = 20;

  // Cache for all users data
  List<User>? _allUsersCache;

  @override
  Widget build(BuildContext context) {
    // Only watch the base users provider (without search params)
    final usersAsync = ref.watch(adminUsersBaseNotifierProvider);

    return usersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Error loading users: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(adminUsersBaseNotifierProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (allUsers) {
        // Cache the users data
        _allUsersCache = allUsers;

        // Apply local filtering and pagination
        final filteredUsers = _applyLocalFilters(allUsers);
        final paginatedData = _applyPagination(filteredUsers);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Create Button
              _buildHeader(),
              const SizedBox(height: 16),

              // Search and Filter Section
              _buildSearchAndFilter(),
              const SizedBox(height: 24),

              // Users List Container
              _buildUsersContainer(paginatedData),

              const SizedBox(height: 24),

              // Pagination
              if (paginatedData['totalPages'] > 1)
                _buildPagination(paginatedData['totalPages']),
            ],
          ),
        );
      },
    );
  }

  // Local filtering method - no provider rebuild
  List<User> _applyLocalFilters(List<User> users) {
    return users.where((user) {
      // Search filter
      if (searchQuery.isNotEmpty) {
        final searchLower = searchQuery.toLowerCase();
        if (!user.fullName.toLowerCase().contains(searchLower) &&
            !user.email.toLowerCase().contains(searchLower) &&
            !user.userName.toLowerCase().contains(searchLower)) {
          return false;
        }
      }

      // Role filter
      final roleFilter = _getRoleFilter();
      if (roleFilter != null && user.roleId != roleFilter) {
        return false;
      }

      // Verified filter
      final verifiedFilter = _getVerifiedFilter();
      if (verifiedFilter != null && user.isVerified != verifiedFilter) {
        return false;
      }

      return true;
    }).toList();
  }

  // Local pagination method
  Map<String, dynamic> _applyPagination(List<User> filteredUsers) {
    final totalCount = filteredUsers.length;
    final totalPages = (totalCount / pageSize).ceil();

    // Ensure current page is valid
    if (currentPage > totalPages && totalPages > 0) {
      currentPage = totalPages;
    }

    final startIndex = (currentPage - 1) * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, filteredUsers.length);
    final paginatedUsers = filteredUsers.sublist(startIndex, endIndex);

    return {
      'users': paginatedUsers,
      'totalCount': totalCount,
      'totalPages': totalPages,
      'currentPage': currentPage,
    };
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'User Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showUserDialog(context, isCreate: true),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create User'),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        // Search Field
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  currentPage = 1; // Reset to first page when searching
                });
              },
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    setState(() {
                      searchQuery = '';
                      currentPage = 1;
                    });
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Filter Dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButton<String>(
            value: selectedFilter,
            underline: Container(),
            items: ['All', 'Admin', 'User', 'Verified', 'Unverified']
                .map((filter) => DropdownMenuItem(
              value: filter,
              child: Text(filter),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedFilter = value ?? 'All';
                currentPage = 1; // Reset to first page when filtering
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUsersContainer(Map<String, dynamic> paginatedData) {
    final users = paginatedData['users'] as List<User>;
    final totalCount = paginatedData['totalCount'] as int;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Users ($totalCount)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.primaryColor,
                  ),
                ),
                const Spacer(),
                // Show search/filter status
                if (searchQuery.isNotEmpty || selectedFilter != 'All')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.primaryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Filtered',
                      style: TextStyle(
                        color: context.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Users List
          if (users.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    searchQuery.isNotEmpty || selectedFilter != 'All'
                        ? Icons.search_off
                        : Icons.people_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    searchQuery.isNotEmpty || selectedFilter != 'All'
                        ? 'No users match your search criteria'
                        : 'No users found',
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey[200],
              ),
              itemBuilder: (context, index) {
                final user = users[index];
                return _buildUserTile(user);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildUserTile(User user) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: context.primaryColor.withValues(alpha: 0.1),
        backgroundImage: user.img != null && user.img!.isNotEmpty
            ? NetworkImage(user.img!)
            : null,
        child: user.img == null || user.img!.isEmpty
            ? Text(
          user.fullName.isNotEmpty ? user.fullName.substring(0, 1).toUpperCase() : '?',
          style: TextStyle(
            color: context.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        )
            : null,
      ),
      title: Text(
        user.fullName,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.email,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: user.roleId == 1
                      ? Colors.red.withValues(alpha: 0.1)
                      : Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.roleId == 1 ? 'Admin' : 'User',
                  style: TextStyle(
                    color: user.roleId == 1 ? Colors.red : Colors.blue,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (user.isVerified == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Verified',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          _handleUserAction(value, user);
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 16),
                SizedBox(width: 8),
                Text('Edit'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: currentPage > 1
              ? () {
            setState(() {
              currentPage--;
            });
          }
              : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Text('Page $currentPage of $totalPages'),
        IconButton(
          onPressed: currentPage < totalPages
              ? () {
            setState(() {
              currentPage++;
            });
          }
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  int? _getRoleFilter() {
    switch (selectedFilter) {
      case 'Admin':
        return 1;
      case 'User':
        return 2;
      default:
        return null;
    }
  }

  bool? _getVerifiedFilter() {
    switch (selectedFilter) {
      case 'Verified':
        return true;
      case 'Unverified':
        return false;
      default:
        return null;
    }
  }

  void _handleUserAction(String action, User user) {
    switch (action) {
      case 'edit':
        _showUserDialog(context, user: user, isCreate: false);
        break;
      case 'delete':
        _showDeleteConfirmation(user);
        break;
    }
  }

  void _showDeleteConfirmation(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(adminUsersBaseNotifierProvider.notifier).deleteUser(user.userId);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${user.fullName} deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete user: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showUserDialog(BuildContext context, {User? user, required bool isCreate}) {
    showDialog(
      context: context,
      builder: (context) => UserManagementDialog(
        user: user,
        isCreate: isCreate,
      ),
    );
  }
}