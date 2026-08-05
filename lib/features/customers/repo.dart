import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/api.dart';
import 'models.dart';

class CustomersRepo {
  final AzamApi api;
  CustomersRepo(this.api);

  Future<List<Customer>> pullSince(String since) async {
    try{
      final Response r = await api.dio.get('/api/changes.php', queryParameters: {
        'since': since,
        'tables': 'customers',
        'limit': 2000,
      });
      if(r.statusCode==200 && r.data is Map && r.data['ok']==true){
        final data = r.data['data'] as Map;
        final rows = (data['customers'] as List?) ?? [];
        return rows.map((e)=>Customer.fromMap(e)).toList();
      }
      return [];
    }catch(_){ return []; }
  }

  Future<bool> pushUpserts(List<Map<String,dynamic>> rows, {String device='mobile'}) async {
    if(rows.isEmpty) return true;
    try{
      final body = jsonEncode({'device': device, 'data': {'customers': rows}});
      final Response r = await api.dio.post('/api/apply_changes.php', data: body, options: Options(headers:{'Content-Type':'application/json'}));
      if(r.statusCode==200 && r.data is Map && r.data['ok']==true) return true;
      return false;
    }catch(_){ return false; }
  }
}
