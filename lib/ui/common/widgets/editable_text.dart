import 'package:flutter/material.dart';

typedef OnSaveCallback = Future<void> Function(String value);

class EditableTextField extends StatefulWidget {
  final String? initialValue;
  final String placeholder;
  final TextStyle? textStyle;
  final OnSaveCallback onSave;
  final double? width;
  final bool expandable;
  final int? maxLines;

  const EditableTextField({
    super.key,
    required this.initialValue,
    required this.placeholder,
    required this.onSave,
    this.textStyle,
    this.width,
    this.expandable = false,
    this.maxLines,
  });

  @override
  State<EditableTextField> createState() => _EditableTextFieldState();
}

class _EditableTextFieldState extends State<EditableTextField> {
  bool _isEditing = false;
  bool _isLoading = false;
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing && !_isLoading) {
        _handleSave();
      }
    });
  }

  @override
  void didUpdateWidget(covariant EditableTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue && !_isEditing) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final newValue = _controller.text.trim();
    final oldValue = widget.initialValue ?? '';

    if (newValue == oldValue) {
      setState(() => _isEditing = false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await widget.onSave(newValue);
    } catch (e) {
      debugPrint("Save error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isEditing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.width ?? double.infinity),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _isEditing ? _buildEditor(context) : _buildDisplay(context),
      ),
    );
  }

  Widget _buildEditor(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      key: const ValueKey('editing'),
      controller: _controller,
      focusNode: _focusNode,
      autofocus: true,
      maxLines: widget.expandable ? widget.maxLines ?? 3 : 1,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _handleSave(),
      style: widget.textStyle ?? TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: widget.placeholder,
        hintStyle: TextStyle(color: theme.hintColor),
        isDense: true,
        filled: true,
        // Uses theme's surface color (light grey in light mode, dark grey in dark mode)
        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.5,
        ),
        suffixIcon: _isLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: _handleSave,
              ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildDisplay(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      key: const ValueKey('display'),
      onTap: () => setState(() => _isEditing = true),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          // CardColor adapts automatically if set in ThemeData
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black26
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _controller.text.isNotEmpty
                    ? _controller.text
                    : widget.placeholder,
                style:
                    widget.textStyle?.copyWith(
                      color: _controller.text.isNotEmpty
                          ? theme.colorScheme.onSurface
                          : theme.hintColor,
                    ) ??
                    TextStyle(
                      fontSize: 16,
                      color: _controller.text.isNotEmpty
                          ? theme.colorScheme.onSurface
                          : theme.hintColor,
                    ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.edit_outlined,
              size: 18,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
