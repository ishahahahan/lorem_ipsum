import 'package:flutter/material.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  static const String id = '/activity';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/activity.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Container(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, false, context),
                _buildNavItem(Icons.fitness_center, false, context),
                _buildCircularNavItem(),
                _buildNavItem(Icons.bar_chart, true, context),
                _buildNavItem(Icons.person_outline, false, context),
              ],
            ),
          )
        ]),
      ),
    );
  }
}

Widget _buildCircularNavItem() {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.yellow,
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Icon(
      Icons.add,
      color: Colors.black,
      size: 28,
    ),
  );
}

Widget _buildNavItem(IconData icon, bool isSelected, BuildContext context) {
  return Icon(
    icon,
    size: 28,
    color: isSelected ? const Color(0xFF4CAF50) : Colors.grey,
  );
}
