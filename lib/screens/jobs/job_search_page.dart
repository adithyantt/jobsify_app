import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/location_service.dart';
import 'jobs_list_screen.dart';

const Color kPrimary = Color.fromARGB(255, 55, 25, 226);
const String kHomeSelectedLocationKey = 'home_selected_location';

class JobSearchPage extends StatefulWidget {
  const JobSearchPage({super.key});

  @override
  State<JobSearchPage> createState() => _JobSearchPageState();
}

class _JobSearchPageState extends State<JobSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedLocation = "Your Location";

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(kHomeSelectedLocationKey);
    if (mounted && saved != null && saved.trim().isNotEmpty) {
      setState(() => _selectedLocation = saved.trim());
    }
  }

  final List<String> allCategories = [
    "Plumber",
    "Painter",
    "Driver",
    "Electrician",
    "Carpenter",
    "Mason",
    "Cleaner",
    "Gardener",
    "Cook",
    "Security Guard",
    "Mechanic",
    "Other",
  ];

  List<String> get filteredCategories {
    if (_searchQuery.isEmpty) return allCategories;
    return allCategories
        .where(
          (name) => name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 55, 25, 224),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Search Services near $_selectedLocation"),
      ),
      body: Column(
        children: [
          // Location row
          Container(
            color: kPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GestureDetector(
              onTap: () async {
                final loc = await LocationService.getCurrentLocation();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString(
                  kHomeSelectedLocationKey,
                  loc['place'] ?? 'Your Location',
                );
                if (mounted)
                  setState(
                    () => _selectedLocation = loc['place'] ?? 'Your Location',
                  );
              },
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedLocation,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: Colors.white),
                ],
              ),
            ),
          ),

          /// 🔍 SEARCH FIELD
          Container(
            color: const Color.fromARGB(255, 56, 25, 232),
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              autofocus: true,
              decoration: InputDecoration(
                prefixIcon: null,
                hintText: "Search services near $_selectedLocation...",
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          /// 📂 CATEGORIES HORIZONTAL ROW
          Expanded(
            child: filteredCategories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No services found near $_selectedLocation",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredCategories.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final name = filteredCategories[index];
                      return SizedBox(
                        width: double.infinity,
                        child: _categoryChip(name),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(String name) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => JobsListScreen(category: name)),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(31, 240, 238, 238),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
