import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class YoutubePlaybackController {
  static final Set<html.IFrameElement> _frames = <html.IFrameElement>{};

  static void register(html.IFrameElement frame) => _frames.add(frame);
  static void unregister(html.IFrameElement frame) => _frames.remove(frame);

  static void pauseAll() {
    for (final frame in List<html.IFrameElement>.from(_frames)) {
      frame.contentWindow?.postMessage(
        '{"event":"command","func":"pauseVideo","args":""}',
        'https://www.youtube.com',
      );
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

  @override
  void initState() {
    super.initState();
    _viewType = 'youtube-${widget.videoId}-${identityHashCode(this)}';

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final frame = html.IFrameElement()
        ..src =
            'https://www.youtube.com/embed/${widget.videoId}?enablejsapi=1&playsinline=1'
        ..style.border = '0'
        ..allow =
            'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
        ..allowFullscreen = true;

      _frame = frame;
      YoutubePlaybackController.register(frame);
      return frame;
    });
  }

  @override
  void dispose() {
    final frame = _frame;
    if (frame != null) {
      frame.contentWindow?.postMessage(
        '{"event":"command","func":"pauseVideo","args":""}',
        'https://www.youtube.com',
      );
      YoutubePlaybackController.unregister(frame);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 16 / 9,
        child: HtmlElementView(viewType: _viewType),
      );
}
