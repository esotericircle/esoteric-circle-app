import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/entitlement/question_allowance.dart';
import '../../core/sigilli/bonus_della_condivisione.dart';
import '../../core/sigilli/diario_del_cammino.dart';
import '../../core/sigilli/sentieri.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../core/condivisione/porta_della_condivisione.dart';
import '../../core/entitlement/registro_degli_eos.dart';
import '../../services/app_services.dart';
import 'card_del_traguardo.dart';
import 'sentiero_screen.dart';
import '../../design_system/components/icona_degli_eos.dart';

/// LA CELEBRAZIONE DI UN TRAGUARDO, nelle sue due forme.
///
/// **Ogni traguardo viene celebrato, senza eccezioni, e ogni celebrazione
/// offre la condivisione.** Cambia la forma, non il fatto: a schermo pieno
/// per il primo traguardo in assoluto e per i cinque grandi, in
/// sovrimpressione per i mini. Cinquanta interruzioni a schermo pieno per
/// sentiero trasformerebbero la magia in fastidio, e un mini che passa senza
/// una parola non sarebbe un traguardo.
class Celebrazione {
  const Celebrazione._();

  /// Celebra cio' che si e' appena acceso, nella forma giusta.
  ///
  /// [primoInAssoluto] e' vero quando questo e' il primissimo Sigillo della
  /// persona: quello va a schermo pieno anche se e' un mini, perche' il primo
  /// premio deve sembrare grande.
  ///
  /// **Torna VERO solo se la festa e' davvero comparsa a schermo**, ordine P
  /// voce 34. Quando non c'e' dove ospitarla, chi ha chiamato la mette in coda
  /// invece di perderla: prima questa funzione usciva in silenzio e nessuno
  /// poteva accorgersene.
  /// [attendiLaFine] serve solo a chi celebra IN FILA, cioe' allo svuotamento
  /// della coda: due scene a schermo pieno spinte insieme si accavallerebbero.
  /// Nel ciclo normale resta falso, e non e' un dettaglio: la forma grande e'
  /// una rotta, e attenderla vuol dire fermare tutto finche' la persona non
  /// chiude la festa. E' cosi' che l'accredito del premio restava ostaggio
  /// della celebrazione, cioe' lo stesso difetto della voce 34 al contrario.
  /// [allaChiusura] si chiama quando la festa LASCIA LO SCHERMO, ed e' il
  /// momento in cui gli Eos volano nel borsellino, ordine S voce 07. Prima non
  /// c'era nessun momento del genere: chi festeggia sapeva solo che la scena era
  /// partita, e il volo lanciato subito avrebbe attraversato una celebrazione a
  /// schermo pieno per arrivare a un borsellino che in quel momento e' coperto.
  static Future<bool> festeggia(
    BuildContext context, {
    required Traguardo traguardo,
    required Sentiero sentiero,
    required bool primoInAssoluto,
    String? serie,
    bool attendiLaFine = false,
    VoidCallback? allaChiusura,
  }) async {
    if (traguardo.eGrande || primoInAssoluto) {
      final navigatore = Navigator.maybeOf(context);
      if (navigatore == null) return false;
      final scena = navigatore.push(_RottaDellaCelebrazione(
        traguardo: traguardo,
        sentiero: sentiero,
        serie: serie,
      ));
      // IL GANCIO VA SULLA ROTTA, non sull'attesa di chi chiama: la forma grande
      // resta aperta finche' la persona non la chiude, e chi ha chiamato non deve
      // aspettarla.
      if (allaChiusura != null) scena.whenComplete(allaChiusura);
      if (attendiLaFine) {
        await scena;
      } else {
        unawaited(scena);
      }
      return true;
    }
    return mostraLaSovrimpressione(context,
        traguardo: traguardo,
        sentiero: sentiero,
        serie: serie,
        allaChiusura: allaChiusura);
  }
}

