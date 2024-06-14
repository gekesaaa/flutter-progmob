import 'package:coba_login/Transaksi/Tabungan.dart';
import 'package:coba_login/Transaksi/add_Transaksi.dart';
import 'package:coba_login/Transaksi/tabunganDetail.dart';
import 'package:coba_login/editMember.dart';
import 'package:coba_login/dashboard_page.dart';
import 'package:coba_login/detailsAnggota.dart';
import 'package:coba_login/profil_page.dart';
import 'package:coba_login/register_page.dart';
import 'package:coba_login/tambahAnggota.dart';
import 'package:coba_login/viewAnggota.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:coba_login/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => const DashboardPage(),
        '/profil': (context) => const ProfilePage(),
        '/addMember': (context) => const AddMemberPage(),
        '/listMember': (context) => const ViewMembersPage(),
        '/detailMember': (context) => const detailsMember(),
        '/editMember': (context) => const EditMember(),
        '/tabungan': (context) => const TabunganPage(),
        '/tabunganDetail': (context) => const TabunganDetail(),
        '/addTabungan': (context) => const AddTabungan(),
      },
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainApp {
  final _dio = Dio();
  final _storage = GetStorage();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api';

  void goLogout(BuildContext context) async {
    try {
      final _response = await _dio.get(
        '$_apiUrl/logout',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      print(_response.data);
      Navigator.pushReplacementNamed(context, '/');
    } on DioError catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
    }
  }
}
