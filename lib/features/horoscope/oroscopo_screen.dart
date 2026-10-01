import '../maestri/widgets/foglio_delle_fonti.dart';
import 'dart:async';
import '../account/dati_di_nascita_screen.dart';
import '../maestri/chat/chat_openers.dart';
import '../ricordi/azioni_del_responso.dart';

import 'package:flutter/material.dart';
import '../sigilli/regia_del_cammino.dart';
import 'package:provider/provider.dart';

import '../../core/entitlement/entitlement_service.dart';
import '../../core/entitlement/plan_catalog.dart';

import '../../core/astro/zodiac.dart';
import '../../core/config/app_flags.dart';
import '../../core/horoscope/astro_tradition.dart';
import '../../core/horoscope/cielo_di_oggi.dart';
import '../../core/horoscope/corrente_del_cielo.dart';
import '../../core/horoscope/horoscope.dart';
import '../../core/horoscope/riflessione_del_cielo.dart';
import '../../core/identity/natal_identity.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/maestro/maestro.dart';
import '../../core/sensi/catalogo_suoni.dart';
import '../../core/sensi/palette_sensoriale.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/testo_che_si_scrive.dart';
import 'titolo_della_scheda_del_giorno.dart';
import '../../design_system/components/entrance_cascade.dart';
import '../../design_system/components/zodiac_glyph.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/typography/paragrafi_di_lettura.dart';
import 'answer_depth.dart';
import '../pricing/upgrade_invite.dart';
import 'horoscope_visuals.dart';
import 'la_testa_della_tradizione.dart';
import '../../design_system/transizioni/velo_del_cerchio.dart';
import '../../core/horoscope/il_domani.dart';
import '../../core/horoscope/l_ora_d_oro.dart';
import 'la_ruota_del_passaggio.dart';
import 'il_periodo_view.dart';
import '../../core/horoscope/la_settimana_del_cielo.dart';
import '../../core/entitlement/tier.dart';
import '../../core/horoscope/la_lettura_cinese.dart';
import '../../core/horoscope/i_tre_cieli.dart';
import '../../core/horoscope/il_sigillo_dei_tre_cieli.dart';
import '../../design_system/components/depth_card.dart';
import '../../core/horoscope/la_lettura_vedica.dart';
import '../../core/horoscope/l_annuale.dart';
import '../../core/horoscope/l_anno_delle_tradizioni.dart';
import '../../core/horoscope/il_capodanno_lunare.dart';
import '../../core/chat/user_profile.dart';
import '../../core/horoscope/i_testi_eu.dart';
import '../../core/horoscope/la_rivoluzione_solare.dart';
import '../../core/horoscope/gli_anni_aperti.dart';
import '../../core/astro/il_fuso_della_nascita.dart';
import '../../core/astro/birth_details.dart';
import '../../core/entitlement/listino_degli_eos.dart';
import '../../design_system/components/porta_della_spesa.dart';
import 'il_pdf_dell_anno.dart';
import 'oroscopo_per.dart';
import '../amici/l_oroscopo_dell_amico_screen.dart';
import '../amici/amici_screen.dart';
import '../../core/astro/luogo_attuale.dart';
import '../../core/lang/euphonic.dart';
import '../../core/astro/natal_chart.dart';
import '../../core/horoscope/il_metodo_del_responso.dart';
import '../../core/astro/aspetti_di_oggi.dart';
import '../../core/horoscope/i_segni_delle_tradizioni.dart';
import 'oroscopo_colors.dart';
import 'oroscopo_share_card.dart';
import 'riquadro_del_numero.dart';
import 'riflessione_del_cielo_view.dart';
import 'tradition_glyph.dart';
import '../maestri/rotta_arte.dart';
import '../../core/condivisione/premio_della_condivisione.dart';
import '../sigilli/celebrazione.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import 'corsa_dello_zodiaco.dart';
import 'la_rivelazione_del_segno.dart';

const List<String> _mesiItaliani = [
  'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno', //
  'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre'
];

/// Data locale per esteso, in italiano.
String italianLongDate(DateTime d) =>
    '${d.day} ${_mesiItaliani[d.month - 1]} ${d.year}';

/// I tre periodi dell'Oroscopo. Per la Demo solo il Giorno e' attivo: Settimana
/// e Mese restano visibili ma bloccati dietro l'abbonamento, mai un vicolo
/// cieco.
enum HoroscopePeriod {
  giorno('Giorno', unlocked: true, livelloMinimo: 0),
  settimana('Settimana', unlocked: false, livelloMinimo: 1),
  mese('Mese', unlocked: false, livelloMinimo: 2),

  /// **L'ANNO DAL COMPLEANNO, ordine ES voce 04.** Si sceglie da tutti: dentro,
  /// dall'Adepto in su si legge, sotto si apre con 300 Eos o col piano.
  anno('Anno', unlocked: true, livelloMinimo: 2);

  const HoroscopePeriod(this.label,
      {required this.unlocked, required this.livelloMinimo});

  /// **DA QUALE PIANO SI APRE, ordine ES voci 02, 03 e 06.** Il Giorno per
  /// tutti; la Settimana dall'Iniziato (livello 1); il Mese dall'Adepto
  /// (livello 2). [unlocked] dice se e' aperto a tutti, anche al Viandante.
  final int livelloMinimo;

  /// Se chi ha il piano [tier] apre questo periodo.
  bool apertoPer(Tier tier) => unlocked || tier.level >= livelloMinimo;

  final String label;
  final bool unlocked;

  /// **COME SI DICE DOPO "OROSCOPO"**, sulla card e nel testo che la
  /// accompagna. Ordine ES voce 05: chi montava la card scriveva "della" piu'
  /// il nome del periodo, e per il Mese e per l'Anno sarebbe uscito "della
  /// mese", "della anno"; non si e' mai visto perche' la card si condivideva
  /// solo dal Giorno.
  String get etichetta => switch (this) {
        HoroscopePeriod.giorno => 'del giorno',
        HoroscopePeriod.settimana => 'della settimana',
        HoroscopePeriod.mese => 'del mese',
        HoroscopePeriod.anno => 'dell\'anno',
      };

  /// Come si dice nel pulsante della condivisione: "Condividi la settimana".
  String get daCondividere => switch (this) {
        HoroscopePeriod.giorno => 'Condividi',
        HoroscopePeriod.settimana => 'Condividi la settimana',
        HoroscopePeriod.mese => 'Condividi il mese',
        HoroscopePeriod.anno => 'Condividi il tuo anno',
      };

  /// IL SOTTOTITOLO CHE SEGUE LA SCELTA, ordine 2171 voce 5.
  ///
  /// Diceva "del giorno" sempre, anche a chi aveva scelto la settimana o il
  /// mese: una riga che non guarda la scelta della persona e' una riga che
  /// prima o poi dice il falso.
  ///
  /// **"OROSCOPO DEL GIORNO", SENZA "PERSONALIZZATO".** Ordine EU voce 04, 1
  /// ottobre 2026, il fondatore: *"Sotto l'emblema del segno non c'è bisogno
  /// di scrivere "personalizzato", è sufficiente "Oroscopo del giorno o
  /// settimana o mese o anno" e sotto la data o date corrispondenti, in
  /// questo modo guadagniamo una interlinea"*.
  String get sottotitolo => switch (this) {
        HoroscopePeriod.giorno => 'Oroscopo del giorno',
        HoroscopePeriod.settimana => 'Oroscopo della settimana',
        HoroscopePeriod.mese => 'Oroscopo del mese',
        HoroscopePeriod.anno => 'Oroscopo dell\'anno',
      };

  /// **IL SOTTOTITOLO COME VA A VIDEO: LA PREPOSIZIONE STA COL SUO NOME.**
  /// Visto nelle anteprime il 30 settembre 2026: a 360 punti il sottotitolo
  /// non sta su una riga, e andava a capo dove capitava, lasciando "giorno"
  /// o "settimana" da soli sulla seconda ("Oroscopo Personalizzato della /
  /// settimana"). Padre: ordine 2171 voce 5, che ha allungato il sottotitolo
  /// col nome del periodo. Lo spazio fra la preposizione e il nome qui non si
  /// spezza: quando serve, a capo ci va "della settimana" intero.
  ///
  /// Dal 1 ottobre 2026 (EU.04) il sottotitolo sta su una riga anche a 360
  /// punti e al carattere massimo; lo spazio che non si spezza resta, perche'
  /// se un giorno tornasse lungo la preposizione stia ancora col suo nome.
  String get sottotitoloAVideo =>
      'Oroscopo ${etichetta.replaceAll(' ', '\u00A0')}';
}

/// Oroscopo Personalizzato, la headline di Medora.
///
/// Quattro schede per il segno di nascita della persona (Generale, Amore,
/// Carriera, Fortuna), ognuna con la sua forma a tema e il livello da 1 a 5,
/// deterministiche dal giorno: stesso segno stesso giorno, stesso responso. Il
/// giorno si legge una sola volta qui e si passa come intero ai calcoli, cosi'
/// l'hash resta puro. Contenuto su dispositivo, senza backend.
class OroscopoScreen extends StatefulWidget {
  const OroscopoScreen({super.key, required this.userSign, this.now});

  final Zodiac userSign;
  final DateTime? now;

  static Route<void> route({required Zodiac userSign, DateTime? now}) {
    return PassaggioDelCerchio.rotta<void>((_) => SogliaArte(
        id: 'horoscope',
        maestro: Maestro.medora,
        child: OroscopoScreen(userSign: userSign, now: now)));
  }

  @override
  State<OroscopoScreen> createState() => _OroscopoScreenState();
}

