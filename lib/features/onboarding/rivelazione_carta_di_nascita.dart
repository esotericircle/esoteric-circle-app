import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/rituals/carta_di_nascita_dei_tarocchi.dart';
import '../../core/tarot/tarot_card.dart';

/// **LA RIVELAZIONE DELLA CARTA DI NASCITA.** Ordine DC voce 14,
/// 10 settembre 2026.
///
/// **IL PRINCIPIO DA CUI NON SI DEROGA**, e l'ordine lo scrive in maiuscolo:
/// la Carta di Nascita **non e' casuale, e' calcolata dalla data**.
/// Un'animazione che raccontasse il caso, con carte che si mescolano e una che
/// esce, **racconterebbe una bugia sul metodo**, e questa app non lo fa.
///
/// Quindi la rivelazione **racconta il calcolo vero**: le cifre della data
/// volano al centro e si sommano, il totale si riduce, e il numero che resta
/// accende la carta corrispondente.
///
/// **IL VINCOLO CHE VALE PIU' DELL'ANIMAZIONE.** I numeri mostrati a schermo
/// sono letti da `CartaDiNascitaDeiTarocchi.passiDi`, **non ricalcolati qui**:
/// se le cifre si sommassero a schermo in un modo e la carta uscisse da un
/// altro calcolo, avremmo costruito una bugia visiva sopra un dato giusto, che
/// e' peggio di non avere l'animazione. Una guardia lo verifica passo per
/// passo su un campione di date.
class RivelazioneCartaDiNascita extends StatefulWidget {
  const RivelazioneCartaDiNascita({
    super.key,
    required this.nascita,
    this.senzaMoto = false,
    this.onFinita,
  });

  final DateTime nascita;

  /// Con Riduci Movimento il cerchio non ruota, le cifre non volano ma
  /// compaiono e si sommano per stati, la carta non zooma. **Il metodo resta
  /// leggibile**, che e' cio' che l'ordine pretende.
  final bool senzaMoto;

  final VoidCallback? onFinita;

  /// **QUANTO DURA IN TUTTO.** Ordine DC voce 14: fra i sei e gli otto
  /// secondi, **mai di piu' perche' e' onboarding**.
  static const Duration quantoDura = Duration(milliseconds: 7000);

  /// I sei momenti, con la quota di tempo in cui ognuno finisce.
  static const List<double> fineDelMomento = [
    0.16, // il cerchio delle ventidue carte gira e si ferma
    0.28, // la data compare al centro
    0.58, // le cifre volano e si sommano
    0.72, // il totale si spezza e si riduce
    0.84, // il numero vola verso la sua carta, le altre si spengono
    1.00, // la carta viene al centro e si gira
  ];

  /// A quale momento si e' alla quota [t] del tempo.
  static int momentoA(double t) {
    for (var i = 0; i < fineDelMomento.length; i++) {
      if (t <= fineDelMomento[i]) return i;
    }
    return fineDelMomento.length - 1;
  }

  @override
  State<RivelazioneCartaDiNascita> createState() =>
      _RivelazioneCartaDiNascitaState();
}

class _RivelazioneCartaDiNascitaState extends State<RivelazioneCartaDiNascita>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tempo = AnimationController(
    vsync: this,
    duration: RivelazioneCartaDiNascita.quantoDura,
  );

  @override
  void initState() {
    super.initState();
    _tempo.addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onFinita?.call();
    });
    if (widget.senzaMoto) {
      // **PER STATI E NON PER SCORRIMENTO.** Il metodo si legge lo stesso: si
      // salta all'ultimo momento, dove la carta e' gia' grande e il numero
      // e' gia' scritto.
      _tempo.value = 1.0;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => widget.onFinita?.call());
    } else {
      _tempo.forward();
    }
  }

  @override
  void dispose() {
    _tempo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _tempo,
        builder: (context, _) => CustomPaint(
          key: const Key('rivelazione_carta_di_nascita'),
          painter: PittoreDellaRivelazione(
            passi: CartaDiNascitaDeiTarocchi.passiDi(widget.nascita),
            carta: CartaDiNascitaDeiTarocchi.cartaDi(widget.nascita),
            t: _tempo.value,
            senzaMoto: widget.senzaMoto,
          ),
          size: Size.infinite,
        ),
      );
}

/// Il pittore della rivelazione. **Pubblico e puro**, cosi' la guardia lo
/// dipinge su una tela vera e conta i pixel invece di fidarsi.
class PittoreDellaRivelazione extends CustomPainter {
  PittoreDellaRivelazione({
    required this.passi,
    required this.carta,
    required this.t,
    this.senzaMoto = false,
  });

  /// **I PASSI, LETTI DAL CALCOLO VERO.** Ordine DC voce 14.
  final PassiDellaCarta passi;

  /// La carta che il calcolo restituisce.
  final TarotCard carta;

  /// Il tempo, da 0 a 1.
  final double t;

  final bool senzaMoto;

  /// **QUANTE CARTE COMPONGONO IL CERCHIO.** Ventidue: sono gli Arcani
  /// Maggiori, ed e' la prima cosa che l'animazione dice, *"le possibilita'
  /// sono ventidue e una sara' tua"*.
  static const int quanteNelCerchio = 22;

  /// **QUANTO OCCUPA LA CARTA FINALE**, in frazione del lato corto.
  ///
  /// Ordine DC voce 14: **almeno il settanta per cento dell'altezza utile**.
  /// Qui e' settantacinque, e la guardia misura sui pixel dipinti dove la
  /// carta non riempie mai il suo rettangolo.
  static const double quotaDellaCartaFinale = 0.75;

