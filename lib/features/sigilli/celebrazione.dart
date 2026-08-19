import 'dart:async';

import 'package:flutter/material.dart';

import 'direzione_della_festa.dart';
import 'segno_del_sentiero.dart';
import 'pittore_della_festa.dart';
import 'package:provider/provider.dart';

import '../../core/entitlement/question_allowance.dart';
import '../../core/sigilli/bonus_della_condivisione.dart';
import '../../core/sigilli/diario_del_cammino.dart';
import '../../core/sigilli/sentieri.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/theme/maestro_palette.dart';
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
  }) =>
      festeggiaInsieme(
        context,
        traguardi: [traguardo],
        sentieri: [sentiero],
        primoInAssoluto: primoInAssoluto,
        serie: serie,
        attendiLaFine: attendiLaFine,
        allaChiusura: allaChiusura,
      );

  /// **QUANTE CELEBRAZIONI SONO PARTITE, e solo le prove lo leggono.** Ordine
  /// AC voce 04: la prova del rosso deve poter DICHIARARE quante feste sono
  /// comparse, non dedurlo da cio' che resta a schermo, perche' due feste in
  /// fila si vedono una alla volta e a ogni istante il conto visibile e' uno.
  @visibleForTesting
  static int partite = 0;

  /// LA FESTA UNICA. Ordine AC voce 04, decisione di Mauro del 16 agosto:
  /// due celebrazioni di seguito danno gia' fastidio, quindi non se ne devono
  /// mai vedere due di fila.
  ///
  /// **Quando nello stesso momento ci sono due o piu' feste in attesa, si
  /// celebra UNA volta sola, e quella celebrazione le nomina tutte**: il nome
  /// di ogni traguardo acceso, la somma degli Eos, e l'intensita' del piu'
  /// importante (se fra loro c'e' un grande, la celebrazione e' piena). Si
  /// unisce la FESTA, non il premio: ogni Sigillo si accende comunque nel
  /// Journal uno per uno, e nessun traguardo perde i suoi Eos, perche'
  /// l'accredito resta per traguardo nella regia. Il salto al Journal porta
  /// al primo dei Sigilli nominati.
  ///
  /// Con un solo traguardo tutto resta identico a prima, ed e' la prova 1
  /// della voce a pretenderlo.
  static Future<bool> festeggiaInsieme(
    BuildContext context, {
    required List<Traguardo> traguardi,
    required List<Sentiero> sentieri,
    required bool primoInAssoluto,
    String? serie,
    bool attendiLaFine = false,
    VoidCallback? allaChiusura,
  }) async {
    if (traguardi.isEmpty || traguardi.length != sentieri.length) return false;
    // **UNA ALLA VOLTA, ordine S voce 09.** Se una festa e' gia' a schermo questa
    // non si dipinge sopra: chi ha chiamato la mette in coda, e la coda la porta
    // al primo momento utile. Due celebrazioni nello stesso istante sono
    // illeggibili, e il premio di entrambe si perde.
    if (FesteInCorso.unaCeGia) return false;
    if (traguardi.any((t) => t.eGrande) || primoInAssoluto) {
      final navigatore = Navigator.maybeOf(context);
      if (navigatore == null) return false;
      final rotta = _RottaDellaCelebrazione(
        traguardi: traguardi,
        sentieri: sentieri,
        serie: serie,
      );
      final scena = navigatore.push(rotta);
      // **SI SEGNA QUI E NON NELLO STATO DELLA SCENA.** Un widget si costruisce
      // al fotogramma DOPO, e il ciclo della regia chiama questa funzione due
      // volte dentro lo stesso fotogramma: segnandolo in `initState` la seconda
      // chiamata trovava il conto ancora a zero e si dipingeva sopra. Lo ha detto
      // la prova, e ha fatto buttare due stesure prima di questa.
      FesteInCorso.entra(() => rotta.isActive);
      // IL GANCIO VA SULLA ROTTA, non sull'attesa di chi chiama: la forma grande
      // resta aperta finche' la persona non la chiude, e chi ha chiamato non deve
      // aspettarla.
      if (allaChiusura != null) scena.whenComplete(allaChiusura);
      partite++;
      if (attendiLaFine) {
        await scena;
      } else {
        unawaited(scena);
      }
      return true;
    }
    final comparsa = mostraLaSovrimpressione(context,
        traguardi: traguardi,
        sentieri: sentieri,
        serie: serie,
        allaChiusura: allaChiusura);
    if (comparsa) partite++;
    return comparsa;
  }
}

