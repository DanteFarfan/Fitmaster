import 'package:flutter/material.dart';
import 'package:myapp/view/home_screen.dart';
import 'package:myapp/model/plan_nutricion.dart';
import 'package:myapp/database/db_helper.dart';

class PlanNutricionScreen extends StatefulWidget {
  const PlanNutricionScreen({super.key});

  @override
  State<PlanNutricionScreen> createState() => _PlanNutricionScreenState();
}

class _PlanNutricionScreenState extends State<PlanNutricionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  String _sexo = 'Masculino'; // Cambiado de _genero a _sexo
  String _objetivo = 'Bajar de peso';
  double? _calorias;
  PlanNutricion? _planNutricion;

  // Declara variables para los valores seleccionados en los dropdowns
  final _sexoKey =
      GlobalKey<FormFieldState>(); // Cambiado de _generoKey a _sexoKey
  final _objetivoKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    super.initState();
    _cargarPlanGuardado();
  }

  Future<void> _cargarPlanGuardado() async {
    final plan = await DBHelper.getPlanNutricionUsuarioActivo();
    if (plan != null) {
      setState(() {
        _planNutricion = plan;
        _pesoController.text = plan.peso.toString();
        _alturaController.text = plan.altura.toString();
        _edadController.text = plan.edad.toString();
        _sexo = plan.sexo; // Cambiado de genero a sexo
        _objetivo = plan.objetivo;
        _calorias = plan.calorias;
      });
    }
  }

  void _calcularCalorias() async {
    if (_formKey.currentState!.validate()) {
      final peso = double.parse(_pesoController.text);
      final altura = double.parse(_alturaController.text);
      final edad = int.parse(_edadController.text);

      // Obtén los valores actuales de los dropdowns usando sus keys
      final sexoActual = _sexoKey.currentState?.value ?? _sexo;
      final objetivoActual = _objetivoKey.currentState?.value ?? _objetivo;

      // Verifica si hay usuario activo
      final usuario = await DBHelper.getUsuarioActivo();
      if (usuario == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Debes iniciar sesión para calcular y guardar tu plan nutricional.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Fórmula de Harris-Benedict (simplificada)
      double tmb;
      if (sexoActual == 'Masculino') {
        tmb = 88.36 + (13.4 * peso) + (4.8 * altura) - (5.7 * edad);
      } else {
        tmb = 447.6 + (9.2 * peso) + (3.1 * altura) - (4.3 * edad);
      }

      // Ajuste según objetivo
      double calorias;
      if (objetivoActual == 'Bajar de peso') {
        calorias = tmb - 500;
      } else {
        calorias = tmb + 500;
      }

      if (calorias <= 0) {
        setState(() {
          _calorias = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'El cálculo de calorías no puede ser menor o igual a cero. Revisa tus datos.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final plan = PlanNutricion(
        idUsuario: usuario.id,
        peso: peso,
        altura: altura,
        edad: edad,
        sexo: sexoActual, // Cambiado de genero a sexo
        objetivo: objetivoActual,
        calorias: calorias,
      );

      await DBHelper.savePlanNutricion(plan);
      await DBHelper.saveHistorialPlanNutricion(plan);

      setState(() {
        _calorias = calorias;
        _planNutricion = plan;
        _sexo = sexoActual; // Cambiado de genero a sexo
        _objetivo = objetivoActual;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si hay datos guardados, autocompleta los campos
    if (_planNutricion != null) {
      _pesoController.text = _planNutricion!.peso.toString();
      _alturaController.text = _planNutricion!.altura.toString();
      _edadController.text = _planNutricion!.edad.toString();
      _sexo = _planNutricion!.sexo; // Cambiado de genero a sexo
      _objetivo = _planNutricion!.objetivo;
      _calorias = _planNutricion!.calorias;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan de Nutrición'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    key: _sexoKey, // Cambiado de _generoKey a _sexoKey
                    value: _sexo,
                    decoration: const InputDecoration(labelText: 'Sexo'),
                    items: const [
                      DropdownMenuItem(
                        value: 'Masculino',
                        child: Text('Masculino'),
                      ),
                      DropdownMenuItem(
                        value: 'Femenino',
                        child: Text('Femenino'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _sexo = value!;
                      });
                    },
                  ),
                  TextFormField(
                    controller: _pesoController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Peso (kg)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese su peso';
                      }
                      final num? val = num.tryParse(value);
                      if (val == null || val <= 0) {
                        return 'El peso debe ser mayor a 0';
                      }
                      return null;
                    },
                    // Sin auto-cálculo aquí
                    inputFormatters: [],
                  ),
                  TextFormField(
                    controller: _alturaController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Altura (cm)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese su altura';
                      }
                      final num? val = num.tryParse(value);
                      if (val == null || val <= 0) {
                        return 'La altura debe ser mayor a 0';
                      }
                      return null;
                    },
                    inputFormatters: [],
                  ),
                  TextFormField(
                    controller: _edadController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Edad'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese su edad';
                      }
                      final num? val = num.tryParse(value);
                      if (val == null || val <= 0) {
                        return 'La edad debe ser mayor a 0';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    key: _objetivoKey,
                    value: _objetivo,
                    decoration: const InputDecoration(labelText: 'Objetivo'),
                    items: const [
                      DropdownMenuItem(
                        value: 'Bajar de peso',
                        child: Text('Bajar de peso'),
                      ),
                      DropdownMenuItem(
                        value: 'Subir de peso',
                        child: Text('Subir de peso'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _objetivo = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _calcularCalorias,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: const Text(
                      'Calcular calorías',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_calorias != null)
                    Text(
                      'Calorías recomendadas por día: ${_calorias!.toStringAsFixed(0)} kcal',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  if (_planNutricion != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        'Datos guardados:\n'
                        'Peso: ${_planNutricion!.peso} kg, '
                        'Altura: ${_planNutricion!.altura} cm, '
                        'Edad: ${_planNutricion!.edad}, '
                        'Sexo: ${_planNutricion!.sexo}, ' // Cambiado de genero a sexo
                        'Objetivo: ${_planNutricion!.objetivo}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final historial =
                    await DBHelper.getHistorialPlanNutricionUsuarioActivo();
                showModalBottomSheet(
                  context: context,
                  builder:
                      (context) => Column(
                        children: [
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.all(16),
                              children:
                                  historial.isEmpty
                                      ? [const Text('No hay historial.')]
                                      : historial
                                          .map(
                                            (item) => ListTile(
                                              title: Text(
                                                'Peso: ${item['peso']} kg, Altura: ${item['altura']} cm, Edad: ${item['edad']}',
                                              ),
                                              subtitle: Text(
                                                'Sexo: ${item['sexo']}, Objetivo: ${item['objetivo']}\n'
                                                'Calorías: ${item['calorias'].toStringAsFixed(0)} kcal\n'
                                                'Fecha: ${item['fecha_guardado'].toString().substring(0, 19).replaceFirst("T", " ")}',
                                              ),
                                            ),
                                          )
                                          .toList(),
                            ),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            label: const Text(
                              'Borrar historial',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () async {
                              await DBHelper.borrarHistorialPlanNutricionUsuarioActivo();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Historial borrado correctamente.',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text(
                'Ver historial',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.home, color: Colors.white),
              label: const Text(
                'Volver al inicio',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
