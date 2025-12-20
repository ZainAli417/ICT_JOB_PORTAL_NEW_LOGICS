// admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:job_portal/Screens/Admin/sidebar.dart';
import 'user_management_section.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _selectedMenu = 'User Management'; // Default selected menu

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AdminSidebar(
            onMenuSelected: (menu) {
              setState(() {
                _selectedMenu = menu;
              });
            },
            selectedMenu: _selectedMenu,
          ),
          // Main Content Area
          Expanded(
            child: Container(
              color: Colors.white,
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedMenu) {
      case 'User Management':
        return const UserManagementSection();
      default:
        return const Center(child: Text('Select a menu item'));
    }
  }
}