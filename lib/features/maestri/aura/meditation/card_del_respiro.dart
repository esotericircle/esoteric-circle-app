import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/condivisione/porta_della_condivisione.dart';
import '../../../synastry/sinastria_share_card.dart' show captureBoundaryPng;

import '../../../../core/brand/brand.dart';
import '../../../../core/maestro/chakra_del_giorno.dart';
import '../../../../core/maestro/libreria_dei_respiri.dart';
import '../../../../core/maestro/colore_del_centro.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';

/// **LA CARD DEL RESPIRO.** Ordine DB voce 10, 9 settembre 2026. Chiude anche
/// la voce CZ.09, che era rimasta ferma su lavoro non montato.
///
/// **Parole dell'ordine**: *"I tempi reali di inspiro e di espiro disegnano una
/// figura. Siccome nessuno respira come un altro, quella figura e' diversa ogni
/// volta e diversa da quella di chiunque."*
///
/// **PERCHE' LA FIGURA E' DAVVERO DIVERSA, e non e' un modo di dire.** Non
/// nasce da una categoria ne' da un numero arrotondato: nasce dalla **quota del
/// dentro** di ogni respiro, cioe' da quanto pesa l'inspiro sul respiro
/// intero, che e' un numero in virgola mobile misurato al millisecondo. Due
/// persone non hanno mai la stessa serie, e la stessa persona non la ripete
/// due volte.
///
/// **E' la stessa lezione della card del Viso**, imparata l'8 settembre: quella
/// diceva *"una costellazione su 104.976 possibili"* e prometteva unicita' che
/// a 382 utenti non reggeva. **Qui la promessa regge**, perche' la figura viene
/// da misure continue e non da caselle, ed e' per questo che il testo puo'
/// dirlo.
///
/// **CHI HA SCELTO IL RESPIRO GUIDATO**, e non il proprio, ottiene la card con
/// la forma del ritmo guidato, **dichiarata come tale**: sarebbe la figura
/// dell'app e non la sua, e spacciarla per sua sarebbe la prima bugia di questa
/// funzione.
///
/// ---
///
/// **E IL 10 SETTEMBRE 2026 IL DITO SE N'E' ANDATO.** Ordine DD voce 17,
/// decisione del fondatore: *"elimina la possibilita' di tenere il dito
/// premuto, solo pulsante play e stop"*.
///
/// **Quella decisione porta via anche la premessa di questa card**, e la cosa
/// va detta invece di essere aggirata: senza il dito non ci sono piu' i tempi
/// veri di nessuno, il fiore va col ritmo dell'app, e la figura sarebbe
/// **identica per tutti**. La frase *"dodici respiri: nessuno uguale al
/// precedente"* diventerebbe falsa il giorno stesso in cui la si e' scritta.
///
/// **Cosa c'e' adesso.** La card porta **il sigillo della sessione**, che nasce
/// da quattro dati veri: il sintomo scelto, la frequenza che ha suonato, il
/// centro acceso quel giorno e la **durata vera**. Vedi
/// [SigilloDellaSessione]. Cambia fra due persone e fra due sessioni, e **non
/// promette piu' di essere unica al mondo**, perche' non lo e'.
///
/// **E la card comincia con un titolo che si legge da fuori.** Chi la riceve in
/// una chat non sa cos'e' Esoteric Circle: *"IL TUO RESPIRO DI OGGI"* parlava a
/// chi era gia' dentro. *"MI SONO PRESO CINQUE MINUTI"* si capisce senza
/// sapere niente, e il numero e' vero.
class CardDelRespiro extends StatelessWidget {
  const CardDelRespiro({
    super.key,
    required this.figura,
    required this.giorno,
    required this.durata,
    this.sintomo,
    this.pratica,
    required this.hertz,
    this.giorniDiFila = 0,
    this.larghezza = 320,
  });

  /// Il sigillo della sessione, un valore per raggio, da zero a uno.
  /// Lo compone [SigilloDellaSessione.figura].
  final List<double> figura;

  /// Il giorno, da cui vengono il centro e il colore.
  final DateTime giorno;

  /// **QUANTO E' DURATA DAVVERO.** E' il numero del titolo, ed e' l'unico dato
  /// continuo della card: fa la differenza fra due minuti e dieci.
  final Duration durata;

  /// Il sintomo scelto, se la persona ha scelto lei. Nullo quando la pratica
  /// l'ha proposta Aura dal centro del giorno.
  final Sintomo? sintomo;

  /// Il nome della pratica, se ce n'e' una scelta.
  final String? pratica;

  /// La frequenza che ha suonato, in hertz.
  final int hertz;

  /// **DA QUANTI GIORNI DI FILA**, che e' la riga che fa tornare. Zero vuol
  /// dire che non si scrive: una striscia di uno non e' una striscia.
  final int giorniDiFila;

