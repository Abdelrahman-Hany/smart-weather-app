import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/constants/api_constants.dart';
import '../cubit/weather_cubit.dart';
import '../cubit/weather_state.dart';
import 'search_screen.dart';

/// Map of preset label names to their icons.
const Map<String, IconData> _presetLabels = {
  'Home': Icons.home_outlined,
  'Office': Icons.business_outlined,
  'School': Icons.school_outlined,
};

/// Returns the icon for a label (preset or custom).
IconData _labelIcon(String label) {
  return _presetLabels[label] ?? Icons.label_outline_rounded;
}

class ManageLocationsScreen extends StatefulWidget {
  const ManageLocationsScreen({super.key});

  @override
  State<ManageLocationsScreen> createState() => _ManageLocationsScreenState();
}

class _ManageLocationsScreenState extends State<ManageLocationsScreen> {
  bool _isSelectMode = false;
  final Set<int> _selectedIndices = {};

  void _toggleSelectMode() {
    setState(() {
      _isSelectMode = !_isSelectMode;
      if (!_isSelectMode) _selectedIndices.clear();
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _selectAll(int total) {
    setState(() {
      if (_selectedIndices.length == total) {
        _selectedIndices.clear();
      } else {
        _selectedIndices.addAll(List.generate(total, (i) => i));
      }
    });
  }

  void _deleteSelected() {
    if (_selectedIndices.isEmpty) return;
    final cubit = context.read<WeatherCubit>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete locations'),
        content: Text(
          'Remove ${_selectedIndices.length} location${_selectedIndices.length > 1 ? 's' : ''}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              cubit.removeMultipleLocations(_selectedIndices);
              setState(() {
                _isSelectMode = false;
                _selectedIndices.clear();
              });
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Show the "Add a custom label" or "Edit custom label" dialog.
  Future<void> _showLabelDialog({
    required int locationIndex,
    String? existingLabel,
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => _LabelDialog(existingLabel: existingLabel),
    );
    if (result != null && mounted) {
      context.read<WeatherCubit>().updateLabel(locationIndex, result);
    }
  }

  /// Edit label for selected locations (uses first selected).
  void _editLabelForSelected() {
    if (_selectedIndices.isEmpty) return;
    final state = context.read<WeatherCubit>().state;
    // Use the first selected location's existing label.
    final firstIdx = _selectedIndices.first;
    if (firstIdx >= state.locations.length) return;
    final existingLabel = state.locations[firstIdx].location.label;
    _showLabelDialog(locationIndex: firstIdx, existingLabel: existingLabel);
  }

  /// Remove labels from all selected locations.
  void _removeLabelsForSelected() {
    if (_selectedIndices.isEmpty) return;
    context.read<WeatherCubit>().removeLabels(Set.from(_selectedIndices));
  }

  void _onLocationTap(int index) {
    if (_isSelectMode) {
      _toggleSelection(index);
    } else {
      context.read<WeatherCubit>().setActiveIndex(index);
      Navigator.pop(context);
    }
  }

  void _onLocationLongPress(int index) {
    if (!_isSelectMode) {
      setState(() {
        _isSelectMode = true;
        _selectedIndices.add(index);
      });
    }
  }

  Future<void> _addCurrentLocation() async {
    context.read<WeatherCubit>().loadWeatherByLocation();
    // Don't pop — the BlocListener will show a snackbar if it fails.
  }

  Future<void> _addCitySearch() async {
    final city = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
    if (city != null && mounted) {
      context.read<WeatherCubit>().loadWeatherByCity(city);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F7),
          appBar: _isSelectMode
              ? _buildSelectAppBar(state)
              : _buildNormalAppBar(),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "Add current location" button
              _buildAddCurrentLocationButton(state),
              const SizedBox(height: 8),
              // Location list
              Expanded(child: _buildLocationList(state)),
              // Info text
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Text(
                  'The location at the top of the list will be used to provide weather information in notifications and other connected services.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          // Bottom bar in select mode
          bottomNavigationBar: _isSelectMode ? _buildSelectBottomBar() : null,
        );
      },
    );
  }

  PreferredSizeWidget _buildNormalAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF2F2F7),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Weather',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, color: Colors.black87),
          onPressed: _addCitySearch,
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: Colors.black87),
          onSelected: (value) {
            if (value == 'select') _toggleSelectMode();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'select', child: Text('Select')),
          ],
        ),
      ],
    );
  }

  PreferredSizeWidget _buildSelectAppBar(WeatherState state) {
    final total = state.locations.length;
    final allSelected = _selectedIndices.length == total;

    return AppBar(
      backgroundColor: const Color(0xFFF2F2F7),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(
          allSelected
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          color: allSelected ? const Color(0xFF4285F4) : Colors.black45,
        ),
        onPressed: () => _selectAll(total),
        tooltip: 'Select all',
      ),
      title: Text(
        '${_selectedIndices.length} selected',
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _toggleSelectMode,
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddCurrentLocationButton(WeatherState state) {
    final hasGps = state.locations.any((l) => l.location.isCurrentLocation);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: state.isGpsLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
          title: Text(
            hasGps ? 'Update current location' : 'Add current location',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onTap: state.isGpsLoading ? null : _addCurrentLocation,
        ),
      ),
    );
  }

  Widget _buildLocationList(WeatherState state) {
    if (state.locations.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No locations saved yet.\nAdd a city or use your current location.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 15),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: state.locations.length,
      itemBuilder: (context, index) {
        final locData = state.locations[index];
        final isSelected = _selectedIndices.contains(index);

        return _LocationCard(
          locData: locData,
          isSelectMode: _isSelectMode,
          isSelected: isSelected,
          onTap: () => _onLocationTap(index),
          onLongPress: () => _onLocationLongPress(index),
        );
      },
    );
  }

  Widget _buildSelectBottomBar() {
    final hasSelection = _selectedIndices.isNotEmpty;
    final state = context.read<WeatherCubit>().state;

    // Check if any selected location has a label.
    final anyHasLabel = _selectedIndices.any((idx) {
      if (idx < state.locations.length) {
        final lbl = state.locations[idx].location.label;
        return lbl != null && lbl.isNotEmpty;
      }
      return false;
    });

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 0.5),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 8,
        top: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Remove label — only enabled when at least one selected has a label
          _BottomBarAction(
            icon: Icons.do_not_disturb_on_outlined,
            label: 'Remove label',
            enabled: hasSelection && anyHasLabel,
            onPressed: hasSelection && anyHasLabel
                ? _removeLabelsForSelected
                : null,
          ),
          // Add label / Edit label — text changes based on whether a label exists
          _BottomBarAction(
            icon: Icons.edit_outlined,
            label: anyHasLabel ? 'Edit label' : 'Add label',
            enabled: hasSelection,
            onPressed: hasSelection ? _editLabelForSelected : null,
          ),
          // Delete
          _BottomBarAction(
            icon: Icons.delete_outline_rounded,
            label: 'Delete',
            enabled: hasSelection,
            onPressed: hasSelection ? _deleteSelected : null,
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final LocationWeatherData locData;
  final bool isSelectMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _LocationCard({
    required this.locData,
    required this.isSelectMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final weather = locData.weather;
    final location = locData.location;
    final now = DateTime.now();
    final dateStr = DateFormat('E, MMMM d \'at\' h:mm a').format(now);
    final hasLabel = location.label != null && location.label!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 0,
        color: isSelected ? const Color(0xFFE8EAF6) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Select checkbox
                if (isSelectMode) ...[
                  Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isSelected
                        ? const Color(0xFF4285F4)
                        : Colors.black26,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                ],
                // City info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label row (if present)
                      if (hasLabel) ...[
                        Row(
                          children: [
                            Icon(
                              _labelIcon(location.label!),
                              size: 14,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              location.label!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                      ],
                      // City name
                      Text(
                        location.cityName,
                        style: TextStyle(
                          fontSize: hasLabel ? 14 : 18,
                          fontWeight: hasLabel
                              ? FontWeight.w400
                              : FontWeight.w600,
                          color: hasLabel ? Colors.black54 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        location.country.isNotEmpty
                            ? '${location.cityName}, ${location.country}'
                            : location.cityName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
                // Weather icon + temp
                if (weather != null) ...[
                  Image.network(
                    ApiConstants.weatherIcon(weather.icon, size: 2),
                    width: 32,
                    height: 32,
                    errorBuilder: (_, __, _) =>
                        const Icon(Icons.cloud, color: Colors.grey, size: 28),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${weather.temperature.round()}\u00B0',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${weather.tempMax.round()}\u00B0 / ${weather.tempMin.round()}\u00B0',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ] else if (locData.status == WeatherStatus.loading) ...[
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
                // Reorder handle in select mode
                if (isSelectMode) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.unfold_more_rounded,
                    color: Colors.black26,
                    size: 24,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A single action button in the selection-mode bottom bar.
class _BottomBarAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback? onPressed;

  const _BottomBarAction({
    required this.icon,
    required this.label,
    required this.enabled,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? Colors.black87 : Colors.black26;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

/// Dialog for adding or editing a custom label.
/// Returns the label string on "Add" / "Save", or null on cancel.
class _LabelDialog extends StatefulWidget {
  final String? existingLabel;

  const _LabelDialog({this.existingLabel});

  @override
  State<_LabelDialog> createState() => _LabelDialogState();
}

class _LabelDialogState extends State<_LabelDialog> {
  late TextEditingController _controller;
  static const int _maxLength = 25;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.existingLabel ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isEditing =>
      widget.existingLabel != null && widget.existingLabel!.isNotEmpty;

  void _submit() {
    final text = _controller.text.trim();
    Navigator.pop(context, text);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              _isEditing ? 'Edit custom label' : 'Add a custom label',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            // Text field with character count
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (_, value, __) {
                return TextField(
                  controller: _controller,
                  maxLength: _maxLength,
                  autofocus: true,
                  decoration: InputDecoration(
                    counterText: '${value.text.length}/$_maxLength',
                    suffixIcon: value.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => _controller.clear(),
                          )
                        : null,
                    border: const UnderlineInputBorder(),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF4285F4),
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            // Preset label chips
            Wrap(
              spacing: 8,
              children: _presetLabels.entries.map((entry) {
                return ActionChip(
                  avatar: Icon(entry.value, size: 18, color: Colors.black54),
                  label: Text(entry.key),
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                  backgroundColor: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  onPressed: () {
                    _controller.text = entry.key;
                    _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: entry.key.length),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Cancel / Add buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Container(width: 1, height: 24, color: Colors.grey.shade300),
                Expanded(
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (_, value, __) {
                      final canSubmit = value.text.trim().isNotEmpty;
                      return TextButton(
                        onPressed: canSubmit ? _submit : null,
                        child: Text(
                          _isEditing ? 'Save' : 'Add',
                          style: TextStyle(
                            color: canSubmit
                                ? const Color(0xFF4285F4)
                                : Colors.black26,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
