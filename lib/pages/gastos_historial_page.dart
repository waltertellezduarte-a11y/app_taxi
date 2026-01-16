import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:app_taxi/storage/app_storage.dart';
import 'package:app_taxi/gasto_form_page.dart';

class GastosHistorialPage extends StatefulWidget {
  const GastosHistorialPage({super.key});

  @override
  State<GastosHistorialPage> createState() => _GastosHistorialPageState();
}

class _GastosHistorialPageState extends State<GastosHistorialPage> {
  String _fmtPesos(int v) => '\$${v.toString()}'; // luego lo mejoramos a COP bonito

  String _fmtFechaFromString(String s) {
    final d = DateTime.tryParse(s);
    if (d == null) return s;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    // Esta es TU box real (la que usa AppStorage)
    final box = Hive.box('app_taxi');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de gastos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GastoFormPage()),
          );
          setState(() {}); // por si vuelve y quieres ver el nuevo registro de una
        },
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, box, child) {
          final gastos = AppStorage.getGastos();
          final total = AppStorage.totalGastos();

          // Si tus mapas ya guardan fecha como String ISO (recomendado)
          gastos.sort((a, b) {
            final fa = DateTime.tryParse((a['fecha'] ?? '').toString()) ?? DateTime(1970);
            final fb = DateTime.tryParse((b['fecha'] ?? '').toString()) ?? DateTime(1970);
            return fb.compareTo(fa); // desc
          });

          return ListView(
            children: [
              const SizedBox(height: 12),

              // Tarjeta Total
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _fmtPesos(total),
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              const Divider(height: 1),

              // Lista
              if (gastos.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Aún no hay gastos registrados.'),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: gastos.length,
                  itemBuilder: (context, index) {
                    final g = gastos[index];

                    final monto = ((g['monto'] ?? 0) as num).toInt();
                    final categoria = (g['categoria'] ?? g['tipo'] ?? 'Gasto').toString();
                    final fechaStr = (g['fecha'] ?? '').toString();

                    return Column(
                      children: [
                        ListTile(
                          title: Text('${_fmtPesos(monto)}  •  $categoria'),
                          subtitle: Text(_fmtFechaFromString(fechaStr)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              await AppStorage.deleteGastoAt(index);
                              setState(() {});
                            },
                          ),
                        ),
                        const Divider(height: 1),
                      ],
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
