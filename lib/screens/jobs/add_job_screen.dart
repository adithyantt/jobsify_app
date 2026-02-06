import 'package:flutter/material.dart';
import '../../services/worker_service.dart';

class AddJobScreen extends StatefulWidget {
  const AddJobScreen({super.key});

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  bool _isLoading = false;

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

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
            _textField(
              context,
              "Enter your full name",
              controller: _nameController,
            ),

            const SizedBox(height: 16),

            _label("Skill Category"),
            _dropdown(context),

            const SizedBox(height: 16),

            _label("Experience"),
            _textField(
              context,
              "e.g., 5 years",
              controller: _experienceController,
            ),

            const SizedBox(height: 16),

            _label("Location"),
            _textField(
              context,
              "Enter your area",
              controller: _locationController,
            ),

            const SizedBox(height: 16),

            _label("Contact Number"),
            _textField(
              context,
              "10-digit mobile number",
              controller: _phoneController,
              keyboard: TextInputType.phone,
            ),

            const SizedBox(height: 16),

            _label("About You"),
            _textField(
              context,
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
                    onPressed: _isLoading ? null : _submit,
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
    // Basic validation
    if (_nameController.text.isEmpty ||
        _experienceController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      _showSnack("All fields are required.");
      return;
    }

    final experience = int.tryParse(_experienceController.text.trim());
    if (experience == null || experience < 0) {
      _showSnack("Please enter a valid number for experience.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // This screen creates a WORKER, so we use WorkerService.
      await WorkerService.createWorker(
        name: _nameController.text.trim(),
        role: _selectedCategory,
        phone: _phoneController.text.trim(),
        experience: experience,
        location: _locationController.text,
        // latitude and longitude are not collected on this screen.
      );

      if (!mounted) return;

      _showSnack(
        "Profile saved successfully. It will be reviewed by an admin.",
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnack("An error occurred: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ---------- UI HELPERS ----------
  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget _textField(
    BuildContext context,
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
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _dropdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