class _OroscopoScreenState extends State<OroscopoScreen>
    with SingleTickerProviderStateMixin {
  // Il giorno per l'oroscopo, letto una sola volta a livello di schermata.
  late final DateTime _date = widget.now ?? DateTime.now();
  late final int _dayOfYear = Horoscope.dayOfYear(_date);
  late final int _year = _date.year;

  HoroscopePeriod _period = HoroscopePeriod.giorno;

  /// IL CIELO SI INTERROGA, NON SI APRE GIA' PRONTO. Ordine 2171, voce 5.
  ///
  /// Prima la schermata mostrava l'oroscopo dal primo fotogramma: sembrava
  /// uscito da una macchina, senza studio ne' interpretazione. Adesso c'e' un
  /// gesto, e i testi si compongono dopo.
  /// **LA FASE DEL CONSULTO, ordine BK voci 02 e 03.**
  ///
  /// Prima erano DUE booleani, `_interrogato` e `_interrogazione`, e il
  /// difetto stava proprio li': diventavano veri nello stesso istante, quindi
  /// le quattro schede montavano al tocco mentre `scrivendo` valeva falso, e
  /// con `scrivendo` falso il responso si costruisce INTERO. La pausa esisteva
  /// e non era mai visibile. Due booleani indipendenti possono trovarsi in
  /// quattro combinazioni, e una sola era quella giusta: una fase sola non ha
  /// combinazioni sbagliate da assumere.
  _FaseDelConsulto _fase = _FaseDelConsulto.attesa;

  /// **IL SEGNO SU CUI LA CORSA SI FERMA. Ordine CC voce 03.**
  ///
  /// Non si va a cercarlo da nessuna parte: la schermata dell'Oroscopo lo ha
  /// gia' in mano, perche' e' il segno con cui e' stata aperta. Una seconda
  /// via per lo stesso dato sarebbe la solita seconda porta.
  Zodiac get _segnoDiChiGuarda => widget.userSign;

  /// **LA CORSA RESTA IN SCENA MENTRE SI DISSOLVE. Ordine CC voce 03.**
  ///
  /// Il fondatore ha scritto "poi in dissolvenza torni a mostrare la schermata
  /// di responso": la dissolvenza deve avvenire SOPRA il responso, non prima.
  /// Legandola ai due momenti della riflessione, la scena sparirebbe
  /// nell'istante in cui il responso nasce, e il responso comparirebbe di
  /// botto sotto un velo gia' tolto: cioe' il difetto che questa voce chiude.
  bool _corsaInScena = false;

  /// Il tempo che la corsa resta sopra il responso mentre si dissolve.
  Timer? _fineDellaCorsa;

  /// Quanto dura la sola dissolvenza, dentro il tempo della corsa.
  static const Duration _dissolvenzaDellaCorsa = Duration(milliseconds: 700);

  /// Vero mentre uno dei due momenti della riflessione e' a schermo.
  bool get _riflettendo =>
      _fase == _FaseDelConsulto.raccolta || _fase == _FaseDelConsulto.nomina;

  /// Quale scheda sta scrivendo adesso: le altre, dopo di lei, non sono
  /// ancora nate. Meno uno vuol dire che non ne e' nata nessuna.
  int _turnoDiScrittura = -1;

  /// La cascata delle schede, ordine BK voce 03.
  Timer? _cascata;

  /// Se l'attesa piena e' gia' stata spesa oggi, letta dal disco all'apertura.
  /// Ordine BK voce 05.
  bool _attesaPienaGiaSpesa = false;

  /// Se QUESTO consulto ha avuto la riflessione piena: decide anche quanto
  /// dura la raccolta dei corpi attorno all'emblema, cosi' la corona finisce
  /// di comporsi quando il momento finisce, breve o pieno che sia.
  bool _pienaQuestoConsulto = true;

  /// Quante schede compone il responso. Dal dato, non da un numero battuto
  /// qui: se domani i domini diventano cinque, la cascata li segue.
  static final int _quanteSchede = HoroscopeDomain.values.length;

  Future<void> _interrogaIlCielo() async {
    if (_fase != _FaseDelConsulto.attesa) return;
    // **QUALE TRADIZIONE SI INTERROGA**, ordine ES voce 08: se durante la
    // riflessione la persona tocca un'altra tradizione, questo consulto si
    // ferma e non scrive le sue schede sotto il segno dell'altra.
    final quale = _inCima;
    // **L'ATTESA PIENA UNA VOLTA AL GIORNO, ordine BK voce 05.** La prima
    // interrogazione del giorno ha la riflessione intera; le successive la
    // stessa scena, compressa. Il giorno lo decide `ConfineDelGiorno`, che e'
    // l'autorita' del confine in tutta l'app, e il conteggio sta sul disco.
    final piena = !_attesaPienaGiaSpesa;
    _pienaQuestoConsulto = piena;
    _attesaPienaGiaSpesa = true;
    unawaited(MemoriaDellaRiflessione.segnaSpesaOggi(_date));
    // **LA FESTA ASPETTA CHE LA RIFLESSIONE FINISCA, ordine BU voce 03.** La
    // domanda che la tiene viva e' la fase: finche' e' raccolta o nomina, il
    // cielo sta ancora parlando e nessuna festa ci si dipinge sopra.
    RiflessioniInCorso.entra(() => mounted && _riflettendo);
    setState(() {
      _fase = _FaseDelConsulto.raccolta;
      _corsaInScena = true;
    });
    // **LA SOGLIA, ordine BK voce 04.** Vibrazione leggera, dalla porta unica:
    // l'interruttore che governa suono e vibrazione e' quello che c'e' gia',
    // e non ne nasce un secondo. **Senza suono dal 1 ottobre 2026**, ordine
    // EU voce 03, il fondatore: *"Quando premo sul tasto di invio per avere
    // la risposta (interroga la luna, ecc) parte immediatamente un suono
    // fastidioso che deve essere eliminato"*. Suona solo la comparsa del
    // responso, col file orchestrale (ES.38).
    unawaited(PaletteSensoriale.momento(
      context,
      aptica: SchemaAptico.tocco,
    ));
    // L'OROSCOPO ENTRA NEL CAMMINO, ordine P voce 35. Il gesto e'
    // l'interrogazione del cielo, non l'apertura della scena: una scena si
    // apre anche per sbaglio, un'interrogazione no.
    // **QUALE PERIODO, ordine AR voce 11.** La scena sa se si sta
    // interrogando il giorno, la settimana o il mese: e' il dettaglio che
    // distingue chi legge sempre l'oggi da chi guarda piu' lontano.
    unawaited(RegiaDelCammino.dopoUnGesto(
      context,
      'oroscopo',
      dettagli: {'periodo': _period.name, 'tradizione': quale.name},
    ));
    // **IL SIGILLO DEI TRE CIELI, ordine ES voce 37**: la lettura del giorno
    // di questa tradizione entra nel conto di oggi.
    if (_period == HoroscopePeriod.giorno) {
      unawaited(IlSigilloDeiTreCieli.segna(quale, _date).then((stato) {
        if (!mounted) return;
        setState(() => _sigilloDeiTreCieli = stato);
        if (stato.appenaAcceso) {
          unawaited(PaletteSensoriale.momento(
            context,
            aptica: SchemaAptico.rivelazione,
            suono: SuonoDelCerchio.rivelazione,
          ));
        }
      }));
    }
    // **QUI C'ERA IL RITORNO ANTICIPATO, e l'ordine BK lo vieta.** Con Riduci
    // Movimento la funzione tornava subito e la riflessione non avveniva
    // affatto: chi ha tolto le animazioni non aveva chiesto di saltare il
    // rito, aveva chiesto che non si muovesse. I due momenti restano, fermi e
    // dichiarati, con la stessa durata; cambia solo che non c'e' movimento
    // dentro, e che il responso non si scrive a macchina.
    final passo = RiflessioneDelCielo.momento(piena: piena);
    await Future<void>.delayed(passo);
    if (!mounted || _inCima != quale) return;
    setState(() => _fase = _FaseDelConsulto.nomina);
    await Future<void>.delayed(passo);
    if (!mounted || _inCima != quale) return;
    setState(() {
      _fase = _FaseDelConsulto.responso;
      _turnoDiScrittura = 0;
      _consultate.add(quale);
    });
    // La corsa non sparisce col cambio di fase: resta sopra il responso il
    // tempo della sua dissolvenza, ed e' quella dissolvenza a scoprirlo.
    //
    // **UN TIMER CHE SI PUO' SPEGNERE, non un Future.** Un Future in volo
    // sopravvive alla schermata chiusa: la guardia `mounted` evita il guasto,
    // ma la prova cade lo stesso con "A Timer is still pending". Chi apre e
    // chiude in fretta l'Oroscopo lascerebbe indietro un pezzo di scena.
    _fineDellaCorsa?.cancel();
    _fineDellaCorsa = Timer(_dissolvenzaDellaCorsa, () {
      if (!mounted) return;
      setState(() => _corsaInScena = false);
      // Scena libera: la festa che ha aspettato la riflessione riparte adesso.
      unawaited(RegiaDelCammino.svuotaLaCoda(context, appenaChiusaUna: true));
    });
    // **LA FESTA ASPETTA CHE LA SCENA SI SIA TOLTA. Ordine CC voce 03.**
    //
    // La festa di un traguardo e' una rotta spinta sopra tutto: partendo qui,
    // copriva la corsa dello zodiaco proprio mentre si dissolveva, e
    // l'anteprima del terzo momento mostrava un cielo di stelle al posto della
    // dissolvenza. Chi legge il suo primo oroscopo vedeva la scena sparire
    // sotto una festa invece che scoprire il responso.
    //
    // Adesso parte quando la corsa se n'e' andata, insieme alla riga che la
    // toglie: e' lo stesso istante, scritto in un posto solo.
    // **LA RIVELAZIONE, ordine BK voce 04.** Parte alla comparsa del responso,
    // cioe' almeno un'intera riflessione dopo la soglia: i due suoni non si
    // sovrappongono mai, e ciascuno parte una volta sola per consulto.
    // **IL SUONO E' QUELLO DEL RESPONSO**, dal 30 settembre 2026: il
    // fondatore ha chiesto di togliere quello di prima e di mettere il suo
    // file orchestrale ([SuonoDelCerchio.responso]).
    unawaited(PaletteSensoriale.suona(context, SuonoDelCerchio.responso));
    _avviaLaCascata();
  }

  /// **LA CASCATA DELLE SCHEDE, ordine BK voce 03.**
  ///
  /// L'ordine pone due tetti diversi, la prima scheda entro 3,5 secondi dal
  /// tocco e l'ultima entro 6,0: due numeri diversi hanno senso solo se le
  /// schede non finiscono tutte insieme. Chi apre l'Oroscopo legge la Generale
  /// mentre le altre si compongono, invece di aspettare fermo che appaia
  /// tutto.
  void _avviaLaCascata() {
    _cascata?.cancel();
    // Senza movimento non c'e' scrittura da scaglionare: le schede nascono
    // tutte insieme, gia' intere.
    if (MediaQuery.of(context).disableAnimations) {
      setState(() => _turnoDiScrittura = _quanteSchede - 1);
      return;
    }
    _cascata = Timer.periodic(RiflessioneDelCielo.passoFraLeSchede, (t) {
      if (!mounted || _turnoDiScrittura >= _quanteSchede - 1) {
        t.cancel();
        return;
      }
      setState(() => _turnoDiScrittura++);
    });
  }

  // La tradizione scelta e il micro messaggio del Maestro sull'ultima
  // tradizione ancora chiusa che e' stata toccata.
  AstroTradition _tradition = AstroTradition.predefinita;
  AstroTradition? _traditionMessage;

  /// **LA TRADIZIONE IN CIMA, ordine ES voci 07 e 11.** Quella che la
  /// persona ha toccato per ultima: in testa alla schermata compare il suo
  /// segno in quella tradizione. Le tradizioni in arrivo si mostrano in cima
  /// col loro segno e la scritta "In arrivo", senza lettura.
  AstroTradition _inCima = AstroTradition.predefinita;

  /// **LE TRADIZIONI GIA' CONSULTATE IN QUESTA APERTURA**, ordine ES voce 08.
  /// Ogni tradizione ha il suo consulto: chi ha letto l'Occidentale e tocca
  /// la Cinese trova il gesto per interrogarla, non le schede cinesi gia'
  /// scritte senza averle chieste; chi torna a una tradizione gia' letta la
  /// ritrova scritta.
  final Set<AstroTradition> _consultate = {};

  /// **LA SETTIMANA E IL MESE SI CALCOLANO UNA VOLTA**, per periodo, carta e
  /// giorno: sono qualche migliaio di posizioni.
  Object? _chiaveDelPeriodo;
  IlPeriodoDelCielo? _ilPeriodo;

  IlPeriodoDelCielo _periodoDelCielo(NatalChart? carta) {
    // La data di nascita, per lo scarto della scelta delle voci (EU
    // Aggiunta): la stessa che usa il Giorno.
    final identita = context.read<ProfileController>().identity;
    final nascita = identita.isExample ? null : identita.birthDate;
    final chiave =
        (_period, carta, _date.year, _date.month, _date.day, nascita);
    if (chiave != _chiaveDelPeriodo || _ilPeriodo == null) {
      _chiaveDelPeriodo = chiave;
      _ilPeriodo = LaSettimanaDelCielo.per(
          segno: widget.userSign,
          carta: carta,
          oggi: _date,
          giorni: _period == HoroscopePeriod.mese ? 30 : 7,
          nascita: nascita);
    }
    return _ilPeriodo!;
  }

  /// **LA SETTIMANA E IL MESE DELLA VEDICA E DELLA CINESE, ordine EU voce
  /// 02**: ogni giorno e' la scheda del Giorno di quella data. Si calcolano
  /// una volta per tradizione, periodo, giorno, nascita e luogo.
  Object? _chiaveDelPeriodoAltro;
  IlPeriodoDelCielo? _ilPeriodoAltro;

  IlPeriodoDelCielo? _periodoDellaTradizione(
      NascitaDeiSegni n, CourtesyForm forma, int? animale) {
    final cinese = _inCima == AstroTradition.cinese;
    final chiave = (
      _inCima,
      _period,
      _date.year,
      _date.month,
      _date.day,
      n.locale,
      _luogo?.citta,
      forma,
      animale
    );
    if (chiave != _chiaveDelPeriodoAltro) {
      _chiaveDelPeriodoAltro = chiave;
      _ilPeriodoAltro = cinese && animale == null
          ? null
          : LaSettimanaDelCielo.dalleSchede(
              oggi: _date,
              giorni: _period == HoroscopePeriod.mese ? 30 : 7,
              tradizione: cinese ? TradizioneEu.cinese : TradizioneEu.vedica,
              scarto: ITestiEu.scarto(n.locale),
              schedeDi: (g) => cinese
                  ? LaLetturaCinese.schede(
                      oggi: g,
                      nascita: n.locale,
                      animale: animale!,
                      forma: forma,
                      diOggi: false)
                  : LaLetturaVedica.schede(
                      adesso: DateTime(g.year, g.month, g.day, 12),
                      nascita: n,
                      luogo: _luogo,
                      forma: forma,
                      oggi: false),
            );
    }
    return _ilPeriodoAltro;
  }

  /// **L'ANNO DELLA VEDICA E DELLA CINESE, ordine EU voce 02**: la Cinese da
  /// Capodanno lunare a Capodanno lunare, la Vedica da compleanno a
  /// compleanno ([LAnnoDelleTradizioni]). Si apre col piano dell'anno: gli
  /// Eos non comprano le letture Vedica e Cinese (tabella della voce ES.06).
  List<Widget> _lAnnoDellaTradizione(
    BuildContext context, {
    required MaestroPalette palette,
    required Tier tier,
    required NascitaDeiSegni nascita,
    required int? animale,
    required LivelloPersonalizzazione livello,
  }) {
    final cinese = _inCima == AstroTradition.cinese;
    final rashi = cinese ? null : LaLetturaVedica.lunaDiNascita(nascita)?.$1;
    final anno = cinese
        ? (animale == null
            ? null
            : LAnnoDelleTradizioni.cinese(_date, animale,
                annoDiNascita: IlCapodannoLunare.annoCinese(nascita.locale)))
        : (rashi == null
            ? null
            : LAnnoDelleTradizioni.vedico(_date, nascita.locale, rashi));
    if (anno == null) {
      return [
        _InvitoAllaNascita(
            testo: cinese
                ? 'Per l\'anno cinese serve la tua data di nascita: '
                    'aggiungila qui.'
                : 'Per l\'anno vedico serve la tua Luna di nascita: '
                    'aggiungi l\'ora di nascita qui.',
            palette: palette,
            alRitorno: _leggiIlLuogo),
      ];
    }
    final riga = Text(
        'Il tuo anno ${cinese ? 'cinese' : 'vedico'} va dal '
        '${italianLongDate(anno.da)} al ${italianLongDate(anno.a)}.',
        key: Key('oroscopo_${_inCima.name}_anno_riga'),
        textAlign: TextAlign.center,
        style: TypographyTokens.didascalia()
            .copyWith(color: ColorTokens.textSecondary, height: 1.4));
    if (tier.level < HoroscopePeriod.anno.livelloMinimo) {
      final piano =
          PlanCatalog.forTier(Tier.values[HoroscopePeriod.anno.livelloMinimo])
              .name;
      return [
        riga,
        const SizedBox(height: SpacingTokens.md),
        Text('L\'oroscopo dell\'anno è compreso ${conPiano(piano)}.',
            key: Key('oroscopo_${_inCima.name}_anno_chiuso'),
            textAlign: TextAlign.center,
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textPrimary, height: 1.4)),
        const SizedBox(height: SpacingTokens.sm),
        OutlinedButton(
          key: Key('oroscopo_${_inCima.name}_anno_piano'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 44),
            side: BorderSide(color: palette.gold.withValues(alpha: 0.6)),
          ),
          onPressed: () => showUpgradeInvite(
            context,
            title: 'L\'oroscopo dell\'anno si apre ${conPiano(piano)}',
            message: 'L\'anno della tua tradizione: il tono, l\'amore, il '
                'lavoro e la fortuna dei dodici mesi.',
          ),
          child: Text('Scopri il piano',
              style:
                  TypographyTokens.corpo().copyWith(color: palette.goldSoft)),
        ),
      ];
    }
    final schede = LAnnoDelleTradizioni.schede(
        cinese ? TradizioneEu.cinese : TradizioneEu.vedica, anno,
        scarto: ITestiEu.scarto(nascita.locale),
        approfondite: {
          for (final voce in _depth.entries)
            voce.key: voce.value == AnswerDepth.profonda,
        });
    return [
      riga,
      const SizedBox(height: SpacingTokens.md),
      for (final s in schede) ...[
        _HoroscopeCardView(
          scrivendo: false,
          durataScrittura: Duration.zero,
          card: s,
          palette: palette,
          pulse: _pulse,
          depth: _depth[s.domain]!,
          onDepthSelected: (scelta) => _scegliProfondita(s.domain, scelta),
          onDepthLocked: (scelta) => _showDepthLocked(s.domain, scelta),
          premiumUnlocked: PlanCatalog.haProfondita(tier),
          giaScritto: () => true,
          onScritto: () {},
          livello: livello,
        ),
        const SizedBox(height: SpacingTokens.md),
      ],
    ];
  }

  // Rivelazione una volta sola: la prima volta il messaggio entra in
  // dissolvenza, dalla seconda in poi compare gia' posato.
  final Set<AstroTradition> _traditionRevealed = <AstroTradition>{};

  // Pulsazione lenta condivisa: respiro dell'emblema e delle forme a tema.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..repeat();

  final GlobalKey _cardKey = GlobalKey();

  /// Il segno della lettura a schermo, per il testo che accompagna la card:
  /// "Leone", oppure "Cavallo nella tradizione cinese". Lo scrive il build.
  String _segnoCondiviso = '';
  bool _sharing = false;
  bool _renderCard = false;

  /// **LE TESSERE DELLA CARD DEL PERIODO, ordine ES voce 05.** Nella
  /// Settimana e nel Mese il giorno migliore di ogni campo, nell'Anno le
  /// quattro schede della Rivoluzione Solare; null nel Giorno, dove la card
  /// porta le schede del consulto. Le scrive il build.
  List<HoroscopeCard>? _schedeDelPeriodo;

  /// Profondita' scelta per ogni scheda. Nel gratuito resta la profondita'
  /// libera, Breve: la Profonda e' del Cerchio Premium.
  ///
  /// **E LA SCELTA NON ARRIVAVA QUI.** Il selettore riceveva `current` e
  /// `onLockedTap`, ma non `onSelect`: chi aveva pagato apriva il menu, sceglieva
  /// Profonda, e non succedeva niente, perche' la scelta non aveva un posto
  /// dove andare. Una funzione venduta e mai consegnata due volte di fila,
  /// prima col lucchetto sbagliato e poi col filo staccato.
  final Map<HoroscopeDomain, AnswerDepth> _depth = {
    for (final d in HoroscopeDomain.values) d: AnswerDepth.free,
  };

  /// **L'ORA D'ORO SI CALCOLA UNA VOLTA**, ordine ES voce 32: sono qualche
  /// centinaio di posizioni della Luna, e la schermata si ricostruisce a ogni
  /// fotogramma della macchina da scrivere. Si tiene per carta e per giorno.
  Object? _chiaveDellOraDOro;
  String? _fraseDellOraDOro;

  String? _oraDOro(NatalChart? carta) {
    final chiave = (carta, _date.year, _date.month, _date.day);
    if (chiave != _chiaveDellOraDOro) {
      _chiaveDellOraDOro = chiave;
      _fraseDellOraDOro = LOraDOro.di(carta, _date)?.fraseAlle(_date);
    }
    return _fraseDellOraDOro;
  }

  void _scegliProfondita(HoroscopeDomain dominio, AnswerDepth scelta) {
    if (_depth[dominio] == scelta) return;
    setState(() => _depth[dominio] = scelta);
  }

  /// I TESTI GIA' SCRITTI, ordine L voce 1. Lo stato del "gia' scritto" vive
  /// QUI, accanto alla risposta, con la chiave scheda piu' profondita' piu'
  /// giorno: viveva dentro lo State del widget della scheda, e la lista
  /// smonta le schede fuori dalla finestra di cache, quindi ogni ritorno le
  /// faceva rinascere vergini e la macchina da scrivere ripartiva da capo.
  /// Chi rinasce ora chiede a questo insieme e trova il testo gia' finito.
  final Set<String> _testiScritti = {};

  String _chiaveDelTesto(HoroscopeDomain dominio) =>
      '${_inCima.name}|${dominio.name}|${_depth[dominio]!.name}|'
      '$_year-$_dayOfYear';

  /// **DOVE SEI OGGI, per il Rahu Kalam della lettura vedica** (ordine ES
  /// voce 09): la citta' dichiarata o il GPS, come per l'alba dei riti. Si
  /// legge all'apertura e al ritorno dai dati di nascita, dove si sceglie.
  LuogoDelGiorno? _luogo;

  /// Gli anni dell'oroscopo annuale aperti con gli Eos (ordine ES voce 04).
  final Set<int> _anniAperti = {};

  /// La chiave della riga delle tradizioni: vedi dove si monta.
  final GlobalKey _chiaveDelleTradizioni = GlobalKey();

  /// **I TRE CIELI DI OGGI, ordine ES voce 36**, calcolati una volta per
  /// giorno, piano, luogo e cielo, e non a ogni fotogramma della cascata:
  /// sono tre letture intere, e il loro esito non cambia mentre le schede si
  /// scrivono.
  String? _chiaveDeiTreCieli;
  List<AccordoDelDominio> _treCieli = const [];

  /// **IL SIGILLO DEI TRE CIELI, ordine ES voce 37**: quali tradizioni sono
  /// state lette oggi, e se il Sigillo e' acceso.
  StatoDeiTreCieli _sigilloDeiTreCieli = StatoDeiTreCieli.vuoto;

  /// Se l'avviso del prossimo compleanno solare e' gia' stato programmato in
  /// questa apertura: una volta basta.
  bool _avvisoDellAnno = false;

  /// **IL TOCCO SU "AMICO/A"**, ordine EU voce 05: "I tuoi amici" per
  /// scegliere, poi la lettura dell'amico scelto, che porta in cima la stessa
  /// riga col suo nome.
  Future<void> _scegliUnAmico(String nomeTuo) async {
    final navigatore = Navigator.of(context);
    final scelto = await navigatore.push(AmiciScreen.route(perScegliere: true));
    if (scelto == null || !mounted) return;
    unawaited(navigatore
        .push(LOroscopoDellAmicoScreen.route(scelto, nomeTuo: nomeTuo)));
  }

  /// **LE DATE DELL'ANNO PER LA TESTATA**, ordine EU voce 04: il ritorno del
  /// Sole in corso e il prossimo, se la nascita ha l'ora; senza, la testata
  /// dice "dal tuo compleanno al prossimo" e la vista chiede l'ora.
  (DateTime, DateTime)? _ilTuoAnno(NascitaDeiSegni? nascita) {
    if (nascita == null || !nascita.oraNota) return null;
    final nascitaUtc = IlFusoDellaNascita.inUtc(nascita.locale, nascita.fuso);
    return (
      LaRivoluzioneSolare.ritornoInCorso(nascitaUtc, _date).toLocal(),
      LaRivoluzioneSolare.prossimoRitorno(nascitaUtc, _date).toLocal(),
    );
  }

  /// **L'ANNO DAL COMPLEANNO, ordine ES voce 04.** Le righe della vista
  /// dell'anno: cio' che manca per calcolarlo, oppure la porta per aprirlo,
  /// oppure le quattro schede della Rivoluzione Solare.
  List<Widget> _lAnno(
    BuildContext context, {
    required MaestroPalette palette,
    required Tier tier,
    required NascitaDeiSegni? nascita,
    required BirthDetails? dettagli,
    required LivelloPersonalizzazione livello,
  }) {
    // Senza l'ora il ritorno del Sole non ha un'ora, e l'Ascendente dell'anno
    // non esiste: si dice, e si porta a darla.
    if (nascita == null || !nascita.oraNota) {
      return [
        _InvitoAllaNascita(
            testo: 'L\'anno dal tuo compleanno si legge dall\'istante in cui '
                'il Sole torna dov\'era alla tua nascita: serve l\'ora di '
                'nascita, aggiungila qui.',
            palette: palette,
            alRitorno: _leggiIlLuogo),
      ];
    }
    // Il luogo: dove vivi adesso, altrimenti quello di nascita, e si dice.
    final lat = _luogo?.lat ?? dettagli?.place?.latitude;
    final lon = _luogo?.lon ?? dettagli?.place?.longitude;
    final dove = _luogo?.citta ?? dettagli?.place?.label ?? 'il tuo luogo';
    if (lat == null || lon == null) {
      return [
        _InvitoAllaNascita(
            testo: 'Il tema dell\'anno si calcola per il luogo in cui sei: '
                'scegli dove vivi adesso.',
            palette: palette,
            alRitorno: _leggiIlLuogo),
      ];
    }
    final nascitaUtc = IlFusoDellaNascita.inUtc(nascita.locale, nascita.fuso);
    final istante = LaRivoluzioneSolare.ritornoInCorso(nascitaUtc, _date);
    final prossimo = LaRivoluzioneSolare.prossimoRitorno(nascitaUtc, _date);
    final aperto = tier.level >= HoroscopePeriod.anno.livelloMinimo ||
        _anniAperti.contains(istante.year);
    final locale = istante.toLocal();
    final ora = '${locale.hour.toString().padLeft(2, '0')}:'
        '${locale.minute.toString().padLeft(2, '0')}';
    final riga = Text(
        'Il tuo anno va dal ${italianLongDate(locale)} al '
        '${italianLongDate(prossimo.toLocal())}. La Rivoluzione Solare è '
        'l\'istante in cui il Sole è tornato dov\'era alla tua nascita: il '
        '${italianLongDate(locale)} alle $ora, calcolata per '
        '$dove${_luogo == null ? ', il luogo di nascita' : ''}.',
        key: const Key('oroscopo_anno_riga'),
        textAlign: TextAlign.center,
        style: TypographyTokens.didascalia()
            .copyWith(color: ColorTokens.textSecondary, height: 1.4));
    if (!aperto) {
      final piano =
          PlanCatalog.forTier(Tier.values[HoroscopePeriod.anno.livelloMinimo])
              .name;
      return [
        riga,
        const SizedBox(height: SpacingTokens.md),
        Text(
            'L\'oroscopo dell\'anno è compreso ${conPiano(piano)}. Per l\'anno '
            'che corre puoi aprirlo anche con gli Eos.',
            key: const Key('oroscopo_anno_chiuso'),
            textAlign: TextAlign.center,
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textPrimary, height: 1.4)),
        const SizedBox(height: SpacingTokens.sm),
        PortaDellaSpesa(
          voce: ListinoDegliEos.oroscopoAnnuale,
          etichetta: 'Apri il tuo anno',
          suSpesaFatta: () {
            setState(() => _anniAperti.add(istante.year));
            unawaited(GliAnniAperti.apri(istante.year));
          },
        ),
        const SizedBox(height: SpacingTokens.sm),
        OutlinedButton(
          key: const Key('oroscopo_anno_piano'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 44),
            side: BorderSide(color: palette.gold.withValues(alpha: 0.6)),
          ),
          onPressed: () => showUpgradeInvite(
            context,
            title: 'L\'oroscopo dell\'anno si apre ${conPiano(piano)}',
            message: 'Ogni compleanno il tema della Rivoluzione Solare: il '
                'tono dell\'anno, dove va l\'energia, l\'amore, il lavoro e '
                'la fortuna dei dodici mesi.',
          ),
          child: Text('Scopri il piano',
              style:
                  TypographyTokens.corpo().copyWith(color: palette.goldSoft)),
        ),
      ];
    }
    final tema = LaRivoluzioneSolare.tema(istante, lat, lon);
    // **LA PROFONDITA' ANCHE SULL'ANNO.** Il fondatore, 30 settembre 2026:
    // *"Ogni scheda deve avere sempre il pulsante profondità e la scelta
    // "approfondita" è esclusiva dei premium."* A video ogni scheda si legge
    // alla profondita' scelta; il PDF e la card portano la lettura intera.
    final forma = context.read<ProfileController>().courtesy;
    final schede = LAnnuale.schede(tema,
        forma: forma,
        nascita: nascita.locale,
        approfondite: {
          for (final voce in _depth.entries)
            voce.key: voce.value == AnswerDepth.profonda,
        });
    final intere = LAnnuale.schede(tema, forma: forma, nascita: nascita.locale);
    _schedeDelPeriodo = intere;
    // L'AVVISO DEL COMPLEANNO: l'anno nuovo e' pronto all'istante del
    // prossimo ritorno. Una volta per apertura, e solo col permesso.
    if (!_avvisoDellAnno) {
      _avvisoDellAnno = true;
      unawaited(LAvvisoDellAnno.programma(prossimo));
    }
    return [
      riga,
      const SizedBox(height: SpacingTokens.md),
      for (final s in schede) ...[
        _HoroscopeCardView(
          scrivendo: false,
          durataScrittura: Duration.zero,
          card: s,
          palette: palette,
          pulse: _pulse,
          depth: _depth[s.domain]!,
          onDepthSelected: (scelta) => _scegliProfondita(s.domain, scelta),
          onDepthLocked: (scelta) => _showDepthLocked(s.domain, scelta),
          premiumUnlocked: PlanCatalog.haProfondita(tier),
          giaScritto: () => true,
          onScritto: () {},
          livello: livello,
        ),
        const SizedBox(height: SpacingTokens.md),
      ],
      // LA CARD DELL'ANNO, col suo emblema (ordine ES voce 05).
      _CondividiIlPeriodo(
          periodo: HoroscopePeriod.anno,
          palette: palette,
          sharing: _sharing,
          onShare: _onShare),
      const SizedBox(height: SpacingTokens.sm),
      // IL PDF DELL'ANNO, all'Illuminato (l'annuale approvato dal fondatore).
      if (tier.level >= Tier.tier3.level)
        OutlinedButton(
          key: const Key('oroscopo_anno_pdf'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 44),
            side: BorderSide(color: palette.gold.withValues(alpha: 0.6)),
          ),
          onPressed: () async {
            final andata = await IlPdfDellAnno.condividi(
              intere,
              titolo: 'Il tuo anno dal ${italianLongDate(locale)}',
              sottotitolo: 'Rivoluzione Solare del ${italianLongDate(locale)} '
                  'alle $ora, per $dove',
            );
            // Il premio della condivisione avvenuta, come per ogni responso
            // mandato (ordine BG voce 04).
            if (andata && context.mounted) {
              await PremioDellaCondivisione.premia(context,
                  cosa: 'Hai condiviso il tuo anno');
            }
          },
          // Su una riga: "Scarica il PDF del tuo anno" col premio accanto
          // andava a capo sul Realme (visto il 30 settembre 2026).
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
                PremioDellaCondivisione.etichetta(context,
                    base: 'Il PDF del tuo anno'),
                key: const Key('oroscopo_anno_pdf_etichetta'),
                maxLines: 1,
                softWrap: false,
                style:
                    TypographyTokens.corpo().copyWith(color: palette.goldSoft)),
          ),
        ),
    ];
  }

  Future<void> _leggiIlLuogo() async {
    final l = await DoveSonoAdesso.letto();
    if (!mounted || l == null) return;
    setState(
        () => _luogo = LuogoDelGiorno(lat: l.lat, lon: l.lon, citta: l.citta));
  }

  @override
  void initState() {
    super.initState();
    unawaited(_leggiIlLuogo());
    unawaited(GliAnniAperti.letti().then((a) {
      if (mounted) setState(() => _anniAperti.addAll(a));
    }));
    // **L'ATTESA PIENA SI CHIEDE AL DISCO ALL'APERTURA, ordine BK voce 05.**
    // Si legge qui e non al tocco, perche' un `await` fra il dito e il primo
    // momento sarebbe un vuoto proprio nell'istante che questo ordine esiste
    // per riempire. Finche' il disco non ha risposto vale la riflessione
    // PIENA: nel dubbio si aspetta di piu', mai di meno, e saltare il rito e'
    // l'unico esito che l'ordine vieta.
    unawaited(MemoriaDellaRiflessione.giaSpesaOggi(_date).then((spesa) {
      if (mounted) _attesaPienaGiaSpesa = spesa;
    }));
    unawaited(IlSigilloDeiTreCieli.di(_date).then((stato) {
      if (mounted) setState(() => _sigilloDeiTreCieli = stato);
    }));
  }

  @override
  void dispose() {
    _fineDellaCorsa?.cancel();
    _cascata?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // L'Oroscopo e' di Medora: blu e oro suoi, sempre, anche se il Maestro
    // attivo altrove fosse un altro. Lo sfondo resta il cosmo ambientale.
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final profile = context.watch<ProfileController>();
    final vocative = Horoscope.vocativeFor(profile.vocative, profile.courtesy);
    // IL CIELO VERO DI QUESTA PERSONA, quando c'e' una carta da interrogare.
    //
    // **Qui muore l'hash.** La corrente del giorno usciva da un pool di frasi
    // generiche scelte da una hash su segno, giorno e anno: cambiava tutti i
    // giorni senza che in cielo fosse cambiato niente, ed era identica per due
    // persone dello stesso segno nate a vent'anni di distanza. Adesso, con la
    // carta natale, la scrive il cielo. Senza carta si torna alla hash, e la
    // nota qui sotto lo dichiara invece di lasciarlo credere.
    // IL CIELO VERO, non il ripiego, ordine 2169 voce 4. `chart` torna anche
    // la carta essenziale, che ha il solo Sole: i transiti su un cielo di un
    // astro non sono transiti. Il livello a valle ripiegava gia' sul pool a
    // hash quando la carta era essenziale, ma lo capiva guardando dentro
    // l'oggetto: adesso la distinzione la fa la porta, una volta per tutti.
    final cielo = CieloDiOggi.perIlGiorno(
        adesso: _date,
        carta: context.watch<BirthIdentityController>().cartaCompleta);
    final notaDelCielo = CorrenteDelCielo.notaDelLivello(cielo);
    // I dati di nascita per il segno delle altre tradizioni (ordine ES).
    final nascita = context.watch<BirthIdentityController>().details;
    final tier = context.watch<EntitlementService>().tier;
    final nascitaDeiSegni = NascitaDeiSegni.daiDati(nascita, profile.identity);
    final segnoInCima = nascitaDeiSegni == null
        ? null
        : ISegniDelleTradizioni.per(_inCima, nascitaDeiSegni);
    // **LA LETTURA CINESE, ordine ES voce 08**: dal primo piano a pagamento,
    // con la data di nascita (l'animale dell'anno e il tronco del giorno).
    // **LA VEDICA, voce 09**: con la Luna di nascita, e l'ora per la stella.
    final cinese = _inCima == AstroTradition.cinese;
    final vedica = _inCima == AstroTradition.vedica;
    final altra = cinese || vedica;
    final aggettivo = cinese ? 'cinese' : 'vedica';
    // Il nome con cui Medora chiama la persona, nell'apertura della lettura.
    final comeTiChiamo = vocative;
    // Il nome nella riga "Oroscopo per": il primo nome, senza cognome, come
    // sulla card; senza un nome, "te".
    final nomeTuo =
        OroscopoShareCard.soloIlNome(profile.profile.displayName) ?? 'te';
    final leggeLaTradizione = _inCima.leggibilePer(tier);
    final animale = cinese ? segnoInCima?.animale : null;
    final schedeCinesi = cinese &&
            leggeLaTradizione &&
            animale != null &&
            nascitaDeiSegni != null
        ? LaLetturaCinese.schede(
            oggi: _date,
            nascita: nascitaDeiSegni.locale,
            animale: animale,
            forma: profile.courtesy,
            approfondite: {
              for (final voce in _depth.entries)
                voce.key: voce.value == AnswerDepth.profonda,
            },
            vocativo: comeTiChiamo)
        : null;
    final schedeVediche = vedica && leggeLaTradizione && nascitaDeiSegni != null
        ? LaLetturaVedica.schede(
            adesso: _date,
            nascita: nascitaDeiSegni,
            luogo: _luogo,
            forma: profile.courtesy,
            approfondite: {
              for (final voce in _depth.entries)
                voce.key: voce.value == AnswerDepth.profonda,
            },
            vocativo: comeTiChiamo)
        : null;
    final schedeAltre = schedeCinesi ?? schedeVediche;
    // Il segno lunare di nascita, su cui si ferma la corsa della Vedica.
    final rashi = vedica && nascitaDeiSegni != null
        ? LaLetturaVedica.lunaDiNascita(nascitaDeiSegni)?.$1
        : null;
    // Il consulto del giorno: l'Occidentale sempre, la Cinese e la Vedica
    // quando hanno le loro schede. La Settimana e il Mese hanno la loro vista.
    final consulto = _period == HoroscopePeriod.giorno &&
        (_inCima == AstroTradition.occidentale || schedeAltre != null);
    _segnoCondiviso = schedeAltre != null
        ? '${segnoInCima!.nome} nella tradizione $aggettivo'
        : widget.userSign.italianName;
    // La card del periodo: l'anno la scrive `_lAnno`, quando e' aperto.
    final periodoAVideo = _inCima == AstroTradition.occidentale &&
        (_period == HoroscopePeriod.settimana ||
            _period == HoroscopePeriod.mese);
    _schedeDelPeriodo = periodoAVideo
        ? LaSettimanaDelCielo.tessere(
            _periodoDelCielo(
                context.watch<BirthIdentityController>().cartaCompleta),
            mese: _period == HoroscopePeriod.mese)
        : null;
    final cards = schedeAltre ??
        Horoscope.forSign(
            sign: widget.userSign,
            dayOfYear: _dayOfYear,
            year: _year,
            // L'apertura viene dal corpus del Giorno (EU Aggiunta), col
            // vocativo di oggi.
            vocativo: vocative,
            cielo: cielo,
            profonde: {
              for (final voce in _depth.entries)
                voce.key: voce.value == AnswerDepth.profonda,
            },
            // Il giorno personale del numero fortunato, ordine ES voce 29.
            nascita:
                profile.identity.isExample ? null : profile.identity.birthDate);

    // **I TRE CIELI, ordine ES voce 36.** Solo a chi legge tutte e tre le
    // tradizioni, cioe' dal primo piano a pagamento e con la data di
    // nascita: al Viandante direbbero cio' che la Cinese e la Vedica
    // vedono, e quelle letture non sono sue.
    final chiaveDeiTreCieli = '${_date.year}-${_date.month}-${_date.day}|'
        '${tier.name}|${_luogo?.citta}|${cielo.livello}|'
        '${nascitaDeiSegni?.locale}';
    if (_chiaveDeiTreCieli != chiaveDeiTreCieli) {
      _chiaveDeiTreCieli = chiaveDeiTreCieli;
      _treCieli = const [];
      if (nascitaDeiSegni != null &&
          AstroTradition.cinese.leggibilePer(tier) &&
          AstroTradition.vedica.leggibilePer(tier)) {
        final animaleDiNascita =
            ISegniDelleTradizioni.per(AstroTradition.cinese, nascitaDeiSegni)
                .animale;
        _treCieli = ITreCieli.di(
          occidentale: Horoscope.forSign(
              sign: widget.userSign,
              dayOfYear: _dayOfYear,
              year: _year,
              cielo: cielo,
              nascita: profile.identity.isExample
                  ? null
                  : profile.identity.birthDate),
          cinese: animaleDiNascita == null
              ? null
              : LaLetturaCinese.schede(
                  oggi: _date,
                  nascita: nascitaDeiSegni.locale,
                  animale: animaleDiNascita,
                  forma: profile.courtesy),
          vedica: LaLetturaVedica.schede(
              adesso: _date,
              nascita: nascitaDeiSegni,
              luogo: _luogo,
              forma: profile.courtesy),
        );
      }
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: palette.goldSoft),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Indietro',
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            // **L'OROSCOPO PER UN AMICO NON STA PIU' NELLA BARRA.** Il 30
            // settembre 2026 il fondatore l'aveva voluto in alto e stava qui;
            // il 1 ottobre (ordine EU voce 05) lo ha trovato poco visibile, e
            // adesso e' la riga "Oroscopo per" sopra i periodi.
            // IL BORSELLINO, ordine S voce 06: stesso segno, stesso angolo, in ogni
            // schermata della pratica. Un saldo che appare e scompare non si impara.
            // **LA FONTE ARRIVA A CHI LEGGE.** Ordine CS, voce S2 della
            // scansione: il selettore che si chiama «tradizione» e' la scelta fra scuole astrologiche,
            // non una dichiarazione di fonti.
            actions: [
              FoglioDelleFonti.bottone(context,
                  palette: palette,
                  testo: TestiDelleFonti.oroscopo,
                  chiave: 'oroscopo_fonti'),
              const AngoloDellaBarra(),
            ],
          ),
          body: CosmosBackground(
            seed: 5,
            showZodiac: false,
            child: SafeArea(
              child: Stack(
                children: [
                  EntranceCascade(
                    listKey: const Key('oroscopo_list'),
                    // Nessun vuoto sopra l'eroe: il segno parte in alto.
                    padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, 0,
                        SpacingTokens.lg, SpacingTokens.lg),
                    hero: _inCima != AstroTradition.occidentale
                        ? LaTestaDellaTradizione(
                            tradizione: _inCima,
                            segno: segnoInCima,
                            palette: palette,
                          )
                        : Column(
                            children: [
                              // IL NOME DEL SEGNO, GRANDE, SOPRA L'EMBLEMA: e' la prima
                              // cosa che la persona cerca, e stava sotto la figura.
                              // Accanto, dall'ordine ES voce 10, il punto
                              // interrogativo che apre la nota della tradizione.
                              NomeConLaNota(
                                  nome: widget.userSign.italianName,
                                  tradizione: AstroTradition.occidentale,
                                  palette: palette,
                                  chiave: const Key('oroscopo_sign_name')),
                              const SizedBox(height: SpacingTokens.xs),
                              _Hero(
                                sign: widget.userSign,
                                palette: palette,
                                pulse: _pulse,
                                // L'EMBLEMA PULSA MENTRE IL CIELO SI INTERROGA: e' il
                                // segno che qualcosa sta accadendo, e dura quanto la
                                // pausa dichiarata.
                                interrogazione: _riflettendo,
                                // I CORPI VERI ATTORNO ALL'EMBLEMA, e restano per
                                // TUTTA la riflessione (ordine BZ voce 06).
                                //
                                // **Prima stavano nel solo primo momento**, e al
                                // secondo la corona spariva: restavano una riga di testo
                                // e due pallini, cioe' la scena si svuotava a meta'
                                // proprio mentre nominava il fatto del giorno. E' la
                                // stessa forma di difetto della voce BZ.07, dove fra
                                // l'ultima carta e la riflessione restava Medora da
                                // sola. I corpi si compongono nel primo momento e
                                // restano composti nel secondo.
                                corona: _riflettendo,
                                adesso: _date,
                                durataDelMomento: RiflessioneDelCielo.momento(
                                    piena: _pienaQuestoConsulto),
                              ),
                            ],
                          ),
                    items: [
                      // **UNA TRADIZIONE IN ARRIVO NON HA PERIODI.** Visto sul
                      // Realme il 30 settembre 2026: sotto l'emblema della
                      // tradizione egizia restavano "Oroscopo personalizzato
                      // del giorno" e il selettore dei periodi, e toccando
                      // "Settimana" cambiava solo quel titolo, perche' una
                      // lettura non c'e'. Padre: ordine ES voce 11. Il titolo
                      // e i periodi stanno solo dove c'e' una lettura.
                      //
                      // **LA TESTA DI UNA TRADIZIONE HA IL SUO RESPIRO SOTTO.**
                      // Visto nelle anteprime il 30 settembre 2026: la frase
                      // del segno ("Il tuo segno cinese è il Cavallo") stava
                      // attaccata al sottotitolo, e il segnale "In arrivo"
                      // toccava la riga delle tradizioni. Padre: ordine ES
                      // voce 07, che ha messo il segno in cima senza uno
                      // stacco da cio' che segue (l'emblema occidentale lo
                      // porta nella sua figura).
                      if (_inCima != AstroTradition.occidentale)
                        const SizedBox(
                            key: Key('oroscopo_respiro_sotto_la_testa'),
                            height: SpacingTokens.md),
                      if (_inCima.unlocked) ...[
                        _Heading(
                            periodo: _period,
                            date: _date,
                            palette: palette,
                            anno: _period == HoroscopePeriod.anno
                                ? _ilTuoAnno(nascitaDeiSegni)
                                : null),
                        const SizedBox(height: SpacingTokens.md),
                        // **"OROSCOPO PER", ordine EU voce 05**: proprio
                        // sopra il selettore dei periodi, il nome della
                        // persona scelto e "amico/a".
                        OroscopoPer(
                          nomeTuo: nomeTuo,
                          palette: palette,
                          onTe: () {},
                          onAmico: () => _scegliUnAmico(nomeTuo),
                        ),
                        const SizedBox(height: SpacingTokens.sm),
                        _PeriodTabs(
                          current: _period,
                          palette: palette,
                          onSelect: _selectPeriod,
                          tier: tier,
                        ),
                        const SizedBox(height: SpacingTokens.sm),
                      ],
                      // Accanto al periodo, la tradizione: lo stesso cielo letto con
                      // occhi diversi. Aperta l'Occidentale, le altre col lucchetto.
                      // Il chip scelto e' quello della tradizione in cima: chi
                      // tocca l'Araba vede l'Araba accesa (vista sul Realme).
                      _TraditionTabs(
                        // La riga tiene il suo stato (dove e' scorsa) anche
                        // quando sopra di lei il titolo e i periodi compaiono
                        // o spariscono e il suo posto nella lista cambia.
                        key: _chiaveDelleTradizioni,
                        current: _inCima,
                        palette: palette,
                        onSelect: _selectTradition,
                      ),
                      _TraditionInvite(
                        tradition: _traditionMessage,
                        maestro: Maestro.medora,
                        palette: palette,
                        // Rivelazione una volta sola per tradizione.
                        animate: _traditionMessage != null &&
                            !_traditionRevealed.contains(_traditionMessage),
                      ),
                      const SizedBox(height: SpacingTokens.md),
                      // IL GESTO CHE APRE IL CONSULTO. Prima del tocco l'oroscopo
                      // non si vede: il cielo si interroga.
                      // **UNA TRADIZIONE IN ARRIVO IN CIMA NON HA LETTURA**,
                      // ordine ES voce 11: sotto il suo segno non si apre il
                      // consulto occidentale, che si leggerebbe come suo. Si
                      // dice, e si offre il gesto per tornare.
                      // LA SETTIMANA E IL MESE, ordine ES voci 02 e 03.
                      if (_inCima == AstroTradition.occidentale &&
                          (_period == HoroscopePeriod.settimana ||
                              _period == HoroscopePeriod.mese))
                        IlPeriodoView(
                          periodo: _periodoDelCielo(context
                              .watch<BirthIdentityController>()
                              .cartaCompleta),
                          mese: _period == HoroscopePeriod.mese,
                          palette: palette,
                          livello: cielo.livello,
                          // La profondita' su ogni scheda, come nel Giorno.
                          profondita: _depth,
                          premiumUnlocked: PlanCatalog.haProfondita(tier),
                          onDepthSelected: _scegliProfondita,
                          onDepthLocked: _showDepthLocked,
                        ),
                      // LA CARD DELLA SETTIMANA E DEL MESE, col loro emblema
                      // (ordine ES voce 05).
                      if (periodoAVideo) ...[
                        const SizedBox(height: SpacingTokens.md),
                        _CondividiIlPeriodo(
                            periodo: _period,
                            palette: palette,
                            sharing: _sharing,
                            onShare: _onShare),
                      ],
                      // L'ANNO DAL COMPLEANNO, ordine ES voce 04.
                      if (_inCima == AstroTradition.occidentale &&
                          _period == HoroscopePeriod.anno)
                        ..._lAnno(context,
                            palette: palette,
                            tier: tier,
                            nascita: nascitaDeiSegni,
                            dettagli: nascita,
                            livello: cielo.livello),
                      if (!_inCima.unlocked)
                        _LaLetturaEInArrivo(
                          tradizione: _inCima,
                          palette: palette,
                          // All'ultima tradizione che la persona legge:
                          // la Cinese sul piano gratuito non ha lettura, e
                          // tornarci sarebbe tornare a un segno senza
                          // consulto (ordine ES voce 08).
                          onTorna: () => _selectTradition(
                              _tradition.leggibilePer(tier)
                                  ? _tradition
                                  : AstroTradition.occidentale),
                        ),
                      // **LA SETTIMANA, IL MESE E L'ANNO DELLA VEDICA E DELLA
                      // CINESE**, ordine EU voce 02: prima dicevano "sono in
                      // arrivo: qui leggi il giorno". Il piano gratuito vede
                      // il segno e l'invito; senza la data si chiede la data.
                      if (altra &&
                          leggeLaTradizione &&
                          nascitaDeiSegni != null &&
                          segnoInCima != null &&
                          (_period == HoroscopePeriod.settimana ||
                              _period == HoroscopePeriod.mese))
                        if (_periodoDellaTradizione(
                                nascitaDeiSegni, profile.courtesy, animale)
                            case final p?)
                          IlPeriodoView(
                            key: Key('oroscopo_${_inCima.name}_periodo'),
                            periodo: p,
                            mese: _period == HoroscopePeriod.mese,
                            palette: palette,
                            livello: cielo.livello,
                            profondita: _depth,
                            premiumUnlocked: PlanCatalog.haProfondita(tier),
                            onDepthSelected: _scegliProfondita,
                            onDepthLocked: _showDepthLocked,
                          ),
                      if (altra &&
                          leggeLaTradizione &&
                          nascitaDeiSegni != null &&
                          segnoInCima != null &&
                          _period == HoroscopePeriod.anno)
                        ..._lAnnoDellaTradizione(context,
                            palette: palette,
                            tier: tier,
                            nascita: nascitaDeiSegni,
                            animale: cinese ? segnoInCima.animale : null,
                            livello: cielo.livello),
                      if (altra && !leggeLaTradizione)
                        _LaLetturaEInArrivo(
                          tradizione: _inCima,
                          palette: palette,
                          chiave:
                              Key('oroscopo_${_inCima.name}_invito_al_piano'),
                          chiaveDelGesto:
                              Key('oroscopo_${_inCima.name}_scopri_il_piano'),
                          testo:
                              'Qui vedi il tuo segno ${cinese ? 'cinese' : 'vedico'}. '
                              'La lettura del giorno, '
                              '${cinese ? 'dall\'almanacco e dai Dieci Dei' : 'dalla Luna e dal calendario indiano'}, '
                              'si apre ${conPiano(PlanCatalog.forTier(Tier.values[_inCima.livelloDellaLettura]).name)}.',
                          etichetta: 'Scopri il piano',
                          onTorna: () => _invitaAllaLettura(_inCima),
                        ),
                      if (altra && leggeLaTradizione && segnoInCima == null)
                        _InvitoAllaNascita(
                            testo: 'Per la lettura $aggettivo serve la tua '
                                'data di nascita: aggiungila qui.',
                            palette: palette,
                            alRitorno: _leggiIlLuogo),
                      // **LA VEDICA DICE CHE COSA LE MANCA**, ordine ES voce
                      // 09: il segno lunare incerto senza l'ora; la stella
                      // senza l'ora; il Rahu Kalam senza la citta'.
                      if (vedica &&
                          leggeLaTradizione &&
                          _period == HoroscopePeriod.giorno &&
                          segnoInCima != null &&
                          schedeVediche == null)
                        _InvitoAllaNascita(
                            testo: 'Il giorno della tua nascita la Luna ha '
                                'cambiato segno: con l\'ora di nascita so '
                                'qual è il tuo: così leggo il tuo giorno.',
                            palette: palette,
                            alRitorno: _leggiIlLuogo),
                      if (schedeVediche != null &&
                          nascitaDeiSegni != null &&
                          !nascitaDeiSegni.oraNota)
                        _InvitoAllaNascita(
                            testo: 'Con l\'ora di nascita leggo anche la tua '
                                'stella, la Tara Bala: aggiungila qui.',
                            palette: palette,
                            alRitorno: _leggiIlLuogo),
                      if (schedeVediche != null && _luogo == null)
                        _InvitoAllaNascita(
                            testo: 'Per il Rahu Kalam di oggi dimmi dove '
                                'vivi adesso: scegli la tua città.',
                            palette: palette,
                            alRitorno: _leggiIlLuogo),
                      if (consulto && _fase == _FaseDelConsulto.attesa)
                        _InterrogaIlCielo(
                          palette: palette,
                          onTap: _interrogaIlCielo,
                          etichetta: cinese
                              ? 'Apri l\'almanacco'
                              : vedica
                                  ? 'Interroga la Luna'
                                  : 'Interroga il cielo',
                        ),
                      // L'INVITO A COMPLETARE I DATI DI NASCITA, ordine ES
                      // voce 31. **Sotto il gesto, non sopra**: sopra spingeva
                      // "Interroga il cielo" sotto la piega dello schermo, e il
                      // gesto principale della schermata va visto senza
                      // scorrere. Dopo il consulto resta qui, sopra le schede.
                      if (_inCima == AstroTradition.occidentale &&
                          CorrenteDelCielo.rigaDellInvito(cielo) != null)
                        _InvitoAllaNascita(
                            testo: CorrenteDelCielo.rigaDellInvito(cielo)!,
                            palette: palette),
                      // I DUE MOMENTI DELLA RIFLESSIONE, ordine BK voce 03. Stanno
                      // dove staranno le schede, cosi' lo sguardo non si sposta
                      // quando il responso arriva.
                      if (consulto && _riflettendo)
                        RigaDellaRiflessione(
                          momento: _fase == _FaseDelConsulto.raccolta
                              ? MomentoDellaRiflessione.raccolta
                              : MomentoDellaRiflessione.nomina,
                          cielo: cielo,
                          palette: palette,
                          almanacco: cinese
                              ? LaLetturaCinese.fattoDelGiorno(_date)
                              : vedica
                                  ? LaLetturaVedica.fattoDelGiorno(
                                      _date, _luogo)
                                  : null,
                        ),
                      // **LE SCHEDE NASCONO DOPO LA RIFLESSIONE, E UNA ALLA
                      // VOLTA.** Ordine BK voci 02 e 03. Prima montavano al tocco,
                      // ed e' per questo che il responso si vedeva intero: una
                      // scheda che esiste mentre la scrittura non e' cominciata
                      // mostra tutto il suo testo. Qui, finche' non e' il suo
                      // turno, la scheda non e' in albero affatto: i caratteri del
                      // responso presenti durante la riflessione sono ZERO, e non
                      // per un'opacita' che li nasconde.
                      if (consulto && _fase == _FaseDelConsulto.responso)
                        for (var i = 0; i < cards.length; i++)
                          if (i <= _turnoDiScrittura) ...[
                            _HoroscopeCardView(
                              // Il cielo occidentale non entra nella
                              // lettura cinese: niente ruota, niente ora d'oro.
                              passaggio: !altra && cielo.ceCieloVero
                                  ? CorrenteDelCielo.vociPer(
                                          cielo, cards[i].domain)
                                      .firstOrNull
                                  : null,
                              carta: altra
                                  ? null
                                  : context
                                      .watch<BirthIdentityController>()
                                      .cartaCompleta,
                              adesso: _date,
                              oraDOro: altra
                                  ? null
                                  : _oraDOro(context
                                      .watch<BirthIdentityController>()
                                      .cartaCompleta),
                              scrivendo: true,
                              durataScrittura:
                                  RiflessioneDelCielo.scritturaDiUnaScheda,
                              card: cards[i],
                              palette: palette,
                              pulse: _pulse,
                              depth: _depth[cards[i].domain]!,
                              // Il "gia' scritto" abita la schermata: la scheda lo
                              // legge quando nasce e lo dichiara quando finisce.
                              // LETTURA VIVA, non un booleano catturato: i widget
                              // della lista vengono costruiti una volta e rinascono
                              // dopo, quindi un valore fissato alla costruzione
                              // sarebbe sempre vecchio. Il gancio legge il registro
                              // nel momento della rinascita.
                              giaScritto: () => _testiScritti
                                  .contains(_chiaveDelTesto(cards[i].domain)),
                              onScritto: () => _testiScritti
                                  .add(_chiaveDelTesto(cards[i].domain)),
                              onDepthSelected: (depth) =>
                                  _scegliProfondita(cards[i].domain, depth),
                              onDepthLocked: (depth) =>
                                  _showDepthLocked(cards[i].domain, depth),
                              livello: cielo.livello,
                              premiumUnlocked: PlanCatalog.haProfondita(
                                  context.watch<EntitlementService>().tier),
                            ),
                            const SizedBox(height: SpacingTokens.md),
                          ],
                      // **I TRE CIELI DI OGGI, ordine ES voce 36**: sotto le
                      // schede, dominio per dominio, se le tre tradizioni
                      // sono d'accordo e, se non lo sono, chi vede cosa.
                      if (consulto &&
                          _fase == _FaseDelConsulto.responso &&
                          _treCieli.isNotEmpty) ...[
                        _ITreCieliView(
                            accordi: _treCieli,
                            sigillo: _sigilloDeiTreCieli,
                            palette: palette),
                        const SizedBox(height: SpacingTokens.md),
                      ],
                      // LA NOTA CHE DICHIARA IL RIPIEGO, quando il cielo non c'e'.
                      //
                      // Una riga generica scritta con lo stesso carattere di una
                      // vera si legge come vera: qui si dice a parole che senza
                      // ora e luogo di nascita quella lettura parla al segno, non
                      // al cielo di questa persona, e si dice come rimediare.
                      if (consulto && !altra && notaDelCielo != null) ...[
                        _NotaDelCielo(
                            testo: notaDelCielo,
                            palette: palette,
                            completa: cielo.ceCieloVero,
                            invito: CorrenteDelCielo.invitoDelLivello(cielo)),
                        const SizedBox(height: SpacingTokens.md),
                      ],
                      // SI PORTA CON SE' SOLO CIO' CHE SI E' LETTO. Prima del
                      // consulto la schermata offriva di condividere un oroscopo
                      // che nessuno aveva ancora chiesto, e la card che ne usciva
                      // portava testi mai comparsi a video: e' lo stesso difetto
                      // che il gesto Interroga il cielo esiste per togliere.
                      if (consulto && _fase == _FaseDelConsulto.responso)
                        _ShareBlock(
                          palette: palette,
                          sharing: _sharing,
                          onShare: _onShare,
                          segno: _segnoCondiviso,
                          // **IL TESTO CHE SI CUSTODISCE E' QUELLO CHE SI E'
                          // LETTO**, cioe' le schede del cielo di oggi in fila:
                          // custodire un testo diverso da quello a video sarebbe
                          // riaprire domani un responso che non e' mai comparso.
                          testoDelResponso: cards
                              .map((c) => '${c.title}\n${c.text}')
                              .join('\n\n'),
                        ),
                      // LA RAGIONE PER TORNARE DOMANI, ordine ES voce 34: in
                      // fondo, calcolata, dove sara' la Luna domani.
                      if (consulto && _fase == _FaseDelConsulto.responso)
                        Padding(
                          padding: const EdgeInsets.only(top: SpacingTokens.md),
                          child: Row(
                            key: const Key('oroscopo_domani'),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.nightlight_round,
                                  size: 16, color: palette.goldSoft),
                              const SizedBox(width: SpacingTokens.sm),
                              Expanded(
                                child: Text(
                                  // Nella lettura cinese, l'almanacco di
                                  // domani.
                                  (cinese
                                          ? LaLetturaCinese.domani(
                                              _date, animale!)
                                          : vedica
                                              ? LaLetturaVedica.domani(_date,
                                                  nascitaDeiSegni!, _luogo)
                                              : null) ??
                                      IlDomani.riga(
                                          widget.userSign,
                                          context
                                              .watch<BirthIdentityController>()
                                              .cartaCompleta,
                                          _date),
                                  style: TypographyTokens.didascalia().copyWith(
                                      color: palette.goldSoft, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      // IL DISCLAIMER E' USCITO DA QUI, ed era uno di SETTE.
                      //
                      // Le linee guida dicevano da sempre "una volta sola", e per
                      // sette volte ognuno ha pensato che il proprio fosse quella
                      // volta. Un disclaimer ripetuto smette di essere letto e
                      // diventa un modo di scaricare la responsabilita' invece di
                      // dirla. Adesso sta in un posto solo, nell'area privacy.
                    ],
                  ),
                  if (_renderCard)
                    Positioned(
                      left: -3000,
                      top: 0,
                      child: RepaintBoundary(
                        key: _cardKey,
                        child: OroscopoShareCard(
                          sign: widget.userSign,
                          // Nel Giorno le schede del consulto; negli altri
                          // periodi le loro tessere (ordine ES voce 05).
                          cards: _period == HoroscopePeriod.giorno
                              ? cards
                              : (_schedeDelPeriodo ?? cards),
                          titoloDelleTessere:
                              _period == HoroscopePeriod.settimana ||
                                      _period == HoroscopePeriod.mese
                                  ? 'Il giorno migliore di ogni campo'
                                  : null,
                          palette: palette,
                          // Il segno della lettura cinese, ordine ES voce 08.
                          nomeDelSegno:
                              schedeAltre != null ? segnoInCima!.nome : null,
                          figuraDelSegno: schedeAltre != null
                              ? LaTestaDellaTradizione.figura(
                                  _inCima, segnoInCima)
                              : null,
                          // Ordine ES voci 05 e 13: l'emblema del periodo,
                          // il nome senza cognome e i dati di nascita.
                          periodo: _period.name,
                          etichettaDelPeriodo: _period.etichetta,
                          nome: OroscopoShareCard.soloIlNome(
                              profile.profile.displayName),
                          nascita: profile.identity.isExample
                              ? null
                              : OroscopoShareCard.laNascitaScritta(
                                  profile.identity.birthDate,
                                  ora: profile.identity.hasBirthTime
                                      ? profile.identity.birthMoment.hour
                                      : null,
                                  minuto: profile.identity.birthMoment.minute,
                                  luogo: profile.identity.birthPlace?.city),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        // **LA CORSA DELLO ZODIACO STA SOPRA TUTTO. Ordine CC voce 03.**
        //
        // Parole del fondatore: "VOGLIO che ci sia una schermata nuova sopra
        // tutto con tutti i simboli dello zodiaco grandi che velocemente si
        // succedono uno dopo l'altro e poi si ferma sul segno zodiacale
        // dell'utente".
        //
        // **Sta FUORI dallo Scaffold, e me l'ha insegnato l'anteprima.** Prima
        // stava dentro il corpo, e restavano scoperte la freccia Indietro e il
        // cuore della barra: una schermata nuova che lascia visibili i comandi
        // di quella vecchia non e' una schermata nuova. Prima ancora stava
        // dentro la colonna dell'eroe, dove un `Positioned.fill` non ha
        // significato e Flutter lo dice con un errore.
        //
        // **Restano fuori le due barre sottili dell'app**, e lo dichiaro:
        // quelle vivono sopra il Navigator, cioe' sopra ogni rotta, e per
        // coprirle bisognerebbe portare questa scena fuori dalla schermata che
        // la possiede, cioe' aprire una seconda porta sullo stesso momento.
        if (_corsaInScena)
          CorsaDelloZodiaco(
            key: const Key('corsa_dello_zodiaco'),
            // Nella Vedica si ferma sul segno lunare di nascita (ES.09).
            segno: schedeVediche != null && rashi != null
                ? Zodiac.values[rashi]
                : _segnoDiChiGuarda,
            palette: palette,
            // Nella lettura cinese corrono i dodici animali (ES.08).
            animaleCinese: schedeCinesi != null ? animale : null,
            // Nella Vedica il segno lunare di nascita, col suo nome (ES.09).
            nomeFinale: schedeVediche != null && rashi != null
                ? ISegniDelleTradizioni.rashi[rashi]
                : null,
            figuraFinale: schedeVediche != null
                ? LaTestaDellaTradizione.figura(_inCima, segnoInCima)
                : null,
            frase: schedeCinesi != null
                ? 'Medora sta aprendo l\'almanacco di oggi'
                : schedeVediche != null
                    ? 'Medora sta cercando la Luna fra le stelle'
                    : null,
            durata:
                RiflessioneDelCielo.momento(piena: _pienaQuestoConsulto) * 2 +
                    _dissolvenzaDellaCorsa,
            riduciMovimento: MediaQuery.of(context).disableAnimations,
          ),
      ],
    );
  }

  void _showDepthLocked(HoroscopeDomain domain, AnswerDepth depth) {
    // LA BOLLA DEL MAESTRO, non una SnackBar di sistema, ordine L voce 1c:
    // l'avviso col fondo bianco e' sparito, e al tocco sul lucchetto sale
    // dal basso l'invito gia' esistente, nel blu di Medora.
    showUpgradeInvite(
      context,
      title: 'La profondità ${depth.label} è del Cerchio Premium',
      message: 'Col piano superiore scegli quanto approfondire ogni scheda, '
          '${domain.label} compresa: la lettura ti segue in profondità.',
    );
  }

  void _selectPeriod(HoroscopePeriod period) {
    final tier = context.read<EntitlementService>().tier;
    if (period.apertoPer(tier)) {
      setState(() => _period = period);
      return;
    }
    // **IL PIANO SI CHIAMA COL SUO NOME, ordine ES voce 06**, non "Cerchio
    // Premium": chi non ha il piano sa quale gli serve.
    final piano = PlanCatalog.forTier(Tier.values[period.livelloMinimo]).name;
    showUpgradeInvite(
      context,
      title: 'L\'oroscopo della ${period.label.toLowerCase()} si apre '
          '${conPiano(piano)}',
      message: 'Leggi anche la ${period.label.toLowerCase()}, oltre il '
          'giorno: i fatti del cielo, il giorno migliore e il momento chiave '
          'di ogni campo.',
    );
  }

  /// La tradizione: se e' aperta si sceglie, se e' chiusa risponde il Maestro.
  ///
  /// Al posto del solito lucchetto muto compare un micro messaggio di Medora in
  /// prima persona, che racconta cosa sara' quella tradizione. La prima volta
  /// entra in dissolvenza, poi resta posato: e' la rivelazione una volta sola.
  void _selectTradition(AstroTradition tradition) {
    if (tradition.unlocked) {
      setState(() {
        if (tradition != _inCima) _consultoDi(tradition);
        _tradition = tradition;
        _traditionMessage = null;
        _inCima = tradition;
      });
      // **LA RIVELAZIONE DEL SEGNO, ordine ES voce 35**: la prima volta che
      // si sceglie la Cinese o la Vedica, dopo il frame della scelta.
      if (LaRivelazioneDelSegno.tradizioni.contains(tradition)) {
        final nascita = NascitaDeiSegni.daiDati(
            context.read<BirthIdentityController>().details,
            context.read<ProfileController>().identity);
        final palette =
            MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          unawaited(LaRivelazioneDelSegno.forseMostra(
            context,
            tradizione: tradition,
            segno: nascita == null
                ? null
                : ISegniDelleTradizioni.per(tradition, nascita),
            palette: palette,
          ));
        });
      }
      return;
    }
    setState(() {
      if (tradition != _inCima) _consultoDi(tradition);
      _traditionMessage = tradition;
      _inCima = tradition;
    });
    // Segna la rivelazione dopo il frame in cui l'animazione e' partita.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _traditionRevealed.add(tradition);
    });
  }

  /// **IL CONSULTO DI UN'ALTRA TRADIZIONE**, ordine ES voce 08. Si chiama
  /// dentro il setState di chi cambia tradizione: la scena della corsa e la
  /// cascata di quella di prima si fermano, e la nuova riparte dal gesto,
  /// oppure scritta se in questa apertura e' gia' stata letta.
  void _consultoDi(AstroTradition nuova) {
    _cascata?.cancel();
    _fineDellaCorsa?.cancel();
    _corsaInScena = false;
    if (_consultate.contains(nuova)) {
      _fase = _FaseDelConsulto.responso;
      _turnoDiScrittura = _quanteSchede - 1;
    } else {
      _fase = _FaseDelConsulto.attesa;
      _turnoDiScrittura = -1;
    }
  }

  /// **L'INVITO ALLA LETTURA DI UNA TRADIZIONE**, ordine ES voce 06: chi e'
  /// sul piano gratuito vede il suo segno cinese, e il piano che apre la
  /// lettura si chiama col suo nome.
  void _invitaAllaLettura(AstroTradition tradizione) {
    final piano =
        PlanCatalog.forTier(Tier.values[tradizione.livelloDellaLettura]).name;
    showUpgradeInvite(
      context,
      title: 'La lettura ${tradizione.label.toLowerCase()} del giorno si apre '
          '${conPiano(piano)}',
      message: tradizione == AstroTradition.cinese
          ? 'Ogni giorno le quattro schede dall\'almanacco cinese: il '
              'rapporto fra l\'animale del giorno e il tuo, il guardiano del '
              'giorno, i Dieci Dei del BaZi per amore, lavoro e fortuna.'
          : 'Ogni giorno le quattro schede dalla Luna siderale: la Chandra '
              'Bala e la Tara Bala, il Rahu Kalam della tua città, le case '
              'dell\'amore, del lavoro e della fortuna.',
    );
  }

  /// **TORNA L\'ESITO invece di ingoiarlo, ordine CG voce 06.** Il vero che
  /// esce di qui e\' quello su cui scatta la custodia automatica.
  Future<bool> _onShare() async {
    setState(() {
      _sharing = true;
      _renderCard = true;
    });
    try {
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final andata = await shareOroscopoCard(
        boundaryKey: _cardKey,
        text: _period == HoroscopePeriod.giorno
            ? 'Il mio oroscopo di oggi, $_segnoCondiviso. Esoteric Circle.'
            : 'Il mio oroscopo ${_period.etichetta}, $_segnoCondiviso. '
                'Esoteric Circle.',
      );
      if (andata && mounted) {
        // Ordine BG voce 04: il premio dichiarato sul pulsante si paga qui,
        // a condivisione davvero avvenuta.
        await PremioDellaCondivisione.premia(context,
            cosa: 'Hai condiviso il tuo oroscopo');
      }
      return andata;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Non riesco a preparare la card ora.')),
        );
      }
      // **UN ERRORE NON \' UNA CONDIVISIONE AVVENUTA**, quindi non custodisce
      // niente: e\' la stessa regola del foglio aperto e poi chiuso.
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _sharing = false;
          _renderCard = false;
        });
      }
    }
  }
}

