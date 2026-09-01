import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../core/maestro/maestro.dart';
import '../../core/permissions/app_permission.dart';
import '../../core/permissions/esito_del_permesso.dart';
import '../../core/rituals/avvisi_del_rito.dart';
import '../../core/rituals/daily_elements.dart';
import '../../core/rituals/scelta_degli_avvisi.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../services/avvisi_locali.dart';
import '../../services/regia_delle_chiamate.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';

/// IL MENU' DELLE NOTIFICHE: CINQUE ORARI, CINQUE INTERRUTTORI.
/// Ordine BC voce 05.
///
/// **Parole del fondatore, maiuscole sue**: "BISOGNA ATTIVARE LE NOTIFICHE
/// VERAMENTE e ne voglio 5, ovvero una per ogni dono con orario che avevamo
/// gia' concordato. Sara' proprio l'utente che potra' gestire e attivare o
/// disattivare i singoli orari delle notifiche nel menu' notifiche."
///
/// **Cosa c'era prima.** La voce Notifiche dell'account chiedeva il permesso e
/// programmava tutto insieme: un solo interruttore per tutto, e per spegnere
/// una sola chiamata bisognava uscire dall'app e cercarne il canale nelle
/// impostazioni di Android. Adesso i cinque appuntamenti si accendono e si
/// spengono qui, ognuno per conto suo, **con la sua ora scritta accanto**.
///
/// **Il permesso di sistema resta il primo cancello**, e la schermata lo dice
/// invece di far finta che gli interruttori bastino: senza permesso nessun
/// avviso parte, e in cima compare la riga che porta a concederlo.
class NotificheScreen extends StatefulWidget {
  const NotificheScreen({super.key, this.avvisi});

  /// **LA PORTA DEGLI AVVISI, iniettabile solo nelle prove.**
  ///
  /// L'app vera usa `avvisiDelCerchio`, come tutto il resto. Le prove ne
  /// passano una finta, perche' senza porta disponibile gli interruttori
  /// restano spenti **ed e' giusto che lo siano**: una levetta che si muove
  /// mentre il telefono non lascia arrivare niente e' peggio di una levetta
  /// ferma. E' la stessa iniezione che usa gia' il Rito dell'Alba.
  final ServizioAvvisi? avvisi;

  static Route<void> route() =>
      PassaggioDelCerchio.rotta<void>((_) => const NotificheScreen());

  @override
  State<NotificheScreen> createState() => _NotificheScreenState();
}

class _NotificheScreenState extends State<NotificheScreen> {
  /// Nullo finche' non si sa: si chiede al sistema una volta sola, all'avvio
  /// della schermata, e non a ogni ridisegno.
  bool? _permesso;

  @override
  void initState() {
    super.initState();
    _guardaIlPermesso();
  }

  ServizioAvvisi get _porta => widget.avvisi ?? avvisiDelCerchio;

  /// **QUANTE CHIAMATE SONO DAVVERO IN CODA SUL TELEFONO. Ordine CF voce
  /// 04.** Nullo finche' non si e' guardato.
  List<int>? _inCoda;

  /// Vero mentre si sta guardando, cosi' il tocco non si ripete a vuoto.
  bool _sistoGuardando = false;

  /// L'esito dell'ultima prova immediata, da dire a video.
  String? _esitoDellaProva;

  Future<void> _contaLaCoda() async {
    final porta = _porta;
    if (!porta.disponibile) return;
    setState(() => _sistoGuardando = true);
    final coda = await porta.inAttesa();
    if (!mounted) return;
    setState(() {
      _inCoda = coda;
      _sistoGuardando = false;
    });
  }

  Future<void> _provaAdesso() async {
    final porta = _porta;
    if (!porta.disponibile) return;
    await porta.mostraAdesso(
      titolo: 'Prova del Cerchio',
      testo: 'Se leggi questo, il canale funziona.',
    );
    if (!mounted) return;
    setState(() => _esitoDellaProva =
        'Mandata adesso. Se non compare nella tenda del telefono, il '
            'problema è nel sistema e non nel Cerchio.');
  }

