import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/job_model.dart';
import '../../services/job_service.dart';
import '../../services/location_service.dart';
import '../../utils/distance_utils.dart';
import '../../utils/salary_utils.dart';
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

  /// 🔍 FILTERS
  int? minSalary;
  int? maxSalary;
  List<String> selectedLocations = [];
  bool? isUrgent;
  String sortBy = 'distance'; // 'distance', 'salary', 'date'

  /// 📍 AVAILABLE LOCATIONS (extracted from jobs dynamically)
  List<String> availableLocations = [];

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
    _loadSavedFilters();
  }

  /// 💾 LOAD SAVED FILTERS
  Future<void> _loadSavedFilters() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      minSalary = prefs.getInt('filter_min_salary');
      maxSalary = prefs.getInt('filter_max_salary');
      isUrgent = prefs.getBool('filter_is_urgent');
      sortBy = prefs.getString('filter_sort_by') ?? 'distance';
      selectedLocations = prefs.getStringList('filter_locations') ?? [];
    });
  }

  /// 💾 SAVE FILTERS
  Future<void> _saveFilters() async {
    final prefs = await SharedPreferences.getInstance();
    if (minSalary != null) {
      await prefs.setInt('filter_min_salary', minSalary!);
    } else {
      await prefs.remove('filter_min_salary');
    }
    if (maxSalary != null) {
      await prefs.setInt('filter_max_salary', maxSalary!);
    } else {
      await prefs.remove('filter_max_salary');
    }
    if (isUrgent != null) {
      await prefs.setBool('filter_is_urgent', isUrgent!);
    } else {
      await prefs.remove('filter_is_urgent');
    }
    await prefs.setString('filter_sort_by', sortBy);
    await prefs.setStringList('filter_locations', selectedLocations);
  }

  /// 🧹 CLEAR ALL FILTERS
  void _clearFilters() {
    setState(() {
      minSalary = null;
      maxSalary = null;
      isUrgent = null;
      selectedLocations = [];
      sortBy = 'distance';
    });
    _saveFilters();
  }

  /// 🔢 GET ACTIVE FILTER COUNT
  int get _activeFilterCount {
    int count = 0;
    if (minSalary != null) count++;
    if (maxSalary != null) count++;
    if (isUrgent != null) count++;
    if (selectedLocations.isNotEmpty) count++;
    if (sortBy != 'distance') count++;
    return count;
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
    } catch (e) {
      if (!mounted) return;
      setState(() => locationLoaded = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location error: ${e.toString()}'),
          action: SnackBarAction(label: 'Retry', onPressed: _loadUserLocation),
        ),
      );
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
      appBar: AppBar(
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Browse Jobs"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PostJobScreen()),
              );
              if (result == true) _refreshJobs();
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 📍 LOCATION INDICATOR
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
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
                      if (!locationLoaded) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 16,
                          ),
                          onPressed: _loadUserLocation,
                          tooltip: 'Retry location',
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  /// 🔍 SEARCH BAR
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
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  /// 🔄 SORT & FILTER ROW
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// 🔄 SORT DROPDOWN
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: sortBy,
                            dropdownColor: kBlue,
                            icon: const Icon(
                              Icons.sort,
                              color: Colors.white,
                              size: 20,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'distance',
                                child: Text('Sort by Distance'),
                              ),
                              DropdownMenuItem(
                                value: 'salary_high',
                                child: Text('Salary: High to Low'),
                              ),
                              DropdownMenuItem(
                                value: 'salary_low',
                                child: Text('Salary: Low to High'),
                              ),
                              DropdownMenuItem(
                                value: 'date',
                                child: Text('Newest First'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  sortBy = value;
                                });
                                _saveFilters();
                              }
                            },
                          ),
                        ),

                        /// 🎯 FILTER BUTTON WITH BADGE
                        Stack(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.tune,
                                color: _activeFilterCount > 0
                                    ? kYellow
                                    : Colors.white,
                                size: 24,
                              ),
                              onPressed: _showFilterBottomSheet,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            if (_activeFilterCount > 0)
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: kRed,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$_activeFilterCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
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

              /// 🏙️ EXTRACT UNIQUE LOCATIONS
              availableLocations =
                  jobs
                      .map((j) => j.location.split(',').first.trim())
                      .toSet()
                      .toList()
                    ..sort();

              /// 📊 APPLY SORTING
              if (sortBy == 'distance' &&
                  locationLoaded &&
                  userLat != null &&
                  userLng != null) {
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
              } else if (sortBy == 'salary_high') {
                jobs.sort(
                  (a, b) => _extractMaxSalary(
                    b.salary,
                  ).compareTo(_extractMaxSalary(a.salary)),
                );
              } else if (sortBy == 'salary_low') {
                jobs.sort(
                  (a, b) => _extractMinSalary(
                    a.salary,
                  ).compareTo(_extractMinSalary(b.salary)),
                );
              } else if (sortBy == 'date') {
                jobs.sort((a, b) => b.id.compareTo(a.id));
              }

              final filtered = jobs.where((job) {
                final categoryMatch =
                    selectedCategory == "All" ||
                    job.category == selectedCategory;
                final searchMatch = job.title.toLowerCase().contains(
                  _searchCtrl.text.toLowerCase(),
                );
                final salaryMatch = SalaryUtils.isSalaryInRange(
                  job.salary,
                  minSalary,
                  maxSalary,
                );
                final locationMatch =
                    selectedLocations.isEmpty ||
                    selectedLocations.any(
                      (loc) => job.location.toLowerCase().contains(
                        loc.toLowerCase(),
                      ),
                    );
                final urgencyMatch = isUrgent == null || job.urgent == isUrgent;

                return categoryMatch &&
                    searchMatch &&
                    salaryMatch &&
                    locationMatch &&
                    urgencyMatch;
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
          if (job.salary != null && job.salary!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                job.salary!,
                style: const TextStyle(color: Colors.green),
              ),
            ),
          const SizedBox(height: 8),
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

  /// 🎯 SHOW MODERN FILTER BOTTOM SHEET
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                /// 🏷️ HEADER
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: kGreen,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Jobs',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                minSalary = null;
                                maxSalary = null;
                                isUrgent = null;
                                selectedLocations = [];
                              });
                            },
                            child: const Text(
                              'Clear All',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                /// 📋 FILTER OPTIONS
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      /// 💰 SALARY RANGE
                      const Text(
                        'Salary Range (₹)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Min',
                                prefixText: '₹',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              controller: TextEditingController(
                                text: minSalary?.toString(),
                              ),
                              onChanged: (value) {
                                minSalary = int.tryParse(value);
                              },
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('—'),
                          ),
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Max',
                                prefixText: '₹',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              controller: TextEditingController(
                                text: maxSalary?.toString(),
                              ),
                              onChanged: (value) {
                                maxSalary = int.tryParse(value);
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      /// 🚨 URGENCY FILTER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Urgent Jobs Only',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Switch(
                            value: isUrgent ?? false,
                            activeColor: kRed,
                            onChanged: (value) {
                              setModalState(() {
                                isUrgent = value ? true : null;
                              });
                            },
                          ),
                        ],
                      ),
                      if (isUrgent != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              FilterChip(
                                label: const Text('Urgent Only'),
                                selected: isUrgent == true,
                                selectedColor: kRed.withValues(alpha: 0.2),
                                checkmarkColor: kRed,
                                onSelected: (selected) {
                                  setModalState(() {
                                    isUrgent = selected ? true : null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),

                      /// 📍 LOCATION FILTER
                      if (availableLocations.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Locations',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setModalState(() {
                                  if (selectedLocations.length ==
                                      availableLocations.length) {
                                    selectedLocations = [];
                                  } else {
                                    selectedLocations = List.from(
                                      availableLocations,
                                    );
                                  }
                                });
                              },
                              child: Text(
                                selectedLocations.length ==
                                        availableLocations.length
                                    ? 'Deselect All'
                                    : 'Select All',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: availableLocations.map((location) {
                            final isSelected = selectedLocations.contains(
                              location,
                            );
                            return FilterChip(
                              label: Text(location),
                              selected: isSelected,
                              selectedColor: kBlue.withValues(alpha: 0.2),
                              checkmarkColor: kBlue,
                              onSelected: (selected) {
                                setModalState(() {
                                  if (selected) {
                                    selectedLocations.add(location);
                                  } else {
                                    selectedLocations.remove(location);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),

                /// ✅ APPLY BUTTON
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setState(() {});
                          _saveFilters();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 💵 EXTRACT MIN SALARY FOR SORTING
  int _extractMinSalary(String? salary) {
    if (salary == null || salary.isEmpty) return 0;
    final match = RegExp(r'(\d+)').firstMatch(salary.replaceAll(',', ''));
    return match != null ? int.parse(match.group(1)!) : 0;
  }

  /// 💵 EXTRACT MAX SALARY FOR SORTING
  int _extractMaxSalary(String? salary) {
    if (salary == null || salary.isEmpty) return 0;
    final matches = RegExp(
      r'(\d+)',
    ).allMatches(salary.replaceAll(',', '')).toList();
    return matches.isNotEmpty
        ? int.parse(matches.last.group(1)!)
        : _extractMinSalary(salary);
  }
}
