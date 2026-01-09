import 'package:flutter/material.dart';
import 'package:app_taxi/storage/app_storage.dart';
import 'package:app_taxi/ingreso_form_page.dart';

class IngresosHistorialPage extends StatefulWidget {
  const IngresosHistorialPage({super.key});

  @override
  State<IngresosHistorialPage> createState() => _IngresosHistorialPageState();
}

class _IngresosHistorialPageState extends State<IngresosHistorialPage> {
  List<Map<String, dynamic>> _ingresos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);

    final list = AppStorage.getIngresos();

    // Ordenar por fecha desc (más reciente primero)
    list.sort((a, b) {
      final fa = (a['fecha'] ?? '').toString();
      final fb = (b['fecha'] ?? '').toString();
      return fb.compareTo(fa);
    });

    if (!mounted) return;
    setState(() {
      _ingresos = list;
      _loading = false;
    });
  }

  int get _total =>
      _ingresos.fold<int>(0, (sum, e) => sum + ((e['monto'] ?? 0) as int));

  String _fmtFecha(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Future<void> _nuevoIngreso() async {
    final saved = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const IngresoFormPage()),
    );

    if (saved == true) {
      await _cargar();
    }
  }

  Future<void> _eliminar(int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar ingreso'),
        content: const Text('¿Seguro que deseas eliminar este ingreso?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    _ingresos.removeAt(index);
    await AppStorage.setIngresos(_ingresos);

    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ingreso eliminado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de ingresos'),
        actions: [
          IconButton(
            onPressed: _cargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _nuevoIngreso,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Resumen
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.attach_money),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total registrado',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '\$$_total',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Divider(height: 1),

                // Lista
                Expanded(
                  child: _ingresos.isEmpty
                      ? const Center(child: Text('Aún no tienes ingresos'))
                      : ListView.separated(
                          itemCount: _ingresos.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final e = _ingresos[i];
                            final monto = (e['monto'] ?? 0);
                            final metodo = (e['metodo'] ?? '').toString();
                            final nota = (e['nota'] ?? '').toString();
                            final fecha = (e['fecha'] ?? '').toString();

                            return ListTile(
                              title: Text('\$$monto  •  $metodo'),
                              subtitle: Text(
                                '${_fmtFecha(fecha)}${nota.trim().isNotEmpty ? "  •  $nota" : ""}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _eliminar(i),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
