import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Serviço isolado de geração e entrega de PDF.
/// A View não interage com este serviço diretamente —
/// os Controllers são os únicos consumidores.
class PdfServico {
  // ── Paleta My Michelin ───────────────────────────────────────
  static const _vermelho      = PdfColor.fromInt(0xFFC62828);
  static const _vermelhoClaro = PdfColor.fromInt(0xFFFFEBEE);
  static const _vermelhoMedio = PdfColor.fromInt(0xFFEF9A9A);
  static const _cinzaEscuro   = PdfColor.fromInt(0xFF424242);
  static const _cinzaMedio    = PdfColor.fromInt(0xFF9E9E9E);
  static const _cinzaClaro    = PdfColor.fromInt(0xFFF5F5F5);
  static const _branco        = PdfColors.white;

  /// Gera um PDF elegante de relatório.
  ///
  /// [titulo]      Título do relatório.
  /// [cabecalhos]  Cabeçalhos das colunas.
  /// [gerarLinhas] Converte cada item em células de texto.
  /// [resumo]      Mapa opcional de estatísticas exibido acima da tabela.
  Future<Uint8List> gerarPdf<T>(
    List<T> dados,
    String titulo,
    List<String> cabecalhos,
    List<String> Function(T item) gerarLinhas, {
    Map<String, String>? resumo,
  }) async {
    final pdf = pw.Document();
    final agora = DateTime.now().toLocal();
    final dataStr =
        '${agora.day.toString().padLeft(2, '0')}/${agora.month.toString().padLeft(2, '0')}/${agora.year}  '
        '${agora.hour.toString().padLeft(2, '0')}:${agora.minute.toString().padLeft(2, '0')}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 32),

        // ── Cabeçalho de página ─────────────────────────────────
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // Faixa vermelha superior
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const pw.BoxDecoration(color: _vermelho),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'My Michelin',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: _branco,
                      letterSpacing: 1.5,
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Relatório Gerado',
                        style: const pw.TextStyle(fontSize: 7, color: _vermelhoMedio),
                      ),
                      pw.Text(
                        dataStr,
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          color: _branco,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Sub-faixa com título
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: _cinzaEscuro,
              child: pw.Text(
                titulo,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: _branco,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            pw.SizedBox(height: 12),
          ],
        ),

        // ── Rodapé de página ────────────────────────────────────
        footer: (context) => pw.Column(
          children: [
            pw.Divider(color: _cinzaMedio, thickness: 0.5),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'My Michelin – Relatório Confidencial',
                  style: const pw.TextStyle(fontSize: 7, color: _cinzaMedio),
                ),
                pw.Text(
                  'Página ${context.pageNumber} de ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 7, color: _cinzaMedio),
                ),
              ],
            ),
          ],
        ),

        // ── Corpo ───────────────────────────────────────────────
        build: (context) => [
          // Bloco de resumo (acima da tabela)
          if (resumo != null && resumo.isNotEmpty) ...[
            _buildResumoBox(resumo),
            pw.SizedBox(height: 14),
          ],

          // Tabela de dados
          _buildTabela(cabecalhos, dados, gerarLinhas),

          pw.SizedBox(height: 8),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              '${dados.length} registro(s) exibido(s)',
              style: const pw.TextStyle(fontSize: 8, color: _cinzaMedio),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  // ── Widgets internos ─────────────────────────────────────────

  pw.Widget _buildResumoBox(Map<String, String> resumo) {
    // Usa Border.all uniforme para poder ter borderRadius sem erro.
    // A cor de acento lateral é simulada por um Container interno fino.
    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(0, 0, 0, 0),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _vermelho, width: 0.5),
        color: _vermelhoClaro,
      ),
      child: pw.Row(
        children: [
          // Faixa vermelha lateral
          pw.Container(width: 5, height: 60, color: _vermelho),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(
                    'RESUMO',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 9,
                      color: _vermelho,
                      letterSpacing: 1.2,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    children: resumo.entries.map((e) {
                      return pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          mainAxisSize: pw.MainAxisSize.min,
                          children: [
                            pw.Text(
                              e.value,
                              style: pw.TextStyle(
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                                color: _cinzaEscuro,
                              ),
                            ),
                            pw.Text(
                              e.key,
                              style: const pw.TextStyle(
                                fontSize: 8,
                                color: _cinzaMedio,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          pw.SizedBox(width: 10),
        ],
      ),
    );
  }




  pw.Widget _buildTabela<T>(
    List<String> cabecalhos,
    List<T> dados,
    List<String> Function(T) gerarLinhas,
  ) {
    return pw.Table(
      border: pw.TableBorder(
        horizontalInside: pw.BorderSide(color: _cinzaClaro, width: 0.5),
        bottom: pw.BorderSide(color: _cinzaMedio, width: 0.5),
      ),
      columnWidths: {
        for (var i = 0; i < cabecalhos.length; i++)
          i: const pw.FlexColumnWidth(),
      },
      children: [
        // Linha de cabeçalho
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _cinzaEscuro),
          children: cabecalhos
              .map(
                (h) => pw.Padding(
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                  child: pw.Text(
                    h.toUpperCase(),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                      color: _branco,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        // Linhas de dados com zebra
        ...dados.asMap().entries.map((entry) {
          final isEven = entry.key.isEven;
          final celulas = gerarLinhas(entry.value);
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isEven ? _branco : _cinzaClaro,
            ),
            children: celulas
                .map(
                  (c) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
                    child: pw.Text(
                      c,
                      style: const pw.TextStyle(
                          fontSize: 9, color: _cinzaEscuro),
                    ),
                  ),
                )
                .toList(),
          );
        }),
      ],
    );
  }

  /// Salva em arquivo temporário e retorna o caminho.
  Future<String> salvarArquivoTemp(Uint8List bytes, String nomeArquivo) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$nomeArquivo');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  bool get isDesktop =>
      !kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows);
}
