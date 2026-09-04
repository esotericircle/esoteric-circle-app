import 'dart:async';
import '../maestri/chat/chat_openers.dart';
import '../ricordi/azioni_del_responso.dart';

import 'package:flutter/material.dart';
import '../../core/sigilli/ora_rituale.dart';

import '../sigilli/regia_del_cammino.dart';

import '../../core/rituals/daily_elements.dart';
import '../../design_system/components/da_dove_nasce.dart';
import '../../design_system/components/riga_del_dono.dart';
import '../../design_system/theme/abito_del_responso.dart';

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
import '../../design_system/typography/paragrafi_di_lettura.dart';
import 'package:provider/provider.dart';
import '../../core/identity/natal_identity.dart';

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

  static Route<void> route({DateTime? now}) => PassaggioDelCerchio.rotta<void>(
      (_) => MaestroScope(child: DayOracleScreen(now: now)));

  @override
  State<DayOracleScreen> createState() => _DayOracleScreenState();
}

/// La data di nascita, se c'e', senza pretendere il provider.
///
/// **Un `context.read` preteso in un punto condiviso fa cadere lontano**: e'
/// una lezione gia' pagata da questo progetto, con quaranta prove cadute
/// altrove. Qui il Dono si apre anche dove il provider non c'e'.
DateTime? _forseLaNascita(BuildContext context) {
  try {
    return context.read<BirthIdentityController>().details?.date;
  } catch (errore) {
    return null;
  }
}

class _DayOracleScreenState extends State<DayOracleScreen> {
  /// Quante volte si e' chiesto di riprovare. Cambia la chiave della vista,
  /// cosi' il rito riparte davvero invece di restare dov'era.
  int _tentativo = 0;

