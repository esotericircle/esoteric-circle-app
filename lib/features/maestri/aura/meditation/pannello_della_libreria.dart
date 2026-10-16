import 'package:flutter/material.dart';

import '../../../../core/maestro/libreria_dei_respiri.dart';
import 'meditation_audio.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';

/// **SCEGLI SINTOMO E FREQUENZA.** Ordine DD voce 12, 10 settembre 2026.
///
/// **LA LIBRERIA CAMBIA SCOPO, e la ragione e' del fondatore**: *"all'utente
/// non importa memorizzare quattro pratiche se non sa cosa farne e perche'"*.
///
/// **COSA C'ERA PRIMA, e va scritto perche' non torni.** L'ordine DB voce 05
/// aveva costruito qui *il rito che ti costruisci*: si toccavano da tre a
/// cinque pratiche, si dava un nome alla sequenza e si premeva **Tieni questo
/// rito**. Era una funzione di archiviazione, e chiedeva a chi arriva con un
/// problema di sapere gia' che cosa cercare.
///
/// **E SUL TELEFONO NON FUNZIONAVA NEMMENO QUELLA.** Misurato sul dispositivo
/// 767f596c, build 2244: toccata la voce *"Il suono del cuore, 5 minuti"*,
/// **cambiavano 603 pixel**, cioe' niente. Il tocco c'era e chiamava
/// `_tocca`, che riempiva un cerchietto di dodici pixel: **il comando
/// rispondeva e nessuno poteva accorgersene**. Il fondatore lo ha riassunto
/// cosi': *"la libreria non risponde"*.
///
/// **COSA C'E' ADESSO.** Ogni voce porta in testa **il sintomo a cui
/// risponde**, scritto grande, e sotto la riga al verbo, cosa si fa e la
/// fonte.
///
/// **IL SINTOMO E' LA VIA, E TOCCARLO SCEGLIE: NON FA PARTIRE.** Ordine DS
/// voce 05, 17 settembre 2026. L'ordine DD voce 12 voleva la pratica avviata
/// al tocco; il fondatore, sulle catture del 16 e del 17 settembre, ha visto
/// il suono partire prima di aver deciso qualcosa: *"aprire la schermata non
/// e' un consenso a sentire un suono"*. **Vince la voce piu' recente.** Adesso
/// la voce si sceglie, la scheda dice **prima** quale frequenza comporta, e
/// il suono parte dal play.
///
/// **E LA FREQUENZA E' UN CONTROLLO SOLO**, un menu' a discesa, al posto delle
/// nove pasticche: *"la scelta della frequenza si fa fra molte bolle"*.
///
/// **IL CONFINE STA NEL VERBO, NON NEL SOSTANTIVO.** Si scrive *"per le sere
/// in cui il sonno non arriva"*, non *"cura l'insonnia"*. Nessuna promessa di
/// guarigione, di effetto clinico o di risultato fisico, in nessun punto:
/// vedi [Respiro.perQuando], e la guardia del vocabolario dell'ordine DB si
/// estende a queste voci.
class PannelloDellaLibreria extends StatefulWidget {
  const PannelloDellaLibreria({
    super.key,
    required this.palette,
    required this.centroDiOggi,
    required this.onSceglie,
    required this.frequenzaScelta,
    required this.onFrequenza,
  });

  /// La frequenza scelta adesso: la nomina il menu', e la nominano le schede
  /// dei sintomi che non hanno un centro loro.
  final MeditationPreset frequenzaScelta;

  /// **E LA FREQUENZA SI SCEGLIE DA QUI.** Ordine DD voce 17, 10 settembre
  /// 2026, decisione del fondatore: *"elimina 'preferisco scegliere io', e'
  /// ridondante visto che dal pulsante puo' gia' scegliere sintomo e
  /// frequenza"*.
  final void Function(MeditationPreset) onFrequenza;

  final MaestroPalette palette;

  /// L'indice del centro acceso oggi: le sue pratiche vengono per prime.
  final int centroDiOggi;

  /// **COSA SUCCEDE AL TOCCO: la pratica si sceglie.** Ordine DS voce 05: non
  /// parte, e la scheda dice gia' che frequenza portera'.
  final void Function(Respiro) onSceglie;

  @override
  State<PannelloDellaLibreria> createState() => _PannelloDellaLibreriaState();
}

