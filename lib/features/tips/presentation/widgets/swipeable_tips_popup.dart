import 'package:flutter/material.dart';

class SwipeableTipsPopup extends StatefulWidget {
  final String category; // 'harassment' or 'disaster'

  const SwipeableTipsPopup({super.key, required this.category});

  @override
  State<SwipeableTipsPopup> createState() => _SwipeableTipsPopupState();
}

class _SwipeableTipsPopupState extends State<SwipeableTipsPopup> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _tips {
    if (widget.category == 'harassment') {
      return _harassmentTips;
    } else {
      return _disasterTips;
    }
  }

  final List<Map<String, dynamic>> _harassmentTips = [
    {
      'title': 'Personal Safety',
      'tips': [
        {
          'number': '1. Trust Your Instincts',
          'description': 'If a situation feels uncomfortable, remove yourself.',
        },
        {
          'number': '2. Stay Aware of Your Surroundings',
          'description':
              'Avoid distractions like excessive phone use in unfamiliar places.',
        },
        {
          'number': '3. Set Boundaries',
          'description':
              'Clearly communicate your limits and stand firm if someone crosses them.',
        },
      ],
    },
    {
      'title': 'Workplace & Public Spaces',
      'tips': [
        {
          'number': '1. Speak Up',
          'description':
              'If you experience harassment, document it and report it to the appropriate authorities.',
        },
        {
          'number': '2. Seek Support',
          'description':
              'Talk to a trusted colleague, HR, or support groups if needed.',
        },
        {
          'number': '3. Know Your Rights',
          'description':
              'Understand your legal rights and company policies regarding harassment.',
        },
      ],
    },
    {
      'title': 'Digital Safety',
      'tips': [
        {
          'number': '1. Protect Your Privacy',
          'description':
              'Be careful about sharing personal information online.',
        },
        {
          'number': '2. Block and Report',
          'description':
              'Use blocking and reporting features on social media platforms.',
        },
        {
          'number': '3. Save Evidence',
          'description':
              'Screenshot and save any harassing messages or content.',
        },
      ],
    },
  ];

  final List<Map<String, dynamic>> _disasterTips = [
    {
      'title': 'Emergency Preparedness',
      'tips': [
        {
          'number': '1. Create Emergency Kit',
          'description':
              'Keep water, food, flashlight, radio, and first aid supplies ready.',
        },
        {
          'number': '2. Know Evacuation Routes',
          'description':
              'Plan and practice evacuation routes from your home and workplace.',
        },
        {
          'number': '3. Stay Informed',
          'description':
              'Monitor weather alerts and emergency broadcasts regularly.',
        },
      ],
    },
    {
      'title': 'During Natural Disasters',
      'tips': [
        {
          'number': '1. Stay Calm',
          'description': 'Keep calm and follow your emergency plan.',
        },
        {
          'number': '2. Seek Safe Shelter',
          'description':
              'Move to designated safe areas depending on the disaster type.',
        },
        {
          'number': '3. Avoid Flooded Areas',
          'description': 'Never walk or drive through flooded roads.',
        },
      ],
    },
    {
      'title': 'After Disaster Recovery',
      'tips': [
        {
          'number': '1. Check for Injuries',
          'description':
              'Provide first aid and seek medical attention if needed.',
        },
        {
          'number': '2. Inspect Your Home',
          'description':
              'Check for structural damage and hazards before entering.',
        },
        {
          'number': '3. Contact Family',
          'description': 'Let family and friends know you are safe.',
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            // Modern Header with rounded top and close button
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.red.shade50, Colors.red.shade100],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Safety Tips',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.category == 'harassment'
                              ? 'Harassment Prevention'
                              : 'Disaster Preparedness',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.red.shade600,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content Section
            Expanded(
              child: Column(
                children: [
                  // Swipeable Content
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      itemCount: _tips.length,
                      itemBuilder: (context, index) {
                        final category = _tips[index];
                        return Container(
                          margin: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section Header with icon
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.red.shade100,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        _getCategoryIcon(category['title']),
                                        color: Colors.red.shade700,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      category['title'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Tips
                              Expanded(
                                child: ListView.builder(
                                  itemCount: category['tips'].length,
                                  itemBuilder: (context, tipIndex) {
                                    final tip = category['tips'][tipIndex];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tip['number'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            tip['description'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade700,
                                              height: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Modern Page Indicator
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _tips.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: index == _currentPage ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color:
                                index == _currentPage
                                    ? Colors.red.shade600
                                    : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get appropriate icon for each category
  IconData _getCategoryIcon(String title) {
    switch (title.toLowerCase()) {
      case 'personal safety':
        return Icons.shield_outlined;
      case 'workplace & public spaces':
        return Icons.business_outlined;
      case 'digital safety':
        return Icons.security_outlined;
      case 'emergency preparedness':
        return Icons.emergency_outlined;
      case 'during natural disasters':
        return Icons.warning_outlined;
      case 'after disaster recovery':
        return Icons.healing_outlined;
      default:
        return Icons.info_outline;
    }
  }
}