/// Lo stile del responso, in un punto solo.
///
/// Serve a due cose che devono restare d'accordo: dipingere il testo e MISURARE
/// quante righe occupa. Se lo stile vivesse in due posti, la divisione in
/// blocchi si calcolerebbe su un carattere e la resa userebbe l'altro, e la
/// regola delle righe direbbe il falso senza che nessuno se ne accorga.
final TextStyle stileDelResponso =
    TypographyTokens.lettura().copyWith(color: ColorTokens.textPrimary);

/// L'eroe: l'emblema 3D del segno della persona, grande, dentro un alone che
/// respira. Nessun altro segno, l'oroscopo e' personalizzato.
/// IL RESPONSO CHE SI SCRIVE, e che un tocco completa.
///
/// Ordine 2171, voce 5. Il testo si compone a macchina da scrivere, con la
/// velocita' dichiarata dalla schermata. Con Riduci Movimento compare intero:
/// l'informazione non dipende dal moto.
///
/// Ordine A. Il responso non e' piu' un muro: si legge nel ruolo [lettura],
/// diciotto punti con interlinea larga, spezzato in paragrafi da tre o quattro
/// righe, distanti fra loro il DOPPIO della misura del testo. I paragrafi si
/// scrivono in fila, uno dopo l'altro, non tutti insieme: la macchina da
/// scrivere sarebbe diventata quattro macchine che battono in coro.
class _ResponsoCheSiScrive extends StatefulWidget {
  const _ResponsoCheSiScrive({
    super.key,
    required this.testo,
    required this.durataScrittura,
    required this.scrivendo,
    required this.giaScritto,
    required this.onScritto,
  });

