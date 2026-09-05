import 'package:flutter/material.dart';

import '../../core/sigilli/bonus_della_condivisione.dart';
import '../../core/maestro/maestro.dart';
import '../../core/sigilli/sentieri.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/components/titolo_che_non_si_spezza.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/components/icona_degli_eos.dart';
import 'package:provider/provider.dart';
import '../../core/entitlement/question_allowance.dart';
import '../../design_system/transizioni/velo_del_cerchio.dart';

/// LA CARD CONDIVISIBILE DI UN TRAGUARDO, nel formato unico gia' in uso.
///
/// Stesso impianto delle altre card del Cerchio (stesa, oroscopo, animale):
/// cornice oro sul buio, il nome in cerimoniale, la frase del Maestro, il
/// marchio in fondo. Cambia il contenuto, non la grammatica.
class CardDelTraguardo extends StatelessWidget {
  const CardDelTraguardo({
    super.key,
    required this.traguardo,
    required this.sentiero,
    this.quando,
  });

  final Traguardo traguardo;
  final Sentiero sentiero;

  /// Quando questo traguardo si e' acceso, se il diario lo sa. Richiesta del
  /// fondatore del 17 agosto 2026: "vorrei che ci fosse anche una scritta con
  /// obiettivo raggiunto il [data e ora]". Ordine BD voce 06.
  ///
  /// **Puo' mancare, e allora la scritta NON c'e'.** Il diario custodisce
  /// l'istante dall'ordine AP: i Sigilli accesi prima non hanno data, e la
  /// regola gia' scritta in `quandoSiEAcceso` vale anche qui, non se ne
  /// inventa una.
  final DateTime? quando;

