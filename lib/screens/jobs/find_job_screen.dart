import 'package:flutter/material.dart';
import '../../models/job_model.dart';
import '../../services/job_service.dart';
import '../../services/location_service.dart';
import '../../utils/distance_utils.dart';
import 'post_job_screen.dart';
import 'job_detail_screen.dart';

/// 🎨 COLORS
const Color kRed = Color(0xFFFF1E2D);
const Color kBlue = Color(0xFF6B7280);
const Color kYellow = Color(0xFFFFC107);
const Color kGreen = Color(0xFF16A34A);

class FindJobsScreen extends StatefulWidget {
  const FindJobsScreen({super.key});

  @override
  State<FindJobsScreen> createState() => _FindJobsScreenState();
}

class _FindJobsScreenState extends State<FindJobsScreen> {
  late Future<List<Job>> jobsFuture;

  /// 📍 USER LOCATION
  double? userLat;
  double? userLng;
  bool locationLoaded = false;

  String selectedCategory = "All";
  final TextEditingController _searchCtrl = TextEditingController();

  final List<String> categories = [
    "All",
    "Plumber",
    "Painter",
    "Driver",
    "Electrician",
    "Carpenter",
  ];

  @override
  void initState() {
    super.initState();
    jobsFuture = JobService.fetchJobs();
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    try {
      final loc = await LocationService.getCurrentLocation();
      if (!mounted) return;

      setState(() {
        userLat = loc['lat'];
        userLng = loc['lng'];
        locationLoaded = true;
      });
    } catch (_) {
      setState(() => locationLoaded = false);
    }
  }

  void _refreshJobs() {
    setState(() {
      jobsFuture = JobService.fetchJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          /// 🔵 HEADER
          SliverToBoxAdapter(
            child: Container(
              color: kBlue,
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Browse Jobs",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PostJobScreen(),
                            ),
                          );
                          if (result == true) _refreshJobs();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
                            ? "Jobs near you"
                            : "Location not available",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: kYellow, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.white),
                        hintText: "Search jobs...",
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
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
                      onSelected: (_) => setState(() => selectedCategory = c),
                    ),
                  );
                },
              ),
            ),
          ),

          /// 🧾 JOB LIST
          FutureBuilder<List<Job>>(
            future: jobsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(child: Text("Failed to load jobs")),
                  ),
                );
              }

              List<Job> jobs = snapshot.data ?? [];

              if (locationLoaded && userLat != null && userLng != null) {
                jobs.sort((a, b) {
                  if (a.latitude == null || a.longitude == null) return 1;
                  if (b.latitude == null || b.longitude == null) return -1;

                  final distA = DistanceUtils.calculateDistance(
                    userLat!,
                    userLng!,
                    double.parse(a.latitude!),
                    double.parse(a.longitude!),
                  );

                  final distB = DistanceUtils.calculateDistance(
                    userLat!,
                    userLng!,
                    double.parse(b.latitude!),
                    double.parse(b.longitude!),
                  );

                  return distA.compareTo(distB);
                });
              }

              final filtered = jobs.where((job) {
                final categoryMatch =
                    selectedCategory == "All" ||
                    job.category == selectedCategory;
                final searchMatch = job.title.toLowerCase().contains(
                  _searchCtrl.text.toLowerCase(),
                );
                return categoryMatch && searchMatch;
              }).toList();

              if (filtered.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        "No jobs found",
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _jobCard(filtered[i]),
                  childCount: filtered.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _jobCard(Job job) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [_tag(job.category, kRed), _tag("Verified", kGreen)]),
          const SizedBox(height: 8),
          Text(
            job.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            job.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium!.color?.withValues(alpha: 153),
            ),
          ),
          const SizedBox(height: 10),
          _iconText(Icons.location_on, job.location),
          _iconText(Icons.access_time, "Recently posted"),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kRed),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
                );
              },
              child: const Text("View Contact"),
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
}
