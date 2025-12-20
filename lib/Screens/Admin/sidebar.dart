// admin_sidebar.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminSidebar extends StatelessWidget {
  final Function(String) onMenuSelected;
  final String selectedMenu;

  const AdminSidebar({
    Key? key,
    required this.onMenuSelected,
    required this.selectedMenu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250, // Fixed width for sidebar, optimized for web
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Admin Dashboard',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
          ),
          // Admin Profile Card
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: AdminProfile(),
          ),
          // Menu Items
          Expanded(
            child: ListView(
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.people,
                  label: 'User Management',
                  isSelected: selectedMenu == 'User Management',
                  onTap: () => onMenuSelected('User Management'),
                ),
                // Add more menu items here if needed in the future
              ],
            ),
          ),
          // Copyrights Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '© 2025 Your Company. All rights reserved.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required bool isSelected,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : Colors.grey[800]),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.grey[800],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: onTap,
    );
  }
}
// admin_profile.dart

class AdminProfile extends StatelessWidget {
  const AdminProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Profile',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Email: ${user?.email ?? 'N/A'}'),
            Text('UID: ${user?.uid ?? 'N/A'}'),
            // Add more admin-specific info if needed
          ],
        ),
      ),
    );
  }
}