  /// La data e l'ora nella forma di casa, senza pacchetti: 23/08/2026 alle
  /// 19:04. Due cifre fisse, cosi' l'otto di sera non diventa un "8:4".
  static String dataEOra(DateTime istante) {
    String due(int v) => v.toString().padLeft(2, '0');
    return '${due(istante.day)}/${due(istante.month)}/${istante.year} '
        'alle ${due(istante.hour)}:${due(istante.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      key: const Key('card_del_traguardo'),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.surfaceElevated, palette.deepest],
        ),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        border: Border.all(color: palette.gold.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            // UNO SOLO, quindi la forma SINGOLARE, dichiarata: questa
            // etichetta nomina il traguardo che si e' appena acceso, che e'
            // uno.
            traguardo.eGrande
                ? sentiero.grande.singolare.toUpperCase()
                : sentiero.mini.singolare.toUpperCase(),
            style: TypographyTokens.etichetta().copyWith(
              color: palette.goldSoft,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          // Il nome non si spezza in mezzo a una parola, ordine AS voce 05.
          TitoloCheNonSiSpezza(
            traguardo.nome,
            key: const Key('card_nome_del_traguardo'),
            allineamento: TextAlign.start,
            stile: TypographyTokens.cerimoniale()
                .copyWith(color: ColorTokens.textPrimary),
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(traguardo.frase,
              style: TypographyTokens.corpo()
                  .copyWith(color: ColorTokens.textSecondary, height: 1.45)),
          if (quando != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            Text('Obiettivo raggiunto il ${dataEOra(quando!)}',
                key: const Key('card_quando_raggiunto'),
                style: TypographyTokens.didascalia()
                    .copyWith(color: palette.goldSoft)),
          ],
          const SizedBox(height: SpacingTokens.md),
          Row(
            children: [
              IconaDegliEos(misura: 16, colore: palette.goldSoft),
              const SizedBox(width: SpacingTokens.xs),
              Text('${traguardo.eos} Eos',
                  style: TypographyTokens.etichetta()
                      .copyWith(color: palette.goldSoft)),
              const Spacer(),
              Text(sentiero.titolo,
                  style: TypographyTokens.didascalia()
                      .copyWith(color: ColorTokens.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

/// LE VIE DELLA CONDIVISIONE, uguali in tutte e due le forme della
/// celebrazione e uguali quando si riapre la card dal journal.
///
/// **Perche' un componente e non tre copie.** L'ordine chiede che il pulsante
/// di condivisione ci sia a schermo pieno, in sovrimpressione e sul Sigillo
/// gia' acceso, e che porti sempre allo stesso bonus. Tre copie diventerebbero
/// tre bonus diversi al primo ritocco.
class VieDellaCondivisione extends StatelessWidget {
  const VieDellaCondivisione({
    super.key,
    required this.suScelta,
    this.compatte = false,
  });

  final void Function(ModoDellaCondivisione modo) suScelta;

  /// In sovrimpressione c'e' meno spazio: un pulsante solo, che apre le tre
  /// vie. La via resta la stessa, cambia quanto posto occupa.
  final bool compatte;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    if (compatte) {
      return TextButton.icon(
        key: const Key('condividi_traguardo_compatto'),
        onPressed: () => _apriLeVie(context),
        icon: Icon(Icons.ios_share_rounded, size: 18, color: palette.goldSoft),
        label: Text('Condividi',
            style:
                TypographyTokens.etichetta().copyWith(color: palette.goldSoft)),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final modo in ModoDellaCondivisione.values) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: Key('condividi_${modo.motivo}'),
              onPressed: () => suScelta(modo),
              style: FilledButton.styleFrom(
                backgroundColor: palette.surfaceElevated,
                foregroundColor: palette.goldSoft,
                side: BorderSide(color: palette.gold.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
              ),
              icon: Icon(_iconaDi(modo), size: 18),
              label: Text(modo.etichetta, style: TypographyTokens.etichetta()),
            ),
          ),
          // **QUANDO ARRIVA IL PREMIO, DETTO PRIMA DEL TOCCO**, ordine AN
          // voce 08: ogni via dice cosa fa arrivare i suoi Eos, e la frase
          // non promette piu' di quanto il codice sappia. Per l'invito, che
          // aspetta un'attribuzione che ancora non esiste, si dichiara anche
          // l'attesa invece di far credere a un accredito immediato.
          Padding(
            padding: const EdgeInsets.only(
                left: SpacingTokens.xs, top: 2, bottom: SpacingTokens.xs),
            child: Text(
              // **UNA RIGA, NON TRE, ordine AS voce 05.** La coda "per ora
              // resta in attesa, te li accrediteremo appena sapremo del suo
              // arrivo" spiegava il funzionamento dell'attribuzione: e' la
              // ragione dietro la risposta, non la risposta. Chi legge vuole
              // sapere QUANDO arrivano gli Eos, e adesso lo legge in quattro
              // parole invece che in tre righe di grigio.
              // **E QUANTI EOS SI GUADAGNANO, in testa alla riga.** Ordine
              // BB voce 04, richiesta del fondatore: "le card con il tasto
              // condivisione dovrebbero riportare il numero di EOS che si
              // guadagnano se si fa una condivisione pubblica in modo che
              // l'utente sia incentivato".
              //
              // **Il numero lo dice il server e non e' scritto qui.** Arriva
              // col listino dentro lo stato del Cerchio: se domani un invito
              // vale settanta invece di sessanta, **questa frase cambia da
              // sola** e nessuno deve ricordarsi di venire a correggerla.
              //
              // **E quando il server non lo ha ancora detto, non si inventa**:
              // la riga resta quella di prima, che dice QUANDO arriva il
              // premio senza dire quanto. Un numero di ripiego scritto nel
              // client sarebbe una promessa che il Cerchio non ha fatto.
              _rigaDelPremio(context, modo),
              key: Key('quando_arriva_${modo.motivo}'),
              style: TypographyTokens.didascalia()
                  .copyWith(color: ColorTokens.textMuted, height: 1.35),
            ),
          ),
        ],
      ],
    );
  }

  /// La riga sotto il pulsante: quanti Eos, e quando arrivano.
  ///
  /// **Il quanto viene dal server**, il quando dal modo. Se il primo manca si
  /// dice solo il secondo: vedi il commento al punto di chiamata.
  String _rigaDelPremio(BuildContext context, ModoDellaCondivisione modo) {
    int? quanti;
    try {
      quanti =
          context.watch<QuestionAllowance>().eosPerLaCondivisione(modo.motivo);
    } catch (senzaBorsellino) {
      // Nelle anteprime e nelle prove mirate non c'e' nessun borsellino da
      // interrogare, e la riga resta quella senza numero.
      quanti = null;
    }
    final coda = modo.subitoPagato ? '' : ' In attesa.';
    // **SENZA IL NUMERO LA FRASE COMINCIA DA CAPO, e non da "Eos".** Ordine
    // BX: la riga era composta come "$quanti Eos ..." con la parola Eos
    // dentro il testo del modo, quindi quando il numero mancava a schermo si
    // leggeva "Eos quando il tuo amico entra nel Cerchio". L'ha visto
    // l'anteprima della festa del primo sogno.
    if (quanti == null) {
      final q = modo.quandoArriva;
      return '${q[0].toUpperCase()}${q.substring(1)}$coda';
    }
    return '$quanti Eos ${modo.quandoArriva}$coda';
  }

  void _apriLeVie(BuildContext context) {
    foglioDelCerchio<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (foglio) => Container(
        key: const Key('vie_della_condivisione'),
        padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
            SpacingTokens.lg, SpacingTokens.xl),
        decoration: BoxDecoration(
          color: context.palette.surfaceElevated,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SpacingTokens.radiusXl)),
        ),
        child: SafeArea(
          top: false,
          child: VieDellaCondivisione(suScelta: (modo) {
            Navigator.of(foglio).pop();
            suScelta(modo);
          }),
        ),
      ),
    );
  }

  static IconData _iconaDi(ModoDellaCondivisione modo) => switch (modo) {
        ModoDellaCondivisione.invitoConDownload => Icons.person_add_alt_1,
        ModoDellaCondivisione.socialPubblico => Icons.public_rounded,
        ModoDellaCondivisione.condivisionePrivata => Icons.send_rounded,
      };
}

/// LA PALETTE DEL SENTIERO: il colore del Maestro che lo governa.
MaestroPalette paletteDelSentiero(Sentiero sentiero) =>
    MaestroPalette.forKey(ThemeKey.of(sentiero.maestro));
