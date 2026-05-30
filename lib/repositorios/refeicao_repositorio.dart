import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:projeto_a1/modelos/refeicao.dart';
import 'package:projeto_a1/modelos/restaurante.dart';

/// Repositório: apenas acesso a dados via Supabase. Sem lógica de negócio.
class RefeicaoRepositorio {
  final _supabase = Supabase.instance.client;

  Future<int> inserir(Refeicao refeicao) async {
    final data = refeicao.toJson()..remove('id');
    final response =
        await _supabase.from('refeicoes').insert(data).select('id').single();
    final id = response['id'] as int;
    refeicao.id = id;
    return id;
  }

  Future<List<Refeicao>> listar() async {
    final maps = await _supabase
        .from('refeicoes')
        .select('*, restaurantes(*)')
        .order('nome', ascending: true);

    return maps.map((m) {
      final restauranteMap = m['restaurantes'] as Map<String, dynamic>;
      final restaurante = Restaurante.fromJson(restauranteMap);
      return Refeicao.fromJson(m, restaurante);
    }).toList();
  }

  Future<Refeicao?> buscarPorId(int id) async {
    final m = await _supabase
        .from('refeicoes')
        .select('*, restaurantes(*)')
        .eq('id', id)
        .maybeSingle();
    if (m == null) return null;
    final restauranteMap = m['restaurantes'] as Map<String, dynamic>;
    final restaurante = Restaurante.fromJson(restauranteMap);
    return Refeicao.fromJson(m, restaurante);
  }

  Future<void> deletar(int id) async {
    await _supabase.from('refeicoes').delete().eq('id', id);
  }

  Future<void> atualizar(Refeicao refeicao) async {
    final data = refeicao.toJson()..remove('id');
    await _supabase
        .from('refeicoes')
        .update(data)
        .eq('id', refeicao.id!);
  }
}
