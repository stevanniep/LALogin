import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_navbar.dart';

class TambahJadwalPage extends StatefulWidget {
  const TambahJadwalPage({super.key});

  @override
  State<TambahJadwalPage> createState() => _TambahJadwalPageState();
}

class _TambahJadwalPageState extends State<TambahJadwalPage> {
  // Controllers for text input fields
  final TextEditingController namaController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController tempatController = TextEditingController();
  final TextEditingController waktuController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set initial text for the date field to today's date
    // Format: DD/MM/YYYY
    tanggalController.text =
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
  }

  // Function to parse a "DD/MM/YYYY" date string into a DateTime object
  DateTime _parseDate(String input) {
    // Split the string by '/'
    final parts = input.split('/');
    // Convert the string parts to integers
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    // Return the DateTime object
    return DateTime(year, month, day);
  }

  @override
  void dispose() {
    // Important: Dispose controllers to prevent memory leaks
    namaController.dispose();
    tanggalController.dispose();
    tempatController.dispose();
    waktuController.dispose();
    super.dispose();
  }

  // Function to show a snackbar (alternative to alert)
  void _showSnackBar(String message, {bool isError = false}) {
    // Ensure the widget is still in the widget tree before showing the snackbar
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF4B2E2B),
      ),
    );
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
              padding: const EdgeInsets.only(
                top: 12,
                left: 16,
                right: 16,
                bottom: 12,
              ),
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
                    onTap: () {
                      // Use pushReplacement to return to the AdminHomePage
                      // This will replace the current route in the navigation stack
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AdminHomePage(initialIndex: 0),
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/icons/kembali.png', // Ensure this asset path is correct
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Tambah Jadwal',
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

            // Body content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 70), // Spacing from AppBar
                    _inputField('Nama Kegiatan', namaController),
                    _inputField('Tanggal', tanggalController),
                    _inputField('Tempat', tempatController),
                    _inputField('Waktu', waktuController),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 248,
                      height: 38,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4B2E2B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          // Initialize Supabase client
                          final supabase = Supabase.instance.client;

                          try {
                            // Insert data into the 'jadwal_kegiatan' table
                            // Supabase will automatically convert DateTime to 'date' or 'timestamp' type
                            await supabase.from('jadwal_kegiatan').insert({
                              'nama': namaController.text,
                              'tanggal': _parseDate(
                                tanggalController.text,
                              ).toIso8601String(), // Convert to ISO 8601 string for consistency
                              'tempat': tempatController.text,
                              'waktu': waktuController.text,
                              'user_id': supabase.auth.currentUser!.id,
                            });

                            // Show success snackbar
                            _showSnackBar('Jadwal berhasil ditambahkan');

                            // Go back to the previous page after successful save
                            // Ensure the widget is still mounted before popping
                            if (!mounted) return;
                            Navigator.pop(context);
                          } catch (e) {
                            // Show error snackbar if an error occurs
                            _showSnackBar(
                              'Gagal menambahkan jadwal: $e',
                              isError: true,
                            );
                          }
                        },
                        child: const Text(
                          'Tambah',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to create a text input field
  Widget _inputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          width: 248,
          height: 30,
          child: TextField(
            controller: controller,
            cursorColor: Colors.black,
            style: const TextStyle(fontSize: 13),
            // If the label is 'Tanggal', the field will be readOnly so it can only be selected from the date picker
            // Otherwise, the field can be edited manually
            readOnly: label == 'Tanggal',
            onTap:
                label ==
                    'Tanggal' // Add onTap so the date picker appears when tapped
                ? () async {
                    // Use a custom theme for the date picker
                    DateTime? pickedDate = await showDialog<DateTime>(
                      context: context,
                      builder: (BuildContext context) {
                        return Theme(
                          // Apply the custom theme here
                          data: ThemeData(
                            colorScheme: ColorScheme.light(
                              primary: const Color(
                                0xFF4B2E2B,
                              ), // Header color and selected date
                              onPrimary: Colors
                                  .white, // Text color on primary background
                              onSurface: const Color(
                                0xFF4B2E2B,
                              ), // Text color on calendar surface
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(
                                  0xFF4B2E2B,
                                ), // Button text color
                              ),
                            ),
                            // You can add more theme customizations here if needed
                            // For example, you can also customize the background color, etc.
                          ),
                          child: DatePickerDialog(
                            initialDate: _parseDate(
                              tanggalController.text,
                            ), // Set initial date from current value
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          ),
                        );
                      },
                    );

                    if (pickedDate != null) {
                      // Format the date to DD/MM/YYYY
                      String formattedDate =
                          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      // Update the text controller with the selected date
                      setState(() {
                        controller.text = formattedDate;
                      });
                    }
                  }
                : null,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF4B2E2B).withOpacity(0.2),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              // Show the calendar icon only for the 'Tanggal' field
              suffixIcon: label == 'Tanggal'
                  ? const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.black,
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
