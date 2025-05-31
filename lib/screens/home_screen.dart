import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/cep_model.dart';
import '../services/cep_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _cepController = TextEditingController();
  final _cepService = CepService();
  List<CepModel> _ceps = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarCeps();
    });
  }

  void _mostrarErro(String mensagem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erro'),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _carregarCeps() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Iniciando carregamento de CEPs...');
      final ceps = await _cepService.listarCeps();
      print('CEPs carregados: ${ceps.length}');

      if (!mounted) return;
      setState(() {
        _ceps = ceps;
        _errorMessage = null;
      });
    } catch (e) {
      print('Erro ao carregar CEPs: $e');
      if (!mounted) return;
      setState(() => _errorMessage = 'Erro ao carregar CEPs: $e');
      _mostrarErro('Erro ao carregar CEPs: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _consultarCep() async {
    final cep = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cep.length != 8) {
      _mostrarErro('CEP inválido - Digite 8 números');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Consultando CEP: $cep');
      final resultado = await _cepService.consultarCep(cep);
      print('Resultado da consulta: $resultado');

      if (!mounted) return;

      if (resultado != null) {
        _cepController.clear();
        await _carregarCeps();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CEP consultado com sucesso!')),
        );
      }
    } catch (e) {
      print('Erro ao consultar CEP: $e');
      if (!mounted) return;
      setState(() => _errorMessage = 'Erro ao consultar CEP: $e');
      _mostrarErro('Erro ao consultar CEP: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deletarCep(CepModel cep) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Deletando CEP: ${cep.cep}');
      await _cepService.deletarCep(cep);
      print('CEP deletado com sucesso');

      if (!mounted) return;
      await _carregarCeps();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CEP removido com sucesso!')),
      );
    } catch (e) {
      print('Erro ao deletar CEP: $e');
      if (!mounted) return;
      setState(() => _errorMessage = 'Erro ao remover CEP: $e');
      _mostrarErro('Erro ao remover CEP: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CEP Fácil'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _carregarCeps,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cepController,
                    decoration: const InputDecoration(
                      labelText: 'CEP',
                      hintText: '00000-000',
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8),
                    ],
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) => _consultarCep(),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _consultarCep,
                  child: const Text('Consultar'),
                ),
              ],
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _ceps.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum CEP cadastrado\nDigite um CEP para consultar',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: _ceps.length,
                        itemBuilder: (context, index) {
                          final cep = _ceps[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            child: ListTile(
                              title: Text('${cep.logradouro} - ${cep.bairro}'),
                              subtitle: Text(
                                '${cep.cidade} - ${cep.uf}\nCEP: ${cep.cep}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deletarCep(cep),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cepController.dispose();
    super.dispose();
  }
}
