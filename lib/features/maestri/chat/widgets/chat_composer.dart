import 'package:flutter/material.dart';

import '../../../../design_system/theme/maestro_scope.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../../core/permissions/app_permission.dart';
import '../../../../core/permissions/avviso_del_permesso.dart';
import '../../../../core/permissions/esito_del_permesso.dart';
import '../../../../core/sensi/palette_sensoriale.dart';
import '../../../../core/voce/dettatura.dart';

/// Barra di composizione del messaggio: campo di testo che cresce e bottone di
/// invio dorato. Disabilitata mentre il Maestro sta rispondendo.
class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.enabled,
    required this.onSend,
    this.onSuggestions,
    this.hintText = 'Scrivi a Medora',
    this.initialText,
    this.dettatura = const DettaturaSpenta(),
  });

  final bool enabled;
  final ValueChanged<String> onSend;

  /// Se non nullo, a sinistra compare un controllo discreto Suggerimenti che
  /// apre il pannello. E' presente solo a conversazione avviata.
  final VoidCallback? onSuggestions;

  final String hintText;

  /// Testo con cui il campo si apre gia' scritto, quando si arriva dalla
  /// chiusura del cerchio del Consulta col tema.
  final String? initialText;

  /// **LA DETTATURA. Ordine CI voce 05.**
  ///
  /// Di partenza e' spenta, quindi il microfono non compare: e' il valore
  /// giusto per le prove e per qualunque punto che non abbia ricevuto quella
  /// vera. Un comando che non funziona e' peggio di un comando assente.
  final Dettatura dettatura;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  /// **IL MICROFONO SI MOSTRA SOLO SE LA PIATTAFORMA SA ASCOLTARE.** Ordine
  /// CI voce 05, vincolo f: non compare spento e non compare con un avviso.
  /// Nullo finche' non si sa: fino ad allora non si disegna.
  bool? _microfonoCePuo;
  bool _staAscoltando = false;

  /// Quello che c'era scritto prima di cominciare a dettare: la dettatura
  /// AGGIUNGE al campo invece di cancellarlo, perche' cancellare quello che
  /// qualcuno ha gia' scritto e' un danno che nessun comando deve poter fare.
  String _primaDiDettare = '';

  /// L'esito del permesso quando NON e' concesso: finche' e' qui, sopra le
  /// due bolle compare la riga che lo dice, e quella riga porta
  /// all'impostazione di sistema invece di lasciare un vicolo cieco.
  EsitoDelPermesso? _permessoNegato;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    final seed = widget.initialText?.trim() ?? '';
    if (seed.isNotEmpty) {
      _controller.text = seed;
      _hasText = true;
    }
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
    _chiediSeSaAscoltare();
  }

  /// **SI CHIEDE SE LA PIATTAFORMA SA ASCOLTARE, non se puo' farlo adesso.**
  /// Non e' una richiesta di permesso: il permesso si chiede al primo tocco e
  /// mai prima, come vuole la sezione 25 delle Linee Guida UX.
  Future<void> _chiediSeSaAscoltare() async {
    final puo = await widget.dettatura.disponibile();
    if (mounted) setState(() => _microfonoCePuo = puo);
  }

  /// **IL PRIMO TOCCO SUL MICROFONO CHIEDE IL PERMESSO**, e non prima.
  ///
  /// La richiesta passa dalla porta di casa, che sa distinguere tre casi che
  /// il sistema confonde in uno: un no, un no per sempre, e una piattaforma
  /// senza quel sensore. Nel secondo caso la riga porta all'impostazione di
  /// sistema, perche' un no per sempre senza una via d'uscita e' un vicolo
  /// cieco.
  Future<void> _tocca() async {
    if (_staAscoltando) {
      await widget.dettatura.ferma();
      if (mounted) setState(() => _staAscoltando = false);
      return;
    }
    final esito = await PortaDelPermesso.chiedi(
      AppPermission.microphone,
      // **LA RICHIESTA VERA E' L'ACCENSIONE DEL RICONOSCITORE**, che sul
      // sistema chiede il permesso del microfono. Un si' di comodo qui
      // avrebbe fatto credere alla porta dei permessi che il permesso ci
      // fosse, e la riga del no non sarebbe mai comparsa.
      richiestaDiSistema: widget.dettatura.accendi,
    );
    if (!mounted) return;
    if (esito != EsitoDelPermesso.concesso) {
      setState(() => _permessoNegato = esito);
      return;
    }
    setState(() => _permessoNegato = null);
    _primaDiDettare = _controller.text;
    final partito = await widget.dettatura.ascolta(
      // **LA DETTATURA COMPILA, NON INVIA.** Vincolo a dell'ordine: la
      // persona resta padrona della domanda, la rilegge e la corregge.
      parole: (dette) {
        if (!mounted) return;
        final unito =
            _primaDiDettare.isEmpty ? dette : '$_primaDiDettare $dette';
        _controller.value = TextEditingValue(
          text: unito,
          selection: TextSelection.collapsed(offset: unito.length),
        );
      },
      finito: () {
        if (mounted) setState(() => _staAscoltando = false);
      },
    );
    if (mounted) setState(() => _staAscoltando = partito);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled) return;
    widget.onSend(text);
    _controller.clear();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final canSend = widget.enabled && _hasText;

    return Container(
      padding: const EdgeInsets.only(
        left: SpacingTokens.md,
        right: SpacingTokens.md,
        top: SpacingTokens.sm,
        // SOLO IL RESPIRO, ordine 2163 voce 9: qui si aggiungeva anche il
        // padding di sistema, che DENTRO la barra del Cerchio vale la barra
        // intera piu' l'inset. Ma il compositore e' gia' sollevato sopra la
        // barra dal Positioned della schermata: il doppio conteggio erano
        // centotrentacinque punti di vuoto sotto il campo, misurati.
        bottom: SpacingTokens.sm,
      ),
      // IL FONDO DIETRO LA RIGA E' TORNATO, ordine H voce 3a, e non e' un
      // ripensamento di nascosto: l'ordine 2164 lo aveva tolto e Mauro lo ha
      // rivoluto quando, con la tastiera alzata, i messaggi scorrevano DIETRO
      // il campo e si leggevano attraverso gli spazi della riga. Il campo era
      // opaco lui, ma la riga che lo ospita no: fra il campo, il tondo di
      // invio e i Suggerimenti il contenuto passava e si vedeva. Adesso la
      // riga intera ha un fondo suo, ancorato con lei: sfuma in cima per non
      // fare uno scalino e diventa pieno dove vivono i controlli.
      // **LA SFUMATURA SI STRINGE, ordine BF voce 05.c.** Piena al 35 per
      // cento, la fascia lasciava trasparente tutta la parte alta della riga:
      // coi Maestri grandi dell'ordine BD la figura e la coda del saluto
      // passavano proprio li' e si leggevano fra i controlli, parola del
      // fondatore. Il velo adesso e' pieno gia' al 12 per cento: resta la
      // dissolvenza in cima, che evita lo scalino, ma all'altezza dei
      // controlli il fondo e' fondo.
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.deepest.withValues(alpha: 0.0),
            palette.deepest.withValues(alpha: 0.98),
            palette.deepest.withValues(alpha: 0.98),
          ],
          stops: const [0.0, 0.12, 1.0],
        ),
      ),
      // **LA FORMA CHIESTA DAL FONDATORE, 1 settembre 2026.** Parole sue:
      // "nelle chat metti sopra il campo suggerimenti e sotto il campo scrivi
      // a nome maestro con bolle della stessa dimensione, e a fianco delle
      // bolle, a destra, la bolla con la freccia verso l'alto".
      //
      // Prima le tre cose stavano in fila: Suggerimenti stretto a sinistra,
      // il campo in mezzo, la freccia a destra. Adesso le due bolle sono
      // IMPILATE e larghe uguali, cioe' tutte e due larghe quanto la colonna,
      // e la freccia sta accanto a tutte e due, centrata fra loro.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              // **STESSA DIMENSIONE** vuol dire questo: le due bolle si
              // stendono tutte e due sull'intera larghezza della colonna,
              // invece di prendersi ognuna lo spazio che le serve.
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // **SE IL PERMESSO NON C'E', LA RIGA LO DICE E APRE LA
                // STRADA.** Ordine CI voce 05, vincolo e: mai un vicolo
                // cieco. Quando il no e' per sempre, quel pulsante non
                // richiede, apre le impostazioni di sistema, perche'
                // richiedere non mostrerebbe piu' niente e sembrerebbe un
                // pulsante rotto.
                if (_permessoNegato != null) ...[
                  AvvisoDelPermesso(
                    chiave: 'chat',
                    permesso: AppPermission.microphone,
                    esito: _permessoNegato!,
                    palette: palette,
                    onRichiedi: _tocca,
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                ],
                if (widget.onSuggestions != null) ...[
                  _SuggestionsControl(onTap: widget.onSuggestions!),
                  const SizedBox(height: SpacingTokens.xs),
                ],
                Container(
                  key: const Key('chat_campo'),
                  decoration: BoxDecoration(
                    // OPACO, ordine 2163 voce 1: il testo delle bolle si
                    // leggeva ATTRAVERSO il campo. Il colore e' lo stesso di
                    // prima (surface al 60 per cento posata sul fondale), ma
                    // composto una volta per tutte invece che lasciato
                    // comporre a video con quello che passa dietro.
                    color: Color.alphaBlend(
                        palette.surface.withValues(alpha: 0.6),
                        palette.deepest),
                    borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
                    border: Border.all(
                      color: palette.gold.withValues(alpha: 0.3),
                    ),
                  ),
                  padding: const EdgeInsets.only(
                    left: SpacingTokens.md,
                    right: 4,
                    top: 4,
                    bottom: 4,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focus,
                          enabled: widget.enabled,
                          minLines: 1,
                          maxLines: 5,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _submit(),
                          keyboardType: TextInputType.multiline,
                          textCapitalization: TextCapitalization.sentences,
                          style: TypographyTokens.lettura(),
                          cursorColor: palette.goldSoft,
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: widget.hintText,
                            hintStyle: TypographyTokens.lettura()
                                .copyWith(color: ColorTokens.textMuted),
                          ),
                        ),
                      ),
                      // **IL MICROFONO STA DENTRO IL CAMPO, e non accanto
                      // alla freccia.** Ordine CI voce 05. Dettare e' un modo
                      // di SCRIVERE, quindi il comando vive dove si scrive;
                      // la freccia invece manda, ed e' un'altra cosa, per
                      // questo resta sola nella sua bolla a destra.
                      //
                      // **Compare solo se la piattaforma sa ascoltare**,
                      // vincolo f: non compare spento e non compare con un
                      // avviso, perche' un comando che non funziona e' peggio
                      // di un comando assente.
                      if (_microfonoCePuo == true)
                        _MicrofonoDellaDettatura(
                          ascolta: _staAscoltando,
                          abilitato: widget.enabled,
                          onTap: _tocca,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: SpacingTokens.xs),
          _SendButton(enabled: canSend, onTap: _submit),
        ],
      ),
    );
  }
}

