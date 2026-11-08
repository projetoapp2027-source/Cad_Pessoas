import 'package:flutter/material.dart';

import '../models/pessoa.dart';

/// Formulario de inclusao/alteracao. Retorna a Pessoa preenchida ou null se cancelado.
class PessoaFormDialog extends StatefulWidget {
  final Pessoa? pessoa;
  const PessoaFormDialog({super.key, this.pessoa});

  @override
  State<PessoaFormDialog> createState() => _PessoaFormDialogState();
}

class _PessoaFormDialogState extends State<PessoaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _email;
  late final TextEditingController _dataCtrl;
  DateTime? _dataNascimento;
  String? _sexo;

  bool get _editando => widget.pessoa != null;

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void initState() {
    super.initState();
    final p = widget.pessoa;
    _nome = TextEditingController(text: p?.nome ?? '');
    _email = TextEditingController(text: p?.email ?? '');
    _dataNascimento = p?.dataNascimento;
    _dataCtrl = TextEditingController(text: p?.dataNascimentoFormatada ?? '');
    _sexo = p?.sexo;
  }

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _dataCtrl.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final hoje = DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _dataNascimento ?? DateTime(hoje.year - 30),
      firstDate: DateTime(1900),
      lastDate: hoje,
      locale: const Locale('pt', 'BR'),
    );
    if (escolhida != null) {
      setState(() {
        _dataNascimento = escolhida;
        _dataCtrl.text = Pessoa.formatarData(escolhida);
      });
    }
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(Pessoa(
      id: widget.pessoa?.id,
      nome: _nome.text.trim(),
      dataNascimento: _dataNascimento!,
      sexo: _sexo!,
      email: _email.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_editando ? 'Alterar registro' : 'Incluir registro'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nome,
                autofocus: true,
                maxLength: 150,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome.' : null,
              ),
              TextFormField(
                controller: _dataCtrl,
                readOnly: true,
                onTap: _escolherData,
                decoration: const InputDecoration(
                  labelText: 'Data de nascimento',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: (_) => _dataNascimento == null ? 'Informe a data de nascimento.' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _sexo,
                decoration: const InputDecoration(labelText: 'Sexo'),
                items: Pessoa.sexos.entries
                    .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                    .toList(),
                onChanged: (v) => setState(() => _sexo = v),
                validator: (v) => v == null ? 'Selecione o sexo.' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                maxLength: 254,
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o e-mail.';
                  if (!_emailRegex.hasMatch(v.trim())) return 'E-mail inválido.';
                  return null;
                },
                onFieldSubmitted: (_) => _salvar(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        FilledButton(onPressed: _salvar, child: const Text('Salvar')),
      ],
    );
  }
}
