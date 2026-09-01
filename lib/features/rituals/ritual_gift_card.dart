import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/quality/quality_tier.dart';
import '../../core/rituals/daily_elements.dart';
import '../../core/rituals/dawn_gift.dart';
import '../../core/rituals/filo_del_giorno.dart';
import '../../design_system/components/le_tre_righe_del_rito.dart';
import '../../design_system/components/riga_del_dono.dart';
import '../../design_system/theme/abito_del_responso.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../core/condivisione/premio_della_condivisione.dart';

// I COLORI NON VIVONO PIU' QUI, E ADESSO NEMMENO UNO. Ordine P voce 12, poi
// ordine BB voce 09.
//
// **Il primo passo, l'ordine P.** Erano tre costanti private, e una costante
// privata non e' un token: non si enumera, non si misura e non si sorveglia.
// Finche' i regimi cromatici erano due e uno solo era governato dai token,
// nessun presidio automatico poteva proteggere l'altro, ed e' cosi' che il
// difetto delle etichette illeggibili e' nato. Sono passate in `RegimeChiaro`,
// col contrasto misurato e una guardia che lo sorveglia.
//
// **Il secondo passo, l'ordine BB.** Erano diventate token, ma restavano
// UNICHE: `_dayInk`, `_dayInkSoft`, `_dayInset`, `_dayGlass`, lette da questo
// file e dai suoi sottocomponenti, uguali per tutti e cinque i Doni. **E' il
// motivo per cui il Soffio del Destino somigliava al Rito dell'Alba**: non era
// una svista di stile, era una scheda sola travestita da cinque. Adesso i
// colori arrivano da `AbitoDelResponso`, che ne conosce due, e la scheda
// chiede quale le tocca al Dono che sta mostrando.

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
    this.azioni,
  });

  /// **LE TRE AZIONI SOTTO IL RESPONSO, ordine CG voci 06 e 08.**
  ///
  /// La scheda non le costruisce: non sa quale Dono sta mostrando ne' quale
  /// testo la persona debba poter custodire. Le costruisce la schermata e le
  /// posa qui, dove prima stava il solo Condividi della parola.
  ///
  /// Nulla nelle prove che montano la scheda da sola, e in quel caso al suo
  /// posto resta il vecchio pulsante: una scheda che sparisse per un
  /// parametro mancante sarebbe un difetto peggiore di quello che questa voce
  /// cura.
  final Widget? azioni;

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
    // **L'ABITO NASCE QUI, dal Dono, e scende ai figli come parametro.**
    // Ordine BB voce 09: prima i colori erano costanti di questo file,
    // lette direttamente anche dai sottocomponenti, ed e' il motivo per
    // cui cinque riti diversi portavano la stessa identica scheda.
    final abito = AbitoDelResponso.di(widget.dono);
    final accento = abito.accentoDi(gift.maestro);

    // **IL BLUR SEGUE IL QUALITY TIER, ordine BF voce 05.f.** Era l'unico
    // BackdropFilter dell'app SENZA il cancello della qualita': depth_card e
    // feature_tile lo lasciano cadere sui telefoni bassi, questa scheda
    // sfocava sempre, a sigma 18, su ogni fotogramma di Impeller. Senza
    // effetti pieni il vetro diventa quasi pieno NEL COLORE DEL SUO ABITO
    // (il giorno resta giorno, la notte resta notte): il contenuto dietro
    // sparisce invece di intravedersi, che e' cio' che il blur otteneva.
    final bool effettiPieni = (() {
      try {
        return context.watch<QualityTierController>().richEffects;
      } catch (errore) {
        return false;
      }
    })();
    final Widget vetro = Container(
      decoration: BoxDecoration(
        color: effettiPieni
            ? abito.velatura
            : abito.velatura.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: abito.bordo),
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
              superficie: abito.superficiePeggiore,
            ),
            // LE TRE RIGHE DEL RITO, ordine P voce 17: cosa fai, perche', e
            // cosa ti resta. In testa, prima di tutto il resto.
            LeTreRigheDelRito(
              rito: widget.dono,
              inchiostro: abito.inchiostro,
              accento: accento,
              // Il perche' scende nella base apribile, ordine AS voce 06:
              // qui sopra restano cosa fai e cosa ti resta, che sono la
              // risposta.
              conIlPerche: false,
            ),
            const SizedBox(height: SpacingTokens.md),
            // **VIA L'ETICHETTA DEL TIPO DI DONO. Ordine AS voce 06.**
            //
            // Diceva "Orientamento del giorno", "Intenzione del giorno" o
            // "Monito del giorno": e' la CATEGORIA del contenuto, cioe' come
            // lo chiamiamo noi, non cosa dice alla persona. Chi apre l'alba
            // vuole sapere cosa fare oggi, e sopra c'e' gia' la riga che
            // dice chi parla. La regola trasversale di quest'ordine dice che
            // dove un testo si puo' togliere, si toglie invece di
            // rimpicciolirlo: e questo si poteva togliere.
            //
            // Il tipo resta nel DATO, `gift.kind`, dove serve a chi compone
            // il dono: sparisce dallo schermo, non dal modello.
            // **L'ORIENTAMENTO E' IL RESPONSO DEL DONO, ordine BV voce
            // 06**: sale alla misura di lettura come il consiglio di
            // Medora. Resta un `Text` e non passa dalla porta unica
            // perche' questa e' una CARTA, un oggetto stampato che si
            // condivide: spezzarlo in paragrafi ne cambierebbe
            // l'ingombro, e l'ingombro qui e' fisso.
            Text(
              gift.orientation,
              key: const Key('alba_orientamento'),
              style:
                  TypographyTokens.lettura().copyWith(color: abito.inchiostro),
            ),
            // **LA PAROLA DEL GIORNO, SOLO ALL'ALBA E COL SUO SIGNIFICATO.**
            // Ordine BB voce 06.
            //
            // **La domanda del fondatore era "cosa ne faccio adesso di
            // questa parola?", e aveva ragione perche' la risposta non
            // c'era.** La parola compariva grande e sola: un titolo senza
            // testo. Chi la leggeva cercava cosa farne e non trovava nulla,
            // e quel vuoto se lo portava dietro per tutto il rito.
            //
            // **Il legame esisteva gia' nel corpus e non arrivava a
            // schermo.** Ogni parola porta con se' il suo `perche`, cioe'
            // cosa indica in questo giorno, e l'ordine AS voce 06 aveva gia'
            // fatto in modo che la parola nascesse dal GESTO e non da un
            // terzo seme. Mancava l'ultimo passo: mostrarlo. Adesso sotto la
            // parola si legge cosa vuol dire, ed e' quello a rispondere alla
            // domanda.
            //
            // **Solo all'Alba.** Nel Soffio del Destino la parola non
            // compare: e' il rito dell'aria e del destino, non quello della
            // parola da portarsi dietro, e la stessa cosa in due riti
            // diversi li fa sembrare lo stesso rito.
            if (widget.dono == DailyElement.dawn && word != null) ...[
              const SizedBox(height: SpacingTokens.lg),
              Text(
                'Parola del giorno',
                key: const Key('alba_etichetta_parola'),
                style: TypographyTokens.didascalia().copyWith(
                  color: abito.inchiostroMuto,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: SpacingTokens.xs),
              Text(
                word,
                key: const Key('gift_word'),
                style: TypographyTokens.cerimonialeGrande().copyWith(
                  color: accento,
                  letterSpacing: 1.4,
                ),
              ),
              // **E SUBITO SOTTO, COSA VUOL DIRE.** E' la riga che mancava:
              // senza, la parola resta un titolo senza testo.
              if (gift.rito?.perche != null) ...[
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  gift.rito!.perche,
                  key: const Key('alba_perche_della_parola'),
                  style: TypographyTokens.corpo()
                      .copyWith(color: abito.inchiostro, height: 1.4),
                ),
              ],
            ],
            // **E NEMMENO IL PONTE VERSO IL SOFFIO.** Ordine BB voce 07,
            // parole del fondatore: "nel rito dell'Alba c'e' un testo
            // collegato che porta al soffio del destino, perche'?
            // Eliminalo."
            //
            // **Un dono del giorno non fa da corridoio a un altro dono.**
            // La riga era nata nell'ordine S voce 13 per togliere il respiro
            // guidato dall'Alba, ed era giusta allora: il rito del mattino
            // non doveva contenere il rito della sera. Ma la porta lasciata
            // al suo posto ha lo stesso difetto in piccolo, perche' ognuno
            // dei doni ha la sua ora e il suo posto nella fascia, e chi
            // arriva all'Alba non deve essere mandato altrove.
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
                  color: abito.incasso,
                  border: Border.all(color: accento.withValues(alpha: 0.4)),
                ),
                child: Text(
                  FiloDelGiorno.richiamoDellaDomanda(widget.domandaDiIeri!),
                  key: const Key('alba_domanda_di_ieri'),
                  style: TypographyTokens.didascalia()
                      .copyWith(color: abito.inchiostro, height: 1.4),
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
                  ? _BasePanel(
                      abito: abito,
                      source: gift.source,
                      // **IL PERCHE' DEL RITO STA QUI DENTRO**, ordine AS
                      // voce 06: la base e' il posto delle ragioni, ed e'
                      // apribile da chi le cerca.
                      percheDelRito: widget.dono.perche,
                    )
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
                if (word != null && widget.azioni == null)
                  _ShareWordButton(onShare: widget.onShare, accento: accento),
                if (widget.streak >= 1)
                  _StreakChip(
                      abito: abito, days: widget.streak, accento: accento),
              ],
            ),
            // **LE TRE AZIONI, quando la schermata le ha posate.** Stanno
            // sotto la fila delle pastiglie e non dentro: il Custodisci e il
            // Parlane non sono etichette, sono gesti, e un gesto in mezzo
            // alle pastiglie si legge come una di loro.
            if (widget.azioni != null) ...[
              const SizedBox(height: SpacingTokens.md),
              widget.azioni!,
            ],
          ],
        ),
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: effettiPieni
          ? BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: vetro,
            )
          : vetro,
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
  const _BasePanel(
      {required this.abito, required this.source, this.percheDelRito});

  /// L'abito deciso dalla scheda: qui non si sceglie niente da capo.
  final AbitoDelResponso abito;

  final GiftSource source;

  /// **PERCHE' QUESTO RITO, ordine AS voce 06.** Era la seconda delle tre
  /// righe in cima alla scheda, e in cima ci sta la risposta: qui e' al suo
  /// posto, accanto alle altre ragioni, e la legge chi apre la base.
  final String? percheDelRito;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('gift_base_panel'),
      width: double.infinity,
      margin: const EdgeInsets.only(top: SpacingTokens.sm),
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: abito.incasso,
        border: Border.all(color: abito.inchiostroMuto.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (percheDelRito != null)
            _BaseRow(
              abito: abito,
              label: 'Perché questo rito',
              value: percheDelRito!,
              provisional: false,
            ),
          _BaseRow(
            abito: abito,
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
              abito: abito,
              label: 'Transito attivo oggi',
              value: source.transit!,
              provisional: false,
            ),
          ],
          if (source.tradition != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            _BaseRow(
              abito: abito,
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
    required this.abito,
    required this.label,
    required this.value,
    required this.provisional,
  });

  final AbitoDelResponso abito;

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
                key: Key('alba_base_etichetta_${chiaveDi(label)}'),
                style: TypographyTokens.didascalia().copyWith(
                  color: abito.inchiostroMuto,
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
          key: Key('alba_base_valore_${chiaveDi(label)}'),
          style: TypographyTokens.corpo().copyWith(
            color: provisional ? abito.inchiostroMuto : abito.inchiostro,
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
        PremioDellaCondivisione.etichetta(context, base: 'Condividi la parola'),
        key: const Key('alba_condividi_etichetta'),
        style: TypographyTokens.didascalia()
            .copyWith(color: accento, letterSpacing: 0.5),
      ),
    );
  }
}

/// Indicatore discreto dei giorni consecutivi di rito compiuto.
class _StreakChip extends StatelessWidget {
  const _StreakChip(
      {required this.abito, required this.days, required this.accento});

  final AbitoDelResponso abito;

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
        color: abito.incasso,
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
