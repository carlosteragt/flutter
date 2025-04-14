import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Tela4 extends StatefulWidget {
  const Tela4({super.key});

  @override
  State<Tela4> createState() => _Tela4State();
}

class _Tela4State extends State<Tela4> {
  late Future<List<Map<String, dynamic>>> _emprestimosFuture;

  @override
  void initState() {
    super.initState();
    _emprestimosFuture = _carregarEmprestimos();
  }

  //ler
  Future<List<Map<String, dynamic>>> _carregarEmprestimos() async {
    final response =
        await Supabase.instance.client.from('emprestimos').select().execute();

    if (response.error != null) {
      throw Exception(
          'Erro ao carregar empréstimos: ${response.error!.message}');
    }

    return List<Map<String, dynamic>>.from(response.data as List);
  }

  Future<void> _atualizarEmprestimo(Map<String, dynamic> emprestimo) async {
    final TextEditingController motivoController =
        TextEditingController(text: emprestimo['motivo']);
    final TextEditingController totalComJurosController =
        TextEditingController(text: emprestimo['total_com_juros'].toString());
    final TextEditingController valorParcelaController =
        TextEditingController(text: emprestimo['valor_parcela'].toString());

    final updatedEmprestimo = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Atualizar Empréstimo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: motivoController,
                decoration: const InputDecoration(labelText: 'Motivo'),
              ),
              TextField(
                controller: totalComJurosController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Total com Juros'),
              ),
              TextField(
                controller: valorParcelaController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration:
                    const InputDecoration(labelText: 'Valor da Parcela'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Atualiza os valores
                final updatedEmprestimo = {
                  'motivo': motivoController.text,
                  'total_com_juros': double.parse(totalComJurosController.text),
                  'valor_parcela': double.parse(valorParcelaController.text),
                };
                Navigator.of(context).pop(updatedEmprestimo);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (updatedEmprestimo != null) {
      final response = await Supabase.instance.client
          .from('emprestimos')
          .update(updatedEmprestimo)
          .eq('motivo', emprestimo['motivo'])
          .execute();

      if (response.error == null) {
        setState(() {
          _emprestimosFuture = _carregarEmprestimos();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Erro ao atualizar empréstimo: ${response.error!.message}')),
        );
      }
    }
  }

  //deletar
  Future<void> _deletarEmprestimo(String motivo) async {
    final response = await Supabase.instance.client
        .from('emprestimos')
        .delete()
        .eq('motivo', motivo)
        .execute();

    if (response.error == null) {
      setState(() {
        _emprestimosFuture = _carregarEmprestimos();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Erro ao excluir empréstimo: ${response.error!.message}')),
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
          "Empréstimos Salvos",
          style: TextStyle(color: Colors.yellow),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _emprestimosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final emprestimos = snapshot.data ?? [];

          return ListView.builder(
            itemCount: emprestimos.length,
            itemBuilder: (context, index) {
              final emprestimo = emprestimos[index];
              return Card(
                color: Colors.black,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.yellow),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  title: Text(
                    emprestimo['motivo'],
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  children: [
                    ListTile(
                      title: Text(
                        "Total com Juros: R\$ ${emprestimo['total_com_juros'].toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "Valor da Parcela: R\$ ${emprestimo['valor_parcela'].toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    OverflowBar(
                      children: [
                        TextButton(
                          onPressed: () => _atualizarEmprestimo(emprestimo),
                          child: const Text(
                            'Editar',
                            style: TextStyle(color: Colors.yellow),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              _deletarEmprestimo(emprestimo['motivo']),
                          child: const Text(
                            'Excluir',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
