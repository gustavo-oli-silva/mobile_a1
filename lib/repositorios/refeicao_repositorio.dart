import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:projeto_a1/modelos/refeicao.dart';
import 'package:projeto_a1/repositorios/restaurante_repositorio.dart';

class RefeicaoRepositorio {
  final _supabase = Supabase.instance.client;
  final RestauranteRepositorio _restauranteRepo = RestauranteRepositorio();

  Future<int> inserir(Refeicao refeicao) async {
    final data = refeicao.toMap();
    data.remove('id');
    final response = await _supabase.from('refeicoes').insert(data).select('id').single();
    final id = response['id'] as int;
    refeicao.id = id;
    return id;
  }

  Future<List<Refeicao>> listar() async {
    final maps = await _supabase.from('refeicoes').select('*, restaurantes(*)').order('nome', ascending: true);

    return maps.map((m) {
      final restauranteMap = m['restaurantes'] as Map<String, dynamic>;
      final restaurante = _restauranteRepo.fromMap(restauranteMap);
      return Refeicao.fromMap(m, restaurante);
    }).toList();
  }

  Future<Refeicao?> buscarPorId(int id) async {
    final m = await _supabase.from('refeicoes').select('*, restaurantes(*)').eq('id', id).maybeSingle();
    if (m == null) return null;
    
    final restauranteMap = m['restaurantes'] as Map<String, dynamic>;
    final restaurante = _restauranteRepo.fromMap(restauranteMap);
    return Refeicao.fromMap(m, restaurante);
  }

  Future<int> deletar(int id) async {
    await _supabase.from('refeicoes').delete().eq('id', id);
    return id;
  }

  Future<int> atualizar(Refeicao refeicao) async {
    await _supabase.from('refeicoes').update(refeicao.toMap()).eq('id', refeicao.id!);
    return refeicao.id!;
  }
}
