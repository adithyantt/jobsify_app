import 'package:flutter/material.dart';

class AddJobScreen extends StatefulWidget {
  const AddJobScreen({super.key});

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  // Theme color (same as Home)
  static const Color primaryColor = Color(0xFF1B0C6D);

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  // Dropdown value
  String _selectedCategory = "Plumber";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Create Your Profile"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _textField("Enter your full name", controller: _nameController),

              const SizedBox(height: 16),

              _label("Category *"),
              _dropdown(),

              const SizedBox(height: 16),

              _label("Experience *"),
              _textField("e.g., 5 years", controller: _experienceController),

              const SizedBox(height: 16),

              _label("Location *"),
              _textField(
                "Enter your location/area",
                controller: _locationController,
              ),

              const SizedBox(height: 16),

              _label("Contact Number *"),
              _textField(
                "+91 98765 43210",
                controller: _contactController,
                keyboard: TextInputType.phone,
              ),

              const SizedBox(height: 16),

              _label("About You"),
              _textField(
                "Tell employers about your skills and experience",
                controller: _aboutController,
                maxLines: 4,
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _submit,
                      child: const Text("Create"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 SUBMIT (UI only for now)
  void _submit() {
    // Later this will call backend POST /jobs
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Profile created (UI only)")));
    Navigator.pop(context);
  }

  // ---------- UI HELPERS ----------

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _textField(
    String hint, {
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _dropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: "Plumber", child: Text("Plumber")),
            DropdownMenuItem(value: "Electrician", child: Text("Electrician")),
            DropdownMenuItem(value: "Painter", child: Text("Painter")),
            DropdownMenuItem(value: "Driver", child: Text("Driver")),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCategory = value!;
            });
          },
        ),
      ),
    );
  }
}