  @override
  Widget build(BuildContext context) {
    final date = widget.now ?? DateTime.now();
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    // **LA CARTA E' TUA, non del calendario.** Ordine CE voce 13: qui entra
    // la data di nascita, e con lei la carta di nascita dei tarocchi. Chi non
    // l'ha data riceve comunque il Dono, con la carta del giorno.
    final nascita = _forseLaNascita(context);
    final carta = ArcanoDelGiorno.di(date, nascita: nascita);

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
      onReveal: () => unawaited(RegiaDelCammino.dopoUnGesto(context, 'oracolo',
          oraRituale: OraRituale.diAdesso(adesso: date),
          dettagli: {
            'arcano': [carta.stem]
          })),
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
            // **IL FONDO DICHIARATO E' QUELLO VERO, ordine CQ voce 6.04.**
            //
            // Qui c'era `ColorTokens.neutralDeepest`, cioe' quasi nero, e
            // **sotto questa riga non c'e' quasi nero**: c'e' il cosmo. Il
            // meccanismo del contrasto porta il blu di Medora fino a
            // toccare 4,58 SULLA SUPERFICIE DICHIARATA, con otto centesimi
            // di margine sulla soglia; sul fondo vero quello stesso blu
            // misura **3,15**, e il fondatore lo ha visto: *una riga di
            // testo blu che non si vede sullo sfondo cosmico*.
            //
            // `AbitoDelResponso` dichiara gia' il fondo PEGGIORE che una
            // lettera puo' trovarsi sotto, e la scheda dei Doni lo usava
            // gia': qui e nelle altre due schermate no. Con la superficie
            // vera il blu sale a #5A94FF e misura 4,83.
            superficie: AbitoDelResponso.di(DailyElement.oracle
                ).superficiePeggiore,
          ),
          // **IL COLPO D'OCCHIO PRIMA DEL TESTO**, che e' la regola di casa
          // sull'anatomia del responso: il nome della carta, poi una frase
          // sola, poi il responso. Chi ha fretta si ferma alla frase e ha
          // gia' avuto la sua risposta.
          //
          // **E DA OGGI LA FRASE STA SOPRA IL NOME. Ordine CO voce 17**, 3
          // settembre 2026. La gerarchia dettata dal fondatore vuole al primo
          // posto un titolo diretto che sia GIA' UNA RISPOSTA, e "La Ruota
          // della Fortuna" e' un nome: dice quale carta e' uscita, non che
          // cosa dice oggi. **Il sommario invece e' esattamente una risposta
          // in una frase**, e c'era gia': stava sotto, in corpo piu' piccolo,
          // dove chi legge la prima riga e chiude non lo incontrava.
          //
          // Il nome non se ne va e non si rimpicciolisce per svalutarlo: sale
          // a fare da occhiello, che e' il posto di cio' che dice DI CHI e' la
          // voce. Sopra c'e' gia' la riga che dice quale Dono e' questo, e le
          // due cose stanno bene insieme. **L'artwork della carta resta il
          // livello visivo, e nessuno ha bisogno del nome scritto grande per
          // riconoscerla: ce l'ha davanti.**
          Text(carta.name.toUpperCase(),
              key: const Key('arcano_nome'),
              style: TypographyTokens.didascalia(weight: 600).copyWith(
                  color: palette.goldSoft.withValues(alpha: 0.85),
                  letterSpacing: 1.2)),
          const SizedBox(height: SpacingTokens.xxs),
          Text(carta.uprightSummary,
              key: const Key('arcano_sommario'),
              style: TypographyTokens.cerimoniale()
                  .copyWith(color: palette.goldSoft, height: 1.25)),
          const SizedBox(height: SpacingTokens.sm),
          // **IL RESPONSO DELL'ARCANO ALLA MISURA DEL RESPONSO.** Ordine CE
          // voce 10: stava a `corpo()`, cioe' sedici punti, mentre il
          // responso dei Tarocchi ne ha diciotto. E' lo stesso gesto, letto
          // per intero, e adesso ha la stessa misura.
          ParagrafiDiLettura(
              key: const Key('arcano_responso'),
              testo: carta.upright,
              stile: TypographyTokens.lettura()
                  .copyWith(color: ColorTokens.textPrimary)),
          const SizedBox(height: SpacingTokens.md),
          // **LA FONTE, BREVE E IN FONDO.** Ordine CQ voce 2.01, 4 settembre
          // 2026, e chiude il quinto strato della legge dei testi.
          //
          // **L'Arcano era l'unico dei cinque Doni senza.** Il Tramonto ha le
          // sue fonti runiche, il Sogno la sua provenienza, l'Alba e il
          // Soffio il pannello "Da dove nasce questo dono": qui non c'era
          // niente, e chi leggeva non poteva risalire da dove venisse la
          // carta. **Una risposta che non si puo' risalire chiede di essere
          // creduta**, ed e' esattamente cio' che questa app non fa.
          //
          // La riga cambia con la persona, e dice il vero in tutti e due i
          // casi: con la nascita la carta nasce dal giorno incrociato con la
          // carta natale dei tarocchi, senza nascita nasce dal solo giorno.
          // **LA PROVENIENZA SCENDE DIETRO LA PORTA. Ordine CQ voce 6.24,**
          // 4 settembre 2026.
          //
          // Parole del fondatore: *non dico di non scrivere da dove arrivano
          // le risposte, ma non all'inizio. va bene informare, ma alla fine.*
          // Questa riga dice da dove nasce la carta, ed e' esattamente cio'
          // che va dietro un tocco: chi cerca la risposta l'ha gia' letta,
          // chi cerca professionalita' la trova qui.
          DaDoveNasce(
            palette: palette,
            children: [
              RigaDellaFonte(
                testo: nascita == null
                    ? 'Ventidue Arcani Maggiori. La carta di oggi nasce dal '
                        'giorno. Non da un caso: domani sarà un\'altra.'
                    : 'Ventidue Arcani Maggiori. La carta di oggi nasce dal '
                        'giorno incrociato con la tua carta di nascita dei '
                        'tarocchi, che la tradizione del mazzo ricava dalla '
                        'data.',
                key: const Key('arcano_provenienza'),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.lg),
          // **LE AZIONI DA UNA PORTA SOLA, ordine CG voci 06 e 08.** Qui il
          // Condividi non c'e' e non e' una dimenticanza: l'Arcano non
          // produce una carta da mandare, l'artwork del mazzo e' arte del
          // Cerchio e non un responso della persona. Restano il Custodisci e
          // il Parlane, che di un'immagine non hanno bisogno.
          AzioniDelResponso(
            palette: palette,
            maestro: Maestro.medora,
            responso: ResponsoDaCustodire(
              arte: 'oracolo',
              titolo: 'Il tuo arcano del giorno: ${carta.name}',
              testo: carta.upright,
              dati: {'carta': carta.name},
            ),
            aperturaDellaChat: ChatOpeners.oracolo(carta.name),
          ),
        ],
      ),
    );
  }
}
