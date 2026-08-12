import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/maestro/maestro.dart';
import '../../core/rituals/daily_elements.dart';
import '../../core/rituals/dawn_gift.dart';
import '../../core/rituals/filo_del_giorno.dart';
import '../../design_system/components/le_tre_righe_del_rito.dart';
import '../../design_system/components/riga_del_dono.dart';
import '../../design_system/theme/accento_del_maestro.dart';
import '../../design_system/tokens/regime_chiaro.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'breath_destiny_screen.dart';

// I COLORI DEL REGIME CHIARO NON VIVONO PIU' QUI. Ordine P voce 12.
//
// Erano tre costanti private, e una costante privata non e' un token: non si
// enumera, non si misura e non si sorveglia. Finche' i regimi cromatici erano
// due e uno solo era governato dai token, nessun presidio automatico poteva
// proteggere l'altro, ed e' cosi' che il difetto delle etichette illeggibili
// e' nato. Adesso stanno in `RegimeChiaro`, col contrasto misurato e una
// guardia che lo sorveglia.
const Color _dayInk = RegimeChiaro.testoSuChiaro;
final Color _dayInkSoft = RegimeChiaro.testoMutoSuChiaro;
const Color _dayInset = RegimeChiaro.incassoSuChiaro;

/// L'ACCENTO DELLA SCHEDA, che nasce dal Maestro del giorno.
///
/// **Da `gift.maestro` e da nient'altro.** Il dono sa gia' di chi e' il giorno,
/// perche' gliel'ha messo dentro `DawnGift.forMaestro`, che a sua volta lo
/// prende da `DailyRituals.dawnMaestro` per la rotazione e da
/// `DailyElements.maestroFor` per i riti a guida fissa. Passare una palette
/// dalle schermate creerebbe **due** punti che decidono lo stesso colore, e
/// prima o poi direbbero due cose diverse.
///
/// **Il testo NON si tinge.** `_dayInk` e `_dayInkSoft` restano quelli: a gesto
/// completato la scena e' luce piena e la bolla e' vetro chiaro, quindi tingere
/// l'inchiostro peggiorerebbe la lettura senza dire niente di piu'. Il Maestro
/// si vede dove il colore e' colore, cioe' negli accenti, nella parola del
/// giorno e nel bordo.
///
/// **La regola del contrasto non vive piu' qui**, vive in
/// `AccentoDelMaestro`: era privata a questo file, e questa scheda era l'unica
/// superficie dell'app che sapesse essere leggibile. Adesso e' un punto solo
/// per tutte le superfici che portano il colore del Maestro del giorno.
Color _accentoDi(Maestro maestro) =>
    AccentoDelMaestro.su(maestro, superficie: _vetroOpaco);

/// Il vetro reso opaco, cioe' la condizione in cui la scheda si mostra davvero:
/// compare a gesto completato, quando la scena sotto e' luce piena.
const Color _vetroOpaco = RegimeChiaro.superficieChiara;

// La bolla e' un vetro smerigliato: semitrasparente e sfocata, lascia intravedere
// la scena sotto ma tiene il testo scuro leggibile sul chiaro.
const Color _dayGlass = RegimeChiaro.velatura;
const Color _dayGlassBorder = RegimeChiaro.bordoDellaVelatura;

/// La card del dono del giorno, condivisa dai riti: dentro una bolla di vetro
/// smerigliato semitrasparente, testo scuro leggibile sul chiaro. Porge tre
/// livelli, l'orientamento del giorno, la parola del giorno e la base apribile
/// che spiega da dove nasce, con la condivisione e il filo di continuita'.
/// Finche' i contenuti verificati non arrivano, i testi del cielo restano
/// provvisori e marcati, mai inventati.
class RitualGiftCard extends StatefulWidget {
  const RitualGiftCard({
    super.key,
    required this.gift,
    required this.dono,
    required this.giorno,
    required this.streak,
    required this.onShare,
    this.domandaDiIeri,
  });

  /// LA DOMANDA CHE MEDORA HA LASCIATO IERI NELLA STESA. Ordine P voce 18.
  ///
  /// Nulla quando ieri non c'e' stata nessuna stesa, e in quel caso la riga non
  /// compare: si mostra il dato che c'e', e di quello che manca non si parla.
  final String? domandaDiIeri;

