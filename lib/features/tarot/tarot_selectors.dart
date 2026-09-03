import 'package:flutter/material.dart';

import '../../core/tarot/tarot_spread_type.dart';
import '../../core/tarot/tarot_topic.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../horoscope/answer_depth.dart';

/// La chiave con cui si legge la stesa.
///
/// La Riflessione e' citata come ispirazione al lavoro di Alejandro Jodorowsky,
/// senza alcun rapporto ufficiale: mai un marchio, sempre col suo disclaimer.
enum ReadingKey {
  predittiva('Predittiva di Medora', available: true),
  riflessione('Riflessione Jodorowsky', available: false),
  esoterica('Esoterica Caligo', available: false);

  const ReadingKey(this.label, {required this.available});

  final String label;
  final bool available;

  /// Nota da mostrare sotto la voce, quando serve.
  String? get note => this == ReadingKey.riflessione
      ? 'Ispirata al lavoro di Alejandro Jodorowsky, senza rapporto ufficiale.'
      : null;
}

/// Il mazzo con cui si legge.
enum TarotDeckStyle {
  riderWaite('Rider-Waite', available: true),
  marsiglia('Marsiglia', available: false),
  thoth('Thoth', available: false);

  const TarotDeckStyle(this.label, {required this.available});

  final String label;
  final bool available;
}

/// Lo stato dei selettori prima della stesa.
class TarotSetup {
  const TarotSetup({
    this.tipo = TarotSpreadType.predefinita,
    this.key = ReadingKey.predittiva,
    this.deck = TarotDeckStyle.riderWaite,
    this.depth = AnswerDepth.breve,
    this.topic = TarotTopic.predefinito,
    this.includeReversed = true,
    this.domandaLibera = '',
  });

  /// Quale stesa si sta facendo. Da qui viene anche il titolo in alto.
  final TarotSpreadType tipo;

  final ReadingKey key;
  final TarotDeckStyle deck;

  /// La profondita' di TUTTA la lettura, non di una posizione sola.
  final AnswerDepth depth;

  /// L'argomento su cui si direziona la lettura.
  final TarotTopic topic;

  /// Includi carte rovesciate: attivo di default nelle impostazioni della
  /// cartomanzia.
  final bool includeReversed;

  /// **LA DOMANDA SCRITTA A MANO, quando le sei suggerite non bastano.**
  /// Ordine CO voce 05, 3 settembre 2026.
  ///
  /// Vuota vuol dire che nessuno ne ha scritta una, e allora la lettura e'
  /// esattamente quella di prima. **Non sostituisce l'argomento**: la tendina
  /// continua a orientare il corpus, perche' il responso di questa app e'
  /// deterministico e nasce dalle carte, non da un modello che legge una
  /// frase. Questa e' la domanda di chi guarda, e serve a due cose: comparire
  /// nel responso, cosi' chi legge sa a che cosa si sta rispondendo, ed
  /// entrare nella memoria del Maestro, cosi' domani lui sa che cosa gli era
  /// stato chiesto.
  ///
  /// **Si dichiara che non cambia il testo**, invece di fingere che lo cambi:
  /// un responso che ripete la domanda con parole diverse e non ne tiene
  /// conto e' peggio di un responso che non la nomina affatto.
  final String domandaLibera;

  /// La domanda scritta a mano, ripulita, o nulla se non ce n'e' una.
  String? get domandaScritta {
    final t = domandaLibera.trim();
    return t.isEmpty ? null : t;
  }

  /// Il riepilogo in poche parole, per la riga richiusa.
  ///
  /// Dice tutto quello che serve sapere a colpo d'occhio, senza aprire nulla:
  /// chi non tocca la configurazione non ha motivo di espanderla.
  String get riepilogo => [
        // **LA DOMANDA SCRITTA VINCE SULL'ARGOMENTO nella riga richiusa.**
        // Chi ne ha scritta una vuole rivedere quella, non la voce della
        // tendina che gli sta sotto.
        domandaScritta ?? topic.label.split(',').first,
        key.label.split(' ').first,
        deck.label,
        includeReversed ? 'con rovesciate' : 'solo dritte',
      ].join('  ·  ');

