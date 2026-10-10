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

import '../../core/chat/il_filo_del_consulto.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/chat/i_responsi_di_oggi.dart';
import '../../core/condivisione/premio_della_condivisione.dart';
import '../../core/maestro/maestro.dart';
import '../../core/ricordi/registro_dei_ricordi.dart';
import '../../core/ricordi/ricordo_custodito.dart';
import '../../core/ricordi/voce_del_ricordo.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../services/app_services.dart';
import '../maestri/chat/maestro_chat_screen.dart';
import '../../core/sensi/catalogo_suoni.dart';
import '../../core/sensi/palette_sensoriale.dart';
import 'dart:async';
import '../../design_system/tokens/regime_chiaro.dart';
import '../../design_system/theme/accento_del_maestro.dart';

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
    this.perIlMaestro,
  });

  /// L'identificativo dell'arte o del Dono, quello di `ContiDelleArti`.
  final String arte;

  final String titolo;
  final String testo;

  /// **IL RESPONSO COME LO HA LETTO LA PERSONA, PER IL MAESTRO.** Ordine EV
  /// voce 04. Quando l'arte mostra a video piu' di [testo] (l'Oroscopo mostra
  /// anche "Da dove viene", il transito da cui il responso nasce), qui c'e'
  /// tutto: e' cio' che il Maestro riceve se la persona gli scrive. Nullo, il
  /// Maestro riceve [testo].
  final String? perIlMaestro;

  /// I dati che servono a ridisegnare la scena: le carte di una stesa, i nomi
  /// delle rune di una gettata, la percentuale di una sinastria.
  final Map<String, String> dati;
}

/// **IL RESPONSO ENTRA NEL DIARIO DA SE', IN UN PUNTO SOLO. Ordine FE voce
/// 22.6.** Il fondatore: *"Ogni consulto, ogni responso e ogni lettura
/// prodotta dall'app entra nel Diario da sé, senza che l'utente prema
/// niente."*
///
/// Fino al 6 ottobre 2026 l'annotazione partiva solo dall'`initState` di
/// [AzioniDelResponso], cioe' quando la porta veniva costruita. Il
/// censimento dell'ordine ha trovato due buchi: sei letture senza la porta
/// (il Viaggio dello Sciamano, l'Angelo Custode, il Consiglio dei Maestri,
/// l'Oroscopo della settimana, del mese e dell'anno, il Confronto del cielo,
/// il Gemello della Sinastria) non entravano mai; e tre arti con la porta in
/// fondo a un elenco pigro (la Stesa, la Sinastria, il Sigillo
/// dell'Intenzione) entravano solo se la persona scorreva fino in fondo.
/// Adesso la porta e [IlResponsoNelDiario] passano tutti da qui, con la
/// stessa chiave (il minuto e l'arte): una voce sola anche quando li monta
/// tutti e due.
Future<bool> annotaNelDiario(
  BuildContext context, {
  required Maestro maestro,
  required ResponsoDaCustodire responso,
  required DateTime quando,
}) async {
  final RegistroDeiRicordi registro;
  try {
    registro = context.read<RegistroDeiRicordi>();
  } catch (errore) {
    // Un provider assente non spegne il responso: nelle prove che montano
    // una schermata sola il registro puo' non esserci.
    debugPrint('Diario: il registro non c\'è. $errore');
    return false;
  }
  final ricordo = RicordoCustodito(
    quando: quando,
    arte: responso.arte,
    maestro: maestro.id,
    titolo: responso.titolo,
    testo: responso.testo,
    dati: responso.dati,
    comeENato: ComeENato.gesto,
  );
  return registro.annotaIlResponso(
    chiave: ricordo.chiave,
    quando: quando,
    arte: responso.arte,
    maestro: maestro.id,
    titolo: responso.titolo,
    contenuto: ricordo.aMappa(),
  );
}

/// **L'ISTANTE DI UN RESPONSO**, che e' la sua chiave nel Diario (il minuto e
/// l'arte). Si lega al contenuto e non all'oggetto: in piu' arti il responso
/// si ricompone a ogni disegno, e un oggetto nuovo darebbe un istante nuovo e
/// una seconda voce. Lo stesso testo della stessa arte resta lo stesso
/// responso; un testo nuovo e' un responso nuovo.
class IstantiDeiResponsi {
  IstantiDeiResponsi({DateTime Function()? orologio})
      : _orologio = orologio ?? DateTime.now;

