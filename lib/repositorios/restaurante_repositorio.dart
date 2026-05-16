import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:projeto_a1/modelos/restaurante.dart';

class RestauranteRepositorio {
  final _supabase = Supabase.instance.client;

  Future<int> inserir(Restaurante restaurante) async {
    final data = restaurante.toMap();
    data.remove('id'); // Remove null id before inserting
    final response = await _supabase.from('restaurantes').insert(data).select('id').single();
    final id = response['id'] as int;
    restaurante.id = id;
    return id;
  }

  Restaurante fromMap(Map<String, dynamic> map) => Restaurante.fromMap(map);

  Future<List<Restaurante>> listar() async {
    final maps = await _supabase.from('restaurantes').select().order('nome', ascending: true);
    return maps.map((m) => Restaurante.fromMap(m)).toList();
  }

  Future<Restaurante?> buscarPorId(int id) async {
    final response = await _supabase.from('restaurantes').select().eq('id', id).maybeSingle();
    if (response == null) return null;
    return Restaurante.fromMap(response);
  }

  Future<int> deletar(int id) async {
    await _supabase.from('restaurantes').delete().eq('id', id);
    return id;
  }

  Future<int> atualizar(Restaurante restaurante) async {
    await _supabase.from('restaurantes').update(restaurante.toMap()).eq('id', restaurante.id!);
    return restaurante.id!;
  }
}
