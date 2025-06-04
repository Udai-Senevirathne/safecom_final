import 'package:flutter/material.dart';

class DisasterHome extends StatelessWidget {
  const DisasterHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // ✅ Set "Disaster" as selected
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
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // Weather Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Colombo",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text("05:30 - 03/08",
                            style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.wb_sunny, color: Colors.white),
                        SizedBox(width: 8),
                        Text("24°", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Report your Disaster',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text('instantly',
                  style: TextStyle(fontSize: 16, color: Colors.black87)),

              const SizedBox(height: 30),

              // SOS Buttons Grid
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            print("SOS tapped");
                          },
                          child: _buildCircleButton(
                            color: Colors.red,
                            icon: Icons.warning,
                            label: 'SOS',
                            large: true,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            print("Call tapped");
                          },
                          child: _buildCircleButton(
                            color: Colors.green,
                            icon: Icons.call,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            print("Shield tapped");
                          },
                          child: _buildCircleButton(
                            color: Colors.blue,
                            icon: Icons.shield,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            print("Notifications tapped");
                          },
                          child: _buildCircleButton(
                            color: Colors.black,
                            icon: Icons.notifications,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // "Have to report something?" Button
              GestureDetector(
                onTap: () {
                  print("Report something tapped");
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade100,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Have to report something.?",
                        style: TextStyle(color: Colors.red),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_right_alt, color: Colors.red),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required Color color,
    required IconData icon,
    String label = '',
    bool large = false,
    Color textColor = Colors.white,
  }) {
    return Column(
      children: [
        Container(
          height: large ? 120 : 150,
          width: large ? 100 : 60,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(icon, color: textColor, size: large ? 36 : 28),
        ),
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: textColor)),
          ),
      ],
    );
  }
}
