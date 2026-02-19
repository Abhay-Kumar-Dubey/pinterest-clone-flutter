import 'package:cached_network_image/cached_network_image.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:pinterest_clone_assignment/core/router/app_router.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/saved_pins_provider.dart';
import '../../domain/entities/saved_pin.dart';

class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    Future.microtask(
      () => ref.read(savedPinsProvider.notifier).loadSavedPins(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Avatar and Tabs
            _buildHeader(),

            // Search Bar and Action Buttons
            _buildSearchAndActions(),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPinsTab(),
                  _buildBoardsTab(),
                  _buildCollagesTab(),
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          // Avatar
          ClerkAuthBuilder(
            signedInBuilder: (context, authState) {
              final user = authState.user;
              final firstName = user?.firstName ?? '';
              final lastName = user?.lastName ?? '';
              final fullName = '$firstName $lastName'.trim();
              final initial = fullName.isNotEmpty
                  ? fullName[0].toUpperCase()
                  : '?';

              return Builder(
                builder: (context) {
                  return GestureDetector(
                    onTap: () {
                      context.push(AppRouter.profile);
                    },
                    child: CircleAvatar(
                      radius: 24.r,
                      backgroundColor: Colors.orange[300],
                      child: Text(
                        initial,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),

          SizedBox(width: 16.w),

          // Tabs
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 25.w),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                // unselectedLabelColor: Colors.grey[600],
                labelStyle: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                ),
                indicatorColor: Colors.black,
                indicatorWeight: 2.h,
                tabs: const [
                  Tab(text: 'Pins'),
                  Tab(text: 'Boards'),
                  Tab(text: 'Collages'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndActions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search your Pins',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[700],
                    size: 24.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // Add Button
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add, size: 28.sp, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildPinsTab() {
    final savedState = ref.watch(savedPinsProvider);

    if (savedState.isLoading) {
      return _buildShimmerLoading();
    }

    if (savedState.error != null) {
      return _buildError(savedState.error!);
    }

    if (savedState.pins.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Filter Buttons
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: [
              _buildFilterChip(icon: Icons.apps, label: '', isSelected: false),
              SizedBox(width: 8.w),
              _buildFilterChip(
                icon: Icons.star,
                label: 'Favourites',
                isSelected: true,
              ),
              SizedBox(width: 8.w),
              _buildFilterChip(
                icon: null,
                label: 'Created by you',
                isSelected: false,
              ),
            ],
          ),
        ),

        // Pins Grid
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: MasonryGridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 5.h,
              crossAxisSpacing: 5.w,
              itemCount: savedState.pins.length,
              itemBuilder: (context, index) {
                final pin = savedState.pins[index];
                return _buildSavedPinCard(pin, index);
              },
            ),
          ),
        ),

        // Pins Count
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Text(
            '${savedState.pins.length} Pins saved',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    IconData? icon,
    required String label,
    required bool isSelected,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: icon != null && label.isEmpty ? 12.w : 16.w,
        vertical: 10.h,
      ),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.grey[200],
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(
              icon,
              size: 20.sp,
              color: isSelected ? Colors.white : Colors.black,
            ),
          if (icon != null && label.isNotEmpty) SizedBox(width: 6.w),
          if (label.isNotEmpty)
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSavedPinCard(SavedPin pin, int index) {
    final screenWidth = ScreenUtil().screenWidth;
    final cardWidth = (screenWidth - 24.w) / 2;
    final calculatedHeight = (cardWidth * pin.aspectRatio).clamp(150.0, 400.0);

    return GestureDetector(
      onTap: () {
        context.push(
          AppRouter.pinDetail,
          extra: PinDetailParams(
            imageUrl: pin.imageUrl,
            index: pin.originalIndex,
            aspectRatio: pin.aspectRatio,
            photographer: pin.photographer,
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          height: calculatedHeight.h,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: CachedNetworkImage(
            imageUrl: pin.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(color: Colors.white),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[300],
              child: Icon(Icons.image, size: 50.sp, color: Colors.grey[400]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBoardsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dashboard_outlined, size: 64.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            'No boards yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Create boards to organize your Pins',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildCollagesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.collections_outlined,
            size: 64.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            'No collages yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Create collages from your saved Pins',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.push_pin_outlined, size: 64.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            'No saved Pins yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48.w),
            child: Text(
              'Save Pins you love to view them here',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            'Failed to load saved pins',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              ref.read(savedPinsProvider.notifier).loadSavedPins();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8.h,
        crossAxisSpacing: 8.w,
        itemCount: 10,
        itemBuilder: (context, index) {
          final heights = [180.0, 250.0, 300.0, 220.0, 280.0];
          final height = heights[index % heights.length];

          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: height.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          );
        },
      ),
    );
  }
}
