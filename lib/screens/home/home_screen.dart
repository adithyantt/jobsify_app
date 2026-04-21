import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../jobs/job_search_page.dart';
import '../jobs/jobs_home_screen.dart';
import '../jobs/jobs_list_screen.dart';
import '../jobs/find_job_screen.dart';
import '../jobs/saved_jobs_screen.dart';
import '../messages/messages_inbox_screen.dart';
import '../notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../workers/find_workers_screen.dart';
import '../../services/location_service.dart';
import '../../services/messaging_service.dart';
import '../../services/notification_service.dart';
import '../../services/user_session.dart';
import '../../utils/offline_handler.dart';

const Color kGreen = Color(0xFF10B981);
const Color kYellow = Color(0xFFD1D5DB);
const String kHomeSelectedLocationKey = 'home_selected_location';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  final List<Widget> _pages = const [
    HomeContent(),
    JobsHomeScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const AppDrawer(),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
        },
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          FocusManager.instance.primaryFocus?.unfocus();
          setState(() => _selectedIndex = index);
          _pageController.jumpToPage(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final FocusNode _searchFocusNode = FocusNode();
  int _unreadMessageCount = 0;
  String _selectedLocation = 'Delhi';

  final List<Map<String, dynamic>> categories = const [
    {'name': 'Plumber', 'icon': Icons.plumbing, 'color': Colors.blue},
    {'name': 'Painter', 'icon': Icons.format_paint, 'color': Colors.purple},
    {'name': 'Driver', 'icon': Icons.local_shipping, 'color': Colors.green},
    {'name': 'Electrician', 'icon': Icons.flash_on, 'color': Colors.orange},
    {'name': 'Carpenter', 'icon': Icons.handyman, 'color': Colors.deepOrange},
    {'name': 'Mason', 'icon': Icons.construction, 'color': Colors.red},
    {'name': 'Cleaner', 'icon': Icons.auto_awesome, 'color': Colors.pink},
    {'name': 'Gardener', 'icon': Icons.grass, 'color': Colors.greenAccent},
    {'name': 'Cook', 'icon': Icons.restaurant, 'color': Colors.brown},
    {'name': 'Security Guard', 'icon': Icons.security, 'color': Colors.grey},
    {'name': 'Mechanic', 'icon': Icons.build, 'color': Colors.black},
    {'name': 'Other', 'icon': Icons.more_horiz, 'color': Colors.indigo},
  ];

  @override
  void initState() {
    super.initState();
    _loadUnreadMessageCount();
    _loadSelectedLocation();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadUnreadMessageCount() async {
    final email = UserSession.email;
    if (email == null) return;
    final unreadCount = await MessagingService.getUnreadCount(email);
    if (mounted) {
      setState(() => _unreadMessageCount = unreadCount);
    }
  }

  Future<void> _loadSelectedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocation = prefs.getString(kHomeSelectedLocationKey);
    if (!mounted || savedLocation == null || savedLocation.trim().isEmpty) {
      return;
    }

    setState(() => _selectedLocation = savedLocation.trim());
  }

  Future<void> _saveSelectedLocation(String location) async {
    final trimmedLocation = location.trim();
    if (trimmedLocation.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kHomeSelectedLocationKey, trimmedLocation);
  }

  Future<void> _openLocationBottomSheet() async {
    final selectedLocation = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _HomeLocationSheet(initialLocation: _selectedLocation),
    );

    if (!mounted || selectedLocation == null || selectedLocation.trim().isEmpty) {
      return;
    }

    setState(() => _selectedLocation = selectedLocation.trim());
    await _saveSelectedLocation(selectedLocation);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: () => _searchFocusNode.unfocus(),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Builder(
              builder: (context) => Container(
                color: primary,
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () {
                            _searchFocusNode.unfocus();
                            Scaffold.of(context).openDrawer();
                          },
                        ),
                        const Text(
                          'Jobsify',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                _searchFocusNode.unfocus();
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MessagesInboxScreen(),
                                  ),
                                );
                                if (!mounted) return;
                                _loadUnreadMessageCount();
                              },
                            ),
                            if (_unreadMessageCount > 0)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _unreadMessageCount > 99
                                        ? '99+'
                                        : _unreadMessageCount.toString(),
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
                    const Text(
                      'Connect. Work. Grow.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        _searchFocusNode.unfocus();
                        _openLocationBottomSheet();
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _selectedLocation,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kYellow, width: 2),
                      ),
                      child: TextField(
                        focusNode: _searchFocusNode,
                        onTap: () {
                          _searchFocusNode.unfocus();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const JobSearchPage(),
                            ),
                          );
                        },
                        style: const TextStyle(color: Colors.black87),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          hintText: 'Search for services or workers...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final ctaCards = [
                  {
                    'color': primary,
                    'title': 'Browse Jobs',
                    'subtitle': 'Find available work',
                    'icon': Icons.work_outline,
                    'onTap': () {
                      _searchFocusNode.unfocus();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => FindJobsScreen()),
                      );
                    },
                  },
                  {
                    'color': kGreen,
                    'title': 'Find Workers',
                    'subtitle': 'Hire skilled workers',
                    'icon': Icons.people_outline,
                    'onTap': () {
                      _searchFocusNode.unfocus();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => FindWorkersScreen()),
                      );
                    },
                  },
                ];
                final card = ctaCards[index];
                return _ctaCard(
                  color: card['color'] as Color,
                  title: card['title'] as String,
                  subtitle: card['subtitle'] as String,
                  icon: card['icon'] as IconData,
                  onTap: card['onTap'] as VoidCallback,
                );
              }, childCount: 2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final c = categories[index];
                return InkWell(
                  onTap: () {
                    _searchFocusNode.unfocus();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JobsListScreen(category: c['name']),
                      ),
                    );
                  },
                  child: Container(
                    decoration: _cardDecoration(context),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: c['color'],
                          child: Icon(c['icon'], color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        Text(c['name']),
                        const Text(
                          'Find Now',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }, childCount: categories.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ctaCard({
    required Color color,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeLocationSheet extends StatefulWidget {
  final String initialLocation;

  const _HomeLocationSheet({required this.initialLocation});

  @override
  State<_HomeLocationSheet> createState() => _HomeLocationSheetState();
}

class _HomeLocationSheetState extends State<_HomeLocationSheet> {
  static const List<String> _popularCities = [
    'Delhi',
    'Bangalore',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Pune',
    'Ahmedabad',
    'Jaipur',
  ];

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<Map<String, String>> _searchResults = [];
  bool _isSearching = false;
  bool _isFetchingCurrentLocation = false;
  String? _errorText;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    final query = value.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _errorText = null;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (!mounted) return;
      setState(() {
        _isSearching = true;
        _errorText = null;
      });

      try {
        final results = await LocationService.searchLocations(query);
        if (!mounted) return;
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _searchResults = [];
          _isSearching = false;
          _errorText = 'Unable to fetch locations';
        });
      }
    });
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isFetchingCurrentLocation = true;
      _errorText = null;
    });

    try {
      final location = await LocationService.getCurrentLocation();
      if (!mounted) return;
      Navigator.pop(context, location['place']?.toString() ?? 'Unknown location');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFetchingCurrentLocation = false;
        _errorText = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final query = _searchController.text.trim();
    final showPopularCities = query.isEmpty;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Location',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ElevatedButton.icon(
              onPressed: _isFetchingCurrentLocation ? null : _useCurrentLocation,
              icon: _isFetchingCurrentLocation
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: Text(
                _isFetchingCurrentLocation
                    ? 'Fetching current location...'
                    : 'Use Current Location',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary.withValues(alpha: 0.1),
                foregroundColor: primary,
                side: BorderSide(color: primary),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search city, area or town...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorText!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : showPopularCities
                ? ListView.builder(
                    itemCount: _popularCities.length,
                    itemBuilder: (context, index) {
                      final city = _popularCities[index];
                      final isSelected = widget.initialLocation == city;

                      return ListTile(
                        leading: const Icon(Icons.location_city),
                        title: Text(city),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: primary)
                            : null,
                        onTap: () => Navigator.pop(context, city),
                      );
                    },
                  )
                : _searchResults.isEmpty
                ? const Center(
                    child: Text(
                      'No matching locations found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final result = _searchResults[index];
                      final place = result['place'] ?? '';
                      final displayName = result['display_name'] ?? place;
                      final isSelected = widget.initialLocation == place;

                      return ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text(place),
                        subtitle: Text(
                          displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: primary)
                            : null,
                        onTap: () => Navigator.pop(context, place),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await NotificationService.getUnreadCount(
        UserSession.email ?? '',
      );
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    } catch (e) {
      if (mounted) {
        OfflineHandler.showErrorSnackBar(context, e, onRetry: _loadUnreadCount);
        setState(() => _unreadCount = 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: primary),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: primary),
            ),
            accountName: ValueListenableBuilder<String?>(
              valueListenable: UserSession.userNameNotifier,
              builder: (_, name, _) => Text(name ?? 'User'),
            ),
            accountEmail: ValueListenableBuilder<String?>(
              valueListenable: UserSession.emailNotifier,
              builder: (_, email, _) => Text(email ?? ''),
            ),
          ),
          _drawerItem(context, Icons.home_outlined, 'Home'),
          _drawerItem(
            context,
            Icons.person_outline,
            'Profile',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          _drawerItem(
            context,
            Icons.bookmark_border,
            'Saved Items',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavedJobsScreen()),
              );
            },
          ),
          _drawerItemWithBadge(
            context,
            Icons.notifications_none,
            'Notifications',
            _unreadCount,
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
              if (mounted) {
                _loadUnreadCount();
              }
            },
          ),
          _drawerItem(
            context,
            Icons.settings_outlined,
            'Settings',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final navigator = Navigator.of(context);
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade300,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                },
              );
              if (!mounted) return;
              if (confirmed == true) {
                UserSession.clear();
                navigator.pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap ?? () => Navigator.pop(context),
    );
  }

  Widget _drawerItemWithBadge(
    BuildContext context,
    IconData icon,
    String title,
    int badgeCount, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Row(
        children: [
          Text(title),
          if (badgeCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badgeCount > 99 ? '99+' : badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: onTap ?? () => Navigator.pop(context),
    );
  }
}

BoxDecoration _cardDecoration(BuildContext context) {
  return BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
  );
}
