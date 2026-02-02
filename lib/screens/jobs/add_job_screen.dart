import 'package:flutter/material.dart';
import '../../services/job_service.dart';

class AddJobScreen extends StatefulWidget {
  const AddJobScreen({super.key});

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  static const Color primaryColor = Color(0xFF1B0C6D);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _selectedCategory = "Plumber";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Create Worker Profile"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label("Full Name"),
            _textField("Enter your full name", controller: _nameController),

            const SizedBox(height: 16),

            _label("Skill Category"),
            _dropdown(),

            const SizedBox(height: 16),

            _label("Experience"),
            _textField("e.g., 5 years", controller: _experienceController),

            const SizedBox(height: 16),

            _label("Location"),
            _textField("Enter your area", controller: _locationController),

            const SizedBox(height: 16),

            _label("Contact Number"),
            _textField(
              "10-digit mobile number",
              controller: _phoneController,
              keyboard: TextInputType.phone,
            ),

            const SizedBox(height: 16),

            _label("About You"),
            _textField(
              "Describe your skills and experience",
              controller: _aboutController,
              maxLines: 4,
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                    onPressed: _submit,
                    child: const Text("Save Profile"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 SUBMIT (BACKEND SAFE)
  void _submit() async {
    try {
      await JobService.createJob(
        title: _nameController.text, // reused safely
        category: _selectedCategory,
        description: _aboutController.text,
        location: _locationController.text,
        phone: _phoneController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile saved successfully")),
      );

      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to save profile")));
    }
  }

  // ---------- UI HELPERS ----------

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
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
            setState(() => _selectedCategory = value!);
          },
        ),
      ),
    );
  }
}
