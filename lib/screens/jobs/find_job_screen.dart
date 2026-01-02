import 'package:flutter/material.dart';

class FindJobsScreen extends StatelessWidget {
  const FindJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("Jobsify"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // later: post job bottom sheet
            },
          ),
        ],
      ),
      body: const Center(child: Text("Jobs list will come here")),
    );
  }
}
//this is the find job card file