/// Controllo discreto a sinistra del composer: un'icona con etichetta
/// Suggerimenti che apre il pannello a comparsa.
class _SuggestionsControl extends StatelessWidget {
  const _SuggestionsControl({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // DENTRO UNA BOLLA, ordine H voce 3b: l'icona con l'etichetta
    // galleggiava nuda sul cosmo, unico controllo della riga senza un
    // contenitore, e non si leggeva come qualcosa che si tocca. La bolla ha
    // lo stesso fondo e lo stesso bordo del campo accanto, cosi' la riga
    // parla una lingua sola.
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        key: const Key('chat_stelline'),
        // Verticale a quattro: a sei la bolla usciva di tre punti sopra il
        // campo, misurato dalla prova della riga pulita.
        padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.sm, vertical: 4),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
              palette.surface.withValues(alpha: 0.6), palette.deepest),
          borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
          border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_outlined,
                color: palette.goldSoft, size: 19),
            Text(
              'Suggerimenti',
              style: TypographyTokens.etichetta()
                  .copyWith(color: ColorTokens.textMuted, letterSpacing: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTap: enabled
          ? () {
              PaletteSensoriale.eseguiSchema(SchemaAptico.tocco);
              onTap();
            }
          : null,
      child: AnimatedContainer(
        key: const Key('chat_invio'),
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // Anche il tondo di invio e' OPACO in tutti e due gli stati,
            // ordine 2163 voce 1: da spento era semitrasparente e le bolle
            // ci passavano dietro. Stesso colore percepito, composto.
            colors: enabled
                ? [palette.goldSoft, palette.gold]
                : [
                    Color.alphaBlend(palette.surface.withValues(alpha: 0.6),
                        palette.deepest),
                    Color.alphaBlend(palette.surface.withValues(alpha: 0.4),
                        palette.deepest),
                  ],
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: palette.glow.withValues(alpha: 0.5),
                    blurRadius: 14,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.arrow_upward_rounded,
          color: enabled ? palette.deepest : ColorTokens.textMuted,
          size: 24,
        ),
      ),
    );
  }
}