  Future<void> _guardaIlPermesso() async {
    final porta = _porta;
    final ok = porta.disponibile && await porta.permessoConcesso();
    if (mounted) setState(() => _permesso = ok);
  }

  /// **SI SPIEGA PRIMA DI CHIEDERE, e non e' cortesia: e' la regola di casa.**
  ///
  /// La prima stesura di questa schermata chiamava dritto il permesso di
  /// sistema, e **l'ha presa la prova che enumera i punti dove l'app chiede
  /// qualcosa**: sono sei, e ognuno passa dal foglio che dice cosa si riceve
  /// prima che il sistema chieda. Un permesso chiesto senza spiegazione si
  /// nega, e su Android si nega **per sempre** dopo due volte.
  Future<void> _chiediIlPermesso() async {
    final porta = _porta;
    if (!porta.disponibile) return;
    await AvvisiDelRito.segnaChiesto();
    if (!mounted) return;
    final ok = await requestPermissionWithPrelude(
      context,
      permission: AppPermission.notifications,
      palette: MaestroPalette.forKey(const ThemeKey.of(Maestro.medora)),
      copy: const PermissionCopy(
        icon: Icons.notifications_active_rounded,
        title: 'Posso chiamarti quando è l\'ora?',
        body: AvvisiDelRito.spiegazione,
        cta: 'Sì, avvisami',
      ),
      // LA PORTA UNICA DEI TRE ESITI, la stessa del Rito dell'Alba: il plugin
      // sa dire solo si' o no, e la porta ricava il no per sempre dal fatto
      // che il dialogo di sistema compare una volta sola.
      systemRequest: () async {
        final esito = await PortaDelPermesso.chiedi(
          AppPermission.notifications,
          richiestaDiSistema: porta.chiediPermesso,
        );
        return esito == EsitoDelPermesso.concesso;
      },
    );
    if (!mounted) return;
    setState(() => _permesso = ok);
    if (ok) {
      await _riprogramma();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          key: const Key('notifiche_permesso_negato'),
          content: const Text(
              'Senza il permesso del telefono non posso avvisarti. Puoi '
              'darmelo dalle impostazioni quando vuoi.'),
          action: SnackBarAction(
            label: 'Impostazioni',
            onPressed: () => Geolocator.openAppSettings(),
          ),
        ),
      );
    }
  }

  /// **OGNI TOCCO RIPROGRAMMA SUBITO, e non a un'uscita che nessuno fa.**
  ///
  /// Un interruttore che scrive una preferenza e lascia l'agenda com'era
  /// mente due volte: dice acceso e non chiama, oppure dice spento e chiama lo
  /// stesso. Qui si riscrive l'agenda a ogni tocco, e la riga sotto dice
  /// quanti appuntamenti ci sono davvero.
  Future<void> _riprogramma() async {
    final quante =
        await RegiaDelleChiamate.riprogramma(context, servizio: widget.avvisi);
    if (mounted) setState(() => _inAgenda = quante.length);
  }

  int? _inAgenda;

  /// **CAMBIA L'ORA DI UN DONO.** Ordine BC voce 05, coda.
  ///
  /// Richiesta del fondatore: "nel menu' notifiche, l'utente deve poter
  /// cambiare anche l'orario di ogni notifica."
  ///
  /// Si apre l'orologio di sistema, quello che la persona conosce gia' da
  /// tutte le altre app: un selettore fatto in casa sarebbe una cosa nuova da
  /// imparare per scegliere un'ora.
  Future<void> _cambiaLOra(DailyElement dono, SceltaDegliAvvisi scelta) async {
    final adesso = scelta.oraDi(dono);
    final scelto = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: adesso.ora, minute: adesso.minuto),
      helpText: 'A che ora ti chiama ${dono.title}?',
      cancelText: 'Lascia com\'è',
      confirmText: 'Va bene',
    );
    if (scelto == null || !mounted) return;
    await scelta.scegliLOra(dono, ora: scelto.hour, minuto: scelto.minute);
    if (!mounted) return;
    // **L'AGENDA SI RISCRIVE SUBITO**, come per l'interruttore: un'ora
    // cambiata che lascia la vecchia chiamata in coda direbbe una cosa e ne
    // farebbe un'altra.
    await _riprogramma();
    if (!mounted) return;
    // **E SI PUO' TORNARE INDIETRO.** Chi sposta un'ora per prova deve poter
    // rimettere quella di casa senza doverla ricordare a memoria.
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      key: const Key('notifiche_ora_cambiata'),
      content: Text('${dono.title} ti chiamerà alle '
          '${scelto.hour.toString().padLeft(2, '0')}:'
          '${scelto.minute.toString().padLeft(2, '0')}.'),
      action: SnackBarAction(
        label: 'Rimetti ${AvvisiDelRito.oraDetta(dono)}',
        onPressed: () async {
          await scelta.rimettiLOraDiCasa(dono);
          if (mounted) await _riprogramma();
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final scelta = context.watch<SceltaDegliAvvisi>();
    final accesi = DailyElement.values.where(scelta.chiama).length;

    return MaestroScope(
      maestro: Maestro.medora,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: palette.goldSoft),
          title: Text('Notifiche',
              style: TypographyTokens.titoloScheda()
                  .copyWith(color: palette.goldSoft)),
        ),
        body: CosmosBackground(
          seed: 11,
          showZodiac: false,
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(SpacingTokens.lg),
              children: [
                Text(
                  'I Doni del giorno hanno ciascuno la sua ora. Scegli quali '
                  'ti chiamano. Gli altri restano lì: li apri quando vuoi.',
                  key: const Key('notifiche_intro'),
                  style: TypographyTokens.corpo()
                      .copyWith(color: ColorTokens.textSecondary),
                ),
                const SizedBox(height: SpacingTokens.lg),
                if (_permesso == false) ...[
                  _IlPermessoManca(onTocco: _chiediIlPermesso),
                  const SizedBox(height: SpacingTokens.lg),
                ],
                for (final dono in DailyElement.values) ...[
                  _UnAppuntamento(
                    dono: dono,
                    acceso: scelta.chiama(dono),
                    palette: palette,
                    // **Spento del tutto quando il permesso manca**: un
                    // interruttore che si muove senza che arrivi niente e'
                    // peggio di un interruttore fermo.
                    attivabile: _permesso != false,
                    suScelta: (v) async {
                      await scelta.scegli(dono, v);
                      if (mounted) await _riprogramma();
                    },
                    suOra: () => _cambiaLOra(dono, scelta),
                    oraDetta: _comeSiScrive(scelta.oraDi(dono)),
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                ],
                const SizedBox(height: SpacingTokens.md),
                Text(
                  _laRigaDelConto(accesi),
                  key: const Key('notifiche_conto'),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.didascalia()
                      .copyWith(color: ColorTokens.textMuted),
                ),
                const SizedBox(height: SpacingTokens.lg),
                // **LA VIA PER MISURARE, ordine CF voce 04.**
                //
                // **Fatto del fondatore, verbatim**: "da quando ho iniziato
                // a installare le varie build dell'APP NON HO MAI RICEVUTO
                // ALCUNA NOTIFICA PUSH PER I DONI, MAI!"
                //
                // **Da fuori due difetti diversi si vedono uguali**: il
                // Cerchio che non programma niente, e il telefono che non
                // esegue cio' che ha in coda. Il secondo e' una causa nota
                // sui telefoni di certi produttori, che addormentano le
                // chiamate approssimate per risparmiare batteria. Senza un
                // modo di guardare, la diagnosi sarebbe una supposizione.
                //
                // **Qui non si suppone: si contano le chiamate in coda e si
                // prova il canale subito.** Se la prova arriva e le chiamate
                // in coda ci sono, allora quello che manca e' l'esecuzione a
                // tempo, ed e' un fatto da portare al produttore del
                // telefono, non un difetto da cercare nel codice.
                _LaCodaDelTelefono(
                  inCoda: _inCoda,
                  sistoGuardando: _sistoGuardando,
                  esitoDellaProva: _esitoDellaProva,
                  palette: palette,
                  suGuarda: _contaLaCoda,
                  suProva: _provaAdesso,
                ),
                const SizedBox(height: SpacingTokens.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// L'ora in cifre, come si legge nel menu'.
  static String _comeSiScrive(({int ora, int minuto}) q) =>
      '${q.ora.toString().padLeft(2, '0')}:'
      '${q.minuto.toString().padLeft(2, '0')}';

  /// **IL NUMERO VERO, non una promessa.**
  ///
  /// Quando l'agenda e' stata riscritta si dice quanti appuntamenti ci sono
  /// dentro davvero, contati da chi li ha messi. Prima di allora si dice
  /// quanti ne sono accesi, che e' l'altra cosa vera che si sa.
  String _laRigaDelConto(int accesi) {
    if (_permesso == false) {
      return 'Nessun avviso partirà finché il telefono non mi dà il permesso.';
    }
    final n = _inAgenda ?? accesi;
    if (n == 0) return 'Nessun Dono ti chiama.';
    if (n == 1) return 'Un Dono ti chiama.';
    return '$n Doni ti chiamano.';
  }
}

/// La riga che compare quando il permesso di sistema manca.
class _IlPermessoManca extends StatelessWidget {
  const _IlPermessoManca({required this.onTocco});

  final Future<void> Function() onTocco;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DepthCard(
      key: const Key('notifiche_permesso_manca'),
      onTap: onTocco,
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        children: [
          Icon(Icons.notifications_off_rounded, color: palette.goldSoft),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Text(
              'Il telefono non mi lascia ancora avvisarti. Tocca per '
              'concedere il permesso.',
              style: TypographyTokens.corpo()
                  .copyWith(color: ColorTokens.textPrimary),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: palette.goldSoft),
        ],
      ),
    );
  }
}

/// Un Dono, la sua ora, e il suo interruttore.
class _UnAppuntamento extends StatelessWidget {
  const _UnAppuntamento({
    required this.dono,
    required this.acceso,
    required this.palette,
    required this.attivabile,
    required this.suScelta,
    required this.suOra,
    required this.oraDetta,
  });

  /// L'ora che questa riga mostra: quella scelta dalla persona, o quella di
  /// casa se non l'ha mai cambiata.
  final String oraDetta;

  final DailyElement dono;
  final bool acceso;
  final MaestroPalette palette;
  final bool attivabile;
  final Future<void> Function(bool) suScelta;

  /// Il tocco sull'ora: apre l'orologio e la cambia.
  final Future<void> Function() suOra;

  @override
  Widget build(BuildContext context) {
    return DepthCard(
      key: Key('notifiche_dono_${dono.name}'),
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
      // **L'ORA SI ALLINEA COL TITOLO, non col centro della riga.** Visto
      // nell'anteprima: il numero galleggiava a meta' altezza mentre il nome
      // del Dono stava in cima, e le due cose che vanno lette insieme
      // partivano da due righe di base diverse.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // **L'ORA IN CIFRE, e prima di tutto il resto.** E' quello che il
          // fondatore ha chiesto di poter gestire: "i singoli orari delle
          // notifiche".
          // **L'ORA SI TOCCA E SI CAMBIA.** Ordine BC voce 05, coda:
          // richiesta del fondatore, "l'utente deve poter cambiare anche
          // l'orario di ogni notifica".
          //
          // **Si tocca anche col Dono spento**, ed e' voluto: chi vuole
          // l'Arcano alle nove deve poter mettere l'ora prima di accendere,
          // invece di accendere alle tredici e correre a cambiarla.
          InkWell(
            key: Key('notifiche_tocco_ora_${dono.name}'),
            onTap: attivabile ? () => suOra() : null,
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: SpacingTokens.xs, horizontal: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 56,
                    child: Text(
                      oraDetta,
                      key: Key('notifiche_ora_${dono.name}'),
                      style: TypographyTokens.titoloScheda().copyWith(
                        color:
                            acceso ? palette.goldSoft : ColorTokens.textMuted,
                      ),
                    ),
                  ),
                  // **UN SEGNO CHE SI PUO' TOCCARE**, se no un'ora scritta
                  // sembra un'etichetta: e' la stessa regola della freccia
                  // sulle tessere del Passaporto, dell'ordine BC voce 03.
                  Icon(Icons.schedule_rounded,
                      size: 13,
                      color: (acceso ? palette.goldSoft : ColorTokens.textMuted)
                          .withValues(alpha: 0.7)),
                ],
              ),
            ),
          ),
          const SizedBox(width: SpacingTokens.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dono.title,
                  style: TypographyTokens.corpo().copyWith(
                    color: acceso
                        ? ColorTokens.textPrimary
                        : ColorTokens.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dono.cosaFai,
                  style: TypographyTokens.didascalia()
                      .copyWith(color: ColorTokens.textMuted),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // L'interruttore torna al centro della sua riga: e' un comando, non
          // una parola da leggere in fila con le altre.
          Align(
            alignment: Alignment.centerRight,
            child: Switch(
              key: Key('notifiche_interruttore_${dono.name}'),
              value: acceso,
              onChanged: attivabile ? (v) => suScelta(v) : null,
              activeThumbColor: palette.gold,
            ),
          ),
        ],
      ),
    );
  }
}

