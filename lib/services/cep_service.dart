import 'package:dio/dio.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../models/cep_model.dart';

class CepService {
  final _dio = Dio();
  final _viaCepUrl = 'https://viacep.com.br/ws';

  Future<CepModel?> consultarCep(String cep) async {
    try {
      print('Consultando CEP: $cep');

      // Primeiro, verifica se o CEP já existe no Back4App
      final query = QueryBuilder<CepModel>(CepModel())
        ..whereEqualTo('cep', cep.replaceAll('-', ''));

      print('Buscando no Back4App...');
      final response = await query.query();
      print(
          'Resposta do Back4App: ${response.results?.length ?? 0} resultados');
      print(
          'Status do Back4App: ${response.success ? 'Sucesso' : 'Falha - ${response.error?.message}'}');

      if (response.results != null && response.results!.isNotEmpty) {
        print('CEP encontrado no Back4App');
        return response.results!.first as CepModel;
      }

      // Se não existir, consulta na API ViaCEP
      print('Consultando ViaCEP...');
      final viaCepResponse = await _dio.get('$_viaCepUrl/$cep/json');
      print('Resposta do ViaCEP: ${viaCepResponse.data}');

      if (viaCepResponse.data['erro'] == true) {
        throw Exception('CEP não encontrado na base dos Correios');
      }

      // Cria um novo registro no Back4App
      print('Salvando no Back4App...');
      final novoCep = CepModel.fromViaCep(viaCepResponse.data);
      final saveResponse = await novoCep.save();
      print(
          'Status do salvamento: ${saveResponse.success ? 'Sucesso' : 'Falha - ${saveResponse.error?.message}'}');

      if (!saveResponse.success) {
        throw Exception(
            'Erro ao salvar no Back4App: ${saveResponse.error?.message}');
      }

      return novoCep;
    } catch (e, stackTrace) {
      print('Erro ao consultar CEP: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<CepModel>> listarCeps() async {
    try {
      print('Listando CEPs...');
      final query = QueryBuilder<CepModel>(CepModel());
      final response = await query.query();
      print(
          'Status da listagem: ${response.success ? 'Sucesso' : 'Falha - ${response.error?.message}'}');
      print('CEPs encontrados: ${response.results?.length ?? 0}');

      if (!response.success) {
        throw Exception('Erro ao listar CEPs: ${response.error?.message}');
      }

      return response.results?.cast<CepModel>() ?? [];
    } catch (e, stackTrace) {
      print('Erro ao listar CEPs: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> atualizarCep(CepModel cep) async {
    await cep.save();
  }

  Future<void> deletarCep(CepModel cep) async {
    try {
      print('Deletando CEP: ${cep.cep}');
      final response = await cep.delete();
      print(
          'Status da deleção: ${response.success ? 'Sucesso' : 'Falha - ${response.error?.message}'}');

      if (!response.success) {
        throw Exception('Erro ao deletar CEP: ${response.error?.message}');
      }
    } catch (e, stackTrace) {
      print('Erro ao deletar CEP: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