/// QUANTE FESTE CI SONO A SCHERMO, ordine S voce 09.
///
/// **Il difetto, visto sulla 2177.** Due celebrazioni si dipingevano nello
/// stesso istante, "IL GIORNO E LA SERA" sopra "IL GIORNO PIENO", con due
/// "+10 Eos" uno sull'altro. La ragione sta nel ciclo della regia: piu' Sigilli
/// possono maturare con lo stesso gesto, e per ognuno si chiedeva la festa senza
/// attendere la precedente. La coda esisteva, ma serializzava cio' che si
/// ACCODA, non cio' che si dipinge.
///
/// **Adesso il conto e' uno e sta qui.** Chi entra si segna, chi esce si toglie,
/// e `Celebrazione.festeggia` rifiuta se ce n'e' gia' una: chi ha chiamato la
/// mette in coda, che e' esattamente cio' che fa quando non c'e' dove ospitarla.
/// Un conto solo, e non un flag per forma: due contatori diversi sarebbero due
/// verita' sulla stessa domanda.
class FesteInCorso {
  const FesteInCorso._();

  /// **UN ELENCO DI DOMANDE, non un contatore.** Ordine S voce 09, seconda
  /// stesura. Con un contatore, chi entra deve ricordarsi di uscire: se l'uscita
  /// non arriva, e succede quando una rotta non viene mai chiusa perche' l'albero
  /// e' stato buttato, il conto resta a uno e da quel momento **nessuna festa si
  /// mostra piu'**. Lo hanno detto due prove della coda, che chiedevano una festa
  /// e non la vedevano arrivare.
  ///
  /// Qui ogni festa lascia una domanda a cui si sa rispondere: "sei ancora a
  /// schermo?". La rotta risponde guardando se e' attiva, la fascia se e' ancora
  /// inserita nell'Overlay. Chi non risponde piu' di si' esce da se', e non c'e'
  /// niente da ricordarsi.
  static final List<bool Function()> _vive = [];

  /// Vero se una festa e' gia' a schermo.
  static bool get unaCeGia {
    _vive.removeWhere((ancoraViva) => !ancoraViva());
    return _vive.isNotEmpty;
  }

  /// Segna una festa appena messa a schermo, con la domanda che la tiene viva.
  static void entra(bool Function() ancoraViva) => _vive.add(ancoraViva);

  /// Solo per le prove: dimentica tutto fra una scena e l'altra.
  @visibleForTesting
  static void azzera() => _vive.clear();
}

/// IL VELO DELLA CELEBRAZIONE: un numero solo, per entrambe le forme.
///
/// **Perche' e' dichiarato qui.** L'ordine chiede che il velo sia opaco
/// abbastanza che nessun testo sottostante si legga attraverso, con soglia
/// dichiarata e misurata, non a occhio. La forma grande aveva la sua barriera
/// scritta a mano dentro la rotta, la fascia aveva un gradiente radiale che
/// finiva TRASPARENTE ai bordi: due numeri diversi per la stessa promessa, e uno
/// dei due la tradiva. Adesso il numero e' uno e le due forme lo leggono.
class VeloDellaCelebrazione {
  const VeloDellaCelebrazione._();