  /// Quale dei cinque Doni e' questa scheda, e di che giorno: servono alla riga
  /// che dichiara chi parla. Non si ricavano dal `gift`, che porta il Maestro
  /// ma non l'appuntamento.
  final DailyElement dono;
  final DateTime giorno;

  final DawnGift gift;
  final int streak;
  final VoidCallback onShare;

  @override
  State<RitualGiftCard> createState() => _RitualGiftCardState();
}

class _RitualGiftCardState extends State<RitualGiftCard> {
  bool _baseOpen = false;

  @override
  Widget build(BuildContext context) {
    final gift = widget.gift;
    final word = gift.word;
    // L'accento nasce QUI, da gift.maestro, e da qui scende ai widget annidati
    // come parametro: non c'e' un secondo punto che lo decida.
    final accento = _accentoDi(gift.maestro);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: _dayGlass,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _dayGlassBorder),
          ),
          padding: const EdgeInsets.all(SpacingTokens.lg),
          // **La scheda scorre**, e da oggi le serve. Finche' il dono era un
          // segnaposto di tre righe ci stava sempre; adesso porta un gesto, un
          // respiro contato e la via col dito, e su uno schermo basso il
          // pulsante della base finiva fuori dalla scheda senza che nessuno
          // potesse toccarlo. L'ha trovato una prova gia' esistente, non io.
          child: SingleChildScrollView(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Livello zero: chi parla. Sta sopra tutto perche' e' la prima
              // cosa da sapere prima di leggere un responso.
              RigaDelDono(
                dono: widget.dono,
                giorno: widget.giorno,
                superficie: _vetroOpaco,
              ),
              // LE TRE RIGHE DEL RITO, ordine P voce 17: cosa fai, perche', e
              // cosa ti resta. In testa, prima di tutto il resto.
              LeTreRigheDelRito(
                rito: widget.dono,
                inchiostro: _dayInk,
                accento: accento,
              ),
              const SizedBox(height: SpacingTokens.md),
              // Livello uno: il tipo di dono e l'orientamento del giorno.
              Row(
                children: [
                  Flexible(
                    child: Text(
                      // NIENTE MAIUSCOLETTO, ordine P voce 13.
                      gift.kind.label,
                      key: const Key('alba_tipo_del_dono'),
                      style: TypographyTokens.didascalia().copyWith(
                        color: accento,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  if (gift.provisional) ...[
                    const SizedBox(width: SpacingTokens.sm),
                  ],
                ],
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                gift.orientation,
                key: const Key('alba_orientamento'),
                style: TypographyTokens.corpo().copyWith(color: _dayInk),
              ),
              // Livello due: la parola del giorno, in risalto. **O NIENTE.**
              //
              // Qui l'etichetta compariva sempre, e quando la parola mancava
              // sotto si leggeva "In arrivo". E' peggio del vuoto, non meglio:
              // e' un campo che PROMETTE, cioe' che dice alla persona di
              // aspettare qualcosa senza dirle cosa ne' quando. E' la stessa
              // famiglia del "In attesa dei contenuti astrologici verificati"
              // che il Rito dell'Alba mostrava e che e' gia' stata chiusa: una
              // schermata non fa vedere alla persona la propria impalcatura.
              //
              // O l'etichetta si riempie, o l'etichetta non c'e'. Quando il
              // rito del giorno non porta una parola, questo livello sparisce
              // intero, etichetta compresa, e la scheda resta quella che ha
              // qualcosa da dire.
              if (word != null) ...[
                const SizedBox(height: SpacingTokens.lg),
                // PAROLA DEL GIORNO, ordine P voce 13: ruolo didascalia,
                // cioe' sedici, niente maiuscoletto, e un colore che soddisfa
                // 4,5 a 1 sul fondo reale. Era etichetta a dodici in
                // maiuscoletto spaziato tre, cioe' la riga meno leggibile
                // della scheda proprio sopra la parola piu' importante.
                Text(
                  'Parola del giorno',
                  key: const Key('alba_etichetta_parola'),
                  style: TypographyTokens.didascalia().copyWith(
                    color: _dayInkSoft,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  word,
                  key: const Key('gift_word'),
                  style: TypographyTokens.display(size: 32).copyWith(
                    color: accento,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
              // **IL RESPIRO GUIDATO ESCE DA QUI, ordine S voce 13.**
              //
              // La voce P.17 aveva ragione a togliere l'istruzione scritta
              // ("tre dentro e tre fuori, sei giri"), che era un compito da
              // contare a mente. Ma il rimedio ha portato il respiro guidato
              // DENTRO ogni dono del giorno, e quello e' il rito del Soffio del
              // Destino: nell'Alba e' comparsa una meditazione che non e' sua, e
              // il rito del mattino e' diventato il contenitore di un altro rito.
              //
              // **Dal dono al Soffio si va con un invito di una riga**, e non
              // col rito intero incastrato dentro. La riga e' una porta vera, non
              // un annuncio: la tocchi e sei nel Soffio.
              if (gift.rito != null && !widget.dono.guidaIlRespiroInScena) ...[
                const SizedBox(height: SpacingTokens.md),
                Center(
                  child: TextButton.icon(
                    key: const Key('ponte_verso_il_soffio'),
                    onPressed: () => Navigator.of(context)
                        .push(BreathDestinyScreen.route(now: widget.giorno)),
                    icon: Icon(Icons.air_rounded, size: 16, color: accento),
                    label: Text(
                      'Il respiro guidato ti aspetta nel Soffio del Destino',
                      textAlign: TextAlign.center,
                      style: TypographyTokens.didascalia()
                          .copyWith(color: accento, height: 1.3),
                    ),
                  ),
                ),
              ],
              // LA DOMANDA DI IERI, ordine P voce 18: il filo fra la stesa di
              // ieri e il dono di stamattina.
              if (widget.domandaDiIeri != null) ...[
                const SizedBox(height: SpacingTokens.md),
                Container(
                  key: const Key('domanda_di_ieri'),
                  width: double.infinity,
                  padding: const EdgeInsets.all(SpacingTokens.sm),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: _dayInset,
                    border: Border.all(color: accento.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    FiloDelGiorno.richiamoDellaDomanda(widget.domandaDiIeri!),
                    key: const Key('alba_domanda_di_ieri'),
                    style: TypographyTokens.didascalia()
                        .copyWith(color: _dayInk, height: 1.4),
                  ),
                ),
              ],
              const SizedBox(height: SpacingTokens.md),
              // Livello tre: la base apribile, da dove nasce il dono.
              _BaseToggle(
                open: _baseOpen,
                onTap: () => setState(() => _baseOpen = !_baseOpen),
                accento: accento,
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.topCenter,
                child: _baseOpen
                    ? _BasePanel(source: gift.source)
                    : const SizedBox(width: double.infinity),
              ),
              const SizedBox(height: SpacingTokens.md),
              // **Wrap e non Row, e il motivo e' che la parola adesso esiste.**
              // Finche' `word` era nulla il pulsante di condivisione non veniva
              // mai costruito, e la riga conteneva la sola spilla: ci stava
              // sempre. Dal momento in cui il rito porta una parola vera i due
              // elementi convivono, e su schermo stretto la riga sforava di
              // novantotto pixel. L'ha trovato la cattura delle anteprime.
              Wrap(
                spacing: SpacingTokens.md,
                runSpacing: SpacingTokens.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // La condivisione della parola torna quando la parola e' reale.
                  if (word != null)
                    _ShareWordButton(
                        onShare: widget.onShare, accento: accento),
                  if (widget.streak >= 1)
                    _StreakChip(days: widget.streak, accento: accento),
                ],
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}


/// La riga che apre e chiude la base del dono.
class _BaseToggle extends StatelessWidget {
  const _BaseToggle(
      {required this.open, required this.onTap, required this.accento});

  final bool open;
  final VoidCallback onTap;

  /// L'accento del Maestro del giorno, deciso una volta sola dalla scheda.
  final Color accento;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: const Key('gift_base_toggle'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline_rounded, size: 15, color: accento),
            const SizedBox(width: 6),
            Text(
              'Da dove nasce questo dono',
              key: const Key('alba_base_toggle'),
              style: TypographyTokens.didascalia().copyWith(
                color: accento,
                letterSpacing: 0.4,
              ),
            ),
            Icon(open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                size: 18, color: accento),
          ],
        ),
      ),
    );
  }
}

/// Il pannello della base: ancora natale reale, transito e tradizione, con la
/// provvisorieta' dichiarata dove il contenuto verificato manca.
class _BasePanel extends StatelessWidget {
  const _BasePanel({required this.source});

  final GiftSource source;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('gift_base_panel'),
      width: double.infinity,
      margin: const EdgeInsets.only(top: SpacingTokens.sm),
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: _dayInset,
        border: Border.all(color: _dayInkSoft.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BaseRow(
            label: 'Ancora natale',
            value: source.natalDescription,
            provisional: false,
          ),
          // LE DUE RIGHE CHE SPARISCONO INVECE DI DIRE DI ASPETTARE.
          //
          // **Qui c'era due volte "In attesa dei contenuti astrologici
          // verificati", ed era l'app che mostrava alla persona la propria
          // impalcatura.** Adesso il transito arriva dal motore vero, lo
          // stesso dell'Oroscopo, ed e' nullo solo quando la carta natale non
          // c'e'; la fonte nella tradizione e' nulla perche' per i nove riti
          // dell'Alba non esiste una fonte verificata da citare.
          //
          // In tutti e due i casi la riga NON COMPARE. E' la stessa regola che
          // le varianti del rito seguono gia': si mostra il dato che c'e', e
          // di quello che manca non si parla.
          if (source.transit != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            _BaseRow(
              label: 'Transito attivo oggi',
              value: source.transit!,
              provisional: false,
            ),
          ],
          if (source.tradition != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            _BaseRow(
              label: 'Nella tradizione',
              value: source.tradition!,
              provisional: false,
            ),
          ],
        ],
      ),
    );
  }
}

