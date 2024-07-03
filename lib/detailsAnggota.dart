import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class detailsMember extends StatefulWidget {
  const detailsMember({super.key});

  @override
  State<detailsMember> createState() => _UserDetailState();
}

class _UserDetailState extends State<detailsMember> {
  Anggota? anggota;
  double? totalSaldo;
  int id = 0;
  final _dio = Dio();
  final _storage = GetStorage();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)?.settings.arguments != null) {
      id = ModalRoute.of(context)?.settings.arguments as int;
      getDetail();
      getSaldo();
    }
  }

  Future<void> getDetail() async {
    try {
      final _response = await _dio.get(
        '$_apiUrl/anggota/$id',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      Map<String, dynamic> responseData = _response.data;
      print(responseData);
      print(id);
      setState(() {
        anggota = Anggota.fromJson(responseData);
      });
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
    }
  }

  Future<void> getSaldo() async {
    try {
      final _response = await _dio.get(
        '$_apiUrl/saldo/$id',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      Map<String, dynamic> responseData = _response.data;
      if (responseData['success']) {
        setState(() {
          totalSaldo = responseData['data']['saldo'].toDouble();
        });
      }
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Oops!"),
              content: Text(e.response?.data['message'] ?? 'An error occurred'),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Row(
          children: [
            SizedBox(width: 8),
            Text(
              'Detail Anggota',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/listMember');
          },
          icon: const Icon(
            Icons.arrow_back,
            size: 32,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: anggota == null
              ? const Text("Belum ada anggota")
              : Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildBorderedText(
                            "Nomor Induk", "${anggota?.nomor_induk}"),
                        _buildBorderedText("Nama", "${anggota?.nama}"),
                        _buildBorderedText("Alamat", "${anggota?.alamat}"),
                        _buildBorderedText(
                            "Tanggal Lahir", "${anggota?.tgl_lahir}"),
                        _buildBorderedText("Telepon", "${anggota?.telepon}"),
                        _buildBorderedText(
                            "Status", "${anggota?.statusAktifText}"),
                        totalSaldo != null
                            ? _buildBorderedText("Total Saldo",
                                "Rp. ${NumberFormat.currency(locale: 'id_ID', symbol: '').format(totalSaldo)}")
                            : const CircularProgressIndicator(),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildBorderedText(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(subtitle),
        ],
      ),
    );
  }
}

class Anggota {
  final int id;
  final int nomor_induk;
  final String nama;
  final String alamat;
  final String tgl_lahir;
  final String telepon;
  final String? image_url;
  final int? status_aktif;

  Anggota({
    required this.id,
    required this.nomor_induk,
    required this.nama,
    required this.alamat,
    required this.tgl_lahir,
    required this.telepon,
    this.image_url,
    this.status_aktif,
  });

  factory Anggota.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;

    if (data != null) {
      final anggotaData = data['anggota'] as Map<String, dynamic>?;

      if (anggotaData != null) {
        return Anggota(
          id: anggotaData['id'],
          nomor_induk: anggotaData['nomor_induk'],
          nama: anggotaData['nama'],
          alamat: anggotaData['alamat'],
          tgl_lahir: anggotaData['tgl_lahir'],
          telepon: anggotaData['telepon'],
          image_url: anggotaData['image_url'],
          status_aktif: anggotaData['status_aktif'],
        );
      }
    }

    throw Exception('Failed to parse Anggota from JSON');
  }

  String get statusAktifText {
    if (status_aktif == 1) {
      return "Aktif";
    } else {
      return "Tidak Aktif";
    }
  }
}








// // KODE UDAH JALAN, KURANG MENAMPILKAN TOTAL TABUNGANNYA
// import 'package:flutter/material.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:dio/dio.dart';

// class detailsMember extends StatefulWidget {
//   const detailsMember({super.key});

//   @override
//   State<detailsMember> createState() => _UserDetailState();
// }

// class _UserDetailState extends State<detailsMember> {
//   Anggota? anggota;
//   int id = 0;
//   final _dio = Dio();
//   final _storage = GetStorage();
//   final _apiUrl = 'https://mobileapis.manpits.xyz/api';

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (ModalRoute.of(context)?.settings.arguments != null) {
//       id = ModalRoute.of(context)?.settings.arguments as int;
//       getDetail();
//     }
//   }

//   Future<void> getDetail() async {
//     try {
//       final _response = await _dio.get(
//         '$_apiUrl/anggota/$id',
//         options: Options(
//           headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
//         ),
//       );
//       Map<String, dynamic> responseData = _response.data;
//       print(responseData);
//       print(id);
//       setState(() {
//         anggota = Anggota.fromJson(responseData);
//       });
//     } on DioException catch (e) {
//       print('${e.response} - ${e.response?.statusCode}');
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFFAFAFA),
//       appBar: AppBar(
//         backgroundColor: Colors.green,
//         title: const Row(
//           children: [
//             SizedBox(width: 8),
//             Text(
//               'Detail Anggota',
//               style: TextStyle(color: Colors.white),
//             ),
//           ],
//         ),
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pushNamed(context, '/listMember');
//           },
//           icon: const Icon(
//             Icons.arrow_back,
//             size: 32,
//           ),
//         ),
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//           child: anggota == null
//               ? const Text("Belum ada anggota")
//               : Card(
//                   elevation: 4,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         _buildBorderedText(
//                             "Nomor Induk", "${anggota?.nomor_induk}"),
//                         _buildBorderedText("Nama", "${anggota?.nama}"),
//                         _buildBorderedText("Alamat", "${anggota?.alamat}"),
//                         _buildBorderedText(
//                             "Tanggal Lahir", "${anggota?.tgl_lahir}"),
//                         _buildBorderedText("Telepon", "${anggota?.telepon}"),
//                         _buildBorderedText(
//                             "Status", "${anggota?.statusAktifText}"),
//                         const SizedBox(height: 16),
//                       ],
//                     ),
//                   ),
//                 ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBorderedText(String title, String subtitle) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         border: Border(
//           bottom: BorderSide(
//             color: Colors.grey.shade300,
//             width: 1,
//           ),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Text(subtitle),
//         ],
//       ),
//     );
//   }
// }

// class Anggota {
//   final int id;
//   final int nomor_induk;
//   final String nama;
//   final String alamat;
//   final String tgl_lahir;
//   final String telepon;
//   final String? image_url;
//   final int? status_aktif;

//   Anggota({
//     required this.id,
//     required this.nomor_induk,
//     required this.nama,
//     required this.alamat,
//     required this.tgl_lahir,
//     required this.telepon,
//     this.image_url,
//     this.status_aktif,
//   });

//   factory Anggota.fromJson(Map<String, dynamic> json) {
//     final data = json['data'] as Map<String, dynamic>?;

//     if (data != null) {
//       final anggotaData = data['anggota'] as Map<String, dynamic>?;

//       if (anggotaData != null) {
//         return Anggota(
//           id: anggotaData['id'],
//           nomor_induk: anggotaData['nomor_induk'],
//           nama: anggotaData['nama'],
//           alamat: anggotaData['alamat'],
//           tgl_lahir: anggotaData['tgl_lahir'],
//           telepon: anggotaData['telepon'],
//           image_url: anggotaData['image_url'],
//           status_aktif: anggotaData['status_aktif'],
//         );
//       }
//     }

//     throw Exception('Failed to parse Anggota from JSON');
//   }

//   String get statusAktifText {
//     if (status_aktif == 1) {
//       return "Aktif";
//     } else {
//       return "Tidak Aktif";
//     }
//   }
// }