  final DateTime Function() _orologio;
  final Map<String, DateTime> _visti = {};

  DateTime di(ResponsoDaCustodire responso) =>
      _visti.putIfAbsent('${responso.arte}\n${responso.testo}', _orologio);
}

/// **IL RESPONSO NEL DIARIO SENZA LA PORTA.** Non si vede: si monta dove il
/// responso compare, fuori da ogni elenco pigro, e lo annota appena
/// costruito. Un responso nuovo (testo o istante diversi) si annota di
/// nuovo; lo stesso, no.
class IlResponsoNelDiario extends StatefulWidget {
  const IlResponsoNelDiario({
    super.key,
    required this.maestro,
    required this.responso,
    this.quando,
  });

  final Maestro maestro;
  final ResponsoDaCustodire responso;

  /// L'istante in cui il responso e' nato: la stessa chiave della porta.
  /// Nullo, lo fissa il widget quando nasce, e lo rifissa solo quando il
  /// responso cambia: una schermata ridisegnata a ogni fotogramma non
  /// annota una voce nuova a ogni minuto.
  final DateTime? quando;

  @override
  State<IlResponsoNelDiario> createState() => _IlResponsoNelDiarioState();
}

class _IlResponsoNelDiarioState extends State<IlResponsoNelDiario> {
  late DateTime _quando = widget.quando ?? DateTime.now();

