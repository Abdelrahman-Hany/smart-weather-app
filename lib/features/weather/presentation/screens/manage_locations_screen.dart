import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../cubit/weather_cubit.dart';
import '../cubit/weather_state.dart';
import '../widgets/bottom_bar_action.dart';
import '../widgets/label_dialog.dart';
import '../widgets/location_card.dart';
import 'search_screen.dart';

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
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteLocationsTitle),
        content: Text(l10n.removeLocationsContent(_selectedIndices.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
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
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _showLabelDialog({
    required int locationIndex,
    String? existingLabel,
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => LabelDialog(existingLabel: existingLabel),
    );
    if (result != null && mounted) {
      context.read<WeatherCubit>().updateLabel(locationIndex, result);
    }
  }

  void _editLabelForSelected() {
    if (_selectedIndices.isEmpty) return;
    final state = context.read<WeatherCubit>().state;
    final firstIdx = _selectedIndices.first;
    if (firstIdx >= state.locations.length) return;
    final existingLabel = state.locations[firstIdx].location.label;
    _showLabelDialog(locationIndex: firstIdx, existingLabel: existingLabel);
  }

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
    return BlocConsumer<WeatherCubit, WeatherState>(
      listenWhen: (prev, curr) => prev.gpsError != curr.gpsError,
      listener: (context, state) {
        if (state.gpsError != null) {
          showErrorSnackbar(context, state.gpsError!);
          context.read<WeatherCubit>().clearGpsError();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F7),
          appBar: _isSelectMode
              ? _buildSelectAppBar(state)
              : _buildNormalAppBar(),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAddCurrentLocationButton(state),
              const SizedBox(height: 8),
              Expanded(child: _buildLocationList(state)),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: _LocationsInfoText(),
              ),
            ],
          ),
          bottomNavigationBar: _isSelectMode ? _buildSelectBottomBar() : null,
        );
      },
    );
  }

  PreferredSizeWidget _buildNormalAppBar() {
    final l10n = context.l10n;
    return AppBar(
      backgroundColor: const Color(0xFFF2F2F7),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        l10n.weather,
        style: const TextStyle(
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
            PopupMenuItem(value: 'select', child: _SelectMenuLabel()),
          ],
        ),
      ],
    );
  }

  PreferredSizeWidget _buildSelectAppBar(WeatherState state) {
    final l10n = context.l10n;
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
        tooltip: l10n.selectAll,
      ),
      title: Text(
        l10n.selectedCount(_selectedIndices.length),
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _toggleSelectMode,
          child: Text(
            l10n.cancel,
            style: const TextStyle(
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
    final l10n = context.l10n;
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
            hasGps ? l10n.updateCurrentLocation : l10n.addCurrentLocation,
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
    final l10n = context.l10n;
    if (state.locations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            l10n.noLocationsSaved,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 15),
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

        return LocationCard(
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
    final l10n = context.l10n;
    final hasSelection = _selectedIndices.isNotEmpty;
    final state = context.read<WeatherCubit>().state;

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
          BottomBarAction(
            icon: Icons.do_not_disturb_on_outlined,
            label: l10n.removeLabel,
            enabled: hasSelection && anyHasLabel,
            onPressed: hasSelection && anyHasLabel
                ? _removeLabelsForSelected
                : null,
          ),
          BottomBarAction(
            icon: Icons.edit_outlined,
            label: anyHasLabel ? l10n.editLabel : l10n.addLabel,
            enabled: hasSelection,
            onPressed: hasSelection ? _editLabelForSelected : null,
          ),
          BottomBarAction(
            icon: Icons.delete_outline_rounded,
            label: l10n.delete,
            enabled: hasSelection,
            onPressed: hasSelection ? _deleteSelected : null,
          ),
        ],
      ),
    );
  }
}

class _LocationsInfoText extends StatelessWidget {
  const _LocationsInfoText();

  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.locationsInfo,
      style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.4),
    );
  }
}

class _SelectMenuLabel extends StatelessWidget {
  const _SelectMenuLabel();

  @override
  Widget build(BuildContext context) {
    return Text(context.l10n.select);
  }
}
