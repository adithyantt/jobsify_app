import 'package:flutter/material.dart';
import '../../services/worker_service.dart';
import '../../services/location_service.dart';

class AddWorkerScreen extends StatefulWidget {
  const AddWorkerScreen({super.key});

  @override
  State<AddWorkerScreen> createState() => _AddWorkerScreenState();
}

class _AddWorkerScreenState extends State<AddWorkerScreen> {
  final nameCtrl = TextEditingController();
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

  /// 🔹 AVAILABILITY STATE
  String availabilityOption =
      "everyday"; // everyday | selected_days | not_available
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

  @override
  void dispose() {
    nameCtrl.dispose();
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
      setState(() {
        locationCtrl.text = loc["place"] ?? "";
        latitude = loc["lat"]?.toString();
        longitude = loc["lng"]?.toString();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Location error: $e")));
    } finally {
      if (mounted) {
        setState(() => locationLoading = false);
      }
    }
  }

  Future<void> submit() async {
    final roleValue = selectedRole == "Other"
        ? roleCtrl.text.trim()
        : selectedRole;

    if (nameCtrl.text.isEmpty ||
        roleValue.isEmpty ||
        phoneCtrl.text.isEmpty ||
        expCtrl.text.isEmpty ||
        locationCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("All fields are required")));
      return;
    }

    if (availabilityOption == "selected_days" && selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select at least one working day")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final exp = int.tryParse(expCtrl.text.trim());
      if (exp == null || exp < 0) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter a valid experience")),
        );
        return;
      }

      final phone = phoneCtrl.text.trim();
      final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
      if (digitsOnly.length < 8) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter a valid phone number")),
        );
        return;
      }

      await WorkerService.createWorker(
        name: nameCtrl.text.trim(),
        role: roleValue,
        phone: phone,
        experience: exp,
        location: locationCtrl.text.trim(),
        latitude: latitude,
        longitude: longitude,
      );

      Navigator.pop(context, true);
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Worker")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Name"),
            ),

            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: const InputDecoration(labelText: "Role"),
              items: roles
                  .map(
                    (role) => DropdownMenuItem(value: role, child: Text(role)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  selectedRole = value;
                  if (selectedRole != "Other") roleCtrl.clear();
                });
              },
            ),

            if (selectedRole == "Other")
              TextField(
                controller: roleCtrl,
                decoration: const InputDecoration(labelText: "Custom role"),
              ),

            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Phone"),
            ),

            TextField(
              controller: expCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Experience (years)",
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: locationCtrl,
                    decoration: const InputDecoration(labelText: "Location"),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: locationLoading ? null : _fillLocation,
                  child: locationLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Use GPS"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// 🔹 AVAILABILITY UI
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Availability",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            RadioListTile(
              title: const Text("Available every day"),
              value: "everyday",
              groupValue: availabilityOption,
              onChanged: (val) {
                setState(() {
                  availabilityOption = val ?? "everyday";
                  selectedDays.clear();
                });
              },
            ),

            RadioListTile(
              title: const Text("Available on selected days"),
              value: "selected_days",
              groupValue: availabilityOption,
              onChanged: (val) {
                setState(() {
                  availabilityOption = val ?? "selected_days";
                });
              },
            ),

            if (availabilityOption == "selected_days")
              Wrap(
                spacing: 8,
                children: weekDays.map((day) {
                  final selected = selectedDays.contains(day);
                  return FilterChip(
                    label: Text(day),
                    selected: selected,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          selectedDays.add(day);
                        } else {
                          selectedDays.remove(day);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

            RadioListTile(
              title: const Text("Not available currently"),
              value: "not_available",
              groupValue: availabilityOption,
              onChanged: (val) {
                setState(() {
                  availabilityOption = val!;
                  selectedDays.clear();
                });
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : submit,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save Worker"),
            ),
          ],
        ),
      ),
    );
  }
}
