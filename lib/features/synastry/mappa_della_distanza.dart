import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/synastry/possibilita_di_incontro.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../onboarding/nazioni_del_mondo.dart';
import '../../core/astro/city_catalog.dart';
import '../../design_system/tokens/color_tokens.dart';

/// L'INQUADRATURA DELLA MAPPA, in gradi di longitudine.
///
/// **La mappa parte stretta sul punto della persona e si allarga fino alla
/// citta' del VIP.** Se abita nella stessa citta' lo zoom NON si allarga, e
/// quella e' la sorpresa: la scena che stavi aspettando non arriva, perche'
/// non serve.
class InquadraturaDellaMappa {
  const InquadraturaDellaMappa({
    required this.centro,
    required this.larghezzaInGradi,
  });

  /// Il centro dell'inquadratura, in gradi.
  final ({double lat, double lon}) centro;

  /// **Vero se quel punto sta dentro il riquadro visibile.** Il riquadro e'
  /// largo [larghezzaInGradi] e alto la stessa cosa diviso il rapporto della
  /// scena, che vale 1,6: la mappa e' piu' larga che alta, e in latitudine
  /// ci sta meno.
  bool contiene(({double lat, double lon}) punto) {
    const rapporto = 1.6;
    final mezzaLarghezza = larghezzaInGradi / 2;
    final mezzaAltezza = larghezzaInGradi / rapporto / 2;
    return (punto.lon - centro.lon).abs() <= mezzaLarghezza &&
        (punto.lat - centro.lat).abs() <= mezzaAltezza;
  }

  /// Quanto e' larga l'inquadratura, in gradi di longitudine.
  final double larghezzaInGradi;

  /// **QUANTO E' STRETTA LA PARTENZA**, in gradi: circa dieci chilometri, cioe'
  /// il tuo quartiere. E' anche l'inquadratura che RESTA quando il VIP vive
  /// nella tua stessa citta'.
  static const double partenza = 0.12;

  /// La larghezza in chilometri, alla latitudine del centro.
  double get larghezzaInChilometri =>
      larghezzaInGradi * 111.32 * math.cos(centro.lat * math.pi / 180).abs();

  /// L'inquadratura a un dato punto della corsa, da 0 a 1.
  ///
  /// **Non si allarga oltre quanto serve a tenere dentro tutti e due i punti**,
  /// con un margine: una mappa che si apre sul mondo intero per due citta'
  /// vicine sarebbe un effetto, non un'informazione.
  static InquadraturaDellaMappa a(
    double avanzamento, {
    required ({double lat, double lon}) tu,
    required ({double lat, double lon}) lui,
  }) {
    final dLon = (lui.lon - tu.lon).abs();
    final dLat = (lui.lat - tu.lat).abs();
    final serve = math.max(dLon, dLat * 1.6) * 1.4;
    final arrivo = serve < partenza ? partenza : serve;
    final t = avanzamento.clamp(0.0, 1.0);
    // La corsa e' esponenziale perche' lo zoom si legge cosi': raddoppiare
    // due volte sembra lo stesso salto, sommare due volte no.
    final larghezza = partenza * math.pow(arrivo / partenza, t);
    // **LA CORSA FINISCE IN MEZZO AI DUE, NON SU DI LUI. Ordine BX voce 06,
    // quinto rilievo.**
    //
    // **Il fatto del fondatore era "le mappe si vedono troppo ingrandite", e
    // la causa non era lo zoom: era il centro.** La corsa portava il centro
    // fino alla citta' del VIP, mentre la larghezza restava quella che serve
    // a tenere dentro la DISTANZA fra i due. Con il centro su di lui, il tuo
    // punto sta a una distanza intera dal centro mentre il riquadro ne
    // contiene sette decimi per lato: **alla fine della corsa tu eri fuori
    // dall'inquadratura**, e la mappa mostrava una citta' sola ingrandita.
    // Non c'era modo di rimediare guardando, perche' l'unica cosa che
    // mancava era proprio l'altro capo della distanza.
    //
    // Adesso il centro arriva a META' STRADA: con la larghezza di prima, che
    // vale 1,4 volte la distanza, i due punti stanno dentro tutti e due con
    // due decimi di margine per lato.
    final meta = (lat: (tu.lat + lui.lat) / 2, lon: (tu.lon + lui.lon) / 2);
    return InquadraturaDellaMappa(
      centro: (
        lat: tu.lat + (meta.lat - tu.lat) * t,
        lon: tu.lon + (meta.lon - tu.lon) * t,
      ),
      larghezzaInGradi: larghezza.toDouble(),
    );
  }
}