/// LA FORMA GRANDE: la scena prende tutto, il Maestro parla, il segno si
/// compie. Non finisce mai col punto: in fondo c'e' il prossimo traguardo.
class _RottaDellaCelebrazione extends PageRouteBuilder<void> {
  _RottaDellaCelebrazione({
    required this.traguardo,
    required this.sentiero,
    this.serie,
  }) : super(
          opaque: false,
          barrierColor: const Color(0xCC05060A),
          // LA FESTA SI PORTA IL SUO SCOPE, e non e' un ripiego: e' la
          // correzione di un difetto vero.
          //
          // **Una rotta non e' figlia della schermata da cui parte.** Il
          // `MaestroScope` vive DENTRO la pagina, mentre una rotta spinta e' una
          // sorella: la festa cercava il colore piu' in alto, non lo trovava e
          // faceva esplodere un assert dentro il rito che stava festeggiando.
          // Lo ha trovato la prova del Cosmic Passport, che apriva la schermata,
          // accendeva un Sigillo e cadeva sulla festa.
          //
          // E il colore giusto e' quello del SENTIERO, non quello della
          // schermata da cui si arriva: un Frutto dell'Albero si festeggia in
          // rosso di Caligo anche se lo hai acceso dentro una stesa di Medora.
          // Prima, quando per caso lo scope c'era, la festa prendeva il colore
          // sbagliato senza che nessuno se ne accorgesse.
          pageBuilder: (context, _, __) => MaestroScope(
            maestro: sentiero.maestro,
            child: CelebrazioneAScermoPieno(
              traguardo: traguardo,
              sentiero: sentiero,
              serie: serie,
            ),
          ),
        );

  final Traguardo traguardo;
  final Sentiero sentiero;
  final String? serie;
}

class CelebrazioneAScermoPieno extends StatefulWidget {
  const CelebrazioneAScermoPieno({
    super.key,
    required this.traguardo,
    required this.sentiero,
    this.serie,
  });

  final Traguardo traguardo;
  final Sentiero sentiero;

  /// "terzo giorno di seguito", quando c'e' una serie da dire.
  final String? serie;

  @override
  State<CelebrazioneAScermoPieno> createState() =>
      _CelebrazioneAScermoPienoState();
}

