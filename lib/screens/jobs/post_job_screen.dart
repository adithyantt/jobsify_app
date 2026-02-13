import 'package:flutter/material.dart';
import '../../services/job_service.dart';
import '../../services/location_service.dart';
import '../../services/user_session.dart';

/// UI COLORS
const Color kRed = Color(0xFFFF1E2D);

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  final TextEditingController locationCtrl = TextEditingController();
  final TextEditingController salaryCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();

  String category = "Plumber";
  bool urgent = false;

  /// 🔹 LOCATION STATE
  bool useCurrentLocation = true;
  String? latitude;
  String? longitude;
  bool fetchingLocation = false;

  final List<String> categories = [
    "Plumber",
    "Painter",
    "Driver",
    "Electrician",
    "Carpenter",
    "Cleaner",
  ];

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    locationCtrl.dispose();
    salaryCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  /// 📍 FETCH GPS LOCATION
  Future<void> _getCurrentLocation() async {
    try {
      setState(() => fetchingLocation = true);

      final loc = await LocationService.getCurrentLocation();

      setState(() {
        latitude = loc["lat"].toString();
        longitude = loc["lng"].toString();
        locationCtrl.text = loc["place"];
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Location error: $e")));
    } finally {
      setState(() => fetchingLocation = false);
    }
  }

  /// 🚀 SUBMIT JOB
  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;

    if (useCurrentLocation && (latitude == null || longitude == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fetch your current location")),
      );
      return;
    }

    try {
      await JobService.createJob(
        title: titleCtrl.text.trim(),
        category: category,
        description: descCtrl.text.trim(),
        location: locationCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        latitude: latitude,
        longitude: longitude,
        userEmail: UserSession.email ?? '', // Add user email
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Job will be posted after admin approval"),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to post job: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      /// 🔴 APP BAR
      appBar: AppBar(
        backgroundColor: kRed,
        elevation: 0,
        title: const Text("Post a Job"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label("Job Title"),
              TextFormField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  hintText: "e.g. Need plumber for pipe repair",
                ),
                validator: (v) => v!.isEmpty ? "Enter job title" : null,
              ),

              const SizedBox(height: 16),

              _label("Category"),
              DropdownButtonFormField<String>(
                initialValue: category,
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => category = v!),
                decoration: _fieldDecoration(context),
              ),

              const SizedBox(height: 16),

              _label("Job Description"),
              _input(
                context,
                controller: descCtrl,
                hint: "Describe the work in detail",
                maxLines: 4,
                validator: (v) => v!.isEmpty ? "Enter description" : null,
              ),

              const SizedBox(height: 16),

              /// 📍 LOCATION MODE
              _label("Location"),
              RadioListTile(
                title: const Text("Use my current location"),
                value: true,
                selected: useCurrentLocation,
                onChanged: (v) {
                  setState(() {
                    useCurrentLocation = v ?? true;
                    if (v == true) {
                      locationCtrl.clear();
                      latitude = null;
                      longitude = null;
                    }
                  });
                },
              ),
              RadioListTile(
                title: const Text("Enter location manually"),
                value: false,
                selected: !useCurrentLocation,
                onChanged: (v) {
                  setState(() {
                    useCurrentLocation = v ?? false;
                    if (v == false) {
                      latitude = null;
                      longitude = null;
                    }
                  });
                },
              ),

              const SizedBox(height: 8),

              /// 📡 GPS BUTTON
              if (useCurrentLocation)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                    ),
                    icon: const Icon(Icons.my_location),
                    label: Text(
                      fetchingLocation
                          ? "Fetching location..."
                          : "Fetch current location",
                    ),
                    onPressed: fetchingLocation ? null : _getCurrentLocation,
                  ),
                ),

              /// ✍️ MANUAL LOCATION
              if (!useCurrentLocation)
                _input(
                  context,
                  controller: locationCtrl,
                  hint: "Enter city / town / village",
                  validator: (v) => v!.isEmpty ? "Enter location" : null,
                ),

              const SizedBox(height: 16),

              _label("Salary / Payment"),
              _input(
                context,
                controller: salaryCtrl,
                hint: "e.g. ₹800-1000/day",
              ),

              const SizedBox(height: 16),

              _label("Contact Number"),
              _input(
                context,
                controller: phoneCtrl,
                hint: "10-digit mobile number",
                keyboardType: TextInputType.phone,
                validator: (v) => v!.length < 10 ? "Enter valid number" : null,
              ),

              const SizedBox(height: 16),

              SwitchListTile(
                value: urgent,
                onChanged: (v) => setState(() => urgent = v),
                title: const Text("Mark as Urgent"),
                activeThumbColor: kRed,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kRed,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _submitJob,
                  child: const Text("Post Job", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 LABEL
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  /// 🔹 INPUT
  Widget _input(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _fieldDecoration(context, hint: hint),
    );
  }

  /// 🔹 DECORATION
  InputDecoration _fieldDecoration(BuildContext context, {String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Theme.of(context).cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