class _PannelloDellaLibreriaState extends State<PannelloDellaLibreria> {
  bool _aperto = false;

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    // Le pratiche del centro di oggi per prime, poi tutte le altre: chi apre
    // la libreria oggi trova in cima quelle che c'entrano con oggi.
    final sue = LibreriaDeiRespiri.perCentro(widget.centroDiOggi);
    final altre = [
      for (final r in LibreriaDeiRespiri.pronte)
        if (!sue.contains(r)) r,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // **IL PULSANTE IN EVIDENZA, maiuscolo e in grassetto**, come l'ordine
        // detta. Prima era una riga di testo piccolo in fondo alla colonna, e
        // chi non scorreva fino in fondo non sapeva che la libreria esistesse.
        FilledButton(
          key: const Key('meditazione_apri_libreria'),
          onPressed: () => setState(() => _aperto = !_aperto),
          style: FilledButton.styleFrom(
            backgroundColor: palette.primary,
            foregroundColor: palette.onPrimary,
            minimumSize: const Size.fromHeight(54),
          ),
          child: Text(
            _aperto ? 'CHIUDI I SINTOMI' : 'SCEGLI IL SINTOMO',
            style: TypographyTokens.etichetta()
                .copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2),
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        // **LA FREQUENZA, UN CONTROLLO SOLO. Ordine DS voce 05.** Un pulsante
        // che dice quale suona, e al tocco apre il menu' delle nove. Sta
        // sotto il sintomo perche' e' la seconda via: la frequenza e' una
        // conseguenza del sintomo, non una domanda che gli si fa.
        _MenuDellaFrequenza(
          scelta: widget.frequenzaScelta,
          palette: palette,
          onScelta: widget.onFrequenza,
        ),
        if (_aperto) ...[
          const SizedBox(height: SpacingTokens.sm),
          // **IL NUMERO ONESTO E' UNO SOLO**, ordine DC voce 18: quante ce ne
          // sono. Le pratiche che arriveranno non si nominano, non si contano
          // e non si mostrano in grigio.
          Text(
            '${LibreriaDeiRespiri.quantePronte} pratiche, tutte pronte. '
            'Toccane una per sceglierla. Poi comincia col play.',
            key: const Key('meditazione_ampiezza_libreria'),
            textAlign: TextAlign.center,
            style: TypographyTokens.didascalia()
                .copyWith(color: ColorTokens.textSecondary),
          ),
          const SizedBox(height: SpacingTokens.md),
          Text(
            'IL SINTOMO',
            key: const Key('meditazione_titolo_sintomi'),
            style: TypographyTokens.etichetta()
                .copyWith(color: palette.goldSoft, letterSpacing: 1.4),
          ),
          const SizedBox(height: SpacingTokens.xs),
          for (final r in [...sue, ...altre])
            _RigaDelRespiro(
              respiro: r,
              palette: palette,
              frequenzaScelta: widget.frequenzaScelta,
              // **SCEGLIENDO, LA LIBRERIA SI CHIUDE.** Difetto misurato sul
              // telefono 767f596c dopo la prima cura: toccata una voce mentre
              // la sessione era gia' in corso, **cambiavano zero pixel**. La
              // pratica partiva davvero e cambiava solo il suono, che con la
              // stessa frequenza del centro non cambiava nemmeno quello.
              // **Un comando che risponde e non lo dice e' un comando morto
              // per chi lo guarda.** La libreria che si chiude e' la risposta
              // visibile, e riporta l'occhio sul fiore.
              onTap: () {
                setState(() => _aperto = false);
                widget.onSceglie(r);
              },
            ),
        ],
      ],
    );
  }
}

/// Una voce della libreria: il sintomo grande in testa, poi il resto.
class _RigaDelRespiro extends StatelessWidget {
  const _RigaDelRespiro({
    required this.respiro,
    required this.palette,
    required this.frequenzaScelta,
    required this.onTap,
  });

  final Respiro respiro;
  final MaestroPalette palette;
  final MeditationPreset frequenzaScelta;
  final VoidCallback onTap;

