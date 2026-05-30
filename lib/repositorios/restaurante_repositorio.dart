import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:projeto_a1/modelos/restaurante.dart';

/// Repositório: apenas acesso a dados via Supabase. Sem lógica de negócio.
class RestauranteRepositorio {
  final _supabase = Supabase.instance.client;

  Future<int> inserir(Restaurante restaurante) async {
    final data = restaurante.toJson()..remove('id');
    final response =
        await _supabase.from('restaurantes').insert(data).select('id').single();
    final id = response['id'] as int;
    restaurante.id = id;
    return id;
  }

  Future<List<Restaurante>> listar() async {
    final maps = await _supabase
        .from('restaurantes')
        .select()
        .order('nome', ascending: true);
    return maps.map((m) => Restaurante.fromJson(m)).toList();
  }

  Future<Restaurante?> buscarPorId(int id) async {
    final response = await _supabase
        .from('restaurantes')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return Restaurante.fromJson(response);
  }

  Future<void> deletar(int id) async {
    await _supabase.from('restaurantes').delete().eq('id', id);
  }

  Future<void> atualizar(Restaurante restaurante) async {
    final data = restaurante.toJson()..remove('id');
    await _supabase
        .from('restaurantes')
        .update(data)
        .eq('id', restaurante.id!);
  }
}