  TarotSetup copyWith({
    TarotSpreadType? tipo,
    ReadingKey? key,
    TarotDeckStyle? deck,
    AnswerDepth? depth,
    TarotTopic? topic,
    bool? includeReversed,
    String? domandaLibera,
  }) =>
      TarotSetup(
        tipo: tipo ?? this.tipo,
        key: key ?? this.key,
        deck: deck ?? this.deck,
        depth: depth ?? this.depth,
        topic: topic ?? this.topic,
        includeReversed: includeReversed ?? this.includeReversed,
        domandaLibera: domandaLibera ?? this.domandaLibera,
      );
}

/// Il pannello dei selettori prima della stesa.
///
/// Sta richiuso in una riga di riepilogo e si apre al tocco. Dentro, ogni
/// scelta e' una tendina compatta, due per riga dove entrano: prima le voci non
/// pronte erano chip impilati, e Chiave e Mazzo si mangiavano tre righe
/// ciascuno. Le voci in arrivo ora stanno dentro la loro tendina, col lucchetto
/// e l'invito ad abbonarsi.
class TarotSetupPanel extends StatelessWidget {
  const TarotSetupPanel({
    super.key,
    required this.setup,
    required this.palette,
    required this.onChanged,
    required this.onLocked,
    this.aperto = false,
    this.onToggle,
  });

  final TarotSetup setup;
  final MaestroPalette palette;
  final ValueChanged<TarotSetup> onChanged;

  /// Invito quando si tocca una voce non disponibile.
  final ValueChanged<String> onLocked;