  /// L'OPACITA' DEL VELO A PIENO REGIME.
  ///
  /// Novantasei centesimi. **La misura diceva che bastavano novantadue, e
  /// l'anteprima ha detto di no:** sotto il velo al 92 per cento le tre righe del
  /// sentiero restavano un fantasma che si leggeva ancora, e la prova non lo
  /// vedeva perche' la sua soglia ammette ventiquattro livelli di luce su 255. Le
  /// anteprime vedono cio' che le prove non cercano. Non e' opaco del tutto perche' la scena sotto deve restare
  /// riconoscibile: la festa e' successa DENTRO qualcosa, e coprirla del tutto
  /// farebbe sembrare la celebrazione un'altra schermata.
  static const double opacita = 0.96;

  /// Quanto dura la dissolvenza in entrata e in uscita.
  static const Duration dissolvenza = Duration(milliseconds: 420);

  /// Il colore del velo per un sentiero.
  static Color colore(MaestroPalette palette) =>
      palette.deepest.withValues(alpha: opacita);
}

/// LA FORMA GRANDE: la scena prende tutto, il Maestro parla, il segno si
/// compie. Non finisce mai col punto: in fondo c'e' il prossimo traguardo.
class _RottaDellaCelebrazione extends PageRouteBuilder<void> {
  _RottaDellaCelebrazione({
    required this.traguardi,
    required this.sentieri,
    this.serie,
  }) : super(
          opaque: false,
          // IL VELO LEGGE IL NUMERO UNICO, ordine S voce 09: qui c'era
          // `0xCC05060A`, cioe' un'opacita' scritta a mano che nessuno teneva
          // d'accordo con quella della fascia.
          barrierColor: const Color(0xFF05060A).withValues(
            alpha: VeloDellaCelebrazione.opacita,
          ),
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
          // **LA SCENA E' DEL PRIMO NOMINATO**: colore, segno e salto al
          // Journal seguono il primo dei Sigilli, come l'ordine AC voce 04
          // prescrive per il salto. L'INTENSITA' invece e' del piu'
          // importante, e la decide la scena guardando se fra i traguardi
          // c'e' un grande.
          pageBuilder: (context, _, __) => MaestroScope(
            maestro: FesteDeiMaestri.dellaScena(traguardi, sentieri),
            child: CelebrazioneAScermoPieno(
              traguardi: traguardi,
              sentieri: sentieri,
              serie: serie,
            ),
          ),
        );

  final List<Traguardo> traguardi;
  final List<Sentiero> sentieri;
  final String? serie;
}

class CelebrazioneAScermoPieno extends StatefulWidget {
  const CelebrazioneAScermoPieno({
    super.key,
    required this.traguardi,
    required this.sentieri,
    this.serie,
  });

  /// I traguardi nominati, nell'ordine in cui il cammino li ha accesi.
  /// Ordine AC voce 04: quasi sempre uno, e quando sono di piu' la festa e'
  /// UNA e li nomina tutti.
  final List<Traguardo> traguardi;
  final List<Sentiero> sentieri;

  /// "terzo giorno di seguito", quando c'e' una serie da dire.
  final String? serie;

  /// Il piu' importante fra i nominati: un grande se c'e', il primo
  /// altrimenti. La sua frase e' quella che si legge, la sua intensita' e'
  /// quella della festa.
  Traguardo get principale =>
      traguardi.firstWhere((t) => t.eGrande, orElse: () => traguardi.first);

  @override
  State<CelebrazioneAScermoPieno> createState() =>
      _CelebrazioneAScermoPienoState();
}

/// QUANTO SPAZIO SI TIENE PER L'USCITA, ordine AN voce 09. E' l'altezza del
/// bersaglio del congedo, quarantotto punti, la stessa misura minima con cui
/// si tocca qualsiasi altra cosa nel Cerchio: la scena che scorre riceve
/// tanto in meno, cosi' il suo centro resta il centro della parte visibile e
/// non della finestra intera.
const double _altezzaDelCongedo = 48;

