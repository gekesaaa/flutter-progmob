// import 'package:coba_login/login_page.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[600],
      ),
      body: const Center(
        child: Text('Welcome to Harvesthub!'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          // ignore: avoid_print
          print(value);
        },
        items: const [
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(Icons.home_outlined),
          ),
          BottomNavigationBarItem(
            label: 'Profile',
            icon: Icon(Icons.person_2_outlined),
          ),
          BottomNavigationBarItem(
            label: 'Logout',
            icon: Icon(Icons.logout_outlined),
          )
        ],
      ),
    );
  }
}