/// I RIFERIMENTI DELLA MAPPA: le citta' che dicono dove sei. Ordine CC voce 06a.
///
/// **Rilievo del fondatore, 29 agosto 2026, verbatim:** "avevo gia' chiesto di
/// rivedere tutte le mappe delle distanze tra vip e utente o tra 2 vip perche'
/// quando sono vicini, non si capisce visivamente dove si trovano, nemmeno la
/// nazione e magari inserisci i nomi delle capitali o capoluoghi o citta' piu'
/// grandi come riferimento, ma anche le citta' dove vivono".
///
/// **Da dove vengono i nomi, e perche' non serve nessuna rete.** Dal catalogo
/// dei luoghi che l'app ha gia' nel bundle, `assets/data/luoghi.csv`: undicimila
/// citta' con le loro coordinate, **ordinate per popolazione decrescente**. Le
/// prime che cadono dentro l'inquadratura sono le piu' grandi che si vedono, e
/// sono esattamente i riferimenti che il fondatore chiede.
///
/// **Quante**: al massimo sei. Una mappa piccola con venti nomi sopra non dice
/// dove sei, dice che c'e' molta gente.
/// **DA UN PUNTO ALLA SUA NAZIONE. Ordine CD voce 02a.**
///
/// Il fondatore aveva scritto "non si capisce visivamente dove si trovano,
/// **nemmeno la nazione**", e le citta' di riferimento dell'ordine CC voce 06a
/// rispondevano solo a meta': a chi conosce Torino e Bologna dicono l'Italia,
/// a chiunque altro no, e su una mappa di due punti stranieri non dicono
/// niente.
///
/// **Nessun dato nuovo.** La nazione si ricava dal catalogo dei luoghi, che
/// questa mappa gia' apre per scegliere i riferimenti: si prende il paese
/// della citta' piu' vicina al punto. Con 40.846 luoghi in catalogo, dopo
/// l'ordine CC voce 07, il piu' vicino a una capitale e' la capitale stessa.
abstract final class NazioneDelPunto {
  /// Oltre questa distanza in gradi non si dichiara nessuna nazione: meglio
  /// tacere che scrivere il paese sbagliato per un punto in mezzo al mare.
  static const double troppoLontano = 3.0;

  static String? di(({double lat, double lon}) punto) {
    String? vicina;
    var minimo = double.infinity;
    for (final c in CityCatalog.luoghi) {
      final dlat = c.latitude - punto.lat;
      final dlon = c.longitude - punto.lon;
      final d = dlat * dlat + dlon * dlon;
      if (d < minimo) {
        minimo = d;
        vicina = c.country;
      }
    }
    if (vicina == null || minimo > troppoLontano * troppoLontano) return null;
    // Nel catalogo i luoghi italiani portano la sigla della provincia, due
    // lettere maiuscole, e gli esteri il nome del paese in italiano.
    if (vicina.length == 2 && vicina == vicina.toUpperCase()) return 'Italia';
    return vicina;
  }
}

abstract final class RiferimentiDellaMappa {
  /// Quanti nomi al massimo, oltre ai due punti della coppia.
  static const int quanti = 6;