/// LA CODA DEL TELEFONO, guardata invece che supposta. Ordine CF voce 04.
///
/// **Non e' una schermata di diagnostica nascosta**: sta nella pagina delle
/// notifiche, dove una persona arriva proprio quando non le arriva niente, ed
/// e' scritta con le sue parole e non con quelle del sistema.
class _LaCodaDelTelefono extends StatelessWidget {
  const _LaCodaDelTelefono({
    required this.inCoda,
    required this.sistoGuardando,
    required this.esitoDellaProva,
    required this.palette,
    required this.suGuarda,
    required this.suProva,
  });

  final List<int>? inCoda;
  final bool sistoGuardando;
  final String? esitoDellaProva;
  final MaestroPalette palette;
  final VoidCallback suGuarda;
  final VoidCallback suProva;

  @override
  Widget build(BuildContext context) {
    final coda = inCoda;
    final String detto;
    if (sistoGuardando) {
      detto = 'Sto guardando...';
    } else if (coda == null) {
      detto = 'Non l\'ho ancora guardata.';
    } else if (coda.isEmpty) {
      detto = 'Nessuna chiamata in coda. Il Cerchio non ne ha programmata '
          'nessuna: accendi un Dono qui sotto.';
    } else {
      detto = coda.length == 1
          ? 'Una chiamata in coda sul telefono.'
          : '${coda.length} chiamate in coda sul telefono.';
    }
    return DepthCard(
      raised: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Le chiamate arrivano?',
              style: TypographyTokens.titoloDiRiga()
                  .copyWith(color: palette.goldSoft)),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            detto,
            key: const Key('notifiche_coda_detto'),
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textSecondary),
          ),
          if (esitoDellaProva != null) ...[
            const SizedBox(height: SpacingTokens.xs),
            Text(
              esitoDellaProva!,
              key: const Key('notifiche_esito_prova'),
              style: TypographyTokens.corpo()
                  .copyWith(color: ColorTokens.textSecondary),
            ),
          ],
          const SizedBox(height: SpacingTokens.sm),
          // **A CAPO E NON IN FILA, misurato.** Su 360 punti i due nomi in
          // riga sbordavano di trenta: `Wrap` li manda a capo invece di
          // stringerli, che e' cio' che un dito preferisce.
          Wrap(
            spacing: SpacingTokens.sm,
            children: [
              TextButton(
                key: const Key('notifiche_guarda_la_coda'),
                onPressed: sistoGuardando ? null : suGuarda,
                child: Text('Guarda la coda',
                    style: TypographyTokens.etichetta()
                        .copyWith(color: palette.goldSoft)),
              ),
              TextButton(
                key: const Key('notifiche_prova_adesso'),
                onPressed: suProva,
                child: Text('Provala adesso',
                    style: TypographyTokens.etichetta()
                        .copyWith(color: palette.goldSoft)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