  final String testo;
  final Duration durataScrittura;
  final bool scrivendo;

  /// Se questo testo e' gia' stato scritto: si mostra intero e fermo. Lo
  /// dice la schermata, che tiene il registro accanto alla risposta: tenerlo
  /// qui dentro non basta, perche' la lista smonta e rimonta. Gancio vivo,
  /// letto a ogni build.
  final bool Function() giaScritto;

  /// La dichiarazione di fine scrittura, verso il registro della schermata.
  final VoidCallback onScritto;

  @override
  State<_ResponsoCheSiScrive> createState() => _ResponsoCheSiScriveState();
}

class _ResponsoCheSiScriveState extends State<_ResponsoCheSiScrive> {
  late List<String> _paragrafi =
      spezzaInParagrafi(widget.testo, stile: stileDelResponso);
  late List<GlobalKey<TestoCheSiScriveState>> _chiavi = _nuoveChiavi();
  int _inScrittura = 0;
  Timer? _passaggio;

  List<GlobalKey<TestoCheSiScriveState>> _nuoveChiavi() => List.generate(
      _paragrafi.length, (_) => GlobalKey<TestoCheSiScriveState>());

  /// Il termine della scrittura, dichiarato al registro. Parte quando la
  /// scrittura comincia, per l'intero budget dichiarato: le fette dei
  /// paragrafi sommano esattamente a quel budget, quindi allo scadere il
  /// testo e' intero. Il tocco che completa dichiara subito.
  Timer? _fine;

