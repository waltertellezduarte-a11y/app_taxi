import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:app_taxi/storage/app_storage.dart';
import 'package:app_taxi/ingreso_form_page.dart';
import 'package:app_taxi/gasto_form_page.dart';
import 'package:app_taxi/pages/ingresos_historial_page.dart';
import 'package:app_taxi/pages/gastos_historial_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('app_taxi');
  runApp(const AppTaxiApp());
}

class AppTaxiApp extends StatelessWidget {
  const AppTaxiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'APP Taxi',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.amber,
      ),
      home: const HomeShell(),
    );
  }
}

/// Contenedor con navegación inferior (Inicio, Registro, Reportes, Ajustes)
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _pages = const [
    HomeDashboardPage(),
    RegistroPage(),
    ReportesPage(),
    AjustesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Registro',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reportes',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}

/// Página principal: resumen + accesos rápidos + últimos registros
class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  // Si aún no tienes mantenimientos guardados, dejamos un valor fijo por ahora
  final int _mantenimientosMes = 2;

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('app_taxi');

    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, value, child) {
        final ingresosHoy = AppStorage.totalIngresosHoy();
        final gastosHoy = AppStorage.totalGastosHoy();
        final balanceHoy = ingresosHoy - gastosHoy;

        final ingresosMes = AppStorage.totalIngresosMes();
        final gastosMes = AppStorage.totalGastosMes();
        final balanceMes = ingresosMes - gastosMes;

        final ingresos = AppStorage.getIngresos();
        final gastos = AppStorage.getGastos();

        final lastIngreso = ingresos.isNotEmpty ? ingresos.first : null;
        final lastGasto = gastos.isNotEmpty ? gastos.first : null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('APP Taxi'),
            centerTitle: false,
            actions: [
              IconButton(
                tooltip: 'Buscar',
                onPressed: () {},
                icon: const Icon(Icons.search),
              ),
              IconButton(
                tooltip: 'Notificaciones',
                onPressed: () {},
                icon: const Icon(Icons.notifications_none),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Resumen de hoy', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),

              // KPIs (restaurados)
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      title: 'Ingresos (mes)',
                      value: _money(ingresosMes),
                      icon: Icons.trending_up,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _KpiCard(
                      title: 'Gastos (mes)',
                      value: _money(gastosMes),
                      icon: Icons.trending_down,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      title: 'Balance Hoy',
                      value: _money(balanceHoy),
                      icon: Icons.account_balance_wallet,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _KpiCard(
                      title: 'Balance (mes)',
                      value: _money(balanceMes),
                      icon: Icons.account_balance_wallet,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _KpiCard(
                title: 'Mantenimientos (mes)',
                value: '$_mantenimientosMes',
                icon: Icons.build,
              ),

              const SizedBox(height: 24),
              Text('Accesos rápidos', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _QuickAction(
                    title: 'Registrar ingreso',
                    icon: Icons.trending_up,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const IngresoFormPage()),
                      );
                    },
                  ),
                  _QuickAction(
                    title: 'Registrar gasto',
                    icon: Icons.trending_down,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GastoFormPage()),
                      );
                    },
                  ),
                  _QuickAction(
                    title: 'Mantenimiento',
                    icon: Icons.car_repair,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Próximo: registro de mantenimientos')),
                      );
                    },
                  ),
                  _QuickAction(
                    title: 'Pico y placa',
                    icon: Icons.event_busy,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Próximo: calendario pico y placa')),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Text('Últimos registros', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),

              _LastItemTile(
                title: 'Ingreso',
                subtitle: lastIngreso != null
                    ? (lastIngreso['concepto'] ??
                            lastIngreso['detalle'] ??
                            lastIngreso['metodo'] ??
                            'Ingreso')
                        .toString()
                    : 'Sin registros',
                trailing: lastIngreso != null
                    ? '+ ${_money(((lastIngreso['monto'] ?? 0) as num).toInt())}'
                    : '',
                icon: Icons.trending_up,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const IngresosHistorialPage()),
                  );
                },
              ),

              _LastItemTile(
                title: 'Gasto',
                subtitle: lastGasto != null
                    ? (lastGasto['categoria'] ??
                            lastGasto['tipo'] ??
                            lastGasto['detalle'] ??
                            'Gasto')
                        .toString()
                    : 'Sin registros',
                trailing: lastGasto != null
                    ? '- ${_money(((lastGasto['monto'] ?? 0) as num).toInt())}'
                    : '',
                icon: Icons.local_gas_station,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GastosHistorialPage()),
                  );
                },
              ),

              _LastItemTile(
                title: 'Mantenimiento',
                subtitle: 'Cambio de aceite (programado)',
                trailing: 'Hoy',
                icon: Icons.build,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Próximo: mantenimientos')),
                  );
                },
              ),
            ],
          ),

          // Restauramos el FAB "Nuevo" (sin perderlo)
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              _showNuevoMenu(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('Nuevo'),
          ),
        );
      },
    );
  }

  void _showNuevoMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.trending_up),
                title: const Text('Ingreso'),
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const IngresoFormPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.trending_down),
                title: const Text('Gasto'),
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GastoFormPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.build),
                title: const Text('Mantenimiento'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Próximo: registro de mantenimientos')),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class RegistroPage extends StatelessWidget {
  const RegistroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('¿Qué quieres registrar?', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.trending_up,
            title: 'Ingreso',
            subtitle: 'Dinero recibido en el día',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const IngresoFormPage()),
              );
            },
          ),
          _MenuTile(
            icon: Icons.trending_down,
            title: 'Gasto',
            subtitle: 'Dinero pagado en el día',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GastoFormPage()),
              );
            },
          ),
          _MenuTile(
            icon: Icons.build,
            title: 'Mantenimiento',
            subtitle: 'Taller, repuestos, revisiones (luego)',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class ReportesPage extends StatelessWidget {
  const ReportesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: null,
      body: Center(child: Text('Próximo: reportes por día/semana/mes')),
    );
  }
}

class AjustesPage extends StatelessWidget {
  const AjustesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: null,
      body: Center(child: Text('Ajustes')),
    );
  }
}

/// ----- Widgets reutilizables -----

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 6),
                  Text(value, style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickAction({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 34),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LastItemTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;
  final IconData icon;
  final VoidCallback? onTap;

  const _LastItemTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(trailing),
        onTap: onTap,
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }
}

String _money(int value) {
  // Formato simple sin paquetes: 180000 -> $180.000
  final s = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final reverseIndex = s.length - i;
    buffer.write(s[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) buffer.write('.');
  }
  return '\$${buffer.toString()}';
}
