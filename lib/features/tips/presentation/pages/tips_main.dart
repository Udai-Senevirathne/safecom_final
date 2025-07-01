import 'package:flutter/material.dart';
import 'package:safecom_final/Core/navigation/appnavigator.dart';
import 'package:safecom_final/Core/navigation/app_routes.dart';
import '../widgets/swipeable_tips_popup.dart';

class TipsMain extends StatefulWidget {
  final String initialCategory; // 'harassment' or 'disaster'

  const TipsMain({super.key, this.initialCategory = 'harassment'});

  @override
  State<TipsMain> createState() => _TipsMainState();
}

class _TipsMainState extends State<TipsMain> {
  late String selectedCategory;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2, // Tips selected
        selectedItemColor: const Color(0xFF10B981), // Green theme for tips
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        onTap: (index) {
          switch (index) {
            case 0:
              AppNavigator.pushReplacement(AppRoutes.homeHarass);
              break;
            case 1:
              AppNavigator.pushReplacement(AppRoutes.homeDisaster);
              break;
            case 2:
              // Already on tips screen
              break;
            case 3:
              AppNavigator.push(AppRoutes.profile);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.woman), label: 'Harassment'),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber),
            label: 'Disaster',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            label: 'Tips',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header with gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.red.shade50, Colors.red.shade100],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Title
                    Text(
                      'Safety Resources',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Category Tabs
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = 'harassment';
                            });
                          },
                          child: _buildModernTab(
                            'Harassment',
                            selectedCategory == 'harassment',
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = 'disaster';
                            });
                          },
                          child: _buildModernTab(
                            'Disaster',
                            selectedCategory == 'disaster',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Wellness Check-in Section
                    _buildWellnessCheckIn(),

                    const SizedBox(height: 32),

                    // Modern Menu Options
                    _buildModernMenuOption(
                      'Safety Tips',
                      'Learn $selectedCategory prevention techniques',
                      Icons.lightbulb_outlined,
                      Colors.blue,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => SwipeableTipsPopup(
                                category: selectedCategory,
                              ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildModernMenuOption(
                      'Counselling',
                      'Professional support and guidance',
                      Icons.psychology_outlined,
                      Colors.green,
                      onTap: () {
                        _showCounsellingOptions();
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildModernMenuOption(
                      'Emergency Contacts',
                      'Quick access to help and support',
                      Icons.contact_phone_outlined,
                      Colors.orange,
                      onTap: () {
                        _showEmergencyContacts();
                      },
                    ),

                    const SizedBox(height: 32),

                    // Additional Info Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.red.shade50, Colors.red.shade100],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.red.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Quick Access',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap any option above for instant access to safety resources and support.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red.shade600,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTab(String title, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        boxShadow:
            isActive
                ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.red.shade700 : Colors.red.shade400,
        ),
      ),
    );
  }

  Widget _buildWellnessCheckIn() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade50, Colors.purple.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.self_improvement,
                    color: Colors.blue.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedCategory == 'harassment'
                            ? 'Quick Wellness'
                            : 'Quick Safety',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      Text(
                        selectedCategory == 'harassment'
                            ? 'Take a moment for yourself'
                            : 'Emergency preparedness tools',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Text(
              selectedCategory == 'harassment'
                  ? 'Choose an activity:'
                  : 'Quick access:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons - Different for each category
            Row(
              children: [
                Expanded(
                  child:
                      selectedCategory == 'harassment'
                          ? _buildQuickAction(
                            '🧘‍♀️', // icons from system tools
                            'Breathe',
                            Colors.blue,
                            () => _handleQuickAction('breathe'),
                          )
                          : _buildQuickAction(
                            '🏠',
                            'Safe Zone',
                            Colors.green,
                            () => _handleQuickAction('safezone'),
                          ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child:
                      selectedCategory == 'harassment'
                          ? _buildQuickAction(
                            '🎵',
                            'Music',
                            Colors.purple,
                            () => _handleQuickAction('music'),
                          )
                          : _buildQuickAction(
                            '🎒',
                            'Prep Kit',
                            Colors.orange,
                            () => _handleQuickAction('prepkit'),
                          ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    String emoji,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleQuickAction(String action) {
    switch (action) {
      case 'breathe':
        _showBreathingExercise();
        break;
      case 'talk':
        _showSupportContacts();
        break;
      case 'journal':
        _showJournalPrompt();
        break;
      case 'music':
        _showMusicSuggestions();
        break;
      case 'safezone':
        _showSafeZoneInfo();
        break;
      case 'prepkit':
        _showPrepKit();
        break;
    }
  }

  void _showBreathingExercise() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.air, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                const Text('Breathing Exercise'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '4-7-8 Breathing Technique',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '1. Inhale through nose for 4 counts\n'
                  '2. Hold breath for 7 counts\n'
                  '3. Exhale through mouth for 8 counts\n'
                  '4. Repeat 3-4 times',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ],
          ),
    );
  }

  void _showSupportContacts() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.phone, color: Colors.green.shade600),
                const SizedBox(width: 8),
                const Text('Support Contacts'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContactItem('Crisis Helpline', '988', Icons.phone),
                const SizedBox(height: 12),
                _buildContactItem(
                  'Emergency Services',
                  '911',
                  Icons.local_hospital,
                ),
                const SizedBox(height: 12),
                _buildContactItem(
                  'Mental Health Support',
                  '1-800-662-4357',
                  Icons.psychology,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildContactItem(String title, String number, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(number, style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
      ],
    );
  }

  void _showJournalPrompt() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.edit, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                const Text('Journal Prompt'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Reflection Questions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '• What am I grateful for today?\n'
                  '• What challenged me today?\n'
                  '• How did I take care of myself?\n'
                  '• What do I want to improve tomorrow?',
                  style: TextStyle(fontSize: 14, height: 1.6),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Start Journaling'),
              ),
            ],
          ),
    );
  }

  void _showMusicSuggestions() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.music_note, color: Colors.purple.shade600),
                const SizedBox(width: 8),
                const Text('Music for Wellness'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Recommended Playlists',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '🎵 Calm & Relaxing\n'
                  '🎵 Nature Sounds\n'
                  '🎵 Meditation Music\n'
                  '🎵 Uplifting Beats\n'
                  '🎵 Focus & Concentration',
                  style: TextStyle(fontSize: 14, height: 1.6),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Listen Now'),
              ),
            ],
          ),
    );
  }

  void _showSafeZoneInfo() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.shield, color: Colors.green.shade600),
                const SizedBox(width: 8),
                const Text('Safe Zone Guide'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Finding Safe Shelter',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '🏢 Sturdy buildings (avoid glass)\n'
                  '🚇 Underground areas or basements\n'
                  '🏫 Schools, hospitals, community centers\n'
                  '🚗 Stay in vehicle if caught outside\n'
                  '📻 Listen for official evacuation orders\n'
                  '🎒 Keep emergency kit accessible',
                  style: TextStyle(fontSize: 14, height: 1.6),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ],
          ),
    );
  }

  void _showPrepKit() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.inventory, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                const Text('Emergency Prep Kit'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Essential Items Checklist',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '✓ Water (1 gallon per person per day)\n'
                  '✓ Non-perishable food (3-day supply)\n'
                  '✓ Flashlight and extra batteries\n'
                  '✓ First aid kit\n'
                  '✓ Radio (battery or hand crank)\n'
                  '✓ Important documents (copies)\n'
                  '✓ Cash and credit cards\n'
                  '✓ Medications (7-day supply)',
                  style: TextStyle(fontSize: 14, height: 1.6),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ],
          ),
    );
  }

  void _showCounsellingOptions() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.psychology, color: Colors.green.shade600),
                const SizedBox(width: 8),
                Text(
                  selectedCategory == 'harassment'
                      ? 'Counselling Support'
                      : 'Disaster Counselling',
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedCategory == 'harassment'
                      ? 'Professional Support Available:'
                      : 'Disaster Recovery Support:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (selectedCategory == 'harassment') ...[
                  const Text('• Crisis Text Line: Text HOME to 741741'),
                  const SizedBox(height: 8),
                  const Text('• National Suicide Prevention: Call 988'),
                  const SizedBox(height: 8),
                  const Text('• Mental Health America: mhanational.org'),
                  const SizedBox(height: 8),
                  const Text('• Local support groups available'),
                ] else ...[
                  const Text('• FEMA Crisis Counseling: 1-800-621-3362'),
                  const SizedBox(height: 8),
                  const Text('• Disaster Distress Helpline: 1-800-985-5990'),
                  const SizedBox(height: 8),
                  const Text('• Red Cross Mental Health: 1-800-RED-CROSS'),
                  const SizedBox(height: 8),
                  const Text('• PTSD Support for survivors'),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showEmergencyContacts() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.emergency, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                Text(
                  selectedCategory == 'harassment'
                      ? 'Emergency Contacts'
                      : 'Disaster Emergency',
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedCategory == 'harassment'
                      ? 'Important Emergency Numbers:'
                      : 'Disaster Response Numbers:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (selectedCategory == 'harassment') ...[
                  const Text('🚨 Emergency Services: 911'),
                  const SizedBox(height: 8),
                  const Text('☎️ Crisis Hotline: 988'),
                  const SizedBox(height: 8),
                  const Text('👮 Domestic Violence: 1-800-799-7233'),
                  const SizedBox(height: 8),
                  const Text('🏥 Poison Control: 1-800-222-1222'),
                ] else ...[
                  const Text('🚨 Emergency Services: 911'),
                  const SizedBox(height: 8),
                  const Text('🏛️ FEMA Assistance: 1-800-621-3362'),
                  const SizedBox(height: 8),
                  const Text('🔴 Red Cross: 1-800-RED-CROSS'),
                  const SizedBox(height: 8),
                  const Text('⛑️ Salvation Army: 1-800-SAL-ARMY'),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildModernMenuOption(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
