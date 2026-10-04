import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api.dart';
import 'youtube_embed.dart';

void main()=>runApp(const WatchCueApp());

class WatchCueScrollBehavior extends MaterialScrollBehavior {
 const WatchCueScrollBehavior();

 @override
 Set<PointerDeviceKind> get dragDevices => {
   PointerDeviceKind.touch,
   PointerDeviceKind.mouse,
   PointerDeviceKind.trackpad,
   PointerDeviceKind.stylus,
   PointerDeviceKind.unknown,
 };
}
class WatchCueApp extends StatelessWidget{
 const WatchCueApp({super.key});
 @override Widget build(BuildContext context)=>MaterialApp(debugShowCheckedModeBanner:false,title:'WatchCue',scrollBehavior:const WatchCueScrollBehavior(),themeMode:ThemeMode.dark,theme:ThemeData(useMaterial3:true,colorSchemeSeed:Colors.deepPurple,brightness:Brightness.dark),home:const HomePage());
}
class HomePage extends StatefulWidget{const HomePage({super.key});@override State<HomePage> createState()=>_HomePageState();}
class _HomePageState extends State<HomePage>{
 final api=WatchCueApi(); List<Map<String,dynamic>> items=[]; bool loading=true; String? error; int tab=0;
 @override void initState(){super.initState();_load();}
 Future<void> _load() async {setState((){loading=true;error=null;});try{items=await api.list();}catch(e){error=e.toString();}if(mounted)setState(()=>loading=false);}
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('WatchCue'),actions:[IconButton(onPressed:_load,icon:const Icon(Icons.refresh))]),body:tab==0?_watchlist():const TvSettingsView(),floatingActionButton:tab==0?FloatingActionButton.extended(onPressed:_add,icon:const Icon(Icons.add),label:const Text('Add')):null,bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(i)=>setState(()=>tab=i),destinations:const [NavigationDestination(icon:Icon(Icons.playlist_play),label:'Watchlist'),NavigationDestination(icon:Icon(Icons.tv),label:'TV reminders')]));
 Widget _watchlist(){if(loading)return const Center(child:CircularProgressIndicator());if(error!=null)return Center(child:Padding(padding:const EdgeInsets.all(24),child:Text('$error\n\nCheck API_BASE_URL and backend.')));if(items.isEmpty)return const Center(child:Text('Nothing saved yet.\nTap Add when social media gives you something to watch.',textAlign:TextAlign.center));return RefreshIndicator(onRefresh:_load,child:ListView.builder(padding:const EdgeInsets.all(12),itemCount:items.length,itemBuilder:(c,i)=>_card(items[i])));}
 Widget _card(Map<String,dynamic> x){final watched=x['status']=='WATCHED';return Card(clipBehavior:Clip.antiAlias,child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Expanded(child:Text(x['title']??'',style:Theme.of(context).textTheme.titleLarge)),Chip(label:Text(_priority(x['priority'])))]),Text('${x['itemType']} • ${watched?'Watched':'Unwatched'}'),if((x['whySaved']??'').toString().isNotEmpty)Padding(padding:const EdgeInsets.only(top:8),child:Text('Why I saved this: ${x['whySaved']}')),if(x['youtubeVideoId']!=null)Padding(padding:const EdgeInsets.only(top:12),child:YoutubeEmbed(videoId:x['youtubeVideoId'])),const SizedBox(height:8),Wrap(spacing:8,runSpacing:4,children:[FilledButton.tonalIcon(onPressed:()async{await api.mark(x['id'],!watched);_load();},icon:Icon(watched?Icons.undo:Icons.done),label:Text(watched?'Unwatch':'Watched')),if(x['youtubeVideoId']==null)TextButton.icon(onPressed:()async{YoutubePlaybackController.pauseAll();try{await api.refreshTrailer(x['id']);await _load();}catch(e){_snack(e.toString());}},icon:const Icon(Icons.movie_filter),label:const Text('Find trailer')),if((x['sourceUrl']??'').toString().isNotEmpty)TextButton.icon(onPressed:()=>launchUrl(Uri.parse(x['sourceUrl'])),icon:const Icon(Icons.open_in_new),label:const Text('Source')),TextButton.icon(onPressed:()async{await api.delete(x['id']);_load();},icon:const Icon(Icons.delete_outline),label:const Text('Remove'))])])));}
 String _priority(String? p)=>switch(p){'MUST_WATCH'=>'🔥 Must watch','INTERESTED'=>'★ Interested',_=>'Maybe later'};
 Future<void> _add() async {YoutubePlaybackController.pauseAll();final title=TextEditingController(),source=TextEditingController(),why=TextEditingController();String type='MOVIE',priority='INTERESTED';final ok=await showDialog<bool>(context:context,builder:(ctx)=>StatefulBuilder(builder:(ctx,setD)=>AlertDialog(title:const Text('Add to WatchCue'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[TextField(controller:title,autofocus:true,decoration:const InputDecoration(labelText:'Title')),const SizedBox(height:8),DropdownButtonFormField(value:type,decoration:const InputDecoration(labelText:'Type'),items:['MOVIE','SERIES','DOCUMENTARY','ANIME','YOUTUBE','SPORTS','OTHER'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(v)=>setD(()=>type=v!)),const SizedBox(height:8),DropdownButtonFormField(value:priority,decoration:const InputDecoration(labelText:'Priority'),items:const [DropdownMenuItem(value:'MUST_WATCH',child:Text('🔥 Must watch')),DropdownMenuItem(value:'INTERESTED',child:Text('★ Interested')),DropdownMenuItem(value:'MAYBE_LATER',child:Text('Maybe later'))],onChanged:(v)=>setD(()=>priority=v!)),const SizedBox(height:8),TextField(controller:source,decoration:const InputDecoration(labelText:'Social/source link (optional)')),const SizedBox(height:8),TextField(controller:why,decoration:const InputDecoration(labelText:'Why I saved this (optional)'))])),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Save + find trailer'))])));if(ok==true&&title.text.trim().isNotEmpty){try{await api.add(title:title.text.trim(),type:type,priority:priority,sourceUrl:source.text.trim().isEmpty?null:source.text.trim(),whySaved:why.text.trim().isEmpty?null:why.text.trim());await _load();}catch(e){_snack(e.toString());}}}
 void _snack(String m){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(m)));}
}

class TvSettingsView extends StatefulWidget {
  const TvSettingsView({super.key});

  @override
  State<TvSettingsView> createState() => _TvSettingsViewState();
}

class _TvSettingsViewState extends State<TvSettingsView> {
  final api = WatchCueApi();
  bool loading = true;
  bool enabled = true;
  bool onStart = true;
  bool periodic = false;
  bool onlyUnwatched = true;
  int period = 180;
  int maxItems = 5;
  String deviceId = 'living-room-tv';
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await api.tvSettings();
      enabled = s['enabled'] ?? true;
      onStart = s['notifyOnTvStart'] ?? true;
      periodic = s['periodicEnabled'] ?? false;
      period = s['periodMinutes'] ?? 180;
      maxItems = s['maxItems'] ?? 5;
      onlyUnwatched = s['onlyUnwatched'] ?? true;
      deviceId = s['deviceId'] ?? 'living-room-tv';
    } catch (e) {
      error = e.toString();
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> _save() async {
    try {
      await api.saveTvSettings({
        'enabled': enabled,
        'notifyOnTvStart': onStart,
        'periodicEnabled': periodic,
        'periodMinutes': period,
        'maxItems': maxItems,
        'onlyUnwatched': onlyUnwatched,
        'deviceId': deviceId,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('TV settings saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _sendNow() async {
    try {
      final sent = await api.sendTvNow();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(sent ? 'Sent to TV' : 'Nothing to send')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text(error!));
    }

    final periodItems = <DropdownMenuItem<int>>[
      for (final minutes in const [60, 120, 180, 360, 720, 1440])
        DropdownMenuItem<int>(
          value: minutes,
          child: Text(minutes == 60 ? '1 hour' : '${minutes ~/ 60} hours'),
        ),
    ];

    final maxItemChoices = <DropdownMenuItem<int>>[
      for (final count in const [3, 5, 8, 10])
        DropdownMenuItem<int>(
          value: count,
          child: Text('$count'),
        ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'TV reminders',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Enable TV reminders'),
          value: enabled,
          onChanged: (value) => setState(() => enabled = value),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('When TV turns on'),
          subtitle: const Text('TV app calls POST /api/v1/tv/online'),
          value: onStart,
          onChanged: enabled
              ? (value) => setState(() => onStart = value)
              : null,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Periodic reminders'),
          value: periodic,
          onChanged: enabled
              ? (value) => setState(() => periodic = value)
              : null,
        ),
        if (periodic)
          DropdownButtonFormField<int>(
            initialValue: period,
            decoration: const InputDecoration(labelText: 'Every'),
            items: periodItems,
            onChanged: (value) {
              if (value != null) setState(() => period = value);
            },
          ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          initialValue: maxItems,
          decoration: const InputDecoration(labelText: 'Maximum items on TV'),
          items: maxItemChoices,
          onChanged: (value) {
            if (value != null) setState(() => maxItems = value);
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Only unwatched items'),
          value: onlyUnwatched,
          onChanged: (value) => setState(() => onlyUnwatched = value),
        ),
        TextFormField(
          initialValue: deviceId,
          decoration: const InputDecoration(labelText: 'TV device ID'),
          onChanged: (value) => deviceId = value,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save),
          label: const Text('Save settings'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _sendNow,
          icon: const Icon(Icons.send_to_mobile),
          label: const Text('Send watchlist to TV now'),
        ),
        const SizedBox(height: 12),
        const Text(
          'TV startup contract:\n'
          'POST /api/v1/tv/online\n'
          '{"deviceId":"living-room-tv"}',
        ),
      ],
    );
  }
}
