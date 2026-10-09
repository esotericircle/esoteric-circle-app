/// LE LINEE DELLE FIGURE DEL REAL TIME COSMO. Ordine FH parti 3 e 4.
///
/// Il file `assets/astro/linee_delle_figure.json` e' dell'Architetto: forme
/// classiche degli atlanti, coppie di stelle scritte per Esoteric Circle sul
/// catalogo HYG v4.1, nessuna riga presa da Stellarium. Ventiquattro figure,
/// 187 coppie; ogni stella e' nominata dal suo numero HIP e si trova nel
/// catalogo attraverso la mappa `perHip`, scritta dallo stesso generatore del
/// binario (ordine FH, fatto 1). Due coppie del quadrato di Pegaso uniscono
/// stelle di costellazioni diverse: il file le dichiara e qui non c'e' nessun
/// caso particolare (voce 3.4).
///
/// **La regola delle linee vive nel file**: il codice disegna le sue coppie e
/// nessun'altra (guardia `test/real_time_cosmo_nessuna_linea_inventata_test.dart`).
library;

import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import 'catalogo_delle_stelle.dart';

/// Una figura del file, col suo peso.
class FiguraDelCielo {
  const FiguraDelCielo({
    required this.iau,
    required this.nome,
    required this.stelleFinoAllaQuarta,
    required this.piuLuminosa,
    required this.stelle,
    required this.forza,
  });

  /// La sigla IAU, come nel catalogo: 'Sco', 'Leo'.
  final String iau;
  final String nome;

  /// Le stelle fino alla quarta magnitudine fra quelle che FORMANO la figura
  /// (agli estremi delle sue linee), dal file. Ordine FH, fatto 2: e' il
  /// numero giusto per il peso, perche' misura quanto si vede la figura e non
  /// la regione di cielo.
  final int stelleFinoAllaQuarta;
  final double piuLuminosa;

  /// Gli indici nel catalogo delle stelle della figura, senza ripetizioni.
  final List<int> stelle;

  /// Il peso della figura (voce 4.2), da 0,35 a 1.
  final double forza;
}

/// LA FORZA DI UNA FIGURA (voce 4.2): la radice quadrata del suo conto di
/// stelle fino alla quarta magnitudine diviso il conto della figura piu'
/// ricca del file, limitata fra 0,35 e 1. Il divisore si legge dal file, non
/// si scrive qui: oggi e' 16, lo Scorpione.
const double kForzaMinima = 0.35;
const double kForzaMassima = 1.0;

double forzaDellaFigura(int conto, int contoPiuRicco) =>
    math.sqrt(conto / math.max(1, contoPiuRicco)).clamp(kForzaMinima, kForzaMassima);

/// Il velo del segno della persona non scende mai sotto 0,70 di forza
/// (voce 4.4): e' il suo, e deve vedersi.
const double kForzaMinimaDelSegno = 0.70;

double forzaDelVelo(double forzaDellaFigura, {required bool eIlSegno}) =>
    eIlSegno ? math.max(kForzaMinimaDelSegno, forzaDellaFigura) : forzaDellaFigura;

class LeLineeDelleFigure {
  LeLineeDelleFigure._(this.figure, this.da, this.a, this.figuraDellaLinea,
      this.fonte, this.contoPiuRicco);

  final List<FiguraDelCielo> figure;

  /// Le coppie: per la linea k, gli indici nel catalogo dei suoi due capi.
  final Int32List da, a;

  /// Per la linea k, l'indice della sua figura in [figure].
  final Int32List figuraDellaLinea;

  /// La riga di provenienza del file.
  final String fonte;

  /// Il conto della figura piu' ricca, il divisore della forza.
  final int contoPiuRicco;

  int get numeroDiLinee => da.length;

  static LeLineeDelleFigure? _inMemoria;

  /// Le linee dal pacchetto, lette una volta sola per processo, come il
  /// catalogo. Ordine FH: rileggerle a ogni apertura della schermata, nelle
  /// prove, si fermava su `rootBundle.loadString` alla seconda montatura.
  static Future<LeLineeDelleFigure> carica(
      CatalogoDelleStelle catalogo, String percorso,
      {AssetBundle? bundle}) async {
    final gia = _inMemoria;
    if (gia != null) return gia;
    final testo = await (bundle ?? rootBundle).loadString(percorso);
    return _inMemoria = LeLineeDelleFigure.daJson(testo, catalogo);
  }

  /// La figura con la sigla IAU [iau], o nulla.
  int? indiceDi(String iau) {
    for (var i = 0; i < figure.length; i++) {
      if (figure[i].iau == iau) return i;
    }
    return null;
  }

  /// Legge il file. Un HIP che il catalogo non conosce SOLLEVA invece di
  /// saltare la linea: una linea che sparisce in silenzio e' una figura
  /// sbagliata con l'aria di quella giusta.
  factory LeLineeDelleFigure.daJson(String testo, CatalogoDelleStelle catalogo) {
    final dati = json.decode(testo) as Map<String, dynamic>;
    final grezze = dati['figure'] as Map<String, dynamic>;
    final chiavi = grezze.keys.toList()..sort();
    var piuRicco = 0;
    for (final k in chiavi) {
      final c = (grezze[k] as Map<String, dynamic>)['stelle_fino_a_mag4'] as int;
      if (c > piuRicco) piuRicco = c;
    }
    final figure = <FiguraDelCielo>[];
    final da = <int>[], a = <int>[], di = <int>[];
    int indice(String figura, int hip) {
      final i = catalogo.perHip[hip];
      if (i == null) {
        throw FormatException(
            'La figura $figura nomina la stella HIP $hip, che il catalogo non '
            'conosce.');
      }
      return i;
    }

    for (final k in chiavi) {
      final f = grezze[k] as Map<String, dynamic>;
      final stelle = <int>{};
      for (final coppia in f['linee'] as List) {
        final c = coppia as List;
        final i1 = indice(k, c[0] as int), i2 = indice(k, c[1] as int);
        da.add(i1);
        a.add(i2);
        di.add(figure.length);
        stelle
          ..add(i1)
          ..add(i2);
      }
      final conto = f['stelle_fino_a_mag4'] as int;
      figure.add(FiguraDelCielo(
        iau: k,
        nome: f['nome'] as String,
        stelleFinoAllaQuarta: conto,
        piuLuminosa: (f['piu_luminosa'] as num).toDouble(),
        stelle: List.unmodifiable(stelle),
        forza: forzaDellaFigura(conto, piuRicco),
      ));
    }
    return LeLineeDelleFigure._(
      List.unmodifiable(figure),
      Int32List.fromList(da),
      Int32List.fromList(a),
      Int32List.fromList(di),
      dati['fonte'] as String,
      piuRicco,
    );
  }
}