  final double larghezza;

  /// **IL TITOLO, e si legge senza sapere cos'e' questa app.** Ordine DD voce
  /// 17: *"inizia con titolo accattivante"*.
  ///
  /// Il numero e' vero e viene dalla durata. Sotto il minuto non si scrive una
  /// cifra che suonerebbe misera: si dice **un momento**, che e' onesto e non
  /// promette niente.
  static String titoloPer(Duration durata) {
    final minuti = durata.inMinutes;
    if (minuti < 1) return 'MI SONO PRESO UN MOMENTO';
    if (minuti == 1) return 'MI SONO PRESO UN MINUTO';
    return 'MI SONO PRESO $minuti MINUTI';
  }

  @override
  Widget build(BuildContext context) {
    final colore = ColoreDelCentro.di(giorno);
    final centro = ChakraDelGiorno.di(giorno);
    return Container(
      key: const Key('card_del_respiro'),
      width: larghezza,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(const Color(0xFF0B0620), colore, 0.18)!,
            const Color(0xFF07030F),
          ],
        ),
        border: Border.all(color: colore.withValues(alpha: 0.55), width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // **IL TITOLO PARLA A CHI NON SA COS'E' QUESTA APP.** Ordine DD
            // voce 17: qui c'era *"IL TUO RESPIRO DI OGGI"*, che si capisce
            // solo se sei gia' dentro. Una card si condivide, e chi la riceve
            // in una chat parte da zero.
            Text(titoloPer(durata),
                key: const Key('card_respiro_titolo'),
                textAlign: TextAlign.center,
                // **IL RUOLO, NON LA MISURA**: una misura scritta a mano su
                // una schermata sola e' debito tipografico, e una guardia
                // conta che non cresca.
                style: TypographyTokens.titoloScheda().copyWith(
                    color: ColoreDelCentro.bordoDi(colore),
                    letterSpacing: 1.4)),
            const SizedBox(height: SpacingTokens.md),
            SizedBox(
              width: larghezza * 0.82,
              height: larghezza * 0.52,
              child: CustomPaint(
                painter: PittoreDellaFigura(figura: figura, colore: colore),
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            // **I DATI, NON UN PARAGRAFO.** Ordine DD voce 17: *"includendo il
            // sintomo e la frequenza, ma non esagerare con il testo
            // descrittivo"*.
            //
            // Qui stavano tre frasi intere di Aura. Adesso stanno **al massimo
            // tre righe corte**, e ognuna e' un dato: cosa hai respirato, su
            // che frequenza, da quanti giorni. Chi guarda una card la guarda
            // due secondi.
            Text(
              righeDellaCard(
                sintomo: sintomo,
                pratica: pratica,
                hertz: hertz,
                giorno: giorno,
                giorniDiFila: giorniDiFila,
              ).join('\n'),
              key: const Key('card_respiro_righe'),
              textAlign: TextAlign.center,
              style: TypographyTokens.corpo()
                  .copyWith(color: const Color(0xFFF2E4C9), height: 1.5),
            ),
            const SizedBox(height: SpacingTokens.sm),
            // **IL PIEDE E' A CORPO E NON IN MAIUSCOLETTO**, e lo ha chiesto
            // una guardia: in maiuscoletto questa riga andava a capo, e *"il
            // maiuscoletto e' un segnale, non un testo: quando va a capo
            // diventa un muro di lettere larghe"*.
            Text('Esoteric Circle · Aura · ${centro.italiano}',
                style: TypographyTokens.corpo().copyWith(
                    color: ColoreDelCentro.bordoDi(colore)
                        .withValues(alpha: 0.75),
                    letterSpacing: 1.0)),
            const SizedBox(height: 2),
            Text(Brand.domain,
                key: const Key('card_respiro_indirizzo'),
                style: TypographyTokens.corpo().copyWith(
                    color: ColoreDelCentro.bordoDi(colore)
                        .withValues(alpha: 0.9),
                    letterSpacing: 0.8)),
          ],
        ),
      ),
    );
  }

  /// **LE RIGHE DELLA CARD, e sono dati e non prosa.** Ordine DD voce 17,
  /// 10 settembre 2026: *"includendo il sintomo e la frequenza, ma non
  /// esagerare con il testo descrittivo"*.
  ///
  /// **COSA C'ERA PRIMA, e va scritto perche' non torni.** Tre frasi intere di
  /// Aura, dell'ordine DB voce 10: quanti respiri, quale centro e cosa apre,
  /// piu' una frase da portare nella giornata. Erano scritte bene e **erano
  /// troppe**: una card si guarda due secondi, e in due secondi tre frasi
  /// diventano un blocco grigio che nessuno legge.
  ///
  /// **Al massimo tre righe corte, e ognuna e' un dato.**
  ///
  /// **Nessuna promessa di effetto**, e la guardia della voce DB.11 lo pretende
  /// su ogni testo di questa funzione: qui si dice **cosa hai fatto**, mai cosa
  /// ti succedera'.
  static List<String> righeDellaCard({
    required Sintomo? sintomo,
    required String? pratica,
    required int hertz,
    required DateTime giorno,
    int giorniDiFila = 0,
  }) {
    final centro = ChakraDelGiorno.di(giorno);
    final righe = <String>[];
    // **UNO. Per che cosa**, che e' la riga che chi guarda cerca per prima.
    // Senza un sintomo scelto la sessione e' quella che Aura propone dal
    // centro del giorno, e si dice quello: nominare un sintomo che nessuno ha
    // scelto sarebbe metterglielo in bocca.
    righe.add(sintomo != null
        ? 'Per ${sintomo.etichetta.toLowerCase()}'
        : 'Il centro di oggi: ${centro.italiano}');
    // **DUE. Cosa ha suonato**, la pratica e la frequenza sulla stessa riga.
    righe.add(pratica != null ? '$pratica · $hertz Hz' : '$hertz Hz');
    // **TRE. Da quanti giorni**, e solo se sono almeno due: una striscia di
    // uno non e' una striscia, e scriverla la sgonfia.
    if (giorniDiFila >= 2) righe.add('$giorniDiFila giorni di fila');
    return righe;
  }
}

