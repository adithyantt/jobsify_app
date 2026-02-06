import 'package:flutter/material.dart';
import '../../models/worker_model.dart';
import '../../services/worker_service.dart';
import '../../services/location_service.dart';
import 'worker_detail_screen.dart';
import 'add_worker_screen.dart';

class FindWorkersScreen extends StatefulWidget {
  const FindWorkersScreen({super.key});
  static const Color primaryColor = Color(0xFF1B0C6D);
  static const Color kGreen = Color(0xFF10B981);

  @override
  State<FindWorkersScreen> createState() => _FindWorkersScreenState();
}

class _FindWorkersScreenState extends State<FindWorkersScreen> {
  List<Worker> allWorkers = [];
  List<Worker> visibleWorkers = [];
  List<String> categories = ["All"];

  bool isLoading = true;
  bool hasError = false;

  String selectedCategory = "All";
  String searchQuery = "";

  double? userLat;
  double? userLng;
  String locationStatus = "Detecting location...";
  bool sortByDistance = true;

  @override
  void initState() {
    super.initState();
    _initEverything();
  }

  Future<void> _initEverything() async {
    try {
      final loc = await LocationService.getCurrentLocation();
      userLat = loc["lat"];
      userLng = loc["lng"];
      setState(() => locationStatus = loc["place"]);
      await _loadWorkers();
    } catch (_) {
      setState(() {
        locationStatus = "Location permission required";
        isLoading = false;
      });
    }
  }

  Future<void> _loadWorkers() async {
    try {
      final data = await WorkerService.fetchWorkers();

      // 🔐 SHOW ONLY VERIFIED WORKERS
      final verifiedWorkers = data.where((w) => w.isVerified).toList();

      final roles = verifiedWorkers
          .map((w) => w.role)
          .where((r) => r.isNotEmpty)
          .toSet();

      setState(() {
        allWorkers = verifiedWorkers;
        categories = ["All", ...roles.toList()..sort()];
        _applyFilters();
        isLoading = false;
        hasError = false;
      });
    } catch (_) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

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

    if (sortByDistance && userLat != null && userLng != null) {
      filtered.sort((a, b) {
        final ad = _distanceToWorker(a);
        final bd = _distanceToWorker(b);
        if (ad == null && bd == null) return 0;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return ad.compareTo(bd);
      });
    }
    setState(() {
      visibleWorkers = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: FindWorkersScreen.kGreen,
        foregroundColor: Colors.white,
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

  Widget _locationBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: Theme.of(context).iconTheme.color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              locationStatus,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        onChanged: (value) {
          searchQuery = value.toLowerCase();
          _applyFilters();
          setState(() {});
        },
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color),
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
          hintText: "Search by name or skill...",
          hintStyle: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium!.color,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _categoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          final cat = categories[index];
          final selected = cat == selectedCategory;
          return GestureDetector(
            onTap: () {
              selectedCategory = cat;
              _applyFilters();
              setState(() {});
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
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              worker.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),
            Text(
              worker.role,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium!.color,
              ),
            ),
            Text(
              "${worker.experience} years • ${worker.location}",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium!.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double? _distanceToWorker(Worker worker) {
    if (userLat == null || userLng == null) return null;
    final lat = double.tryParse(worker.latitude ?? "");
    final lng = double.tryParse(worker.longitude ?? "");
    if (lat == null || lng == null) return null;
    return LocationService.distanceKm(userLat!, userLng!, lat, lng);
  }
}
