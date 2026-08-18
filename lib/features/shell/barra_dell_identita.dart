import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/identity/profile_controller.dart';
import '../../design_system/components/borsellino.dart';
import '../../design_system/components/porta_dell_account.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'barra_del_cerchio.dart';

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

  /// L'ALTEZZA APERTA: la barra scende e il contenuto si ingrandisce, per
  /// essere piu' leggibile. **Tarata MISURANDO, ordine AN voce 02**: a 66
  /// punti le tre righe del cielo che viene traboccavano di 43, perche' tre
  /// righe di didascalia occupano da sole una sessantina di punti. Qui ci
  /// stanno intere col loro respiro, e la barra resta una fascia che scende
  /// di poco, non un pannello.
  static const double altezzaAperta = 88;

  /// Quanto dura la discesa. Con Riduci Movimento il passaggio e' secco.
  static const Duration discesa = Duration(milliseconds: 260);

  /// Dove NON si vede: le soglie del Risveglio, dove la persona non ha
  /// ancora ne' volto ne' saldo ne' cielo, e una barra dell'identita' sopra
  /// il rito d'ingresso sarebbe una promessa vuota.
  static const Set<String> soglie = {
    'OnboardingScreen',
    'MaestroRevealScreen',
    'ArtIntroScreen',
  };

  static bool siVede(String? schermata) => !soglie.contains(schermata);

  @override
  State<BarraDellIdentita> createState() => _BarraDellIdentitaState();
}

class _BarraDellIdentitaState extends State<BarraDellIdentita> {
  String? _schermata;
  bool _aperta = false;

  @override
  void initState() {
    super.initState();
    widget.observatore.cambi.addListener(_pilaCambiata);
    _pilaCambiata();
  }

  @override
  void dispose() {
    widget.observatore.cambi.removeListener(_pilaCambiata);
    super.dispose();
  }

  void _pilaCambiata() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cima = widget.observatore.schermataInCima();
      if (cima == _schermata) return;
      // Cambiando schermata la barra torna sottile: l'apertura apparteneva
      // alla lettura di prima.
      setState(() {
        _schermata = cima;
        _aperta = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final siVede = BarraDellIdentita.siVede(_schermata);
    final altezza = _aperta
        ? BarraDellIdentita.altezzaAperta
        : BarraDellIdentita.altezzaChiusa;
    final quantoOccupa = siVede ? altezza : 0.0;
    final durata =
        mq.disableAnimations ? Duration.zero : BarraDellIdentita.discesa;

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
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: _LaBarra(
              altezza: altezza,
              aperta: _aperta,
              durata: durata,
              suTocco: () => setState(() => _aperta = !_aperta),
              suChiusura: () => setState(() => _aperta = false),
            ),
          ),
      ],
    );
  }
}

class _LaBarra extends StatelessWidget {
  const _LaBarra({
    required this.altezza,
    required this.aperta,
    required this.durata,
    required this.suTocco,
    required this.suChiusura,
  });

