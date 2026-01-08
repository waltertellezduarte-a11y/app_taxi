import 'package:flutter/material.dart';
import 'package:app_taxi/storage/app_storage.dart';


class IngresoFormPage extends StatefulWidget {
  const IngresoFormPage({super.key});

  @override
  State<IngresoFormPage> createState() => _IngresoFormPageState();
}

class _IngresoFormPageState extends State<IngresoFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _montoCtrl = TextEditingController();
  final _notaCtrl = TextEditingController();

  DateTime _fecha = DateTime.now();
  String _metodo = 'Efectivo';

  @override
  void dispose() {
    _montoCtrl.dispose();
    _notaCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFecha() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  Future<void> _guardar() async {
  if (!_formKey.currentState!.validate()) return;

  final monto = int.parse(_montoCtrl.text);

  final ingreso = {
    'monto': monto,
    'metodo': _metodo,
    'fecha': _fecha.toIso8601String(),
    'nota': _notaCtrl.text.trim(),
  };

  await AppStorage.addIngreso(ingreso);

  if (!mounted) return; // ✅ clave para quitar el warning

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Ingreso guardado')),
  );

  Navigator.pop(context);
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar ingreso')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _montoCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Monto (COP)',
                    hintText: 'Ej: 25000',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final text = (v ?? '').trim();
                    if (text.isEmpty) return 'Escribe el monto';
                    final n = int.tryParse(text);
                    if (n == null) return 'Debe ser un número';
                    if (n <= 0) return 'Debe ser mayor a 0';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  initialValue: _metodo,
                  items: const [
                    DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                    DropdownMenuItem(value: 'Nequi', child: Text('Nequi')),
                    DropdownMenuItem(value: 'Daviplata', child: Text('Daviplata')),
                    DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
                    DropdownMenuItem(value: 'Transferencia', child: Text('Transferencia')),
                  ],
                  onChanged: (v) => setState(() => _metodo = v ?? 'Efectivo'),
                  decoration: const InputDecoration(
                    labelText: 'Método de pago',
                    prefixIcon: Icon(Icons.payment),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                InkWell(
                  onTap: _pickFecha,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${_fecha.day}/${_fecha.month}/${_fecha.year}'),
                        const Icon(Icons.edit_calendar),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _notaCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Nota (opcional)',
                    hintText: 'Ej: Carrera aeropuerto, propina, etc.',
                    prefixIcon: Icon(Icons.notes),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _guardar,
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar ingreso'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
