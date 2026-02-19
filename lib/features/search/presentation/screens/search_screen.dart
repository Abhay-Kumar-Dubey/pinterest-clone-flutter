import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:pinterest_clone_assignment/features/home/presentation/screens/pin_detail_screen.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/router/app_router.dart';
import '../providers/search_provider.dart';
import '../../domain/entities/search_photo.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final PageController _carouselController = PageController();
  int _currentCarouselPage = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(searchProvider.notifier).searchPhotos('');
      ref.read(categorySearchProvider.notifier).loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final categoryState = ref.watch(categorySearchProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildSearchBar()),
                if (searchState.query.isNotEmpty) _buildBackButton(),
              ],
            ),
            Expanded(
              child: searchState.query.isEmpty
                  ? _buildDefaultContent(categoryState)
                  : _buildSearchResults(searchState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: EdgeInsets.only(left: 5.w, top: 8.h, bottom: 8.h, right: 14.w),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              _searchController.clear();
              ref.read(searchProvider.notifier).searchPhotos('');
            },
            child: Text('Cancel', style: TextStyle(fontSize: 20.sp)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(10.w),
      child: Container(
        decoration: BoxDecoration(
          // color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.black, width: 1.w),
        ),
        child: TextField(
          controller: _searchController,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              ref.read(searchProvider.notifier).searchPhotos(value);
            }
          },
          decoration: InputDecoration(
            hintText: 'Search for ideas',
            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 18.sp),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey[700],
              size: 24.sp,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.camera_alt_outlined,
                color: Colors.grey[700],
                size: 24.sp,
              ),
              onPressed: () {},
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultContent(CategorySearchState categoryState) {
    if (categoryState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (categoryState.error != null) {
      return Center(child: Text('Error: ${categoryState.error}'));
    }

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCarousel(categoryState),
          SizedBox(height: 7.h),
          _buildCategorySection('wallpapers', categoryState),
          _buildCategorySection('anime', categoryState),
          _buildCategorySection('landscape', categoryState),
          _buildCategorySection('Marvel', categoryState),
        ],
      ),
    );
  }

  Widget _buildCarousel(CategorySearchState categoryState) {
    final carouselImages = <String>[];
    final carouselTitles = ['Wallpapers', 'Anime', 'Landscape', 'Marvel'];
    final carouselCategories = ['wallpapers', 'anime', 'landscape', 'Marvel'];

    for (final category in carouselCategories) {
      final photos = categoryState.categoryPhotos[category];
      if (photos != null && photos.isNotEmpty) {
        carouselImages.add(photos.first.imageUrl);
      }
    }

    if (carouselImages.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 400.h,
          child: PageView.builder(
            controller: _carouselController,
            onPageChanged: (index) {
              setState(() {
                _currentCarouselPage = index;
              });
            },
            itemCount: carouselImages.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = carouselCategories[index];
                  ref
                      .read(searchProvider.notifier)
                      .searchPhotos(carouselCategories[index]);
                },
                child: ClipRRect(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: carouselImages[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(color: Colors.white),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16.h,
                        left: 16.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hues in harmony',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              carouselTitles[index],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            carouselImages.length,
            (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              width: _currentCarouselPage == index ? 8.w : 6.w,
              height: _currentCarouselPage == index ? 8.w : 6.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentCarouselPage == index
                    ? Colors.black
                    : Colors.grey[400],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(
    String category,
    CategorySearchState categoryState,
  ) {
    final photos = categoryState.categoryPhotos[category];

    if (photos == null || photos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    _searchController.text = category;
                    ref.read(searchProvider.notifier).searchPhotos(category);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ideas for you',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        category.substring(0, 1).toUpperCase() +
                            category.substring(1),
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _searchController.text = category;
                    ref.read(searchProvider.notifier).searchPhotos(category);
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      color: Colors.grey[200],
                      shape: BoxShape.rectangle,
                    ),
                    child: Icon(Icons.search, size: 20.sp),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 170.h,
            child: GestureDetector(
              onTap: () {
                _searchController.text = category;
                ref.read(searchProvider.notifier).searchPhotos(category);
              },
              child: SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1.w),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15.r),
                            bottomLeft: Radius.circular(15.r),
                          ),
                          child: SizedBox.expand(
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: photos[0].imageUrl,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: SizedBox.expand(
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: photos[1].imageUrl,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: SizedBox.expand(
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: photos[2].imageUrl,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(15.r),
                            bottomRight: Radius.circular(15.r),
                          ),
                          child: SizedBox.expand(
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: photos[3].imageUrl,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(SearchState searchState) {
    if (searchState.isLoading) {
      return _buildShimmerLoading();
    }

    if (searchState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
            SizedBox(height: 16.h),
            Text('Error: ${searchState.error}'),
          ],
        ),
      );
    }

    if (searchState.photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64.sp, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              'No results found',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8.h,
        crossAxisSpacing: 8.w,
        itemCount: searchState.photos.length,
        itemBuilder: (context, index) {
          final photo = searchState.photos[index];
          return _buildSearchResultCard(photo, index);
        },
      ),
    );
  }

  Widget _buildSearchResultCard(SearchPhoto photo, int index) {
    final screenWidth = ScreenUtil().screenWidth;
    final cardWidth = (screenWidth - 24.w) / 2;
    final calculatedHeight = (cardWidth * photo.aspectRatio).clamp(
      150.0,
      400.0,
    );

    void _showPinOptionsBottomSheet(BuildContext context) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => PinOptionsBottomSheet(
          imageUrl: photo.imageUrl,
          index: index,
          aspectRatio: photo.aspectRatio,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            context.push(
              AppRouter.pinDetail,
              extra: PinDetailParams(
                imageUrl: photo.imageUrl,
                index: index,
                aspectRatio: photo.aspectRatio,
                photographer: photo.photographer,
                alt: photo.alt,
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
                imageUrl: photo.imageUrl,
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
