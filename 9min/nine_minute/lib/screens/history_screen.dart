import 'package:flutter/material.dart';
import '../data/history_repo.dart';
import '../theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryEntry>? _entries;

  @override
  void initState() {
    super.initState();
    HistoryRepo.load().then((list) {
      if (mounted) setState(() => _entries = list);
    });
  }

  String _formatDate(DateTime dt) {
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'am' : 'pm';
    return '${dt.day} ${months[dt.month]} ${dt.year}  $h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, left: 4),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back,
                      color: AppTheme.textSecondary),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text('History',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 6),
                  const Text(
                    'A quiet log of your practice.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
            Expanded(
              child: _entries == null
                  ? const SizedBox.shrink()
                  : _entries!.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Nothing here yet.',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w300,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: _entries!.length,
                          itemBuilder: (_, i) {
                            final e = _entries![i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Expanded(
                                    child: Text(
                                      e.flowName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _formatDate(e.dateTime),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w300,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