  void _annota() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(annotaNelDiario(context,
            maestro: widget.maestro,
            responso: widget.responso,
            quando: _quando));
      });

  @override
  void initState() {
    super.initState();
    _annota();
  }

  @override
  void didUpdateWidget(IlResponsoNelDiario vecchio) {
    super.didUpdateWidget(vecchio);
    final cambiato = vecchio.responso.arte != widget.responso.arte ||
        vecchio.responso.testo != widget.responso.testo;
    if (cambiato || vecchio.quando != widget.quando) {
      _quando = widget.quando ?? (cambiato ? DateTime.now() : _quando);
      _annota();
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
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
    this.suChiaro = false,
    this.quando,
  });

  /// L'istante in cui il responso e' nato, quando l'arte lo annota anche
  /// con [IlResponsoNelDiario]: la stessa chiave, una voce sola. Nullo, e'
  /// l'istante in cui la porta compare.
  final DateTime? quando;

  /// **SE QUESTE AZIONI STANNO SU UN FONDO CHIARO. Ordine CO voce 14**, 3
  /// settembre 2026, e nasce da uno scatto del fondatore.
  ///
  /// I due pulsanti contornati scrivono in `palette.goldSoft`, che e' l'oro
  /// pensato per i fondi scuri di questa app e li' regge benissimo, da 9,29 a
  /// 13,81 a uno. **Dentro la scheda del Dono il fondo non e' scuro: e' il
  /// pannello del regime chiaro**, e li' lo stesso oro misura **1,30 a uno**.
  /// Non e' poco leggibile: e' invisibile, e nello scatto del fondatore si
  /// vedono due rettangoli vuoti accanto a un terzo pulsante perfettamente
  /// leggibile, che e' pieno e si porta il fondo da solo.
  ///
  /// **Perche' nessuna guardia lo aveva preso.** La tabella del contrasto del
  /// Rito dell'Alba misura ogni testo dipinto e chiede il colore al `Text`;
  /// **l'etichetta di un pulsante il colore non ce l'ha**, lo eredita dallo
  /// stile del pulsante che la contiene. Per la tabella quei due testi non
  /// avevano inchiostro, e un testo senza inchiostro non si puo' misurare:
  /// venivano saltati. E' la quarta specie di cecita' incontrata in
  /// quest'ordine, dopo l'iscrizione per nome, il fotogramma unico e la
  /// radice del `RichText`.
  ///
  /// Vero solo dove il fondo e' chiaro, cioe' dentro la scheda dei Doni.
  /// Altrove l'oro resta, ed e' giusto che resti.
  final bool suChiaro;

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
  late final DateTime _quando = widget.quando ?? _adesso;

  /// Il responso come lo riceve il Maestro, ordine EV voce 04.
  ResponsoDiOggi get _perIlMaestro => ResponsoDiOggi(
        arte: widget.responso.arte,
        titolo: widget.responso.titolo,
        testo: widget.responso.perIlMaestro ?? widget.responso.testo,
      );

  /// **OGNI RESPONSO COMPARSO SI RICORDA PER IL MAESTRO**, ordine EV voce 04:
  /// se la persona gli scrive dopo, anche senza "Parlane con...", il Maestro
  /// sa che cosa ha letto e non lo nega.
  @override
  void initState() {
    super.initState();
    IResponsiDiOggi.ricorda(_perIlMaestro, adesso: _adesso);
    // **IL RESPONSO ENTRA NEL DIARIO DA SE'. Ordine FE voce 22.6.** Appena
    // si mostra, senza che la persona prema niente: la memoria non ha buchi
    // dove non si e' pigiato. Si annotano i dati che lo generano (FE.22.11).
    WidgetsBinding.instance.addPostFrameCallback((_) => _annota());
  }

  RegistroDeiRicordi? get _registro {
    try {
      return context.read<RegistroDeiRicordi>();
    } catch (errore) {
      // Un provider assente non spegne il responso: nelle prove che montano
      // una schermata sola il registro puo' non esserci.
      debugPrint('Azioni: il registro del Diario non c\'è. $errore');
      return null;
    }
  }

  Future<void> _annota() async {
    if (!mounted) return;
    final registro = _registro;
    if (registro == null) return;
    final ricordo = _daCustodire(ComeENato.gesto);
    final gia = registro.vociDelMese(VoceDelRicordo.chiaveDelMese(_quando));
    final stella = gia.any((v) => v.chiave == ricordo.chiave && v.stella);
    if (stella && mounted) setState(() => _custodito = true);
    if (!mounted) return;
    await annotaNelDiario(context,
        maestro: widget.maestro, responso: widget.responso, quando: _quando);
  }

  @override
  void didUpdateWidget(AzioniDelResponso vecchio) {
    super.didUpdateWidget(vecchio);
    if (vecchio.responso.titolo != widget.responso.titolo ||
        vecchio.responso.testo != widget.responso.testo ||
        vecchio.responso.perIlMaestro != widget.responso.perIlMaestro) {
      IResponsiDiOggi.ricorda(_perIlMaestro, adesso: _adesso);
    }
  }

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
  /// **LA STELLA, DAL RESPONSO. Ordine FE voce 22.7.** Lo stesso campo che
  /// si tocca nel Diario: si mette e si toglie da qui e da li'. Prima qui
  /// c'era "Custodisci", che scriveva in un magazzino a parte (lo scrigno
  /// dei custoditi): due elenchi per un solo segno, e il secondo e' stato
  /// cancellato.
  Future<void> _segna() async {
    final registro = _registro;
    if (registro == null) return;
    final ricordo = _daCustodire(ComeENato.gesto);
    final stella = !_custodito;
    setState(() => _custodito = stella);
    await registro.mettiLaStella(
      VoceDelRicordo(
        quando: _quando,
        arte: widget.responso.arte,
        maestro: widget.maestro.id,
        titolo: widget.responso.titolo,
        tipo: TipoDelRicordo.responso,
        riferimento: ricordo.chiave,
        chiaveDelDiario: ricordo.chiave,
      ),
      stella,
    );
    if (!mounted || !stella) return;
    unawaited(PaletteSensoriale.suona(context, SuonoDelCerchio.custodisci));
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(content: Text('Segnato nel Diario Cosmico.')),
    );
  }

  Future<void> _condividi() async {
    final porta = widget.condividi;
    if (porta == null) return;
    setState(() => _condividendo = true);
    try {
      // La voce e' gia' nel Diario (FE.22.6): condividere non segna niente.
      await porta();
    } finally {
      if (mounted) setState(() => _condividendo = false);
    }
  }

  void _parlane() {
    // Prima di aprire la chat: il Maestro deve sapere da quale responso la
    // persona parte, ordine EV voce 04.
    IResponsiDiOggi.apri(_perIlMaestro, adesso: _adesso);
    // **IL RESPONSO E' UNA FRASE DEL MAESTRO.** Ordine FE voce 11: il
    // "Parlane con" che cita le sue parole (il gesto dell'Alba, il Soffio, il
    // saluto della Notte, la riscrittura del Sigillo) le riprende, e non e'
    // una domanda nuova.
    IlFiloDelConsulto.ricordaLaFrase(widget.responso.testo);
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

  /// **LE ETICHETTE DELLE AZIONI A SEDICI PUNTI. Ordine DW voce 02.**
  ///
  /// Prendevano la misura di serie del pulsante, quattordici punti, e nessuno
  /// se n'era accorto: sui Doni il censimento dei caratteri (ordine CG voce
  /// 14) non arrivava fin quaggiu'. Con le azioni sull'Arcano dell'Alba le ha
  /// misurate, sotto i sedici che i Doni pretendono. I pulsanti stanno uno
  /// sotto l'altro a tutta larghezza, quindi il ruolo della riga ci sta.
  static final TextStyle _misuraDelleAzioni = TypographyTokens.titoloDiRiga();

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
                  textStyle: _misuraDelleAzioni,
                  backgroundColor: palette.gold,
                  foregroundColor: palette.deepest,
                  padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.xl, vertical: SpacingTokens.sm),
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
                  textStyle: _misuraDelleAzioni,
                  foregroundColor: widget.suChiaro
                      ? RegimeChiaro.testoSuChiaro
                      : palette.goldSoft,
                  side: BorderSide(
                      color: widget.suChiaro
                          ? RegimeChiaro.accentoSuChiaro(widget.maestro)
                          : palette.gold.withValues(alpha: 0.6))),
              onPressed: _condividendo ? null : _condividi,
              icon: const Icon(Icons.ios_share_rounded),
              label: Text(PremioDellaCondivisione.etichetta(context)),
            ),
          if (widget.condividi != null)
            const SizedBox(height: SpacingTokens.sm),
          OutlinedButton.icon(
            key: const Key('responso_custodisci'),
            style: OutlinedButton.styleFrom(
                textStyle: _misuraDelleAzioni,
                foregroundColor: widget.suChiaro
                    ? RegimeChiaro.testoSuChiaro
                    : palette.goldSoft,
                side: BorderSide(
                    color: widget.suChiaro
                        ? RegimeChiaro.accentoSuChiaro(widget.maestro)
                        : palette.gold.withValues(alpha: 0.6))),
            onPressed: _segna,
            // **SEGNA NEL DIARIO, CON LA STELLA. Ordine FE voce 22.3.** Il
            // nome dice dove va quello che si segna; la stella e' il segno
            // della persona, lo stesso del Diario (FE.22.7).
            icon: Icon(
                _custodito ? Icons.star_rounded : Icons.star_border_rounded),
            label: const Text('Segna nel Diario'),
          ),
          const SizedBox(height: SpacingTokens.sm),
          FilledButton.icon(
            key: const Key('responso_parlane'),
            // **IL RIEMPIMENTO SI PORTA ALLA SOGLIA, non si sceglie a
            // mano.** Ordine CO voce 14, 3 settembre 2026.
            //
            // Su questo pulsante il contrasto non dipende da cosa c'e'
            // dietro: e' fra la sua etichetta e il suo stesso riempimento.
            // Misurato con l'inchiostro chiaro dell'app: Medora 6,89, Caligo
            // 5,88, **Aura 2,84**. Il verde di Aura e' il piu' luminoso dei
            // tre primari, e sotto la soglia ci va da solo.
            //
            // **Non si sceglie un verde piu' scuro a mano**: si passa dalla
            // porta che gia' esiste, quella che scurisce un tono finche' non
            // regge sopra una superficie. Chi e' gia' sopra la soglia torna
            // indietro identico, quindi Medora e Caligo non si accorgono di
            // niente e il giorno che un primario cambia il conto si rifa' da
            // solo.
            style: FilledButton.styleFrom(
                textStyle: _misuraDelleAzioni,
                backgroundColor: AccentoDelMaestro.portatoSu(
                    palette.primary, palette.onPrimary),
                foregroundColor: palette.onPrimary),
            onPressed: _parlane,
            icon: const Icon(Icons.forum_outlined),
            label: Text('Parlane con ${widget.maestro.nomeAVideo}'),
          ),
        ],
      ),
    );
  }
}
