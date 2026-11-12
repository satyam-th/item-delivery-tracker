import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers.dart';
import 'manage_customers_screen.dart';
import 'manage_items_screen.dart';
import 'manage_rates_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showInfoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: AppColors.primaryGreen)),
          ),
        ],
      ),
    );
  }

  void _showManualResetDialog(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context, listen: false);
    final data = Provider.of<DataProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 8),
            Text(locale.resetGrid),
          ],
        ),
        content: Text(locale.resetGridConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(locale.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              data.manualReset();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(locale.resetSuccessful),
                  backgroundColor: AppColors.primaryGreen,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(locale.confirm),
          ),
        ],
      ),
    );
  }

  void _showResetSettingsDialog(BuildContext context) {
    final data = Provider.of<DataProvider>(context, listen: false);
    final locale = Provider.of<LocaleProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => _ResetSettingsDialog(
        data: data,
        locale: locale,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final data = Provider.of<DataProvider>(context);

    String resetModeSummary;
    if (data.resetMode == 'manual') {
      resetModeSummary = locale.manualOnly;
    } else {
      final timeStr = _formatTimeOfDay(TimeOfDay(hour: data.resetHour, minute: data.resetMinute));
      String freqStr;
      switch (data.resetFrequency) {
        case 'weekly':
          freqStr = '${locale.weekly} (${_weekdayName(data.resetWeekday, locale)})';
          break;
        case 'custom':
          final dayNames = data.resetCustomDays.map((d) => _weekdayShort(d)).join(', ');
          freqStr = '${locale.custom}: $dayNames';
          break;
        case 'daily':
        default:
          freqStr = locale.daily;
      }
      resetModeSummary = '${locale.automatic} · $freqStr · $timeStr';
    }

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      appBar: AppBar(
        title: Text(locale.settings),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.darkNavy,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                locale.language,
                style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            _buildListTile(
              icon: Icons.language,
              title: locale.currentLanguage,
              subtitle: locale.isNepali ? 'नेपाली (सक्रिय)' : 'English (Active)',
              onTap: () {
                locale.toggleLanguage();
              },
            ),
            const Divider(height: 1, color: Colors.black12),
            
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                locale.returnDisplayMode,
                style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            _buildListTile(
              icon: Icons.view_agenda,
              title: locale.extraRow,
              subtitle: locale.isNepali ? 'मानक दृश्य' : 'Standard View',
              onTap: () {
                _showInfoDialog(
                  context,
                  locale.returnDisplayMode,
                  locale.isNepali 
                      ? 'वर्तमान मोड: प्रत्येक कक्षमा लोड र फिर्ता दुवै देखाइन्छ।'
                      : 'Current mode: Displays both Load and Return in each cell.',
                );
              },
            ),
            const Divider(height: 1, color: Colors.black12),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                locale.returnFormatStyle,
                style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            _buildListTile(
              icon: Icons.format_list_numbered,
              title: '5-1',
              subtitle: locale.isNepali ? 'लोड - फिर्ता' : 'Load - Return',
              onTap: () {
                _showInfoDialog(
                  context,
                  locale.returnFormatStyle,
                  locale.isNepali 
                      ? 'वर्तमान ढाँचा: लोड माथि र फिर्ता (- संख्या) तल देखाइन्छ।'
                      : 'Current style: Load is displayed on top, and Return (- count) below.',
                );
              },
            ),
            const Divider(height: 1, color: Colors.black12),
            
            const SizedBox(height: 16),

            // ===================== RESET SECTION =====================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                locale.resetSettings,
                style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            _buildListTile(
              icon: Icons.settings_backup_restore,
              title: locale.resetMode,
              subtitle: resetModeSummary,
              onTap: () => _showResetSettingsDialog(context),
            ),
            const Divider(height: 1, color: Colors.black12),
            ListTile(
              leading: const Icon(Icons.restart_alt, color: Colors.orange),
              title: Text(
                locale.resetGrid,
                style: const TextStyle(color: Colors.orange, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                locale.isNepali ? 'ग्रिड र गाडी लोड तुरुन्तै रिसेट गर्नुहोस्' : 'Instantly reset grid and vehicle stock',
                style: const TextStyle(fontSize: 12, color: Colors.black45),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.black54),
              onTap: () => _showManualResetDialog(context),
            ),
            const Divider(height: 1, color: Colors.black12),

            const SizedBox(height: 16),
            
            _buildListTile(
              icon: Icons.people,
              title: locale.manageCustomers,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageCustomersScreen()),
                );
              },
            ),
            const Divider(height: 1, color: Colors.black12),
            
            _buildListTile(
              icon: Icons.category,
              title: locale.manageItems,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageItemsScreen()),
                );
              },
            ),
            const Divider(height: 1, color: Colors.black12),
            
            _buildListTile(
              icon: Icons.currency_rupee,
              title: locale.manageRates,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageRatesScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  String _weekdayName(int weekday, LocaleProvider locale) {
    if (locale.isNepali) {
      const days = ['सोमबार', 'मंगलबार', 'बुधबार', 'बिहिबार', 'शुक्रबार', 'शनिबार', 'आइतबार'];
      return days[weekday - 1];
    }
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  String _weekdayShort(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryGreen),
      title: Text(
        title,
        style: const TextStyle(color: Colors.black87, fontSize: 16),
      ),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black45)) : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.black54),
      onTap: onTap,
    );
  }
}

