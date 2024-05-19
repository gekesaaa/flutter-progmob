import 'package:coba_login/dashboard_page.dart';
import 'package:coba_login/tambahAnggota.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:coba_login/login_page.dart';
import 'profil_page.dart'; // Import ProfilPage.dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => const DashboardPage(),
        '/profil': (context) => const ProfilPage(),
        '/addMember': (context) => const AddMemberPage(),
      },
      initialRoute: '/',
    );
  }
}

class MainApp {
  static void goUser(BuildContext context, String nama, String email) {
    Navigator.pushNamed(
      context,
      '/profil',
      arguments: {'nama': nama, 'email': email},
    );
  }

  void goLogout(BuildContext context) {}
}
