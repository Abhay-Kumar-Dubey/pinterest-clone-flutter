import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/router/app_router.dart';
import '../providers/photo_provider.dart';
import 'pin_detail_screen.dart';
import '../../../../widgets/radial_menu_overlay.dart';
import '../../../../features/saved/presentation/providers/saved_pins_provider.dart';
import '../../../../core/services/image_download_service.dart';
import 'package:permission_handler/permission_handler.dart';

class PinterestHomeScreenNew extends ConsumerStatefulWidget {
  const PinterestHomeScreenNew({Key? key}) : super(key: key);

  @override
  ConsumerState<PinterestHomeScreenNew> createState() =>
      _PinterestHomeScreenNewState();
}

class _PinterestHomeScreenNewState
    extends ConsumerState<PinterestHomeScreenNew> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load initial photos
    Future.microtask(() => ref.read(photoProvider.notifier).loadPhotos());

    // Setup pagination
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(photoProvider.notifier).loadPhotos();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photoState = ref.watch(photoProvider);

    return SafeArea(
      child: Column(
        children: [
          // Top App Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      'For you',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Container(color: Colors.black, height: 1.h, width: 62.w),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(13.r),
                  ),
                  child: Icon(Icons.edit, size: 24.sp),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: photoState.photos.isEmpty && photoState.isLoading
                ? _buildShimmerLoading()
                : photoState.photos.isEmpty && photoState.error != null
                ? _buildError(photoState.error!)
                : _buildPhotoGrid(photoState),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(PhotoState photoState) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(photoProvider.notifier).loadPhotos(refresh: true);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: MasonryGridView.count(
          controller: _scrollController,
          crossAxisCount: 2,
          mainAxisSpacing: 8.h,
          crossAxisSpacing: 8.w,
          itemCount: photoState.photos.length + (photoState.isLoading ? 2 : 0),
          itemBuilder: (context, index) {
            if (index >= photoState.photos.length) {
              return _buildShimmerCard();
            }

            final photo = photoState.photos[index];
            return PinCardNew(
              imageUrl: photo.imageUrl,
              originalImageUrl: photo.originalImageUrl,
              photographer: photo.photographer,
              aspectRatio: photo.aspectRatio,
              index: index,
              alt: photo.alt,
            );
          },
        ),
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
        itemBuilder: (context, index) => _buildShimmerCard(),
      ),
    );
  }

  Widget _buildShimmerCard() {
    final heights = [180.0, 250.0, 300.0, 220.0, 280.0];
    final height = heights[DateTime.now().millisecond % heights.length];

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
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            'Failed to load photos',
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
              ref.read(photoProvider.notifier).loadPhotos(refresh: true);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class PinCardNew extends ConsumerWidget {
  final String imageUrl;
  final String originalImageUrl;
  final String photographer;
  final double aspectRatio;
  final int index;
  final String alt;

  const PinCardNew({
    Key? key,
    required this.imageUrl,
    required this.originalImageUrl,
    required this.photographer,
    required this.aspectRatio,
    required this.index,
    required this.alt,
  }) : super(key: key);

  double _calculateCardHeight(double aspectRatio) {
    final screenWidth = ScreenUtil().screenWidth;
    final cardWidth = (screenWidth - 24.w) / 2;

    final calculatedHeight = cardWidth * aspectRatio;
    return calculatedHeight.clamp(150.0, 400.0);
  }

  void _showPinOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PinOptionsBottomSheet(
        imageUrl: imageUrl,
        index: index,
        aspectRatio: aspectRatio,
      ),
    );
  }

  void _showRadialMenu(BuildContext context, Offset position, WidgetRef ref) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, _, __) => RadialMenuOverlay(
          position: position,
          onSave: () async {
            final success = await ref
                .read(savedPinsProvider.notifier)
                .savePin(
                  imageUrl: imageUrl,
                  photographer: photographer,
                  aspectRatio: aspectRatio,
                  originalIndex: index,
                );
            if (success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Pin saved!'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          onShare: () async {
            try {
              await Share.share(
                originalImageUrl,
                subject: alt ?? 'Check out this pin!',
              );
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to share'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            }
          },
          onDownload: () async {
            try {
              final downloadService = ImageDownloadService();
              final success = await downloadService.downloadImage(imageUrl);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Image downloaded successfully!'
                          : 'Failed to download image',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                final showSettings =
                    e.toString().contains('permission') ||
                    e.toString().contains('accessDenied');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to download image'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 3),
                    action: showSettings
                        ? SnackBarAction(
                            label: 'Settings',
                            textColor: Colors.white,
                            onPressed: () => openAppSettings(),
                          )
                        : null,
                  ),
                );
              }
            }
          },
          onHide: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Hide feature coming soon!'),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          },
          onMore: () {
            _showPinOptionsBottomSheet(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        context.push(
          AppRouter.pinDetail,
          extra: PinDetailParams(
            imageUrl: imageUrl,
            originalImageUrl: originalImageUrl,
            index: index,
            aspectRatio: aspectRatio,
            photographer: photographer,
            alt: alt,
          ),
        );
      },
      onLongPressStart: (details) {
        _showRadialMenu(context, details.globalPosition, ref);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Hero(
            tag: 'pin_$index',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                height: _calculateCardHeight(aspectRatio).h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.image,
                      size: 50.sp,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _showPinOptionsBottomSheet(context);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 3.h),
              child: Icon(Icons.more_horiz, size: 18.sp),
            ),
          ),
        ],
      ),
    );
  }
}