  /// **LA FREQUENZA CHE QUESTO SINTOMO COMPORTA.** Ordine DS voce 05: *"chi
  /// sceglie respiro corto deve leggere li' che frequenza gli tocca"*.
  ///
  /// Le pratiche di un centro suonano il tono del centro. **Quattro pratiche
  /// non hanno un centro**, e suonano la frequenza gia' scelta: la scheda lo
  /// dice col numero, invece di tacere o di inventarne una.
  String get frequenzaDetta {
    final sua = MeditationPreset.perCentro(respiro.centro);
    return sua == null
        ? 'Frequenza: quella scelta, ${frequenzaScelta.label}'
        : 'Frequenza: ${sua.label}, ${sua.subtitle.toLowerCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
      child: Material(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        child: InkWell(
          key: Key('meditazione_respiro_${respiro.id}'),
          onTap: onTap,
          enableFeedback: false,
          // **NESSUN SUONO CHE NON HAI SCELTO**, ordine CQ voce 1.08: il click
          // di sistema non appartiene al Cerchio, e i suoni li accende la
          // Palette Sensoriale quando la persona li ha voluti.
          //
          // **E L'INTERRUTTORE STA ATTACCATO AL GESTO, non in fondo alla
          // lista.** La guardia legge i quattrocento caratteri che seguono
          // l'apertura del widget, e con questa spiegazione in mezzo la riga
          // finiva **oltre il millesimo**: il tocco era spento davvero e la
          // guardia diceva il contrario, perche' la sua finestra non ci
          // arrivava. Prima l'interruttore, poi il perche'.
          //
          // **E il nome del widget non si scrive qui dentro**, nemmeno fra
          // apici: la guardia lo cerca col grep, e un commento che lo nomina
          // diventa un elemento in piu' da sorvegliare che non esiste.
          borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
              border: Border.all(color: palette.gold.withValues(alpha: 0.22)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // **IL SINTOMO IN TESTA, SCRITTO GRANDE.** E' la cosa che chi
                // arriva sta cercando, e prima non c'era affatto.
                Text(
                  respiro.sintomo.etichetta,
                  style: TypographyTokens.titoloScheda()
                      .copyWith(color: palette.goldSoft),
                ),
                const SizedBox(height: 2),
                // **LA RIGA AL VERBO**, che e' cio' che tiene questa funzione
                // fuori dal terreno clinico: dice quando, non che cosa cura.
                Text(
                  respiro.perQuando,
                  style: TypographyTokens.corpo()
                      .copyWith(color: ColorTokens.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  frequenzaDetta,
                  key: Key('meditazione_frequenza_del_sintomo_${respiro.id}'),
                  style: TypographyTokens.titoloDiRiga()
                      .copyWith(color: palette.goldSoft),
                ),
                const SizedBox(height: SpacingTokens.xs),
                // **E IL TESTO E' PIU' GRANDE DI PRIMA**, come l'ordine
                // chiede: cosa si fa era una didascalia, adesso e' corpo.
                Text(
                  '${respiro.nome}, ${respiro.quantoDura}. '
                  '${respiro.cosaSiFa}',
                  style: TypographyTokens.corpo()
                      .copyWith(color: ColorTokens.textSecondary),
                ),
                const SizedBox(height: 2),
                // **LA FONTE STA SOTTO OGNI PRATICA**, ordine DB voce 02:
                // *"ogni pratica porta la sua fonte"*. Non un tooltip che
                // confessa mancanze: la tradizione col suo autore e il suo
                // anno, e cio' che riferisce chi la pratica.
                Text(
                  respiro.tradizione.fonte,
                  style: TypographyTokens.didascalia().copyWith(
                      color: palette.goldSoft.withValues(alpha: 0.75),
                      height: 1.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// **IL MENU' DELLA FREQUENZA.** Ordine DS voce 05, 17 settembre 2026.
///
/// **Qui c'erano le pasticche**, nove bolle in un `Wrap`, dall'ordine DD voce
/// 17. Il fondatore ha chiesto un pulsante solo che apre un menu' a discesa,
/// e la classe delle pasticche **se n'e' andata invece di restare spenta**:
/// un componente che nessuno monta e' un componente che qualcuno rimonta.
class _MenuDellaFrequenza extends StatelessWidget {
  const _MenuDellaFrequenza({
    required this.scelta,
    required this.palette,
    required this.onScelta,
  });

  final MeditationPreset scelta;
  final MaestroPalette palette;
  final void Function(MeditationPreset) onScelta;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MeditationPreset>(
      key: const Key('meditazione_scelta_frequenza'),
      tooltip: 'Scegli la frequenza',
      initialValue: scelta,
      onSelected: onScelta,
      color: palette.surfaceElevated,
      itemBuilder: (context) => [
        for (final p in MeditationPreset.values)
          PopupMenuItem<MeditationPreset>(
            key: Key('meditazione_frequenza_${p.id}'),
            value: p,
            child: Text(
              '${p.label}, ${p.subtitle.toLowerCase()}',
              style: TypographyTokens.titoloDiRiga().copyWith(
                  color:
                      p == scelta ? palette.goldSoft : ColorTokens.textPrimary),
            ),
          ),
      ],
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
          border: Border.all(color: palette.gold.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'FREQUENZA: ${scelta.label}',
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.goldSoft, letterSpacing: 1.2),
              ),
            ),
            Icon(Icons.arrow_drop_down_rounded, color: palette.goldSoft),
          ],
        ),
      ),
    );
  }
}

/// Il bottone che avvia o ferma il suono e il visualizzatore.
