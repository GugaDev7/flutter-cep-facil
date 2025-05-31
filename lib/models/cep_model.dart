import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class CepModel extends ParseObject implements ParseCloneable {
  static const String _keyClassName = 'Cep';
  static const String _keyCep = 'cep';
  static const String _keyLogradouro = 'logradouro';
  static const String _keyBairro = 'bairro';
  static const String _keyCidade = 'cidade';
  static const String _keyUf = 'uf';

  CepModel() : super(_keyClassName);
  CepModel.clone() : this();

  @override
  CepModel clone(Map<String, dynamic> map) => CepModel.clone()..fromJson(map);

  String get cep => get<String>(_keyCep) ?? '';
  set cep(String value) => set<String>(_keyCep, value);

  String get logradouro => get<String>(_keyLogradouro) ?? '';
  set logradouro(String value) => set<String>(_keyLogradouro, value);

  String get bairro => get<String>(_keyBairro) ?? '';
  set bairro(String value) => set<String>(_keyBairro, value);

  String get cidade => get<String>(_keyCidade) ?? '';
  set cidade(String value) => set<String>(_keyCidade, value);

  String get uf => get<String>(_keyUf) ?? '';
  set uf(String value) => set<String>(_keyUf, value);

  factory CepModel.fromViaCep(Map<String, dynamic> json) {
    print('Criando CepModel a partir dos dados do ViaCEP:');
    print('CEP: ${json['cep']}');
    print('Logradouro: ${json['logradouro']}');
    print('Bairro: ${json['bairro']}');
    print('Cidade: ${json['localidade']}');
    print('UF: ${json['uf']}');

    final cep = CepModel()
      ..cep = json['cep']?.replaceAll('-', '') ?? ''
      ..logradouro = json['logradouro'] ?? ''
      ..bairro = json['bairro'] ?? ''
      ..cidade = json['localidade'] ?? ''
      ..uf = json['uf'] ?? '';

    print('CepModel criado: ${cep.toJson()}');
    return cep;
  }

  @override
  String toString() {
    return 'CepModel(cep: $cep, logradouro: $logradouro, bairro: $bairro, cidade: $cidade, uf: $uf)';
  }
}
