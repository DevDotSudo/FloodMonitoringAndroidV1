import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key}); // Added const constructor

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 0, top: 0, bottom: 4.0), // Smaller bottom padding
            child: Text(
              'Welcome back,',
              style: TextStyle(
                fontSize: 16, // Smaller font size
                color: Colors.grey[600],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 0, bottom: 16.0), // Smaller bottom padding
            child: Text(
              'Eric Dave Cala-or',
              style: TextStyle(
                fontSize: 22, // Smaller font size
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Divider( // Add a divider like in the picture
            color: Colors.grey[300],
            thickness: 1,
            indent: 0,
            endIndent: 0,
          ),
          SizedBox(height: 16), // Spacing after the welcome section

          // Changed from Column to Row to place the cards side-by-side
          Row(
            children: [
              Expanded(
                // River Status card
                child: _buildDashboardCard(
                  context,
                  icon: Icons.warning, // Icon for River Status
                  iconColor: Colors.orange.shade600,
                  title: 'River Status', // Changed title
                  value: 'Warning', // Value for River Status
                  valueColor: Colors.orange.shade800,
                  backgroundColor: Colors.white, // White background for cards
                  isFullWidth: false, // Not full width when in a row
                ),
              ),
              SizedBox(width: 16), // Spacing between the two cards
              Expanded(
                // Current Water Level card
                child: _buildDashboardCard(
                  context,
                  icon: Icons.water_drop,
                  iconColor: Colors.teal.shade600,
                  title: 'Current Water Level',
                  value: '4.5m',
                  valueColor: Colors.teal.shade800,
                  backgroundColor: Colors.white, // White background for cards
                  isFullWidth: false, // Not full width when in a row
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Bridge is passable card remains as a full-width card below
          _buildDashboardCard(
            context,
            icon: Icons.check_circle_outline,
            iconColor: Colors.green.shade600,
            title: 'Bridge is passable',
            value: '', // No value for this status
            valueColor: Colors.green.shade800,
            backgroundColor: Colors.white, // White background for cards
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  // Helper function to build dashboard cards, now a method of HomePage
  Widget _buildDashboardCard(
    BuildContext context,
    {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required Color valueColor,
    required Color backgroundColor,
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12.0), // Slightly smaller padding
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [ // Added box shadow to match the picture
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      // If isFullWidth is true, use a SizedBox to ensure it spans the width
      // This is particularly useful when the card is not in an Expanded widget
      child: SizedBox(
        width: isFullWidth ? double.infinity : null, // Take full width if specified
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6), // Smaller padding for icon container
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1), // Subtle background for icon
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 20), // Smaller icon size
                ),
                SizedBox(width: 10), // Smaller spacing
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14, // Smaller font size for title
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8), // Smaller spacing
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 20, // Smaller font size for value
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
