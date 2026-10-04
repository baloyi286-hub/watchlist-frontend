import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class YoutubePlaybackController {
  static final Set<html.IFrameElement> _frames = <html.IFrameElement>{};

  static void register(html.IFrameElement frame) => _frames.add(frame);
  static void unregister(html.IFrameElement frame) => _frames.remove(frame);

  // Hard reset is intentional. A cross-origin YouTube iframe can ignore
  // postMessage pause commands while it is still initialising. Reloading the
  // embed guarantees that audio/video stops before a dialog or action opens.
  static void stopAll() {
    for (final frame in List<html.IFrameElement>.from(_frames)) {
      final src = frame.src;
      frame.src = 'about:blank';
      Future<void>.delayed(const Duration(milliseconds: 40), () {
        if (_frames.contains(frame)) frame.src = src;
      });
    }
  }
}

class YoutubeEmbed extends StatefulWidget {
  const YoutubeEmbed({super.key, required this.videoId});
  final String videoId;

  @override
  State<YoutubeEmbed> createState() => _YoutubeEmbedState();
}

class _YoutubeEmbedState extends State<YoutubeEmbed> {
  late final String _viewType;
  html.IFrameElement? _frame;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _viewType = 'youtube-${widget.videoId}-${identityHashCode(this)}';

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final frame = html.IFrameElement()
        ..src =
            'https://www.youtube.com/embed/${widget.videoId}?enablejsapi=1&playsinline=1&controls=0'
        ..style.border = '0'
        // Critical for web/trackpads: the cross-origin iframe otherwise
        // consumes wheel/trackpad events and Flutter never receives them.
        ..style.pointerEvents = 'none'
        ..allow =
            'autoplay; encrypted-media; picture-in-picture'
        ..allowFullscreen = true;

      _frame = frame;
      YoutubePlaybackController.register(frame);
      return frame;
    });
  }

  void _command(String command) {
    _frame?.contentWindow?.postMessage(
      '{"event":"command","func":"$command","args":""}',
      '*',
    );
  }

  void _togglePlayback() {
    setState(() => _playing = !_playing);
    _command(_playing ? 'playVideo' : 'pauseVideo');
  }

  @override
  void dispose() {
    final frame = _frame;
    if (frame != null) {
      frame.src = 'about:blank';
      YoutubePlaybackController.unregister(frame);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            HtmlElementView(viewType: _viewType),
            Center(
              child: IconButton.filled(
                onPressed: _togglePlayback,
                tooltip: _playing ? 'Pause trailer' : 'Play trailer',
                iconSize: 42,
                icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
              ),
            ),
          ],
        ),
      );
}
