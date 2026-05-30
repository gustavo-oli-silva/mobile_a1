import 'package:projeto_a1/modelos/default_model.dart';
import 'package:projeto_a1/modelos/restaurante.dart';

class Refeicao extends DefaultModel {
  String nome;
  String? descricao;
  double preco;
  Restaurante restaurante;

  Refeicao(this.nome, this.preco, this.restaurante);
  Refeicao.comDescricao(this.nome, this.descricao, this.preco, this.restaurante);

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'restaurante_id': restaurante.id,
    };
  }

  Map<String, dynamic> toMap() => toJson();

  factory Refeicao.fromJson(Map<String, dynamic> map, Restaurante restaurante) {
    final r = Refeicao(
      map['nome'] as String,
      (map['preco'] as num).toDouble(),
      restaurante,
    );
    r.id = map['id'] as int?;
    r.descricao = map['descricao'] as String?;
    return r;
  }

  factory Refeicao.fromMap(Map<String, dynamic> map, Restaurante restaurante) =>
      Refeicao.fromJson(map, restaurante);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Refeicao && id != null && id == other.id);

  @override
  int get hashCode => id?.hashCode ?? nome.hashCode;

  @override
  String toString() => nome;
}