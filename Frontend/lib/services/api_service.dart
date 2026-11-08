import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pessoa.dart';

/// URL da API, definida no build com --dart-define=API_URL=https://...
const String apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8000');

class ApiException implements Exception {
  final String mensagem;
  ApiException(this.mensagem);

  @override
  String toString() => mensagem;
}

class ApiService {
  final http.Client _client;
  ApiService([http.Client? client]) : _client = client ?? http.Client();

  Uri _uri(String path) => Uri.parse('$apiUrl$path');
  static const _headers = {'Content-Type': 'application/json'};

  Future<List<Pessoa>> listar() async {
    final resp = await _client.get(_uri('/pessoas'));
    _verificar(resp);
    final lista = jsonDecode(utf8.decode(resp.bodyBytes)) as List<dynamic>;
    return lista.map((e) => Pessoa.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> incluir(Pessoa p) async {
    final resp = await _client.post(_uri('/pessoas'), headers: _headers, body: jsonEncode(p.toJson()));
    _verificar(resp);
  }

  Future<void> alterar(Pessoa p) async {
    final resp = await _client.put(_uri('/pessoas/${p.id}'), headers: _headers, body: jsonEncode(p.toJson()));
    _verificar(resp);
  }

  Future<void> excluir(int id) async {
    final resp = await _client.delete(_uri('/pessoas/$id'));
    _verificar(resp);
  }

  void _verificar(http.Response resp) {
    if (resp.statusCode >= 200 && resp.statusCode < 300) return;
    var mensagem = 'Erro ${resp.statusCode} ao comunicar com o servidor.';
    try {
      final detail = (jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>)['detail'];
      if (detail is String) {
        mensagem = detail;
      } else if (detail is List && detail.isNotEmpty) {
        mensagem = detail.map((e) => (e as Map<String, dynamic>)['msg']).join('\n');
      }
    } catch (_) {
      // corpo nao e JSON: mantem a mensagem generica
    }
    throw ApiException(mensagem);
  }
}