/// IL MICROFONO DELLA DETTATURA. Ordine CI voce 05.
///
/// **Non e' un pulsante d'invio piu' piccolo.** Sta dentro il campo perche'
/// dettare e' un modo di scrivere: riempie il campo e non manda niente. Il
/// suo stato acceso si vede, perche' un microfono che ascolta senza dirlo e'
/// la cosa che spaventa di piu' in un'app.
class _MicrofonoDellaDettatura extends StatelessWidget {
  const _MicrofonoDellaDettatura({
    required this.ascolta,
    required this.abilitato,
    required this.onTap,
  });

  final bool ascolta;
  final bool abilitato;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      label: ascolta ? 'Smetti di dettare' : 'Detta il messaggio',
      child: IconButton(
        key: const Key('chat_microfono'),
        onPressed: abilitato ? onTap : null,
        // L'area di tocco resta quella di sistema, quarantotto punti: un
        // comando dentro un campo di testo e' gia' il piu' facile da sbagliare
        // col dito, e stringerlo lo renderebbe peggio.
        iconSize: 22,
        visualDensity: VisualDensity.compact,
        tooltip: ascolta ? 'Smetti di dettare' : 'Detta il messaggio',
        icon: Icon(
          ascolta ? Icons.stop_circle_rounded : Icons.mic_none_rounded,
          color: ascolta ? palette.gold : ColorTokens.textMuted,
        ),
      ),
    );
  }
}