  void _armaLaFine() {
    _fine?.cancel();
    _fine =
        Timer(widget.durataScrittura + const Duration(milliseconds: 50), () {
      if (mounted) widget.onScritto();
    });
  }

  @override
  void didUpdateWidget(_ResponsoCheSiScrive vecchio) {
    super.didUpdateWidget(vecchio);
    if (vecchio.testo != widget.testo) {
      _passaggio?.cancel();
      // **IL TIMER TORNA NULLO, ordine I voce 2.** Cancellarlo non basta: la
      // build riarma il passaggio solo quando `_passaggio == null`, e un
      // timer cancellato ma ancora in mano teneva il turno fermo al primo
      // paragrafo per sempre. Era la causa della scheda Profonda vista da
      // Mauro: testo cancellato, un paragrafo solo, il vuoto sotto.
      _passaggio = null;
      _paragrafi = spezzaInParagrafi(widget.testo, stile: stileDelResponso);
      _chiavi = _nuoveChiavi();
      _inScrittura = 0;
      // Il testo nuovo e' un responso nuovo: anche il tocco che aveva
      // completato il vecchio non vale piu', e la fine si riarma.
      _completato = false;
      _fine?.cancel();
      _fine = null;
    }
  }

  @override
  void dispose() {
    _passaggio?.cancel();
    _fine?.cancel();
    super.dispose();
  }

