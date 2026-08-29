import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/sigilli/ora_rituale.dart';

import '../sigilli/regia_del_cammino.dart';

import '../../core/rituals/daily_elements.dart';
import '../../design_system/components/riga_del_dono.dart';

import '../../core/maestro/maestro.dart';
import '../../core/rituals/arcano_del_giorno.dart';
import '../../core/tarot/tarot_card.dart';
import '../tarot/tarot_card_art.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'ritual_view.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';

/// L'ARCANO DEL GIORNO, dominio Medora. Ordine AS voce 08.
///
/// **Era l'Oracolo del Giorno**, cioe' una riga presa a giro da un elenco di
/// ventidue frasi, uguale per tutti e legata al giorno dell'anno: si leggeva
/// come un biscotto della fortuna. Adesso e' l'estrazione di UNA CARTA dei soli
/// Arcani Maggiori, con la sua immagine e il significato che il progetto ha
/// gia' scritto per la Stesa.
///
/// **Il gesto registrato nel cammino resta `oracolo`**, come l'ordine chiede:
/// il dono cambia natura, ma i traguardi che lo nominano non si spostano di un
/// gradino.
///
/// La rivelazione arriva al giroscopio sul device, inclinando il telefono; qui,
/// e sempre, il ripiego universale e' lo scorrimento del dito. La carta e'
/// deterministica dal giorno: la stessa per tutta la giornata, e se la riapri
/// e' quella.
class DayOracleScreen extends StatefulWidget {
  const DayOracleScreen({super.key, this.now});

  final DateTime? now;

  static Route<void> route({DateTime? now}) => PassaggioDelCerchio.rotta<void>((_) => MaestroScope(child: DayOracleScreen(now: now)));

  @override
  State<DayOracleScreen> createState() => _DayOracleScreenState();
}

class _DayOracleScreenState extends State<DayOracleScreen> {
  /// Quante volte si e' chiesto di riprovare. Cambia la chiave della vista,
  /// cosi' il rito riparte davvero invece di restare dov'era.
  int _tentativo = 0;

