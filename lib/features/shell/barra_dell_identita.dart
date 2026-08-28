import 'package:flutter/material.dart';

import '../sigilli/celebrazione.dart';

import '../../design_system/components/borsellino.dart';
import '../../design_system/components/porta_dell_account.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'barra_del_cerchio.dart';
import 'dove_si_vede_la_barra.dart';

/// LA BARRA SOTTILE DELL'IDENTITA', CASA UNICA. Ordine AM voce 04, forma
/// decisa da Mauro dal collaudo della 2180.
///
/// Una fascia sottile e persistente in alto, sotto la barra di stato e sopra
/// il Navigator, con quattro cose in fila: la porta dell'account col volto,
/// il borsellino con la moneta d'oro e il saldo, il segno zodiacale in
/// miniatura e l'Ascendente. Al tocco scende e ingrandisce il contenuto, per
/// leggerlo meglio; un secondo tocco la richiude.
///
/// **E' LA CASA UNICA di quelle quattro cose**: volto, saldo, segno e
/// Ascendente non compaiono in nessun altro punto dell'app, e una prova
/// enumera i sorgenti e cade se una copia ricompare. E' la regola delle due
/// porte applicata alla scena, la stessa che ha tolto la pillola dalle
/// testate.
///
/// **La capsula, che stava qui prima, se n'e' andata** con la voce 03: era
/// un blocco in alto a destra e Mauro l'ha voluta via subito.
class BarraDellIdentita extends StatefulWidget {
  const BarraDellIdentita({
    super.key,
    required this.observatore,
    required this.child,
  });

  final OsservatoreDellaPila observatore;
  final Widget child;

  /// **L'ALTEZZA A RIPOSO, sottile.** Le schermate le fanno spazio come lo
  /// fanno alla barra di stato: si aggiunge al padding alto, cosi' ogni
  /// SafeArea gia' scritto ne tiene conto da solo e nessuna testata finisce
  /// coperta. E' una misura che descrive una resa, e la prova la confronta
  /// con l'altezza vera.
  static const double altezzaChiusa = 30;



  /// **DOVE SI VEDE, e l'elenco non sta piu' qui. Ordine AP voce 07.**
  ///
  /// Le soglie vivevano dentro questo file, e la barra storica aveva il suo
  /// elenco in `dove_si_vede_la_barra.dart`: due elenchi in due posti per la
  /// stessa domanda, "dove si vede questa barra". Adesso la casa e' una, e
  /// chi cerca la risposta la trova dove gia' guardava.
  static bool siVede(String? schermata) => barraSottileSiVede(schermata);

  @override
  State<BarraDellIdentita> createState() => _BarraDellIdentitaState();
}

class _BarraDellIdentitaState extends State<BarraDellIdentita> {
  String? _schermata;

  /// **LA BARRA SPARISCE DURANTE UNA FESTA. Ordine BX voce 07.**
  ///
  /// Questa barra sta SOPRA il Navigator, quindi si dipinge su ogni rotta,
  /// compresa la celebrazione: il velo della festa, per quanto fitto, non la
  /// puo' coprire perche' non le sta davanti. Il fondatore ha letto
  /// "Eventi Cosmici" sopra quattro schermate di festa e l'ha presa per
  /// l'intestazione della festa stessa: ci ha scritto sopra un ordine intero,
  /// su una famiglia di traguardi che non esiste.
  ///
  /// Durante una festa si vede la festa e nient'altro.
  bool _festaInScena = false;

  @override
  void initState() {
    super.initState();
    widget.observatore.cambi.addListener(_pilaCambiata);
    // **E ANCHE LE FESTE, ordine BX voce 07**: una festa puo' entrare in scena
    // senza che la pila delle schermate cambi, e la barra deve sparire lo
    // stesso.
    FesteInCorso.cambi.addListener(_pilaCambiata);
    _pilaCambiata();
  }

  @override
  void dispose() {
    widget.observatore.cambi.removeListener(_pilaCambiata);
    FesteInCorso.cambi.removeListener(_pilaCambiata);
    super.dispose();
  }

