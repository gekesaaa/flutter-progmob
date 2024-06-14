// import 'package:flutter/material.dart';

// class TabunganDetail extends StatefulWidget {
//   const TabunganDetail({super.key});

//   @override
//   _TabunganDetailState createState() => _TabunganDetailState();
// }

// class _TabunganDetailState extends State<TabunganDetail> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Detail Tabungan'),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Container(
//               color: Colors.green,
//               padding: const EdgeInsets.all(16),
//               child: const Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(height: 16),
//                   Text(
//                     'Nama Anggota',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                     ),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     'Rp 0.00',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Padding(
//               padding: EdgeInsets.all(8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Transaksi',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             DefaultTabController(
//               length: 5,
//               child: Column(
//                 children: [
//                   const TabBar(
//                     isScrollable: true,
//                     labelColor: Colors.black,
//                     unselectedLabelColor: Colors.grey,
//                     tabs: [
//                       Tab(text: 'Januari'),
//                       Tab(text: 'Februari'),
//                       Tab(text: 'Maret'),
//                       Tab(text: 'April'),
//                     ],
//                   ),
//                   SizedBox(
//                     height: 300, // Height of TabBarView
//                     child: TabBarView(
//                       children: [
//                         ListView(
//                           children: const [
//                             ListTile(
//                               leading: Icon(Icons.arrow_downward,
//                                   color: Colors.green),
//                               title: Text('Menerima Uang'),
//                               // subtitle: Text(
//                               //     'Transaction details'),
//                               trailing: Text(
//                                 '+ Rp 0.00',
//                                 style: TextStyle(color: Colors.green),
//                               ),
//                             ),
//                             ListTile(
//                               leading:
//                                   Icon(Icons.arrow_upward, color: Colors.red),
//                               title: Text('Transfer Uang'),
//                               // subtitle: Text(
//                               //     'Transaction details'),
//                               trailing: Text(
//                                 '- Rp 0.00',
//                                 style: TextStyle(color: Colors.red),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const Center(child: Text('No transactions')),
//                         const Center(child: Text('No transactions')),
//                         const Center(child: Text('No transactions')),
//                         const Center(child: Text('No transactions')),
//                         const Center(child: Text('No transactions')),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class TabunganDetail extends StatefulWidget {
  const TabunganDetail({super.key});

  @override
  State<TabunganDetail> createState() => _TabunganDetailState();
}

class _TabunganDetailState extends State<TabunganDetail> {
  late final int id;
  late final String nama;
  late final int saldo;

  final _dio = Dio();
  final _storage = GetStorage();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api';
  List<Map<String, dynamic>> _transactions = [];
  Map<int, String> _transactionTypes = {};
  bool _isInitialized = false;

  Future<void> getDetails() async {
    try {
      final _response = await _dio.get(
        '$_apiUrl/tabungan/$id',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      Map<String, dynamic> responseData = _response.data;
      if (responseData['success']) {
        setState(() {
          _transactions =
              List<Map<String, dynamic>>.from(responseData['data']['tabungan']);
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

  Future<void> getJenisTransaksi() async {
    try {
      final _response = await _dio.get(
        '$_apiUrl/jenistransaksi',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      Map<String, dynamic> responseData = _response.data;
      print(responseData);
      if (responseData['success']) {
        setState(() {
          _transactionTypes = {
            for (var item in responseData['data']['jenistransaksi'])
              item['id']: item['trx_name']
          };
        });
      }
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized && ModalRoute.of(context)?.settings.arguments != null) {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      id = arguments['id'] as int;
      nama = arguments['nama'];
      saldo = arguments['saldo'];
      getDetails();
      _isInitialized = true;
    }
  }

  @override
  void initState() {
    super.initState();
    getJenisTransaksi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Row(
          children: [
            SizedBox(width: 8),
            Text('Detail Tabungan'),
          ],
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, '/tabungan', (route) => false);
          },
          icon: const Icon(
            Icons.arrow_back,
            size: 32,
          ),
        ),
        actions: [
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(26, 94, 86, 149),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(26, 94, 86, 149),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _transactions.isEmpty
                    ? const Center(
                        child: Text('Tidak Ada Tabungan :) \nAyo Nabung!!',
                            textAlign: TextAlign.center),
                      )
                    : ListView.builder(
                        itemCount: _transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = _transactions[index];
                          final transactionType =
                              _transactionTypes[transaction['trx_id']] ??
                                  'Unknown';
                          return ListTile(
                            title: Text(NumberFormat.currency(
                                    locale: 'id_ID', symbol: 'Rp.')
                                .format(transaction['trx_nominal'])),
                            trailing: Text(transactionType),
                            subtitle: Text(DateFormat('dd MMMM yyyy – kk:mm')
                                .format(DateTime.parse(
                                    transaction['trx_tanggal']))),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