class _BaseRow extends StatelessWidget {
  const _BaseRow({
    required this.label,
    required this.value,
    required this.provisional,
  });

  final String label;
  final String value;
  final bool provisional;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                // NIENTE MAIUSCOLETTO, ordine P voce 13: le etichette della
                // base erano le piu' piccole della scheda e le piu' spaziate,
                // cioe' le meno leggibili di tutte.
                label,
                key: Key('alba_base_etichetta_' + chiaveDi(label)),
                style: TypographyTokens.didascalia().copyWith(
                  color: _dayInkSoft,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            if (provisional) ...[
              const SizedBox(width: SpacingTokens.sm),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          key: Key('alba_base_valore_' + chiaveDi(label)),
          style: TypographyTokens.corpo().copyWith(
            color: provisional ? _dayInkSoft : _dayInk,
            height: 1.4,
            fontStyle: provisional ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    );
  }
}

/// Pulsante discreto per condividere la parola del giorno con la condivisione
/// nativa del sistema.
class _ShareWordButton extends StatelessWidget {
  const _ShareWordButton({required this.onShare, required this.accento});

  final VoidCallback onShare;

  /// L'accento del Maestro del giorno, deciso una volta sola dalla scheda.
  final Color accento;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      key: const Key('gift_share_word'),
      onPressed: onShare,
      style: TextButton.styleFrom(
        foregroundColor: accento,
        padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          side: BorderSide(color: accento.withValues(alpha: 0.5)),
        ),
      ),
      icon: const Icon(Icons.ios_share_rounded, size: 16),
      label: Text(
        'Condividi la parola',
        key: const Key('alba_condividi_etichetta'),
        style: TypographyTokens.didascalia()
            .copyWith(color: accento, letterSpacing: 0.5),
      ),
    );
  }
}

/// Indicatore discreto dei giorni consecutivi di rito compiuto.
class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.days, required this.accento});

  /// L'accento del Maestro del giorno, deciso una volta sola dalla scheda.
  final Color accento;

  final int days;

  @override
  Widget build(BuildContext context) {
    final label = days == 1 ? 'Primo giorno' : '$days giorni di fila';
    return Container(
      key: const Key('gift_streak'),
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        color: _dayInset,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wb_twilight_rounded, size: 14, color: accento),
          const SizedBox(width: 6),
          Text(
            label,
            key: const Key('alba_giorni_di_fila'),
            style: TypographyTokens.didascalia().copyWith(
              color: accento,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// La chiave a video di un'etichetta della base, ricavata dal suo testo.
///
/// Serve alla misura del contrasto, ordine P voce 11: la tabella deve poter
/// trovare a video ogni testo di cui dichiara il contrasto, e una chiave
/// scritta a mano per ciascuna riga sarebbe un secondo elenco da tenere
/// allineato con le righe vere.
String chiaveDi(String etichetta) =>
    etichetta.toLowerCase().replaceAll(' ', '_').replaceAll('\'', '');
