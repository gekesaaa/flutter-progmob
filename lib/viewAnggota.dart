// isi searching dan filter anggota
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';

class ViewMembersPage extends StatefulWidget {
  const ViewMembersPage();

  @override
  State<ViewMembersPage> createState() => _ViewAnggotaState();
}

class _ViewAnggotaState extends State<ViewMembersPage> {
  AnggotaDatas? anggotaDatas;
  List<Anggota> filteredAnggotaDatas = [];
  final _dio = Dio();
  final _storage = GetStorage();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    getAnggota();
    _searchController.addListener(_filterAnggota);
  }

  Future<void> getAnggota() async {
    try {
      final _response = await _dio.get(
        '$_apiUrl/anggota',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      final responseData = _response.data;
      setState(() {
        anggotaDatas = AnggotaDatas.fromJson(responseData);
        filteredAnggotaDatas = anggotaDatas?.anggotaDatas ?? [];
      });
    } on DioError catch (e) {
      print('Error: ${e.response?.statusCode} - ${e.message}');
    }
  }

  void _filterAnggota() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredAnggotaDatas = anggotaDatas?.anggotaDatas
              .where((anggota) =>
                  anggota.nama.toLowerCase().contains(query) ||
                  anggota.nomorInduk.toString().contains(query))
              .toList() ??
          [];
    });
  }

  Future<void> hapusMember(int id) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Yakin Menghapus Anggota?'),
          actions: <Widget>[
            TextButton(
              child: Text("Batal"),
              onPressed: () {
                Navigator.of(context).pop(false);
                getAnggota();
              },
            ),
            TextButton(
              child: Text("Hapus"),
              onPressed: () {
                Navigator.of(context).pop(true);
                getAnggota();
              },
            ),
          ],
        );
      },
    );

    if (confirmed) {
      try {
        await _dio.delete(
          '$_apiUrl/anggota/$id',
          options: Options(
            headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
          ),
        );

        // Hapus anggota dari daftar lokal
        setState(() {
          anggotaDatas?.anggotaDatas.removeWhere((anggota) => anggota.id == id);
          _filterAnggota();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Anggota berhasil dihapus')),
        );
      } on DioError catch (e) {
        print('${e.response} - ${e.response?.statusCode}');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(
                  'Gagal menghapus anggota: ${e.response?.data['message'] ?? 'Terjadi kesalahan'}'),
              actions: <Widget>[
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    getAnggota();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anggota'),
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, '/home', (route) => false);
          },
          icon: const Icon(
            Icons.arrow_back,
            size: 32,
          ),
        ),
        actions: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: _isSearching ? 250.0 : 48.0,
            child: Row(
              children: [
                _isSearching
                    ? Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Cari anggota...',
                            border: InputBorder.none,
                          ),
                        ),
                      )
                    : Container(),
                IconButton(
                  icon: Icon(_isSearching ? Icons.close : Icons.search),
                  onPressed: () {
                    setState(() {
                      if (_isSearching) {
                        _searchController.clear();
                      }
                      _isSearching = !_isSearching;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: anggotaDatas == null || filteredAnggotaDatas.isEmpty
            ? const Text("Belum Ada Anggota yang Terdaftar")
            : ListView.builder(
                itemCount: filteredAnggotaDatas.length,
                itemBuilder: (context, index) {
                  final anggota = filteredAnggotaDatas[index];
                  return ListTile(
                    title: Text(anggota.nama),
                    subtitle: Row(
                      children: [
                        Icon(Icons.phone, size: 14),
                        SizedBox(width: 6),
                        Text(anggota.telepon),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (String result) {
                        if (result == 'Detail') {
                          Navigator.pushNamed(
                            context,
                            '/detailMember',
                            arguments: anggota.id,
                          );
                        } else if (result == 'Edit') {
                          Navigator.pushNamed(
                            context,
                            '/editMember',
                            arguments: anggota.id,
                          );
                        } else if (result == 'Hapus') {
                          hapusMember(anggota.id);
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'Detail',
                          child: Text('Detail'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Hapus',
                          child: Text('Hapus'),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class AnggotaDatas {
  final List<Anggota> anggotaDatas;

  AnggotaDatas({required this.anggotaDatas});

  factory AnggotaDatas.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final anggota = data?['anggotas'] as List<dynamic>?;

    return AnggotaDatas(
      anggotaDatas: anggota
              ?.map((anggotaData) =>
                  Anggota.fromJson(anggotaData as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Anggota {
  final int id;
  final int nomorInduk;
  final String nama;
  final String alamat;
  final String tglLahir;
  final String telepon;
  final String? imageUrl;
  final int? statusAktif;

  Anggota({
    required this.id,
    required this.nomorInduk,
    required this.nama,
    required this.alamat,
    required this.tglLahir,
    required this.telepon,
    this.imageUrl,
    this.statusAktif,
  });

  factory Anggota.fromJson(Map<String, dynamic> json) {
    return Anggota(
      id: json['id'],
      nomorInduk: json['nomor_induk'],
      nama: json['nama'],
      alamat: json['alamat'],
      tglLahir: json['tgl_lahir'],
      telepon: json['telepon'],
      imageUrl: json['image_url'],
      statusAktif: json['status_aktif'],
    );
  }
}


// belum isi searching dan filter anggota
// import 'package:flutter/material.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:dio/dio.dart';

// class ViewMembersPage extends StatefulWidget {
//   const ViewMembersPage();

//   @override
//   State<ViewMembersPage> createState() => _ViewAnggotaState();
// }

// class _ViewAnggotaState extends State<ViewMembersPage> {
//   AnggotaDatas? anggotaDatas;
//   final _dio = Dio();
//   final _storage = GetStorage();
//   final _apiUrl = 'https://mobileapis.manpits.xyz/api';

//   @override
//   void initState() {
//     super.initState();
//     getAnggota();
//   }

//   Future<void> getAnggota() async {
//     try {
//       final _response = await _dio.get(
//         '$_apiUrl/anggota',
//         options: Options(
//           headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
//         ),
//       );
//       final responseData = _response.data;
//       setState(() {
//         anggotaDatas = AnggotaDatas.fromJson(responseData);
//       });
//     } on DioError catch (e) {
//       print('Error: ${e.response?.statusCode} - ${e.message}');
//     }
//   }

//   Future<void> hapusMember(int id) async {
//     bool confirmed = await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Konfirmasi Hapus'),
//           content: Text('Yakin Menghapus Anggota?'),
//           actions: <Widget>[
//             TextButton(
//               child: Text("Batal"),
//               onPressed: () {
//                 Navigator.of(context).pop(false);
//                 getAnggota();
//               },
//             ),
//             TextButton(
//               child: Text("Hapus"),
//               onPressed: () {
//                 Navigator.of(context).pop(true);
//                 getAnggota();
//               },
//             ),
//           ],
//         );
//       },
//     );

//     if (confirmed) {
//       try {
//         await _dio.delete(
//           '$_apiUrl/anggota/$id',
//           options: Options(
//             headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
//           ),
//         );

//         // Hapus anggota dari daftar lokal
//         setState(() {
//           anggotaDatas?.anggotaDatas.removeWhere((anggota) => anggota.id == id);
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Anggota berhasil dihapus')),
//         );
//       } on DioError catch (e) {
//         print('${e.response} - ${e.response?.statusCode}');
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               content: Text(
//                   'Gagal menghapus anggota: ${e.response?.data['message'] ?? 'Terjadi kesalahan'}'),
//               actions: <Widget>[
//                 TextButton(
//                   child: Text("OK"),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                     getAnggota();
//                   },
//                 ),
//               ],
//             );
//           },
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Anggota'),
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pushNamedAndRemoveUntil(
//                 context, '/home', (route) => false);
//           },
//           icon: const Icon(
//             Icons.arrow_back,
//             size: 32,
//           ),
//         ),
//       ),
//       body: Center(
//         child: anggotaDatas == null || anggotaDatas!.anggotaDatas.isEmpty
//             ? const Text("Belum Ada Anggota yang Terdaftar")
//             : ListView.builder(
//                 itemCount: anggotaDatas!.anggotaDatas.length,
//                 itemBuilder: (context, index) {
//                   final anggota = anggotaDatas!.anggotaDatas[index];
//                   return ListTile(
//                     title: Text(anggota.nama),
//                     subtitle: Row(
//                       children: [
//                         Icon(Icons.phone, size: 14),
//                         SizedBox(width: 6),
//                         Text(anggota.telepon),
//                       ],
//                     ),
//                     trailing: PopupMenuButton<String>(
//                       onSelected: (String result) {
//                         if (result == 'Detail') {
//                           Navigator.pushNamed(
//                             context,
//                             '/detailMember',
//                             arguments: anggota.id,
//                           );
//                         } else if (result == 'Edit') {
//                           Navigator.pushNamed(
//                             context,
//                             '/editMember',
//                             arguments: anggota.id,
//                           );
//                         } else if (result == 'Hapus') {
//                           hapusMember(anggota.id);
//                         }
//                       },
//                       itemBuilder: (BuildContext context) =>
//                           <PopupMenuEntry<String>>[
//                         const PopupMenuItem<String>(
//                           value: 'Detail',
//                           child: Text('Detail'),
//                         ),
//                         const PopupMenuItem<String>(
//                           value: 'Edit',
//                           child: Text('Edit'),
//                         ),
//                         const PopupMenuItem<String>(
//                           value: 'Hapus',
//                           child: Text('Hapus'),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//       ),
//     );
//   }
// }

// class AnggotaDatas {
//   final List<Anggota> anggotaDatas;

//   AnggotaDatas({required this.anggotaDatas});

//   factory AnggotaDatas.fromJson(Map<String, dynamic> json) {
//     final data = json['data'] as Map<String, dynamic>?;
//     final anggota = data?['anggotas'] as List<dynamic>?;

//     return AnggotaDatas(
//       anggotaDatas: anggota
//               ?.map((anggotaData) =>
//                   Anggota.fromJson(anggotaData as Map<String, dynamic>))
//               .toList() ??
//           [],
//     );
//   }
// }

// class Anggota {
//   final int id;
//   final int nomorInduk;
//   final String nama;
//   final String alamat;
//   final String tglLahir;
//   final String telepon;
//   final String? imageUrl;
//   final int? statusAktif;

//   Anggota({
//     required this.id,
//     required this.nomorInduk,
//     required this.nama,
//     required this.alamat,
//     required this.tglLahir,
//     required this.telepon,
//     this.imageUrl,
//     this.statusAktif,
//   });

//   factory Anggota.fromJson(Map<String, dynamic> json) {
//     return Anggota(
//       id: json['id'],
//       nomorInduk: json['nomor_induk'],
//       nama: json['nama'],
//       alamat: json['alamat'],
//       tglLahir: json['tgl_lahir'],
//       telepon: json['telepon'],
//       imageUrl: json['image_url'],
//       statusAktif: json['status_aktif'],
//     );
//   }
// }
