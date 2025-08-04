import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminContactPage extends StatefulWidget {
  const AdminContactPage({super.key});

  @override
  State<AdminContactPage> createState() => _AdminContactPageState();
}

class _AdminContactPageState extends State<AdminContactPage> {
  // Variabel untuk menyimpan data kontak admin
  List<Map<String, dynamic>> _adminContacts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAdminContacts();
  }

  // Fungsi untuk mengambil data kontak admin dari Supabase
  Future<void> _fetchAdminContacts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await Supabase.instance.client
          .from('profiles') // Asumsi nama tabel 'profiles'
          .select('full_name, email') // Ambil kolom yang dibutuhkan
          .eq(
            'role',
            'Admin',
          ); // Filter berdasarkan kolom 'role' yang bernilai 'Admin'

      if (response != null) {
        setState(() {
          _adminContacts = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat data kontak. Respons null.';
          _isLoading = false;
        });
      }
    } on PostgrestException catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan Supabase: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk meluncurkan aplikasi email
  Future<void> _launchEmailApp(String email) async {
    final Uri emailLaunchUri = Uri(scheme: 'mailto', path: email);
    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tidak dapat membuka aplikasi email untuk $email'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Terjadi kesalahan saat meluncurkan email: ${e.toString()}',
            ),
          ),
        );
      }
    }
  }

  // Fungsi untuk meluncurkan aplikasi telepon
  Future<void> _launchPhoneApp(String phoneNumber) async {
    final Uri phoneLaunchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneLaunchUri)) {
        await launchUrl(phoneLaunchUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Tidak dapat membuka aplikasi telepon untuk $phoneNumber',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Terjadi kesalahan saat meluncurkan telepon: ${e.toString()}',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5E4036)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Kontak Admin',
          style: TextStyle(
            color: Color(0xFF5E4036),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF5E4036)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_adminContacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Tidak ada admin yang ditemukan.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchAdminContacts,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5E4036),
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    // Tampilkan daftar kontak admin
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView.builder(
        itemCount: _adminContacts.length,
        itemBuilder: (context, index) {
          final contact = _adminContacts[index];
          return _buildContactCard(
            context,
            name:
                contact['full_name'] ?? 'Nama Admin', // Asumsi ada kolom 'name'
            email:
                contact['email'] ??
                'admin@example.com', // Asumsi ada kolom 'email'
          );
        },
      ),
    );
  }

  // Widget pembangun untuk kartu kontak admin
  Widget _buildContactCard(
    BuildContext context, {
    required String name,
    required String email,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFF5E4036),
              child: Icon(Icons.person, size: 30, color: Colors.white),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5E4036),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    email,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
