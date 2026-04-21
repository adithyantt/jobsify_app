import 'package:flutter/material.dart';

import '../../../utils/offline_handler.dart';
import '../../models/worker_model.dart';
import '../../services/location_service.dart';
import '../../services/user_session.dart';
import '../../services/worker_service.dart';

const Color kPrimary = Color(0xFF4F46E5);

class AddWorkerScreen extends StatefulWidget {
  final Worker? workerToEdit;

  const AddWorkerScreen({super.key, this.workerToEdit});

  @override
  State<AddWorkerScreen> createState() => _AddWorkerScreenState();
}

class _AddWorkerScreenState extends State<AddWorkerScreen> {
  final _formKey = GlobalKey<FormState>();
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final roleCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final expCtrl = TextEditingController();
  final locationCtrl = TextEditingController();

  bool loading = false;
  bool locationLoading = false;
  String? latitude;
  String? longitude;

  final List<String> roles = const [
    "Plumber",
    "Electrician",
    "Painter",
    "Driver",
    "Carpenter",
    "Mechanic",
    "Other",
  ];
  String selectedRole = "Plumber";
  String availabilityOption = "everyday";
  final List<String> weekDays = [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun",
  ];
  List<String> selectedDays = [];
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    if (widget.workerToEdit != null) {
      final nameParts = widget.workerToEdit!.name.split(' ');
      if (nameParts.isNotEmpty) {
        firstNameCtrl.text = nameParts.first;
        if (nameParts.length > 1) {
          lastNameCtrl.text = nameParts.sublist(1).join(' ');
        }
      }
      selectedRole = roles.contains(widget.workerToEdit!.role)
          ? widget.workerToEdit!.role
          : "Other";
      if (selectedRole == "Other") roleCtrl.text = widget.workerToEdit!.role;
      phoneCtrl.text = widget.workerToEdit!.phone;
      expCtrl.text = widget.workerToEdit!.experience.toString();
      locationCtrl.text = widget.workerToEdit!.location;
      latitude = widget.workerToEdit!.latitude;
      longitude = widget.workerToEdit!.longitude;
      availabilityOption = widget.workerToEdit!.availabilityType ?? "everyday";
      selectedDays =
          widget.workerToEdit!.availableDays
              ?.split(',')
              .map((day) => day.trim())
              .where((day) => day.isNotEmpty)
              .toList() ??
          [];
    }
  }

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    roleCtrl.dispose();
    phoneCtrl.dispose();
    expCtrl.dispose();
    locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _fillLocation() async {
    setState(() => locationLoading = true);
    try {
      final loc = await LocationService.getCurrentLocation();
      if (!mounted) return;
      setState(() {
        locationCtrl.text = loc["place"] ?? "";
        latitude = loc["lat"]?.toString();
        longitude = loc["lng"]?.toString();
      });
    } catch (_) {
      if (!mounted) return;
      OfflineHandler.showErrorSnackBar(
        context,
        Exception("Unable to fetch location"),
      );
    } finally {
      if (mounted) {
        setState(() => locationLoading = false);
      }
    }
  }

  Future<void> submit() async {
    FocusScope.of(context).unfocus();

    if (_errorMsg != null) {
      setState(() => _errorMsg = null);
    }

    if (!_formKey.currentState!.validate()) {
      setState(() => _errorMsg = "Please correct the highlighted fields");
      return;
    }

    if (availabilityOption == "selected_days" && selectedDays.isEmpty) {
      setState(() => _errorMsg = "Select at least one working day");
      return;
    }

    setState(() => loading = true);

    try {
      final roleValue = selectedRole == "Other"
          ? roleCtrl.text.trim()
          : selectedRole;
      final exp = int.parse(expCtrl.text.trim());
      final phone = phoneCtrl.text.trim();

      if (widget.workerToEdit != null) {
        await WorkerService.updateWorker(
          workerId: widget.workerToEdit!.id,
          firstName: firstNameCtrl.text.trim(),
          lastName: lastNameCtrl.text.trim(),
          role: roleValue,
          phone: phone,
          experience: exp,
          location: locationCtrl.text.trim(),
          latitude: latitude,
          longitude: longitude,
          userEmail: UserSession.email ?? '',
          availabilityType: availabilityOption,
          availableDays: availabilityOption == "selected_days"
              ? selectedDays.join(',')
              : null,
        );
      } else {
        await WorkerService.createWorker(
          firstName: firstNameCtrl.text.trim(),
          lastName: lastNameCtrl.text.trim(),
          role: roleValue,
          phone: phone,
          experience: exp,
          location: locationCtrl.text.trim(),
          latitude: latitude,
          longitude: longitude,
          userEmail: UserSession.email ?? '',
          availabilityType: availabilityOption,
          availableDays: availabilityOption == "selected_days"
              ? selectedDays.join(',')
              : null,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(
            SnackBar(
              content: Text(
                widget.workerToEdit != null
                    ? "Worker updated successfully."
                    : "Worker will be posted after admin approval",
              ),
            ),
          )
          .closed
          .then((_) {
            if (mounted) {
              Navigator.pop(context, true);
            }
          });
    } catch (e) {
      setState(() {
        loading = false;
        _errorMsg =
            e.toString().contains('internet') ||
                e.toString().contains('NoInternetException')
            ? "No internet connection. Tap retry."
            : "Error: ${e.toString()}";
      });
      return;
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  void _clearErrorAndRetry() {
    setState(() => _errorMsg = null);
    submit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Worker Profile"),
        backgroundColor: kPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              _buildSection(
                "Personal Information",
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _styledTextField(
                            firstNameCtrl,
                            "First Name",
                            icon: Icons.person_outline,
                            validator: (value) =>
                                _validateName(value, "First name"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _styledTextField(
                            lastNameCtrl,
                            "Last Name",
                            icon: Icons.person_outline,
                            validator: (value) =>
                                _validateName(value, "Last name"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _styledTextField(
                      phoneCtrl,
                      "Phone Number",
                      inputType: TextInputType.phone,
                      icon: Icons.phone_outlined,
                      validator: _validatePhone,
                    ),
                  ],
                ),
              ),
              _buildSection(
                "Professional Details",
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: const InputDecoration(
                          labelText: "Role / Profession",
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.work_outline,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ),
                        items: roles
                            .map((role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            selectedRole = value;
                            if (selectedRole != "Other") roleCtrl.clear();
                          });
                        },
                      ),
                    ),
                    if (selectedRole == "Other") ...[
                      const SizedBox(height: 12),
                      _styledTextField(
                        roleCtrl,
                        "Enter your role",
                        icon: Icons.edit,
                        validator: _validateOtherRole,
                      ),
                    ],
                    const SizedBox(height: 12),
                    _styledTextField(
                      expCtrl,
                      "Experience (Years)",
                      inputType: TextInputType.number,
                      icon: Icons.timeline,
                      validator: _validateExperience,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _styledTextField(
                            locationCtrl,
                            "City / Location",
                            icon: Icons.location_on_outlined,
                            validator: _validateLocation,
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: locationLoading ? null : _fillLocation,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 54,
                            width: 54,
                            decoration: BoxDecoration(
                              color: kPrimary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: kPrimary),
                            ),
                            child: Center(
                              child: locationLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.my_location,
                                      color: kPrimary,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildSection(
                "Availability",
                Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text("Available every day"),
                      value: "everyday",
                      groupValue: availabilityOption,
                      activeColor: kPrimary,
                      onChanged: (value) {
                        setState(() {
                          availabilityOption = value ?? "everyday";
                          selectedDays.clear();
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text("Available on selected days"),
                      value: "selected_days",
                      groupValue: availabilityOption,
                      activeColor: kPrimary,
                      onChanged: (value) {
                        setState(() {
                          availabilityOption = value ?? "selected_days";
                        });
                      },
                    ),
                    if (availabilityOption == "selected_days")
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 8,
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: weekDays.map((day) {
                            final selected = selectedDays.contains(day);
                            return FilterChip(
                              label: Text(day),
                              selected: selected,
                              selectedColor: kPrimary.withValues(alpha: 0.2),
                              labelStyle: TextStyle(
                                color: selected ? kPrimary : Colors.black87,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              onSelected: (value) {
                                setState(() {
                                  if (value) {
                                    selectedDays.add(day);
                                  } else {
                                    selectedDays.remove(day);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    RadioListTile<String>(
                      title: const Text("Not available currently"),
                      value: "not_available",
                      groupValue: availabilityOption,
                      activeColor: kPrimary,
                      onChanged: (value) {
                        setState(() {
                          availabilityOption = value ?? "not_available";
                          selectedDays.clear();
                        });
                      },
                    ),
                  ],
                ),
              ),
              if (_errorMsg != null)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: const Border(
                      left: BorderSide(color: Colors.orange, width: 4),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.wifi_off, color: Colors.orange.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMsg!,
                              style: const TextStyle(color: Colors.deepOrange),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _clearErrorAndRetry,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Retry"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading
                      ? null
                      : (_errorMsg != null ? _clearErrorAndRetry : submit),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.workerToEdit != null
                              ? "Update Worker"
                              : "Save Worker",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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

  String? _validateName(String? value, String fieldName) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return "$fieldName is required";
    }
    if (!RegExp(r"^[A-Za-z]+(?:[ '-][A-Za-z]+)*$").hasMatch(normalized)) {
      return "$fieldName can only contain letters";
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty || digits.length < 8 || digits.length > 15) {
      return "Enter a valid phone number";
    }
    return null;
  }

  String? _validateExperience(String? value) {
    final exp = int.tryParse(value?.trim() ?? '');
    if (exp == null) {
      return "Experience is required";
    }
    if (exp < 0 || exp > 60) {
      return "Experience must be between 0 and 60 years";
    }
    return null;
  }

  String? _validateLocation(String? value) {
    final location = value?.trim() ?? '';
    if (location.isEmpty) {
      return "Location is required";
    }
    if (location.length < 3) {
      return "Enter a more specific location";
    }
    return null;
  }

  String? _validateOtherRole(String? value) {
    if (selectedRole != "Other") return null;
    final role = value?.trim() ?? '';
    if (role.isEmpty) {
      return "Role is required";
    }
    if (role.length < 3) {
      return "Role must be at least 3 characters";
    }
    return null;
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

  Widget _styledTextField(
    TextEditingController controller,
    String label, {
    TextInputType inputType = TextInputType.text,
    IconData? icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      textCapitalization: inputType == TextInputType.number
          ? TextCapitalization.none
          : TextCapitalization.words,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null
            ? Icon(icon, size: 20, color: Colors.grey)
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: kPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }
}
