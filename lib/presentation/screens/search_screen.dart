import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final List<String> _recentSearches = [];

  static const List<String> _popularCities = [
    'London',
    'New York',
    'Tokyo',
    'Paris',
    'Dubai',
    'Cairo',
    'Sydney',
    'Berlin',
    'Istanbul',
    'Mumbai',
    'Singapore',
    'Toronto',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitCity(String city) {
    if (city.trim().isEmpty) return;
    final trimmed = city.trim();
    _recentSearches.remove(trimmed);
    _recentSearches.insert(0, trimmed);
    Navigator.pop(context, trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: const InputDecoration(
            hintText: 'Search city...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: _submitCity,
          onChanged: (_) => setState(() {}),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () {
                _controller.clear();
                setState(() {});
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_controller.text.isNotEmpty) ...[
              _buildSearchAction(),
            ] else ...[
              if (_recentSearches.isNotEmpty) ...[
                _buildSectionHeader('Recent Searches'),
                const SizedBox(height: 8),
                _buildRecentSearches(),
                const SizedBox(height: 24),
              ],
              _buildSectionHeader('Popular Cities'),
              const SizedBox(height: 12),
              _buildPopularCities(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAction() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.search_rounded, color: Color(0xFF4285F4)),
        title: Text(
          'Search for "${_controller.text}"',
          style: const TextStyle(
            color: Color(0xFF4285F4),
            fontWeight: FontWeight.w500,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () => _submitCity(_controller.text),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Column(
      children: _recentSearches.map((city) {
        return Card(
          elevation: 0,
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(Icons.history_rounded, color: Colors.grey),
            title: Text(city),
            trailing: const Icon(
              Icons.north_west_rounded,
              size: 16,
              color: Colors.grey,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onTap: () => _submitCity(city),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPopularCities() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _popularCities.map((city) {
        return ActionChip(
          label: Text(city),
          avatar: const Icon(Icons.location_city_rounded, size: 16),
          onPressed: () => _submitCity(city),
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          labelStyle: const TextStyle(fontSize: 13),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        );
      }).toList(),
    );
  }
}