class _CelebrazioneAScermoPienoState extends State<CelebrazioneAScermoPieno>
    with SingleTickerProviderStateMixin {
  late final AnimationController _segno = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  bool _partito = false;

  /// IL MOVIMENTO SI DECIDE IN didChangeDependencies, non in initState: la
  /// MediaQuery non si puo' leggere prima che initState sia finito, e leggerla
  /// li' faceva cadere l'intera scena. Lo ha trovato la prova, al primo giro.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_partito) return;
    _partito = true;
    if (MediaQuery.of(context).disableAnimations) {
      _segno.value = 1;
    } else {
      _segno.forward();
    }
  }

  @override
  void dispose() {
    _segno.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final diario = context.watch<DiarioDelCammino>();
    final prossimo = diario.prossimoDi(widget.sentiero);

    return CosmosBackground(
      seed: 23,
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          // LA SCENA SCORRE SE LO SCHERMO E' BASSO, invece di traboccare: su
          // un telefono piccolo, o con la scrittura ingrandita, la festa non
          // deve diventare una riga gialla di errore. La prova lo ha trovato
          // al primo montaggio, su uno schermo da 600 punti.
          child: LayoutBuilder(
            builder: (context, vincoli) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: vincoli.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: SpacingTokens.xxl),
                    SegnoDelMaestro(
                      sentiero: widget.sentiero,
                      avanzamento: _segno,
                      grande: true,
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    Text(
                      widget.traguardo.nome,
                      key: const Key('celebrazione_nome'),
                      textAlign: TextAlign.center,
                      style: TypographyTokens.cerimonialeGrande()
                          .copyWith(color: palette.goldSoft),
                    ),
                    if (widget.serie != null) ...[
                      const SizedBox(height: SpacingTokens.xs),
                      Text(widget.serie!,
                          key: const Key('celebrazione_serie'),
                          style: TypographyTokens.etichetta()
                              .copyWith(color: palette.goldSoft)),
                    ],
                    const SizedBox(height: SpacingTokens.md),
                    Text(
                      widget.traguardo.frase,
                      key: const Key('celebrazione_frase'),
                      textAlign: TextAlign.center,
                      style: TypographyTokens.corpo().copyWith(
                          color: ColorTokens.textPrimary, height: 1.5),
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    EosCheVolano(
                        quanti: widget.traguardo.eos, avanzamento: _segno),
                    const SizedBox(height: SpacingTokens.lg),
                    VieDellaCondivisione(
                      suScelta: (modo) => condividiIlTraguardo(
                        context,
                        traguardo: widget.traguardo,
                        modo: modo,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.xl),
                    // NON SI CHIUDE MAI COL PUNTO: il prossimo traguardo e'
                    // sempre li', e sempre uno vicino. Un premio che finisce con
                    // un tasto Chiudi spegne il ciclo.
                    if (prossimo != null)
                      Container(
                        key: const Key('celebrazione_prossimo'),
                        padding: const EdgeInsets.all(SpacingTokens.md),
                        decoration: BoxDecoration(
                          color: palette.surfaceElevated.withValues(alpha: 0.7),
                          borderRadius:
                              BorderRadius.circular(SpacingTokens.radiusLg),
                          border: Border.all(
                              color: palette.gold.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            Text('Il prossimo',
                                style: TypographyTokens.etichetta()
                                    .copyWith(color: palette.goldSoft)),
                            const SizedBox(height: 4),
                            Text(prossimo.nome,
                                textAlign: TextAlign.center,
                                style: TypographyTokens.titoloScheda()
                                    .copyWith(color: ColorTokens.textPrimary)),
                          ],
                        ),
                      ),
                    const SizedBox(height: SpacingTokens.sm),
                    // IL SALTO DIRETTO AL PUNTO DEL JOURNAL, ordine P voce 20.
                    //
                    // La festa mostrava il Sigillo acceso e poi si chiudeva su
                    // se stessa: chi voleva vederlo al suo posto doveva
                    // ritrovare il sentiero da solo. Il sentiero scende gia' da
                    // solo sul punto raggiunto, voce 36, quindi qui basta
                    // aprirlo: la discesa fa il resto.
                    TextButton.icon(
                      key: const Key('celebrazione_vai_al_sigillo'),
                      onPressed: () {
                        final navigatore = Navigator.of(context);
                        navigatore.maybePop();
                        navigatore.push(SentieroScreen.route(widget.sentiero));
                      },
                      icon: Icon(Icons.route_rounded,
                          size: 16, color: palette.goldSoft),
                      label: Text('Vedi il Sigillo sul sentiero',
                          style: TypographyTokens.didascalia()
                              .copyWith(color: palette.goldSoft)),
                    ),
                    TextButton(
                      key: const Key('celebrazione_continua'),
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: Text('Continua il cammino',
                          style: TypographyTokens.etichetta()
                              .copyWith(color: ColorTokens.textSecondary)),
                    ),
                    const SizedBox(height: SpacingTokens.md),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// IL SEGNO DEL MAESTRO: il frutto che matura, la stella che si accende, il
/// petalo che si apre. Mai uno scrigno, in nessuna delle due forme.
class SegnoDelMaestro extends StatelessWidget {
  const SegnoDelMaestro({
    super.key,
    required this.sentiero,
    required this.avanzamento,
    this.grande = false,
  });

  final Sentiero sentiero;
  final Animation<double> avanzamento;
  final bool grande;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final misura = grande ? 96.0 : 32.0;
    final icona = switch (sentiero) {
      Sentiero.costellazione => Icons.star_rounded,
      Sentiero.albero => Icons.spa_rounded,
      Sentiero.loto => Icons.local_florist_rounded,
    };
    return AnimatedBuilder(
      key: const Key('segno_del_maestro'),
      animation: avanzamento,
      builder: (context, _) {
        final t = Curves.easeOutBack.transform(avanzamento.value.clamp(0, 1));
        return Opacity(
          opacity: avanzamento.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.6 + 0.4 * t,
            child: Icon(icona, size: misura, color: palette.goldSoft),
          ),
        );
      },
    );
  }
}

/// GLI EOS CHE VOLANO NEL BORSELLINO, e il saldo che scatta a vista.
class EosCheVolano extends StatelessWidget {
  const EosCheVolano({
    super.key,
    required this.quanti,
    required this.avanzamento,
  });

  final int quanti;
  final Animation<double> avanzamento;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AnimatedBuilder(
      key: const Key('eos_che_volano'),
      animation: avanzamento,
      builder: (context, _) {
        final visti = (quanti * avanzamento.value).round();
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconaDegliEos(misura: 18, colore: palette.goldSoft),
            const SizedBox(width: 6),
            Text('+$visti Eos',
                key: const Key('eos_contati'),
                style: TypographyTokens.titoloScheda()
                    .copyWith(color: palette.goldSoft)),
          ],
        );
      },
    );
  }
}