  /// Se il pannello e' aperto o richiuso nella sua riga di riepilogo.
  ///
  /// Di base sta richiuso: aperto spingeva il ventaglio sotto la piega, e per
  /// pescare bisognava scorrere oltre tutta la configurazione.
  final bool aperto;

  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) =>
      aperto ? _pannello(context) : _riga(context);

  /// **IL NOME DELLE SCELTE, E VIVE QUI SOLO.** Ordine BN voce 01, parole del
  /// fondatore: "la prima bolla dove fare le scelte delle opzioni si deve
  /// chiamare Scegli la tua stesa". Prima il pannello aperto diceva "LA TUA
  /// STESA" e quello chiuso non diceva niente: la riga portava il riassunto
  /// delle scelte gia' fatte, che risponde a "cosa ho scelto" e non a "cosa
  /// devo fare". Adesso il nome e' lo stesso nei due stati e sta in una
  /// costante, perche' due stringhe uguali in due punti diventano diverse al
  /// primo che ne cambia una.
  static const String titolo = 'Scegli la tua stesa';

  /// La riga richiusa: il titolo, il riepilogo sotto, tappabile per aprire.
  Widget _riga(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Configurazione della stesa, tocca per aprire',
      child: GestureDetector(
        key: const Key('stesa_setup_riga'),
        onTap: onToggle,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.md, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
            color: palette.surfaceElevated.withValues(alpha: 0.45),
            border: Border.all(color: palette.gold.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Icon(Icons.tune_rounded, size: 15, color: palette.goldSoft),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(titolo,
                        key: const Key('stesa_setup_titolo_chiuso'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TypographyTokens.etichetta().copyWith(
                            color: palette.goldSoft, letterSpacing: 1.2)),
                    const SizedBox(height: 2),
                    // Il riassunto delle scelte resta, sotto il titolo: dice
                    // cosa hai scelto, mentre il titolo dice cosa puoi fare.
                    Text(setup.riepilogo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TypographyTokens.didascalia()
                            .copyWith(color: ColorTokens.textSecondary)),
                  ],
                ),
              ),
              // IL TRIANGOLO DEL SELETTORE, non la freccia in giu'.
              //
              // Qui c'era un `expand_more`, cioe' l'icona che nel resto
              // dell'app significa "qui sotto c'e' altro testo, te lo mostro".
              // Questo chip non mostra testo: apre un pannello di scelte, che
              // e' un'altra cosa. Il triangolo pieno e' l'affordance del
              // selettore, ed e' quella che porta gia' il chip gemello qui
              // sotto.
              Icon(Icons.arrow_drop_down_rounded,
                  size: 18, color: palette.goldSoft),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pannello(BuildContext context) {
    return Container(
      key: const Key('stesa_setup'),
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        color: palette.surfaceElevated.withValues(alpha: 0.55),
        border: Border.all(color: palette.gold.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            key: const Key('stesa_setup_chiudi'),
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Expanded(
                  child: Text(titolo,
                      key: const Key('stesa_setup_titolo_aperto'),
                      maxLines: 1,
                      style: TypographyTokens.etichetta().copyWith(
                          color: palette.goldSoft, letterSpacing: 1.4)),
                ),
                Icon(Icons.expand_less_rounded,
                    size: 18, color: palette.goldSoft),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          // Le tendine, affiancate due per riga dove entrano.
          LayoutBuilder(
            builder: (context, constraints) {
              final larga = constraints.maxWidth >= 300;
              final w = larga
                  ? (constraints.maxWidth - SpacingTokens.xs) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: SpacingTokens.xs,
                runSpacing: SpacingTokens.xs,
                children: [
                  // **LA DOMANDA PER PRIMA, ordine BV voce 05.** Era la
                  // seconda e uguale alle altre quattro: la scelta che
                  // cambia il responso stava in mezzo al contorno.
                  SizedBox(
                    width: w,
                    child: TendinaSelettore<TarotTopic>(
                      chiave: const Key('stesa_topic'),
                      titolo: 'Scegli la tua domanda',
                      inRilievo: true,
                      corrente: setup.topic,
                      voci: TarotTopic.values,
                      palette: palette,
                      etichetta: (t) => t.label,
                      gruppo: (t) => t.group.label,
                      bloccata: (_) => false,
                      onSelect: (t) => onChanged(setup.copyWith(topic: t)),
                      onLocked: (_) {},
                    ),
                  ),
                  // **E SUBITO SOTTO LE SUGGERITE, LA PROPRIA.**
                  // Ordine CO voce 05 per l'esistenza, ordine CQ voce 1.05
                  // del 3 settembre 2026 per il posto.
                  //
                  // **Il campo c'era e il fondatore non l'ha trovato**, e la
                  // ragione si vede aprendo il pannello: stava in fondo,
                  // dopo altre cinque tendine, mentre le domande suggerite
                  // stanno in cima. Fra la cosa e la sua alternativa c'era
                  // tutto il contorno della stesa, cioe' abbastanza da far
                  // credere che l'alternativa non esistesse.
                  //
                  // Prende la riga intera e non mezza: e' un campo in cui si
                  // scrive una frase, non una tendina da cui si sceglie, e a
                  // meta' riga si scriverebbe una frase dentro una feritoia.
                  SizedBox(
                    width: constraints.maxWidth,
                    child: _DomandaScritta(
                      testo: setup.domandaLibera,
                      palette: palette,
                      onChanged: (t) =>
                          onChanged(setup.copyWith(domandaLibera: t)),
                    ),
                  ),
                  // Il tipo di stesa: da qui viene anche il titolo in alto.
                  SizedBox(
                    width: w,
                    child: TendinaSelettore<TarotSpreadType>(
                      chiave: const Key('stesa_tipo'),
                      titolo: 'Tipo di stesa',
                      corrente: setup.tipo,
                      voci: TarotSpreadType.values,
                      palette: palette,
                      etichetta: (t) => t.breve,
                      sottotitolo: (t) => t.descrizione,
                      bloccata: (t) => !t.disponibile,
                      onSelect: (t) => onChanged(setup.copyWith(tipo: t)),
                      onLocked: (t) => onLocked(t.nome),
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: TendinaSelettore<ReadingKey>(
                      chiave: const Key('stesa_chiave'),
                      titolo: 'Chiave di lettura',
                      corrente: setup.key,
                      voci: ReadingKey.values,
                      palette: palette,
                      etichetta: (k) => k.label,
                      // La nota etica su Jodorowsky compare solo sulla sua
                      // voce, dentro la tendina, dove sta in contesto.
                      sottotitolo: (k) => k.note,
                      bloccata: (k) => !k.available,
                      onSelect: (k) => onChanged(setup.copyWith(key: k)),
                      onLocked: (k) => onLocked(k.label),
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: TendinaSelettore<TarotDeckStyle>(
                      chiave: const Key('stesa_mazzo'),
                      titolo: 'Mazzo',
                      corrente: setup.deck,
                      voci: TarotDeckStyle.values,
                      palette: palette,
                      etichetta: (d) => d.label,
                      bloccata: (d) => !d.available,
                      onSelect: (d) => onChanged(setup.copyWith(deck: d)),
                      onLocked: (d) => onLocked(d.label),
                    ),
                  ),
                  // Una sola profondita' per tutta la lettura.
                  SizedBox(
                    width: w,
                    child: TendinaSelettore<AnswerDepth>(
                      chiave: const Key('stesa_depth'),
                      titolo: 'Profondità della lettura',
                      corrente: setup.depth,
                      voci: AnswerDepth.shown,
                      palette: palette,
                      etichetta: (d) => d.label,
                      bloccata: (d) => d.premium,
                      onSelect: (d) => onChanged(setup.copyWith(depth: d)),
                      onLocked: (d) => onLocked(d.label),
                    ),
                  ),
                  // L'interruttore resta un interruttore, in linea con le
                  // tendine.
                  SizedBox(
                    width: w,
                    child: _Interruttore(
                      titolo: 'Carte rovesciate',
                      acceso: setup.includeReversed,
                      palette: palette,
                      onChanged: (v) =>
                          onChanged(setup.copyWith(includeReversed: v)),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Una tendina compatta della configurazione.
///
/// Sopra il titolo in maiuscoletto, sotto la voce corrente con la freccia. Le
/// voci non ancora pronte restano nell'elenco col lucchetto, non spariscono:
/// si vede che esistono e che arrivano, senza occupare spazio da chiuse.
class TendinaSelettore<T> extends StatelessWidget {
  const TendinaSelettore({
    super.key,
    required this.chiave,
    required this.titolo,
    required this.corrente,
    required this.voci,
    required this.palette,
    required this.etichetta,
    required this.bloccata,
    required this.onSelect,
    required this.onLocked,
    this.sottotitolo,
    this.gruppo,
    this.inRilievo = false,
  });

  /// La chiave del bottone, per i test.
  final Key chiave;

  final String titolo;
  final T corrente;
  final List<T> voci;
  final MaestroPalette palette;

  final String Function(T) etichetta;

  /// Una riga di spiegazione sotto la voce, dove serve.
  final String? Function(T)? sottotitolo;

  /// Se le voci vanno raccolte per gruppi, il nome del gruppo.
  final String Function(T)? gruppo;

  /// Se questa tendina va messa in rilievo rispetto alle altre. Ordine BV
  /// voce 05: la domanda e' la scelta che cambia il responso, le altre sono
  /// contorno, e finche' sono tutte uguali non si vede quale conta.
  final bool inRilievo;

  final bool Function(T) bloccata;
  final ValueChanged<T> onSelect;
  final ValueChanged<T> onLocked;

  @override
  Widget build(BuildContext context) {
    final items = <PopupMenuEntry<T>>[];
    String? gruppoCorrente;
    for (final v in voci) {
      if (gruppo != null && gruppo!(v) != gruppoCorrente) {
        gruppoCorrente = gruppo!(v);
        items.add(PopupMenuItem<T>(
          enabled: false,
          height: 28,
          child: Text(gruppoCorrente.toUpperCase(),
              style: TypographyTokens.etichetta().copyWith(
                  color: palette.goldSoft.withValues(alpha: 0.8),
                  letterSpacing: 1.4)),
        ));
      }
      final bloccato = bloccata(v);
      final nota = sottotitolo?.call(v);
      items.add(PopupMenuItem<T>(
        value: v,
        height: nota == null ? 42 : 58,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              child: v == corrente
                  ? Icon(Icons.check_rounded, size: 14, color: palette.goldSoft)
                  : null,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(etichetta(v),
                      style: TypographyTokens.didascalia().copyWith(
                        color: bloccato
                            ? ColorTokens.textSecondary
                            : (v == corrente
                                ? palette.goldSoft
                                : ColorTokens.textPrimary),
                      )),
                  if (nota != null)
                    Text(nota,
                        maxLines: 2,
                        style: TypographyTokens.didascalia().copyWith(
                            color: ColorTokens.textSecondary,
                            fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            if (bloccato) ...[
              const SizedBox(width: 6),
              Icon(Icons.lock_rounded,
                  size: 13, color: palette.goldSoft.withValues(alpha: 0.75)),
              const SizedBox(width: 4),
              Text('Coming soon',
                  style: TypographyTokens.etichetta().copyWith(
                      color: palette.goldSoft.withValues(alpha: 0.75),
                      letterSpacing: 0.4)),
            ],
          ],
        ),
      ));
    }

    return PopupMenuButton<T>(
      key: chiave,
      tooltip: titolo,
      position: PopupMenuPosition.under,
      color: palette.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        side: BorderSide(color: palette.gold.withValues(alpha: 0.35)),
      ),
      padding: EdgeInsets.zero,
      onSelected: (v) => bloccata(v) ? onLocked(v) : onSelect(v),
      itemBuilder: (context) => items,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
          color: palette.deepest.withValues(alpha: inRilievo ? 0.65 : 0.45),
          // **IL COLORE DEL MAESTRO, non un colore nuovo**: il bagliore della
          // palette, che sulle altre tendine non compare mai.
          border: Border.all(
              color: inRilievo
                  ? palette.glow
                  : palette.gold.withValues(alpha: 0.35),
              width: inRilievo ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(titolo.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TypographyTokens.etichetta().copyWith(
                    color: inRilievo ? palette.glow : ColorTokens.textSecondary,
                    fontWeight: inRilievo ? FontWeight.w700 : null,
                    letterSpacing: 0.8)),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(etichetta(corrente),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TypographyTokens.didascalia()
                          .copyWith(color: palette.goldSoft)),
                ),
                // Il lucchetto sul chip solo se la voce MOSTRATA e' bloccata.
                if (bloccata(corrente))
                  Icon(Icons.lock_rounded,
                      size: 12, color: palette.goldSoft.withValues(alpha: 0.7)),
                Icon(Icons.arrow_drop_down_rounded,
                    size: 18, color: palette.goldSoft),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Un interruttore della configurazione, alto quanto una tendina.
class _Interruttore extends StatelessWidget {
  const _Interruttore({
    required this.titolo,
    required this.acceso,
    required this.palette,
    required this.onChanged,
  });

  final String titolo;
  final bool acceso;
  final MaestroPalette palette;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        color: palette.deepest.withValues(alpha: 0.45),
        border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(titolo.toUpperCase(),
                maxLines: 2,
                style: TypographyTokens.etichetta().copyWith(
                    color: ColorTokens.textSecondary, letterSpacing: 0.8)),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              key: const Key('stesa_reversed_switch'),
              value: acceso,
              activeThumbColor: palette.gold,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

/// **IL CAMPO DOVE SI SCRIVE LA PROPRIA DOMANDA.**
/// Ordine CO voce 05, 3 settembre 2026.
///
/// Sta sotto le sei suggerite, e ha la stessa veste delle tendine sopra:
/// stesso fondo, stesso oro al bordo, stessa etichetta in alto. Un campo di
/// testo con la veste di sistema, in mezzo a sei tendine vestite, si legge
/// come una cosa arrivata dopo, ed e' arrivata dopo davvero, ma non deve
/// sembrarlo.
///
/// **Tiene il proprio controller**, e non ricostruisce il testo dal padre a
/// ogni battuta: passare il valore dall'alto e riscriverlo dentro il campo
/// sposta il cursore in fondo a ogni lettera, e chi corregge una parola in
/// mezzo alla frase si trova a scrivere in coda.
class _DomandaScritta extends StatefulWidget {
  const _DomandaScritta({
    required this.testo,
    required this.palette,
    required this.onChanged,
  });

  final String testo;
  final MaestroPalette palette;
  final ValueChanged<String> onChanged;

  @override
  State<_DomandaScritta> createState() => _DomandaScrittaState();
}

class _DomandaScrittaState extends State<_DomandaScritta> {
  late final TextEditingController _controllore =
      TextEditingController(text: widget.testo);

  @override
  void dispose() {
    _controllore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        color: palette.deepest.withValues(alpha: 0.45),
        border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('OPPURE SCRIVI LA TUA DOMANDA',
              style: TypographyTokens.etichetta().copyWith(
                  color: ColorTokens.textSecondary, letterSpacing: 0.8)),
          TextField(
            key: const Key('stesa_domanda_scritta'),
            controller: _controllore,
            onChanged: widget.onChanged,
            maxLength: 140,
            maxLines: 2,
            minLines: 1,
            textCapitalization: TextCapitalization.sentences,
            style: TypographyTokens.corpo().copyWith(
                color: ColorTokens.textPrimary),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              // Il contatore delle battute e' rumore su un campo di due
              // righe: il limite si sente scrivendo, e non serve un numero
              // che conta alla rovescia mentre si pensa a una domanda.
              counterText: '',
              hintText: 'Che cosa vuoi chiedere alle carte?',
              hintStyle: TypographyTokens.corpo().copyWith(
                  color: ColorTokens.textSecondary.withValues(alpha: 0.7)),
            ),
          ),
        ],
      ),
    );
  }
}
