import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Tela3 extends StatefulWidget {
  const Tela3({super.key});

  @override
  State<Tela3> createState() => _Tela3State();
}

class _Tela3State extends State<Tela3> {
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _jurosController = TextEditingController();
  final TextEditingController _parcelasController = TextEditingController();
  final TextEditingController _motivoController = TextEditingController();

  void _calcularEmprestimo() async {
    //Verificar valor valido
    final valor = double.tryParse(_valorController.text);
    final jurosMensal = double.tryParse(_jurosController.text);
    final parcelas = int.tryParse(_parcelasController.text);

    if (valor == null || valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Por favor, insira um valor válido para o empréstimo')),
      );
      return;
    }

    if (jurosMensal == null || jurosMensal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, insira uma taxa de juros válida')),
      );
      return;
    }

    if (parcelas == null || parcelas <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Por favor, insira um número válido de parcelas')),
      );
      return;
    }

    final motivo = _motivoController.text.trim();
    if (motivo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, insira um motivo válido')),
      );
      return;
    }

    // Calcular o valor total com juros
    final jurosTotal = valor * (jurosMensal / 100) * parcelas;
    final totalComJuros = valor + jurosTotal;
    final valorParcela = totalComJuros / parcelas;

    final novoEmprestimo = {
      'motivo': motivo,
      'total_com_juros': totalComJuros,
      'valor_parcela': valorParcela,
    };

    // Criar no Supabase
    final response = await Supabase.instance.client
        .from('emprestimos')
        .insert([novoEmprestimo]).execute();

    if (response.error == null) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Erro ao salvar empréstimo: ${response.error!.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.yellow),
        title: const Text(
          "Novo Empréstimo",
          style: TextStyle(color: Colors.yellow),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField("Valor do Empréstimo", _valorController),
            const SizedBox(height: 15),
            _buildTextField("Taxa de Juros ao mês (%)", _jurosController),
            const SizedBox(height: 15),
            _buildTextField("Número de Parcelas", _parcelasController),
            const SizedBox(height: 15),
            _buildTextField("Motivo do Empréstimo", _motivoController),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _calcularEmprestimo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 50,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Calcular",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.yellow),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.yellow),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
