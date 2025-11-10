import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CalculationScreen extends StatefulWidget {
  final String franchiseName;
  final String franchiseId;
  
  const CalculationScreen({
    super.key, 
    required this.franchiseName,
    this.franchiseId = '1'
  });

  @override
  State<CalculationScreen> createState() => _CalculationScreenState();
}

class _CalculationScreenState extends State<CalculationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _workersController = TextEditingController();
  final _shiftTimeController = TextEditingController();
  final _shiftsController = TextEditingController();
  final _salaryController = TextEditingController();

  Map<String, dynamic>? results;
  bool _isCalculating = false;

  Future<void> _calculate() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isCalculating = true;
      });

      try {
        final inputData = {
          'workers': _workersController.text,
          'shiftTime': _shiftTimeController.text,
          'shifts': _shiftsController.text,
          'salary': _salaryController.text,
        };

        final response = await ApiService.calculate(
          franchiseId: widget.franchiseId,
          inputData: inputData,
        );

        // Проверяем mounted перед setState
        if (!mounted) return;
        
        setState(() {
          results = response;
          _isCalculating = false;
        });
      } catch (e) {
        // Проверяем mounted перед setState
        if (!mounted) return;
        
        setState(() {
          _isCalculating = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка расчета: $e')),
        );
      }
    }
  }

  void _submitApplication() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подать заявку'),
        content: const Text('Вы хотите подать заявку на эту франшизу?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Реализация подачи заявки
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Заявка отправлена')),
              );
            },
            child: const Text('Подать заявку'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Расчет ${widget.franchiseName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _workersController,
                decoration: const InputDecoration(
                  labelText: 'Количество работников',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите количество работников';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _shiftTimeController,
                decoration: const InputDecoration(
                  labelText: 'Время смены (часы)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите время смены';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _shiftsController,
                decoration: const InputDecoration(
                  labelText: 'Количество смен в день',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите количество смен';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _salaryController,
                decoration: const InputDecoration(
                  labelText: 'Зарплата в час (₽)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите зарплату';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isCalculating ? null : _calculate,
                  child: _isCalculating 
                      ? const CircularProgressIndicator()
                      : const Text('Рассчитать на сервере'),
                ),
              ),
              if (results != null) ...[
                const SizedBox(height: 30),
                const Text(
                  'Результаты расчета:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      _buildResultRow('Общие расходы:', '${results!['total_expenses']?.toStringAsFixed(0)} ₽'),
                      _buildResultRow('Чистая прибыль:', '${results!['net_profit']?.toStringAsFixed(0)} ₽'),
                      _buildResultRow('ROI:', '${results!['roi']?.toStringAsFixed(1)}%'),
                      _buildResultRow('Срок окупаемости:', '${results!['payback_period']?.toStringAsFixed(1)} года'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _submitApplication,
                    icon: const Icon(Icons.send),
                    label: const Text('Подать заявку на франшизу'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}