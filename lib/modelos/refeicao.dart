import 'package:projeto_a1/modelos/default_model.dart';
import 'package:projeto_a1/modelos/restaurante.dart';

class Refeicao extends DefaultModel {
  String nome;
  String? descricao;
  double preco;
  Restaurante restaurante;

  Refeicao(this.nome, this.preco, this.restaurante);
  Refeicao.comDescricao(this.nome, this.descricao, this.preco, this.restaurante);

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'restaurante_id': restaurante.id,
    };
  }

  factory Refeicao.fromMap(Map<String, dynamic> map, Restaurante restaurante) {
    final r = Refeicao(
      map['nome'] as String,
      (map['preco'] as num).toDouble(),
      restaurante,
    );
    r.id = map['id'] as int?;
    r.descricao = map['descricao'] as String?;
    return r;
  }

  @override
  String toString() => nome;
}