import 'dart:convert';
import 'package:http/http.dart' as http;

class WatchCueApi {
  WatchCueApi({String? baseUrl}) : baseUrl = baseUrl ?? const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://watchlist-backend-one.vercel.app/api/v1');
  final String baseUrl;
  Future<List<Map<String,dynamic>>> list({bool includeWatched=true}) async {final r=await http.get(Uri.parse('$baseUrl/watch-items?includeWatched=$includeWatched'));_ok(r);return (jsonDecode(r.body) as List).cast<Map<String,dynamic>>();}
  Future<void> add({required String title,required String type,required String priority,String? sourceUrl,String? whySaved}) async {final r=await http.post(Uri.parse('$baseUrl/watch-items'),headers:_json,body:jsonEncode({'title':title,'itemType':type,'priority':priority,'sourceUrl':sourceUrl,'whySaved':whySaved,'autoFindTrailer':true}));_ok(r);}
  Future<void> mark(String id,bool watched) async {final action=watched?'watched':'unwatched';final r=await http.post(Uri.parse('$baseUrl/watch-items/$id/$action'));_ok(r);}
  Future<void> delete(String id) async {final r=await http.delete(Uri.parse('$baseUrl/watch-items/$id'));_ok(r);}
  Future<void> refreshTrailer(String id) async {final r=await http.post(Uri.parse('$baseUrl/watch-items/$id/trailer/refresh'));_ok(r);}
  Future<Map<String,dynamic>> tvSettings() async {final r=await http.get(Uri.parse('$baseUrl/tv/settings'));_ok(r);return jsonDecode(r.body);}
  Future<void> saveTvSettings(Map<String,dynamic> body) async {final r=await http.put(Uri.parse('$baseUrl/tv/settings'),headers:_json,body:jsonEncode(body));_ok(r);}
  Future<bool> sendTvNow() async {final r=await http.post(Uri.parse('$baseUrl/tv/send-watchlist'));_ok(r);return jsonDecode(r.body)['notificationSent']==true;}
  static const _json={'Content-Type':'application/json'};
  void _ok(http.Response r){if(r.statusCode<200||r.statusCode>=300){throw Exception(r.body.isEmpty?'HTTP ${r.statusCode}':r.body);}}
}
