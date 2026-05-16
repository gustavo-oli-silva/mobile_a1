import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:projeto_a1/modelos/avaliacao.dart';
import 'package:projeto_a1/repositorios/refeicao_repositorio.dart';

class AvaliacaoRepositorio {
  final _supabase = Supabase.instance.client;
  final RefeicaoRepositorio _refeicaoRepo = RefeicaoRepositorio();

  Future<int> inserir(Avaliacao avaliacao) async {
    final data = avaliacao.toMap();
    data.remove('id');
    final response = await _supabase.from('avaliacoes').insert(data).select('id').single();
    final id = response['id'] as int;
    avaliacao.id = id;
    return id;
  }

  Future<List<Avaliacao>> listar() async {
    final maps = await _supabase.from('avaliacoes').select('*, refeicoes(*, restaurantes(*))').order('id', ascending: false);

    final List<Avaliacao> avaliacoes = [];
    for (final m in maps) {
      final refeicaoId = m['refeicao_id'] as int;
      final refeicao = await _refeicaoRepo.buscarPorId(refeicaoId);
      if (refeicao != null) {
        avaliacoes.add(Avaliacao.fromMap(m, refeicao));
      }
    }
    return avaliacoes;
  }

  Future<int> deletar(int id) async {
    await _supabase.from('avaliacoes').delete().eq('id', id);
    return id;
  }

  Future<int> atualizar(Avaliacao avaliacao) async {
    await _supabase.from('avaliacoes').update(avaliacao.toMap()).eq('id', avaliacao.id!);
    return avaliacao.id!;
  }
}