  void _pilaCambiata() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cima = widget.observatore.schermataInCima();
      final festa = FesteInCorso.unaCeGia;
      if (cima == _schermata && festa == _festaInScena) return;
      // Cambiando schermata la barra torna sottile: l'apertura apparteneva
      // alla lettura di prima. E' la via 2 e la via 4 del ritiro.
      setState(() {
        _schermata = cima;
        _festaInScena = festa;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final siVede =
        BarraDellIdentita.siVede(_schermata) && !_festaInScena;
    // **UN SOLO STATO, ordine AR voce 10.** La barra non si apre piu': era
    // alta 30 punti a riposo e 66 da aperta, e il primo tocco serviva ad
    // aprirla invece che a portare da qualche parte. Decisione di Mauro del
    // 19 agosto 2026, che supera due sue decisioni precedenti (l'ordine AN
    // voce 02 sul nome accanto al volto e l'ordine AO voce 02 sul ritiro
    // automatico): tutto e' gia' abbastanza chiaro e toccabile senza
    // ingrandire, e i tre eventi che la barra aperta mostrava vivono nel
    // Calendario, che e' la loro casa.
    //
    // **Sono spariti anche i due ascoltatori sopra l'app**, che servivano
    // solo a ritirarla: senza uno stato aperto non c'e' piu' niente da
    // ritirare, e ogni tocco e ogni scorrimento dell'app smettono di passare
    // da qui.
    final quantoOccupa = siVede ? BarraDellIdentita.altezzaChiusa : 0.0;

    return Stack(
      children: [
        // **LE SCHERMATE LE FANNO SPAZIO**, esattamente come alla barra di
        // stato: si somma al padding alto e ogni SafeArea la rispetta senza
        // saperlo. Nessuna testata finisce coperta.
        MediaQuery(
          data: mq.copyWith(
            padding: mq.padding.copyWith(top: mq.padding.top + quantoOccupa),
            viewPadding:
                mq.viewPadding.copyWith(top: mq.viewPadding.top + quantoOccupa),
          ),
          child: widget.child,
        ),
        if (siVede)
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: _LaBarra(),
          ),
      ],
    );
  }
}

class _LaBarra extends StatelessWidget {
  const _LaBarra();

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final palette = MaestroScope.forse(context) ?? MaestroPalette.neutral;

    return Material(
      type: MaterialType.transparency,
      child: Container(
        key: const Key('barra_dell_identita'),
        // La fascia occupa anche l'area sicura di sistema: sta SOTTO
        // l'orologio del telefono e non ci finisce mai sopra.
        padding: EdgeInsets.only(top: mq.padding.top),
        height: BarraDellIdentita.altezzaChiusa + mq.padding.top,
        decoration: BoxDecoration(
          // Un velo di colore, mai una sfocatura per fotogramma.
          color: palette.deepest.withValues(alpha: 0.72),
          border: Border(
            bottom:
                BorderSide(color: palette.goldSoft.withValues(alpha: 0.22)),
          ),
        ),
        child: const Row(
          children: [
            SizedBox(width: SpacingTokens.sm),
            // 1. IL VOLTO, e SOLO il volto. Ordine AR voce 10: il nome e'
            // uscito dalla barra, perche' con un nome lungo si sovrapponeva
            // al resto. Chi sono lo dice il volto, che e' anche la porta
            // dell'account.
            _AreaDiTocco(
              chiave: Key('barra_volto'),
              // **AL PRIMO TOCCO SI VA ALL'ACCOUNT.** Prima il volto apriva
              // la barra e solo da aperta portava all'account.
              suTocco: NavigazioneDellaBarra.allAccount,
              // **IL VOLTO RICEVE LA VIA DALL'OSSERVATORE.** La barra vive
              // nel `builder` di `MaterialApp`, che AVVOLGE il Navigator:
              // qui dentro `Navigator.of(context)` non trova niente, quindi
              // il volto non puo' usare la sua via di casa e riceve quella
              // che passa dall'osservatore della pila.
              child: PortaDellAccount(
                misura: 22,
                suTocco: NavigazioneDellaBarra.allAccount,
              ),
            ),
            // 2. LA PORTA DEGLI EVENTI COSMICI, che porta al Calendario al
            // PRIMO tocco.
            Expanded(child: _PortaDegliEventiCosmici()),
            // 3. IL BORSELLINO, moneta d'oro e saldo, che apre il borsellino
            // al primo tocco.
            _AreaDiTocco(
              chiave: Key('barra_borsellino'),
              suTocco: null,
              child: SegnoDelBorsellino(
                compatta: true,
                monetaDOro: true,
                senzaVeste: true,
                contestoDelFoglio:
                    NavigazioneDellaBarra.contestoDelNavigatore,
              ),
            ),
            SizedBox(width: SpacingTokens.sm),
          ],
        ),
      ),
    );
  }
}

/// **L'AREA DI TOCCO E' PIENA ANCHE SE LA BARRA E' SOTTILE. Ordine AR voce
/// 10.** Trenta punti di altezza non bastano per un dito: si allarga l'area
/// INVISIBILE del bersaglio, non la barra. Il riquadro sale e scende oltre il
/// bordo della fascia senza disegnare niente, quindi il tocco e' comodo e la
/// barra resta sottile.
class _AreaDiTocco extends StatelessWidget {
  const _AreaDiTocco({
    required this.chiave,
    required this.child,
    this.suTocco,
  });

  final Key chiave;
  final Widget child;
  final VoidCallback? suTocco;

  /// **QUANTO SI PUO' ALLARGARE, e perche' non di piu'.** In larghezza si
  /// allarga quanto serve; in altezza il bersaglio prende tutta la barra e
  /// non un punto di piu': sotto la fascia comincia il contenuto della
  /// schermata, e un bersaglio piu' alto gli ruberebbe i tocchi, che e' un
  /// difetto peggiore di un bersaglio corto.
  static const double larghezzaMinima = 44;

