import 'package:flutter/material.dart';

import '../models/pessoa.dart';
import '../services/api_service.dart';
import 'pessoa_form_dialog.dart';

class PessoasPage extends StatefulWidget {
  const PessoasPage({super.key});

  @override
  State<PessoasPage> createState() => _PessoasPageState();
}

class _PessoasPageState extends State<PessoasPage> {
  final _api = ApiService();
  List<Pessoa> _pessoas = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final lista = await _api.listar();
      if (!mounted) return;
      setState(() => _pessoas = lista);
    } catch (e) {
      if (!mounted) return;
      setState(() => _erro = 'Não foi possível carregar os registros: $e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _mensagem(String texto, {bool erro = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(texto),
      backgroundColor: erro ? Theme.of(context).colorScheme.error : null,
    ));
  }

  Future<void> _abrirFormulario([Pessoa? pessoa]) async {
    final resultado = await showDialog<Pessoa>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PessoaFormDialog(pessoa: pessoa),
    );
    if (resultado == null) return;
    try {
      if (pessoa == null) {
        await _api.incluir(resultado);
        _mensagem('Registro incluído com sucesso.');
      } else {
        await _api.alterar(resultado);
        _mensagem('Registro alterado com sucesso.');
      }
      await _carregar();
    } catch (e) {
      _mensagem(e.toString(), erro: true);
    }
  }

  Future<void> _excluir(Pessoa pessoa) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir registro'),
        content: Text('Deseja realmente excluir "${pessoa.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    try {
      await _api.excluir(pessoa.id!);
      _mensagem('Registro excluído com sucesso.');
      await _carregar();
    } catch (e) {
      _mensagem(e.toString(), erro: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Pessoas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FilledButton.icon(
                  onPressed: () => _abrirFormulario(),
                  icon: const Icon(Icons.add),
                  label: const Text('Incluir'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Atualizar',
                  onPressed: _carregando ? null : _carregar,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: _conteudo()),
          ],
        ),
      ),
    );
  }

  Widget _conteudo() {
    final cores = Theme.of(context).colorScheme;
    if (_carregando) return const Center(child: CircularProgressIndicator());
    if (_erro != null) {
      return Center(child: Text(_erro!, style: TextStyle(color: cores.error)));
    }
    if (_pessoas.isEmpty) {
      return const Center(child: Text('Nenhum registro cadastrado. Clique em "Incluir" para começar.'));
    }
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(cores.surfaceContainerHighest),
          columns: const [
            DataColumn(label: Text('Nome')),
            DataColumn(label: Text('Data de nascimento')),
            DataColumn(label: Text('Sexo')),
            DataColumn(label: Text('E-mail')),
            DataColumn(label: Text('Ações')),
          ],
          rows: _pessoas
              .map((p) => DataRow(cells: [
                    DataCell(Text(p.nome)),
                    DataCell(Text(p.dataNascimentoFormatada)),
                    DataCell(Text(p.sexoDescricao)),
                    DataCell(Text(p.email)),
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Alterar',
                          icon: const Icon(Icons.edit),
                          onPressed: () => _abrirFormulario(p),
                        ),
                        IconButton(
                          tooltip: 'Excluir',
                          icon: Icon(Icons.delete, color: cores.error),
                          onPressed: () => _excluir(p),
                        ),
                      ],
                    )),
                  ]))
              .toList(),
        ),
      ),
    );
  }
}