  /// La fetta di tempo del paragrafo che sta scrivendo, in proporzione alla sua
  /// lunghezza: cosi' il responso intero resta dentro il budget dichiarato dalla
  /// schermata, comunque lo si spezzi.
  Duration _durataDi(int indice) {
    final totale = _paragrafi.fold<int>(0, (s, p) => s + p.length);
    if (totale == 0) return Duration.zero;
    return widget.durataScrittura * (_paragrafi[indice].length / totale);
  }

  void _programmaIlPassaggio() {
    if (_inScrittura >= _paragrafi.length - 1) return;
    _passaggio?.cancel();
    _passaggio = Timer(_durataDi(_inScrittura), () {
      if (!mounted) return;
      setState(() => _inScrittura++);
      _programmaIlPassaggio();
    });
  }

  /// Il tocco completa TUTTO il responso, non il solo paragrafo in corso: chi
  /// tocca vuole leggere adesso, e lasciargli tre paragrafi ancora da aspettare
  /// sarebbe la stessa gabbia con tre porte.
  void _completaTutto() {
    _passaggio?.cancel();
    // PRIMA si spegne la scrittura, POI si completa. Al contrario non
    // funzionava, ed e' un difetto che la prova ha preso: portando il turno
    // all'ultimo paragrafo, quello passava da fermo a attivo e RIPARTIVA da
    // zero, quindi il tocco che doveva chiudere il responso ne riapriva un
    // pezzo.
    if (!_completato) setState(() => _completato = true);
    for (final chiave in _chiavi) {
      chiave.currentState?.completa();
    }
    // Chi completa col tocco ha il testo intero adesso: si dichiara subito.
    _fine?.cancel();
    widget.onScritto();
  }

  /// Vero dal tocco in poi: nessun paragrafo batte piu' e tutti si vedono.
  bool _completato = false;

  @override
  Widget build(BuildContext context) {
    // Un testo GIA' SCRITTO non si riscrive: nasce intero e fermo, anche se
    // questo State e' appena rinato dopo uno scorrimento.
    final attiva = widget.scrivendo &&
        !widget.giaScritto() &&
        !_completato &&
        !MediaQuery.of(context).disableAnimations;
    final stile = stileDelResponso;

    if (attiva && _fine == null) {
      _armaLaFine();
    }
    // Il doppio della misura del testo, presa dallo stile e non riscritta a
    // mano: se domani il ruolo cambia misura, la distanza lo segue.
    final distanza = (stile.fontSize ?? TypographyTokens.pavimento) * 2;

    if (attiva && _passaggio == null && _paragrafi.length > 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _passaggio == null) _programmaIlPassaggio();
      });
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _completaTutto,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // L'ALTEZZA SEGUE IL TESTO CHE C'E' DAVVERO, ordine I voce 2b. I
          // paragrafi non ancora scritti stavano in albero trasparenti per
          // riservare il posto: quel posto era il vuoto sotto la scheda, e il
          // ramo e' stato tolto. Mentre si scrive la scheda cresce paragrafo
          // dopo paragrafo, e a scrittura finita non c'e' nessuna riserva.
          for (var i = 0; i < _paragrafi.length; i++)
            if (!attiva || i <= _inScrittura) ...[
              if (i > 0) SizedBox(height: distanza),
              TestoCheSiScrive(
                key: _chiavi[i],
                testo: _paragrafi[i],
                stile: stile,
                durataMassima: _durataDi(i),
                attiva: attiva && i == _inScrittura,
              ),
            ],
        ],
      ),
    );
  }
}

/// **LA LETTURA DI QUESTA TRADIZIONE E' IN ARRIVO, ordine ES voce 11.**
///
/// Sotto il segno di una tradizione non ancora aperta: una riga che dice
/// che la lettura non c'e' ancora, e il gesto per tornare all'oroscopo che
/// c'e'.
class _LaLetturaEInArrivo extends StatelessWidget {
  const _LaLetturaEInArrivo({
    required this.tradizione,
    required this.palette,
    required this.onTorna,
    this.testo,
    this.etichetta = 'Torna al tuo oroscopo',
    this.chiave,
    this.chiaveDelGesto = const Key('oroscopo_torna_al_tuo_oroscopo'),
  });

  final AstroTradition tradizione;
  final MaestroPalette palette;
  final VoidCallback onTorna;

  /// Il testo dell'avviso, quando non e' la lettura in arrivo: la settimana
  /// cinese, l'invito al piano (ordine ES voce 08).
  final String? testo;
  final String etichetta;
  final Key? chiave;
  final Key chiaveDelGesto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: chiave ?? Key('oroscopo_lettura_in_arrivo_${tradizione.name}'),
      padding: const EdgeInsets.only(top: SpacingTokens.md),
      child: Column(
        children: [
          Text(
            testo ??
                'La lettura della tradizione ${tradizione.label} è in arrivo: '
                    'qui vedi già il tuo segno.',
            textAlign: TextAlign.center,
            style: TypographyTokens.didascalia()
                .copyWith(color: ColorTokens.textSecondary, height: 1.4),
          ),
          const SizedBox(height: SpacingTokens.sm),
          OutlinedButton(
            key: chiaveDelGesto,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 44),
              side: BorderSide(color: palette.gold.withValues(alpha: 0.6)),
            ),
            onPressed: onTorna,
            // Nel carattere del corpo, non in quello delle etichette: il
            // maiuscoletto che va a capo diventa un muro di lettere
            // (etichette_e_lettura, padre ES.11).
            child: Text(etichetta,
                textAlign: TextAlign.center,
                style:
                    TypographyTokens.corpo().copyWith(color: palette.goldSoft)),
          ),
        ],
      ),
    );
  }
}

/// **L'INVITO A COMPLETARE ORA E LUOGO DI NASCITA, ordine ES voce 31.**
///
/// Una riga sola, discreta, che porta alla schermata dei dati di nascita.
/// Quando i dati ci sono non c'e'.
class _InvitoAllaNascita extends StatelessWidget {
  const _InvitoAllaNascita(
      {required this.testo, required this.palette, this.alRitorno});

  final String testo;
  final MaestroPalette palette;

  /// Chiamato al ritorno dai dati di nascita: la citta' di oggi si sceglie
  /// li', e la lettura vedica la rilegge (ordine ES voce 09).
  final Future<void> Function()? alRitorno;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Anche sotto: dopo il consulto l'invito sta sopra la prima scheda, e
      // senza spazio la toccava (visto nell'anteprima del 30 settembre 2026).
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('oroscopo_invito_nascita'),
          // L'interruttore del silenzio del Cerchio: niente click di sistema.
          enableFeedback: false,
          borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
          onTap: () => Navigator.of(context)
              .push(DatiDiNascitaScreen.route())
              .then((_) => alRitorno?.call()),
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
              border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule_rounded, size: 18, color: palette.goldSoft),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Text(testo,
                      style: TypographyTokens.didascalia().copyWith(
                          color: ColorTokens.textPrimary, height: 1.35)),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: 20, color: palette.goldSoft),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// IL GESTO CHE APRE IL CONSULTO.
///
/// Ordine 2171, voce 5. Prima la schermata si apriva con l'oroscopo gia'
/// scritto: sembrava uscito da una macchina, senza studio ne' interpretazione.
/// Un consulto comincia quando qualcuno lo chiede.
class _InterrogaIlCielo extends StatelessWidget {
  const _InterrogaIlCielo(
      {required this.palette,
      required this.onTap,
      this.etichetta = 'Interroga il cielo'});

  /// "Apri l'almanacco" nella lettura cinese, ordine ES voce 08.
  final String etichetta;

  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          enableFeedback: false,
          key: const Key('oroscopo_interroga'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.lg, vertical: SpacingTokens.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
              gradient: LinearGradient(colors: [
                palette.primary.withValues(alpha: 0.85),
                palette.surfaceElevated.withValues(alpha: 0.85),
              ]),
              border: Border.all(color: palette.gold.withValues(alpha: 0.7)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 18, color: palette.goldSoft),
                const SizedBox(width: SpacingTokens.sm),
                // **IL TESTO DEVE POTER CEDERE.** Ordine CM voce 09, famiglia A.
                Flexible(
                    child: Text(etichetta,
                        style: TypographyTokens.titoloScheda()
                            .copyWith(color: palette.goldSoft))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.sign,
    required this.palette,
    required this.pulse,
    this.interrogazione = false,
    this.corona = false,
    required this.adesso,
    this.durataDelMomento = RiflessioneDelCielo.momentoPieno,
  });

  final Zodiac sign;
  final MaestroPalette palette;
  final Animation<double> pulse;

  /// Se attorno all'emblema si raccolgono i corpi veri del giorno. Ordine BK
  /// voce 03, primo momento.
  final bool corona;

  /// Il giorno da cui vengono le posizioni dei corpi: lo stesso della
  /// schermata, quindi la corona mostra il cielo del responso e non quello
  /// dell'istante in cui si guarda.
  final DateTime adesso;

  /// Quanto dura il momento, cosi' i corpi finiscono di raccogliersi quando il
  /// momento finisce, sia nella riflessione piena sia in quella breve.
  final Duration durataDelMomento;

  /// Vero mentre il cielo si interroga: l'alone si accende di piu', perche' si
  /// capisca che c'e' un'elaborazione in corso e non un'attesa vuota.
  ///
  /// Con Riduci Movimento il respiro non c'e', ma il bagliore resta acceso e
  /// fermo: chi ha tolto le animazioni deve vedere lo stesso che sta
  /// succedendo qualcosa.
  final bool interrogazione;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 268,
      child: AnimatedBuilder(
        animation: pulse,
        builder: (context, _) {
          final riduciMovimento = MediaQuery.of(context).disableAnimations;
          final respiro = 0.5 + 0.5 * (1 - (pulse.value - 0.5).abs() * 2);
          // Mentre si interroga il cielo il respiro si fa piu' ampio; fermo,
          // ma acceso, quando le animazioni sono spente.
          final breathe = interrogazione
              ? (riduciMovimento ? 1.0 : 0.6 + 0.4 * respiro)
              : respiro;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                key: interrogazione
                    ? const Key('oroscopo_emblema_pulsa')
                    : const Key('oroscopo_emblema'),
                width: 250 + (interrogazione ? 44 : 28) * breathe,
                height: 250 + (interrogazione ? 44 : 28) * breathe,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    palette.gold.withValues(alpha: 0.12 + 0.16 * breathe),
                    palette.glow.withValues(alpha: 0.08 * breathe),
                    Colors.transparent,
                  ], stops: const [
                    0.0,
                    0.55,
                    1.0
                  ]),
                ),
              ),
              ZodiacEmblem(
                  key: const Key('oroscopo_emblem'),
                  sign: sign,
                  size: 264,
                  art: ZodiacEmblemArt.emblem),
              if (corona)
                CoronaDeiCorpi(
                  key: const Key('oroscopo_corona_dei_corpi'),
                  adesso: adesso,
                  palette: palette,
                  raggio: 122,
                  durata: durataDelMomento,
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Intestazione: nome del segno, titolo e data locale.
class _Heading extends StatelessWidget {
  const _Heading(
      {required this.periodo,
      required this.date,
      required this.palette,
      this.anno});

  final HoroscopePeriod periodo;
  final DateTime date;
  final MaestroPalette palette;

  /// Il ritorno del Sole in corso e il prossimo: le date dell'Anno.
  final (DateTime, DateTime)? anno;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(periodo.sottotitoloAVideo,
            key: const Key('oroscopo_heading'),
            textAlign: TextAlign.center,
            style: TypographyTokens.etichetta().copyWith(
                color: ColorTokens.textSecondary, letterSpacing: 1.2)),
        // **LA SETTIMANA E IL MESE DICONO IL LORO INTERVALLO**, visto sul
        // Realme: "29 settembre 2026" sopra una settimana si legge come il
        // giorno solo.
        Text(
            switch (periodo) {
              HoroscopePeriod.giorno => italianLongDate(date),
              HoroscopePeriod.settimana => 'dal ${date.day} '
                  '${_mesiItaliani[date.month - 1]} al '
                  '${italianLongDate(DateTime(date.year, date.month, date.day + 6))}',
              HoroscopePeriod.mese => 'dal ${date.day} '
                  '${_mesiItaliani[date.month - 1]} al '
                  '${italianLongDate(DateTime(date.year, date.month, date.day + 29))}',
              // L'anno va da un compleanno solare all'altro: con l'ora di
              // nascita le date vere (ordine EU voce 04: "sotto la data o
              // date corrispondenti"), senza la frase che lo dice.
              HoroscopePeriod.anno => anno == null
                  ? 'dal tuo compleanno al prossimo'
                  : 'dal ${anno!.$1.day} ${_mesiItaliani[anno!.$1.month - 1]} '
                      '${anno!.$1.year} al ${italianLongDate(anno!.$2)}',
            },
            key: const Key('oroscopo_date'),
            textAlign: TextAlign.center,
            style: TypographyTokens.didascalia()
                .copyWith(color: ColorTokens.textSecondary)),
      ],
    );
  }
}

/// Il selettore del periodo: Giorno attivo, Settimana e Mese visibili ma
/// bloccati col lucchetto e l'invito all'abbonamento.
class _PeriodTabs extends StatelessWidget {
  const _PeriodTabs(
      {required this.current,
      required this.palette,
      required this.onSelect,
      required this.tier});

  final HoroscopePeriod current;
  final MaestroPalette palette;
  final ValueChanged<HoroscopePeriod> onSelect;

