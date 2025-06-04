import 'package:flutter/material.dart';

class EditProfileContent extends StatelessWidget {
  const EditProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Profile selected
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.woman),
            label: 'Harassment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.house),
            label: 'Disaster',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            label: 'Tips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Profile Picture with Edit Icon
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.edit, color: Colors.white, size: 16),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 16),
              const Text(
                'Name',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Location',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 40),

              // Menu Items
              _buildMenuItem(
                label: 'Personal information',
                icon: Icons.arrow_forward_ios,
                onTap: () {
                  print("Personal information tapped");
                },
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                label: 'Privacy policy',
                icon: Icons.arrow_forward_ios,
                onTap: () {
                  print("Privacy policy tapped");
                },
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                label: 'Logout',
                icon: Icons.logout,
                iconColor: Colors.red,
                onTap: () {
                  print("Logout tapped");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.red,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(20, 0, 0, 0),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500)),
            Icon(icon, color: iconColor, size: 20),
          ],
        ),
      ),
    );
  }
}
