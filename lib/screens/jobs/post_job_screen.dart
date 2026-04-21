import 'package:flutter/material.dart';
import '../../services/job_service.dart';
import '../../services/location_service.dart';
import '../../services/user_session.dart';

/// UI COLORS
const Color kRed = Color(0xFFFF1E2D);
const Color kPrimary = Color(0xFF4F46E5);

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
  final TextEditingController requiredWorkersCtrl = TextEditingController(
    text: "1",
  );

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
    requiredWorkersCtrl.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Please turn on location services for better experience",
          ),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _getCurrentLocation,
          ),
        ),
      );
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

    // Parse required workers
    final requiredWorkers = int.tryParse(requiredWorkersCtrl.text) ?? 1;

    try {
      await JobService.createJob(
        title: titleCtrl.text.trim(),
        category: category,
        description: descCtrl.text.trim(),
        location: locationCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        latitude: latitude,
        longitude: longitude,
        userEmail: UserSession.email ?? '',
        urgent: urgent,
        requiredWorkers: requiredWorkers,
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
      backgroundColor: const Color(0xFFF8FAFC),

      /// 🔴 APP BAR
      appBar: AppBar(
        backgroundColor: kPrimary,
        elevation: 0,
        title: const Text("Post a Job"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                "Job Details",
                Column(
                  children: [
                    _label("Job Title"),
                    TextFormField(
                      controller: titleCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: _fieldDecoration(
                        context,
                        hint: "e.g. Need plumber for pipe repair",
                        icon: Icons.work_outline,
                      ),
                      validator: (v) =>
                          v!.trim().isEmpty ? "Enter job title" : null,
                    ),
                    const SizedBox(height: 16),
                    _label("Category"),
                    DropdownButtonFormField<String>(
                      value: category,
                      items: categories
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => category = v!),
                      decoration: _fieldDecoration(
                        context,
                        icon: Icons.category_outlined,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _label("Job Description"),
                    TextFormField(
                      controller: descCtrl,
                      maxLines: 4,
                      validator: (v) =>
                          v!.trim().isEmpty ? "Enter description" : null,
                      decoration: _fieldDecoration(
                        context,
                        hint: "Describe the work in detail",
                      ),
                    ),
                  ],
                ),
              ),

              _buildSection(
                "Location",
                Column(
                  children: [
                    RadioListTile<bool>(
                      title: const Text("Use my current location"),
                      value: true,
                      groupValue: useCurrentLocation,
                      activeColor: kPrimary,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) {
                        setState(() {
                          useCurrentLocation = v!;
                          if (v) {
                            locationCtrl.clear();
                            latitude = null;
                            longitude = null;
                          }
                        });
                      },
                    ),
                    RadioListTile<bool>(
                      title: const Text("Enter location manually"),
                      value: false,
                      groupValue: useCurrentLocation,
                      activeColor: kPrimary,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) {
                        setState(() {
                          useCurrentLocation = v!;
                          if (!v) {
                            latitude = null;
                            longitude = null;
                          }
                        });
                      },
                    ),
                    if (useCurrentLocation)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimary.withValues(alpha: 0.1),
                              foregroundColor: kPrimary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: fetchingLocation
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.my_location),
                            label: Text(
                              fetchingLocation
                                  ? "Fetching location..."
                                  : "Fetch GPS Location",
                            ),
                            onPressed: fetchingLocation
                                ? null
                                : _getCurrentLocation,
                          ),
                        ),
                      ),
                    if (!useCurrentLocation)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: _input(
                          context,
                          controller: locationCtrl,
                          hint: "Enter city / town / village",
                          icon: Icons.map_outlined,
                          validator: (v) =>
                              v!.trim().isEmpty ? "Enter location" : null,
                        ),
                      ),
                  ],
                ),
              ),

              _buildSection(
                "Payment & Contact",
                Column(
                  children: [
                    _label("Salary / Payment"),
                    _input(
                      context,
                      controller: salaryCtrl,
                      hint: "e.g. ₹800-1000/day",
                      icon: Icons.currency_rupee,
                    ),
                    const SizedBox(height: 16),
                    _label("Contact Number"),
                    _input(
                      context,
                      controller: phoneCtrl,
                      hint: "10-digit mobile number",
                      keyboardType: TextInputType.phone,
                      icon: Icons.phone,
                      validator: (v) =>
                          v!.length < 10 ? "Enter valid number" : null,
                    ),
                    const SizedBox(height: 16),
                    _label("Number of Workers"),
                    _input(
                      context,
                      controller: requiredWorkersCtrl,
                      hint: "1",
                      keyboardType: TextInputType.number,
                      icon: Icons.group,
                    ),
                  ],
                ),
              ),

              CheckboxListTile(
                value: urgent,
                onChanged: (v) => setState(() => urgent = v!),
                title: const Text(
                  "Mark as Urgent",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("Urgent jobs get more attention"),
                activeColor: kRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: urgent ? kRed.withValues(alpha: 0.05) : null,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  onPressed: _submitJob,
                  child: const Text(
                    "Post Job",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontSize: 12,
              letterSpacing: 1.1,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Padding(padding: const EdgeInsets.all(16), child: content),
        ),
      ],
    );
  }

  /// 🔹 LABEL
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
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
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _fieldDecoration(context, hint: hint, icon: icon),
    );
  }

  /// 🔹 DECORATION
  InputDecoration _fieldDecoration(
    BuildContext context, {
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null
          ? Icon(icon, color: Colors.grey, size: 20)
          : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kPrimary, width: 2),
      ),
    );
  }
}
