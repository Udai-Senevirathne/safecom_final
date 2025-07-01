import 'package:flutter/material.dart';
import '../theme/colors.dart';

class SOSButton extends StatefulWidget {
  final VoidCallback onPressed;
  final double size;
  final bool isEmergency;

  const SOSButton({
    super.key,
    required this.onPressed,
    this.size = 120.0,
    this.isEmergency = false,
  });

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isEmergency) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (!widget.isEmergency) {
          _animationController.forward();
        }
      },
      onTapUp: (_) {
        if (!widget.isEmergency) {
          _animationController.reverse();
        }
        widget.onPressed();
      },
      onTapCancel: () {
        if (!widget.isEmergency) {
          _animationController.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale:
                widget.isEmergency
                    ? _pulseAnimation.value
                    : _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      widget.isEmergency
                          ? [
                            AppColors.emergency,
                            AppColors.error,
                            const Color(0xFF7F1D1D),
                          ]
                          : [
                            AppColors.primary,
                            AppColors.primaryDark,
                            const Color(0xFF7F1D1D),
                          ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.emergency.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: widget.isEmergency ? 4 : 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'SOS',
                  style: TextStyle(
                    color: AppColors.onPrimary,
                    fontSize: widget.size * 0.23,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
