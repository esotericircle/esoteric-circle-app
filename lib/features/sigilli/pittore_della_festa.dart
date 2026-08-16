import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/maestro/maestro.dart';
import '../rituals/rune_strokes.dart';
import 'direzione_della_festa.dart';

/// IL PITTORE DELLE TRE FESTE. Ordine U voce 02.
///
/// **Una scena per Maestro, e si riconosce dal MOVIMENTO prima che dal colore.**
/// La direzione arriva da `FesteDeiMaestri` e non si decide qui: questo file
/// sa disegnare tre direzioni, non sa quale spetta a chi.
///
/// **Le particelle non sono casuali a ogni fotogramma.** Il seme e' fisso, cosi'
/// la stessa festa si ridisegna identica: una scena che cambia a ogni montaggio
/// non si puo' provare a pixel, e non e' piu' la TUA festa.
class PittoreDellaFesta extends CustomPainter {
  PittoreDellaFesta({
    required this.maestro,
    required this.avanzamento,
    required this.oro,
    required this.oroTenue,
    required this.eGrande,
    required this.effettiPieni,
  })  : _festa = FesteDeiMaestri.di(maestro),
        _quante = FesteDeiMaestri.particelleDi(maestro, eGrande: eGrande);

  final Maestro maestro;

  /// Da zero a uno.
  final double avanzamento;

  final Color oro;
  final Color oroTenue;
  final bool eGrande;

  /// **Falso con Riduci Movimento oppure con Quality Tier basso: la festa
  /// DEGRADA, non si spegne.** Restano il velo che scopre e il movimento
  /// essenziale, cade il pieno di particelle. Spegnerla vorrebbe dire non
  /// festeggiare chi ha chiesto meno movimento.
  final bool effettiPieni;

  final FestaDelMaestro _festa;
  final int _quante;

  /// **QUANTE PARTICELLE RESTANO QUANDO SI DEGRADA:** un quinto, e non zero.
  static const double quotaDelDegrado = 0.2;

  /// **NESSUNA RUNA PIU' GRANDE DI UN DODICESIMO DEL LATO CORTO.** Non e' una
  /// misura estetica: e' il confine oltre il quale un segno smette di essere una
  /// particella e diventa **un responso**. Una runa grande al centro dello
  /// schermo si legge come una gettata, e la persona ci troverebbe un
  /// significato che nessuno le ha dato.
  static const double quotaMassimaDellaRuna = 1 / 12;

  /// **I NUMERI DI UNA PARTICELLA DIPENDONO DAL SUO INDICE, non dall'ordine in
  /// cui si e' arrivati a lei.** Ordine AC voce 03.
  ///
  /// **Il difetto che questa riga chiude.** Prima le tre estrazioni si facevano
  /// dentro il ciclo e solo per le particelle gia' nate: una non nata ne
  /// consumava una, una nata tre. Cosi' **ogni nascita spostava il flusso di
  /// tutte quelle dopo di lei**, e le stelle gia' in volo saltavano in un altro
  /// punto invece di proseguire. Misurato prima della correzione: fra 0,18 e
  /// 0,19 cambiavano angolo quattordici stelle su trentacinque, fra 0,30 e 0,31
  /// trentatre su cinquantuno, e solo da 0,45 in poi, quando sono tutte nate, il
  /// disegno si stabilizzava. **Per il primo quarantacinque per cento della
  /// festa le particelle saltavano invece di aprirsi.**
  ///
  /// Adesso si estrae per TUTTE prima di qualunque filtro, quindi la particella
  /// numero venti prende sempre gli stessi tre numeri, che sia nata o no. Il seme
  /// complessivo resta fisso, quindi la stessa festa continua a ridisegnarsi
  /// identica.
  static List<({double ritardo, double quanto, double laterale})> numeriDelle(
    Maestro maestro,
    int quante, {
    required bool eGrande,
  }) {
    final caso = math.Random(maestro.index * 7919 + (eGrande ? 31 : 17));
    return List.generate(
      quante,
      (_) => (
        // Ogni particella parte con un suo ritardo, cosi' il fronte non e' una
        // riga netta: una festa che arriva tutta insieme e' un lampo, non un
        // movimento.
        ritardo: caso.nextDouble() * 0.45,
        quanto: caso.nextDouble(),
        laterale: caso.nextDouble(),
      ),
    );
  }

