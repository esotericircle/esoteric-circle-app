import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/astro/celestial.dart';
import '../../core/maestro/consulto_del_cielo.dart';
import '../../core/maestro/corpo_del_consulto.dart';
import '../../core/maestro/maestro.dart';
import '../../core/maestro/natal_context.dart';
import '../../core/maestro/tempi_dell_attesa.dart';
import '../../core/quality/quality_tier.dart';
import '../theme/maestro_scope.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'moon_phase_emblem.dart';
import 'zodiac_glyph.dart';

/// L'attesa e' il Maestro che consulta il tuo cielo, E IL CIELO SI VEDE.
///
/// Vive nel design system e non dentro la chat perche' le superfici che
/// aspettano una risposta sono DUE, la chat e il Consulta.
///
/// **Il corpo si disegna davvero.** La prima stesura di questa scena mostrava
/// due righe di testo e nient'altro: nessun corpo, nessuna luce. Le dieci prove
/// che la coprivano contavano widget e testo, quindi nessuna poteva
/// accorgersene, ed e' esattamente il modo in cui una scena vuota passa per
/// fatta. Adesso c'e' l'arte vera gia' a bundle, la stessa che l'Oroscopo e il
/// Rito del Sogno mostrano, e una prova conta i PIXEL dipinti.
///
/// Con Riduci Movimento o Quality Tier basso l'emblema C'E' ed e' fermo: si
/// spegne il moto, non l'immagine.
class ConsultoDelCieloView extends StatefulWidget {
  const ConsultoDelCieloView({
    super.key,
    required this.natal,
    this.maestro,
    this.rotazione = 0,
    this.durataBattuta = TempiDellAttesa.durataBattuta,
  });

  /// I dati di questa persona. Se e' vuoto la scena consulta il solo Sole e lo
  /// dichiara, invece di inventare un segno.
  final NatalContext natal;

  /// Chi sta consultando. Con lui le battute portano la sua LENTE: Medora
  /// guarda il moto, Aura l'effetto, Caligo il simbolo. Nullo fuori da una
  /// conversazione, e allora la frase resta neutra.
  final Maestro? maestro;

  /// Quale giro di frasi. Cresce a ogni domanda, cosi' due attese vicine non
  /// fanno rileggere la stessa riga del Maestro.
  final int rotazione;

  /// Quanto resta a schermo ogni battuta. Il valore vive in [TempiDellAttesa],
  /// insieme agli altri tempi dell'attesa: qui c'e' solo il modo di scavalcarlo
  /// in una prova.
  final Duration durataBattuta;

  /// Quanto e' grande il corpo disegnato. Dichiarata perche' la prova a pixel
  /// tara la sua soglia su questo numero.
  static const double misuraDelCorpo = 96;

  @override
  State<ConsultoDelCieloView> createState() => _ConsultoDelCieloViewState();
}

