import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:projeto_a1/modelos/avaliacao.dart';
import 'package:projeto_a1/modelos/refeicao.dart';
import 'package:projeto_a1/modelos/restaurante.dart';

/// Repositório: apenas acesso a dados via Supabase. Sem lógica de negócio.
/// BUGFIX: listar() agora usa um único join ao invés de N queries separadas.
class AvaliacaoRepositorio {
  final _supabase = Supabase.instance.client;

  Future<int> inserir(Avaliacao avaliacao) async {
    final data = avaliacao.toJson()..remove('id');
    final response =
        await _supabase.from('avaliacoes').insert(data).select('id').single();
    final id = response['id'] as int;
    avaliacao.id = id;
    return id;
  }

  Future<List<Avaliacao>> listar() async {
    // Uma única query com joins aninhados — corrige o N+1 original
    final maps = await _supabase
        .from('avaliacoes')
        .select('*, refeicoes(*, restaurantes(*))')
        .order('id', ascending: false);

    return maps.map((m) {
      final refeicaoMap = m['refeicoes'] as Map<String, dynamic>;
      final restauranteMap = refeicaoMap['restaurantes'] as Map<String, dynamic>;
      final restaurante = Restaurante.fromJson(restauranteMap);
      final refeicao = Refeicao.fromJson(refeicaoMap, restaurante);
      return Avaliacao.fromJson(m, refeicao);
    }).toList();
  }

  Future<void> deletar(int id) async {
    await _supabase.from('avaliacoes').delete().eq('id', id);
  }

  Future<void> atualizar(Avaliacao avaliacao) async {
    final data = avaliacao.toJson()..remove('id');
    await _supabase
        .from('avaliacoes')
        .update(data)
        .eq('id', avaliacao.id!);
  }
}