  /// Il piano di chi guarda: decide quali periodi portano il lucchetto.
  final Tier tier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        color: palette.surfaceElevated.withValues(alpha: 0.45),
        border: Border.all(color: palette.gold.withValues(alpha: 0.25)),
      ),
      // **OGNI PERIODO LARGO QUANTO IL SUO NOME.** Visto sul Realme il 30
      // settembre 2026: con l'Anno i periodi sono quattro, e in quattro parti
      // uguali "Settimana" andava a capo sull'ultima lettera ("SETTIMAN / A").
      // Padre: ordine ES voce 04. Ogni voce prende la larghezza del suo nome
      // (col lucchetto, quando c'e') e lo spazio che avanza si divide in parti
      // uguali; se i nomi non ci stanno, per esempio col carattere ingrandito,
      // la riga intera si rimpicciolisce insieme, cosi' i quattro nomi restano
      // alla stessa misura.
      child: LayoutBuilder(builder: (context, vincoli) {
        final scala = MediaQuery.textScalerOf(context);
        final larghezze = <HoroscopePeriod, double>{
          for (final p in HoroscopePeriod.values)
            p: _PeriodTab.larghezzaNaturale(p,
                locked: !p.apertoPer(tier), scala: scala),
        };
        final naturale = larghezze.values.fold<double>(0, (a, b) => a + b);
        final avanza = vincoli.maxWidth - naturale;
        // Mezzo punto di gioco: le quattro larghezze sommate non devono
        // superare la riga per un arrotondamento.
        final inPiu =
            avanza > 0.5 ? (avanza - 0.5) / HoroscopePeriod.values.length : 0.0;
        final riga = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final period in HoroscopePeriod.values)
              SizedBox(
                width: larghezze[period]! + inPiu,
                child: _PeriodTab(
                  period: period,
                  locked: !period.apertoPer(tier),
                  selected: period == current,
                  palette: palette,
                  onTap: () => onSelect(period),
                ),
              ),
          ],
        );
        if (avanza >= 0) return riga;
        return FittedBox(fit: BoxFit.scaleDown, child: riga);
      }),
    );
  }
}

/// Il selettore della tradizione: Occidentale aperta, le altre col lucchetto.
///
/// Le astrologie non occidentali non hanno una card nel dominio ne' una
/// schermata propria: vivono qui, come modo diverso di leggere lo stesso cielo.
/// Ogni voce porta il suo glifo disegnato, cosi' si riconosce prima di leggerla.
class _TraditionTabs extends StatefulWidget {
  const _TraditionTabs(
      {super.key,
      required this.current,
      required this.palette,
      required this.onSelect});

  final AstroTradition current;
  final MaestroPalette palette;
  final ValueChanged<AstroTradition> onSelect;

  @override
  State<_TraditionTabs> createState() => _TraditionTabsState();
}

class _TraditionTabsState extends State<_TraditionTabs> {
  final Map<AstroTradition, GlobalKey> _chiavi = {
    for (final t in AstroTradition.values) t: GlobalKey(),
  };

  /// **LA TRADIZIONE SCELTA SI VEDE NELLA RIGA.** Visto sul Realme il 30
  /// settembre 2026: tornando dall'Araba con "Torna al tuo oroscopo" la
  /// scelta passava all'Occidentale, ma la riga restava scorsa in fondo, su
  /// Maya, Celtica ed Egizia, e la voce accesa non si vedeva. Padre: ordine
  /// ES voce 11. Quando la scelta cambia, la riga scorre fino a mostrarla.
  @override
  void initState() {
    super.initState();
    // Una riga appena nata parte dall'inizio: se la scelta sta piu' in la',
    // la si va a prendere.
    if (widget.current != AstroTradition.values.first) _mostraLaScelta();
  }

