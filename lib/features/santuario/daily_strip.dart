import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/astro/sky_location.dart';
import '../../core/astro/sunset_time.dart';
import '../../core/maestro/maestro.dart';
import '../../core/rituals/daily_elements.dart';
import '../../core/rituals/sunset_rune.dart';
import '../../core/rituals/sunset_rune_memory.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../rituals/breath_destiny_screen.dart';
import '../rituals/dawn_rite_screen.dart';
import '../rituals/day_oracle_screen.dart';
import '../rituals/dream_rite_screen.dart';
import '../rituals/sunset_rune_screen.dart';

const Color _gold = Color(0xFFE8C463);

/// La route dell'esperienza di un elemento giornaliero. Un solo posto che lega
/// l'elemento alla sua schermata, cosi' lo usano sia il tocco sulla striscia sia
/// il deep-link da notifica push.
Route<void> dailyElementRoute(DailyElement element) {
  switch (element) {
    case DailyElement.dawn:
      return DawnRiteScreen.route();
    case DailyElement.breath:
      return BreathDestinyScreen.route();
    case DailyElement.oracle:
      return DayOracleScreen.route();
    case DailyElement.rune:
      return SunsetRuneScreen.route();
    case DailyElement.night:
      return DreamRiteScreen.route();
  }
}

/// Apre direttamente l'esperienza dell'elemento, senza schermata intermedia di
/// dominio. Alla chiusura si torna da dove si e' partiti (il Santuario).
void openDailyElement(BuildContext context, DailyElement element) {
  Navigator.of(context).push(dailyElementRoute(element));
}

/// L'icona dell'elemento nella striscia del giorno, come widget cosi' Alba e
/// Tramonto possono usare un disegno dedicato, inequivocabile su sale e scende.
///
/// Alba: sole che sorge sull'orizzonte con raggi verso l'alto. Soffio: soffio di
/// vento. Oracolo: sole pieno. Tramonto: sole caldo che scende sull'orizzonte,
/// mai una luna. Notte: luna con una piccola stella.
Widget _elementIcon(DailyElement element,
    {required Color color, required double size}) {
  final key = Key('daily_icon_${element.name}');
  switch (element) {
    case DailyElement.dawn:
      return _SunHorizonIcon(key: key, color: color, size: size, rising: true);
    case DailyElement.breath:
      return Icon(Icons.air_rounded, key: key, size: size, color: color);
    case DailyElement.oracle:
      return Icon(Icons.wb_sunny_rounded, key: key, size: size, color: color);
    case DailyElement.rune:
      return _SunHorizonIcon(key: key, color: color, size: size, rising: false);
    case DailyElement.night:
      return Icon(Icons.nights_stay_rounded,
          key: key, size: size, color: color);
  }
}

/// Sole sull'orizzonte, disegnato: una cupola solare che poggia sulla linea
/// dell'orizzonte, con una freccia direzionale che ne dice il verso. In su per
/// il Rito dell'Alba (con raggi che salgono), in giu' per la Runa del Tramonto.
class _SunHorizonIcon extends StatelessWidget {
  const _SunHorizonIcon({
    super.key,
    required this.color,
    required this.size,
    required this.rising,
  });

  final Color color;
  final double size;
  final bool rising;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SunHorizonPainter(color: color, rising: rising),
      ),
    );
  }
}

class _SunHorizonPainter extends CustomPainter {
  _SunHorizonPainter({required this.color, required this.rising});

  final Color color;
  final bool rising;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final horizonY = h * 0.66;
    final r = w * 0.2;

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.075
      ..strokeCap = StrokeCap.round
      ..color = color;
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    // La linea dell'orizzonte.
    canvas.drawLine(
        Offset(w * 0.1, horizonY), Offset(w * 0.9, horizonY), stroke);

    // La cupola del sole che poggia sull'orizzonte.
    final dome = Path()
      ..moveTo(cx - r, horizonY)
      ..arcToPoint(Offset(cx + r, horizonY),
          radius: Radius.circular(r), clockwise: true)
      ..close();
    canvas.drawPath(dome, fill);

