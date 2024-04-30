import 'package:coba_login/login_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class MainApp extends StatelessWidget {
  MainApp({Key? key}) : super(key: key);

  final myStorage = GetStorage();
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
                builder: (context) => DashboardPage(),
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

  void goUser() async {
    try {
      final _response = await _dio.get(
        '$_apiUrl/user',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      print(_response.data);
      // ignore: deprecated_member_use
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
    }
  }

  void goLogout(BuildContext context) async {
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
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          if (value == 0) {
            // Home
            print('Home');
          } else if (value == 1) {
            // Profile
            MainApp().goUser();
          } else if (value == 2) {
            // Logout
            MainApp().goLogout(context);
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
            label: 'Logout',
            icon: Icon(Icons.logout_outlined),
          )
        ],
      ),
    );
  }
}
