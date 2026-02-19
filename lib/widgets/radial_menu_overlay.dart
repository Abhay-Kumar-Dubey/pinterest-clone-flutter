import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

class RadialMenuOverlay extends StatefulWidget {
  final Offset position;
  final VoidCallback onHide;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onDownload;
  final VoidCallback onMore;

  const RadialMenuOverlay({
    Key? key,
    required this.position,
    required this.onHide,
    required this.onSave,
    required this.onShare,
    required this.onDownload,
    required this.onMore,
  }) : super(key: key);

  @override
  State<RadialMenuOverlay> createState() => _RadialMenuOverlayState();
}

class _RadialMenuOverlayState extends State<RadialMenuOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  int? _hoveredIndex;

  final List<RadialMenuItem> _menuItems = [];

  @override
  void initState() {
    super.initState();

    _menuItems.addAll([
      RadialMenuItem(icon: Icons.push_pin, label: 'Save', onTap: widget.onSave),
      RadialMenuItem(
        icon: Icons.share_outlined,
        label: 'Share',
        onTap: widget.onShare,
      ),
      RadialMenuItem(
        icon: Icons.download_outlined,
        label: 'Download',
        onTap: widget.onDownload,
      ),
      RadialMenuItem(
        icon: Icons.visibility_off_outlined,
        label: 'Hide',
        onTap: widget.onHide,
      ),
    ]);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);

    final dx = localPosition.dx - widget.position.dx;
    final dy = localPosition.dy - widget.position.dy;

    final radius = 80.w;
    final centerAngle = -math.pi / 2;
    final spacingAngle = math.pi / 6;
    final startAngle =
        centerAngle - (spacingAngle * (_menuItems.length - 1) / 2);

    int? newHoveredIndex;
    double minDistance = double.infinity;

    for (int i = 0; i < _menuItems.length; i++) {
      final angle = startAngle + (i * spacingAngle);

      final iconX = radius * math.cos(angle);
      final iconY = radius * math.sin(angle);

      final distanceToIcon = math.sqrt(
        (dx - iconX) * (dx - iconX) + (dy - iconY) * (dy - iconY),
      );

      if (distanceToIcon < 40.w && distanceToIcon < minDistance) {
        minDistance = distanceToIcon;
        newHoveredIndex = i;
      }
    }

    if (_hoveredIndex != newHoveredIndex) {
      setState(() {
        _hoveredIndex = newHoveredIndex;
      });
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_hoveredIndex != null) {
      _menuItems[_hoveredIndex!].onTap();
    }
    _controller.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onTap: () {
        _controller.reverse().then((_) {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      },
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Stack(
          children: [
            // Center point indicator
            Positioned(
              left: widget.position.dx - 4.w,
              top: widget.position.dy - 4.h,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            // Radial menu items
            ..._buildRadialMenuItems(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRadialMenuItems() {
    final radius = 80.w; // Keep your preferred radius

    final centerAngle = -math.pi / 2;

    final spacingAngle = math.pi / 4;

    final startAngle =
        centerAngle - (spacingAngle * (_menuItems.length - 1) / 2);

    return List.generate(_menuItems.length, (index) {
      final angle = startAngle + (index * spacingAngle);
      final x = widget.position.dx + radius * math.cos(angle);
      final y = widget.position.dy + radius * math.sin(angle);

      final isHovered = _hoveredIndex == index;

      return Positioned(
        left: x - 28.w,
        top: y - 28.h,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedScale(
            scale: isHovered ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              width: 56.w,
              height: 56.h,
              decoration: BoxDecoration(
                color: isHovered ? Colors.blue : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _menuItems[index].icon,
                color: isHovered ? Colors.white : Colors.black,
                size: 24.sp,
              ),
            ),
          ),
        ),
      );
    });
  }
}

class RadialMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  RadialMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