  @override
  void didUpdateWidget(covariant _TraditionTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.current == widget.current) return;
    _mostraLaScelta();
  }

  void _mostraLaScelta() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contesto = _chiavi[widget.current]?.currentContext;
      if (contesto == null || !mounted) return;
      // Solo la riga delle tradizioni: `Scrollable.ensureVisible` muoverebbe
      // anche la pagina, che deve restare dov'e'.
      final posizione = Scrollable.maybeOf(contesto)?.position;
      final oggetto = contesto.findRenderObject();
      if (posizione == null || oggetto == null) return;
      unawaited(posizione.ensureVisible(
        oggetto,
        alignment: 0.5,
        duration: MediaQuery.of(context).disableAnimations
            ? Duration.zero
            : const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.current;
    final palette = widget.palette;
    final onSelect = widget.onSelect;
    return SizedBox(
      key: const Key('oroscopo_tradition_tabs'),
      // Alta quanto serve al glifo, al nome e al badge "In arrivo", che sulla
      // voce bloccata sta su una terza riga.
      //
      // **OTTANTASEI E NON PIU' OTTANTA. Ordine CQ voce 2.11**, 3 settembre
      // 2026: le etichette sono salite da dodici a quattordici punti e questa
      // pastiglia traboccava di UN pixel. Sei punti invece di due perche' la
      // stessa pastiglia era gia' fra i rossi accettati a scala 1,3, dove
      // sforava di cinque: alzarla del minimo avrebbe curato la scala 1 e
      // lasciato rossa la 1,3, cioe' meta' del difetto.
      //
      // **E CRESCE COL CARATTERE, ordine ES voce 11.** Le voci in arrivo
      // hanno tre righe (il glifo, il nome con la clessidra, "In arrivo, Fase
      // 4"), e a scala 1,3 sforavano di cinque punti: non si vedeva nelle
      // prove perche' la riga costruiva solo le voci in vista, e le tre in
      // vista ne hanno due. Adesso le costruisce tutte, e l'altezza segue la
      // scala del testo.
      height: 86 + 56 * (MediaQuery.textScalerOf(context).scale(14) / 14 - 1),
      // Sette voci: si costruiscono tutte, cosi' la riga puo' scorrere fino a
      // quella scelta anche quando sta fuori dallo schermo.
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final t in AstroTradition.values) ...[
              if (t != AstroTradition.values.first)
                const SizedBox(width: SpacingTokens.xs),
              KeyedSubtree(
                key: _chiavi[t],
                child: _TraditionChip(
                  tradition: t,
                  selected: t == current,
                  palette: palette,
                  onTap: () => onSelect(t),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TraditionChip extends StatelessWidget {
  const _TraditionChip({
    required this.tradition,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  final AstroTradition tradition;
  final bool selected;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locked = !tradition.unlocked;
    // Alla persona si dice soltanto "In arrivo": la fase e' un dato di piano e
    // resta nella sola vista Demo per gli investitori.
    final fase = AppFlags.isDemo && tradition.phase != null
        ? ', ${tradition.phase}'
        : '';
    return GestureDetector(
      key: Key('oroscopo_tradition_${tradition.name}'),
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        // Il chip acceso porta il suo segno: la prova lo cerca (ordine ES).
        key: selected ? const Key('oroscopo_tradition_accesa') : null,
        padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.sm, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
          // L'accento del Maestro solo su quella scelta e viva: le altre
          // restano su una superficie sobria, comunque ben leggibile.
          gradient: selected
              ? LinearGradient(colors: [
                  palette.primary.withValues(alpha: 0.85),
                  palette.surfaceElevated.withValues(alpha: 0.85),
                ])
              : null,
          color:
              selected ? null : palette.surfaceElevated.withValues(alpha: 0.35),
          border: Border.all(
            color: palette.gold.withValues(alpha: selected ? 0.6 : 0.25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TraditionGlyph(
              tradition: tradition,
              color: palette.goldSoft.withValues(alpha: locked ? 0.7 : 1.0),
              size: 22,
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tradition.label,
                  style: TypographyTokens.etichetta().copyWith(
                    color: selected
                        ? palette.goldSoft
                        : ColorTokens.textSecondary
                            .withValues(alpha: locked ? 0.75 : 1.0),
                    letterSpacing: 0.5,
                  ),
                ),
                // **LA CLESSIDRA, NON IL LUCCHETTO, ordine ES voce 11.** Il
                // lucchetto nell'app e' il segno del Premium: una tradizione
                // che non e' ancora pronta porta la clessidra, come le arti
                // in arrivo.
                if (locked) ...[
                  const SizedBox(width: 3),
                  Icon(Icons.hourglass_bottom_rounded,
                      key:
                          Key('oroscopo_tradition_clessidra_${tradition.name}'),
                      size: 10,
                      color: palette.goldSoft.withValues(alpha: 0.65)),
                ],
              ],
            ),
            if (locked)
              Text(
                'In arrivo$fase',
                key: Key('oroscopo_tradition_soon_${tradition.name}'),
                style: TypographyTokens.etichetta().copyWith(
                  color: palette.goldSoft.withValues(alpha: 0.6),
                  letterSpacing: 0.3,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Il micro messaggio del Maestro su una tradizione ancora chiusa.
///
/// Al posto del lucchetto muto risponde Medora in prima persona. Con Riduci
/// Movimento compare gia' posato, e dalla seconda volta in poi anche.
class _TraditionInvite extends StatelessWidget {
  const _TraditionInvite({
    required this.tradition,
    required this.maestro,
    required this.palette,
    required this.animate,
  });

  final AstroTradition? tradition;
  final Maestro maestro;
  final MaestroPalette palette;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final t = tradition;
    if (t == null) return const SizedBox.shrink();
    final immobile = MediaQuery.of(context).disableAnimations || !animate;
    final riga = Container(
      key: Key('tradition_invite_${t.name}'),
      margin: const EdgeInsets.only(top: SpacingTokens.sm),
      padding: const EdgeInsets.all(SpacingTokens.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        color: palette.surfaceElevated.withValues(alpha: 0.5),
        border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TraditionGlyph(tradition: t, color: palette.goldSoft, size: 20),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Text(
              t.invito,
              style: TypographyTokens.didascalia().copyWith(
                color: ColorTokens.textPrimary,
                height: 1.35,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
    if (immobile) return riga;
    return TweenAnimationBuilder<double>(
      key: ValueKey('tradition_invite_anim_${t.name}'),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child:
            Transform.translate(offset: Offset(0, (1 - v) * 8), child: child),
      ),
      child: riga,
    );
  }
}

class _PeriodTab extends StatelessWidget {
  const _PeriodTab({
    required this.period,
    required this.locked,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  final HoroscopePeriod period;

  /// Se chi guarda non ha il piano di questo periodo.
  final bool locked;
  final bool selected;
  final MaestroPalette palette;
  final VoidCallback onTap;

  /// Lo stile del nome, senza il colore: serve anche a misurarlo.
  static TextStyle get _stile =>
      TypographyTokens.etichetta().copyWith(letterSpacing: 0.6);

  /// Il margine ai due lati del nome dentro la pastiglia. Sei punti: con
  /// dieci, al Viandante (due lucchetti) i quattro nomi non stavano nella
  /// riga del Realme e si rimpicciolivano di un sesto, sotto la misura delle
  /// etichette; con sei restano alla loro misura, a meno di tre centesimi.
  static const double _respiro = 6;

  /// Quanto e' largo il lucchetto col suo spazio.
  static const double _lucchetto = 16;

  /// La larghezza che serve a questa voce per stare su una riga: il nome
  /// misurato col suo stile e la scala del testo, il lucchetto se c'e', il
  /// respiro ai lati e un margine, perche' una parola che entra per un decimo
  /// di punto sul telefono va a capo lo stesso.
  static double larghezzaNaturale(HoroscopePeriod period,
      {required bool locked, required TextScaler scala}) {
    final pittore = TextPainter(
      text: TextSpan(text: period.label, style: _stile),
      textDirection: TextDirection.ltr,
      textScaler: scala,
      maxLines: 1,
    )..layout();
    final larghezza = pittore.width;
    pittore.dispose();
    return larghezza + (locked ? _lucchetto : 0) + _respiro * 2 + 2;
  }

  @override
  Widget build(BuildContext context) {
    final tab = GestureDetector(
      key: Key('oroscopo_period_${period.name}'),
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          gradient: selected
              ? LinearGradient(colors: [
                  palette.primary.withValues(alpha: 0.85),
                  palette.surfaceElevated.withValues(alpha: 0.85),
                ])
              : null,
          border: selected
              ? Border.all(color: palette.gold.withValues(alpha: 0.6))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // **IL TESTO DEVE POTER CEDERE.** Ordine CM voce 09, famiglia A.
            // Su una riga sola: la larghezza gliela da' chi lo monta
            // ([larghezzaNaturale]), e a capo non ci va.
            Flexible(
                child: Text(period.label,
                    key: Key('oroscopo_period_nome_${period.name}'),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: _stile.copyWith(
                      color: selected
                          ? palette.goldSoft
                          : ColorTokens.textSecondary
                              .withValues(alpha: locked ? 0.6 : 1.0),
                    ))),
            if (locked) ...[
              const SizedBox(width: 4),
              Icon(Icons.lock_rounded,
                  key: Key('oroscopo_lock_${period.name}'),
                  size: 12,
                  color: palette.goldSoft.withValues(alpha: 0.65)),
            ],
          ],
        ),
      ),
    );
    if (!locked) return tab;
    return Tooltip(
      message:
          'L\'oroscopo della ${period.label.toLowerCase()} è del Cerchio Premium. Abbonati per aprirlo.',
      child: tab,
    );
  }
}

class _HoroscopeCardView extends StatelessWidget {
  const _HoroscopeCardView({
    required this.scrivendo,
    required this.durataScrittura,
    required this.card,
    required this.palette,
    required this.pulse,
    required this.depth,
    required this.onDepthSelected,
    required this.onDepthLocked,
    required this.premiumUnlocked,
    required this.giaScritto,
    required this.onScritto,
    required this.livello,
    this.oraDOro,
    this.passaggio,
    this.carta,
    this.adesso,
  });

  /// **IL PASSAGGIO CHE SI ACCENDE, ordine ES voce 33**: la voce del cielo
  /// che il testo nomina per primo, la carta e il giorno. Tutti e tre, o la
  /// riga non c'e'.
  final VoceDelCielo? passaggio;
  final NatalChart? carta;
  final DateTime? adesso;

  /// **L'ORA D'ORO, ordine ES voce 32**, solo sulla Generale e solo con la
  /// carta natale; null nei giorni senza un aspetto favorevole esatto.
  final String? oraDOro;

  /// A quale livello di dati di nascita e' fatto il responso: decide la nota
  /// del metodo (ordine ES voce 30).
  final LivelloPersonalizzazione livello;

  /// Se questo testo e' gia' stato scritto una volta: la macchina da
  /// scrivere non riparte, il testo nasce intero e fermo. E' un gancio e non
  /// un booleano: si legge alla rinascita, non alla costruzione.
  final bool Function() giaScritto;

  /// Chiamato quando la scrittura di questo testo finisce, per intero o per
  /// tocco: la schermata se lo segna accanto alla risposta.
  final VoidCallback onScritto;

  /// Se il responso si sta componendo adesso, a macchina da scrivere.
  ///
  /// Ordine 2171 voce 5: i testi non compaiono interi, si scrivono. Con
  /// Riduci Movimento compaiono interi lo stesso, perche' l'informazione non
  /// dipende dal moto.
  final bool scrivendo;

  /// Quanto ci mette un responso a scriversi per intero. La velocita' vive
  /// nella schermata e arriva qui dichiarata: chi la cambia la vede.
  final Duration durataScrittura;

  final HoroscopeCard card;
  final MaestroPalette palette;
  final Animation<double> pulse;
  final AnswerDepth depth;

  /// La scelta della profondita', che prima non aveva dove andare.
  final ValueChanged<AnswerDepth> onDepthSelected;
  final ValueChanged<AnswerDepth> onDepthLocked;

  /// Se la persona ha diritto alla profondita' Profonda. Arriva da chi
  /// conosce il piano, perche' una card non deve leggere l'abbonamento.
  final bool premiumUnlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('oroscopo_card_${card.domain.name}'),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        // Blu e oro di Medora, come la card di condivisione.
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.surfaceElevated.withValues(alpha: 0.95),
            Color.lerp(palette.surface, palette.deepest, 0.35)!
                .withValues(alpha: 0.92),
          ],
        ),
        border: Border.all(color: palette.gold.withValues(alpha: 0.32)),
        boxShadow: [
          BoxShadow(
            color: palette.glow.withValues(alpha: 0.16),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // In alto a sinistra titolo e categoria, in alto a destra la
          // profondita' della risposta.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // **A CAPO FRA LE PAROLE, MAI DENTRO.** Sulla build 2285
                    // (ordine ER) la scheda della Fortuna dei Gemelli si
                    // leggeva "AMICI PORT / AFORTUNA": i titoli del giorno
                    // della voce ER.14 sono piu' lunghi, e la colonna accanto
                    // alla tendina e' stretta. La card da condividere lo
                    // risolveva dall'ordine BD voce 07; qui mancava. Vedi
                    // [TitoloDellaSchedaDelGiorno].
                    TitoloDellaSchedaDelGiorno(
                        key: Key('oroscopo_titolo_${card.domain.name}'),
                        testo: card.title,
                        stile: TypographyTokens.titoloScheda()
                            .copyWith(color: palette.goldSoft, height: 1.1)),
                    Text(card.domain.label.toUpperCase(),
                        style: TypographyTokens.etichetta().copyWith(
                            color: ColorTokens.textSecondary,
                            letterSpacing: 1.4)),
                  ],
                ),
              ),
              // **LA PROFONDITA' C'E' SEMPRE, su ogni scheda** (il fondatore,
              // 30 settembre 2026): anche su quelle dell'anno, che la voce
              // ES.04 aveva lasciato senza.
              ...[
                const SizedBox(width: SpacingTokens.sm),
                // Menu a tendina compatto: ora le etichette sono corte, quindi
                // resta leggibile senza rubare spazio al titolo.
                AnswerDepthSelector(
                  key: Key('oroscopo_depth_${card.domain.name}'),
                  current: depth,
                  palette: palette,
                  // Chi ha pagato deve poter aprire la Profonda. Questo
                  // parametro non veniva passato da nessuno in tutta l'app,
                  // quindi restava falso e il lucchetto valeva anche per chi
                  // l'aveva comprata: una funzione venduta e mai consegnata.
                  premiumUnlocked: premiumUnlocked,
                  onSelect: onDepthSelected,
                  onLockedTap: onDepthLocked,
                ),
              ],
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          // Poi l'infografica a cinque icone col numero, sotto il titolo.
          // Accanto, dall'ordine ES voce 30, il punto interrogativo del
          // metodo: discreto, per chi lo cerca.
          Row(
            children: [
              Expanded(
                child: DomainLevel(
                  domain: card.domain,
                  value: card.indicator,
                  palette: palette,
                  pulse: pulse,
                ),
              ),
              SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  key: Key('oroscopo_metodo_${card.domain.name}'),
                  tooltip: 'Come nasce questa lettura',
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.help_outline_rounded,
                      size: 18, color: palette.goldSoft.withValues(alpha: 0.7)),
                  onPressed: () => dialogoDelCerchio<void>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      key: Key('oroscopo_nota_metodo_${card.domain.name}'),
                      backgroundColor: palette.deepest,
                      title: Text('Come nasce questa lettura',
                          style: TypographyTokens.cerimoniale()
                              .copyWith(color: palette.goldSoft)),
                      content: Text(
                          card.metodo ??
                              IlMetodoDelResponso.delGiorno(
                                  card.domain, livello),
                          style: TypographyTokens.corpo().copyWith(
                              color: ColorTokens.textPrimary, height: 1.45)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text('Chiudi',
                              style: TypographyTokens.etichetta()
                                  .copyWith(color: palette.goldSoft)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          // L'apertura personalizzata col nome, prima del testo della Generale.
          if (card.opening != null) ...[
            Text(card.opening!,
                key: const Key('oroscopo_opening'),
                style: TypographyTokens.lettura().copyWith(
                    color: palette.goldSoft,
                    height: 1.5,
                    fontStyle: FontStyle.italic)),
            const SizedBox(height: SpacingTokens.sm),
          ],
          // IL RESPONSO SI COMPONE, ordine 2171 voce 5. **Un tocco sul testo
          // lo completa subito**: un'animazione da cui non si puo' uscire e'
          // una gabbia, e chi ha fretta non deve aspettare il rito.
          _ResponsoCheSiScrive(
            key: Key('oroscopo_testo_${card.domain.name}'),
            testo: card.text,
            durataScrittura: durataScrittura,
            scrivendo: scrivendo,
            giaScritto: giaScritto,
            onScritto: onScritto,
          ),
          // **DA DOVE VIENE, DOPO LA LETTURA** (ordine ES voce 28, spostata
          // il 30 settembre 2026). La riga che nomina i pianeti e le case
          // stava sotto il livello, prima del testo: chi leggeva incontrava
          // il simbolo prima della risposta. Le Linee Guida, sezione 2: *"il
          // simbolo non apre mai"*, il "da dove viene" e' la terza parte.
          if (card.rigaDelLivello != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            Text('Da dove viene',
                style: TypographyTokens.etichetta().copyWith(
                    color: ColorTokens.textSecondary, letterSpacing: 1.2)),
            Text(card.rigaDelLivello!,
                key: Key('oroscopo_riga_del_livello_${card.domain.name}'),
                style: TypographyTokens.didascalia()
                    .copyWith(color: ColorTokens.textSecondary, height: 1.35)),
          ],
          if (passaggio != null && carta != null && adesso != null) ...[
            const SizedBox(height: SpacingTokens.xs),
            LaRigaDelPassaggio(
                voce: passaggio!,
                carta: carta!,
                adesso: adesso!,
                palette: palette),
          ],
          if (oraDOro != null && card.domain == HoroscopeDomain.generale) ...[
            const SizedBox(height: SpacingTokens.sm),
            Row(
              key: const Key('oroscopo_ora_d_oro'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.wb_twilight_rounded,
                    size: 18, color: palette.goldSoft),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Text(oraDOro!,
                      style: TypographyTokens.didascalia()
                          .copyWith(color: palette.goldSoft, height: 1.4)),
                ),
              ],
            ),
          ],
          // **IL NUMERO E IL COLORE SOLO DOVE CI SONO.** Visto sul Realme il
          // 30 settembre 2026: la scheda della Fortuna dell'anno mostrava
          // "NUMERO 0" e "COLORE DEL GIORNO" vuoto, perche' il riquadro si
          // disegnava per ogni scheda della Fortuna e l'anno non ha ne'
          // l'uno ne' l'altro. Padre: ordine ES voce 04.
          if (card.domain == HoroscopeDomain.fortuna &&
              (card.luckyNumber != null ||
                  card.numeriDelGiorno != null ||
                  card.dayColor != null)) ...[
            const SizedBox(height: SpacingTokens.md),
            _FortunaFooter(card: card, palette: palette),
            // LA REGOLA DEL NUMERO E DEL COLORE, ordine ES voce 29.
            if (card.rigaDellaFortuna != null) ...[
              const SizedBox(height: SpacingTokens.xs),
              Text(card.rigaDellaFortuna!,
                  key: const Key('oroscopo_regola_della_fortuna'),
                  style: TypographyTokens.didascalia().copyWith(
                      color: ColorTokens.textSecondary, height: 1.35)),
            ],
          ],
        ],
      ),
    );
  }
}

/// La riga che dichiara da dove viene il testo, quando non viene dal cielo.
/// **I TRE CIELI DI OGGI, ordine ES voce 36.** Una riga per dominio: in oro
/// quando le tre tradizioni sono d'accordo, piu' piana quando non lo sono.
class _ITreCieliView extends StatelessWidget {
  const _ITreCieliView(
      {required this.accordi, required this.sigillo, required this.palette});

  final List<AccordoDelDominio> accordi;
  final StatoDeiTreCieli sigillo;
  final MaestroPalette palette;

  /// La riga del Sigillo dei Tre Cieli (ordine ES voce 37): acceso, o cosa
  /// manca per accenderlo oggi.
  String get _rigaDelSigillo {
    if (sigillo.accesoOggi) {
      final quante = sigillo.giorni > 1
          ? ' In tutto si è acceso in ${sigillo.giorni} giorni.'
          : '';
      return 'Il Sigillo dei Tre Cieli è acceso: oggi hai letto il cielo in '
          'tutte e tre le tradizioni.$quante';
    }
    final mancano =
        sigillo.mancano.map((t) => ITreCieli.conArticolo[t]!).join(' e ');
    return 'Il Sigillo dei Tre Cieli si accende leggendo oggi anche $mancano.';
  }

  @override
  Widget build(BuildContext context) {
    return DepthCard(
      key: const Key('oroscopo_tre_cieli'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('I tre cieli di oggi',
              style: TypographyTokens.titoloSezione()
                  .copyWith(color: palette.goldSoft)),
          for (final a in accordi) ...[
            const SizedBox(height: SpacingTokens.sm),
            Text(
              a.frase,
              key: Key('oroscopo_tre_cieli_${a.dominio.name}'),
              style: TypographyTokens.corpo().copyWith(
                  color:
                      a.concordi ? palette.goldSoft : ColorTokens.textSecondary,
                  height: 1.4),
            ),
          ],
          const SizedBox(height: SpacingTokens.md),
          Row(
            key: const Key('oroscopo_sigillo_tre_cieli'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                  sigillo.accesoOggi
                      ? Icons.verified_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 18,
                  color: sigillo.accesoOggi
                      ? palette.gold
                      : ColorTokens.textMuted),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Text(
                  _rigaDelSigillo,
                  key: const Key('oroscopo_sigillo_tre_cieli_riga'),
                  style: TypographyTokens.didascalia().copyWith(
                      color: sigillo.accesoOggi
                          ? palette.goldSoft
                          : ColorTokens.textMuted,
                      height: 1.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotaDelCielo extends StatelessWidget {
  const _NotaDelCielo(
      {required this.testo,
      required this.palette,
      required this.completa,
      required this.invito});

  final String testo;
  final MaestroPalette palette;

  /// L'etichetta della porta verso i dati di nascita, gia' scelta per il
  /// livello. Nulla a cielo completo, dove non c'e' nulla da completare.
  final String? invito;

  /// Vero quando qualche transito vero c'e' comunque: cambia solo l'icona,
  /// perche' "manca l'ora" e "manca tutto" non sono la stessa mancanza.
  final bool completa;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('oroscopo_nota_del_cielo'),
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        color: palette.deepest.withValues(alpha: 0.45),
        border: Border.all(color: palette.gold.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                  completa
                      ? Icons.schedule_rounded
                      : Icons.info_outline_rounded,
                  size: 16,
                  color: palette.goldSoft),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Text(testo,
                    style: TypographyTokens.didascalia().copyWith(
                        color: ColorTokens.textSecondary, height: 1.45)),
              ),
            ],
          ),
          // **LA PORTA, non solo il nome del rimedio.** Ordine CS voce S1.
          // Prima qui la nota diceva Completa i dati di nascita e finiva
          // li': la schermata che li accoglie esisteva gia', raggiungibile
          // dal Calendario e dall'Account, ma da sotto il responso no.
          if (invito != null) ...[
            const SizedBox(height: SpacingTokens.xs),
            Align(
              alignment: Alignment.centerLeft,
              // Oro pieno con la scritta scura, la stessa forma con cui il
              // Calendario apre questa stessa porta. L'oro come inchiostro
              // sul fondo della nota faceva 5.65 contro i 7.0 che una
              // etichetta deve tenere, e il censimento dei grigi l'ha colto
              // prima che arrivasse a un telefono.
              child: FilledButton(
                key: const Key('oroscopo_completa_la_nascita'),
                style: FilledButton.styleFrom(
                  backgroundColor: palette.gold,
                  foregroundColor: palette.deepest,
                  minimumSize: const Size(0, 44),
                  padding:
                      const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
                ),
                onPressed: () =>
                    Navigator.of(context).push(DatiDiNascitaScreen.route()),
                child: Text(invito!,
                    style: TypographyTokens.etichetta()
                        .copyWith(color: palette.deepest)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// **LE TRE AZIONI SOTTO IL RESPONSO DELL\'OROSCOPO, ordine CG voci 06 e 08.**
///
/// Prima qui c\'era il solo Condividi, in oro pieno, con la sua attesa: quella
/// forma resta, perche\' e\' l\'invito che chiude il responso e non un accidente.
/// Accanto sono nati il Custodisci e il Parlane con Medora, e vengono dalla
/// porta sola che vale per tutte e tredici le arti col responso.
class _ShareBlock extends StatelessWidget {
  const _ShareBlock(
      {required this.palette,
      required this.sharing,
      required this.onShare,
      required this.segno,
      required this.testoDelResponso});

  final MaestroPalette palette;
  final bool sharing;
  final Future<bool> Function() onShare;
  final String segno;

  /// Il testo che si custodisce: le schede del cielo di oggi, in fila.
  final String testoDelResponso;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Porta il tuo cielo di oggi con te',
            textAlign: TextAlign.center,
            style: TypographyTokens.didascalia()
                .copyWith(color: ColorTokens.textSecondary)),
        const SizedBox(height: SpacingTokens.sm),
        AzioniDelResponso(
          palette: palette,
          maestro: Maestro.medora,
          dorato: true,
          responso: ResponsoDaCustodire(
            arte: 'oroscopo',
            titolo: 'Il tuo oroscopo, $segno',
            testo: testoDelResponso,
            dati: {'segno': segno},
          ),
          condividi: onShare,
          aperturaDellaChat: ChatOpeners.oroscopo(segno),
        ),
      ],
    );
  }
}

/// **IL PULSANTE CHE CONDIVIDE LA CARD DEL PERIODO, ordine ES voce 05.** Il
/// fondatore ha fatto un emblema per la Settimana, uno per il Mese e uno per
/// l'Anno, e la card da condividere li porta in testa; ma il gesto per
/// condividere c'era solo sotto il consulto del Giorno, e quegli emblemi non
/// li vedeva nessuno (visto il 30 settembre 2026, cercando sul Realme la card
/// di un periodo).
class _CondividiIlPeriodo extends StatelessWidget {
  const _CondividiIlPeriodo({
    required this.periodo,
    required this.palette,
    required this.sharing,
    required this.onShare,
  });

  final HoroscopePeriod periodo;
  final MaestroPalette palette;
  final bool sharing;
  final Future<bool> Function() onShare;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      key: Key('oroscopo_condividi_${periodo.name}'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 44),
        side: BorderSide(color: palette.gold.withValues(alpha: 0.6)),
      ),
      onPressed: sharing ? null : () => unawaited(onShare()),
      icon: Icon(Icons.ios_share_rounded, size: 18, color: palette.goldSoft),
      // **L'ETICHETTA INTERA, ANCHE COL PREMIO.** Visto sul Realme il 30
      // settembre 2026, build di prova 2289: "Condividi la settimana · +15
      // Eo", con l'ultima lettera tagliata. Padre: ordine ES voce 05, mio; in
      // prova il premio non c'e' e l'etichetta ci stava. Se non ci sta, si
      // rimpicciolisce intera.
      label: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
            PremioDellaCondivisione.etichetta(context,
                base: periodo.daCondividere),
            key: Key('oroscopo_condividi_etichetta_${periodo.name}'),
            maxLines: 1,
            softWrap: false,
            style: TypographyTokens.corpo().copyWith(color: palette.goldSoft)),
      ),
    );
  }
}

/// Il piede della scheda Fortuna: numero fortunato e colore del giorno.
class _FortunaFooter extends StatelessWidget {
  const _FortunaFooter({required this.card, required this.palette});

  final HoroscopeCard card;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    // **LE DUE BOLLE SONO ALTE UGUALE.** Ordine DD voce 09, 10 settembre
    // 2026, e il fatto e' del fondatore: i riquadri Numero e Colore del
    // giorno non sono alti uguale e la coppia si vede storta.
    //
    // **Misurato prima della cura**: la bolla NUMERO alta **61,0** punti,
    // quella COLORE DEL GIORNO **84,0**, cioe' **ventitre punti di scarto**.
    // La causa e' che questa Row non allineava niente e ognuna prendeva
    // l'altezza del suo contenuto: da una parte una cifra su una riga,
    // dall'altra un'etichetta piu' lunga che va a capo.
    //
    // `IntrinsicHeight` misura la piu' alta delle due e `stretch` porta
    // l'altra alla stessa quota: **le due bolle si pareggiano da sole**
    // anche il giorno che un colore ha un nome piu' lungo.
    return IntrinsicHeight(
        child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Il numero al centro del suo riquadro, ordine ES voce 14.
        RiquadroDelNumero(
            numero: card.luckyNumber ?? 0,
            palette: palette,
            // I due numeri dell'elemento nella lettura cinese (ES.08).
            etichetta: card.numeriDelGiorno == null ? 'Numero' : 'Numeri',
            cifre: card.numeriDelGiorno?.join(' e ')),
        const SizedBox(width: SpacingTokens.sm),
        Expanded(
          child: _Pill(
            label: 'Colore del giorno',
            palette: palette,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: oroscopoColor(card.dayColor) ?? palette.goldSoft,
                    border:
                        Border.all(color: palette.gold.withValues(alpha: 0.6)),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(card.dayColor ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TypographyTokens.didascalia()
                          .copyWith(color: ColorTokens.textPrimary)),
                ),
              ],
            ),
          ),
        ),
      ],
    ));
  }
}

class _Pill extends StatelessWidget {
  const _Pill(
      {required this.label, required this.child, required this.palette});

  final String label;
  final Widget child;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm, vertical: SpacingTokens.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
        color: palette.primary.withValues(alpha: 0.4),
        border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label.toUpperCase(),
              style: TypographyTokens.etichetta().copyWith(
                  color: ColorTokens.textSecondary, letterSpacing: 0.8)),
          const SizedBox(height: 2),
          child,
        ],
      ),
    );
  }
}

/// LE FASI DEL CONSULTO, ordine BK voci 02 e 03.
///
/// Una fase sola al posto di due booleani indipendenti. Il difetto che l'ha
/// resa necessaria: `_interrogato` e `_interrogazione` diventavano veri
/// insieme, e la combinazione "schede montate mentre la scrittura non e'
/// ancora cominciata" mostrava il responso intero. Qui quella combinazione non
/// esiste, perche' le schede appartengono a una fase che viene DOPO.
enum _FaseDelConsulto {
  /// Il cielo non e' stato ancora interrogato: c'e' il gesto, e nient'altro.
  attesa,

  /// Primo momento: il cielo si raccoglie, coi corpi veri attorno all'emblema.
  raccolta,

  /// Secondo momento: il fatto vero del giorno viene nominato.
  nomina,

  /// Il responso si compone, una scheda dopo l'altra.
  responso,
}