    if (rising) {
      // Raggi che salgono attorno alla cupola.
      for (final a in const [-1.4, -1.0, -0.6, -2.14, -2.54]) {
        final dir = Offset(math.cos(a), math.sin(a));
        final p1 = Offset(cx, horizonY) + dir * (r * 1.35);
        final p2 = Offset(cx, horizonY) + dir * (r * 1.95);
        canvas.drawLine(p1, p2, stroke);
      }
      // Freccia in su, sopra il sole: il giorno che nasce.
      final apex = Offset(cx, h * 0.08);
      canvas.drawLine(apex, apex + Offset(-w * 0.14, h * 0.12), stroke);
      canvas.drawLine(apex, apex + Offset(w * 0.14, h * 0.12), stroke);
    } else {
      // Raggi corti e calmi ai lati, il sole che cala.
      for (final a in const [-0.35, -2.79]) {
        final dir = Offset(math.cos(a), math.sin(a));
        final p1 = Offset(cx, horizonY) + dir * (r * 1.3);
        final p2 = Offset(cx, horizonY) + dir * (r * 1.75);
        canvas.drawLine(p1, p2, stroke);
      }
      // Freccia in giu', sotto l'orizzonte: il sole che tramonta.
      final tip = Offset(cx, h * 0.92);
      canvas.drawLine(tip, tip + Offset(-w * 0.14, -h * 0.12), stroke);
      canvas.drawLine(tip, tip + Offset(w * 0.14, -h * 0.12), stroke);
    }
  }

  @override
  bool shouldRepaint(_SunHorizonPainter old) =>
      old.color != color || old.rising != rising;
}

/// L'accento dell'elemento: il colore del Maestro che lo guida.
///
/// **Prima l'Alba restava oro, e non era giusto.** I due riti che ruotano, Alba
/// e Buonanotte, non hanno un Maestro fisso, e per questo cadevano nell'oro
/// generico: ma un Maestro di turno ce l'hanno eccome, ed e' quello che porge
/// il rito di oggi. La bolla adesso prende il suo colore, blu per Medora, verde
/// per Aura, rosso per Caligo.
///
/// **Il colore nasce da un punto solo.** Chi sia il Maestro lo dice
/// `DailyElements.maestroFor`, che gia' governa la rotazione: qui non si
/// sceglie un colore per conto proprio, si chiede a lui. L'oro resta come
/// ripiego se un giorno arrivasse un elemento senza Maestro.
Color _accentFor(Maestro maestro) =>
    MaestroPalette.forKey(ThemeKey.of(maestro)).primary;

/// La riga "Guidato da" del popup informativo. Per il Rito dell'Alba, che
/// ruota, indica il Maestro di turno del giorno; per gli altri il loro Maestro
/// fisso.
String _guideLine(DailyElement element, Maestro maestro) {
  if (element.guide == null) {
    return 'Guidato dal Maestro di turno del giorno, oggi ${maestro.displayName}';
  }
  return 'Guidato da ${maestro.displayName}';
}