  /// Le citta' piu' grandi dentro [q], escluse quelle troppo vicine ai due
  /// punti della coppia, che avrebbero il nome sovrapposto.
  static List<City> dentro(
    InquadraturaDellaMappa q, {
    required ({double lat, double lon}) tu,
    required ({double lat, double lon}) lui,
  }) {
    final fuoriMano = <({double lat, double lon})>[tu, lui];
    // Quanto vicino e' "troppo vicino": un decimo della larghezza inquadrata.
    final troppoVicino = q.larghezzaInGradi * 0.1;
    final out = <City>[];
    for (final c in CityCatalog.luoghi) {
      if (out.length >= quanti) break;
      final p = (lat: c.latitude, lon: c.longitude);
      if (!q.contiene(p)) continue;
      final addosso = fuoriMano.any((x) =>
          (x.lat - p.lat).abs() < troppoVicino &&
          (x.lon - p.lon).abs() < troppoVicino);
      if (addosso) continue;
      final gia = out.any((y) =>
          (y.latitude - c.latitude).abs() < troppoVicino &&
          (y.longitude - c.longitude).abs() < troppoVicino);
      if (gia) continue;
      out.add(c);
    }
    return out;
  }
}

/// LA MAPPA DELLA DISTANZA. Ordine BO voce 09.
///
/// **Si usa il disegno delle nazioni gia' presente nel repository**, cioe'
/// `assets/data/nazioni.csv` e `NazioniDelMondo`, non un servizio di mappe
/// esterno: nessuna rete, nessuna chiave, nessun riquadro che resta grigio
/// quando il telefono e' offline.
///
/// **Per chi non c'e' piu' questa scena non esiste**, ordine BO voce 04: la
/// mappa non si monta affatto, perche' non c'e' nessun incontro da misurare.
class MappaDellaDistanza extends StatefulWidget {
  const MappaDellaDistanza({
    super.key,
    required this.incontro,
    required this.doveSei,
    required this.palette,
    this.riduciMovimento = false,
  });

  final PossibilitaDiIncontro incontro;
  final DoveSei doveSei;
  final MaestroPalette palette;
  final bool riduciMovimento;

  /// Quanto dura la corsa dello zoom.
  static const Duration corsa = Duration(milliseconds: 1400);

  @override
  State<MappaDellaDistanza> createState() => _MappaDellaDistanzaState();
}

