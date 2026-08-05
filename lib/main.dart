import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AzamApp());
}

class AzamApp extends StatelessWidget {
  const AzamApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'نظام عزام - جوال',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0d6efd),
        useMaterial3: true,
        fontFamily: 'Arial',
      ),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      home: const BootScreen(),
    );
  }
}

class BootScreen extends StatefulWidget {
  const BootScreen({super.key});
  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen> {
  String? baseUrl;
  String? apiToken;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      baseUrl = sp.getString('baseUrl');
      apiToken = sp.getString('apiToken');
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (baseUrl == null || apiToken == null) {
      return const SetupScreen();
    }
    return const HomeScreen();
  }
}

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});
  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _url = TextEditingController();
  final _token = TextEditingController();
  bool testing = false;
  String? testResult;

  Future<void> _test() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { testing = true; testResult = null; });
    try {
      final dio = Dio(BaseOptions(
        baseUrl: _url.text.trim(),
        headers: {'X-Azam-Token': _token.text.trim()},
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 12),
      ));
      final r = await dio.get('/api/changes.php', queryParameters: {
        'since': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'tables': 'customers',
        'limit': 1,
      });
      if (r.statusCode == 200 && r.data is Map && r.data['ok'] == true) {
        testResult = 'نجح الاتصال';
      } else {
        testResult = 'تعذر الاتصال';
      }
    } catch (e) {
      testResult = 'خطأ: $e';
    } finally {
      setState(() { testing = false; });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final sp = await SharedPreferences.getInstance();
    await sp.setString('baseUrl', _url.text.trim());
    await sp.setString('apiToken', _token.text.trim());
    if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إعداد الاتصال')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _url,
                  decoration: const InputDecoration(labelText: 'رابط الخادم (BASE_URL)'),
                  validator: (v) => (v==null||v.trim().isEmpty)? 'مطلوب': null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _token,
                  decoration: const InputDecoration(labelText: 'مفتاح API'),
                  validator: (v) => (v==null||v.trim().isEmpty)? 'مطلوب': null,
                ),
                const SizedBox(height: 12),
                Row(children: [
                  ElevatedButton(onPressed: testing? null : _test, child: const Text('اختبار الاتصال')),
                  const SizedBox(width: 8),
                  OutlinedButton(onPressed: testing? null : _save, child: const Text('حفظ والمتابعة')),
                ]),
                if (testing) const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator()),
                if (testResult!=null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(testResult!)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? baseUrl;
  String? apiToken;
  bool syncing=false;
  String status='';

  Future<void> _loadCfg() async {
    final sp = await SharedPreferences.getInstance();
    baseUrl = sp.getString('baseUrl');
    apiToken = sp.getString('apiToken');
  }

  Future<void> _syncNow() async {
    setState(() { syncing=true; status=''; });
    try{
      await _loadCfg();
      if(baseUrl==null || apiToken==null) throw 'إعداد مفقود';
      final dio = Dio(BaseOptions(baseUrl: baseUrl!, headers:{'X-Azam-Token': apiToken!}));
      final since = DateTime.now().subtract(const Duration(days: 1)).toIso8601String();
      final r = await dio.get('/api/changes.php', queryParameters: {'since': since, 'limit': 100});
      if(r.statusCode==200 && r.data is Map && r.data['ok']==true){
        status='تم الجلب: '+((r.data['data'] as Map).keys.length).toString()+' جدول';
      } else {
        status='فشل الجلب';
      }
    }catch(e){ status='خطأ: $e'; }
    finally{ setState(() { syncing=false; }); }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('نظام عزام - جوال')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children:[
                ElevatedButton.icon(onPressed: syncing? null : _syncNow, icon: const Icon(Icons.sync), label: const Text('مزامنة الآن')),
                const SizedBox(width: 8),
                OutlinedButton.icon(onPressed: () async{ Navigator.of(context).push(MaterialPageRoute(builder: (_)=>const SetupScreen())); }, icon: const Icon(Icons.settings), label: const Text('الإعدادات')),
              ]),
              const SizedBox(height: 12),
              if(syncing) const LinearProgressIndicator(),
              if(status.isNotEmpty) Padding(padding: const EdgeInsets.only(top:8), child: Text(status)),
              const SizedBox(height: 16),
              const Text('هذا نموذج أولي. الشاشات التفصيلية (العملاء/الموردون/الفواتير) ستُضاف في الخطوة التالية.'),
            ],
          ),
        ),
      ),
    );
  }
}