// ===================== RESET SETTINGS DIALOG =====================

class _ResetSettingsDialog extends StatefulWidget {
  final DataProvider data;
  final LocaleProvider locale;

  const _ResetSettingsDialog({required this.data, required this.locale});

  @override
  State<_ResetSettingsDialog> createState() => _ResetSettingsDialogState();
}

class _ResetSettingsDialogState extends State<_ResetSettingsDialog> {
  late String _mode;
  late int _hour;
  late int _minute;
  late String _frequency;
  late int _weekday;
  late List<int> _customDays;

  @override
  void initState() {
    super.initState();
    _mode = widget.data.resetMode;
    _hour = widget.data.resetHour;
    _minute = widget.data.resetMinute;
    _frequency = widget.data.resetFrequency;
    _weekday = widget.data.resetWeekday;
    _customDays = List.from(widget.data.resetCustomDays);
  }

  String _formatTimeOfDay(int hour, int minute) {
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final period = hour >= 12 ? 'PM' : 'AM';
    return '$h:${minute.toString().padLeft(2, '0')} $period';
  }

  String _weekdayName(int weekday) {
    if (widget.locale.isNepali) {
      const days = ['सोमबार', 'मंगलबार', 'बुधबार', 'बिहिबार', 'शुक्रबार', 'शनिबार', 'आइतबार'];
      return days[weekday - 1];
    }
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _hour, minute: _minute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _hour = picked.hour;
        _minute = picked.minute;
      });
    }
  }

  void _toggleCustomDay(int day) {
    setState(() {
      if (_customDays.contains(day)) {
        _customDays.remove(day);
      } else {
        _customDays.add(day);
        _customDays.sort();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;
    final isAuto = _mode == 'auto';

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.settings_backup_restore, color: AppColors.primaryGreen),
          const SizedBox(width: 8),
          Text(locale.resetSettings),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mode Toggle
              Text(locale.resetMode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'auto', label: Text(locale.automatic, style: const TextStyle(fontSize: 12))),
                  ButtonSegment(value: 'manual', label: Text(locale.manualOnly, style: const TextStyle(fontSize: 12))),
                ],
                selected: {_mode},
                onSelectionChanged: (val) => setState(() => _mode = val.first),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    return states.contains(WidgetState.selected) ? AppColors.primaryGreen : null;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    return states.contains(WidgetState.selected) ? Colors.white : Colors.black87;
                  }),
                ),
              ),

              if (isAuto) ...[
                const SizedBox(height: 20),

                // Reset Time
                Text(locale.resetTime, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickTime,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: AppColors.primaryGreen, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _formatTimeOfDay(_hour, _minute),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        const Icon(Icons.edit, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Frequency
                Text(locale.resetFrequency, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'daily', label: Text(locale.daily, style: const TextStyle(fontSize: 11))),
                    ButtonSegment(value: 'weekly', label: Text(locale.weekly, style: const TextStyle(fontSize: 11))),
                    ButtonSegment(value: 'custom', label: Text(locale.custom, style: const TextStyle(fontSize: 11))),
                  ],
                  selected: {_frequency},
                  onSelectionChanged: (val) => setState(() => _frequency = val.first),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      return states.contains(WidgetState.selected) ? AppColors.primaryGreen : null;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      return states.contains(WidgetState.selected) ? Colors.white : Colors.black87;
                    }),
                  ),
                ),

                // Weekly: pick weekday
                if (_frequency == 'weekly') ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _weekday,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: List.generate(7, (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text(_weekdayName(i + 1)),
                    )),
                    onChanged: (val) {
                      if (val != null) setState(() => _weekday = val);
                    },
                  ),
                ],

                // Custom: pick multiple weekdays
                if (_frequency == 'custom') ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(7, (i) {
                      final day = i + 1;
                      final selected = _customDays.contains(day);
                      return FilterChip(
                        label: Text(
                          _weekdayName(day),
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.black87,
                            fontSize: 12,
                          ),
                        ),
                        selected: selected,
                        onSelected: (_) => _toggleCustomDay(day),
                        selectedColor: AppColors.primaryGreen,
                        checkmarkColor: Colors.white,
                      );
                    }),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(locale.cancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            widget.data.updateResetSettings(
              mode: _mode,
              hour: _hour,
              minute: _minute,
              frequency: _frequency,
              weekday: _weekday,
              customDays: _customDays,
            );
            Navigator.pop(context);
          },
          child: Text(locale.save),
        ),
      ],
    );
  }
}
