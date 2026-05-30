import 'package:projeto_a1/modelos/default_model.dart';

class Restaurante extends DefaultModel {
  String nome;
  String? descricao;

  Restaurante(this.nome);
  Restaurante.comDescricao(this.nome, this.descricao);

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'descricao': descricao,
    };
  }

  /// Mantido por retrocompatibilidade com código legado
  Map<String, dynamic> toMap() => toJson();

  factory Restaurante.fromJson(Map<String, dynamic> map) {
    final r = Restaurante(map['nome'] as String);
    r.id = map['id'] as int?;
    r.descricao = map['descricao'] as String?;
    return r;
  }

  factory Restaurante.fromMap(Map<String, dynamic> map) =>
      Restaurante.fromJson(map);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Restaurante && id != null && id == other.id);

  @override
  int get hashCode => id?.hashCode ?? nome.hashCode;

  @override
  String toString() => nome;
}