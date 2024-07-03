// SUDAH BISA TAMBAH DAN MENAMPILKAN DATA BUNGA, SUDAH BISA DI CLEAR JUGA KETIKA BUNGA BERHASIL DI SIMPAN DAN DATA LIST BUNGA SUDAH RAPI
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';

class AddBunga extends StatefulWidget {
  const AddBunga({super.key});

  @override
  State<AddBunga> createState() => _AddBungaState();
}

class _AddBungaState extends State<AddBunga> {
  BungaDatas? bungaDatas;
  List<Bunga> activeBunga = [];
  List<Bunga> inactiveBunga = [];
  final _dio = Dio();
  final _storage = GetStorage();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _bungaPersenController = TextEditingController();
  int? _bungaStatus;

  @override
  void initState() {
    super.initState();
    getBunga();
  }

  Future<void> getBunga() async {
    try {
      final _response = await _dio.get(
        '$_apiUrl/settingbunga',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      final responseData = _response.data;
      setState(() {
        bungaDatas = BungaDatas.fromJson(responseData);
        activeBunga = bungaDatas?.bungas
                .where((bunga) => bunga.status == 'Aktif')
                .toList() ??
            [];
        inactiveBunga = bungaDatas?.bungas
                .where((bunga) => bunga.status == 'Tidak Aktif')
                .toList() ??
            [];
      });
    } on DioError catch (e) {
      print('Error: ${e.response?.statusCode} - ${e.message}');
    }
  }

  Future<void> addBunga() async {
    try {
      final _response = await _dio.post(
        '$_apiUrl/addsettingbunga',
        data: {
          'persen': double.parse(_bungaPersenController.text),
          'isaktif': _bungaStatus,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_storage.read('token')}'
          },
        ),
      );
      final responseData = _response.data;
      print(responseData);
      setState(() {
        if (responseData['success']) {
          _formKey.currentState?.reset();
          _bungaPersenController.clear();
          _bungaStatus = null;
          getBunga();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text('Bunga Berhasil di Simpan'),
                actions: <Widget>[
                  TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else {}
      });
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
    }
  }

  Future<void> _confirmAddBunga() async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi'),
          content: Text('Apakah Anda yakin ingin menambahkan bunga ini?'),
          actions: <Widget>[
            TextButton(
              child: Text("Batal", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text("Ya", style: TextStyle(color: Colors.green)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed) {
      addBunga();
    }
  }

  @override
  void dispose() {
    _bungaPersenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'Tambah Bunga',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[600],
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  DropdownButtonFormField<int>(
                    value: _bungaStatus,
                    onChanged: (value) {
                      setState(() {
                        _bungaStatus = value;
                      });
                    },
                    items: const [
                      DropdownMenuItem<int>(
                        value: 1,
                        child: Text('Aktif'),
                      ),
                      DropdownMenuItem<int>(
                        value: 0,
                        child: Text('Tidak Aktif'),
                      ),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Status Bunga',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null ? 'Silakan pilih status bunga' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _bungaPersenController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Persentase Bunga',
                      prefixIcon: Icon(Icons.percent),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Silakan masukkan persentase bunga';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Persentase harus berupa angka desimal';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 50),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState?.save();
                              _confirmAddBunga();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                          child: const Text(
                            'Simpan',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Bunga Aktif',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: activeBunga.length,
                    itemBuilder: (context, index) {
                      final bunga = activeBunga[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text('Persen: ${bunga.persen}%'),
                          subtitle: Text('Status: ${bunga.status}'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Bunga Tidak Aktif',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: inactiveBunga.length,
                    itemBuilder: (context, index) {
                      final bunga = inactiveBunga[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text('Persen: ${bunga.persen}%'),
                          subtitle: Text('Status: ${bunga.status}'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class BungaDatas {
  final List<Bunga> bungas;

  BungaDatas({required this.bungas});

  factory BungaDatas.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final bungas = data?['settingbungas'] as List<dynamic>?;

    return BungaDatas(
      bungas: bungas
              ?.map((bungaData) =>
                  Bunga.fromJson(bungaData as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Bunga {
  final double persen;
  final String status;

  Bunga({required this.persen, required this.status});

  factory Bunga.fromJson(Map<String, dynamic> json) {
    return Bunga(
      persen: json['persen'],
      status: json['isaktif'] == 1 ? 'Aktif' : 'Tidak Aktif',
    );
  }
}
















// UDAH BISA NAMBAH BUNGA DAN NAMPILIN BUNGA TAPI MASIH BELOM BISA DI REFRESH PAS UDAH BERHASIL DI SIMPAN BUNGANYA
// import 'package:flutter/material.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:dio/dio.dart';

// class AddBunga extends StatefulWidget {
//   const AddBunga({super.key});

//   @override
//   State<AddBunga> createState() => _AddBungaState();
// }

// class _AddBungaState extends State<AddBunga> {
//   BungaDatas? bungaDatas;
//   List<Bunga> activeBunga = [];
//   List<Bunga> inactiveBunga = [];
//   final _dio = Dio();
//   final _storage = GetStorage();
//   final _apiUrl = 'https://mobileapis.manpits.xyz/api';
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _bungaPersenController = TextEditingController();
//   int? _bungaStatus;
//   String? _resultMessage;

//   @override
//   void initState() {
//     super.initState();
//     getBunga();
//   }

//   Future<void> getBunga() async {
//     try {
//       final _response = await _dio.get(
//         '$_apiUrl/settingbunga',
//         options: Options(
//           headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
//         ),
//       );
//       final responseData = _response.data;
//       setState(() {
//         bungaDatas = BungaDatas.fromJson(responseData);
//         activeBunga = bungaDatas?.bungas
//                 .where((bunga) => bunga.status == 'Aktif')
//                 .toList() ??
//             [];
//         inactiveBunga = bungaDatas?.bungas
//                 .where((bunga) => bunga.status == 'Tidak Aktif')
//                 .toList() ??
//             [];
//       });
//     } on DioError catch (e) {
//       print('Error: ${e.response?.statusCode} - ${e.message}');
//     }
//   }

//   Future<void> addBunga() async {
//     try {
//       final _response = await _dio.post(
//         '$_apiUrl/addsettingbunga',
//         data: {
//           'persen': double.parse(_bungaPersenController.text),
//           'isaktif': _bungaStatus,
//         },
//         options: Options(
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer ${_storage.read('token')}'
//           },
//         ),
//       );
//       final responseData = _response.data;
//       print(responseData);
//       setState(() {
//         if (responseData['success']) {
//           _resultMessage = "Bunga Berhasil di Simpan";
//           getBunga();
//         } else {
//           _resultMessage = responseData['message'];
//         }
//       });
//     } on DioException catch (e) {
//       print('${e.response} - ${e.response?.statusCode}');
//       setState(() {
//         _resultMessage = e.response?.data['message'] ?? 'An error occurred';
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _bungaPersenController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: const Color(0xFFFAFAFA),
//         appBar: AppBar(
//           title: const Text(
//             'Tambah Bunga',
//             style: TextStyle(color: Colors.white),
//           ),
//           backgroundColor: Colors.green[600],
//           leading: IconButton(
//             onPressed: () {
//               Navigator.pushNamedAndRemoveUntil(
//                   context, '/home', (route) => false);
//             },
//             icon: const Icon(
//               Icons.arrow_back,
//               size: 32,
//             ),
//           ),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16),
//           child: ListView(
//             children: [
//               const SizedBox(height: 10),
//               Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     DropdownButtonFormField<int>(
//                       value: _bungaStatus,
//                       onChanged: (value) {
//                         setState(() {
//                           _bungaStatus = value;
//                         });
//                       },
//                       items: const [
//                         DropdownMenuItem<int>(
//                           value: 1,
//                           child: Text('Aktif'),
//                         ),
//                         DropdownMenuItem<int>(
//                           value: 0,
//                           child: Text('Tidak Aktif'),
//                         ),
//                       ],
//                       decoration: const InputDecoration(
//                         labelText: 'Status Bunga',
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (value) =>
//                           value == null ? 'Silakan pilih status bunga' : null,
//                     ),
//                     const SizedBox(height: 20),
//                     TextFormField(
//                       controller: _bungaPersenController,
//                       keyboardType:
//                           const TextInputType.numberWithOptions(decimal: true),
//                       decoration: const InputDecoration(
//                         labelText: 'Persentase Bunga',
//                         prefixIcon: Icon(Icons.percent),
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Silakan masukkan persentase bunga';
//                         }
//                         if (double.tryParse(value) == null) {
//                           return 'Persentase harus berupa angka desimal';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 50),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: () {
//                               if (_formKey.currentState!.validate()) {
//                                 _formKey.currentState?.save();
//                                 addBunga();
//                               }
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.green,
//                               elevation: 1,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               padding: const EdgeInsets.symmetric(vertical: 20),
//                             ),
//                             child: const Text(
//                               'Simpan',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     if (_resultMessage != null)
//                       Text(
//                         _resultMessage!,
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: _resultMessage == "Bunga Berhasil di Simpan"
//                               ? Colors.green
//                               : Colors.red,
//                         ),
//                       ),
//                     const SizedBox(height: 20),
//                     const Text(
//                       'Bunga Aktif',
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     ListView.builder(
//                       shrinkWrap: true,
//                       physics: NeverScrollableScrollPhysics(),
//                       itemCount: activeBunga.length,
//                       itemBuilder: (context, index) {
//                         final bunga = activeBunga[index];
//                         return ListTile(
//                           title: Text('Persen: ${bunga.persen}%'),
//                           subtitle: Text('Status: ${bunga.status}'),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 20),
//                     const Text(
//                       'Bunga Tidak Aktif',
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     ListView.builder(
//                       shrinkWrap: true,
//                       physics: NeverScrollableScrollPhysics(),
//                       itemCount: inactiveBunga.length,
//                       itemBuilder: (context, index) {
//                         final bunga = inactiveBunga[index];
//                         return ListTile(
//                           title: Text('Persen: ${bunga.persen}%'),
//                           subtitle: Text('Status: ${bunga.status}'),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ));
//   }
// }

// class BungaDatas {
//   final List<Bunga> bungas;

//   BungaDatas({required this.bungas});

//   factory BungaDatas.fromJson(Map<String, dynamic> json) {
//     final data = json['data'] as Map<String, dynamic>?;
//     final bungas = data?['settingbungas'] as List<dynamic>?;

//     return BungaDatas(
//       bungas: bungas
//               ?.map((bungaData) =>
//                   Bunga.fromJson(bungaData as Map<String, dynamic>))
//               .toList() ??
//           [],
//     );
//   }
// }

// class Bunga {
//   final double persen;
//   final String status;

//   Bunga({required this.persen, required this.status});

//   factory Bunga.fromJson(Map<String, dynamic> json) {
//     return Bunga(
//       persen: json['persen'],
//       status: json['isaktif'] == 1 ? 'Aktif' : 'Tidak Aktif',
//     );
//   }
// }






















// KODE BISA NAMBAH BUNGA TAPI BELUM BISA NAMPILIN BUNGA NYA

// import 'package:flutter/material.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:dio/dio.dart';

// class AddBunga extends StatefulWidget {
//   const AddBunga({super.key});

//   @override
//   State<AddBunga> createState() => _AddBungaState();
// }

// class _AddBungaState extends State<AddBunga> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _bungaPersenController = TextEditingController();

//   int? _bungaStatus;
//   String? _resultMessage;

//   final _dio = Dio();
//   final _storage = GetStorage();
//   final _apiUrl = 'https://mobileapis.manpits.xyz/api';

//   bool _isInitialized = false;

//   Future<void> fetchBungaStatus() async {
//     try {
//       final _response = await _dio.get(
//         '$_apiUrl/settingbunga',
//         options: Options(
//           headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
//         ),
//       );
//       Map<String, dynamic> responseData = _response.data;
//       if (responseData['success']) {
//         setState(() {
//           _bungaStatus = responseData['data']['bunga_status'];
//         });
//       }
//     } catch (e) {
//       print('Error fetching bunga status: $e');
//     }
//   }

//   Future<void> addBunga() async {
//     try {
//       final _response = await _dio.post(
//         '$_apiUrl/addsettingbunga',
//         data: {
//           'persen': double.parse(_bungaPersenController.text),
//           'isaktif': _bungaStatus,
//         },
//         options: Options(
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer ${_storage.read('token')}'
//           },
//         ),
//       );
//       Map<String, dynamic> responseData = _response.data;
//       print(responseData);
//       setState(() {
//         if (responseData['success']) {
//           _resultMessage = "Bunga Berhasil di Simpan";
//         } else {
//           _resultMessage = responseData['message'];
//         }
//       });
//     } on DioException catch (e) {
//       print('${e.response} - ${e.response?.statusCode}');
//       setState(() {
//         _resultMessage = e.response?.data['message'] ?? 'An error occurred';
//       });
//     }
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (!_isInitialized) {
//       _isInitialized = true;
//       fetchBungaStatus();
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: const Color(0xFFFAFAFA),
//         appBar: AppBar(
//           title: const Text(
//             'Tambah Bunga',
//             style: TextStyle(color: Colors.white),
//           ),
//           backgroundColor: Colors.green[600],
//           leading: IconButton(
//             onPressed: () {
//               Navigator.pushNamedAndRemoveUntil(
//                   context, '/home', (route) => false);
//             },
//             icon: const Icon(
//               Icons.arrow_back,
//               size: 32,
//             ),
//           ),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16),
//           child: ListView(
//             children: [
//               const SizedBox(height: 10),
//               Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     DropdownButtonFormField<int>(
//                       value: _bungaStatus,
//                       onChanged: (value) {
//                         setState(() {
//                           _bungaStatus = value;
//                         });
//                       },
//                       items: const [
//                         DropdownMenuItem<int>(
//                           value: 1,
//                           child: Text('Aktif'),
//                         ),
//                         DropdownMenuItem<int>(
//                           value: 0,
//                           child: Text('Tidak Aktif'),
//                         ),
//                       ],
//                       decoration: const InputDecoration(
//                         labelText: 'Status Bunga',
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (value) =>
//                           value == null ? 'Silakan pilih status bunga' : null,
//                     ),
//                     const SizedBox(height: 20),
//                     TextFormField(
//                       controller: _bungaPersenController,
//                       keyboardType:
//                           const TextInputType.numberWithOptions(decimal: true),
//                       decoration: const InputDecoration(
//                         labelText: 'Persentase Bunga',
//                         prefixIcon: Icon(Icons.percent),
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Silakan masukkan persentase bunga';
//                         }
//                         if (double.tryParse(value) == null) {
//                           return 'Persentase harus berupa angka desimal';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 50),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: () {
//                               if (_formKey.currentState!.validate()) {
//                                 _formKey.currentState?.save();
//                                 addBunga();
//                               }
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.green,
//                               elevation: 1,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               padding: const EdgeInsets.symmetric(vertical: 20),
//                             ),
//                             child: const Text(
//                               'Simpan',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     if (_resultMessage != null)
//                       Text(
//                         _resultMessage!,
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: _resultMessage == "Bunga Berhasil di Simpan"
//                               ? Colors.green
//                               : Colors.red,
//                         ),
//                       ),
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ));
//   }
// }
