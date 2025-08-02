import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDataAsistenPage extends StatefulWidget {
  const AdminDataAsistenPage({super.key});

  @override
  State<AdminDataAsistenPage> createState() => _AdminDataAsistenPageState();
}

class _AdminDataAsistenPageState extends State<AdminDataAsistenPage> {
  // Future to hold the fetched user profile data (now a list)
  late Future<List<Map<String, dynamic>>?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchAllProfilesData();
  }

  // Function to fetch all profile data from Supabase
  Future<List<Map<String, dynamic>>?> _fetchAllProfilesData() async {
    try {
      // Fetch all data from the 'profiles' table
      // The .select() method directly returns the data in newer versions of supabase_flutter
      final List<Map<String, dynamic>> response = await Supabase.instance.client
          .from('profiles')
          .select('full_name, username, role, email, nim')
          .order('full_name', ascending: true); // Optional: order by full_name

      // The response is already a List<Map<String, dynamic>> if successful
      return response;
    } on PostgrestException catch (e) {
      // Handle Supabase-specific errors
      print('Supabase error fetching profiles: ${e.message}');
      return null;
    } catch (e) {
      // Handle other potential errors during data fetching
      print('Error fetching profiles data: $e');
      return null;
    }
  }

  // Helper function to safely get data and replace null with '-'
  String _getDataOrDefault(dynamic data) {
    return data?.toString() ?? '-';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      'assets/icons/kembali.png', // Pastikan path benar
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Data Asisten',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF4B2E2B),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // Box info asisten using FutureBuilder for a list of profiles
            Expanded(
              // Use Expanded to allow ListView to take available space
              child: FutureBuilder<List<Map<String, dynamic>>?>(
                future: _profileFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Show a loading indicator while data is being fetched
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4B2E2B),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    // Show an error message if data fetching fails
                    return Center(
                      child: Container(
                        width: 360,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors
                              .red[700], // Use a distinct color for errors
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Gagal memuat data profil.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // Show a message if no data is found
                    return Center(
                      child: Container(
                        width: 360,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4B2E2B),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Tidak ada data profil ditemukan.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  } else {
                    // Data successfully fetched, display it in a ListView
                    final List<Map<String, dynamic>> profiles = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: profiles.length,
                      itemBuilder: (context, index) {
                        final profileData = profiles[index];
                        final String fullName = _getDataOrDefault(
                          profileData['full_name'],
                        );
                        final String username = _getDataOrDefault(
                          profileData['username'],
                        );
                        final String role = _getDataOrDefault(
                          profileData['role'],
                        );
                        final String email = _getDataOrDefault(
                          profileData['email'],
                        );
                        final String nim = _getDataOrDefault(
                          profileData['nim'],
                        );

                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: 20.0,
                          ), // Spacing between boxes
                          child: Container(
                            width: 360, // Fixed width as per original design
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4B2E2B),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(width: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    'assets/images/photoprofile.png', // Pastikan path benar
                                    width: 85,
                                    height: 85,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // Info asisten
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        fullName,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        username,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        role,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        email,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        nim,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
