import 'package:flutter/material.dart';

import 'label_helpers.dart';

/// Dialog for adding or editing a custom label.
///
/// Returns the label string on "Add" / "Save", or `null` on cancel.
class LabelDialog extends StatefulWidget {
  final String? existingLabel;

  const LabelDialog({super.key, this.existingLabel});

  @override
  State<LabelDialog> createState() => _LabelDialogState();
}

class _LabelDialogState extends State<LabelDialog> {
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
            Text(
              _isEditing ? 'Edit custom label' : 'Add a custom label',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (_, value, _) {
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
            Wrap(
              spacing: 8,
              children: presetLabels.entries.map((entry) {
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
                    builder: (_, value, _) {
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