class _CelebrazioneAScermoPienoState extends State<CelebrazioneAScermoPieno>
    with SingleTickerProviderStateMixin {
  late final AnimationController _segno = AnimationController(
    vsync: this,
    // **LA DURATA VIENE DAL DATO E NON DA QUI.** Ordine U voce 02: si sceglie
    // sul tempo di LETTURA di cio' che si scopre, non su quello
    // dell'animazione, e il grande dura un terzo in piu' del mini.
    duration: Duration(
        milliseconds: FesteDeiMaestri.millesimiDi(
            eGrande: widget.traguardi.any((t) => t.eGrande))),
  );

  /// **UN TOCCO LA SALTA, e porta subito al traguardo e al premio.** Una festa
  /// da cui non si puo' uscire diventa un ostacolo alla seconda volta: la prima
  /// si guarda, la decima si vuole superare.
  void _salta() {
    if (_segno.isCompleted) return;
    _segno.value = 1;
  }

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
    final prossimo = diario.prossimoDi(widget.sentieri.first);
    // I sentieri coinvolti, senza ripetizioni e nell'ordine dei nominati: la
    // festa unita porta il segno di ognuno, che e' il "Sigilli di tutti"
    // dell'ordine AC voce 04.
    final coinvolti = <Sentiero>[];
    for (final s in widget.sentieri) {
      if (!coinvolti.contains(s)) coinvolti.add(s);
    }
    final eosTotali =
        widget.traguardi.fold<int>(0, (somma, t) => somma + t.eos);

    return CosmosBackground(
      seed: 23,
      child: Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          key: const Key('festa_salta'),
          behavior: HitTestBehavior.opaque,
          onTap: _salta,
          child: Stack(
            children: [
        SafeArea(
          // LA SCENA SCORRE SE LO SCHERMO E' BASSO, invece di traboccare: su
          // un telefono piccolo, o con la scrittura ingrandita, la festa non
          // deve diventare una riga gialla di errore. La prova lo ha trovato
          // al primo montaggio, su uno schermo da 600 punti.
          //
          // **E IL CONGEDO STA FUORI DALLO SCORRIMENTO, ordine AN voce 09.**
          // Finche' stava in fondo alla colonna bastava che la festa
          // crescesse per spingerlo oltre il bordo, ed e' successo: le tre
          // frasi "quando arrivano i tuoi Eos" della voce 08 lo hanno portato
          // a 877 punti su uno schermo di 797, cioe' fuori. Una festa a
          // schermo pieno senza uscita raggiungibile e' una stanza senza
          // porta, quindi la porta si ancora al fondo e il resto scorre
          // sotto: qualunque cosa cresca dentro domani, l'uscita resta dov'e'.
          child: LayoutBuilder(
            builder: (context, vincoli) => Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: vincoli.maxHeight - _altezzaDelCongedo),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: SpacingTokens.xxl),
                    // IL SEGNO DI OGNI SENTIERO COINVOLTO: quasi sempre uno,
                    // e con una festa unita di sentieri diversi uno ciascuno.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (final s in coinvolti) ...[
                          SegnoDelMaestro(
                            sentiero: s,
                            avanzamento: _segno,
                            grande: true,
                          ),
                          if (s != coinvolti.last)
                            const SizedBox(width: SpacingTokens.md),
                        ],
                      ],
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    // **OGNI TRAGUARDO PORTA IL SUO NOME**, ordine AC voce
                    // 04: la festa e' una e li nomina tutti. Il primo tiene
                    // la chiave storica, cosi' ogni prova che cercava il nome
                    // della festa continua a trovarlo.
                    for (final t in widget.traguardi) ...[
                      Text(
                        t.nome,
                        key: t == widget.traguardi.first
                            ? const Key('celebrazione_nome')
                            : null,
                        textAlign: TextAlign.center,
                        style: TypographyTokens.cerimonialeGrande()
                            .copyWith(color: palette.goldSoft),
                      ),
                      if (t != widget.traguardi.last)
                        const SizedBox(height: SpacingTokens.xs),
                    ],
                    if (widget.serie != null) ...[
                      const SizedBox(height: SpacingTokens.xs),
                      Text(widget.serie!,
                          key: const Key('celebrazione_serie'),
                          style: TypographyTokens.etichetta()
                              .copyWith(color: palette.goldSoft)),
                    ],
                    const SizedBox(height: SpacingTokens.md),
                    // Una frase sola, quella del piu' importante: tre frasi
                    // cerimoniali in fila sarebbero un muro di testo, e la
                    // festa deve restare leggibile in un respiro.
                    Text(
                      widget.principale.frase,
                      key: const Key('celebrazione_frase'),
                      textAlign: TextAlign.center,
                      style: TypographyTokens.corpo().copyWith(
                          color: ColorTokens.textPrimary, height: 1.5),
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    // LA SOMMA DEGLI EOS: nessun traguardo perde i suoi,
                    // l'accredito resta per traguardo nella regia.
                    EosCheVolano(quanti: eosTotali, avanzamento: _segno),
                    const SizedBox(height: SpacingTokens.lg),
                    VieDellaCondivisione(
                      // Si condivide il piu' importante: la card porta un
                      // traguardo solo, e il piu' importante e' la festa.
                      suScelta: (modo) => condividiIlTraguardo(
                        context,
                        traguardo: widget.principale,
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
                        // AL PRIMO DEI SIGILLI NOMINATI, ordine AC voce 04.
                        navigatore
                            .push(SentieroScreen.route(widget.sentieri.first));
                      },
                      icon: Icon(Icons.route_rounded,
                          size: 16, color: palette.goldSoft),
                      label: Text('Vedi il Sigillo sul sentiero',
                          style: TypographyTokens.didascalia()
                              .copyWith(color: palette.goldSoft)),
                    ),
                  ],
                ),
              ),
                  ),
                ),
                // IL CONGEDO, ANCORATO: sta fuori dallo scorrimento, quindi
                // e' raggiungibile qualunque cosa ci sia sopra.
                //
                // **E porta il suo velo**, una sfumatura ferma e non una
                // sfocatura per fotogramma: senza, cio' che scorre gli passa
                // dietro e le due scritte si leggono una sull'altra.
                Container(
                  height: _altezzaDelCongedo,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x0005060A), Color(0xE605060A)],
                    ),
                  ),
                  child: Center(
                    child: TextButton(
                      key: const Key('celebrazione_continua'),
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: Text('Continua il cammino',
                          style: TypographyTokens.etichetta()
                              .copyWith(color: ColorTokens.textSecondary)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
              // **LA FESTA STA SOPRA, e non sotto.** Ordine U voce 02: il
              // movimento deve SCOPRIRE cio' che c'e' sotto, quindi passa
              // davanti alla scena e se ne va. Non intercetta il tocco, cosi'
              // i due pulsanti restano raggiungibili anche mentre corre.
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _segno,
                    builder: (context, _) => CustomPaint(
                      key: Key('festa_${FesteDeiMaestri.dellaScena(
                        widget.traguardi,
                        widget.sentieri,
                      ).id}'),
                      painter: PittoreDellaFesta(
                        maestro: FesteDeiMaestri.dellaScena(
                          widget.traguardi,
                          widget.sentieri,
                        ),
                        // **CON RIDUCI MOVIMENTO LA FESTA RESTA UNA FESTA,
                        // ordine AQ voce 02.** Con quel modo acceso la scena
                        // porta il segno gia' a fine corsa, e a fine corsa le
                        // particelle hanno gia' finito il loro volo: misurato,
                        // ZERO pixel su mille cambiavano ai bordi, cioe' la
                        // festa era un fermo immagine e tutte e tre si
                        // riducevano alla stessa scheda con sopra un simbolo.
                        // Adesso il pittore riceve la POSA in cui il campo e'
                        // pieno: niente si muove, ma la materia del proprio
                        // Maestro si vede, ed e' cio' che distingue le tre
                        // feste.
                        // **CON RIDUCI MOVIMENTO SI MOSTRA IL CAMPO PIENO,
                        // ordine AQ voce 02.** Con quel modo acceso la scena
                        // porta il segno subito a fine corsa, e la festa
                        // veniva dipinta nell'istante in cui il volo e' gia'
                        // finito: la coda, non la festa. Adesso il pittore
                        // riceve la posa in cui il campo e' pieno. Nessun
                        // movimento, come la persona ha chiesto, ma la
                        // materia del proprio Maestro si vede tutta.
                        avanzamento: MediaQuery.of(context).disableAnimations
                            ? PittoreDellaFesta.posaDelCampoPieno
                            : _segno.value,
                        oro: palette.gold,
                        oroTenue: palette.goldSoft,
                        // L'INTENSITA' E' QUELLA DEL PIU' IMPORTANTE: un
                        // grande fra i nominati accende la festa piena.
                        eGrande: widget.traguardi.any((t) => t.eGrande),
                        effettiPieni:
                            !MediaQuery.of(context).disableAnimations,
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
    return AnimatedBuilder(
      key: const Key('segno_del_maestro'),
      animation: avanzamento,
      builder: (context, _) {
        final t = Curves.easeOutBack.transform(avanzamento.value.clamp(0, 1));
        return Opacity(
          opacity: avanzamento.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.6 + 0.4 * t,
            // **IL SEGNO E' DISEGNATO DA NOI, ordine AQ voce 02.** Qui
            // stavano tre glifi di Material, e due erano lo stesso fiore.
            child: SegnoDelSentiero(
              sentiero: sentiero,
              colore: palette.goldSoft,
              misura: misura,
              avanzamento: avanzamento.value,
            ),
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
  required List<Traguardo> traguardi,
  required List<Sentiero> sentieri,
  String? serie,
  VoidCallback? allaChiusura,
}) {
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return false;
  // Stessa ragione della forma grande: il conto si segna alla porta, non nello
  // stato del widget, che nasce un fotogramma dopo.
  if (FesteInCorso.unaCeGia) return false;
  late final OverlayEntry fascia;
  // **LA DOMANDA CHE TIENE VIVA LA FESTA.** Non si puo' chiedere
  // `fascia.mounted`: una voce dell'Overlay diventa montata al fotogramma DOPO
  // l'inserimento, e il ciclo della regia chiama due volte nello stesso
  // fotogramma. Si tiene percio' una bandiera, spenta da tutte le strade di
  // uscita, ritiro e smontaggio.
  var viva = true;
  fascia = OverlayEntry(
    // ANCHE LA FASCIA SI PORTA IL SUO SCOPE, per la stessa ragione della forma
    // grande: una voce dell'Overlay non e' figlia della pagina che l'ha chiesta,
    // e il colore giusto e' quello del sentiero che si sta festeggiando.
    builder: (ctx) => MaestroScope(
      maestro: FesteDeiMaestri.dellaScena(traguardi, sentieri),
      child: _FasciaDellaCelebrazione(
        traguardi: traguardi,
        sentieri: sentieri,
        serie: serie,
        suMorte: () => viva = false,
        suFine: () {
          viva = false;
          if (fascia.mounted) fascia.remove();
          // LA FASCIA SE NE VA DA SE' dopo qualche secondo: quello e' il suo
          // momento di chiusura, ed e' li' che gli Eos volano.
          allaChiusura?.call();
        },
      ),
    ),
  );
  overlay.insert(fascia);
  FesteInCorso.entra(() => viva);
  return true;
}

class _FasciaDellaCelebrazione extends StatefulWidget {
  const _FasciaDellaCelebrazione({
    required this.traguardi,
    required this.sentieri,
    required this.suFine,
    required this.suMorte,
    this.serie,
  });

  /// I traguardi nominati: la festa unita dell'ordine AC voce 04 vale anche
  /// nella forma breve.
  final List<Traguardo> traguardi;
  final List<Sentiero> sentieri;
  final String? serie;
  final VoidCallback suFine;

  /// **CHIAMATA SU QUALUNQUE STRADA DI USCITA**, ordine S voce 09. Il ritiro
  /// normale passa da [suFine], ma un albero buttato non ritira niente: senza
  /// questa, la festa resterebbe segnata come viva per sempre e nessun'altra si
  /// mostrerebbe piu'.
  final VoidCallback suMorte;

  @override
  State<_FasciaDellaCelebrazione> createState() =>
      _FasciaDellaCelebrazioneState();
}

class _FasciaDellaCelebrazioneState extends State<_FasciaDellaCelebrazione>
    with TickerProviderStateMixin {
  late final AnimationController _segno = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  /// IL VELO, che entra e SI DISSOLVE ALLA FINE, ordine S voce 09. Prima la
  /// fascia spariva di colpo, e una scena che si spegne a scatto sembra un
  /// errore di disegno invece della fine di una festa.
  late final AnimationController _velo = AnimationController(
    vsync: this,
    duration: VeloDellaCelebrazione.dissolvenza,
  );
  Timer? _ritiro;

  /// Quanto resta a schermo prima di ritirarsi da sola.
  static const Duration quantoResta = Duration(seconds: 6);

  @override
  void initState() {
    super.initState();
    // Il ritiro parte in anticipo di quanto dura la dissolvenza, cosi' la scena
    // resta a schermo per il tempo dichiarato e non un istante di piu'.
    _ritiro = Timer(quantoResta - VeloDellaCelebrazione.dissolvenza, _ritirati);
  }

  Future<void> _ritirati() async {
    if (!mounted) {
      widget.suFine();
      return;
    }
    // Con Riduci Movimento non si dissolve niente: si esce, e si esce subito.
    if (MediaQuery.of(context).disableAnimations) {
      widget.suFine();
      return;
    }
    await _velo.reverse();
    widget.suFine();
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
      _velo.value = 1;
    } else {
      _segno.forward();
      _velo.forward();
    }
  }

  @override
  void dispose() {
    widget.suMorte();
    _ritiro?.cancel();
    _velo.dispose();
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
      child: FadeTransition(
        opacity: _velo,
        child: Material(
          key: const Key('sovrimpressione_del_traguardo'),
          type: MaterialType.transparency,
          child: Stack(
            children: [
              IgnorePointer(
                // **IL VELO E' UNO STRATO A SE', E IL BAGLIORE STA SOPRA.**
                // Ordine S voce 09. Qui c'era un gradiente radiale che ai bordi
                // arrivava a `Colors.transparent`: il testo della schermata sotto
                // si leggeva attraverso, ed e' cio' che si vedeva sulla 2177.
                //
                // **E il primo rimedio non bastava, e la misura lo ha detto.** Un
                // `BoxDecoration` che porta insieme un colore e un gradiente
                // dipinge il GRADIENTE e ignora il colore: mettere il velo come
                // colore accanto al bagliore non copriva niente, e nella fascia in
                // alto il testo di sotto restava al quarantacinque per cento.
                // Adesso sono due strati: il velo pieno, e sopra il bagliore che
                // aggiunge luce senza togliere copertura.
                child: ColoredBox(
                  color: VeloDellaCelebrazione.colore(palette),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        radius: 0.9,
                        colors: [
                          palette.surfaceElevated.withValues(alpha: 0.62),
                          palette.surfaceElevated.withValues(alpha: 0.24),
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
                                  sentiero: widget.sentieri.first,
                                  avanzamento: _segno,
                                  grande: true),
                              const SizedBox(height: SpacingTokens.md),
                              // OGNI TRAGUARDO PORTA IL SUO NOME, ordine AC
                              // voce 04: il primo tiene la chiave storica.
                              for (final t in widget.traguardi) ...[
                                Text(t.nome,
                                    key: t == widget.traguardi.first
                                        ? const Key('sovrimpressione_nome')
                                        : null,
                                    textAlign: TextAlign.center,
                                    style: TypographyTokens.cerimoniale()
                                        .copyWith(color: palette.goldSoft)),
                                if (t != widget.traguardi.last)
                                  const SizedBox(height: SpacingTokens.xs),
                              ],
                              const SizedBox(height: SpacingTokens.xs),
                              // **GLI EOS NON SI SCRIVONO DUE VOLTE.** Qui c'era
                              // `widget.serie ?? '+N Eos'`, e appena sotto c'e'
                              // il segno degli Eos che li conta: nell'anteprima
                              // si leggeva "+20 Eos" e subito sotto "+20 Eos"
                              // con l'icona. La riga porta la SERIE, che e'
                              // l'unica cosa che il segno non sa dire.
                              if (widget.serie != null) ...[
                                Text(
                                  widget.serie!,
                                  key: const Key('sovrimpressione_eos'),
                                  textAlign: TextAlign.center,
                                  style: TypographyTokens.titoloScheda()
                                      .copyWith(color: ColorTokens.textPrimary),
                                ),
                                const SizedBox(height: SpacingTokens.xs),
                              ],
                              // LA SOMMA DEGLI EOS di tutti i nominati.
                              EosCheVolano(
                                  quanti: widget.traguardi.fold<int>(
                                      0, (somma, t) => somma + t.eos),
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
                      traguardo: widget.traguardi.first,
                      modo: modo,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
    // **IL FOGLIO VESTE IL MAESTRO DEL SENTIERO, ordine AL voce 04.** Il
    // builder vive sul Navigator radice, fuori dallo scope della schermata
    // che lo apre: qui la card e le vie chiedevano `context.palette` a uno
    // scope che non c'era, e in release il foglio moriva BIANCO. Lo scope
    // giusto non e' quello della schermata di passaggio ma quello del
    // sentiero del traguardo, lo stesso disegno di paletteDelSentiero.
    builder: (foglio) => MaestroScope(
      maestro: sentiero.maestro,
      child: Padding(
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

  // **L'INVITO NON SI PAGA ADESSO, ordine AN voce 08, e qui si dice la
  // verita' invece di fingere.** Il suo premio arriva quando l'amico scarica
  // il Cerchio, e sapere se l'ha fatto richiede un'attribuzione
  // dell'installazione che nel progetto NON esiste. Accreditarlo alla
  // condivisione, mentre il pulsante dichiara "quando il tuo amico scarica",
  // sarebbe una bugia a schermo: resta dichiarato in attesa sulla card e si
  // accreditera' quando l'attribuzione ci sara'. Gli altri due modi si
  // incassano subito, perche' del loro esito il codice sa tutto.
  if (!modo.subitoPagato) return;

  // 3. SI INCASSA, e il saldo si applica col numero che il server ha appena
  //    detto: chiederlo di nuovo con una seconda chiamata era il difetto della
  //    voce S.04, e se quella non risponde il numero in barra resta vecchio.
  final saldo = await PremioDelTraguardo.bonus(porta, traguardo, modo);
  if (saldo == null) {
    servizi.guasti.registra(
      operazione: 'bonus di condivisione ${modo.motivo} per ${traguardo.id}',
      // Nessun "e'" scritto con l'apostrofo: la guardia della lingua non puo'
      // distinguere da fuori una frase mostrata da una riga di registro, e in
      // questo repository quella forma resta vietata comunque.
      errore: 'il server non ha risposto: la condivisione era partita e il '
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
