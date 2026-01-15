import 'package:flutter/material.dart';
import 'package:app_taxi/storage/app_storage.dart';

class GastoFormPage extends StatefulWidget {
  const GastoFormPage({super.key});

  @override
  State<GastoFormPage> createState() => _GastoFormPageState();
}

class _GastoFormPageState extends State<GastoFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _montoCtrl = TextEditingController();
  final _detalleCtrl = TextEditingController();

  String _categoria = 'Combustible';
  DateTime _fecha = DateTime.now();

  @override
  void dispose() {
    _montoCtrl.dispose();
    _detalleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final raw = _montoCtrl.text.replaceAll('.', '').replaceAll(',', '').trim();
    final monto = int.parse(raw);

    final gasto = <String, dynamic>{
      'fecha': _fecha.toIso8601String(),
      'monto': monto,
      'categoria': _categoria,
      'detalle': _detalleCtrl.text.trim(),
    };

    await AppStorage.addGasto(gasto);

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gasto guardado ✅')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar gasto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha'),
                subtitle: Text(
                  '${_fecha.year}-${_fecha.month.toString().padLeft(2, '0')}-${_fecha.day.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.calendar_month),
                onTap: _pickFecha,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _categoria,
                items: const [
                  DropdownMenuItem(value: 'Combustible', child: Text('Combustible')),
                  DropdownMenuItem(value: 'Mantenimiento', child: Text('Mantenimiento')),
                  DropdownMenuItem(value: 'Peajes', child: Text('Peajes')),
                  DropdownMenuItem(value: 'Lavado', child: Text('Lavado')),
                  DropdownMenuItem(value: 'Multas', child: Text('Multas')),
                  DropdownMenuItem(value: 'Otros', child: Text('Otros')),
                ],
                onChanged: (v) => setState(() => _categoria = v ?? 'Otros'),
                decoration: const InputDecoration(labelText: 'Categoría'),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _montoCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  prefixText: '\$ ',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingresa un monto';
                  final raw = v.replaceAll('.', '').replaceAll(',', '').trim();
                  final n = int.tryParse(raw);
                  if (n == null || n <= 0) return 'Monto inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _detalleCtrl,
                decoration: const InputDecoration(labelText: 'Detalle (opcional)'),
              ),
              const SizedBox(height: 20),

              FilledButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.save),
                label: const Text('Guardar gasto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
