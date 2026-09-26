import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class YoutubeEmbed extends StatefulWidget {
  const YoutubeEmbed({super.key, required this.videoId});
  final String videoId;
  @override State<YoutubeEmbed> createState()=>_YoutubeEmbedState();
}
class _YoutubeEmbedState extends State<YoutubeEmbed>{
  late final String _viewType;
  @override void initState(){
    super.initState(); _viewType='youtube-${widget.videoId}-${identityHashCode(this)}';
    ui_web.platformViewRegistry.registerViewFactory(_viewType,(int viewId){
      final frame=html.IFrameElement()..src='https://www.youtube.com/embed/${widget.videoId}'..style.border='0'..allow='accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture'..allowFullscreen=true;
      return frame;
    });
  }
  @override Widget build(BuildContext context)=>AspectRatio(aspectRatio:16/9,child:HtmlElementView(viewType:_viewType));
}
