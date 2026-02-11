import 'package:flutter/material.dart';
import '../audio/tts_service.dart';
import '../theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TtsService _tts = TtsService();
  List<Map<String, String>>? _voices;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadVoices();
  }

  Future<void> _loadVoices() async {
    await _tts.init();
    final voices = await _tts.getAvailableVoices();
    if (mounted) {
      setState(() {
        _voices = voices;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
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

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text('Settings',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 6),
                  const Text(
                    'Customize your experience.',
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

            // Body
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildAccountSection(),
                  const SizedBox(height: 32),
                  _buildVoiceSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Account section (placeholder)
  // ---------------------------------------------------------------------------

  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'ACCOUNT'),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.person_outline,
                  color: AppTheme.textSecondary, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sign in to sync your practice',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 36,
                      child: OutlinedButton(
                        onPressed: null, // disabled placeholder
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.divider),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Voice section
  // ---------------------------------------------------------------------------

  /// The currently selected value for the dropdown.
  /// `null` means "Original" (WAV files).
  String? get _dropdownValue => _tts.selectedVoiceName;

  Widget _buildVoiceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'VOICE'),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _loading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _dropdownValue ?? '',
                          isExpanded: true,
                          dropdownColor: AppTheme.surface,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textPrimary,
                          ),
                          icon: const Icon(Icons.expand_more,
                              color: AppTheme.textSecondary),
                          items: [
                            const DropdownMenuItem<String>(
                              value: '',
                              child: Text('Original'),
                            ),
                            if (_voices != null)
                              ..._voices!.map((v) {
                                final name = v['name']!;
                                return DropdownMenuItem<String>(
                                  value: name,
                                  child: Text(_formatVoiceName(name)),
                                );
                              }),
                          ],
                          onChanged: (value) async {
                            if (value == null) return;
                            if (value.isEmpty) {
                              await _tts.selectVoice(null, null);
                            } else {
                              final voice = _voices!.firstWhere(
                                (v) => v['name'] == value,
                              );
                              await _tts.selectVoice(
                                  voice['name'], voice['locale']);
                            }
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                    if (_dropdownValue != null && _dropdownValue!.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          final voice = _voices!.firstWhere(
                            (v) => v['name'] == _dropdownValue,
                          );
                          _tts.preview(voice['name']!, voice['locale']!);
                        },
                        icon: const Icon(Icons.play_circle_outline,
                            color: AppTheme.textSecondary, size: 22),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 8),
        Text(
          _dropdownValue == null || _dropdownValue!.isEmpty
              ? 'Uses bundled voice files.'
              : 'Uses system text-to-speech.',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w300,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Make system voice names more readable.
  String _formatVoiceName(String raw) {
    // iOS voices look like "com.apple.voice.compact.en-US.Samantha"
    // Android voices look like "en-us-x-sfg#male_1-local"
    // Try to extract the human-friendly part.
    if (raw.contains('.')) {
      final parts = raw.split('.');
      return parts.last;
    }
    return raw;
  }
}

// =============================================================================
// Supporting widgets
// =============================================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
        color: AppTheme.textSecondary,
      ),
    );
  }
}

