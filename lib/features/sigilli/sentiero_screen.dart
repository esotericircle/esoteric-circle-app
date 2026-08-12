import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../../core/entitlement/entitlement_service.dart';
import '../../core/entitlement/question_allowance.dart';
import '../../core/entitlement/tier.dart';
import '../../core/sigilli/diario_del_cammino.dart';
import '../../core/sigilli/sentieri.dart';
import '../../core/sigilli/stato_del_sigillo.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../maestri/rotta_arte.dart';
import '../pricing/upgrade_invite.dart';
import 'celebrazione.dart';
import 'disegno_del_sentiero.dart';

/// IL SENTIERO DEI SIGILLI: Albero, Costellazione o Loto.
///
/// **Il disegno sta in alto ed e' la prima cosa che si vede, ordine P voce
/// 33.** Prima di questa voce la schermata era un elenco di righe con le icone
/// di serie del framework, e i tre sentieri differivano per la sola palette:
/// la sezione 13 del Briefing non era costruita. Adesso ogni sentiero ha il
/// suo disegno, `DisegnoDelSentiero`, e l'elenco resta come SECONDA LETTURA,
/// scorrendo. Il disegno e l'elenco si parlano nei due versi: toccando un
/// punto si va al suo traguardo, e toccando un traguardo si evidenzia il suo
/// punto.
///
/// **L'apertura viene dall'alto**, come deciso: prima il traguardo 50 in
/// piena luce, poi lo scorrimento scende a ritroso e si ferma sul punto
/// raggiunto. Non e' un vezzo: chi apre un journal vuoto deve vedere prima
/// dove si arriva, non dove non e' ancora arrivato.
class SentieroScreen extends StatefulWidget {
  const SentieroScreen({super.key, required this.sentiero, this.senzaVolo = false});

  final Sentiero sentiero;

  /// Per le prove e le anteprime: niente scorrimento animato, la scena si
  /// monta gia' ferma sul punto raggiunto.
  final bool senzaVolo;

  static Route<void> route(Sentiero sentiero) => MaterialPageRoute<void>(
        builder: (_) => SogliaArte(
          id: 'sigilli_${sentiero.name}',
          maestro: sentiero.maestro,
          child: SentieroScreen(sentiero: sentiero),
        ),
      );

  @override
  State<SentieroScreen> createState() => _SentieroScreenState();
}

class _SentieroScreenState extends State<SentieroScreen> {
  final ScrollController _scorrimento = ScrollController();

  /// Le chiavi dei gradini: servono a MISURARE dove sta una riga invece di
  /// dedurlo da un'altezza scritta a mano, ordine P voce 36.
  final Map<String, GlobalKey> _chiaviDeiGradini = {};