/// Il pittore della figura del respiro. **Pubblico apposta**: la sua geometria
/// e' la cosa da misurare, e una guardia deve poterlo interrogare senza
/// montare una schermata.
class PittoreDellaFigura extends CustomPainter {
  PittoreDellaFigura({required this.figura, required this.colore});

  final List<double> figura;
  final Color colore;

  /// **QUANTO SONO DIVERSE DUE FIGURE**, come distanza media punto per punto.
  /// Serve alla guardia che prova che due respiri non danno lo stesso disegno.
  static double distanzaFra(List<double> a, List<double> b) {
    final quanti = a.length < b.length ? a.length : b.length;
    if (quanti == 0) return 0;
    var somma = 0.0;
    for (var i = 0; i < quanti; i++) {
      somma += (a[i] - b[i]).abs();
    }
    return somma / quanti;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (figura.isEmpty) return;
    final centro = size.center(Offset.zero);
    final raggio = size.shortestSide / 2 * 0.92;

    // **UNA CORONA DI RAGGI, uno per respiro.** Il raggio lungo e' un respiro
    // che ha tenuto dentro, quello corto uno che ha lasciato andare presto:
    // la figura si legge senza spiegazioni, e nessuna e' uguale a un'altra.
    final passo = 2 * math.pi / figura.length;
    final via = Path();
    for (var i = 0; i < figura.length; i++) {
      final q = figura[i].clamp(0.0, 1.0);
      final r = raggio * (0.35 + 0.65 * q);
      final a = -math.pi / 2 + i * passo;
      final punto = centro + Offset(math.cos(a), math.sin(a)) * r;
      if (i == 0) {
        via.moveTo(punto.dx, punto.dy);
      } else {
        via.lineTo(punto.dx, punto.dy);
      }
      canvas.drawCircle(
          punto, 2.4, Paint()..color = ColoreDelCentro.bordoDi(colore));
    }
    via.close();
    canvas.drawPath(
        via,
        Paint()
          ..style = PaintingStyle.fill
          ..color = colore.withValues(alpha: 0.30));
    canvas.drawPath(
        via,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = ColoreDelCentro.bordoDi(colore).withValues(alpha: 0.85));
  }

  @override
  bool shouldRepaint(covariant PittoreDellaFigura vecchio) =>
      vecchio.colore != colore ||
      vecchio.figura.length != figura.length;
}

/// **CONDIVIDE LA CARD, DAL PUNTO UNICO.** Ordine DB voce 10: *"passa dal
/// punto unico della condivisione. Non se ne scrive un altro."*
///
/// E' la stessa strada dell'Oroscopo e del Sigillo: il PNG nasce dal boundary,
/// finisce in un file temporaneo del telefono e va alla porta. **Nessun
/// server**, e l'esito vero risale a chi ha chiamato, perche' il premio della
/// condivisione si paga solo a condivisione avvenuta.
Future<bool> condividiLaCardDelRespiro({
  required GlobalKey boundaryKey,
  required String testo,
}) async {
  final png = await captureBoundaryPng(boundaryKey);
  if (png == null) return false;
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/card_del_respiro.png');
  await file.writeAsBytes(png, flush: true);
  return PortaDellaCondivisione.daFile(file.path, testo: testo);
}
