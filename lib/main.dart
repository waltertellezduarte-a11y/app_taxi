import 'package:flutter/material.dart';
import 'ingreso_form.dart';
import 'package:hive_flutter/hive_flutter.dart';


///void main() => runApp(const AppTaxiApp()); esta línea la documento, porque se va a cambiar por otra para poder hacer funcionar el hive

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

/// Página principal: resumen del día + accesos rápidos
class HomeDashboardPage extends StatelessWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Valores de ejemplo (luego los conectamos a almacenamiento)
    const ingresosHoy = 180000;
    const gastosHoy = 35000;
    const mantenimientosMes = 2;

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
          Text(
            'Resumen de hoy',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _KpiCard(
                  title: 'Ingresos',
                  value: _money(ingresosHoy),
                  icon: Icons.attach_money,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _KpiCard(
                  title: 'Gastos',
                  value: _money(gastosHoy),
                  icon: Icons.receipt_long,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          _KpiCard(
            title: 'Mantenimientos (mes)',
            value: '$mantenimientosMes',
            icon: Icons.build,
          ),

          const SizedBox(height: 24),
          Text(
            'Accesos rápidos',
            style: Theme.of(context).textTheme.titleLarge,
          ),
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
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Próximo: formulario de ingresos')),
                  );
                },
              ),
              _QuickAction(
                title: 'Registrar gasto',
                icon: Icons.trending_down,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Próximo: formulario de gastos')),
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
          Text(
            'Últimos registros',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          const _LastItemTile(
            title: 'Ingreso',
            subtitle: 'Carrera + propina',
            trailing: '+ \$25.000',
            icon: Icons.trending_up,
          ),
          const _LastItemTile(
            title: 'Gasto',
            subtitle: 'Gasolina',
            trailing: '- \$40.000',
            icon: Icons.local_gas_station,
          ),
          const _LastItemTile(
            title: 'Mantenimiento',
            subtitle: 'Cambio de aceite (programado)',
            trailing: 'Hoy',
            icon: Icons.build,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Próximo: elegir tipo de registro')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
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
          Text(
            '¿Qué quieres registrar?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
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
            icon: Icons.build,
            title: 'Mantenimiento',
            subtitle: 'Taller, repuestos, revisiones',
            onTap: () {},
          ),
          _MenuTile(
            icon: Icons.photo_camera,
            title: 'Adjuntar foto',
            subtitle: 'Soportes: recibos, facturas (luego)',
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
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: const Center(
        child: Text('Próximo: reportes por día/semana/mes'),
      ),
    );
  }
}

class AjustesPage extends StatelessWidget {
  const AjustesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MenuTile(
            icon: Icons.backup,
            title: 'Respaldo',
            subtitle: 'Exportar/Importar (luego)',
            onTap: () {},
          ),
          _MenuTile(
            icon: Icons.lock,
            title: 'Seguridad',
            subtitle: 'PIN / huella (luego)',
            onTap: () {},
          ),
          _MenuTile(
            icon: Icons.info_outline,
            title: 'Acerca de',
            subtitle: 'APP Taxi v0.1',
            onTap: () {},
          ),
        ],
      ),
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

  const _LastItemTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.icon,
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
