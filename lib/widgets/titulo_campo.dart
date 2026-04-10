import 'package:flutter/material.dart';

class TituloCampo extends StatelessWidget {
  final String titulo; 

  const TituloCampo({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Text(
      titulo,
      style: TextStyle(fontSize: 22));
  }
}