  @override
  Widget build(BuildContext context) {
    // **UNA LARGHEZZA MINIMA, non una larghezza fissa**, e la differenza
    // l'ha trovata l'anteprima col saldo a quattro cifre: con `width` fisso
    // il borsellino sbordava di ventisette pixel, perche' "9999" chiede piu'
    // spazio di un bersaglio comodo. Il minimo serve a chi e' piccolo, e chi
    // e' grande resta com'e'.
    final dentro = ConstrainedBox(
      constraints: const BoxConstraints(minWidth: larghezzaMinima),
      child: SizedBox(
        height: double.infinity,
        child: Center(child: child),
      ),
    );
    if (suTocco == null) {
      return KeyedSubtree(key: chiave, child: dentro);
    }
    return GestureDetector(
      key: chiave,
      behavior: HitTestBehavior.opaque,
      onTap: suTocco,
      child: dentro,
    );
  }
}

/// **IL NOME E' USCITO DALLA BARRA. Ordine AR voce 10.**
///
/// Qui viveva `_VoltoENome`, che accanto al volto scriveva il nome proprio
/// (ordine AN voce 02). Mauro lo ha tolto il 19 agosto 2026, e la ragione e'
/// misurabile: con un nome lungo la riga si sovrapponeva al resto, e in una
/// fascia da trenta punti non c'e' spazio per un saluto e una porta insieme.
/// Chi sei lo dice il volto, che resta ed e' anche la porta dell'account.
///
/// La classe non c'e' piu': tenerla morta avrebbe fatto credere che il nome
/// possa tornare con un flag, mentre e' una decisione.

/// LA PORTA DEGLI EVENTI COSMICI: una scritta sola, sempre quella.
///
/// **Cosa c'era prima, e perche' se n'e' andato. Ordine AO voce 01.** Qui
/// stava il PROSSIMO EVENTO col conto alla rovescia, una riga da chiusa e
/// tre da aperta, prese dal motore della voce AN.01. Dal collaudo della 2182
/// Mauro ha deciso che il centro della barra e' una PORTA e non un
/// bollettino: una notizia che cambia da sola, dentro una fascia alta trenta
/// punti, si legge male e cambia sotto gli occhi mentre la si guarda.
///
/// **Il conto alla rovescia non e' stato cancellato, e' tornato a casa sua**:
/// il Calendario degli Eventi lo mostra per ogni evento, con la data e il
/// "fra quanto", nello spazio giusto per leggerlo. E il motore
/// `ProssimiEventi` resta intero: serve al Calendario, ai promemoria e ai
/// Maestri, e buttarlo perche' la barra non lo usa piu' vorrebbe dire buttare
/// il calcolo insieme alla sua vetrina.
///
/// **La scritta e' la stessa da chiusa e da aperta.** Da aperta cresce, come
/// tutto il resto della barra, ma non diventa un'altra cosa: chi ha imparato
/// dove si tocca lo ritrova dov'era.
class _PortaDegliEventiCosmici extends StatelessWidget {
  const _PortaDegliEventiCosmici();

  @override
  Widget build(BuildContext context) {
    final palette = MaestroScope.forse(context) ?? MaestroPalette.neutral;
    return GestureDetector(
      key: const Key('barra_eventi_cosmici'),
      behavior: HitTestBehavior.opaque,
      // **AL PRIMO TOCCO SI VA AL CALENDARIO, ordine AR voce 10.** Non c'e'
      // piu' nessuna apertura da consumare prima.
      onTap: NavigazioneDellaBarra.alCalendario,
      child: Container(
        // **IL BERSAGLIO PRENDE TUTTA L'ALTEZZA DELLA BARRA**, ordine AR
        // voce 10: la scritta e' alta diciotto punti, e un bersaglio alto
        // quanto la scritta chiede al dito una mira che nessuno ha.
        alignment: Alignment.center,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xs),
        // La scritta si adatta invece di troncarsi: su uno schermo stretto
        // "Eventi Cosmici" tagliato a meta' sarebbe una porta senza nome.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Eventi Cosmici',
            maxLines: 1,
            textAlign: TextAlign.center,
            style: TypographyTokens.etichetta()
                .copyWith(color: palette.goldSoft),
          ),
        ),
      ),
    );
  }
}

/// **IL SEGNO E L'ASCENDENTE NON VIVONO PIU' QUI, ordine AN voce 02**, per
/// decisione di Mauro dal collaudo della 2181: il centro della barra
/// appartiene al cielo che viene, e il segno con l'Ascendente si leggono nel
/// Passaporto, dove stanno insieme al resto dell'identita'. Il componente
/// `_SegnoEAscendente` e' stato tolto invece di essere lasciato spento: un
/// widget che nessuno monta e' codice che mente sulla scena.
