import 'package:hive/hive.dart';

class AppStorage {
  static Box get _box => Hive.box('app_taxi');

  static const String _kIngresos = 'ingresos';

  // Obtener todos los ingresos
  static List<Map<String, dynamic>> getIngresos() {
    final raw = _box.get(_kIngresos);
    if (raw is List) {
      return raw
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  // Agregar un ingreso
  static Future<void> addIngreso(Map<String, dynamic> ingreso) async {
    final list = getIngresos();
    list.insert(0, ingreso); // el más nuevo arriba
    await _box.put(_kIngresos, list);
  }

  // Limpiar ingresos (útil para pruebas)
  static Future<void> clearIngresos() async {
    await _box.delete(_kIngresos);
  }
}
