import 'package:flutter/material.dart';

import '../../../utils/offline_handler.dart';
import '../../models/job_model.dart';
import '../../services/job_service.dart';
import '../../services/location_service.dart';
import '../../services/user_session.dart';

const Color kRed = Color(0xFFFF1E2D);

class AddJobScreen extends StatefulWidget {
  final Job? jobToEdit;

  const AddJobScreen({super.key, this.jobToEdit});

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  static const Color primaryColor = Color(0xFF4F46E5);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _requiredWorkersController =
      TextEditingController(text: "1");

  String _selectedCategory = "Plumber";
  bool _urgent = false;
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
      _requiredWorkersController.text =
          widget.jobToEdit!.requiredWorkers.toString();
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

  Future<void> _getCurrentLocation() async {
    try {
      setState(() => _fetchingLocation = true);
      final loc = await LocationService.getCurrentLocation();
      if (!mounted) return;
      setState(() {
        _latitude = loc["lat"].toString();
        _longitude = loc["lng"].toString();
        _locationController.text = loc["place"];
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Location error: $e")));
    } finally {
      if (mounted) {
        setState(() => _fetchingLocation = false);
      }
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
                validator: _validateTitle,
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
                validator: _validateDescription,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text("Use my current location"),
                value: _useCurrentLocation,
                onChanged: (value) {
                  setState(() {
                    _useCurrentLocation = value;
                    if (value) {
                      _locationController.clear();
                      _latitude = null;
                      _longitude = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 8),
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
              if (!_useCurrentLocation)
                _textField(
                  context,
                  "Enter city / town / village",
                  controller: _locationController,
                  validator: _validateLocation,
                ),
              const SizedBox(height: 16),
              _label("Salary / Payment"),
              _textField(
                context,
                "e.g. Rs 800-1000/day",
                controller: _salaryController,
                validator: _validateSalary,
              ),
              const SizedBox(height: 16),
              _label("Number of Workers Required"),
              _textField(
                context,
                "Enter number of workers needed",
                controller: _requiredWorkersController,
                keyboard: TextInputType.number,
                validator: _validateRequiredWorkers,
              ),
              const SizedBox(height: 16),
              _label("Contact Number"),
              _textField(
                context,
                "10-digit mobile number",
                controller: _phoneController,
                keyboard: TextInputType.phone,
                validator: _validatePhone,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: _urgent,
                onChanged: (value) => setState(() => _urgent = value),
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

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final requiredWorkers =
        int.tryParse(_requiredWorkersController.text.trim()) ?? 1;
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

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _showSnack("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message) {
    OfflineHandler.showErrorSnackBar(context, Exception(message));
  }

  String? _validateTitle(String? value) {
    final title = value?.trim() ?? '';
    if (title.isEmpty) {
      return "Job title is required";
    }
    if (title.length < 3) {
      return "Job title must be at least 3 characters";
    }
    return null;
  }

  String? _validateDescription(String? value) {
    final description = value?.trim() ?? '';
    if (description.isEmpty) {
      return "Description is required";
    }
    if (description.length < 20) {
      return "Description should be at least 20 characters";
    }
    return null;
  }

  String? _validateLocation(String? value) {
    if (_useCurrentLocation) return null;
    final location = value?.trim() ?? '';
    if (location.isEmpty) {
      return "Location is required";
    }
    if (location.length < 3) {
      return "Enter a more specific location";
    }
    return null;
  }

  String? _validateSalary(String? value) {
    final salary = value?.trim() ?? '';
    if (salary.isEmpty) {
      return null;
    }
    if (salary.length < 3) {
      return "Enter a valid salary or leave it blank";
    }
    return null;
  }

  String? _validateRequiredWorkers(String? value) {
    final workers = int.tryParse(value?.trim() ?? '');
    if (workers == null) {
      return "Enter the number of workers needed";
    }
    if (workers < 1 || workers > 500) {
      return "Workers required must be between 1 and 500";
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) {
      return "Enter a valid 10-digit contact number";
    }
    return null;
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
            .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
            .toList(),
        onChanged: (value) => setState(() => _selectedCategory = value!),
      ),
    ),
  );
}
