import 'package:projeto_a1/modelos/default_model.dart';
import 'package:projeto_a1/modelos/refeicao.dart';

class Avaliacao extends DefaultModel {
  double notaApresentacao;
  double notaPorcao;
  double notaTemperatura;
  String anotacao;
  Refeicao prato;

  Avaliacao(this.prato, this.notaApresentacao, this.notaPorcao, this.notaTemperatura, this.anotacao);

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nota_apresentacao': notaApresentacao,
      'nota_porcao': notaPorcao,
      'nota_temperatura': notaTemperatura,
      'anotacao': anotacao,
      'refeicao_id': prato.id,
    };
  }

  factory Avaliacao.fromMap(Map<String, dynamic> map, Refeicao refeicao) {
    final a = Avaliacao(
      refeicao,
      (map['nota_apresentacao'] as num).toDouble(),
      (map['nota_porcao'] as num).toDouble(),
      (map['nota_temperatura'] as num).toDouble(),
      map['anotacao'] as String,
    );
    a.id = map['id'] as int?;
    return a;
  }
}