  /// Quante particelle disegna questa festa, degrado compreso.
  int get quanteParticelle => effettiPieni
      ? _quante
      : math.max(6, (_quante * quotaDelDegrado).round());

  /// **DOVE STA UNA PARTICELLA, come dato e non come effetto del disegno.**
  ///
  /// Serve alla prova che sorveglia il salto: senza, l'unico modo di sapere dove
  /// sta una stella sarebbe guardare i pixel, e due stelle vicine non si
  /// distinguerebbero. Chi disegna e chi misura passano di qui tutti e due,
  /// quindi non possono scostarsi.
  Map<int, Offset> posizioni(Size misura) {
    final quante = quanteParticelle;
    final numeri = numeriDelle(maestro, quante, eGrande: eGrande);
    final dove = <int, Offset>{};
    for (var i = 0; i < quante; i++) {
      final t = ((avanzamento - numeri[i].ritardo) / (1 - numeri[i].ritardo))
          .clamp(0.0, 1.0);
      if (t <= 0) continue;
      dove[i] = _dove(misura, numeri[i].quanto, numeri[i].laterale, t, i);
    }
    return dove;
  }

  @override
  void paint(Canvas tela, Size misura) {
    final quante = quanteParticelle;
    final numeri = numeriDelle(maestro, quante, eGrande: eGrande);
    for (var i = 0; i < quante; i++) {
      final t = ((avanzamento - numeri[i].ritardo) / (1 - numeri[i].ritardo))
          .clamp(0.0, 1.0);
      if (t <= 0) continue;
      _particella(tela, misura, numeri[i].quanto, numeri[i].laterale, t, i);
    }
  }

  Offset _dove(
      Size misura, double quanto, double laterale, double t, int indice) {
    final larghezza = misura.width, altezza = misura.height;
    late Offset dove;
    switch (_festa.direzione) {
      case DirezioneDellaFesta.dalCentro:
        // **DAL CENTRO VERSO FUORI**, e il centro e' il punto in cui il
        // traguardo si e' acceso, cioe' il mezzo della scena.
        final angolo = quanto * 2 * math.pi;
        final raggio = t * math.max(larghezza, altezza) * (0.35 + laterale);
        dove = Offset(larghezza / 2 + raggio * math.cos(angolo),
            altezza / 2 + raggio * math.sin(angolo) * 0.9);
      case DirezioneDellaFesta.dallAlto:
        // **DALL'ALTO VERSO IL BASSO**, e quando la cascata finisce sotto di lei
        // restano scoperti il traguardo e il premio.
        dove = Offset(quanto * larghezza, -0.1 * altezza + t * 1.25 * altezza);
      case DirezioneDellaFesta.dalBasso:
        // **DAL BASSO VERSO L'ALTO**, e nel salire scopre cio' che sta sotto.
        // Il polline non sale dritto: ondeggia, ed e' cio' che lo distingue da
        // una pioggia girata al contrario.
        final onda = math.sin(t * math.pi * 2 + indice) * larghezza * 0.06;
        dove = Offset(quanto * larghezza + onda,
            altezza * 1.05 - t * 1.2 * altezza);
    }
    return dove;
  }

  void _particella(Canvas tela, Size misura, double quanto, double laterale,
      double t, int indice) {
    final larghezza = misura.width, altezza = misura.height;
    final dove = _dove(misura, quanto, laterale, t, indice);
    // Le particelle si spengono verso la fine della loro corsa.
    final vigore = (1 - t * t) * (effettiPieni ? 1.0 : 0.75);
    final grandezza = (eGrande ? 1.35 : 1.0) * (5 + laterale * 9);
    final colore = (indice.isEven ? oro : oroTenue)
        .withValues(alpha: (0.85 * vigore).clamp(0.0, 1.0));
    // **IL TETTO SI IMPONE QUI, e non si lascia alla buona volonta' di chi
    // disegna.** Sotto questa misura un segno e' una particella, sopra e' un
    // responso: e' l'unico punto in cui il vincolo puo' valere per tutte e tre
    // le materie insieme.
    final corto = math.min(larghezza, altezza);
    final entroIlTetto =
        math.min(grandezza, corto * quotaMassimaDellaRuna / 2.4);
    switch (_festa.materia) {
      case MateriaDellaFesta.stelle:
        _stella(tela, dove, entroIlTetto, colore);
      case MateriaDellaFesta.rune:
        _runa(tela, dove, entroIlTetto, colore, indice);
      case MateriaDellaFesta.polline:
        _polline(tela, dove, entroIlTetto, colore, t);
    }
  }

