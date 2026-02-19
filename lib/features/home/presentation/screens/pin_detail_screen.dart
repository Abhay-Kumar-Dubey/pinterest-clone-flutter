import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/router/app_router.dart';
import '../../../../features/saved/presentation/providers/saved_pins_provider.dart';
import '../../../../core/services/image_download_service.dart';
import '../../../../features/search/presentation/providers/search_provider.dart';
import '../../../../features/search/domain/entities/search_photo.dart';

class PinDetailScreen extends ConsumerStatefulWidget {
  final String imageUrl;
  final String? originalImageUrl;
  final int index;
  final double aspectRatio;
  final String? photographer;
  final String? alt;

  const PinDetailScreen({
    Key? key,
    required this.imageUrl,
    this.originalImageUrl,
    required this.index,
    required this.aspectRatio,
    this.photographer,
    this.alt,
  }) : super(key: key);

  @override
  ConsumerState<PinDetailScreen> createState() => _PinDetailScreenState();
}

class _PinDetailScreenState extends ConsumerState<PinDetailScreen> {
  bool isLiked = false;
  int likeCount = 302;
  bool isSaved = false;
  List<SearchPhoto> relatedPhotos = [];
  bool isLoadingRelated = false;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();

    Future.microtask(() => _loadRelatedPhotos());
  }

  Future<void> _checkIfSaved() async {
    final saved = await ref
        .read(savedPinsProvider.notifier)
        .isPinSaved(widget.imageUrl);
    if (mounted) {
      setState(() {
        isSaved = saved;
      });
    }
  }

  Future<void> _loadRelatedPhotos() async {
    if (widget.alt == null || widget.alt!.isEmpty) return;

    setState(() {
      isLoadingRelated = true;
    });

    final words = widget.alt!.trim().split(RegExp(r'\s+'));
    final searchQuery = words.take(3).join(' ');

    await ref.read(searchProvider.notifier).searchPhotos(searchQuery);

    final searchState = ref.read(searchProvider);
    if (mounted) {
      setState(() {
        relatedPhotos = searchState.photos;
        isLoadingRelated = false;
      });
    }
  }

  String _getSearchQueryFromAlt() {
    if (widget.alt == null || widget.alt!.isEmpty) return '';
    final words = widget.alt!.trim().split(RegExp(r'\s+'));
    return words.take(3).join(' ');
  }

  double _calculateDetailImageHeight() {
    final screenWidth = MediaQuery.of(context).size.width;
    final calculatedHeight = screenWidth * widget.aspectRatio;

    final screenHeight = MediaQuery.of(context).size.height;
    return calculatedHeight.clamp(screenHeight * 0.4, screenHeight * 0.7);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: _calculateDetailImageHeight(),
              floating: false,
              pinned: true,
              leading: Padding(
                padding: EdgeInsets.all(8.w),
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_outlined,
                          color: Colors.black,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: 'pin_${widget.index}',
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24.r),
                        bottomRight: Radius.circular(24.r),
                        topLeft: Radius.circular(24.r),
                        topRight: Radius.circular(24.r),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24.r),
                          bottomRight: Radius.circular(24.r),
                          topLeft: Radius.circular(24.r),
                          topRight: Radius.circular(24.r),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: widget.originalImageUrl ?? widget.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(color: Colors.white),
                          ),
                          errorWidget: (context, url, error) {
                            return Container(
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.image,
                                size: 100.sp,
                                color: Colors.grey[500],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isLiked = !isLiked;
                              likeCount = isLiked
                                  ? likeCount + 1
                                  : likeCount - 1;
                            });
                          },
                          child: Row(
                            children: [
                              Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked ? Colors.red : Colors.black,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '$likeCount',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 24.w),

                        GestureDetector(
                          onTap: () {},
                          child: Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.black,
                            size: 20.sp,
                          ),
                        ),

                        SizedBox(width: 24.w),

                        GestureDetector(
                          onTap: () async {
                            try {
                              await Share.share(
                                widget.originalImageUrl ?? widget.imageUrl,
                                subject: widget.alt ?? 'Check out this pin!',
                              );
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to share'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          },
                          child: Icon(
                            Icons.share_outlined,
                            color: Colors.black,
                            size: 20.sp,
                          ),
                        ),

                        SizedBox(width: 24.w),

                        GestureDetector(
                          onTap: () {
                            _showPinOptionsBottomSheet(context);
                          },
                          child: Icon(
                            Icons.more_horiz,
                            color: Colors.black,
                            size: 20.sp,
                          ),
                        ),

                        Spacer(),

                        ElevatedButton(
                          onPressed: () async {
                            if (isSaved) {
                              await ref
                                  .read(savedPinsProvider.notifier)
                                  .deletePin(widget.imageUrl);
                              setState(() {
                                isSaved = false;
                              });
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Pin removed from saved!'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } else {
                              final success = await ref
                                  .read(savedPinsProvider.notifier)
                                  .savePin(
                                    imageUrl: widget.imageUrl,
                                    photographer: 'aryan_modkharkar_',
                                    aspectRatio: widget.aspectRatio,
                                    originalIndex: widget.index,
                                  );
                              if (success) {
                                setState(() {
                                  isSaved = true;
                                });
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Pin saved!'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSaved
                                ? Colors.grey[800]
                                : Colors.red[600],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 32.w,
                              vertical: 14.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            isSaved ? 'Saved' : 'Save',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 13.r,
                          backgroundColor: Colors.grey[300],
                          child: Icon(Icons.person, size: 20.sp),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          widget.photographer ?? 'aryan_modkharkar_',
                          style: GoogleFonts.roboto(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (widget.alt != null && widget.alt!.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        widget.alt!,
                        style: GoogleFonts.roboto(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[800],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 24.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      'More to explore',
                      style: GoogleFonts.roboto(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),
                ],
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              sliver: SliverToBoxAdapter(
                child: isLoadingRelated
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.h),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : relatedPhotos.isNotEmpty
                    ? MasonryGrid(
                        itemCount: relatedPhotos.length,
                        itemBuilder: (context, index) {
                          final photo = relatedPhotos[index];
                          return PinCard(
                            imageUrl: photo.imageUrl,
                            index: index + 1000,
                            photographer: photo.photographer,
                            alt: photo.alt,
                            aspectRatio: photo.aspectRatio,
                          );
                        },
                      )
                    : MasonryGrid(
                        itemCount: 20,
                        itemBuilder: (context, index) {
                          return PinCard(
                            imageUrl: _getImageForIndex(index),
                            index: index + 100,
                          );
                        },
                      ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 20.h)),
          ],
        ),
      ),
    );
  }

  void _showPinOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PinOptionsBottomSheet(
        imageUrl: widget.imageUrl,
        index: widget.index,
        aspectRatio: widget.aspectRatio,
      ),
    );
  }

  String _getImageForIndex(int index) {
    final images = [
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=500',
      'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?w=500',
      'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=500',
      'https://images.unsplash.com/photo-1614730321146-b6fa6a46bcb4?w=500',
      'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=500',
      'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=500',
      'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=500',
      'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=500',
    ];
    return images[index % images.length];
  }
}

