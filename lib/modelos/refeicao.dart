import 'package:projeto_a1/modelos/restaurante.dart';

class Refeicao {
  String nome;
  String? descricao;
  double preco;
  Restaurante restaurante;

  Refeicao(this.nome, this.preco, this.restaurante);
  Refeicao.comDescricao(this.nome, this.descricao, this.preco, this.restaurante);
}