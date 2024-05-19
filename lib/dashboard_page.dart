import 'package:coba_login/login_page.dart';
import 'package:coba_login/tambahAnggota.dart';
import 'package:coba_login/viewAnggota.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
// import 'profil_page.dart'; // Import ProfilPage.dart

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final _dio = Dio();
  final _storage = GetStorage();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Navigator(
          onGenerateRoute: (settings) {
            if (settings.name == '/') {
              return MaterialPageRoute(
                builder: (context) => const DashboardPage(),
              );
            }
            return MaterialPageRoute(
              builder: (context) => LoginPage(),
            );
          },
        ),
      ),
    );
  }

  void goUser(BuildContext context) async {
    // Mengubah goUser agar menerima context
    try {
      final _response = await _dio.get(
        '$_apiUrl/user',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      print(_response.data);
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
    }
  }

  void goLogout(BuildContext context) async {
    // Mengubah goLogout agar menerima context
    try {
      final _response = await _dio.get(
        '$_apiUrl/logout',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      print(_response.data);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } on DioError catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
    }
  }
}

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
      body: Stack(
        children: [
          // Your main content goes here
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AddMemberPage()));
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          height: 60.0, // Adjust the height as needed
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            unselectedItemColor: Colors.green,
            selectedItemColor: Colors.green,
            selectedLabelStyle: const TextStyle(color: Colors.green),
            unselectedLabelStyle: const TextStyle(color: Colors.green),
            onTap: (value) {
              if (value == 0) {
                // Home
                print('Home');
              } else if (value == 1) {
                // Profile
                MainApp().goUser(context); // Menggunakan instance yang sama
              } else if (value == 2) {
                // List Anggota
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ViewMembersPage()));
              } else if (value == 3) {
                // Logout
                MainApp().goLogout(context); // Menggunakan instance yang sama
              }
            },
            items: const [
              BottomNavigationBarItem(
                label: 'Home',
                icon: Icon(Icons.home_outlined),
              ),
              BottomNavigationBarItem(
                label: 'Profile',
                icon: Icon(Icons.person_outline),
              ),
              BottomNavigationBarItem(
                label: 'List Anggota',
                icon: Icon(Icons.list_outlined),
              ),
              BottomNavigationBarItem(
                label: 'Logout',
                icon: Icon(Icons.logout_outlined),
              )
            ],
          ),
        ),
      ),
    );
  }
}