  @override
  Widget build(BuildContext context) {
    final date = widget.now ?? DateTime.now();
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final carta = ArcanoDelGiorno.di(date);

    return RitualView(
      key: ValueKey('oracolo_$_tentativo'),
      title: 'Arcano del Giorno',
      palette: palette,
      rito: DailyElement.oracle,
      // Slot del fondale condiviso: qui si cabla il PNG dell'oracolo quando
      // arrivera'. Per ora null, fondo procedurale coerente col cosmo.
      backgroundAsset: null,
      // IL GIROSCOPIO ADESSO C'E' DAVVERO, ordine P voce 16.
      //
      // **Il modo esatto in cui l'Oracolo non funzionava.** Il gesto dichiarato
      // qui era `swipe`, e `RitualGesture` non aveva nemmeno un valore per
      // l'inclinazione: nessuna riga di questa app leggeva il giroscopio per
      // l'Oracolo. Intanto il commento in testa al file diceva "la rivelazione
      // arriva al giroscopio sul device" e la riga a schermo diceva "Inclina il
      // telefono": l'app chiedeva un gesto che non aveva nessun effetto, e chi
      // lo faceva non poteva capire perche' non succedesse niente. Non era un
      // dato mancante ne' una condizione rara: era una promessa scritta in due
      // punti e mantenuta in nessuno.
      //
      // Il ripiego tattile resta obbligatorio e sta dentro `RitualGesture.tilt`:
      // tocco e scorrimento svelano comunque.
      gesture: RitualGesture.tilt,
      // NESSUNO STATO SENZA USCITA. L'oracolo di oggi nasce da una funzione
      // locale e deterministica, quindi non c'e' nessuna rete che possa non
      // tornare: il ripiego scatta solo se il corpus restasse senza righe, che
      // e' una cintura e non un caso atteso. Esiste perche' il giorno che
      // l'Oracolo passasse da un motore vero, il posto dove agganciarlo c'e'
      // gia', invece di essere una schermata muta da scoprire sul telefono.
      ripiego: carta.upright.trim().isEmpty
          ? (
              etichetta: 'La carta di oggi non si è lasciata leggere. '
                  'Non è colpa tua: riprova fra un istante.',
              riprova: () => setState(() => _tentativo++),
            )
          : null,
      // L'ORACOLO ENTRA NEL CAMMINO, ordine P voce 35: alla rivelazione, che
      // e' il momento in cui il dono e' davvero ricevuto.
      // **QUALE ARCANO E' USCITO, ordine BX voce 01.** Il corpus chiede "lo
      // stesso Arcano del Giorno esce due volte in una settimana", e il gesto
      // arrivava nudo: la regia sapeva che l'Arcano era stato ricevuto, non
      // quale fosse.
      onReveal: () => unawaited(RegiaDelCammino.dopoUnGesto(
          context, 'oracolo',
          oraRituale: OraRituale.diAdesso(adesso: date),
          dettagli: {'arcano': [carta.stem]})),
      // COSA STAI PER RICEVERE, prima del gesto: nessuno compie un gesto senza
      // sapere cosa ne esce.
      cosaRicevi: 'Una carta degli Arcani Maggiori, la tua per tutta la '
          'giornata: non cambia se la riapri.',
      prompt: 'Inclina o scorri per rivelare',
      sensorHint:
          'Inclina il telefono, oppure scorri col dito: il ripiego tattile vale sempre.',
      // **COSA E' IL DISCO, ordine S voce 12.** Funzionava e non diceva cosa
      // fosse: chi lo guardava non capiva ne' cosa stesse guardando ne' cosa
      // ottenesse muovendolo. Delle due strade dell'ordine si e' presa la prima,
      // il disco resta e acquista un senso: e' la ruota del cielo di questo
      // momento, con le dodici case e i corpi che vi stanno adesso, e muovendo il
      // telefono ci si guarda dentro.
      cosaEIlVisivo: 'La carta che il giorno ti ha messo davanti.',
      // **IL LIVELLO VISIVO E' LA CARTA VERA, ordine AS voce 08.** Prima era un
      // disco procedurale che nessuno sapeva cosa fosse, tanto che l'ordine S
      // voce 12 aveva dovuto scrivergli accanto una didascalia per spiegarlo;
      // adesso e' l'arte del mazzo, la stessa che la Stesa mostra, e finche' il
      // gesto non e' compiuto la carta resta coperta dal suo dorso.
      //
      // **Il pittore del disco e' stato TOLTO, non spento.** Un pittore che
      // nessuno usa e' codice che nessuno mantiene e che il giorno dopo
      // qualcuno crede vivo: se la ruota del cielo tornera', tornera' con una
      // scena sua, e la storia sta nel registro di git.
      visualBuilder: (context, revealed, t, inclinazione) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
          child: AspectRatio(
            aspectRatio: 0.62,
            child: revealed
                ? TarotCardArt(card: carta, palette: palette)
                : Image.asset(TarotDeck.dorsoFull, fit: BoxFit.contain),
          ),
        ),
      ),
      revealed: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chi parla, prima del responso.
          RigaDelDono(
            dono: DailyElement.oracle,
            giorno: date,
            superficie: ColorTokens.neutralDeepest,
          ),
          // **IL COLPO D'OCCHIO PRIMA DEL TESTO**, che e' la regola di casa
          // sull'anatomia del responso: il nome della carta, poi una frase
          // sola, poi il responso. Chi ha fretta si ferma alla frase e ha
          // gia' avuto la sua risposta.
          Text(carta.name,
              key: const Key('arcano_nome'),
              style: TypographyTokens.cerimoniale()
                  .copyWith(color: palette.goldSoft)),
          const SizedBox(height: SpacingTokens.xs),
          Text(carta.uprightSummary,
              key: const Key('arcano_sommario'),
              style: TypographyTokens.lettura()
                  .copyWith(color: palette.goldSoft, height: 1.4)),
          const SizedBox(height: SpacingTokens.sm),
          Text(carta.upright,
              key: const Key('arcano_responso'),
              style: TypographyTokens.corpo()
                  .copyWith(color: ColorTokens.textPrimary, height: 1.5)),
        ],
      ),
    );
  }
}