class _ConsultoDelCieloViewState extends State<ConsultoDelCieloView> {
  late final List<BattutaDelConsulto> _battute = ConsultoDelCielo.battutePer(
    widget.natal,
    maestro: widget.maestro,
    rotazione: widget.rotazione,
  );
  int _corrente = 0;
  Timer? _passo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _avvia());
  }

  void _avvia() {
    if (!mounted || _battute.length <= 1) return;
    if (MediaQuery.of(context).disableAnimations) return;
    _passo = Timer.periodic(widget.durataBattuta, (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_corrente >= _battute.length - 1) {
        t.cancel();
        return;
      }
      setState(() => _corrente++);
    });
  }

  @override
  void dispose() {
    _passo?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final riduciMovimento = MediaQuery.of(context).disableAnimations;
    final qualita = context.watch<QualityTierController>().tier;
    final fermo = riduciMovimento || qualita == QualityTier.low;

    // Fermi, si mostra la PRIMA battuta e basta: e' la piu' personale, ed e'
    // l'informazione. Il movimento e' cio' che si toglie, non il contenuto.
    final battuta = _battute[fermo ? 0 : _corrente];

    final scena = Column(
      key: const Key('consulto_del_cielo'),
      mainAxisSize: MainAxisSize.min,
      children: [
        CorpoDelConsultoDipinto(
          battuta: battuta,
          fermo: fermo,
          misura: ConsultoDelCieloView.misuraDelCorpo,
        ),
        const SizedBox(height: SpacingTokens.sm),
        Text(
          'Sto consultando',
          style: TypographyTokens.body(size: 13)
              .copyWith(color: palette.goldSoft),
        ),
        const SizedBox(height: SpacingTokens.xxs),
        Text(
          battuta.frase,
          key: ValueKey('consulto_${battuta.corpo}'),
          textAlign: TextAlign.center,
          style: TypographyTokens.display(size: 18)
              .copyWith(color: palette.textPrimary),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.lg,
        vertical: SpacingTokens.md,
      ),
      child: fermo
          ? scena
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              // LA CHIAVE E' L'INDICE, non il corpo.
              //
              // Era `ValueKey(battuta.corpo)`, e reggeva finche' ogni riga
              // guardava un corpo diverso. Adesso le frasi del Maestro
              // EREDITANO il corpo della riga ancorata, apposta, perche' la
              // Luna vera di questa persona resti illuminata mentre la riga
              // cambia: con la vecchia chiave due righe di fila avrebbero
              // avuto la stessa chiave e la seconda sarebbe comparsa di
              // scatto, cioe' la scena avrebbe perso proprio il movimento per
              // cui esiste.
              child: KeyedSubtree(
                key: ValueKey(_corrente),
                child: scena,
              ),
            ),
    );
  }
}

/// Il corpo, dipinto con l'arte vera che esiste gia' a bundle.
///
/// PUBBLICO e separato dalla scena apposta: la prova a pixel lo monta da solo,
/// senza timer ne' provider. Una misura che deve montare mezza applicazione
/// smette di essere eseguita, e una regola dentro una classe privata non si
/// puo' nemmeno nominare.
class CorpoDelConsultoDipinto extends StatelessWidget {
  const CorpoDelConsultoDipinto({
    super.key,
    required this.battuta,
    required this.misura,
    this.fermo = false,
  });

  final BattutaDelConsulto battuta;
  final double misura;
  final bool fermo;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final ancoraggio = battuta.ancoraggio;
    final corpo = ancoraggio == null
        ? const CorpoPunto()
        : CorpoDelConsulto.per(ancoraggio);

    switch (corpo) {
      case CorpoSegno(:final segno):
        // L'emblema 3D del segno, lo stesso che l'Oroscopo mostra in testa.
        return ZodiacEmblem(
          key: const Key('consulto_corpo'),
          sign: segno,
          size: misura,
        );
      case CorpoLuna():
        // Il disco lunare col terminatore vero, dal Rito del Sogno. La frazione
        // esatta della nascita non e' fra i dati che arrivano qui: si mostra il
        // disco a mezza luce senza asserire una frazione che non abbiamo.
        return MoonPhaseEmblem(
          key: const Key('consulto_corpo'),
          phase: const MoonIllumination(
            fraction: 0.5,
            waxing: true,
            elongationDeg: 90,
          ),
          size: misura,
          animate: !fermo,
        );
      case CorpoPunto():
        // Il trattamento che il cielo gia' da' ai corpi senza figura: un punto
        // luminoso. Mai il vuoto, mai arte inventata.
        return SizedBox(
          key: const Key('consulto_corpo'),
          width: misura,
          height: misura,
          child: Center(
            child: Container(
              width: misura * 0.28,
              height: misura * 0.28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.goldSoft,
                boxShadow: [
                  BoxShadow(
                    color: palette.gold.withValues(alpha: 0.55),
                    blurRadius: misura * 0.35,
                    spreadRadius: misura * 0.06,
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}
