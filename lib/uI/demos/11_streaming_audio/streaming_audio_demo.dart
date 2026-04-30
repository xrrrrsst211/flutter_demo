import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class StreamingAudioDemo extends StatefulWidget {
  const StreamingAudioDemo({super.key});

  @override
  State<StreamingAudioDemo> createState() => _StreamingAudioDemoState();
}

class _StreamingAudioDemoState extends State<StreamingAudioDemo> {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSubscription;

  bool _isLoading = true;
  String? _errorMessage;

  static const String _audioUrl =
      'https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3';

  @override
  void initState() {
    super.initState();
    _initAudio();
    _playerStateSubscription = _player.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        await _player.pause();
        await _player.seek(Duration.zero);
      }
    });
  }

  Future<void> _initAudio() async {
    try {
      await _player.setUrl(_audioUrl);
    } catch (error) {
      _errorMessage = 'Could not load stream: $error';
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.play();
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Playback error: $error');
    }
  }

  Future<void> _stop() async {
    await _player.pause();
    await _player.seek(Duration.zero);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours;

    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('11. Streaming audio'),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.podcasts_rounded,
                        size: 76,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Streaming audio with just_audio',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This demo streams one long audio file from a URL. It supports play, pause, buffering state, and seeking.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else ...[
                        StreamBuilder<Duration>(
                          stream: _player.positionStream,
                          builder: (context, positionSnapshot) {
                            final position = positionSnapshot.data ?? Duration.zero;
                            final duration = _player.duration ?? Duration.zero;
                            final max = duration.inMilliseconds.toDouble();
                            final value = position.inMilliseconds
                                .clamp(0, duration.inMilliseconds)
                                .toDouble();

                            return Column(
                              children: [
                                Slider(
                                  min: 0,
                                  max: max <= 0 ? 1 : max,
                                  value: max <= 0 ? 0 : value,
                                  onChanged: max <= 0
                                      ? null
                                      : (newValue) {
                                          _player.seek(
                                            Duration(milliseconds: newValue.round()),
                                          );
                                        },
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_formatDuration(position)),
                                    Text(_formatDuration(duration)),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        StreamBuilder<PlayerState>(
                          stream: _player.playerStateStream,
                          builder: (context, snapshot) {
                            final state = snapshot.data;
                            final processingState = state?.processingState;
                            final playing = state?.playing ?? false;
                            final isBusy = processingState == ProcessingState.loading ||
                                processingState == ProcessingState.buffering;

                            return Column(
                              children: [
                                if (isBusy) ...[
                                  const LinearProgressIndicator(),
                                  const SizedBox(height: 12),
                                ],
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FilledButton.icon(
                                      onPressed: isBusy ? null : _togglePlayPause,
                                      icon: Icon(
                                        playing ? Icons.pause : Icons.play_arrow,
                                      ),
                                      label: Text(playing ? 'Pause' : 'Play'),
                                    ),
                                    const SizedBox(width: 12),
                                    OutlinedButton.icon(
                                      onPressed: _stop,
                                      icon: const Icon(Icons.stop),
                                      label: const Text('Stop'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Status: ${processingState?.name ?? 'idle'}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            );
                          },
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
