/// LE TRE AZIONI SOTTO OGNI RESPONSO, DA UNA PORTA SOLA.
/// Ordine CG voci 06 e 08.
///
/// **Perche' un widget e non tre pulsanti per arte.** Prima di questa voce
/// ogni arte scriveva i propri pulsanti a mano: sei avevano "Parlane col
/// Maestro" e sette no, e nessuno poteva dire quante fossero senza aprire
/// quattordici file. Con una porta sola una guardia enumera le arti e chiede a
/// ognuna se la monta, e un'arte nuova che nascesse domani senza montarla fa
/// cadere una prova invece di nascere muta.
///
/// **Le tre azioni, e l'ordine in cui stanno.**
///
/// 1. CONDIVIDI, che c'era gia'. Adesso, quando la condivisione AVVIENE
///    davvero, custodisce da sola: condividere e' gia' la dichiarazione piu'
///    forte che una persona possa fare su un contenuto. Un foglio aperto e poi
///    chiuso non custodisce niente.
/// 2. CUSTODISCI, che e' nuovo. Un tocco, e il responso resta per sempre.
///    Toccato due volte non fa niente di male: il magazzino ha una chiave per
///    responso, quindi non nascono due carte uguali.
/// 3. PARLANE COL MAESTRO, col responso GIA' DENTRO la conversazione. Non si
///    riapre una chat vuota: la persona non deve raccontare al Maestro cosa ha
///    appena letto.
///
/// **Perche' Custodisci sta in mezzo e non in fondo.** Le prime due azioni
/// tengono il responso, la terza porta via da questa schermata: mettere il
/// gesto che porta via fra i due che restano spezzerebbe la lettura.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/condivisione/premio_della_condivisione.dart';
import '../../core/maestro/maestro.dart';
import '../../core/ricordi/registro_dei_ricordi.dart';
import '../../core/ricordi/ricordo_custodito.dart';
import '../../core/ricordi/scrigno_dei_custoditi.dart';
import '../../core/ricordi/voce_del_ricordo.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../services/app_services.dart';
import '../maestri/chat/maestro_chat_screen.dart';

/// Cio' che un'arte consegna perche' il suo responso possa essere custodito.
///
/// **Il testo e i dati, mai l'immagine.** La ragione e' il peso: un testo coi
/// suoi dati sta in qualche centinaio di byte, un PNG in qualche centinaio di
/// chilobyte, cioe' mille volte tanto.
@immutable
class ResponsoDaCustodire {
  const ResponsoDaCustodire({
    required this.arte,
    required this.titolo,
    required this.testo,
    this.dati = const {},
  });

  /// L'identificativo dell'arte o del Dono, quello di `ContiDelleArti`.
  final String arte;

  final String titolo;
  final String testo;

  /// I dati che servono a ridisegnare la scena: le carte di una stesa, i nomi
  /// delle rune di una gettata, la percentuale di una sinastria.
  final Map<String, String> dati;
}

class AzioniDelResponso extends StatefulWidget {
  const AzioniDelResponso({
    super.key,
    required this.palette,
    required this.maestro,
    required this.responso,
    this.condividi,
    required this.aperturaDellaChat,
    this.orologio,
    this.dorato = false,
  });

  final MaestroPalette palette;

  /// Il Maestro proprietario dell'arte, che e' quello con cui si parla.
  final Maestro maestro;

  final ResponsoDaCustodire responso;

  /// Come quest'arte condivide. Torna VERO quando la condivisione e' avvenuta
  /// davvero, cioe' cio' che `PortaDellaCondivisione.avvenuta` risponde: e' su
  /// quel vero che scatta la custodia automatica.
  ///
  /// **NULLO quando quell'arte non ha niente da condividere**, e non e' una
  /// dimenticanza. Il Sigillo dell'Intenzione e l'Arcano del Giorno non hanno
  /// una carta da mandare: inventargliela sarebbe una funzione nuova, non
  /// questa voce. Custodisci e Parlane restano, perche' quelli non hanno
  /// bisogno di un'immagine.
  final Future<bool> Function()? condividi;

  /// La prima domanda con cui si apre la chat, composta da `ChatOpeners`.
  final String aperturaDellaChat;

  /// Iniettabile, cosi' le prove sanno che ora e' senza aspettare il minuto.
  final DateTime Function()? orologio;

  /// **LA FORMA DORATA DEL CONDIVIDI, e perche' esiste.**
  ///
  /// Tre arti di Medora (Oroscopo, Stesa, Sinastria) avevano gia' un
  /// Condividi in oro pieno, centrato, con la sua attesa "Preparo la card":
  /// non e' un accidente, e' l'invito che chiude quei tre responsi. Una porta
  /// sola non vuol dire un aspetto solo: qui cambia il vestito di UN pulsante,
  /// mentre il gesto, la custodia automatica e la guardia restano gli stessi
  /// per tutte e tredici le arti.
  final bool dorato;

  @override
  State<AzioniDelResponso> createState() => _AzioniDelResponsoState();
}

class _AzioniDelResponsoState extends State<AzioniDelResponso> {
  bool _condividendo = false;
  bool _custodito = false;

  DateTime get _adesso => (widget.orologio ?? DateTime.now)();