/// LA FORMA BREVE DEI MINI: **a tutto schermo**, ordine P voci 20 e 34.
///
/// **Cosa e' cambiato.** Era una fascia stretta in cima allo schermo, e una
/// fascia non e' una celebrazione: cinquanta traguardi festeggiati con una
/// striscia in un angolo sono cinquanta traguardi che passano inosservati.
/// Adesso la scena prende tutto lo schermo, il simbolo del sentiero si accende
/// con un movimento, il nome entra e gli Eos salgono contando.
///
/// **E continua a non bloccare mai.** Il livello visivo e' dentro un
/// `IgnorePointer`: i tocchi passano alla schermata di sotto, che resta
/// utilizzabile. L'unica cosa toccabile e' la condivisione. La scena si ritira
/// da sola, e chi la ignora non perde niente, perche' il Sigillo e' gia'
/// acceso nel journal e da li' si riapre e si condivide anche settimane dopo.
///
/// Torna vero se la scena e' davvero comparsa.
bool mostraLaSovrimpressione(
  BuildContext context, {
  required Traguardo traguardo,
  required Sentiero sentiero,
  String? serie,
  VoidCallback? allaChiusura,
}) {
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return false;
  late final OverlayEntry fascia;
  fascia = OverlayEntry(
    // ANCHE LA FASCIA SI PORTA IL SUO SCOPE, per la stessa ragione della forma
    // grande: una voce dell'Overlay non e' figlia della pagina che l'ha chiesta,
    // e il colore giusto e' quello del sentiero che si sta festeggiando.
    builder: (ctx) => MaestroScope(
      maestro: sentiero.maestro,
      child: _FasciaDellaCelebrazione(
        traguardo: traguardo,
        sentiero: sentiero,
        serie: serie,
        suFine: () {
          if (fascia.mounted) fascia.remove();
          // LA FASCIA SE NE VA DA SE' dopo qualche secondo: quello e' il suo
          // momento di chiusura, ed e' li' che gli Eos volano.
          allaChiusura?.call();
        },
      ),
    ),
  );
  overlay.insert(fascia);
  return true;
}

class _FasciaDellaCelebrazione extends StatefulWidget {
  const _FasciaDellaCelebrazione({
    required this.traguardo,
    required this.sentiero,
    required this.suFine,
    this.serie,
  });

  final Traguardo traguardo;
  final Sentiero sentiero;
  final String? serie;
  final VoidCallback suFine;

  @override
  State<_FasciaDellaCelebrazione> createState() =>
      _FasciaDellaCelebrazioneState();
}