  final double altezza;
  final bool aperta;
  final Duration durata;
  final VoidCallback suTocco;
  final VoidCallback suChiusura;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final palette = MaestroScope.forse(context) ?? MaestroPalette.neutral;
    // Le misure del contenuto: sottile a riposo, leggibile da aperta.
    final volto = aperta ? 40.0 : 22.0;

    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: suTocco,
        child: AnimatedContainer(
          key: const Key('barra_dell_identita'),
          duration: durata,
          curve: Curves.easeOut,
          // La fascia occupa anche l'area sicura di sistema: sta SOTTO
          // l'orologio del telefono e non ci finisce mai sopra.
          padding: EdgeInsets.only(top: mq.padding.top),
          height: altezza + mq.padding.top,
          decoration: BoxDecoration(
            // Un velo di colore, mai una sfocatura per fotogramma.
            color: palette.deepest.withValues(alpha: aperta ? 0.92 : 0.72),
            border: Border(
              bottom: BorderSide(
                  color: palette.goldSoft.withValues(alpha: 0.22)),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: SpacingTokens.sm),
              // 1. IL VOLTO E IL NOME, ordine AN voce 02: chi apre l'app si
              // vede riconosciuto. Senza nome resta il solo volto, mai un
              // segnaposto.
              _VoltoENome(
                misura: volto,
                aperta: aperta,
                suTocco: aperta ? NavigazioneDellaBarra.allAccount : suTocco,
              ),
              // 2. LA PORTA DEGLI EVENTI COSMICI.
              //
              // **IL TOCCO PORTA AL CALENDARIO SEMPRE, chiusa o aperta che
              // sia la barra, ordine AO voce 01.** Prima il primo tocco da
              // chiusa apriva soltanto la barra, per la regola dell'ordine
              // AM voce 04 che diceva di non portare via da dove si sta: ma
              // quella regola nasceva quando qui c'era una NOTIZIA da
              // leggere in grande, e una notizia si ingrandisce mentre una
              // porta si attraversa. Adesso al centro c'e' una porta col suo
              // nome scritto sopra, e una porta che al primo tocco fa
              // qualcos'altro insegna a non fidarsi del proprio dito.
              Expanded(
                child: _PortaDegliEventiCosmici(
                  aperta: aperta,
                  suTocco: () {
                    suChiusura();
                    NavigazioneDellaBarra.alCalendario();
                  },
                ),
              ),
              // 3. IL BORSELLINO, moneta d'oro e saldo.
              SegnoDelBorsellino(
                compatta: !aperta,
                monetaDOro: true,
                senzaVeste: true,
                contestoDelFoglio: aperta
                    ? NavigazioneDellaBarra.contestoDelNavigatore
                    : null,
                suTocco: aperta ? null : suTocco,
              ),
              const SizedBox(width: SpacingTokens.sm),
            ],
          ),
        ),
      ),
    );
  }
}

/// IL VOLTO E IL NOME PROPRIO. Ordine AN voce 02.
///
/// Il nome viene dal profilo, che e' la porta dove il nome vive gia'
/// normalizzato: qui non si normalizza una seconda volta. Se il nome non
/// c'e' ancora resta il solo volto: un segnaposto direbbe che manca
/// qualcosa senza dire cosa fare, e il posto per darlo e' l'account, che
/// questo stesso volto apre.
class _VoltoENome extends StatelessWidget {
  const _VoltoENome({
    required this.misura,
    required this.aperta,
    required this.suTocco,
  });

  final double misura;
  final bool aperta;
  final VoidCallback suTocco;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroScope.forse(context) ?? MaestroPalette.neutral;
    String? nome;
    try {
      nome = context.watch<ProfileController>().profile.displayName;
    } catch (errore) {
      // Senza il profilo nell'albero, come in una prova che monta una scena
      // da sola, resta il solo volto.
      nome = null;
    }
    final pulito = (nome ?? '').trim();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PortaDellAccount(misura: misura, suTocco: suTocco),
        if (pulito.isNotEmpty) ...[
          const SizedBox(width: 6),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: suTocco,
            child: ConstrainedBox(
              // Il nome non ruba il posto all'evento: e' un saluto, non un
              // titolo. Oltre questa larghezza si accorcia con garbo.
              // Il nome cede spazio al cielo: da chiusa il centro deve
              // poter dire "Saturno retrogrado, oggi" per intero, e
              // guardando l'anteprima con 78 punti si troncava.
              constraints: BoxConstraints(maxWidth: aperta ? 120 : 56),
              child: Text(
                pulito,
                key: const Key('barra_nome_proprio'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.goldSoft),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

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
  const _PortaDegliEventiCosmici(
      {required this.aperta, required this.suTocco});

  final bool aperta;
  final VoidCallback suTocco;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroScope.forse(context) ?? MaestroPalette.neutral;
    return GestureDetector(
      key: const Key('barra_eventi_cosmici'),
      behavior: HitTestBehavior.opaque,
      onTap: suTocco,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xs),
        // La scritta si adatta invece di troncarsi: su uno schermo stretto
        // "Eventi Cosmici" tagliato a meta' sarebbe una porta senza nome.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Eventi Cosmici',
            maxLines: 1,
            textAlign: TextAlign.center,
            style: (aperta
                    ? TypographyTokens.titoloScheda()
                    : TypographyTokens.etichetta())
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
