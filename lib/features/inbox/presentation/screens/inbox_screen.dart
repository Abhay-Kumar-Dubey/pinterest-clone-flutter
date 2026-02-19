import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            // Content
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Messages Section
                  _buildMessagesSection(),

                  SizedBox(height: 24.h),

                  // Updates Section
                  _buildUpdatesSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Inbox',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Icon(Icons.edit_outlined, size: 28.sp, color: Colors.black),
        ],
      ),
    );
  }

  Widget _buildMessagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Messages Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Messages',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  Text(
                    'See all',
                    style: TextStyle(fontSize: 16.sp, color: Colors.black),
                  ),
                  Icon(Icons.chevron_right, size: 20.sp, color: Colors.black),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        // Invite Friends Card
        _buildInviteFriendsCard(),
      ],
    );
  }

  Widget _buildInviteFriendsCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: InkWell(
        onTap: () {
          // Handle invite friends tap
        },
        child: Row(
          children: [
            // Icon
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_add_outlined,
                size: 28.sp,
                color: Colors.black,
              ),
            ),

            SizedBox(width: 16.w),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invite your friends',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Connect to start chatting',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Updates Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'Updates',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),

        SizedBox(height: 16.h),

        // Update Items
        _buildUpdateItem(
          icon: Icons.search,
          title: 'Still searching? Explore ideas related to House',
          time: '8h',
          iconBackgroundColor: Colors.grey[200],
        ),
        _buildUpdateItem(
          imageUrl: 'https://via.placeholder.com/56',
          title: "It's all about you",
          time: '10h',
        ),
        _buildUpdateItem(
          imageUrl: 'https://via.placeholder.com/56',
          title: 'Your next obsession awaits 👀',
          time: '1d',
        ),
        _buildUpdateItem(
          imageUrl: 'https://via.placeholder.com/56',
          title: 'Your latest search results are in',
          time: '4d',
        ),
      ],
    );
  }

  Widget _buildUpdateItem({
    IconData? icon,
    String? imageUrl,
    required String title,
    required String time,
    Color? iconBackgroundColor,
  }) {
    return InkWell(
      onTap: () {
        // Handle update item tap
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            // Icon or Image
            if (icon != null)
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: iconBackgroundColor ?? Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28.sp, color: Colors.black),
              )
            else if (imageUrl != null)
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.image,
                          size: 28.sp,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  ),
                ),
              ),

            SizedBox(width: 16.w),

            // Title and Time
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 16.sp, color: Colors.black),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    time,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            // More Icon
            Icon(Icons.more_horiz, size: 24.sp, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
