import 'package:projeto_a1/modelos/default_model.dart';

class Restaurante extends DefaultModel {
  String nome;
  String? descricao;

  Restaurante(this.nome);
  Restaurante.comDescricao(this.nome, this.descricao);

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'descricao': descricao,
    };
  }

  factory Restaurante.fromMap(Map<String, dynamic> map) {
    final r = Restaurante(map['nome'] as String);
    r.id = map['id'] as int?;
    r.descricao = map['descricao'] as String?;
    return r;
  }

  @override
  String toString() => nome;
}