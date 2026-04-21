import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/job_model.dart';
import '../../services/job_service.dart';
import '../../services/location_service.dart';
import '../../utils/distance_utils.dart';
import '../../utils/offline_handler.dart';
import 'post_job_screen.dart';
import 'job_detail_screen.dart';

/// 🎨 COLORS
const Color kBlue = Color(0xFF6B7280);
const Color kHeaderGrey = Color(0xFF6B7280);
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
  String sortBy = 'distance';

  /// 🎯 FILTER TEXT CONTROLLERS
  final TextEditingController _minSalaryController = TextEditingController();
  final TextEditingController _maxSalaryController = TextEditingController();

  /// 📍 AVAILABLE LOCATIONS
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
    if (mounted) {
      setState(() {
        minSalary = prefs.getInt('filter_min_salary');
        maxSalary = prefs.getInt('filter_max_salary');
        isUrgent = prefs.getBool('filter_is_urgent');
        sortBy = prefs.getString('filter_sort_by') ?? 'distance';
        selectedLocations = prefs.getStringList('filter_locations') ?? [];
      });
    }
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

  /// 🔢 ACTIVE FILTER COUNT
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
      if (mounted) {
        setState(() {
          userLat = loc['lat'] as double?;
          userLng = loc['lng'] as double?;
          locationLoaded = true;
        });
      }
    } catch (e) {
      if (mounted) setState(() => locationLoaded = false);
    }
  }

  Future<void> _refreshJobs() async {
    if (mounted) {
      setState(() {
        jobsFuture = JobService.fetchJobs(
          category: selectedCategory == "All" ? null : selectedCategory,
          location: selectedLocations.join(', '),
          urgent: isUrgent,
          minSalary: minSalary?.toDouble(),
          maxSalary: maxSalary?.toDouble(),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
              if (result == true) await _refreshJobs();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshJobs,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                color: kHeaderGrey,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              locationLoaded
                                  ? "Jobs near you"
                                  : "Location not available",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          if (!locationLoaded) ...[
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white24,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: _loadUserLocation,
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text(
                                'Retry',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: primary.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(color: kYellow),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white12,
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          hintText: "Search jobs...",
                          hintStyle: const TextStyle(color: kYellow),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: sortBy,
                              dropdownColor: kHeaderGrey,
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
                                if (value != null && mounted) {
                                  setState(() => sortBy = value);
                                  _saveFilters();
                                }
                              },
                            ),
                          ),
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
                                      color: primary,
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
                        selectedColor: primary,
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
            FutureBuilder<List<Job>>(
              future: jobsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    OfflineHandler.showErrorSnackBar(context, snapshot.error!);
                  });
                  return SliverFillRemaining(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off, size: 64, color: Colors.orange),
                          const SizedBox(height: 16),
                          const Text(
                            'Failed to load jobs',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                            onPressed: _refreshJobs,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final jobs = snapshot.data ?? [];
                availableLocations =
                    jobs
                        .map((j) => j.location.split(',').first.trim())
                        .toSet()
                        .toList()
                      ..sort();
                final filteredJobs = jobs.where((job) {
                  final searchMatch =
                      _searchCtrl.text.isEmpty ||
                      job.title.toLowerCase().contains(
                        _searchCtrl.text.toLowerCase(),
                      );
                  final urgencyMatch =
                      isUrgent == null || job.urgent == isUrgent;
                  return searchMatch && urgencyMatch;
                }).toList();

                /// SORT
                if (sortBy == 'distance' &&
                    locationLoaded &&
                    userLat != null &&
                    userLng != null) {
                  filteredJobs.sort((a, b) {
                    if (a.latitude == null || a.longitude == null) return 1;
                    if (b.latitude == null || b.longitude == null) return -1;
                    final distA = DistanceUtils.calculateDistance(
                      userLat!,
                      userLng!,
                      double.parse(a.latitude!),
                      double.parse(b.longitude!),
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
                  filteredJobs.sort(
                    (a, b) => _extractMaxSalary(
                      b.salary,
                    ).compareTo(_extractMaxSalary(a.salary)),
                  );
                } else if (sortBy == 'salary_low') {
                  filteredJobs.sort(
                    (a, b) => _extractMinSalary(
                      a.salary,
                    ).compareTo(_extractMinSalary(b.salary)),
                  );
                } else if (sortBy == 'date') {
                  filteredJobs.sort((a, b) => b.id.compareTo(a.id));
                }
                if (filteredJobs.isEmpty) {
                  return SliverFillRemaining(
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
                    (_, i) => _jobCard(filteredJobs[i]),
                    childCount: filteredJobs.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _jobCard(Job job) {
    final primary = Theme.of(context).primaryColor;
    final rawSalary = job.salary?.trim();
    final showSalary = rawSalary != null && rawSalary.isNotEmpty;
    final salaryText = _salaryLabel(job);

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
          Row(
            children: [
              _tag(job.category, primary),
              if (job.verified) _tag("Verified", kGreen),
            ],
          ),
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
              ).textTheme.bodyMedium!.color!.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 10),
          if (showSalary)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                salaryText,
                style: TextStyle(
                  color: salaryText == "Salary not disclosed"
                      ? Colors.grey
                      : Colors.green,
                ),
              ),
            ),
          if (!showSalary)
            _iconText(Icons.payments_outlined, "Salary not disclosed"),
          const SizedBox(height: 8),
          _iconText(Icons.location_on, job.location),
          _iconText(Icons.access_time, _postedLabel(job)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primary),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
              ),
              child: const Text("View Contact"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconText(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        Icon(icon, size: 14, color: Theme.of(context).primaryColor),
        const SizedBox(width: 4),
        Expanded(child: Text(text)),
      ],
    ),
  );

  Widget _tag(String text, Color color) => Container(
    margin: const EdgeInsets.only(right: 6),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(text, style: TextStyle(color: color, fontSize: 11)),
  );

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
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
                          onPressed: () => setState(() {
                            minSalary = null;
                            maxSalary = null;
                            isUrgent = null;
                            selectedLocations = [];
                          }),
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
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
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
                              prefixText: '₹ ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            controller: _minSalaryController,
                            onChanged: (value) =>
                                minSalary = int.tryParse(value),
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
                              prefixText: '₹ ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            controller: _maxSalaryController,
                            onChanged: (value) =>
                                maxSalary = int.tryParse(value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
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
                          activeThumbColor: Theme.of(context).primaryColor,
                          onChanged: (value) =>
                              setState(() => isUrgent = value ? true : null),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
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
                            onPressed: () => setState(
                              () =>
                                  selectedLocations.length ==
                                      availableLocations.length
                                  ? selectedLocations = []
                                  : selectedLocations = List.from(
                                      availableLocations,
                                    ),
                            ),
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
                        children: availableLocations
                            .map(
                              (location) => FilterChip(
                                label: Text(location),
                                selected: selectedLocations.contains(location),
                                selectedColor: Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.2),
                                checkmarkColor: Theme.of(context).primaryColor,
                                onSelected: (selected) => setState(
                                  () => selected
                                      ? selectedLocations.add(location)
                                      : selectedLocations.remove(location),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
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
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        _saveFilters();
                        Navigator.pop(context);
                        _refreshJobs();
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
        ),
      ),
    );
  }

  /// 💵 IMPROVED SALARY PARSING
  (int, int) _parseSalaryRange(String? salary) {
    if (salary == null || salary.isEmpty) return (0, 0);
    String clean = salary.replaceAll(RegExp(r'[^0-9-]'), '');
    final numbers = RegExp(
      r'\d+',
    ).allMatches(clean).map((match) => int.parse(match.group(0)!)).toList();
    if (numbers.isEmpty) return (0, 0);
    if (numbers.length == 1) return (numbers.first, numbers.first);
    return (numbers.first, numbers.last);
  }

  int _extractMinSalary(String? salary) => _parseSalaryRange(salary).$1;
  int _extractMaxSalary(String? salary) => _parseSalaryRange(salary).$2;

  String _salaryLabel(Job job) {
    final salary = job.salary?.trim();
    if (salary == null || salary.isEmpty) return "Salary not disclosed";
    return salary;
  }

  String _postedLabel(Job job) {
    final createdAt = job.createdAt?.trim();
    if (createdAt == null || createdAt.isEmpty) return "Recently posted";
    final parsed = DateTime.tryParse(createdAt);
    if (parsed == null) return "Posted: $createdAt";
    return "Posted: ${_formatDate(parsed)}";
  }

  String _formatDate(DateTime date) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    final month = months[date.month - 1];
    return "${date.day} $month ${date.year}";
  }
}