  void _stella(Canvas tela, Offset centro, double raggio, Color colore) {
    final via = Path();
    for (var p = 0; p < 10; p++) {
      final r = p.isEven ? raggio : raggio * 0.42;
      final a = -math.pi / 2 + p * math.pi / 5;
      final punto =
          Offset(centro.dx + r * math.cos(a), centro.dy + r * math.sin(a));
      p == 0 ? via.moveTo(punto.dx, punto.dy) : via.lineTo(punto.dx, punto.dy);
    }
    via.close();
    tela.drawPath(via, Paint()..color = colore);
  }

  /// **LE RUNE SI DISEGNANO A TRATTI, MAI COME TESTO.**
  ///
  /// Si usa `kRuneStrokes`, che porta tutte e ventiquattro le rune dell'Elder
  /// Futhark come spezzate normalizzate fra zero e uno. **Un `TextPainter` col
  /// blocco runico rifarebbe esattamente il difetto appena chiuso**: nessuno dei
  /// due font del progetto, Cinzel ed EBGaramond, contiene quei glifi, e la
  /// pioggia tornerebbe una pioggia di quadrati. E' successo con le cifre e
  /// l'ha trovato un'anteprima, non una prova.
  ///
  /// **LA PIOGGIA NON DEVE MAI POTERSI LEGGERE COME UNA GETTATA, ed e' il
  /// vincolo piu' importante di questo metodo.** Vale la regola di casa sul
  /// contenuto oracolare: la runa, la carta e l'arcano discendono in modo
  /// deterministico da persona, giorno e domanda, **mai dal caso**. Una runa
  /// sola, grande, al centro sarebbe indistinguibile da un responso, e la
  /// persona ci leggerebbe un significato che nessuno le ha dato: una festa che
  /// per sbaglio profetizza e' peggio di una festa brutta. Quindi molte rune
  /// insieme, di misure diverse, e **nessuna piu' grande di
  /// [quotaMassimaDellaRuna] del lato corto dello schermo**.
  void _runa(
      Canvas tela, Offset centro, double misura, Color colore, int indice) {
    final nomi = kRuneStrokes.keys.toList();
    final spezzate = kRuneStrokes[nomi[indice % nomi.length]]!;
    final lato = misura * 2.4;
    final pennello = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = (lato * 0.14).clamp(1.0, 6.0)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = colore;
    for (final spezzata in spezzate) {
      if (spezzata.isEmpty) continue;
      final via = Path();
      for (var k = 0; k < spezzata.length; k++) {
        final punto = Offset(
          centro.dx + (spezzata[k].dx - 0.5) * lato,
          centro.dy + (spezzata[k].dy - 0.5) * lato,
        );
        k == 0 ? via.moveTo(punto.dx, punto.dy) : via.lineTo(punto.dx, punto.dy);
      }
      tela.drawPath(via, pennello);
    }
  }

  void _polline(
      Canvas tela, Offset centro, double misura, Color colore, double t) {
    // Un petalo: due archi che si chiudono a punta, inclinato secondo la salita.
    tela.save();
    tela.translate(centro.dx, centro.dy);
    tela.rotate(t * 1.8);
    final via = Path()
      ..moveTo(0, -misura)
      ..quadraticBezierTo(misura * 0.7, 0, 0, misura)
      ..quadraticBezierTo(-misura * 0.7, 0, 0, -misura)
      ..close();
    tela.drawPath(via, Paint()..color = colore);
    tela.restore();
  }

  @override
  bool shouldRepaint(covariant PittoreDellaFesta vecchio) =>
      vecchio.avanzamento != avanzamento ||
      vecchio.maestro != maestro ||
      vecchio.eGrande != eGrande ||
      vecchio.effettiPieni != effettiPieni;
}
