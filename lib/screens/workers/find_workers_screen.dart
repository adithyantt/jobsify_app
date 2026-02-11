import 'package:flutter/material.dart';
import '../../models/worker_model.dart';
import '../../services/worker_service.dart';
import '../../services/location_service.dart';
import 'worker_detail_screen.dart';
import 'add_worker_screen.dart';

/// 🎨 COLORS
const Color kRed = Color(0xFFFF1E2D);
const Color kBlue = Color(0xFF6B7280);
const Color kYellow = Color(0xFFFFC107);
const Color kGreen = Color(0xFF16A34A);
const Color kLightBlue = Color(0xFF87CEEB);

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
  bool locationLoaded = false;
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
      setState(() {
        locationStatus = loc["place"];
        locationLoaded = true;
      });
      await _loadWorkers();
    } catch (_) {
      setState(() {
        locationStatus = "Location permission required";
        locationLoaded = false;
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
        backgroundColor: kLightBlue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Find Workers"),
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
      body: CustomScrollView(
        slivers: [
          /// 🔵 HEADER
          SliverToBoxAdapter(
            child: Container(
              color: kBlue,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        locationLoaded
                            ? "Workers near you"
                            : "Location not available",
                        style: const TextStyle(color: Colors.white),
                      ),
                      if (!locationLoaded) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 16,
                          ),
                          onPressed: _initEverything,
                          tooltip: 'Retry location',
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: kYellow, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        searchQuery = value.toLowerCase();
                        _applyFilters();
                        setState(() {});
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.white),
                        hintText: "Search workers...",
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// 📊 WORKERS COUNT MESSAGE
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "${allWorkers.length} workers available",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          /// 🟠 CATEGORY CHIPS
          SliverToBoxAdapter(
            child: SizedBox(
              height: 56,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (_, i) {
                  final c = categories[i];
                  final selected = c == selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: ChoiceChip(
                      label: Text(c),
                      selected: selected,
                      selectedColor: kRed,
                      labelStyle: TextStyle(
                        color: selected
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                      onSelected: (_) {
                        selectedCategory = c;
                        _applyFilters();
                        setState(() {});
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          /// 🧾 WORKER LIST
          if (isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (hasError)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text("Failed to load workers")),
              ),
            )
          else if (visibleWorkers.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    "No workers found",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _workerCard(visibleWorkers[i]),
                childCount: visibleWorkers.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _workerCard(Worker worker) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _tag(worker.role, kRed),
              if (worker.isVerified) _tag("Verified", kGreen),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            worker.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${worker.experience} years experience • ${worker.role}",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium!.color?.withValues(alpha: 153),
            ),
          ),
          const SizedBox(height: 10),
          _iconText(Icons.location_on, worker.location),
          _iconText(Icons.work, "${worker.experience} years"),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kRed),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WorkerDetailScreen(worker: worker),
                  ),
                );
              },
              child: const Text("View Details"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: kRed),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11)),
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