class MasonryGrid extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  const MasonryGrid({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnWidth = (constraints.maxWidth - 8.w) / 2;

        final leftColumnItems = <Widget>[];
        final rightColumnItems = <Widget>[];

        for (int i = 0; i < itemCount; i++) {
          if (i % 2 == 0) {
            leftColumnItems.add(itemBuilder(context, i));
          } else {
            rightColumnItems.add(itemBuilder(context, i));
          }
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: columnWidth,
              child: Column(children: leftColumnItems),
            ),
            SizedBox(width: 8.w),
            SizedBox(
              width: columnWidth,
              child: Column(children: rightColumnItems),
            ),
          ],
        );
      },
    );
  }
}

class PinCard extends StatelessWidget {
  final String imageUrl;
  final int index;
  final String? photographer;
  final String? alt;
  final double? aspectRatio;

  const PinCard({
    Key? key,
    required this.imageUrl,
    required this.index,
    this.photographer,
    this.alt,
    this.aspectRatio,
  }) : super(key: key);

  double _getHeightForIndex(int index) {
    final heights = [
      180.0,
      250.0,
      300.0,
      220.0,
      280.0,
      200.0,
      320.0,
      240.0,
      260.0,
      290.0,
      210.0,
      270.0,
      310.0,
      190.0,
      330.0,
      230.0,
    ];
    return heights[index % heights.length];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: GestureDetector(
        onTap: () {
          context.push(
            AppRouter.pinDetail,
            extra: PinDetailParams(
              imageUrl: imageUrl,
              index: index,
              aspectRatio: aspectRatio ?? 1.5,
              photographer: photographer,
              alt: alt,
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                height: _getHeightForIndex(index).h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.image,
                        size: 50.sp,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2.w),
                      ),
                    );
                  },
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (context) => PinOptionsBottomSheet(
                    imageUrl: imageUrl,
                    index: index,
                    aspectRatio: aspectRatio ?? 1.5,
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 3.h),
                child: Icon(Icons.more_horiz, size: 18.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PinOptionsBottomSheet extends ConsumerStatefulWidget {
  final String imageUrl;
  final int index;
  final double aspectRatio;

  final double _imageWidth = 150.0;

  const PinOptionsBottomSheet({
    Key? key,
    required this.imageUrl,
    required this.index,
    required this.aspectRatio,
  }) : super(key: key);

  double get _imageHeight {
    final calculatedHeight = _imageWidth * aspectRatio;

    return calculatedHeight.clamp(180.0, 320.0);
  }

  @override
  ConsumerState<PinOptionsBottomSheet> createState() =>
      _PinOptionsBottomSheetState();
}

class _PinOptionsBottomSheetState extends ConsumerState<PinOptionsBottomSheet> {
  bool isSaved = false;
  bool isDownloading = false;
  final ImageDownloadService _downloadService = ImageDownloadService();

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    final saved = await ref
        .read(savedPinsProvider.notifier)
        .isPinSaved(widget.imageUrl);
    if (mounted) {
      setState(() {
        isSaved = saved;
      });
    }
  }

  Future<void> _handleSave() async {
    if (isSaved) {
      await ref.read(savedPinsProvider.notifier).deletePin(widget.imageUrl);
      if (mounted) {
        setState(() {
          isSaved = false;
        });
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pin removed from saved!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      final success = await ref
          .read(savedPinsProvider.notifier)
          .savePin(
            imageUrl: widget.imageUrl,
            photographer: 'aryan_modkharkar_',
            aspectRatio: widget.aspectRatio,
            originalIndex: widget.index,
          );
      if (success && mounted) {
        setState(() {
          isSaved = true;
        });
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pin saved!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleDownload() async {
    setState(() {
      isDownloading = true;
    });

    try {
      final success = await _downloadService.downloadImage(widget.imageUrl);

      if (mounted) {
        setState(() {
          isDownloading = false;
        });

        context.pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Image downloaded successfully!'
                  : 'Failed to download image',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isDownloading = false;
        });

        context.pop();

        String errorMessage = 'Failed to download image';
        bool showSettingsButton = false;

        if (e.toString().contains('permission denied') ||
            e.toString().contains('accessDenied')) {
          errorMessage = 'Storage permission denied. Tap Settings to enable.';
          showSettingsButton = true;
        } else if (e.toString().contains('network')) {
          errorMessage = 'Network error. Please check your connection.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 5),
            action: showSettingsButton
                ? SnackBarAction(
                    label: 'Settings',
                    textColor: Colors.white,
                    onPressed: () async {
                      await openAppSettings();
                    },
                  )
                : null,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double overlapOffset = widget._imageHeight / 2;

    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: overlapOffset.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32.r),
              topRight: Radius.circular(32.r),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        color: Colors.transparent,
                        child: Icon(
                          Icons.close,
                          size: 28.sp,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: (overlapOffset / 2).h + 20.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Text(
                  'This Pin is inspired by your recent activity',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 12.h),

              _buildOption(
                icon: Icons.push_pin,
                label: isSaved ? 'Remove from saved' : 'Save',
                onTap: _handleSave,
              ),
              _buildOption(
                icon: Icons.share_outlined,
                label: 'Share',
                onTap: () async {
                  try {
                    context.pop();
                    await Share.share(
                      widget.imageUrl,
                      subject: 'Check out this pin!',
                    );
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to share'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
              ),
              _buildOption(
                icon: Icons.download_outlined,
                label: isDownloading ? 'Downloading...' : 'Download image',
                onTap: isDownloading ? () {} : _handleDownload,
              ),
              _buildOption(
                icon: Icons.favorite_border,
                label: 'See more like this',
                onTap: () {},
              ),
              _buildOption(
                icon: Icons.visibility_off_outlined,
                label: 'See less like this',
                onTap: () {},
              ),
              _buildOption(
                icon: Icons.report_gmailerrorred_outlined,
                label: 'Report Pin',
                subtitle: "This goes against Pinterest's Community Guidelines",
                onTap: () {},
                isLast: true,
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),

        Positioned(
          top: 0,
          child: Container(
            height: widget._imageHeight.h,
            width: widget._imageWidth.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.image,
                      size: 40.sp,
                      color: Colors.grey[400],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.h),
        child: Row(
          crossAxisAlignment: subtitle != null
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 30.sp, color: Colors.black),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      height: 1.1,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
