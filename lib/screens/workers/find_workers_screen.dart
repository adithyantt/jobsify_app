import 'package:flutter/material.dart';
import '../../models/worker_model.dart';
import '../../services/worker_service.dart';
import '../../services/location_service.dart';
import 'worker_detail_screeen.dart';
import 'add_worker_screen.dart';

class FindWorkersScreen extends StatefulWidget {
  const FindWorkersScreen({super.key});

  static const Color primaryColor = Color(0xFF1B0C6D);

  @override
  State<FindWorkersScreen> createState() => _FindWorkersScreenState();
}

class _FindWorkersScreenState extends State<FindWorkersScreen> {
  /// DATA
  List<Worker> allWorkers = [];
  List<Worker> visibleWorkers = [];

  /// STATE
  bool isLoading = true;
  bool hasError = false;

  /// FILTERS
  String selectedCategory = "All";
  String searchQuery = "";

  /// LOCATION
  double? userLat;
  double? userLng;
  String locationStatus = "Detecting location...";

  @override
  void initState() {
    super.initState();
    _initEverything();
  }

  /// 🔥 LOCATION + WORKERS
  Future<void> _initEverything() async {
    try {
      final loc = await LocationService.getCurrentLocation();

      userLat = loc["lat"];
      userLng = loc["lng"];

      setState(() {
        locationStatus = loc["place"]; // village / town / city
      });

      await _loadWorkers();
    } catch (e) {
      setState(() {
        locationStatus = "Location permission required";
        isLoading = false;
      });
    }
  }

  /// 🔥 LOAD FROM BACKEND
  Future<void> _loadWorkers() async {
    try {
      final data = await WorkerService.fetchWorkers();

      setState(() {
        allWorkers = data;
        _applyFilters();
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  /// 🔥 FILTER LOGIC
  void _applyFilters() {
    List<Worker> filtered = allWorkers;

    if (selectedCategory != "All") {
      filtered = filtered.where((w) => w.role == selectedCategory).toList();
    }

    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((w) {
        return w.name.toLowerCase().contains(searchQuery) ||
            w.role.toLowerCase().contains(searchQuery);
      }).toList();
    }

    setState(() {
      visibleWorkers = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: FindWorkersScreen.primaryColor,
        title: const Text("Jobsify"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddWorkerScreen()),
              );

              if (result == true) {
                setState(() => isLoading = true);
                await _loadWorkers();
              }
            },
          ),
        ],
      ),

      body: _buildBody(),
    );
  }

  /// 🧠 BODY STATE
  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return const Center(child: Text("Failed to load workers"));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _locationBar(),
          const SizedBox(height: 12),
          _searchBar(),
          const SizedBox(height: 16),
          _categoryChips(),
          const SizedBox(height: 16),
          Text(
            "${visibleWorkers.length} workers available",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          if (visibleWorkers.isEmpty)
            const Center(child: Text("No workers found"))
          else
            ...visibleWorkers.map(_workerCard),
        ],
      ),
    );
  }

  /// 📍 LOCATION BAR
  Widget _locationBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              locationStatus,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔍 SEARCH
  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        onChanged: (value) {
          searchQuery = value.toLowerCase();
          _applyFilters();
        },
        decoration: const InputDecoration(
          icon: Icon(Icons.search),
          hintText: "Search by name or skill...",
          border: InputBorder.none,
        ),
      ),
    );
  }

  /// 🧩 CATEGORY FILTER
  Widget _categoryChips() {
    final categories = ["All", "Plumber", "Painter", "Driver"];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final selected = cat == selectedCategory;

          return GestureDetector(
            onTap: () {
              selectedCategory = cat;
              _applyFilters();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? FindWorkersScreen.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: FindWorkersScreen.primaryColor),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : FindWorkersScreen.primaryColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 🧑 WORKER CARD
  Widget _workerCard(Worker worker) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WorkerDetailScreen(worker: worker)),
        );
      },
      child: Container(
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
                  backgroundColor: FindWorkersScreen.primaryColor,
                  child: Text(
                    worker.name[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        worker.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          _tag(worker.role, FindWorkersScreen.primaryColor),
                          const SizedBox(width: 6),
                          if (worker.isVerified) _tag("Verified", Colors.green),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text("⭐ ${worker.rating} (${worker.reviews} reviews)"),
            const SizedBox(height: 6),
            Text("${worker.experience} years • ${worker.location}"),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, color: color)),
    );
  }
}
