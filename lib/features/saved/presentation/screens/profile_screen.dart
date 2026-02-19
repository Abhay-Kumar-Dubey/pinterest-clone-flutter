import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  Future<void> _handleSignOut(BuildContext context) async {
    try {
      final auth = ClerkAuth.of(context);
      await auth.signOut();

      context.pop();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to sign out: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Your account',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Profile Header
          _buildProfileHeader(context),

          SizedBox(height: 24.h),

          // Settings Section
          _buildSectionTitle('Settings'),
          _buildMenuItem(context, 'Account management'),
          _buildMenuItem(context, 'Profile visibility'),
          _buildMenuItem(context, 'Refine your recommendations'),
          _buildMenuItem(context, 'Claimed external accounts'),
          _buildMenuItem(context, 'Social permissions'),
          _buildMenuItem(context, 'Notifications'),
          _buildMenuItem(context, 'Privacy and data'),
          _buildMenuItem(context, 'Reports and violations centre'),

          SizedBox(height: 16.h),

          // Login Section
          _buildSectionTitle('Login'),
          _buildMenuItem(context, 'Add account'),
          _buildMenuItem(context, 'Security'),
          _buildMenuItem(
            context,
            'Log out',
            showArrow: false,
            onTap: () => _handleSignOut(context),
          ),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return ClerkAuthBuilder(
      signedInBuilder: (context, authState) {
        final user = authState.user;
        final firstName = user?.firstName ?? '';
        final lastName = user?.lastName ?? '';
        final fullName = '$firstName $lastName'.trim();
        final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Row(
            children: [
              // Avatar with real initial
              CircleAvatar(
                radius: 28.r,
                backgroundColor: Colors.orange[300],

                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Real username
                    Text(
                      fullName.isNotEmpty ? fullName : 'No name',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 24.sp, color: Colors.black),
            ],
          ),
        );
      },
      signedOutBuilder: (context, authState) => const SizedBox.shrink(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Text(
        title,
        style: TextStyle(fontSize: 16.sp, color: Colors.black),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title, {
    bool showArrow = true,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            if (showArrow)
              Icon(Icons.chevron_right, size: 24.sp, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