  /// **LA CHIAVE DEL RESPONSO SI CALCOLA UNA VOLTA E NON A OGNI TOCCO.**
  ///
  /// Se nascesse a ogni tocco, custodire col gesto alle 9:00:59 e condividere
  /// alle 9:01:01 produrrebbe due chiavi diverse e due carte identiche nella
  /// griglia. Qui l'istante e' quello in cui il responso e' comparso.
  late final DateTime _quando = _adesso;

  RicordoCustodito _daCustodire(ComeENato come) => RicordoCustodito(
        quando: _quando,
        arte: widget.responso.arte,
        maestro: widget.maestro.id,
        titolo: widget.responso.titolo,
        testo: widget.responso.testo,
        dati: widget.responso.dati,
        comeENato: come,
      );

  /// Custodisce, e segna la voce nell'indice dei Ricordi.
  ///
  /// **Le due scritture stanno insieme e non in due punti**: un responso
  /// custodito che non comparisse nella timeline sarebbe una carta senza il
  /// giorno in cui e' nata.
  Future<bool> _tieni(ComeENato come) async {
    final ricordo = _daCustodire(come);
    var entrato = false;
    try {
      final scrigno = context.read<ScrignoDeiCustoditi>();
      entrato = await scrigno.custodisci(ricordo);
    } catch (errore) {
      // **Un provider assente non spegne il responso.** Nelle prove che
      // montano una schermata sola lo scrigno puo' non esserci, e un responso
      // che morisse per questo sarebbe un difetto peggiore di quello che
      // questa voce cura.
      debugPrint('Azioni: lo scrigno non c\'e\'. $errore');
      return false;
    }
    if (!entrato) return false;
    if (!mounted) return true;
    try {
      final registro = context.read<RegistroDeiRicordi>();
      await registro.segna(VoceDelRicordo(
        quando: _quando,
        arte: widget.responso.arte,
        maestro: widget.maestro.id,
        titolo: widget.responso.titolo,
        tipo: TipoDelRicordo.responso,
        riferimento: ricordo.chiave,
      ));
    } catch (errore) {
      debugPrint('Azioni: il registro dei Ricordi non c\'e\'. $errore');
    }
    return true;
  }

  Future<void> _condividi() async {
    final porta = widget.condividi;
    if (porta == null) return;
    setState(() => _condividendo = true);
    try {
      final avvenuta = await porta();
      // **SOLO SE E' AVVENUTA.** Un foglio aperto e poi chiuso non custodisce
      // niente, ed e' la misura di accettazione dell'ordine.
      if (avvenuta) {
        final entrato = await _tieni(ComeENato.condivisione);
        if (entrato && mounted) setState(() => _custodito = true);
      }
    } finally {
      if (mounted) setState(() => _condividendo = false);
    }
  }

  Future<void> _custodisci() async {
    final entrato = await _tieni(ComeENato.gesto);
    if (!mounted) return;
    // **Il vero e il falso portano allo stesso stato a video**, e non e' una
    // svista: chi tocca Custodisci su un responso gia' custodito deve vedere
    // che e' custodito, non un rifiuto.
    setState(() => _custodito = true);
    if (!entrato) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(content: Text('Custodito nei Ricordi del Cerchio.')),
    );
  }

  void _parlane() {
    final AppServices services;
    try {
      services = context.read<AppServices>();
    } catch (errore) {
      debugPrint('Azioni: i servizi non ci sono. $errore');
      return;
    }
    Navigator.of(context).push(MaestroChatScreen.route(
      maestro: widget.maestro,
      services: services,
      initialUserMessage: widget.aperturaDellaChat,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.condividi == null)
            const SizedBox.shrink()
          else if (widget.dorato)
            Center(
              child: FilledButton.icon(
                key: const Key('responso_condividi'),
                style: FilledButton.styleFrom(
                  backgroundColor: palette.gold,
                  foregroundColor: palette.deepest,
                  padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.xl,
                      vertical: SpacingTokens.sm),
                ),
                onPressed: _condividendo ? null : _condividi,
                icon: _condividendo
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.ios_share_rounded, size: 18),
                label: Text(_condividendo
                    ? 'Preparo la card'
                    : PremioDellaCondivisione.etichetta(context)),
              ),
            )
          else
            OutlinedButton.icon(
              key: const Key('responso_condividi'),
              style: OutlinedButton.styleFrom(
                  foregroundColor: palette.goldSoft,
                  side: BorderSide(color: palette.gold.withValues(alpha: 0.6))),
              onPressed: _condividendo ? null : _condividi,
              icon: const Icon(Icons.ios_share_rounded),
              label: Text(PremioDellaCondivisione.etichetta(context)),
            ),
          if (widget.condividi != null)
            const SizedBox(height: SpacingTokens.sm),
          OutlinedButton.icon(
            key: const Key('responso_custodisci'),
            style: OutlinedButton.styleFrom(
                foregroundColor: palette.goldSoft,
                side: BorderSide(color: palette.gold.withValues(alpha: 0.6))),
            onPressed: _custodito ? null : _custodisci,
            icon: Icon(_custodito
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded),
            label: Text(_custodito ? 'Custodito' : 'Custodisci'),
          ),
          const SizedBox(height: SpacingTokens.sm),
          FilledButton.icon(
            key: const Key('responso_parlane'),
            style: FilledButton.styleFrom(
                backgroundColor: palette.primary,
                foregroundColor: palette.onPrimary),
            onPressed: _parlane,
            icon: const Icon(Icons.forum_outlined),
            label: Text('Parlane con ${widget.maestro.displayName}'),
          ),
        ],
      ),
    );
  }
}
