class Pessoa {
  final int? id;
  final String nome;
  final DateTime dataNascimento;
  final String sexo; // M, F ou O
  final String email;

  const Pessoa({
    this.id,
    required this.nome,
    required this.dataNascimento,
    required this.sexo,
    required this.email,
  });

  static const sexos = {'M': 'Masculino', 'F': 'Feminino', 'O': 'Outro'};

  String get sexoDescricao => sexos[sexo] ?? sexo;

  String get dataNascimentoFormatada => formatarData(dataNascimento);

  static String _dois(int n) => n.toString().padLeft(2, '0');

  static String formatarData(DateTime d) => '${_dois(d.day)}/${_dois(d.month)}/${d.year}';

  factory Pessoa.fromJson(Map<String, dynamic> json) => Pessoa(
        id: json['id'] as int,
        nome: json['nome'] as String,
        dataNascimento: DateTime.parse(json['data_nascimento'] as String),
        sexo: json['sexo'] as String,
        email: json['email'] as String,
      );

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'data_nascimento':
            '${dataNascimento.year.toString().padLeft(4, '0')}-${_dois(dataNascimento.month)}-${_dois(dataNascimento.day)}',
        'sexo': sexo,
        'email': email,
      };
}
