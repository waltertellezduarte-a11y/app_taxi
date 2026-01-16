import 'package:hive/hive.dart';

class AppStorage {
  static Box get _box => Hive.box('app_taxi');

  static const String _kIngresos = 'ingresos';
  static const String _kGastos = 'gastos';

  // ===================== INGRESOS =====================

  static List<Map<String, dynamic>> getIngresos() {
    final raw = _box.get(_kIngresos);
    if (raw is List) {
      return raw
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  static Future<void> addIngreso(Map<String, dynamic> ingreso) async {
    final list = getIngresos();
    list.insert(0, ingreso);
    await _box.put(_kIngresos, list);
  }

  static Future<void> setIngresos(List<Map<String, dynamic>> ingresos) async {
    await _box.put(_kIngresos, ingresos);
  }

  static Future<void> clearIngresos() async {
    await _box.delete(_kIngresos);
  }

  // ===================== GASTOS =====================

  static List<Map<String, dynamic>> getGastos() {
    final raw = _box.get(_kGastos);
    if (raw is List) {
      return raw
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  static Future<void> addGasto(Map<String, dynamic> gasto) async {
    final list = getGastos();
    list.insert(0, gasto);
    await _box.put(_kGastos, list);
  }

  static Future<void> setGastos(List<Map<String, dynamic>> gastos) async {
    await _box.put(_kGastos, gastos);
  }

  static Future<void> clearGastos() async {
    await _box.delete(_kGastos);
  }

  static int totalIngresosHoy() {
  final hoy = DateTime.now();
  final ymd = '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';

  return getIngresos()
      .where((e) => (e['fecha'] ?? '').toString().startsWith(ymd))
      .fold<int>(0, (sum, e) => sum + ((e['monto'] ?? 0) as num).toInt());
  }

  static int totalGastosHoy() {
  final hoy = DateTime.now();
  final ymd = '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';

  return getGastos()
      .where((e) => (e['fecha'] ?? '').toString().startsWith(ymd))
      .fold<int>(0, (sum, e) => sum + ((e['monto'] ?? 0) as num).toInt());
  }

  static int totalIngresosMes() {
  final now = DateTime.now();
  return getIngresos()
      .where((e) {
        final f = DateTime.tryParse((e['fecha'] ?? '').toString());
        return f != null && f.year == now.year && f.month == now.month;
      })
      .fold<int>(0, (sum, e) => sum + ((e['monto'] ?? 0) as num).toInt());
  }

  static int totalGastosMes() {
  final now = DateTime.now();
  return getGastos()
      .where((e) {
        final f = DateTime.tryParse((e['fecha'] ?? '').toString());
        return f != null && f.year == now.year && f.month == now.month;
      })
      .fold<int>(0, (sum, e) => sum + ((e['monto'] ?? 0) as num).toInt());
  }

  static Future<void> deleteGastoAt(int index) async {
  final list = getGastos();
  if (index < 0 || index >= list.length) return;
  list.removeAt(index);
  await _box.put(_kGastos, list);
  }

  static int totalGastos() {
  return getGastos()
      .fold<int>(0, (sum, e) => sum + ((e['monto'] ?? 0) as num).toInt());
  }


}
