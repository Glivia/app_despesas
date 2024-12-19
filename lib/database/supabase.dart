
import 'package:supabase_flutter/supabase_flutter.dart';//importando supabase no flutter

class Database {//crando classe do banco
  final SupabaseClient _bdSupabase = Supabase.instance.client;//istanciando o banco para poder fazer as alterações

  Future<void> addTransacao(//adicionando no banco de dados
      String titulo, double valor, DateTime data, bool entrada) async {
    try {
      final response = await _bdSupabase.from('transacoes').insert({//adiciona a tabela transacoes no banco
        'titulo': titulo,
        'valor': valor,
        'data': data.toIso8601String(),//convertendo data para string ISO8601
        'entrada': entrada,
      });

      if (response == null || response.error != null) {//verifica se retornou algum erro do banco
        throw Exception(response?.error?.message ?? "Erro desconhecido ao adicionar transação.");
      }
    } catch (e) {
      throw Exception("Erro ao adicionar transação: $e");//print erro
    }
  }

Future<List<Map<String, dynamic>>> getTransacoes() async {//pegando todas as transações da tabela
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
      DateTime data, bool entrada) async {//atualiza a transacao buscando peli id na coluna
    try {
      final response = await _bdSupabase.from('transacoes').update({
        'titulo': titulo,
        'valor': valor,
        'data': data.toIso8601String(),
        'entrada': entrada,
      }).eq('id', id);

      if (response.error != null) {
        throw Exception(response?.error?.message ??"Erro desconhecido ao editar transação.");
      }
    } catch (e) {
      throw Exception("Erro ao editar transação: $e");
    }
  }

Future<void> deleteTransacao(String id) async {//deletando item do banco
  try {
    final response = await _bdSupabase.from('transacoes').delete().eq('id', id);//

    if (response == null || response.error != null) {
      throw Exception(response?.error?.message ?? "Erro desconhecido");
    }
  } catch (e) {
    throw Exception("Erro ao excluir transação: $e");
  }
}
}