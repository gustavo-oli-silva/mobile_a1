import 'package:flutter/material.dart';

class Botao extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;

  const Botao({super.key, required this.texto, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red
          ),
          child: Text(texto,
          style: TextStyle(color: Colors.white)));
  }
}