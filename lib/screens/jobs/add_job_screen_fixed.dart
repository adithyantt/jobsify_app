import 'package:flutter/material.dart';
import '../../services/job_service.dart';
import '../../services/location_service.dart';
import '../../services/user_session.dart';
import '../../models/job_model.dart';
import '../../../utils/offline_handler.dart';

/// UI COLORS
const Color kRed = Color(0xFFFF1E2D);

class AddJobScreen extends StatefulWidget {
  final Job? jobToEdit; // Optional job for editing

  const AddJobScreen({super.key, this.jobToEdit});

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  static const Color primaryColor = Color(0xFF1B0C6D);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _requiredWorkersController =
      TextEditingController(text: "1");

  String _selectedCategory = "Plumber";
  bool _urgent = false;

  /// 🔹 LOCATION STATE
  bool _useCurrentLocation = true;
  String? _latitude;
  String? _longitude;
  bool _fetchingLocation = false;

  final List<String> _categories = [
    "Plumber",
    "Painter",
    "Driver",
    "Electrician",
    "Carpenter",
    "Cleaner",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.jobToEdit != null) {
      _titleController.text = widget.jobToEdit!.title;
      _selectedCategory = widget.jobToEdit!.category;
      _descriptionController.text = widget.jobToEdit!.description;
      _locationController.text = widget.jobToEdit!.location;
      _phoneController.text = widget.jobToEdit!.phone;
      _salaryController.text = widget.jobToEdit!.salary ?? '';
      _urgent = widget.jobToEdit!.urgent;
      _requiredWorkersController.text = widget.jobToEdit!.requiredWorkers
          .toString();
      _latitude = widget.jobToEdit!.latitude;
      _longitude = widget.jobToEdit!.longitude;
      _useCurrentLocation = _latitude != null && _longitude != null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _salaryController.dispose();
    _requiredWorkersController.dispose();
    super.dispose();
  }

  /// 📍 FETCH GPS LOCATION
  Future<void> _getCurrentLocation() async {
    try {
      setState(() => _fetchingLocation = true);
      final loc = await LocationService.getCurrentLocation();
      setState(() {
        _latitude = loc["lat"].toString();
        _longitude = loc["lng"].toString();
        _locationController.text = loc["place"];
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Location error: $e")));
    } finally {
      setState(() => _fetchingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(widget.jobToEdit != null ? "Edit Job" : "Post a Job"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label("Job Title"),
              _textField(
                context,
                "Enter job title",
                controller: _titleController,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              _label("Category"),
              _dropdown(context),
              const SizedBox(height: 16),
              _label("Description"),
              _textField(
                context,
                "Describe the job",
                controller: _descriptionController,
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              /// 📍 LOCATION MODE
              SwitchListTile(
                title: const Text("Use my current location"),
                value: _useCurrentLocation,
                onChanged: (v) {
                  setState(() {
                    _useCurrentLocation = v;
                    if (v) {
                      _locationController.clear();
                      _latitude = null;
                      _longitude = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 8),

              /// 📡 GPS BUTTON
              if (_useCurrentLocation)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                    ),
                    icon: const Icon(Icons.my_location),
                    label: Text(
                      _fetchingLocation
                          ? "Fetching location..."
                          : "Fetch current location",
                    ),
                    onPressed: _fetchingLocation ? null : _getCurrentLocation,
                  ),
                ),

              /// ✍️ MANUAL LOCATION
              if (!_useCurrentLocation)
                _textField(
                  context,
                  "Enter city / town / village",
                  controller: _locationController,
                ),
              const SizedBox(height: 16),
              _label("Salary / Payment"),
              _textField(
                context,
                "e.g. ₹800-1000/day",
                controller: _salaryController,
              ),
              const SizedBox(height: 16),
              _label("Number of Workers Required"),
              _textField(
                context,
                "Enter number of workers needed",
                controller: _requiredWorkersController,
                keyboard: TextInputType.number,
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
              SwitchListTile(
                value: _urgent,
                onChanged: (v) => setState(() => _urgent = v),
                title: const Text("Mark as Urgent"),
                activeThumbColor: kRed,
                contentPadding: EdgeInsets.zero,
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
                      child: Text(
                        widget.jobToEdit != null ? "Update Job" : "Post Job",
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 SUBMIT
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final requiredWorkers =
        int.tryParse(_requiredWorkersController.text.trim()) ?? 1;
    if (requiredWorkers < 1) {
      _showSnack("Please enter a valid number of workers (minimum 1)");
      return;
    }
    if (_useCurrentLocation && (_latitude == null || _longitude == null)) {
      _showSnack("Please fetch your current location");
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (widget.jobToEdit != null) {
        await JobService.updateJob(
          jobId: widget.jobToEdit!.id,
          title: _titleController.text.trim(),
          category: _selectedCategory,
          description: _descriptionController.text.trim(),
          location: _locationController.text.trim(),
          phone: _phoneController.text.trim(),
          latitude: _latitude,
          longitude: _longitude,
          userEmail: UserSession.email ?? '',
          urgent: _urgent,
          salary: _salaryController.text.trim().isNotEmpty
              ? _salaryController.text.trim()
              : null,
          requiredWorkers: requiredWorkers,
        );
        _showSnack("Job updated successfully.");
      } else {
        await JobService.createJob(
          title: _titleController.text.trim(),
          category: _selectedCategory,
          description: _descriptionController.text.trim(),
          location: _locationController.text.trim(),
          phone: _phoneController.text.trim(),
          latitude: _latitude,
          longitude: _longitude,
          userEmail: UserSession.email ?? '',
          urgent: _urgent,
          salary: _salaryController.text.trim().isNotEmpty
              ? _salaryController.text.trim()
              : null,
          requiredWorkers: requiredWorkers,
        );
        _showSnack("Job posted! Awaiting admin approval.");
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showSnack("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message) {
    OfflineHandler.showErrorSnackBar(context, Exception(message));
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
  );

  Widget _textField(
    BuildContext context,
    String hint, {
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,
      textCapitalization: textCapitalization,
      validator: validator,
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

  Widget _dropdown(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedCategory,
        isExpanded: true,
        items: _categories
            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
            .toList(),
        onChanged: (value) => setState(() => _selectedCategory = value!),
      ),
    ),
  );
}
