import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioDemo extends StatefulWidget {
  const AudioDemo({super.key});

  @override
  State<AudioDemo> createState() => _AudioDemoState();
}

class _AudioDemoState extends State<AudioDemo> {
  final Map<String, AudioPlayer> _players = {
    'click': AudioPlayer(),
    'success': AudioPlayer(),
    'error': AudioPlayer(),
  };

  bool _isLoading = true;
  String? _errorMessage;
  String _lastSound = 'Nothing yet';

  @override
  void initState() {
    super.initState();
    _loadSounds();
  }

  Future<void> _loadSounds() async {
    try {
      await Future.wait([
        _players['click']!.setAsset('assets/audio/click.wav'),
        _players['success']!.setAsset('assets/audio/success.wav'),
        _players['error']!.setAsset('assets/audio/error.wav'),
      ]);
    } catch (error) {
      _errorMessage = 'Audio load error: $error';
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _playSound(String key, String label) async {
    final player = _players[key];
    if (player == null) return;
    try {
      await player.seek(Duration.zero);
      player.play();
      setState(() => _lastSound = label);
    } catch (error) {
      setState(() => _errorMessage = 'Play error: $error');
    }
  }

  @override
  void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('10. Audio Demo'),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.music_note_rounded, size: 72, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text('Short audio clips with just_audio', textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Tap a button to play a small local sound from assets/audio.', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    FilledButton.icon(onPressed: () => _playSound('click', 'Click sound'), icon: const Icon(Icons.touch_app), label: const Text('Play click')),
                    const SizedBox(height: 12),
                    FilledButton.icon(onPressed: () => _playSound('success', 'Success sound'), icon: const Icon(Icons.check_circle), label: const Text('Play success')),
                    const SizedBox(height: 12),
                    FilledButton.icon(onPressed: () => _playSound('error', 'Error sound'), icon: const Icon(Icons.warning), label: const Text('Play error')),
                    const SizedBox(height: 24),
                    Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('Last played: $_lastSound', textAlign: TextAlign.center))),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error)),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
