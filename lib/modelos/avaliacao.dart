import 'package:projeto_a1/modelos/refeicao.dart';

class Avaliacao {
  double notaApresentacao;
  double notaPorcao;
  double notaTemperatura;
  String anotacao;
  Refeicao prato;

  Avaliacao(this.prato ,this.notaApresentacao, this.notaPorcao, this.notaTemperatura, this.anotacao);
}