/// Apre il popup informativo dell'elemento: cosa e', quale Maestro lo guida e a
/// cosa serve. Breve e chiudibile, non apre l'esperienza.
void _showElementInfo(
  BuildContext context,
  DailyElement element,
  Maestro maestro,
  Color accent,
) {
  showDialog<void>(
    context: context,
    barrierColor: ColorTokens.scrim,
    builder: (context) => Dialog(
      key: Key('daily_info_${element.name}'),
      backgroundColor: ColorTokens.neutralDeep,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: accent.withValues(alpha: 0.55)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            SpacingTokens.lg, SpacingTokens.lg, SpacingTokens.lg, SpacingTokens.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      accent.withValues(alpha: 0.5),
                      ColorTokens.neutralDeepest.withValues(alpha: 0.3),
                    ]),
                    border: Border.all(color: accent.withValues(alpha: 0.9)),
                  ),
                  alignment: Alignment.center,
                  child: _elementIcon(element, color: _gold, size: 18),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Text(
                    element.title,
                    style: TypographyTokens.titoloScheda().copyWith(
                      color: _gold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.sm),
            Row(
              children: [
                Icon(Icons.schedule_rounded,
                    size: 15, color: accent.withValues(alpha: 0.9)),
                const SizedBox(width: 6),
                Text(
                  'Alle ${element.clockLabel}',
                  style: TypographyTokens.etichetta().copyWith(
                    color: ColorTokens.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _guideLine(element, maestro),
              style: TypographyTokens.didascalia().copyWith(
                color: accent.withValues(alpha: 0.95),
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              element.description,
              style: TypographyTokens.didascalia().copyWith(
                color: ColorTokens.textPrimary,
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                key: Key('daily_info_close_${element.name}'),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Ho capito',
                  style: TypographyTokens.etichetta().copyWith(color: _gold),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// La striscia degli appuntamenti quotidiani, fissa in cima al Cerchio: i cinque
/// appuntamenti del giorno come icone, quello della fascia oraria attiva in
/// evidenza con un lieve pulsare, nel colore del suo accento. Gli orari non sono
/// piu' a vista: vivono nel popup che si apre dal cerchio "?" accanto a ogni
/// etichetta. Un tocco sull'icona apre direttamente l'esperienza, senza passare
/// dal dominio.
class DailyStrip extends StatefulWidget {
  /// Quanto del Dono successivo deve restare dentro lo schermo.
  ///
  /// E' un DATO, non un effetto collaterale della larghezza. Un elenco che
  /// scorre lo dichiara mostrando che c'e' dell'altro, e il mezzo oggetto
  /// tagliato dal bordo e' l'invito piu' antico che esista. A 390 punti il
  /// quarto Dono faceva capolino per fortuna, non per scelta; a 360 spariva, e
  /// restavano tre icone con una barretta sottile che nessuno legge come
  /// "scorri".
  static const double sbirciaturaMinima = 26;

  /// Quanto e' larga una casella, RICAVATA dalla sbirciatura invece che fissa.
  ///
  /// Tre Doni interi piu' la sbirciatura del quarto devono stare nella fascia:
  /// da questa condizione esce la larghezza, e non il contrario. La costante di
  /// 116 punti che c'era prima funzionava su uno schermo e falliva sull'altro.
  static double larghezzaCasella(double larghezzaSchermo) {
    final utile = larghezzaSchermo - SpacingTokens.md * 2 - sbirciaturaMinima;
    return (utile / 3).clamp(84.0, 116.0);
  }
  const DailyStrip({
    super.key,
    this.clock,
    this.onOpen,
    this.location = const GeolocatorSkyLocation(),
  });

  /// Orologio iniettabile per i test. Di default l'ora locale del dispositivo.
  final DateTime Function()? clock;

  /// Callback di apertura, iniettabile per i test. Di default apre la route
  /// reale dell'elemento.
  final void Function(BuildContext context, DailyElement element)? onOpen;


  /// La sorgente della posizione per il conto alla rovescia al tramonto, la
  /// stessa astrazione della schermata: cosi' i due numeri non divergono. Di
  /// default spenta nei test, cosi' non chiedono permessi.
  final SkyLocation location;

  @override
  State<DailyStrip> createState() => _DailyStripState();
}

class _DailyStripState extends State<DailyStrip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  final ScrollController _scroll = ScrollController();
  Timer? _tick; // fa scorrere il conto alla rovescia al tramonto
  SkyPlace? _luogo; // la posizione reale, solo se il permesso e' già concesso
  String? _runaApertaIl; // il giorno rituale della runa già vissuta

  // Largo abbastanza da tenere intero il nome piu' lungo, "Tramonto", insieme
  // al cerchio "?", senza mai troncare l'etichetta ne' sforare la riga.
  /// L'altezza della fascia.
  ///
  /// Centoquarantaquattro e non centotrentadue. La casella di un Dono contiene
  /// l'icona da 46, sei di stacco, la riga dell'etichetta col cerchio "?" e lo
  /// slot del conto alla rovescia da 12: con centotrentadue lo spazio che
  /// restava all'elenco era esattamente al limite, e sui rapporti di pixel
  /// alti l'arrotondamento del testo lo superava di dieci punti. Era
  /// l'overflow che rendeva rosse nove prove.
  ///
  /// Nella stima avevo scritto che avrei evitato di alzare la fascia per non
  /// mangiare spazio all'eroe. L'ho cambiata: dodici punti su
  /// settecentonovantasette sono un prezzo piccolo, e le alternative
  /// toccavano l'allineamento delle caselle, che e' piu' fragile.
  /// **CENTOQUARANTOTTO DALL'ORDINE A**, e il commento qui sotto lo aveva
  /// previsto: "se domani l'etichetta cresce, la soglia e' gia' il posto dove
  /// dirlo". L'etichetta e' cresciuta, da undici punti al pavimento di dodici,
  /// e la casella ha cominciato a sbordare di 2,0 pixel in basso, misurati su
  /// tre rapporti di schermo diversi. Quattro punti invece di due perche' il
  /// margine di prima era esattamente zero, ed e' il motivo per cui e' bastato
  /// un punto di carattere per romperlo. Due punti vengono da qui e due dallo
  /// stacco fra icona ed etichetta, perche' prenderli tutti e quattro da qui
  /// avrebbe fatto scendere la carta del Maestro centrale sotto il quaranta per
  /// cento dello schermo che `SantuarioScreen.quotaMinimaCarta` le garantisce:
  /// misurato, 39,9 contro 40,0.
  static const double _heightLarga = 146;
  static const double _heightStretta = 146;

  /// L'altezza della fascia, che SI ADATTA alla larghezza.
  ///
  /// Non e' un numero solo, perche' il contenuto di una casella non cambia
  /// mentre lo spazio per disporlo si'. La casella contiene l'icona da 46, sei
  /// di stacco, la riga dell'etichetta col cerchio "?" e lo slot del conto alla
  /// rovescia da 12: su uno schermo stretto quella riga si dispone piu' alta, e
  /// con un'altezza sola lo spazio restava esattamente al limite. Sui rapporti
  /// di pixel alti l'arrotondamento del testo lo superava di dieci punti, ed
  /// era l'overflow che rendeva rosse nove prove.
  ///
  /// Le due misure oggi coincidono, e la funzione resta perche' il contenuto di
  /// una casella non cambia mentre lo spazio per disporlo si': se domani
  /// l'etichetta cresce, la soglia e' gia' il posto dove dirlo.
  static double altezzaPer(double larghezza) =>
      larghezza < _sogliaStretta ? _heightStretta : _heightLarga;

  /// Sotto questa larghezza la fascia serve piu' alta. Trecentottanta sta fra
  /// i 360 del telefono reale e i 390 del riferimento.
  static const double _sogliaStretta = 380;

  DateTime Function() get _clock => widget.clock ?? DateTime.now;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    // Alla prima comparsa il controller di scorrimento non e' ancora agganciato:
    // un giro dopo il primo frame aggiorna la barra di scorrimento, cosi' mostra
    // subito che ci sono altre icone a destra.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
    _programmaTick();
    // La posizione reale allinea il conto a quello della schermata, ma SOLO se
    // il permesso e' gia' concesso: aprire il Santuario non deve mai far
    // comparire il dialogo del GPS. La richiesta esplicita vive nella Runa,
    // dietro "Attiva la posizione".
    _risolviLuogo();
    // Se la runa di stasera e' gia' stata vissuta, la casella e' accesa e muta.
    _leggiRunaAperta();
  }

  Future<void> _risolviLuogo() async {
    final luogo = await widget.location.resolveSeConcesso();
    if (luogo != null && mounted) setState(() => _luogo = luogo);
  }

  Future<void> _leggiRunaAperta() async {
    final ultima = await SunsetRuneMemory.ultimaPerCerniera();
    if (ultima != null && mounted) {
      setState(() => _runaApertaIl = ultima.giorno);
    }
  }

  // Il conto alla rovescia batte ogni trenta secondi finche' c'e' qualcosa da
  // contare. Passato il tramonto si ferma, e resta un solo risveglio al prossimo
  // cambio di giorno rituale, cosi' a notte fonda la striscia non si ricostruisce
  // per sempre a vuoto.
  void _programmaTick() {
    _tick?.cancel();
    final now = _clock();
    if (_contoTramonto(now) != null) {
      _tick = Timer.periodic(const Duration(seconds: 30), (_) {
        if (!mounted) return;
        setState(() {});
        // Appena il conto finisce, si riprogramma: il periodico si spegne.
        if (_contoTramonto(_clock()) == null) _programmaTick();
      });
      return;
    }
    final risveglio = _prossimoConfineRituale(now);
    _tick = Timer(risveglio.difference(now), () {
      if (!mounted) return;
      setState(() {});
      _programmaTick();
    });
  }

  /// Il prossimo mezzogiorno locale, cioe' il confine del giorno rituale.
  DateTime _prossimoConfineRituale(DateTime now) {
    final mezzogiorno = DateTime(now.year, now.month, now.day, 12);
    return now.isBefore(mezzogiorno)
        ? mezzogiorno
        : mezzogiorno.add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _tick?.cancel();
    _pulse.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _open(DailyElement element) {
    final open = widget.onOpen ?? openDailyElement;
    open(context, element);
  }

  // Il conto alla rovescia al tramonto per la casella della Runa. Il confine di
  // giornata e' UNO SOLO, quello della schermata: `SunsetRune.giornoRituale`, con
  // confine a mezzogiorno. Cosi' fra mezzanotte e mezzogiorno la striscia non
  // annuncia un tramonto di diciassette ore mentre la schermata serve ancora la
  // runa di ieri. Nessuna rete, tutto offline.
  DateTime _tramontoDelGiornoRituale(DateTime now) {
    final offset = now.timeZoneOffset;
    // La posizione reale quando il permesso c'e' gia', altrimenti la stima dal
    // fuso: la stessa fonte della schermata, cosi' i due numeri non divergono.
    final lat = _luogo?.latitude ?? SunsetTime.latDiRipiego;
    final lon = _luogo?.longitude ?? SunsetTime.longitudineDaFuso(offset);
    final giorno = SunsetRune.giornoRituale(now);
    return SunsetTime.perData(giorno, lat: lat, lon: lon, offset: offset) ??
        SunsetTime.oraMedia(giorno);
  }

  /// Vero se la runa del giorno rituale corrente e' gia' stata aperta.
  bool _runaGiaVissuta(DateTime now) =>
      _runaApertaIl != null &&
      _runaApertaIl == SunsetRune.iso(SunsetRune.giornoRituale(now));

  String? _contoTramonto(DateTime now) {
    // Se la runa di stasera e' gia' stata vissuta, nessun conto: e' fatta.
    if (_runaGiaVissuta(now)) return null;
    final minuti = _tramontoDelGiornoRituale(now).difference(now).inMinutes;
    if (minuti <= 0) return null;
    final h = minuti ~/ 60;
    final m = minuti % 60;
    return h > 0 ? 'tra ${h}h ${m}min' : 'tra ${m}min';
  }

  // La casella della Runa e' accesa quando il tramonto del giorno rituale e'
  // passato, oppure quando la runa di stasera e' gia' stata vissuta.
  bool _tramontoArrivato(DateTime now) =>
      _runaGiaVissuta(now) ||
      !now.isBefore(_tramontoDelGiornoRituale(now));

  @override
  Widget build(BuildContext context) {
    final now = _clock();
    final current = DailyElements.current(now);
    return Container(
      key: const Key('santuario_daily_strip'),
      height: altezzaPer(MediaQuery.of(context).size.width),
      decoration: BoxDecoration(
        // Una fascia scura appena accennata con un filo d'oro sotto, cosi' si
        // stacca dal cosmo senza pesare.
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ColorTokens.neutralDeepest.withValues(alpha: 0.0),
            ColorTokens.neutralDeepest.withValues(alpha: 0.45),
          ],
        ),
        border: Border(
          bottom: BorderSide(color: _gold.withValues(alpha: 0.22)),
        ),
      ),
      child: Column(
        children: [
          // Staccata dal margine superiore: un respiro sotto la safe area, mai a
          // ridosso della tacca.
          const SizedBox(height: 8),
          // Riga sottile che annuncia la striscia, centrata.
          Text(
            'I tuoi doni del giorno',
            textAlign: TextAlign.center,
            // Una riga sola. Senza questo vincolo, a 360 punti di larghezza il
            // titolo andava a capo e rubava dieci punti all'elenco sotto, che
            // ha altezza fissa: era l'overflow di dieci pixel della striscia.
            // A 390 ci stava, ed e' il motivo per cui il difetto sembrava non
            // esistere.
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
            style: TypographyTokens.etichetta().copyWith(
              color: ColorTokens.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
              itemCount: DailyElement.values.length,
              itemBuilder: (context, indice) {
                final i = indice;
                final element = DailyElement.values[i];
                // Il Maestro si risolve UNA volta, e da lui nasce il colore:
                // la bolla non sceglie mai una tinta per conto suo.
                final maestro = DailyElements.maestroFor(element, now);
                final accent = _accentFor(maestro);
                final isRuna = element == DailyElement.rune;
                return _StripItem(
                  element: element,
                  active: element == current ||
                      (isRuna && _tramontoArrivato(now)),
                  accent: accent,
                  pulse: _pulse,
                  width: DailyStrip.larghezzaCasella(
                      MediaQuery.of(context).size.width),
                  subtitle: isRuna ? _contoTramonto(now) : null,
                  onTap: () => _open(element),
                  onInfo: () =>
                      _showElementInfo(context, element, maestro, accent),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          // Barra di scorrimento sottile: segnala che le icone continuano oltre
          // quelle visibili, nell'oro del tema.
          _StripScrollbar(controller: _scroll),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

/// Barra di scorrimento discreta sotto le icone: una traccia tenue con un
/// cursore dorato la cui larghezza e posizione riflettono quanto della striscia
/// e' visibile, cosi' si capisce che ci sono altri appuntamenti a destra.
class _StripScrollbar extends StatelessWidget {
  const _StripScrollbar({required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xxl),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) => LayoutBuilder(
            builder: (context, c) {
              final trackW = c.maxWidth;
              double frac = 1;
              double prog = 0;
              if (controller.hasClients &&
                  controller.position.hasContentDimensions) {
                final pos = controller.position;
                final viewport = pos.viewportDimension;
                final max = pos.maxScrollExtent;
                final content = max + viewport;
                if (content > 0) frac = (viewport / content).clamp(0.2, 1.0);
                if (max > 0) prog = (pos.pixels / max).clamp(0.0, 1.0);
              }
              final thumbW = trackW * frac;
              final left = (trackW - thumbW) * prog;
              return Stack(
                children: [
                  // Traccia.
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: _gold.withValues(alpha: 0.12),
                    ),
                  ),
                  // Cursore.
                  Positioned(
                    left: left,
                    child: Container(
                      height: 3,
                      width: thumbW,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: _gold.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StripItem extends StatelessWidget {
  const _StripItem({
    required this.element,
    required this.active,
    required this.accent,
    required this.pulse,
    required this.width,
    required this.onTap,
    required this.onInfo,
    this.subtitle,
  });

  final DailyElement element;
  final bool active;
  final Color accent;
  final Animation<double> pulse;
  final double width;
  final VoidCallback onTap;
  final VoidCallback onInfo;

  /// Riga sotto l'etichetta, oggi usata solo dalla Runa per il conto alla
  /// rovescia al tramonto. Lo spazio e' riservato uguale per tutti, cosi' le
  /// icone restano allineate anche dove la riga e' vuota.
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    // Area di tocco principale: apre direttamente l'esperienza. Il cerchio "?"
    // e' un GestureDetector annidato che vince l'arena solo per i tocchi sul
    // suo cerchio, cosi' le due aree restano separate.
    return GestureDetector(
      key: Key('daily_element_${element.name}'),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            _corpo(),
            // Il bersaglio del controllo di aiuto, quarantaquattro per
            // quarantaquattro, sovrapposto al cerchio "?" senza toccarne il
            // disegno: nel flusso verticale non entrerebbe, perche' la casella e'
            // alta quanto l'icona piu' l'etichetta. Si posa sul cerchio misurando
            // l'etichetta, senza aggiungere testo all'albero.
            Align(
              alignment: Alignment.center,
              child: Transform.translate(
                offset: Offset(_scartoOrizzontaleAiuto, _scartoAiuto),
                child: GestureDetector(
                  key: Key('daily_help_target_${element.name}'),
                  behavior: HitTestBehavior.opaque,
                  onTap: onInfo,
                  child: const SizedBox(width: 44, height: 44),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Lo scarto verticale del bersaglio di aiuto dal centro della casella. Il
  /// cerchio "?" sta circa venti punti sotto il centro; il bersaglio si posa a
  /// ventitre, cosi' la sua fascia alta non copre il centro dell'icona, che deve
  /// restare il tocco che apre il Dono.
  static const double _scartoAiuto = 23;

  /// Lo scarto orizzontale del centro del cerchio "?" dal centro della casella.
  /// La riga e' etichetta piu' cinque piu' diciotto, centrata: il cerchio cade a
  /// destra di meta' etichetta piu' due e mezzo.
  double get _scartoOrizzontaleAiuto {
    final tp = TextPainter(
      text: TextSpan(
        text: element.shortLabel,
        style: TypographyTokens.etichetta().copyWith(letterSpacing: 0.4),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return tp.width / 2 + 2.5;
  }

  Widget _corpo() {
    return SizedBox(
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: pulse,
              builder: (context, child) {
                // L'elemento attivo pulsa leggermente; gli altri fermi.
                final scale = active ? 1.0 + 0.06 * pulse.value : 1.0;
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    accent.withValues(alpha: active ? 0.55 : 0.18),
                    ColorTokens.neutralDeepest.withValues(alpha: 0.3),
                  ]),
                  border: Border.all(
                    color: accent.withValues(alpha: active ? 0.95 : 0.35),
                    width: active ? 1.8 : 1,
                  ),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.45),
                            blurRadius: 16,
                            spreadRadius: -3,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: _elementIcon(
                  element,
                  size: 22,
                  color: active
                      ? _gold
                      : ColorTokens.textSecondary.withValues(alpha: 0.9),
                ),
              ),
            ),
            // Quattro e non sei: i due punti recuperati qui sono meta' di
            // quelli che l'etichetta piu' grande ha chiesto, e vengono da uno
            // stacco che non li usava. L'altra meta' viene dall'altezza della
            // fascia. Prenderli tutti dalla fascia avrebbe tolto alla carta del
            // Maestro centrale lo spazio che una prova le garantisce.
            const SizedBox(height: 4),
            // Etichetta e, a fianco, il cerchio "?" che apre la spiegazione.
            //
            // Dentro un FittedBox: la riga e' etichetta piu' cinque piu'
            // diciotto, e su alcune larghezze quella somma supera la casella. Il
            // Row sbordava di lato invece di stringersi, perche' ha
            // mainAxisSize.min e nessuno gli diceva di rimpicciolirsi. Adesso si
            // riduce invece di uscire.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nome per intero, mai troncato: lo spazio dell'elemento e' gia'
                // dimensionato per "Tramonto" con il cerchio "?" a fianco.
                Text(
                  element.shortLabel,
                  maxLines: 1,
                  softWrap: false,
                  style: TypographyTokens.etichetta().copyWith(
                    color: active ? _gold : ColorTokens.textSecondary,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(width: 5),
                // Solo disegno: il tocco lo raccoglie il bersaglio sovrapposto,
                // largo quarantaquattro, cosi' il dito non deve centrare 18 punti.
                Container(
                  key: Key('daily_help_button_${element.name}'),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorTokens.neutralDeepest.withValues(alpha: 0.7),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.6),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '?',
                    style: TypographyTokens.etichetta().copyWith(
                      color: accent.withValues(alpha: 0.95),
                      letterSpacing: 0,
                    ),
                  ),
                ),
                ],
              ),
            ),
            // Slot del conto alla rovescia, altezza fissa per tutti.
            SizedBox(
              height: 12,
              child: subtitle == null
                  ? null
                  : Text(
                      subtitle!,
                      key: Key('daily_conto_${element.name}'),
                      maxLines: 1,
                      softWrap: false,
                      style: TypographyTokens.etichetta().copyWith(
                        color: accent.withValues(alpha: 0.95),
                        letterSpacing: 0.2,
                      ),
                    ),
            ),
          ],
        ));
  }
}
