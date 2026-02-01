import 'package:flutter/material.dart';
import '../../services/worker_service.dart';

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
  Future<void> submit() async {
    if (nameCtrl.text.isEmpty ||
        roleCtrl.text.isEmpty ||
        phoneCtrl.text.isEmpty ||
        expCtrl.text.isEmpty ||
        locationCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("All fields are required")));
      return;
    }

    setState(() => loading = true);

    try {
      final success = await WorkerService.createWorker(
        name: nameCtrl.text.trim(),
        role: roleCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        experience: int.parse(expCtrl.text),
        location: locationCtrl.text.trim(),
      );

      if (success) {
        Navigator.pop(context, true); // ✅ refresh FindWorkersScreen
      } else {
        setState(() => loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to add worker")));
      }
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: roleCtrl,
              decoration: const InputDecoration(labelText: "Role"),
            ),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: "Phone"),
            ),
            TextField(
              controller: expCtrl,
              decoration: const InputDecoration(
                labelText: "Experience (years)",
              ),
            ),
            TextField(
              controller: locationCtrl,
              decoration: const InputDecoration(labelText: "Location"),
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
