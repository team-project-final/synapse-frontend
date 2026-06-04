import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

class CommandPaletteItem {
  const CommandPaletteItem({
    required this.icon,
    required this.label,
    required this.route,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String route;
  final String? subtitle;
}

class CommandPalette extends StatefulWidget {
  const CommandPalette({
    required this.items,
    required this.onSelect,
    super.key,
  });

  final List<CommandPaletteItem> items;
  final ValueChanged<CommandPaletteItem> onSelect;

  static Future<void> show(
    BuildContext context, {
    required List<CommandPaletteItem> items,
    required ValueChanged<CommandPaletteItem> onSelect,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => CommandPalette(items: items, onSelect: onSelect),
    );
  }

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  final _searchController = TextEditingController();
  int _selectedIndex = 0;
  late List<CommandPaletteItem> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter(String query) {
    setState(() {
      _selectedIndex = 0;
      _filtered = query.isEmpty
          ? widget.items
          : widget.items
              .where((item) =>
                  item.label.toLowerCase().contains(query.toLowerCase()) ||
                  (item.subtitle?.toLowerCase().contains(query.toLowerCase()) ??
                      false))
              .toList();
    });
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() => _selectedIndex =
          (_selectedIndex + 1).clamp(0, _filtered.length - 1));
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() => _selectedIndex =
          (_selectedIndex - 1).clamp(0, _filtered.length - 1));
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.enter &&
        _filtered.isNotEmpty) {
      Navigator.of(context).pop();
      widget.onSelect(_filtered[_selectedIndex]);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: _handleKey,
      child: Dialog(
        alignment: Alignment.topCenter,
        insetPadding: const EdgeInsets.only(
            top: 80, left: AppSpacing.lg, right: AppSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: '명령어 검색... (↑↓ 이동, Enter 선택)',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                  onChanged: _filter,
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) {
                    final item = _filtered[index];
                    final isSelected = index == _selectedIndex;
                    return ListTile(
                      leading: Icon(item.icon, size: 20),
                      title: Text(item.label),
                      subtitle: item.subtitle != null
                          ? Text(item.subtitle!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.stone400))
                          : null,
                      selected: isSelected,
                      selectedTileColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      dense: true,
                      onTap: () {
                        Navigator.of(context).pop();
                        widget.onSelect(item);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
