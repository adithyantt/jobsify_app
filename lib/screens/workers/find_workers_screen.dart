import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  /// 🔍 FILTERS
  int? minExperience;
  int? maxExperience;
  double? minRating;
  List<String> selectedLocations = [];

  /// 📅 AVAILABILITY FILTERS
  String?
  availabilityTypeFilter; // 'everyday', 'selected_days', 'not_available', null = all
  List<String> selectedDaysFilter = []; // Mon, Tue, Wed, Thu, Fri, Sat, Sun

  String sortBy =
      'distance'; // 'distance', 'experience_high', 'experience_low', 'rating_high', 'rating_low'

  /// 📍 AVAILABLE LOCATIONS (extracted from workers dynamically)
  List<String> availableLocations = [];

  /// 📅 WEEK DAYS
  final List<String> weekDays = [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun",
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedFilters();
    _initEverything();
  }

  /// 💾 LOAD SAVED FILTERS
  Future<void> _loadSavedFilters() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      minExperience = prefs.getInt('filter_min_experience');
      maxExperience = prefs.getInt('filter_max_experience');
      minRating = prefs.getDouble('filter_min_rating');
      availabilityTypeFilter = prefs.getString('filter_availability_type');
      selectedDaysFilter = prefs.getStringList('filter_selected_days') ?? [];
      sortBy = prefs.getString('filter_workers_sort_by') ?? 'distance';
      selectedLocations = prefs.getStringList('filter_worker_locations') ?? [];
    });
  }

  /// 💾 SAVE FILTERS
  Future<void> _saveFilters() async {
    final prefs = await SharedPreferences.getInstance();
    if (minExperience != null) {
      await prefs.setInt('filter_min_experience', minExperience!);
    } else {
      await prefs.remove('filter_min_experience');
    }
    if (maxExperience != null) {
      await prefs.setInt('filter_max_experience', maxExperience!);
    } else {
      await prefs.remove('filter_max_experience');
    }
    if (minRating != null) {
      await prefs.setDouble('filter_min_rating', minRating!);
    } else {
      await prefs.remove('filter_min_rating');
    }
    if (availabilityTypeFilter != null) {
      await prefs.setString(
        'filter_availability_type',
        availabilityTypeFilter!,
      );
    } else {
      await prefs.remove('filter_availability_type');
    }
    await prefs.setStringList('filter_selected_days', selectedDaysFilter);
    await prefs.setString('filter_workers_sort_by', sortBy);
    await prefs.setStringList('filter_worker_locations', selectedLocations);
  }

  /// 🔢 GET ACTIVE FILTER COUNT
  int get _activeFilterCount {
    int count = 0;
    if (minExperience != null) count++;
    if (maxExperience != null) count++;
    if (minRating != null) count++;
    if (availabilityTypeFilter != null) count++;
    if (selectedDaysFilter.isNotEmpty) count++;
    if (selectedLocations.isNotEmpty) count++;
    if (sortBy != 'distance') count++;
    return count;
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
      final data = await WorkerService.fetchWorkers(
        minExperience: minExperience,
        maxExperience: maxExperience,
        minRating: minRating,
        availabilityType: availabilityTypeFilter,
        availableDays: selectedDaysFilter.isNotEmpty
            ? selectedDaysFilter
            : null,
        sortBy: sortBy,
      );

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

    // Apply location filter (client-side for multi-select)
    if (selectedLocations.isNotEmpty) {
      filtered = filtered.where((w) {
        return selectedLocations.any(
          (loc) => w.location.toLowerCase().contains(loc.toLowerCase()),
        );
      }).toList();
    }

    // Apply availability type filter
    if (availabilityTypeFilter != null) {
      filtered = filtered.where((w) {
        return w.availabilityType == availabilityTypeFilter;
      }).toList();
    }

    // Apply selected days filter
    if (selectedDaysFilter.isNotEmpty) {
      filtered = filtered.where((w) {
        if (w.availabilityType == 'everyday') return true;
        if (w.availableDays == null) return false;
        final workerDays = w.availableDays!.split(',');
        return selectedDaysFilter.any((day) => workerDays.contains(day));
      }).toList();
    }

    // Apply sorting
    if (sortBy == 'distance' && userLat != null && userLng != null) {
      filtered.sort((a, b) {
        final ad = _distanceToWorker(a);
        final bd = _distanceToWorker(b);
        if (ad == null && bd == null) return 0;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return ad.compareTo(bd);
      });
    } else if (sortBy == 'experience_high') {
      filtered.sort((a, b) => b.experience.compareTo(a.experience));
    } else if (sortBy == 'experience_low') {
      filtered.sort((a, b) => a.experience.compareTo(b.experience));
    } else if (sortBy == 'rating_high') {
      filtered.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    } else if (sortBy == 'rating_low') {
      filtered.sort((a, b) => (a.rating ?? 0).compareTo(b.rating ?? 0));
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
                                value: 'experience_high',
                                child: Text('Experience: High to Low'),
                              ),
                              DropdownMenuItem(
                                value: 'experience_low',
                                child: Text('Experience: Low to High'),
                              ),
                              DropdownMenuItem(
                                value: 'rating_high',
                                child: Text('Rating: High to Low'),
                              ),
                              DropdownMenuItem(
                                value: 'rating_low',
                                child: Text('Rating: Low to High'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  sortBy = value;
                                });
                                _saveFilters();
                                _applyFilters();
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

          /// 📊 WORKERS COUNT MESSAGE
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "${allWorkers.length} workers available",
                style: TextStyle(
                  color:
                      Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.black,
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
                            : Theme.of(context).textTheme.bodyLarge?.color ??
                                  Colors.black,
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
          else
            FutureBuilder<List<Worker>>(
              future: Future.value(allWorkers),
              builder: (context, snapshot) {
                List<Worker> workers = allWorkers;

                /// 🏙️ EXTRACT UNIQUE LOCATIONS
                availableLocations =
                    workers
                        .map((w) => w.location.split(',').first.trim())
                        .toSet()
                        .toList()
                      ..sort();

                if (visibleWorkers.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          "No workers found",
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color ??
                                Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _workerCard(visibleWorkers[i]),
                    childCount: visibleWorkers.length,
                  ),
                );
              },
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
              color:
                  Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
            ),
          ),

          const SizedBox(height: 4),
          Text(
            "${worker.experience} years experience • ${worker.role}",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color:
                  Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 153) ??
                  Colors.grey,
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

  /// 📻 CUSTOM RADIO OPTION
  Widget _buildRadioOption({
    required String label,
    required String value,
    required String currentValue,
    required VoidCallback onTap,
  }) {
    final isSelected = value == currentValue;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? kLightBlue : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Container(
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kLightBlue,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? kLightBlue : Colors.black87,
              ),
            ),
          ],
        ),
      ),
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
                    color: kLightBlue,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Workers',
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
                                minExperience = null;
                                maxExperience = null;
                                minRating = null;
                                availabilityTypeFilter = null;
                                selectedDaysFilter = [];
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
                      /// 💼 EXPERIENCE RANGE
                      const Text(
                        'Experience Range (Years)',
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
                                suffixText: 'yrs',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              controller: TextEditingController(
                                text: minExperience?.toString(),
                              ),
                              onChanged: (value) {
                                minExperience = int.tryParse(value);
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
                                suffixText: 'yrs',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              controller: TextEditingController(
                                text: maxExperience?.toString(),
                              ),
                              onChanged: (value) {
                                maxExperience = int.tryParse(value);
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      /// ⭐ MINIMUM RATING
                      const Text(
                        'Minimum Rating',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          for (int i = 1; i <= 5; i++)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('$i'),
                                    const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                  ],
                                ),
                                selected: minRating == i.toDouble(),
                                selectedColor: Colors.amber.withValues(
                                  alpha: 0.2,
                                ),
                                onSelected: (selected) {
                                  setModalState(() {
                                    minRating = selected ? i.toDouble() : null;
                                  });
                                },
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      /// 📅 AVAILABILITY TYPE FILTER
                      const Text(
                        'Availability',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: [
                          _buildRadioOption(
                            label: 'All',
                            value: 'all',
                            currentValue: availabilityTypeFilter ?? 'all',
                            onTap: () {
                              setModalState(() {
                                availabilityTypeFilter = null;
                                selectedDaysFilter = [];
                              });
                            },
                          ),
                          _buildRadioOption(
                            label: 'Available Everyday',
                            value: 'everyday',
                            currentValue: availabilityTypeFilter ?? 'all',
                            onTap: () {
                              setModalState(() {
                                availabilityTypeFilter = 'everyday';
                                selectedDaysFilter = [];
                              });
                            },
                          ),
                          _buildRadioOption(
                            label: 'Available on Selected Days',
                            value: 'selected_days',
                            currentValue: availabilityTypeFilter ?? 'all',
                            onTap: () {
                              setModalState(() {
                                availabilityTypeFilter = 'selected_days';
                              });
                            },
                          ),
                          _buildRadioOption(
                            label: 'Not Available',
                            value: 'not_available',
                            currentValue: availabilityTypeFilter ?? 'all',
                            onTap: () {
                              setModalState(() {
                                availabilityTypeFilter = 'not_available';
                                selectedDaysFilter = [];
                              });
                            },
                          ),
                        ],
                      ),

                      /// 📅 SELECTED DAYS FILTER (only show when selected_days is chosen)
                      if (availabilityTypeFilter == 'selected_days') ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Select Days',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: weekDays.map((day) {
                            final isSelected = selectedDaysFilter.contains(day);
                            return FilterChip(
                              label: Text(day),
                              selected: isSelected,
                              selectedColor: kLightBlue.withValues(alpha: 0.3),
                              checkmarkColor: kLightBlue,
                              onSelected: (selected) {
                                setModalState(() {
                                  if (selected) {
                                    selectedDaysFilter.add(day);
                                  } else {
                                    selectedDaysFilter.remove(day);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],

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
                              selectedColor: kLightBlue.withValues(alpha: 0.2),
                              checkmarkColor: kLightBlue,
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
                          backgroundColor: kLightBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setState(() {});
                          _saveFilters();
                          _loadWorkers();
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
}