class _FasciaDellaCelebrazioneState extends State<_FasciaDellaCelebrazione>
    with SingleTickerProviderStateMixin {
  late final AnimationController _segno = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  Timer? _ritiro;

  /// Quanto resta a schermo prima di ritirarsi da sola.
  static const Duration quantoResta = Duration(seconds: 6);

  @override
  void initState() {
    super.initState();
    _ritiro = Timer(quantoResta, widget.suFine);
  }

  /// **CON RIDUCI MOVIMENTO LA SCENA DIVENTA STATICA E NON SPARISCE**: il
  /// simbolo si vede acceso, il nome si legge, gli Eos ci sono e la
  /// condivisione pure. Si toglie il movimento, non il contenuto. La
  /// MediaQuery non si legge in initState, per questo il movimento si decide
  /// qui: lo stesso passo falso era gia' costato la scena grande.
  bool _partito = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_partito) return;
    _partito = true;
    if (MediaQuery.of(context).disableAnimations) {
      _segno.value = 1;
    } else {
      _segno.forward();
    }
  }

  @override
  void dispose() {
    _ritiro?.cancel();
    _segno.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // A TUTTO SCHERMO, ma senza intercettare i tocchi: la scena prende tutta
    // la tela, il livello visivo sta dentro un IgnorePointer e la schermata di
    // sotto resta utilizzabile. E' il modo di tenere insieme le due cose che
    // l'ordine chiede allo stesso momento, "sempre a tutto schermo" e "non
    // blocca mai".
    return Positioned.fill(
      child: Material(
        key: const Key('sovrimpressione_del_traguardo'),
        type: MaterialType.transparency,
        child: Stack(
          children: [
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 0.9,
                    colors: [
                      palette.surfaceElevated.withValues(alpha: 0.62),
                      palette.deepest.withValues(alpha: 0.30),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: SpacingTokens.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SegnoDelMaestro(
                              sentiero: widget.sentiero,
                              avanzamento: _segno,
                              grande: true),
                          const SizedBox(height: SpacingTokens.md),
                          Text(widget.traguardo.nome,
                              key: const Key('sovrimpressione_nome'),
                              textAlign: TextAlign.center,
                              style: TypographyTokens.cerimoniale()
                                  .copyWith(color: palette.goldSoft)),
                          const SizedBox(height: SpacingTokens.xs),
                          Text(
                            widget.serie ?? '+${widget.traguardo.eos} Eos',
                            key: const Key('sovrimpressione_eos'),
                            textAlign: TextAlign.center,
                            style: TypographyTokens.titoloScheda()
                                .copyWith(color: ColorTokens.textPrimary),
                          ),
                          const SizedBox(height: SpacingTokens.sm),
                          EosCheVolano(
                              quanti: widget.traguardo.eos,
                              avanzamento: _segno),
                          // Lo spazio che la fascia toccabile occupera' sotto:
                          // il testo non le finisce mai dietro.
                          const SizedBox(height: SpacingTokens.xxl),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // L'UNICA COSA TOCCABILE: la condivisione, che porta alla stessa
            // card e allo stesso bonus della forma grande.
            Positioned(
              left: 0,
              right: 0,
              bottom: SpacingTokens.xl,
              child: Center(
                child: VieDellaCondivisione(
                  compatte: true,
                  suScelta: (modo) => condividiIlTraguardo(
                    context,
                    traguardo: widget.traguardo,
                    modo: modo,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// RIAPRE LA CARD di un Sigillo gia' acceso, dal journal, anche settimane
/// dopo: il bonus in sospeso si incassa da qui.
Future<void> mostraLaCardDelTraguardo(
  BuildContext context, {
  required Traguardo traguardo,
  required Sentiero sentiero,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (foglio) => Padding(
      padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.lg,
          SpacingTokens.lg, SpacingTokens.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CardDelTraguardo(traguardo: traguardo, sentiero: sentiero),
          const SizedBox(height: SpacingTokens.md),
          VieDellaCondivisione(
            suScelta: (modo) {
              Navigator.of(foglio).pop();
              condividiIlTraguardo(context, traguardo: traguardo, modo: modo);
            },
          ),
        ],
      ),
    ),
  );
}

/// CONDIVIDE UN TRAGUARDO e incassa il bonus graduato, che e' uno solo.
///
/// **QUI I TRE PULSANTI NON FACEVANO NIENTE, ordine S voce 08.** Questa funzione
/// segnava il traguardo come condiviso e chiedeva il bonus al server, e nessun
/// foglio di sistema si apriva: toccando "Condividi pubblicamente" non partiva
/// niente verso nessuno, e il bonus era un premio per un gesto mai avvenuto. Un
/// controllo o e' collegato a qualcosa o e' dichiarato inattivo, e non esiste la
/// terza possibilita'.
///
/// **L'ORDINE ADESSO E': si condivide, e solo dopo si incassa.** Se la
/// condivisione non parte non si segna niente e non si chiede niente: `false`
/// dalla porta non e' solo un guasto, e' anche la persona che ha aperto il foglio
/// di sistema e ha cambiato idea, e in quel caso il bonus non e' dovuto.
///
/// Passa dalla PORTA UNICA della condivisione, quella della voce P.28: non se ne
/// scrive una quarta strada.
Future<void> condividiIlTraguardo(
  BuildContext context, {
  required Traguardo traguardo,
  required ModoDellaCondivisione modo,
}) async {
  final diario = context.read<DiarioDelCammino>();
  final servizi = context.read<AppServices>();
  final porta = servizi.porta;
  final borsa = context.read<QuestionAllowance>();
  final registro = _registroDegliEos(context);

  // 1. SI CONDIVIDE DAVVERO.
  final andata = await PortaDellaCondivisione.testo(
    TestoDellaCondivisione.perIlTraguardo(traguardo, modo),
  );
  if (!andata) return;

  // 2. SI SEGNA, cosi' il bonus in sospeso non resta in sospeso per sempre.
  await diario.segnaCondiviso(traguardo.id);

  // 3. SI INCASSA, e il saldo si applica col numero che il server ha appena
  //    detto: chiederlo di nuovo con una seconda chiamata era il difetto della
  //    voce S.04, e se quella non risponde il numero in barra resta vecchio.
  final saldo = await PremioDelTraguardo.bonus(porta, traguardo, modo);
  if (saldo == null) {
    servizi.guasti.registra(
      operazione: 'bonus di condivisione ${modo.motivo} per ${traguardo.id}',
      errore: 'il server non ha risposto: la condivisione e\' avvenuta e il '
          'bonus si riprende alla prossima sincronia',
    );
    return;
  }
  final arrivati = saldo - borsa.saldoEos;
  await registro?.segna(
    quanti: arrivati,
    perche: 'Hai condiviso ${traguardo.nome}',
  );
  await borsa.applicaSaldo(saldo);
}

/// Il registro dei movimenti, se l'albero lo porta: una card riaperta dal
/// journal in una prova non deve cadere per un provider mancante.
RegistroDegliEos? _registroDegliEos(BuildContext context) {
  try {
    return context.read<RegistroDegliEos>();
  } catch (errore) {
    return null;
  }
}