class _MappaDellaDistanzaState extends State<MappaDellaDistanza>
    with SingleTickerProviderStateMixin {
  late final AnimationController _zoom;

  @override
  void initState() {
    super.initState();
    _zoom = AnimationController(vsync: this, duration: MappaDellaDistanza.corsa)
      ..forward();
    // Con Riduci Movimento la mappa e' gia' all'arrivo: l'informazione resta
    // tutta, non si muove niente.
    if (widget.riduciMovimento) _zoom.value = 1;
    NazioniDelMondo.ensureLoaded().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _zoom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sua = widget.incontro;
    final tu =
        (lat: widget.doveSei.latitudine, lon: widget.doveSei.longitudine);
    // Senza la citta' del VIP non c'e' nessuna distanza da percorrere.
    final km = sua.chilometri;
    final lui = sua.sueCoordinate;
    if (!sua.esiste || km == null || lui == null) {
      return const SizedBox.shrink();
    }
    return AnimatedBuilder(
      animation: _zoom,
      builder: (context, _) {
        final q = InquadraturaDellaMappa.a(_zoom.value, tu: tu, lui: lui);
        return Column(
          children: [
            AspectRatio(
              aspectRatio: 1.6,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                child: CustomPaint(
                  key: const Key('sinastria_mappa'),
                  painter: _DisegnoDellaMappa(
                    inquadratura: q,
                    tu: tu,
                    lui: lui,
                    palette: widget.palette,
                    tuaCitta: widget.doveSei.citta,
                    suaCitta: sua.suaCitta,
                    // La nazione si ricava una volta sola qui e non dentro il
                    // pittore: il pittore ridipinge a ogni fotogramma della
                    // corsa dello zoom, e cercare la citta' piu' vicina fra
                    // quarantamila a ogni fotogramma sarebbe uno spreco.
                    tuaNazione: NazioneDelPunto.di(tu),
                    suaNazione: NazioneDelPunto.di(lui),
                    riferimenti:
                        RiferimentiDellaMappa.dentro(q, tu: tu, lui: lui),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Text(
              _laRiga(km, _zoom.value),
              key: const Key('sinastria_mappa_chilometri'),
              textAlign: TextAlign.center,
              style: TypographyTokens.didascalia()
                  .copyWith(color: widget.palette.goldSoft),
            ),
            // **DA DOVE SI MISURA, DETTO. Ordine CF voce 13.**
            //
            // **Rilievo del fondatore, verbatim**: "il calcolo viene fatto
            // sulla citta' natale, ma se adesso vivessi in altro luogo?"
            // Misurato: la mappa legge il luogo dichiarato quando c'e' e
            // ripiega su quello di nascita quando non c'e', **e non lo diceva
            // a nessuno**. Un numero che non dichiara da dove nasce e' la
            // stessa bugia di un titolo senza testo.
            const SizedBox(height: SpacingTokens.xxs),
            Text(
              // **`citta` senza accento e' il NOME DEL CAMPO, non una
              // parola a video**, ma la prova che legge le frasi mostrate
              // non ha modo di distinguerli: le va incontro un nome che
              // non le somiglia.
              'Misurato da ${widget.doveSei.luogoDetto}'
              '${widget.doveSei.dichiarato ? "" : ", la tua città di nascita: "
                  "dilla in \"I tuoi dati\" se vivi altrove"}.',
              key: const Key('sinastria_mappa_da_dove'),
              textAlign: TextAlign.center,
              style: TypographyTokens.didascalia()
                  .copyWith(color: ColorTokens.textSecondary),
            ),
          ],
        );
      },
    );
  }

  /// I chilometri che scorrono, e alla fine il numero vero.
  String _laRiga(double km, double t) {
    if (km < 20) {
      return 'Nella tua stessa città. Lo zoom non si allarga: '
          'non c\'è nessuna distanza da percorrere.';
    }
    final scorsi = (km * t).round();
    return '$scorsi km da te';
  }
}

class _DisegnoDellaMappa extends CustomPainter {
  const _DisegnoDellaMappa({
    required this.inquadratura,
    required this.tu,
    required this.lui,
    required this.palette,
    required this.tuaCitta,
    required this.suaCitta,
    required this.tuaNazione,
    required this.suaNazione,
    required this.riferimenti,
  });

  final InquadraturaDellaMappa inquadratura;
  final ({double lat, double lon}) tu;
  final ({double lat, double lon}) lui;
  final MaestroPalette palette;

  /// Come si chiamano i due punti. Senza i nomi, due pallini su una linea non
  /// dicono dove sei: e' il rilievo del fondatore.
  final String tuaCitta;
  final String? suaCitta;

  /// Il paese di ognuno dei due punti, ricavato dal catalogo dei luoghi.
  /// Nullo quando il punto e' troppo lontano da qualunque citta' conosciuta.
  final String? tuaNazione;
  final String? suaNazione;

  /// Le citta' grandi attorno, che danno il senso del luogo.
  final List<City> riferimenti;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size,
        Paint()..color = palette.deepest.withValues(alpha: 0.9));
    final scala = size.width / inquadratura.larghezzaInGradi;
    Offset dove(({double lat, double lon}) p) => Offset(
          size.width / 2 + (p.lon - inquadratura.centro.lon) * scala,
          size.height / 2 - (p.lat - inquadratura.centro.lat) * scala,
        );

    // I CONTORNI DELLE NAZIONI, quelli veri gia' nel repository.
    final terra = Paint()
      ..color = palette.gold.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (final anelli in NazioniDelMondo.tuttiIContorni) {
      for (final anello in anelli) {
        Path? tracciato;
        for (final p in anello) {
          final o = dove(p);
          if (o.dx < -size.width ||
              o.dx > size.width * 2 ||
              o.dy < -size.height ||
              o.dy > size.height * 2) {
            tracciato = null;
            continue;
          }
          if (tracciato == null) {
            tracciato = Path()..moveTo(o.dx, o.dy);
          } else {
            tracciato.lineTo(o.dx, o.dy);
          }
        }
        if (tracciato != null) canvas.drawPath(tracciato, terra);
      }
    }

    // **I RIFERIMENTI, prima del filo.** Ordine CC voce 06a: stanno sotto,
    // perche' sono il fondale, e la coppia deve restare sopra a tutto.
    for (final c in riferimenti) {
      final o = dove((lat: c.latitude, lon: c.longitude));
      canvas.drawCircle(
          o, 2, Paint()..color = palette.goldSoft.withValues(alpha: 0.45));
      _scrivi(canvas, c.name, o + const Offset(5, -6), size,
          palette.goldSoft.withValues(alpha: 0.7), 9);
    }

    // IL FILO FRA I DUE PUNTI, e i due punti.
    final a = dove(tu);
    final b = dove(lui);
    canvas.drawLine(
        a,
        b,
        Paint()
          ..color = palette.goldSoft.withValues(alpha: 0.7)
          ..strokeWidth = 1.4);
    canvas.drawCircle(a, 4, Paint()..color = palette.goldSoft);
    canvas.drawCircle(
        b,
        4,
        Paint()
          ..color = palette.primary
          ..style = PaintingStyle.fill);
    canvas.drawCircle(
        b,
        6,
        Paint()
          ..color = palette.goldSoft
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);

    // **I NOMI DELLE DUE CITTA', e sono la meta' del rilievo.** Il fondatore:
    // "non si capisce visivamente dove si trovano, nemmeno la nazione [...] ma
    // anche le citta' dove vivono". Due pallini su una linea non dicono dove
    // sei.
    _scrivi(
        canvas, tuaCitta, a + const Offset(7, -8), size, palette.goldSoft, 11);
    if (suaCitta != null) {
      _scrivi(canvas, suaCitta!, b + const Offset(9, -8), size,
          palette.goldSoft, 11);
    }

    // **E LA NAZIONE SOTTO IL NOME. Ordine CD voce 02a.** Il fondatore aveva
    // scritto "nemmeno la nazione": la citta' dice dove, il paese dice in che
    // mondo. Piu' piccola e piu' spenta del nome, perche' e' la seconda cosa
    // che si legge, non la prima. Quando i due punti stanno nello stesso
    // paese il nome compare una volta sola, sotto il tuo: ripeterlo sarebbe
    // rumore.

    if (tuaNazione != null) {
      _scrivi(canvas, tuaNazione!, a + const Offset(7, 4), size,
          ColorTokens.textSecondary, 9);
    }
    if (suaCitta != null && suaNazione != null && suaNazione != tuaNazione) {
      _scrivi(canvas, suaNazione!, b + const Offset(9, 4), size,
          ColorTokens.textSecondary, 9);
    }
  }

  /// Scrive un nome sulla mappa, tenendolo dentro il riquadro.
  ///
  /// **Il nome non esce dal bordo**, e non e' pignoleria: sulla mappa stretta
  /// la citta' di chi guarda sta al centro e quella del VIP sul bordo, quindi
  /// meta' dei nomi cadrebbe fuori dal riquadro e verrebbe tagliata proprio
  /// mentre la scena serve a dire dove sono.
  void _scrivi(Canvas canvas, String testo, Offset dove, Size size,
      Color colore, double misura) {
    final p = TextPainter(
      text: TextSpan(
        text: testo,
        style: TextStyle(
          color: colore,
          fontSize: misura,
          fontFamily: 'EBGaramond',
          shadows: const [
            Shadow(color: Color(0xCC000000), blurRadius: 3),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = dove.dx.clamp(2.0, size.width - p.width - 2);
    final y = dove.dy.clamp(2.0, size.height - p.height - 2);
    p.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(_DisegnoDellaMappa vecchio) =>
      vecchio.inquadratura.larghezzaInGradi != inquadratura.larghezzaInGradi ||
      vecchio.inquadratura.centro != inquadratura.centro ||
      vecchio.riferimenti.length != riferimenti.length;
}
