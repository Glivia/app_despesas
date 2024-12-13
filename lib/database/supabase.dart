import 'package:app_despesas/transacao.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Database {
  final SupabaseClient _bdSupabase = Supabase.instance.client;

  Future<void> addTransacao(
      String titulo, double valor, DateTime data, bool entrada) async {
    try {
      final response = await _bdSupabase.from('transacoes').insert({
        'titulo': titulo,
        'valor': valor,
        'data': data.toIso8601String(),
        'entrada': entrada,
      });

      if (response == null || response.error != null) {
        throw Exception(response?.error?.message ??
            "Erro desconhecido ao adicionar transação.");
      }
    } catch (e) {
      throw Exception("Erro ao adicionar transação: $e");
    }
  }

Future<List<Map<String, dynamic>>> getTransacoes() async {
  try {
    final List<dynamic> response = await _bdSupabase.from('transacoes').select();

    if (response.isEmpty) {
      print("Nenhuma transação encontrada.");
      return [];
    }
    return List<Map<String, dynamic>>.from(response.map((item) => item as Map<String, dynamic>));
  } catch (e) {
    throw Exception("Erro ao buscar transações: $e");
  }
}


  Future<void> updateTransacao(String id, String titulo, double valor,
      DateTime data, bool entrada) async {
    try {
      final response = await _bdSupabase.from('transacoes').update({
        'titulo': titulo,
        'valor': valor,
        'data': data.toIso8601String(),
        'entrada': entrada,
      }).eq('id', id);

      if (response.error != null) {
        throw Exception(response?.error?.message ??
            "Erro desconhecido ao editar transação.");
      }
    } catch (e) {
      throw Exception("Erro ao editar transação: $e");
    }
  }

Future<void> deleteTransacao(String id) async {
  try {
    final response = await _bdSupabase.from('transacoes').delete().eq('id', id);

    if (response == null || response.error != null) {
      throw Exception(response?.error?.message ?? "Erro desconhecido");
    }
  } catch (e) {
    throw Exception("Erro ao excluir transação: $e");
  }
}
}