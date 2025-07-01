import 'package:flutter/material.dart';
import 'package:safecom_final/core/services/safety_data_service.dart';

class EnhancedSOSButton extends StatefulWidget {
  final String category; // 'disaster', 'harassment', or 'general'

  const EnhancedSOSButton({super.key, this.category = 'general'});

  @override
  State<EnhancedSOSButton> createState() => _EnhancedSOSButtonState();
}

class _EnhancedSOSButtonState extends State<EnhancedSOSButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;
  bool _isSOSActive = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _triggerSOS() async {
    if (_isSOSActive) return;

    setState(() {
      _isPressed = true;
    });

    // Show confirmation dialog
    bool? confirmed = await _showSOSConfirmation();

    if (confirmed == true) {
      setState(() {
        _isSOSActive = true;
      });

      // Trigger the SOS alert with category
      final result = await SafetyDataService.triggerSOSAlert(
        category: widget.category,
      );

      if (mounted) {
        _showSOSResult(result);
      }
    }

    setState(() {
      _isPressed = false;
    });
  }

  Future<bool?> _showSOSConfirmation() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text(
                'Emergency SOS',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to trigger an SOS alert?',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                'This will:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                '• Send your location to emergency services',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                '• Start real-time location tracking',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                '• Alert nearby SafeCom users',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(fontSize: 16)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Send SOS',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSOSResult(Map<String, dynamic> result) {
    final bool success = result['success'] ?? false;
    final String message = result['message'] ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: success ? Colors.green : Colors.red,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                success ? 'SOS Sent!' : 'SOS Failed',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(message, style: const TextStyle(fontSize: 16)),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (success) {
                  setState(() {
                    _isSOSActive = false;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: success ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _triggerSOS(),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? _scaleAnimation.value : 1.0,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient:
                    _isSOSActive
                        ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.green[400]!,
                            Colors.green[600]!,
                            Colors.green[800]!,
                          ],
                        )
                        : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.red[400]!,
                            Colors.red[600]!,
                            Colors.red[800]!,
                          ],
                        ),
                boxShadow: [
                  BoxShadow(
                    color: (_isSOSActive ? Colors.green : Colors.red)
                        .withOpacity(0.4),
                    blurRadius: 20 * _pulseAnimation.value,
                    offset: const Offset(0, 8),
                    spreadRadius: 2 * _pulseAnimation.value,
                  ),
                ],
              ),
              child: Center(
                child:
                    _isSOSActive
                        ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ACTIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        )
                        : const Text(
                          'SOS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
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
