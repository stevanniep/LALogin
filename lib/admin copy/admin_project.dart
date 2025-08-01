import 'package:flutter/material.dart';

class AdminProjectPage extends StatelessWidget {
  const AdminProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          child: const SafeArea(
            child: Text(
              'Proyek',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF4B2E2B),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          CustomProjectTile(title: 'Proyek Lab 1', hasDetail: true),
          SizedBox(height: 16),
          CustomProjectTile(title: 'Proyek Lab 2'),
          SizedBox(height: 16),
          CustomProjectTile(title: 'Proyek Lab 3'),
        ],
      ),
    );
  }
}

class CustomProjectTile extends StatefulWidget {
  final String title;
  final bool hasDetail;

  const CustomProjectTile({
    super.key,
    required this.title,
    this.hasDetail = false,
  });

  @override
  State<CustomProjectTile> createState() => _CustomProjectTileState();
}

class _CustomProjectTileState extends State<CustomProjectTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            ListTile(
              title: Text(
                widget.title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: Color(0xFF4B2E2B),
                ),
              ),
              trailing: GestureDetector(
                onTap: () {
                  if (widget.hasDetail) {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  }
                },
                child: AnimatedRotation(
                  turns: _isExpanded ? 0.25 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Image.asset(
                    'assets/adm/panah.png',
                    width: 20,
                    height: 20,
                    color: const Color(0xFF4B2E2B),
                  ),
                ),
              ),
            ),
            if (_isExpanded && widget.hasDetail)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tahap 1",
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                        Text(
                          "Selesai",
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                        Text(
                          "22/07/25",
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tahap 2",
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            right: 65,
                          ), // Coba geser ke kanan sekitar 32 pixel
                          child: Text(
                            "Belum Selesai",
                            style: TextStyle(fontFamily: 'Poppins'),
                          ),
                        ),

                        Text("", style: TextStyle(fontFamily: 'Poppins')),
                      ],
                    ),

                    SizedBox(height: 12),
                    Center(
                      child: Text(
                        "Progres: 50%",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
