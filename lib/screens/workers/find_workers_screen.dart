import 'package:flutter/material.dart';
import '../jobs/post_job_screen.dart';

class FindWorkersScreen extends StatelessWidget {
  FindWorkersScreen({super.key});

  static const Color primaryColor = Color(0xFF1B0C6D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Jobsify"),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PostJobScreen()),
                );
              },
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _searchBar(),
            const SizedBox(height: 16),
            _categoryChips(),
            const SizedBox(height: 16),
            _header(),
            const SizedBox(height: 16),

            _workerCard(
              name: "Ramesh Kumar",
              role: "Plumber",
              rating: "4.5",
              reviews: "127",
              experience: "8 years",
              location: "Sector 12, Delhi",
            ),
            _workerCard(
              name: "Vijay Singh",
              role: "Painter",
              rating: "4.8",
              reviews: "203",
              experience: "6 years",
              location: "Lajpat Nagar, Delhi",
            ),
          ],
        ),
      ),
    );
  }

  // 🔍 Search bar
  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search),
          hintText: "Search workers by name or skill...",
          border: InputBorder.none,
        ),
      ),
    );
  }

  // 🧩 Category chips
  Widget _categoryChips() {
    final categories = ["All", "Plumber", "Painter", "Driver"];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = index == 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryColor),
            ),
            child: Text(
              categories[index],
              style: TextStyle(
                color: isSelected ? Colors.white : primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }

  // 📌 Header
  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          "6 workers available",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        Row(
          children: [
            Icon(Icons.filter_list, size: 18),
            SizedBox(width: 4),
            Text("Filter"),
          ],
        ),
      ],
    );
  }

  // 🧑 Worker card
  Widget _workerCard({
    required String name,
    required String role,
    required String rating,
    required String reviews,
    required String experience,
    required String location,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: primaryColor,
                child: Text(
                  name[0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        _tag(role, primaryColor),
                        const SizedBox(width: 6),
                        _tag("Available Now", Colors.green),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.verified, color: Colors.green),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.star, size: 16, color: Colors.orange),
              const SizedBox(width: 4),
              Text("$rating ($reviews reviews)"),
            ],
          ),

          const SizedBox(height: 8),
          Text("Expert in all $role work. Fast and reliable service."),

          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.work, size: 16),
              const SizedBox(width: 4),
              Text(experience),
              const Spacer(),
              const Icon(Icons.location_on, size: 16),
              const SizedBox(width: 4),
              Text(location),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {},
              child: const Text("Get Contact"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
