import 'package:flutter/material.dart';

class PostJobScreen extends StatelessWidget {
  const PostJobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post a Job")),
      body: const Center(
        child: Text(
          "Post Job Screen (Coming Soon)",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
