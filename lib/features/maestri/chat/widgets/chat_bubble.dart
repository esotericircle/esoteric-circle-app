import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/chat/chat_message.dart';
import '../../../../core/chat/immersive_intents.dart';
import '../../../../core/chat/testo_del_responso.dart';
import '../../../../core/maestro/frase_di_ripiego.dart';
import '../../../../core/maestro/maestro.dart';
import '../../../../core/maestro/tempi_dell_attesa.dart';
import '../../../../core/quality/quality_tier.dart';
import '../../../../design_system/components/collasso.dart';
import '../../../../design_system/components/testo_che_si_scrive.dart';
import '../../../../design_system/components/user_avatar.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/theme/maestro_scope.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../widgets/maestro_bust.dart';
import 'astral_typing_indicator.dart';

/// Una bolla della conversazione.
///
/// Il messaggio del Maestro nasce da un piccolo avatar tondo e da una
/// superficie in vetro col filo d'oro, quello dell'utente da una tessera piu'
/// sobria allineata a destra. Mentre il Maestro compone, al posto del testo
/// pulsa l'indicatore astrale.
class ChatBubble extends StatefulWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.maestro,
    this.onOpenIntent,
    this.onRetry,
    this.onApprofondisci,
    this.onChiediAgliAltri,
    this.altreVoci = const [],
    this.siPuoRaccogliere = false,
    this.aperta = true,
    this.onApriChiudi,
    this.scriviti = false,
    this.durataMassimaDiScrittura = TempiDellAttesa.tettoAlTestoCompleto,
  });

  final ChatMessage message;
  final Maestro maestro;

  /// Apre la funzione immersiva instradata, dato l'id dell'intento.
  final void Function(String intentId)? onOpenIntent;

  /// Riprova questo turno. Non nullo solo sulla bolla fallita a cui il comando
  /// si riferisce: prima il "Riprova" viveva in una striscia fra la lista e la
  /// barra di scrittura, cioe' lontano dalla cosa che comanda, e chi lo vedeva
  /// doveva indovinare a cosa si riferisse.
  final VoidCallback? onRetry;

  /// Porta la stessa domanda alle altre due voci del cerchio, QUI DENTRO.
  /// Non nullo solo sull'ultima lettura vera, e solo se manca ancora qualcuno:
  /// la regola sta nel controller, che sa chi ha gia' parlato.
  final VoidCallback? onChiediAgliAltri;

  /// Chi sono gli altri due, per mostrarne i volti. Vuoto quando la riga non
  /// si mostra.
  final List<Maestro> altreVoci;


  /// Vero se questa risposta si puo' raccogliere, cioe' non e' piu' quella
  /// viva. La regola sta in `RaccoltaDelleRisposte`, qui arriva gia' decisa.
  final bool siPuoRaccogliere;

  /// Vero se il testo e' aperto. L'ultima risposta lo e' sempre.
  final bool aperta;

  /// Apre e chiude al tocco della freccetta.
  final VoidCallback? onApriChiudi;

  /// Vero SOLO sulla risposta appena arrivata, che e' l'unica che si scrive
  /// sotto gli occhi. Una risposta gia' letta, riletta scorrendo indietro,
  /// deve stare ferma: rimettersi a scrivere sarebbe una gabbia, non un effetto.
  final bool scriviti;

  /// Quanto tempo resta alla scrittura dentro il tetto dei dieci secondi. Lo
  /// calcola [TempiDellAttesa] a partire da quanto e' durata la pausa.
  final Duration durataMassimaDiScrittura;

  /// Porta questa risposta piu' a fondo. Non nullo solo sull'ultima risposta
  /// vera del Maestro. Per il Viandante NON e' nullo: l'invito si vede e al
  /// tocco porta l'invito a salire, perche' un lucchetto muto e' un vicolo
  /// cieco, e la casa non ne ammette.
  final VoidCallback? onApprofondisci;

  /// I due colori della superficie, gia' OPACHI.
  ///
  /// Prima erano gradazioni translucide, e il cosmo di sfondo passava dentro la
  /// bolla: nell'anteprima della 2128 una stella cade sopra il testo del
  /// messaggio dell'utente. La leggibilita' non puo' dipendere da dove il seme
  /// del cosmo mette una stella, quindi le stesse tinte si fondono in anticipo
  /// sul fondo della palette. A occhio la superficie e' identica, ma sotto non
  /// passa piu' niente.
  static List<Color> superficieDi(MaestroPalette palette, {required bool isUser}) {
    final fondo = palette.deepest;
    final tinte = isUser
        ? [
            palette.gold.withValues(alpha: 0.20),
            palette.gold.withValues(alpha: 0.08),
          ]
        : [
            palette.surfaceElevated.withValues(alpha: 0.95),
            palette.surface.withValues(alpha: 0.80),
          ];
    return [for (final t in tinte) Color.alphaBlend(t, fondo)];
  }

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  /// Il testo che si scrive, per poterlo COMPLETARE dal tocco sulla bolla.
  final GlobalKey<TestoCheSiScriveState> _chiaveDelTesto = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final maestro = widget.maestro;
    final onOpenIntent = widget.onOpenIntent;
    final onRetry = widget.onRetry;
    final onApprofondisci = widget.onApprofondisci;
    final onChiediAgliAltri = widget.onChiediAgliAltri;
    final altreVoci = widget.altreVoci;
    final palette = context.palette;
    final isUser = message.isUser;

    // Ferma quando la persona ha chiesto di non vedere movimento, e ferma sui
    // messaggi che non sono appena arrivati. Il contenuto non cambia mai: cio'
    // che si toglie e' il tempo che ci mette a comparire.
    final scrive = widget.scriviti &&
        !isUser &&
        !MediaQuery.of(context).disableAnimations &&
        context.watch<QualityTierController>().tier != QualityTier.low;

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.78,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: ChatBubble.superficieDi(palette, isUser: isUser),
        ),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(SpacingTokens.radiusMd),
          topRight: const Radius.circular(SpacingTokens.radiusMd),
          bottomLeft: Radius.circular(
              isUser ? SpacingTokens.radiusMd : SpacingTokens.xxs),
          bottomRight: Radius.circular(
              isUser ? SpacingTokens.xxs : SpacingTokens.radiusMd),
        ),
        border: Border.all(
          color: message.failed
              ? ColorTokens.caligoGlow.withValues(alpha: 0.5)
              : palette.gold.withValues(alpha: isUser ? 0.35 : 0.28),
          width: 1,
        ),
      ),
      child: message.pending
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: AstralTypingIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // LA RIGA DEL RACCOGLIMENTO, solo sulle risposte che non sono
                // piu' quella viva.
                //
                // Chiusa mostra la prima riga, cosi' la si ritrova senza
                // riaprirla a caso: una fila di righe uguali che dicono
                // "risposta" non aiuterebbe a scegliere quale riaprire.
                if (widget.siPuoRaccogliere)
                  GestureDetector(
                    key: const Key('chat_raccogli'),
                    onTap: widget.onApriChiudi,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        Expanded(
                          child: widget.aperta
                              ? const SizedBox.shrink()
                              : Text(
                                  message.text,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TypographyTokens.body(size: 15)
                                      .copyWith(
                                          color: ColorTokens.textSecondary),
                                ),
                        ),
                        FreccettaDelCollasso(
                          aperto: widget.aperta,
                          color: palette.goldSoft,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                Collassabile(
                  aperto: widget.aperta,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                TestoCheSiScrive(
                  key: _chiaveDelTesto,
                  testo: message.text,
                  attiva: scrive,
                  durataMassima: widget.durataMassimaDiScrittura,
                  stile: TypographyTokens.body(size: 17).copyWith(
                    color: isUser
                        ? ColorTokens.textPrimary
                        : palette.textPrimary,
                    height: 1.5,
                  ),
                  // L'ENFASI SUI NOMI NOTI E' NOSTRA, e non del modello.
                  //
                  // Nella bolla dell'utente no: li' scrive la persona, e
                  // colorarle le parole sarebbe correggerla. E nemmeno quando
                  // non c'e' niente da mettere in risalto: comporre un testo
                  // ricco senza motivo toglie il `data` al widget, e ogni prova
                  // che cerca una frase a schermo smette di trovarla.
                  componi: isUser ||
                          !TestoDelResponso.portaUnNomeNoto(message.text)
                      ? null
                      : (testo, stile) => TextSpan(
                            children: [
                              for (final pezzo
                                  in TestoDelResponso.pezzi(testo))
                                TextSpan(
                                  text: pezzo.testo,
                                  style: pezzo.inOro
                                      ? stile.copyWith(
                                          color: palette.goldSoft,
                                          fontWeight: FontWeight.w600,
                                        )
                                      : stile,
                                ),
                            ],
                          ),
                ),
                // Un ripiego lo dichiara la bolla stessa, sotto il testo: la
                // persona deve poter distinguere a colpo d'occhio la voce del
                // Maestro da cio' che l'app ha messo al suo posto. Senza questa
                // riga il ripiego si legge come una risposta.
                if (message.ripiego) ...[
                  const SizedBox(height: SpacingTokens.xs),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.cloud_off_outlined,
                        size: 13,
                        color: ColorTokens.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          RipiegoDelMaestro.etichettaDi(maestro),
                          style: TypographyTokens.body(size: 13)
                              .copyWith(color: ColorTokens.textMuted),
                        ),
                      ),
                    ],
                  ),
                ],
                if (message.intentId != null) ...[
                  const SizedBox(height: SpacingTokens.sm),
                  _IntentButton(
                    intentId: message.intentId!,
                    palette: palette,
                    onTap: () => onOpenIntent?.call(message.intentId!),
                  ),
                ],
                // "Vai piu' a fondo" sta SOTTO la risposta, dentro la sua
                // bolla: la profondita' non si sceglie prima di leggere, si
                // chiede dopo aver letto.
                if (onApprofondisci != null) ...[
                  const SizedBox(height: SpacingTokens.sm),
                  GestureDetector(
                    key: const Key('chat_approfondisci'),
                    onTap: onApprofondisci,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.expand_more_rounded,
                            color: palette.goldSoft, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          'Vai più a fondo',
                          style: TypographyTokens.body(size: 14, weight: 600)
                              .copyWith(color: palette.goldSoft),
                        ),
                      ],
                    ),
                  ),
                ],
                // LE ALTRE VOCI, dentro la bolla della risposta a cui si
                // riferiscono.
                //
                // Era un'icona a bilancia nell'intestazione: dorata, in una
                // schermata di astrologia, si leggeva come il SEGNO della
                // Bilancia. E portava altrove, dove la conversazione
                // ricominciava da zero. Qui invece i due volti dicono da soli
                // chi sono le altre voci, e al tocco arrivano sotto.
                if (onChiediAgliAltri != null && altreVoci.isNotEmpty) ...[
                  const SizedBox(height: SpacingTokens.sm),
                  GestureDetector(
                    key: const Key('chat_altre_voci'),
                    onTap: onChiediAgliAltri,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final altro in altreVoci) ...[
                          MaestroBust(maestro: altro, ring: 26, popOut: false),
                          const SizedBox(width: 4),
                        ],
                        const SizedBox(width: 2),
                        Text(
                          'Chiedi anche agli altri',
                          style: TypographyTokens.body(size: 14, weight: 600)
                              .copyWith(color: palette.goldSoft),
                        ),
                      ],
                    ),
                  ),
                ],
                    ],
                  ),
                ),
                // Il Riprova nasce dentro la bolla che ha fallito, attaccato al
                // testo a cui si riferisce.
                if (onRetry != null) ...[
                  const SizedBox(height: SpacingTokens.xs),
                  GestureDetector(
                    key: const Key('chat_riprova'),
                    onTap: onRetry,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded,
                            color: palette.goldSoft, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Riprova',
                          style: TypographyTokens.body(size: 14)
                              .copyWith(color: palette.goldSoft),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
    );

    // UN TOCCO SULLA BOLLA COMPLETA IL TESTO.
    //
    // Sulla bolla intera e non su una manina in un angolo: chi vuole saltare
    // vuole saltare adesso, e cercare un bersaglio piccolo mentre il testo
    // scorre e' peggio che aspettare. `opaque` perche' altrimenti i tocchi
    // sullo spazio fra le righe non arriverebbero.
    final bolla = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _chiaveDelTesto.currentState?.completa(),
      child: bubble,
    );

    if (isUser) {
      // Il volto dell'utente, piccolo e discreto, sul lato destro della sua
      // bolla: la sua foto, o l'emblema del segno, o le iniziali, o il sigillo
      // neutro. Mai un tondo vuoto.
      return Padding(
        padding: const EdgeInsets.only(
          left: SpacingTokens.xl,
          top: SpacingTokens.xs,
          bottom: SpacingTokens.xs,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(child: bolla),
            const SizedBox(width: SpacingTokens.xs),
            UserAvatar.forUser(context, size: 28, key: const Key('chat_user_avatar')),
          ],
        ),
      );
    }

    // Maestro: il suo volto tondo piu' la bolla.
    return Padding(
      padding: const EdgeInsets.only(
        right: SpacingTokens.xl,
        top: SpacingTokens.xs,
        bottom: SpacingTokens.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stesso volto inquadrato di header e lente, ma contenuto nel tondo,
          // senza sporgenza, per non affollare il testo.
          MaestroBust(maestro: maestro, ring: 34, popOut: false),
          const SizedBox(width: SpacingTokens.xs),
          Flexible(child: bolla),
        ],
      ),
    );
  }
}

/// Il pulsante che apre la funzione immersiva instradata dalla chat.
class _IntentButton extends StatelessWidget {
  const _IntentButton({
    required this.intentId,
    required this.palette,
    required this.onTap,
  });

  final String intentId;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final intent = ImmersiveIntents.all.firstWhere((i) => i.id == intentId);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('intent_open_$intentId'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
            gradient: LinearGradient(colors: [
              palette.primary.withValues(alpha: 0.7),
              palette.surfaceElevated.withValues(alpha: 0.7),
            ]),
            border: Border.all(color: palette.gold.withValues(alpha: 0.6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, size: 16, color: palette.goldSoft),
              const SizedBox(width: SpacingTokens.sm),
              Flexible(
                child: Text(intent.buttonLabel,
                    style: TypographyTokens.display(size: 16)
                        .copyWith(color: palette.goldSoft)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