  /// Il traguardo che il disegno deve evidenziare.
  String? _evidenziato;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scendiAlPunto());
  }

  @override
  void dispose() {
    _scorrimento.dispose();
    super.dispose();
  }

  /// Il traguardo su cui il cammino si e' fermato: il primo NON ancora acceso.
  Traguardo _dovePuntare(int accesi) {
    final mini = Sentieri.miniDi(widget.sentiero);
    return mini[accesi.clamp(0, mini.length - 1)];
  }

  /// LA DISCESA: dal 50 in luce fino al punto raggiunto.
  ///
  /// **Il conto era rovesciato, ordine P voce 36.** Qui c'era
  /// `(50 - gradini) * altezzaDelGradino` con `gradini = (50 - accesi)`, cioe',
  /// sostituendo, `accesi * 92`. La lista e' rovesciata, quindi in cima c'e' il
  /// 50 e in fondo l'1: con due traguardi accesi lo scorrimento si fermava a
  /// 184 punti, due righe, ed e' il motivo per cui non si muoveva niente. Con
  /// zero accesi non si muoveva affatto.
  ///
  /// **E sotto quel difetto ce n'era un secondo**: `altezzaDelGradino` era
  /// fissata a 92 mentre le righe hanno titoli e frasi di lunghezza diversa,
  /// quindi anche col conto giusto il punto di arrivo sarebbe scivolato. Per
  /// questo qui non si calcola piu' niente: si MISURA la riga vera sulla resa,
  /// col viewport che la ospita. Una misura non puo' scivolare.
  Future<void> _scendiAlPunto() async {
    if (!mounted) return;
    final diario = context.read<DiarioDelCammino>();
    final accesi = diario.quantiAccesiDi(widget.sentiero);
    final dove = offsetDelTraguardo(_dovePuntare(accesi).id);
    if (dove == null || !_scorrimento.hasClients) return;
    final meta = dove.clamp(0.0, _scorrimento.position.maxScrollExtent);
    // CON RIDUCI MOVIMENTO LA DISCESA E' IMMEDIATA MA IL PUNTO DI ARRIVO E'
    // LO STESSO: si toglie il volo, non la destinazione.
    final fermo = widget.senzaVolo ||
        MediaQuery.maybeOf(context)?.disableAnimations == true;
    if (fermo) {
      _scorrimento.jumpTo(meta);
      return;
    }
    await _scorrimento.animateTo(
      meta,
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeOutCubic,
    );
  }

  /// Dove sta una riga dentro cio' che scorre, MISURATO sulla resa.
  ///
  /// Restituisce null finche' la riga non e' stata disposta: con le righe
  /// costruite tutte insieme (sono cinquanta) succede solo prima del primo
  /// fotogramma.
  double? offsetDelTraguardo(String id) {
    final contesto = _chiaviDeiGradini[id]?.currentContext;
    final scatola = contesto?.findRenderObject();
    if (scatola is! RenderBox || !scatola.hasSize || !scatola.attached) {
      return null;
    }
    return RenderAbstractViewport.of(scatola)
        .getOffsetToReveal(scatola, 0)
        .offset;
  }

  void _vaiAlTraguardo(Traguardo traguardo) {
    setState(() => _evidenziato = traguardo.id);
    final dove = offsetDelTraguardo(traguardo.id);
    if (dove == null || !_scorrimento.hasClients) return;
    final meta = dove.clamp(0.0, _scorrimento.position.maxScrollExtent);
    if (MediaQuery.maybeOf(context)?.disableAnimations == true) {
      _scorrimento.jumpTo(meta);
      return;
    }
    _scorrimento.animateTo(meta,
        duration: const Duration(milliseconds: 600), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final diario = context.watch<DiarioDelCammino>();
    final borsa = context.watch<QuestionAllowance>();
    final piano = context.watch<EntitlementService>().tier;
    // I traguardi si mostrano dal 50 al 1: l'apertura viene dall'alto.
    final mini = Sentieri.miniDi(widget.sentiero).reversed.toList();
    final accesi = {
      for (final t in Sentieri.di(widget.sentiero))
        if (diario.eAcceso(t.id)) t.id,
    };

    return CosmosBackground(
      seed: 19,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // LA BARRA UNICA DELLE ARTI, non una AppBar montata a mano: e' la
        // regola che tiene insieme il cuore delle arti preferite e le azioni
        // di ogni schermata, e una barra fatta in casa e' il modo in cui il
        // difetto era nato la prima volta.
        appBar: BarraArte(
          // IL TITOLO INTERO, e non tagliato: "Costellazione pers..." era
          // quello che si leggeva nell'anteprima, e un titolo troncato dice
          // che la schermata non e' finita.
          titolo: Text(widget.sentiero.titolo,
              maxLines: 2,
              style: TypographyTokens.titoloScheda()
                  .copyWith(color: palette.goldSoft)),
          azioni: [
            // IL SALDO EOS, che legge dal server e non finge: finche' le
            // funzioni non sono distribuite mostra l'ultimo saldo noto.
            Padding(
              padding: const EdgeInsets.only(right: SpacingTokens.md),
              child: Row(
                key: const Key('saldo_eos'),
                children: [
                  Icon(Icons.auto_awesome, size: 16, color: palette.goldSoft),
                  const SizedBox(width: 4),
                  Text('${borsa.saldoEos}',
                      key: const Key('saldo_eos_numero'),
                      style: TypographyTokens.etichetta()
                          .copyWith(color: palette.goldSoft)),
                ],
              ),
            ),
          ],
        ),
        // TUTTO DENTRO UN SOLO SCORRIMENTO: il disegno in alto e' la prima
        // cosa che si vede, l'elenco arriva scorrendo. Le cinquanta righe si
        // costruiscono tutte, non a domanda: sono cinquanta, e servono
        // disposte perche' la discesa possa MISURARE dove si ferma.
        body: CustomScrollView(
          key: const Key('sentiero_scorrimento'),
          controller: _scorrimento,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(SpacingTokens.md,
                    SpacingTokens.sm, SpacingTokens.md, SpacingTokens.sm),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: DisegnoDelSentiero(
                    sentiero: widget.sentiero,
                    accesi: accesi,
                    evidenziato: _evidenziato,
                    suTocco: _vaiAlTraguardo,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _FasciaDeiGrandi(
                sentiero: widget.sentiero,
                diario: diario,
                suTocco: _vaiAlTraguardo,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.lg, vertical: SpacingTokens.md),
              // UNA COLONNA E NON UNA LISTA PIGRA, ed e' una scelta della
              // voce 36. Una lista pigra dispone soltanto le righe dentro il
              // viewport: le altre non hanno una posizione, quindi la discesa
              // non potrebbe MISURARE dove si ferma e tornerebbe a stimarla
              // da un'altezza scritta a mano, che e' il difetto di partenza.
              // Le righe sono cinquanta: costruirle tutte non costa niente e
              // rende la misura possibile.
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    for (final traguardo in mini)
                      GradinoDelSentiero(
                        key: _chiaviDeiGradini.putIfAbsent(
                            traguardo.id, GlobalKey.new),
                        traguardo: traguardo,
                        sentiero: widget.sentiero,
                        diario: diario,
                        piano: piano,
                        evidenziato: _evidenziato == traguardo.id,
                        suTocco: () =>
                            setState(() => _evidenziato = traguardo.id),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// I CINQUE GRANDI, sempre visibili in anticipo: modello tessera punti.
class _FasciaDeiGrandi extends StatelessWidget {
  const _FasciaDeiGrandi({
    required this.sentiero,
    required this.diario,
    required this.suTocco,
  });

  final Sentiero sentiero;
  final DiarioDelCammino diario;
  final void Function(Traguardo traguardo) suTocco;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      key: const Key('fascia_dei_grandi'),
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg, vertical: SpacingTokens.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final grande in Sentieri.grandiDi(sentiero))
            GestureDetector(
              onTap: () => suTocco(grande),
              child: Column(
                children: [
                  Icon(
                    diario.eAcceso(grande.id)
                        ? Icons.auto_awesome
                        : Icons.circle_outlined,
                    size: 26,
                    color: diario.eAcceso(grande.id)
                        ? palette.goldSoft
                        : ColorTokens.textSecondary
                            .withValues(alpha: SogliaDelLeggibile.alfaDelloSpento),
                  ),
                  const SizedBox(height: 2),
                  Text('${grande.posizione}',
                      style: TypographyTokens.etichetta().copyWith(
                        color: diario.eAcceso(grande.id)
                            ? palette.goldSoft
                            : ColorTokens.textSecondary,
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// LE OPACITA' DEL SENTIERO, UNA SOLA PER STATO. Ordine P voce 37.
///
/// **Il difetto, coi numeri.** Il colore del non raggiunto era
/// `textSecondary` ad alfa 0,35 e l'intera riga era avvolta in
/// `Opacity(opacity: 0.78)`. Le due si moltiplicavano: l'alfa effettivo del
/// titolo era **0,273**, cioe' un contrasto di 1,76 a 1 sul fondo reale, sotto
/// la meta' della soglia. Il commento accanto al codice diceva che a 0,55 i
/// nomi sparivano e che il grigio era stato reso leggibile: la misura diceva
/// il contrario, e ha vinto la misura.
///
/// **La regola.** Una sola opacita' governa lo stato, mai due che si
/// moltiplicano, e il valore non si sceglie a occhio: si sceglie perche' il
/// contrasto del titolo sul fondo reale soddisfi la soglia della voce P.12,
/// 4,5 a 1. A 0,80 il caso peggiore dei tre sentieri, il verde di Aura, misura
/// 4,85 a 1.
class SogliaDelLeggibile {
  const SogliaDelLeggibile._();

  /// L'unica opacita' dello stato spento. Non ne esiste una seconda che la
  /// moltiplichi: e' proprio il moltiplicarsi ad aver prodotto lo 0,273.
  static const double alfaDelloSpento = 0.80;

  /// Lo stato "e' il tuo prossimo": oro tenue, e a 0,70 misura 4,82 a 1 nel
  /// caso peggiore.
  static const double alfaDelProssimo = 0.70;

  /// La soglia della voce P.12 per il testo di lettura e di corpo.
  static const double contrastoMinimo = 4.5;
}

/// UN GRADINO: il Sigillo nei suoi CINQUE stati dichiarati.
class GradinoDelSentiero extends StatelessWidget {
  const GradinoDelSentiero({
    super.key,
    required this.traguardo,
    required this.sentiero,
    required this.diario,
    required this.piano,
    this.evidenziato = false,
    this.suTocco,
  });

  final Traguardo traguardo;
  final Sentiero sentiero;
  final DiarioDelCammino diario;
  final Tier piano;
  final bool evidenziato;
  final VoidCallback? suTocco;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // I CINQUE STATI, chiesti al dato invece di combinati a mente qui.
    //
    // **Ordine P voce 21.** Erano tre booleani, quindi otto combinazioni di cui
    // quattro senza senso, e nessuno poteva enumerarle per verificare che
    // nessuna lasciasse una casella grigia dopo un traguardo raggiunto. Adesso
    // lo stato e' un dato solo, e `test/il_sigillo_non_lascia_buchi_test.dart`
    // li attraversa tutti e cinque.
    final stato = StatoDeiSigilli.di(
      raggiunto: diario.eAcceso(traguardo.id),
      condiviso: diario.eStatoCondiviso(traguardo.id),
      bloccato: Sentieri.chiedeIlTier(traguardo) && piano == Tier.free,
      eIlProssimo: diario.prossimoDi(sentiero)?.id == traguardo.id,
    );
    final acceso = stato.acceso;
    final prossimo = stato == StatoDelSigillo.prossimo;
    final bloccato = stato == StatoDelSigillo.bloccato;

    // Il Sigillo si accende al RAGGIUNGIMENTO, sempre: la condivisione governa
    // solo il bonus, e chi non condivide non vede buchi.
    //
    // UNA SOLA OPACITA', quella del colore. La riga non e' piu' avvolta in un
    // Opacity: era la seconda, e le due si moltiplicavano.
    final colore = acceso
        ? palette.goldSoft
        : prossimo
            ? palette.goldSoft
                .withValues(alpha: SogliaDelLeggibile.alfaDelProssimo)
            : ColorTokens.textSecondary
                .withValues(alpha: SogliaDelLeggibile.alfaDelloSpento);

    final sottotitolo = acceso
        ? traguardo.frase
        : bloccato
            ? 'Dal Tier 1 in su'
            : '${traguardo.posizione} di 50';

    return InkWell(
      key: Key('gradino_${traguardo.id}'),
      // OGNI SIGILLO ACCESO E' TOCCABILE, voce 2e: riapre la sua card e la si
      // puo' condividere anche settimane dopo, incassando il bonus rimasto in
      // sospeso. Nessun traguardo raggiunto resta senza una via per
      // condividerlo. E ogni riga, in qualunque stato, evidenzia il suo punto
      // dentro il disegno: e' il verso di ritorno del legame di voce 33.
      onTap: () {
        suTocco?.call();
        if (acceso) {
          mostraLaCardDelTraguardo(context,
              traguardo: traguardo, sentiero: sentiero);
        } else if (bloccato) {
          showUpgradeInvite(
            context,
            title: 'Il cammino continua dal Tier 1',
            message: 'I primi venti traguardi di ogni sentiero sono di tutti. '
                'Dal ventunesimo il cammino prosegue con l\'Iniziato: gli Eos '
                'che hai già preso restano tuoi per sempre.',
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.sm, vertical: SpacingTokens.sm),
        decoration: evidenziato
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                border:
                    Border.all(color: palette.gold.withValues(alpha: 0.55)),
              )
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IL LUCCHETTO SOLO DOVE C'E' DAVVERO UN BLOCCO: in Demo non ce
            // n'e' nessuno, e un sentiero pieno di lucchetti diceva "chiuso" a
            // chi poteva percorrerlo tutto. Visto sull'anteprima, non
            // ragionato.
            Padding(
              padding: const EdgeInsets.only(top: 2),
              // LA PULSAZIONE LENTA DEL SOSPESO, ordine P voce 21: il Sigillo
              // acceso che ha ancora un bonus da dare respira piano. Con Riduci
              // Movimento resta fermo e acceso, e la marcatura accanto al nome
              // continua a dire che c'e' qualcosa in attesa: il contenuto non
              // si toglie mai.
              child: _SigilloPulsante(
                pulsa: stato.pulsa &&
                    !MediaQuery.of(context).disableAnimations,
                child: Icon(
                  acceso
                      ? Icons.auto_awesome
                      : bloccato
                          ? Icons.lock_outline_rounded
                          : Icons.radio_button_unchecked,
                  color: colore,
                ),
              ),
            ),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(traguardo.nome,
                      key: Key('gradino_nome_${traguardo.id}'),
                      style: TypographyTokens.titoloScheda()
                          .copyWith(color: colore)),
                  // LA MARCATURA DEL SOSPESO: dice che il bonus c'e' ancora.
                  if (stato.marcatura != null)
                    Padding(
                      // I VUOTI PASSANO DAI TOKEN, anche i piccoli: il
                      // censimento degli spazi e' a cricchetto e puo' solo
                      // scendere, quindi una marcatura nuova non ha il diritto
                      // di portarsi dietro due misure scritte a mano.
                      padding: const EdgeInsets.only(top: SpacingTokens.xxs),
                      child: Container(
                        key: Key('gradino_sospeso_${traguardo.id}'),
                        padding: const EdgeInsets.symmetric(
                            horizontal: SpacingTokens.xs,
                            vertical: SpacingTokens.xxs),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(SpacingTokens.radiusPill),
                          border: Border.all(
                              color: palette.gold.withValues(alpha: 0.55)),
                        ),
                        child: Text(stato.marcatura!,
                            style: TypographyTokens.didascalia()
                                .copyWith(color: palette.goldSoft)),
                      ),
                    ),
                  const SizedBox(height: 2),
                  // NIENTE maxLines, ordine P voce 39. Sul gradino acceso si
                  // leggeva "Tre gettate di rune: le pietre hanno imparato il
                  // peso della" e finiva li': la frase era piu' lunga di due
                  // righe e veniva troncata senza puntini, a meta' di un
                  // gruppo di parole. Una frase tagliata a meta' e' una frase
                  // non scritta, e i puntini l'avrebbero solo nascosta: qui lo
                  // spazio si adatta alla frase.
                  Text(
                    sottotitolo,
                    key: Key('gradino_frase_${traguardo.id}'),
                    style: TypographyTokens.didascalia().copyWith(
                      color: ColorTokens.textSecondary.withValues(
                          alpha: acceso || prossimo
                              ? 1.0
                              : SogliaDelLeggibile.alfaDelloSpento),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text('${traguardo.eos}',
                  style:
                      TypographyTokens.etichetta().copyWith(color: colore)),
            ),
          ],
        ),
      ),
    );
  }
}

/// IL SIGILLO CHE RESPIRA, quando ha ancora un bonus da dare.
///
/// Ordine P voce 21. Una pulsazione lenta, tre secondi per giro: piu' veloce
/// sarebbe un avviso, e un avviso su cinquanta righe diventa un fastidio.
class _SigilloPulsante extends StatefulWidget {
  const _SigilloPulsante({required this.pulsa, required this.child});

  final bool pulsa;
  final Widget child;

  @override
  State<_SigilloPulsante> createState() => _SigilloPulsanteState();
}

class _SigilloPulsanteState extends State<_SigilloPulsante>
    with SingleTickerProviderStateMixin {
  AnimationController? _motore;

  @override
  void initState() {
    super.initState();
    if (widget.pulsa) {
      _motore = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _motore?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motore = _motore;
    if (motore == null) return widget.child;
    return FadeTransition(
      opacity: Tween<double>(begin: 0.55, end: 1).animate(motore),
      child: widget.child,
    );
  }
}
