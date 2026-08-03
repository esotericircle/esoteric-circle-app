import 'dart:async';

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  /// IL PAVIMENTO DEL CORPO, sotto il quale non si stringe.
  ///
  /// A 72 punti l'emblema di un segno e' ancora riconoscibile e la falce della
  /// Luna si legge ancora come falce. Piu' sotto diventa una macchia, e una
  /// macchia non dice niente a nessuno: meglio togliere il disegno e lasciare
  /// la riga di testo, che almeno si legge.
  static const double pavimentoDelCorpo = 72;

  /// IL TETTO DEL CORPO. Oltre, su uno schermo alto, l'emblema smetterebbe di
  /// stare in una scena e diventerebbe la schermata.
  static const double tettoDelCorpo = 220;

  /// Gli stacchi fra le tre righe della colonna, piu' il rientro verticale
  /// della scena: 12 e 4 fra le righe, 16 sopra e 16 sotto.
  static const double stacchiERientri = 12 + 4 + 16 + 16;

  /// QUANTO CHIEDE TUTTO CIO' CHE NON E' IL DISEGNO, MISURATO SULLA FRASE VERA.
  ///
  /// **Perche' non e' una costante.** Lo era, e valeva 130, calcolata sul caso
  /// peggiore del corpus a 360 punti di larghezza. Nella chat vera la colonna
  /// sforava lo stesso di 28 pixel: un numero peggiore-caso e' fragile per
  /// costruzione, perche' basta una frase nuova, una lingua nuova o una
  /// larghezza diversa e smette di essere il peggiore senza che nessuno lo
  /// dica. Qui si impagina il testo che si sta per mostrare, con lo stile con
  /// cui si mostrera', e si legge quanto e' alto.
  ///
  /// La taratura, per capirsi sugli ordini di grandezza: a 360 punti la riga
  /// "Sto consultando" misura 19,0, le frasi sulla fase lunare stanno in due
  /// righe da 42,0, quelle sull'Ascendente in tre da 63,0, e gli stacchi con i
  /// rientri fanno 48,0.
  static double riservaPer(String frase, double larghezza) {
    final utile = math.max(0.0, larghezza - SpacingTokens.lg * 2);
    double altezza(TextStyle stile, String testo) => (TextPainter(
          text: TextSpan(text: testo, style: stile),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        )..layout(maxWidth: utile))
        .height;
    return altezza(TypographyTokens.body(size: 13), 'Sto consultando') +
        altezza(TypographyTokens.display(size: 18), frase) +
        stacchiERientri;
  }

  /// Sotto questa altezza libera non resta abbastanza nemmeno per il pavimento
  /// piu' il testo: la scena degrada alla sola riga, invece di schiacciare il
  /// disegno.
  static double liberoMinimoPer(String frase, double larghezza) =>
      pavimentoDelCorpo + riservaPer(frase, larghezza);

  /// Quanto e' grande il corpo dato lo spazio libero.
  ///
  /// **Non e' un numero fisso, ed e' il punto.** Prima valeva 96 sempre, cioe'
  /// circa un quarto della larghezza dello schermo, dentro una fascia vuota
  /// alta centinaia di punti. Adesso il lato cresce con cio' che avanza e si
  /// ferma al tetto, oppure scende fino al pavimento quando la conversazione
  /// si e' presa quasi tutto.
  static double corpoPer(double altezzaLibera, double riserva) {
    final perIlDisegno = altezzaLibera - riserva;
    return perIlDisegno.clamp(pavimentoDelCorpo, tettoDelCorpo);
  }

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

    // QUANTO SPAZIO C'E' DAVVERO, chiesto ai vincoli e non deciso qui.
    //
    // Quando la scena vive dentro `ScenaSopraLaConversazione` questi vincoli
    // sono cio' che la conversazione ha lasciato libero. Quando invece sta al
    // centro di una schermata vuota sono l'altezza di quella schermata. In
    // tutti e due i casi la domanda e' la stessa: quanto avanza?
    final libero = MediaQuery.maybeOf(context)?.size.height ?? 0;

    Widget scenaCon(double altezzaLibera, double larghezza) {
      final disponibile =
          altezzaLibera.isFinite && altezzaLibera > 0 ? altezzaLibera : libero;
      final riserva = ConsultoDelCieloView.riservaPer(battuta.frase, larghezza);
      // SOTTO IL MINIMO SI TOGLIE IL DISEGNO, non lo si schiaccia.
      //
      // Un emblema compresso sotto il pavimento non e' un emblema piu'
      // piccolo, e' una macchia che non si riconosce, e una macchia sopra la
      // frase peggiora la frase invece di aggiungerle qualcosa.
      final ciSta =
          disponibile >= ConsultoDelCieloView.pavimentoDelCorpo + riserva;
      final misura = ConsultoDelCieloView.corpoPer(disponibile, riserva);

      // TRE GRADINI, E IL TERZO E' IL VUOTO.
      //
      // **Il numero che ha fatto nascere questo gradino.** Con la
      // conversazione piena lo spazio libero misurato nella chat vera scende a
      // 48,3 punti, e la riserva del testo ne chiede 109: la scena degradata
      // alla sola riga sforava lo stesso, di 28 pixel. Quando non c'e' posto
      // nemmeno per una riga, la risposta non e' una riga schiacciata: e'
      // niente. La bolla in attesa sotto dice gia' che il Maestro sta
      // rispondendo.
      if (disponibile < riserva) return const SizedBox.shrink();

      return Column(
        key: const Key('consulto_del_cielo'),
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ciSta) ...[
            CorpoDelConsultoDipinto(
              battuta: battuta,
              fermo: fermo,
              misura: misura,
            ),
            const SizedBox(height: SpacingTokens.sm),
          ],
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
    }

    return LayoutBuilder(builder: (context, vincoli) {
      final scena = scenaCon(vincoli.maxHeight, vincoli.maxWidth);
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg,
          vertical: SpacingTokens.md,
        ),
        child: fermo
            ? scena
            : AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              // UNA RIGA ALLA VOLTA, e non due sovrapposte.
              //
              // Di suo `AnimatedSwitcher` impila il figlio che entra su quello
              // che esce, e per tutta la transizione a schermo ci sono DUE
              // battute una sopra l'altra: nell'anteprima del 3 agosto 2026 si
              // leggeva "Sto consultando" due volte e le due frasi
              // accavallate, illeggibili. Nessuna prova poteva prenderlo,
              // perche' contare i widget dava il numero giusto: si vede solo
              // guardando l'immagine. Tenendo in layout il solo figlio
              // corrente, quello che esce sparisce invece di restare sotto.
              layoutBuilder: (corrente, precedenti) =>
                  corrente ?? const SizedBox.shrink(),
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
    });
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
        : CorpoDelConsulto.per(ancoraggio, luna: battuta.luna);

    switch (corpo) {
      case CorpoSegno(:final segno):
        // L'emblema 3D del segno, lo stesso che l'Oroscopo mostra in testa.
        return ZodiacEmblem(
          key: const Key('consulto_corpo'),
          sign: segno,
          size: misura,
        );
      case CorpoLuna(:final luce):
        // LA FORMA E LA PAROLA DALLO STESSO NUMERO.
        //
        // Qui c'era `fraction: 0.5` scritto a mano, con accanto un commento
        // che ammetteva di non avere il dato vero: il disco usciva una meta'
        // esatta, cioe' un primo quarto, mentre sotto si leggeva "La Luna
        // crescente sotto cui sei nato". Adesso la frazione arriva con la
        // battuta, ed e' la stessa da cui `NatalContext.moonPhase` ricava il
        // nome. Senza quella misura non si disegna nessuna Luna: si cade sul
        // punto luminoso, gia' dentro `CorpoDelConsulto.per`.
        return MoonPhaseEmblem(
          key: const Key('consulto_corpo'),
          phase: luce,
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