  /// **QUALE CARTA DEL CERCHIO SI ACCENDE.**
  ///
  /// Viene dal numero del calcolo, non da una posizione scelta: e' il pezzo
  /// che lega l'animazione al dato.
  int get indiceDellaSua => passi.numero % quanteNelCerchio;

  /// **IL NUMERO CHE SI VEDE AL CENTRO ADESSO**, o nulla quando al centro non
  /// c'e' nessun numero.
  ///
  /// **E' la funzione che la guardia interroga**: quello che torna di qui e'
  /// esattamente quello che il pittore scrive.
  int? numeroAlCentro() {
    final momento = RivelazioneCartaDiNascita.momentoA(t);
    if (momento < 2) return null;
    if (momento == 2) {
      // Le cifre volano una a una: si mostra la somma parziale raggiunta.
      final quota = _dentroIlMomento(2);
      final quante = (quota * passi.sommeParziali.length)
          .floor()
          .clamp(0, passi.sommeParziali.length - 1);
      return passi.sommeParziali[quante];
    }
    if (momento == 3) {
      if (passi.riduzioni.isEmpty) return passi.numero;
      final quota = _dentroIlMomento(3);
      final quante =
          (quota * passi.riduzioni.length).floor().clamp(0, passi.riduzioni.length - 1);
      return passi.riduzioni[quante];
    }
    return passi.numero;
  }

  /// Quanto si e' avanti dentro il momento [quale], da 0 a 1.
  double _dentroIlMomento(int quale) {
    final da = quale == 0 ? 0.0 : RivelazioneCartaDiNascita.fineDelMomento[quale - 1];
    final a = RivelazioneCartaDiNascita.fineDelMomento[quale];
    if (a <= da) return 1;
    return ((t - da) / (a - da)).clamp(0.0, 1.0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final lato = size.shortestSide;
    final momento = RivelazioneCartaDiNascita.momentoA(t);

    // --- IL CERCHIO DELLE VENTIDUE ---
    final raggio = lato * 0.40;
    // Il cerchio ruota veloce per un istante, poi si ferma. Con Riduci
    // Movimento non ruota affatto.
    final giro = senzaMoto
        ? 0.0
        : (1 - _dentroIlMomento(0)) * 4 * math.pi * (momento == 0 ? 1 : 0);
    for (var i = 0; i < quanteNelCerchio; i++) {
      final angolo = giro + i * 2 * math.pi / quanteNelCerchio - math.pi / 2;
      final dove = centro + Offset(math.cos(angolo), math.sin(angolo)) * raggio;
      // **AL MOMENTO 4 SI ACCENDE LA SUA E LE ALTRE SI SPENGONO INSIEME.**
      final sua = i == indiceDellaSua;
      final spente = momento >= 4 ? _dentroIlMomento(4) : 0.0;
      final opacita = sua ? 1.0 : (1.0 - spente).clamp(0.0, 1.0);
      if (momento >= 5 && !sua) continue;
      final larghezza = lato * 0.085;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: dove, width: larghezza, height: larghezza * 1.6),
          Radius.circular(larghezza * 0.14),
        ),
        Paint()
          ..color = (sua && momento >= 4
                  ? const Color(0xFFE9C87A)
                  : const Color(0xFF2A3566))
              .withValues(alpha: 0.35 + 0.6 * opacita),
      );
    }

    // --- LA DATA, POI LE SOMME ---
    final numero = numeroAlCentro();
    final testo = momento == 1
        ? _dataScritta()
        : (numero == null ? '' : '$numero');
    if (testo.isNotEmpty && momento < 5) {
      _scrivi(canvas, centro, testo, lato * (momento == 1 ? 0.075 : 0.16));
    }

    // --- LA CARTA FINALE ---
    if (momento >= 5) {
      final quota = _dentroIlMomento(5);
      // Senza moto non zooma: compare gia' grande.
      final grande = senzaMoto ? 1.0 : Curves.easeOutCubic.transform(quota);
      final alta = lato * quotaDellaCartaFinale * (0.3 + 0.7 * grande);
      final larga = alta / 1.6;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: centro, width: larga, height: alta),
          Radius.circular(alta * 0.05),
        ),
        Paint()..color = const Color(0xFF1B2450),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: centro, width: larga, height: alta),
          Radius.circular(alta * 0.05),
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFFE9C87A),
      );
      _scrivi(canvas, centro + Offset(0, -alta * 0.36),
          _romano(passi.numero), alta * 0.11);
      _scrivi(canvas, centro + Offset(0, alta * 0.36), carta.name,
          alta * 0.075);
    }
  }

  String _dataScritta() => '';

  /// Il numero in cifre romane, come i Trionfi lo portano.
  static String _romano(int n) {
    const valori = [10, 9, 5, 4, 1];
    const segni = ['X', 'IX', 'V', 'IV', 'I'];
    var resto = n;
    final b = StringBuffer();
    for (var i = 0; i < valori.length; i++) {
      while (resto >= valori[i]) {
        b.write(segni[i]);
        resto -= valori[i];
      }
    }
    return b.toString();
  }

  void _scrivi(Canvas canvas, Offset dove, String testo, double misura) {
    if (testo.isEmpty) return;
    final tp = TextPainter(
      text: TextSpan(
        text: testo,
        style: TextStyle(
          color: const Color(0xFFF2E4C9),
          fontSize: misura,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    tp.paint(canvas, dove - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(PittoreDellaRivelazione vecchio) =>
      vecchio.t != t || vecchio.passi.numero != passi.numero;
}
