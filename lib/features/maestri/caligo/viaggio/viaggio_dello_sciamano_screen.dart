import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/astro/zodiac.dart';
import '../../../../core/config/app_flags.dart';
import '../../../../core/rituals/animal_catalog.dart';
import '../../../../core/rituals/guide_animal_derivation.dart';
import '../../../../core/sensi/respiro_che_dirada.dart';
import '../../../../core/sensi/palette_sensoriale.dart';
import '../../../../core/viaggio/diario_dei_viaggi.dart';
import '../../../../core/viaggio/dove_sta_la_testa.dart';
import '../../../../core/viaggio/i_quattro_viaggi.dart';
import '../../../../core/viaggio/la_domanda_del_viaggio.dart';
import '../../../../core/viaggio/la_voce_del_mondo_di_sotto.dart';
import '../../../../core/viaggio/scena_del_viaggio.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../../../design_system/components/depth_card.dart';
import '../../../../design_system/typography/paragrafi_di_lettura.dart';
import '../../../../design_system/components/titolo_che_non_si_rompe.dart';
import '../../../maestri/rotta_arte.dart';
import '../../../sigilli/regia_del_cammino.dart';
import '../../widgets/foglio_delle_fonti.dart';
import '../../../../core/maestro/maestro.dart';
import 'il_tunnel_che_scende.dart';
import 'la_girandola_degli_animali.dart';
import 'sfondo_del_mondo_di_sotto.dart';
import '../../../../core/entitlement/entitlement_service.dart';
import '../../../../core/entitlement/tier.dart';
import '../../../../core/viaggio/il_verso_dell_animale.dart';
import '../../../../core/viaggio/la_promessa_del_viaggio.dart';
import '../../../../core/viaggio/tetti_del_viaggio.dart';
import 'card_della_rivelazione.dart';
import 'la_lente_che_scopre.dart';
import 'le_quattro_impronte.dart';
import 'la_nebbia_e_l_animale.dart';

/// **IL VIAGGIO DELLO SCIAMANO.** Ordine DC voci 01, 04, 05, 06 e 07,
/// 10 settembre 2026.
///
/// **Sostituisce l'Animale Guida**, che il fondatore ha giudicato *"una
/// funzionalita' buttata li': rivela un animale, da' un messaggio, e
/// finisce"*. La causa e' una sola: **oggi l'Animale e' un risultato, e nella
/// tradizione e' un rapporto.**
///
/// Nel core shamanism l'animale di potere non si scopre con un test: si
/// incontra viaggiando, si riconosce dopo che si e' mostrato piu' volte, si
/// nutre perche' resti, e soprattutto **si consulta**: si scende con una
/// domanda e si risale con una risposta.
///
/// **LE FONTI**: Michael Harner, *The Way of the Shaman*, 1980, per il metodo;
/// Mircea Eliade, *Le Chamanisme et les techniques archaiques de l'extase*,
/// 1951, per la cosmologia dei tre mondi.
class ViaggioDelloSciamanoScreen extends StatefulWidget {
  const ViaggioDelloSciamanoScreen({
    super.key,
    required this.userSign,
    this.now,
    this.diario,
  });

  final Zodiac userSign;

  /// L'istante da cui si guarda, dichiarato nelle prove.
  final DateTime? now;

  /// Il diario, iniettabile: **le prove non aspettano nessun archivio**, che
  /// e' la regola della voce DC.16.
  final DiarioDeiViaggi? diario;

  static Route<void> route({required Zodiac userSign, DateTime? now}) {
    return PassaggioDelCerchio.rotta<void>((_) => SogliaArte(
          id: 'guide_animal',
          maestro: Maestro.caligo,
          child: ViaggioDelloSciamanoScreen(userSign: userSign, now: now),
        ));
  }

  /// **QUANTO DURA LA DISSOLVENZA CHE INTRODUCE LA NEBBIA.** Ordine DG voce
  /// 09: un secondo e due decimi.
  ///
  /// **Sta nella classe pubblica e non nello stato** perche' una guardia
  /// deve poterlo leggere: la prova che misura la dissolvenza aspetta questo
  /// tempo e non un numero scritto due volte.
  ///
  /// **Perche' non mezzo secondo e perche' non tre.** Sotto il mezzo secondo
  /// l'occhio legge ancora un taglio, e la dissolvenza tanto varrebbe non
  /// farla. Sopra i due secondi diventa un'attesa in piu' dentro una discesa
  /// che il fondatore ha gia' chiesto di accorciare, e si pagherebbe con il
  /// tempo cio' che si e' guadagnato con la grazia.
  static const Duration quantoDuraLaDissolvenza = Duration(milliseconds: 1200);

  @override
  State<ViaggioDelloSciamanoScreen> createState() =>
      _ViaggioDelloSciamanoScreenState();
}

/// **LE TRE VIE CON CUI SI SCENDE.** Ordine DC voce 05, forma rifatta il 10
/// settembre 2026.
///
/// L'ordine ne detta tre e dice che **nessuna e' la via povera**. Fino a
/// questa stesura erano montate tutte e tre e nessuna era dichiarata: un
/// campo di testo, sei pulsanti e una settima riga, tutti allo stesso
/// livello. Adesso sono un selettore, e chi guarda vede che sono tre.
enum ViaDellaDomanda {
  /// Una delle sei gia' scritte.
  scelta,

  /// La propria, scritta a mano.
  scritta,

  /// Nessuna: si scende soltanto per incontrarlo.
  incontro,
}

/// I momenti del viaggio, in fila.
enum FaseDelViaggio {
  /// Si sceglie la porta e si scrive la domanda.
  soglia,

  /// Il dito preme e si scende.
  discesa,

  /// La nebbia, che la mano apre.
  nebbia,

  /// L'incontro, e la scelta fra le tre ombre.
  incontro,

  /// **LA LENTE: si e' seguita un'ombra, e adesso la si scopre.**
  /// Ordine DE voce 03.
  lente,

  /// La scena che si riporta su.
  risalita,
}

class _ViaggioDelloSciamanoScreenState
    extends State<ViaggioDelloSciamanoScreen> {
  late final DiarioDeiViaggi _diario =
      widget.diario ?? DiarioDeiViaggi(orologio: () => _adesso);

  DateTime get _adesso => widget.now ?? DateTime.now();

  FaseDelViaggio _fase = FaseDelViaggio.soglia;

  /// **QUANTO SI E' SCESI**, da 0 a 1, e **la muove il dito**.
  double _scesi = 0;
  Timer? _discesa;

  /// **DA DOVE NASCE IL PNG DELLA CARD DELLA RIVELAZIONE.** Ordine DE voce
  /// 08: la card si fotografa da qui e va alla porta unica.
  final GlobalKey _cornice = GlobalKey();

  /// **LA RIGA DEL RICHIAMO**, quando questa scena riprende un elemento di
  /// una di prima. Ordine DE voce 11. Nulla quando non c'e' niente da
  /// riprendere: *"una continuita' inventata vale meno di nessuna
  /// continuita'"*.
  String? _ilRichiamo;

  /// I varchi aperti nella nebbia dalla mano.
  /// **QUANTO LA NEBBIA E' GIA' DIRADATA**, da 0 a 1. Ordine DG voce 05.
  double _nebbia = 0;

  /// **QUANTO IL TUNNEL SI E' GIA' DISSOLTO**, da 0 a 1. Ordine DG voce 09,
  /// 12 settembre 2026: *"quando si scende, dovrebbe esserci una dissolvenza
  /// che introduce la nebbia"*.
  ///
  /// Sotto c'e' gia' la nebbia, e la galleria svanisce sopra di lei. A uno la
  /// dissolvenza e' finita.
  double _entraLaNebbia = 0;

  /// Il battito della dissolvenza. **Non un `AnimationController`**: sul
  /// 767f596c le scale di animazione valgono zero, e una dissolvenza fatta col
  /// controller sarebbe il taglio secco di prima con la convinzione di averlo
  /// tolto.
  Timer? _dissolvenza;

  /// **QUANTO IL DITO STA SPINGENDO**, da 0 a 1. Cala da sola a ogni battito:
  /// fermarsi non tiene aperto.
  double _spintaDelDito = 0;

  /// Il battito che alza la nebbia finche' il dito si muove.
  Timer? _respiro;

  final TextEditingController _domanda = TextEditingController();

  /// **CON CHE COSA SI SCENDE**, e le tre vie sono dichiarate come tre.
  ViaDellaDomanda _via = ViaDellaDomanda.scelta;
  String _temaScelto = '';

  ScenaDelViaggio? _scena;

  /// **IL GIORNO IN CUI QUESTA SCENA E' NATA.** Ordine DG voce 07: il filo
  /// della risposta lo conosce, e se lo chiedesse all'orologio a ogni
  /// ridisegno il testo cambierebbe sotto gli occhi di chi legge.
  DateTime? _giornoDellaScena;
  String? _seguito;
  bool _caricato = false;

  /// **QUANTO DURA LA DISCESA. VENTI SECONDI, POI NOVE.** Ordine DE voce 06.
  ///
  /// **CHE COSA C'ERA PRIMA, sotto la Regola D.** Quarantacinque secondi la
  /// prima volta e venti dal secondo viaggio in poi, scritti dalla voce
  /// DC.07. Il fondatore: *"la discesa da quaranta a novanta secondi e' troppo
  /// lunga e la colpa e' dell'ordine precedente"*.
  ///
  /// **PERCHE' VENTI E NON QUARANTACINQUE.** Venti secondi col dito premuto
  /// **senza mai staccarlo** sono gia' un impegno: nessuno tiene un dito fermo
  /// per venti secondi per sbaglio. Quarantacinque erano il doppio del tempo
  /// in cui la galleria ha finito di dire cio' che ha da dire, e la seconda
  /// meta' era attesa pura.
  ///
  /// **PERCHE' NOVE E NON OTTO NE' DIECI.** L'ordine concede otto o dieci, e
  /// nove sta in mezzo: e' **meno della meta'** della prima discesa, che e' il
  /// segnale che la strada e' conosciuta, e resta sopra gli otto secondi
  /// perche' sotto quel tempo il punto di fuga non fa in tempo ad aprirsi e la
  /// galleria si legge come una dissolvenza.
  static const Duration primaDiscesa = Duration(seconds: 20);

  /// **E DALLA SECONDA IN POI DURA UGUALE.** Ordine DG voce 06,
  /// 11 settembre 2026: *"il viaggio in discesa fa veramente cagare ed e'
  /// lunghissimo"*.
  ///
  /// **Qui c'erano nove secondi**, scelti dall'ordine DC come *"meno della
  /// meta' della prima"*. Il fondatore aveva gia' fissato il valore che voleva
  /// nell'ordine DE, **venti secondi**, e nove non e' venti: la discesa
  /// conosciuta era diventata una scorciatoia, non una discesa.
  static const Duration discesaConosciuta = Duration(seconds: 20);

  Duration get _quantoDura =>
      _diario.quanteDiscese == 0 ? primaDiscesa : discesaConosciuta;

  @override
  void initState() {
    super.initState();
    // **NON SI ASPETTA L'ARCHIVIO.** Ordine DC voce 16: se il diario non
    // risponde, si scende lo stesso e questa e' la prima discesa.
    unawaited(_diario.carica().then((_) {
      if (mounted) setState(() => _caricato = true);
    }));
  }

  @override
  void dispose() {
    _discesa?.cancel();
    _dissolvenza?.cancel();
    _fermaIlRespiro();
    _domanda.dispose();
    super.dispose();
  }

  /// **LE FASI IN CUI LA SCENA OCCUPA TUTTO.**
  ///
  /// La discesa e la nebbia sono immagini continue, senza niente da leggere
  /// in cima, e una striscia di pagina sopra le smentisce.
  ///
  /// **L'INCONTRO NO, ed e' un difetto visto sul telefono 767f596c il 10
  /// settembre 2026**: le tre ombre stanno in tre righe, e con la barra sopra
  /// **la prima delle tre finiva mezza dietro il titolo**. L'incontro non e'
  /// una scena da guardare, e' una scelta fra tre, e una scelta nascosta non
  /// e' una scelta. La soglia e la risalita sono testo, e li' la barra ha il
  /// suo posto da sempre.
  bool get _laScenaEPiena =>
      _fase == FaseDelViaggio.discesa ||
      _fase == FaseDelViaggio.nebbia ||
      // **LA LENTE E' UNA SCENA PIENA, ordine DE voce 03**: l'immagine
      // dell'animale occupa tutto, e una striscia di pagina sopra la
      // smentirebbe.
      _fase == FaseDelViaggio.lente ||
      // **E LA SOGLIA, dall'ordine DE voce 01**: *"la soglia esce dal
      // riquadro e diventa una scena piena: l'immagine occupa tutta l'area
      // utile, e il testo ci sta sopra"*. Una striscia di pagina sopra il
      // bosco vorrebbe dire che l'immagine non occupa tutta l'area utile.
      _fase == FaseDelViaggio.soglia;

  /// **L'ANIMALE DI QUESTA PERSONA, e viene dalla sua nascita.** Ordine DG
  /// voce 01: la porta e' una sola, `GuideAnimalDerivation.forSign`, e il
  /// Viaggio non ne apre una seconda.
  GuideAnimal get _suoAnimale => GuideAnimalDerivation.forSign(widget.userSign);

  /// **SE IL NOME SI PUO' DIRE**, cioe' se le quattro discese sono compiute.
  ///
  /// **Prima chiedeva quale ombra era stata seguita piu' volte.** Era la
  /// seconda porta dell'animale guida: il Passaporto diceva Lupo e il Viaggio
  /// consegnava Aquila. Ordine DG voce 01.
  bool get _riconosciuto =>
      IQuattroViaggi.nomeDopoLeQuattroDiscese(
          _diario.quanteDiscese, _suoAnimale.name) !=
      null;

  /// **IL PIANO DI CHI STA GUARDANDO, e il Viaggio regge di non saperlo.**
  /// Ordine DE voce 14.
  ///
  /// **Si chiede col `try`, e non si pretende.** E' la lezione del provider
  /// preteso: un `context.read` obbligatorio dentro una schermata condivisa ha
  /// gia' fatto cadere quaranta prove altrove. Quando il servizio non c'e' si
  /// vale il gratuito, che e' il piano piu' severo: **sbagliare per eccesso di
  /// limite non regala niente a nessuno**, sbagliare per difetto sì.
  Tier get _piano {
    try {
      return context.read<EntitlementService>().tier;
    } catch (errore) {
      return Tier.free;
    }
  }

  /// **IL DITO PREME: si scende.** Ordine DC voce 07.
  void _premi() {
    _discesa?.cancel();
    const passo = Duration(milliseconds: 60);
    _discesa = Timer.periodic(passo, (t) {
      if (!mounted) return t.cancel();
      setState(() {
        _scesi = (_scesi + passo.inMilliseconds / _quantoDura.inMilliseconds)
            .clamp(0.0, 1.0);
        if (_scesi >= 1.0) {
          t.cancel();
          _fase = FaseDelViaggio.nebbia;
          _nebbia = 0;
          _spintaDelDito = 0;
          // **LA GALLERIA NON SPARISCE, SI DISSOLVE.** Ordine DG voce 09.
          _entraLaNebbia = 0;
          _accendiLaDissolvenza();
          _respiro?.cancel();
          _respiro = Timer.periodic(RespiroCheDirada.passo, _unRespiroDiNebbia);
          unawaited(PaletteSensoriale.vibra(context, SchemaAptico.tocco));
        }
      });
    });
  }

  /// **ACCENDE LA DISSOLVENZA CHE INTRODUCE LA NEBBIA.** Ordine DG voce 09.
  ///
  /// Il passo e' lo stesso battito da sessanta millisecondi della discesa: un
  /// solo ritmo in tutta la scena, e nessun orologio nuovo da tenere a mente.
  void _accendiLaDissolvenza() {
    _dissolvenza?.cancel();
    const passo = Duration(milliseconds: 60);
    _dissolvenza = Timer.periodic(passo, (t) {
      if (!mounted) return t.cancel();
      setState(() {
        _entraLaNebbia = (_entraLaNebbia +
                passo.inMilliseconds /
                    ViaggioDelloSciamanoScreen
                        .quantoDuraLaDissolvenza.inMilliseconds)
            .clamp(0.0, 1.0);
        if (_entraLaNebbia >= 1.0) t.cancel();
      });
    });
  }

  /// **IL DITO SI ALZA: ci si ferma.** Non si torna su: si resta dove si e'.
  void _lascia() {
    _discesa?.cancel();
    _discesa = null;
  }

  /// **IL COMANDO DI DEMO, ordine DG voce 08.** Riporta il Viaggio a zero
  /// discese senza toccare account ne' cammino: vedi
  /// `DiarioDeiViaggi.ricomincia`.
  Future<void> _ricominciaInDemo() async {
    final fatto = await _diario.ricomincia();
    if (!fatto || !mounted) return;
    setState(() {
      _fase = FaseDelViaggio.soglia;
      _seguito = null;
      _scena = null;
      _nebbia = 0;
      _spintaDelDito = 0;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Il viaggio riparte da zero discese.'),
      duration: Duration(seconds: 2),
    ));
  }

  void _fermaIlRespiro() {
    _respiro?.cancel();
    _respiro = null;
  }

  /// **LA MANO DIRADA LA NEBBIA, E NON A TOCCHI.** Ordine DG voce 05,
  /// 11 settembre 2026.
  ///
  /// **Qui c'erano tre tocchi**: ognuno depositava un varco e al terzo si
  /// passava oltre. Il fondatore li ha contati: *"per diradare la nebbia devo
  /// fare 3 tap con grafica di merda e non un movimento continuo come per il
  /// dono sigillo del sogno che il diradamento e' fatto bene"*.
  ///
  /// **La taratura viene da li' e non e' stata reinventata**: vive in
  /// `RespiroCheDirada`, che e' la stessa casa da cui la legge il Sigillo del
  /// Sogno.
  void _ilDitoDirada(double distanza) {
    _spintaDelDito = RespiroCheDirada.spintaDopo(_spintaDelDito, distanza);
  }

  void _unRespiroDiNebbia(Timer _) {
    if (_fase != FaseDelViaggio.nebbia || !mounted) return;
    final prima = _nebbia;
    final (aperta, spinta) = RespiroCheDirada.unPasso(_nebbia, _spintaDelDito);
    _nebbia = aperta;
    _spintaDelDito = spinta;
    if (_nebbia >= 1 && prima < 1) {
      _respiro?.cancel();
      _respiro = null;
      setState(() => _fase = FaseDelViaggio.incontro);
    } else if (_nebbia != prima) {
      setState(() {});
    }
  }

  /// **SI SEGUE UN'OMBRA, E SI VA A GUARDARLA DA VICINO.**
  /// Ordine DE voce 03.
  ///
  /// **Prima la scelta si depositava subito e si risaliva**: seguivi un'ombra
  /// e ti ritrovavi il testo del ritorno. Adesso fra le due cose c'e' la
  /// lente, che e' il momento in cui quell'ombra smette di essere una massa
  /// scura e diventa **zampe, manto, collo**, un pezzo per discesa.
  void _segui(String nome) {
    setState(() {
      _seguito = nome;
      _fase = FaseDelViaggio.lente;
    });
  }

  /// **L'ARTICOLO DEL NOME**, ordine DE voce 08. Nel dubbio maschile, che e'
  /// il caso di otto animali su dodici: un nome che il catalogo non conosce
  /// non deve far cadere la schermata della rivelazione.
  String _articoloDi(String nome) => _animale(nome)?.articolo ?? 'il ';

  /// **IL PRONOME DEL NOME**, stessa legge dell'articolo.
  String _pronomeDi(String nome) => _animale(nome)?.pronome ?? 'lo';

  /// **L'ILLUSTRAZIONE VERA DI UN NOME**, o nulla se quel nome non ha arte.
  GuideAnimal? _animale(String? nome) {
    if (nome == null) return null;
    for (final a in AnimalCatalog.animals) {
      if (a.name == nome) return a;
    }
    return null;
  }

  /// **SI RISALE, E SOLO ADESSO LA SCELTA SI DEPOSITA.**
  ///
  /// **La discesa vale quando e' finita**, ed e' la stessa legge che la
  /// Meditazione ha imparato nell'ordine DD: fermarsi a meta' non e'
  /// compiere. Chi chiude l'app davanti alla lente non ha bruciato la sua
  /// discesa del giorno.
  Future<void> _risaliDallaLente() async {
    final nome = _seguito;
    if (nome == null) return;
    final quante = _diario.quanteDiscese;
    final nitidezza =
        NitidezzaDellaScena.dopoGiorni(_diario.giorniDiDistanza ?? 0);
    final domanda = LaDomandaDelViaggio.oppureIlMomento(_domanda.text);
    // **LA VIA DI SOTTO, e per adesso e' l'unica montata.** Ordine DC voce 06:
    // la scelta dei tre elementi la fa Gemini, e quando non arriva si cade su
    // questa composizione deterministica. **La porta al modello non e' ancora
    // aperta**, ed e' dichiarato nel manifesto: quello che c'e' oggi e' il
    // ripiego, che l'ordine vuole comunque esistente e provato.
    final scena = ScenaSenzaModello.componi(
      domanda: domanda,
      giorno: _adesso,
      nitidezza: nitidezza,
      // **IL NUMERO DELLA DISCESA ENTRA NEL SEME.** Ordine DF voce 05: senza,
      // due discese nello stesso giorno con la stessa domanda riportavano su
      // **la stessa identica scena**, parola per parola.
      discesa: quante,
    );
    _giornoDellaScena = _adesso;
    await _diario.segna(UnViaggio(
      quando: _adesso,
      domanda: domanda,
      temaDellaDomanda: _temaScelto,
      pezzi: scena.idDeiPezzi,
      animaleSeguito: nome,
      nitidezza: nitidezza,
    ));
    // **IL RICHIAMO: questa scena riprende un elemento di una di prima?**
    // Ordine DE voce 11. Si guarda **cinque scene indietro** e non di piu':
    // il richiamo funziona solo se la persona si ricorda di aver visto quella
    // cosa, e cio' che si ricorda di un'immagine simbolica dura poche
    // settimane.
    _ilRichiamo = IlRichiamoDelleScene.laRiga(
      precedenti: [for (final v in _diario.viaggi) v.pezzi],
      oggi: scena.idDeiPezzi,
      nomeDellElemento: scena.cosa.nome,
      quale: 1,
    );
    if (!mounted) return;
    setState(() {
      _scena = scena;
      _fase = FaseDelViaggio.risalita;
    });
    // **IL VERSO, NELL'ISTANTE IN CUI LA TESTA E' USCITA DAL VELO.**
    // Ordine DE voce 07. Una volta sola nella vita, e solo alla rivelazione:
    // le tre porte le tiene `IlVersoDellAnimale`, e se i dodici file non sono
    // nel pacchetto il momento **resta muto** invece di prendere in prestito
    // un ululato che non e' il suo.
    final suo = _suoAnimale;
    if (true) {
      unawaited(
          IlVersoDellAnimale.faiSentire(suo, eLaRivelazione: _riconosciuto)
              .then((udito) {
        // **OGGI QUESTO E SEMPRE FALSO, ed e giusto cosi.** I dodici file non
        // sono nel pacchetto: il momento resta muto invece di prendere in
        // prestito un ululato che non e il suo. Vedi
        // assets/audio/animali/LEGGIMI.md.
        debugPrint('Ordine DE voce 07: verso udito = $udito');
      }));
    }
    // **IL CAMMINO SE NE ACCORGE**, e il gesto porta il suo dettaglio: e' la
    // stessa porta che la Meditazione usa dall'ordine DC voce 06.
    if (mounted) {
      unawaited(RegiaDelCammino.dopoUnGesto(context, 'animale_guida',
          dettagli: {'animale': nome, 'discesa': quante + 1}));
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.caligo));
    return Scaffold(
      backgroundColor: PittoreDelTunnel.bluProfondo,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        // **IL TITOLO NON SI TRONCA.** Difetto visto sul telefono 767f596c:
        // la barra mostrava "IL VIAGGIO DELL...". Il componente di casa lo
        // manda a capo invece di tagliarlo, e non lo rimpicciolisce sotto il
        // pavimento tipografico.
        title: TitoloCheNonSiRompe(
          testo: 'Il Viaggio dello Sciamano',
          stile:
              TypographyTokens.titoloScheda().copyWith(color: palette.goldSoft),
        ),
        actions: [
          FoglioDelleFonti.bottone(context,
              palette: palette, testo: _fonti, chiave: 'viaggio_fonti'),
          const AngoloDellaBarra(),
        ],
      ),
      // **LA BARRA STA SOPRA LA SCENA SOLO DOVE LA SCENA E' UNA SCENA.**
      //
      // Due difetti visti sul telefono 767f596c il 10 settembre 2026, e il
      // secondo l'ha fatto la cura del primo. Prima: la barra stava sempre
      // sopra il corpo, e la prima riga della soglia, "Non sei ancora
      // sceso.", finiva **sopra il titolo**. Poi, tolto lo sconfinamento
      // dappertutto, **il tunnel ha perso la sua fascia in alto**: sopra la
      // galleria c'era una striscia di pagina alta quanto la barra.
      //
      // Il confine non e' lo schermo, e' **la fase**: dove si legge un testo
      // la barra ha il suo posto, dove si sta dentro una scena il corpo
      // passa sotto.
      extendBodyBehindAppBar: _laScenaEPiena,
      body: SafeArea(
        top: false,
        child: switch (_fase) {
          FaseDelViaggio.soglia => _laSoglia(palette),
          FaseDelViaggio.discesa => _laDiscesa(palette),
          FaseDelViaggio.nebbia => _laNebbia(palette),
          FaseDelViaggio.incontro => _lIncontro(palette),
          FaseDelViaggio.lente => _laLente(palette),
          FaseDelViaggio.risalita => _laRisalita(palette),
        },
      ),
    );
  }

  /// **LA SOGLIA: il colpo d'occhio, la promessa, la domanda.**
  ///
  /// **RIFATTA IL 10 SETTEMBRE 2026, e la causa e' una frase del fondatore
  /// davanti alla fotografia della voce DC.21**: *"l'utente e' gia' scappato
  /// prima ancora di leggere. Solo testo da leggere, nessuna vena artistica,
  /// nessuna immagine o riquadro che metta in evidenza o guidi l'utente.
  /// Niente di attraente a primo impatto, niente che faccia capire di cosa si
  /// tratta a primo impatto. Le domande buttate li'."*
  ///
  /// **Aveva ragione su tre leggi di casa insieme.** L'anatomia del responso a
  /// quattro strati vuole **il livello visivo PRIMA del testo**, e qui il
  /// primo strato era un paragrafo. La regola dell'ordine AS vuole **meno
  /// testo e piu' diretto**, e qui c'erano tre paragrafi prima di qualunque
  /// cosa si potesse toccare. E le sei domande erano **sei pulsanti di testo
  /// in colonna**, senza un riquadro, senza uno stato acceso, senza niente
  /// che dicesse che erano una scelta.
  ///
  /// **La forma nuova, in quattro pezzi.**
  ///
  /// **Uno, la bocca del tunnel.** La prima cosa che si vede e' la scena, non
  /// una frase: il pittore della discesa a quota zero, che e' esattamente
  /// l'apertura nella terra da cui si scende, con dentro l'occhiello e la
  /// promessa. **La stessa immagine che si vedra' scendendo**, cosi' il colpo
  /// d'occhio non e' una decorazione: e' un'anticipazione vera.
  ///
  /// **Due, i quattro segni.** A che punto si e' non e' piu' una frase in
  /// cima: sono quattro tacche sotto la bocca, accese quante sono le discese.
  /// La frase resta, sotto, per chi legge.
  ///
  /// **Tre, le tre vie, dichiarate come tre.** Scegli una domanda, scrivila
  /// tu, scendi soltanto per incontrarlo. Prima erano un campo di testo, sei
  /// pulsanti e una settima riga, tutti allo stesso livello: chi guardava non
  /// poteva sapere che erano tre strade diverse.
  ///
  /// **Quattro, il pulsante pieno.** Era un contorno in fondo a una colonna
  /// lunga, e a colonna scorsa non si vedeva nemmeno.
  Widget _laSoglia(MaestroPalette palette) {
    final primo = _diario.quanteDiscese == 0;
    final perche =
        LaDomandaDelViaggio.perCheNonVa(_domanda.text, primoViaggio: primo);
    // **IL TETTO LO DECIDONO I TETTI, ordine DE voce 14.** Prima era una
    // discesa al giorno e basta, e dopo la rivelazione nessun limite di
    // nessun genere: chi aveva il nome poteva fare mille domande al giorno
    // senza pagare niente.
    final siPuo = _caricato &&
        TettiDelViaggio.siPuoScendere(
          giaRiconosciuto: _riconosciuto,
          quanteOggi: _diario.quanteOggi,
          tier: _piano,
        );
    final percheNoOggi = TettiDelViaggio.percheNonOggi(
      giaRiconosciuto: _riconosciuto,
      quanteOggi: _diario.quanteOggi,
      tier: _piano,
    );
    final pronto = siPuo && (perche == null || _temaScelto.isNotEmpty);
    final schermo = MediaQuery.of(context).size;
    // **QUANTO SPAZIO SI LASCIA IN CIMA**, cioe' la barra piu' la tacca del
    // telefono: il corpo passa **sotto** la barra perche' la scena deve
    // arrivare fino in alto, e il testo non deve finirci dentro. E' lo stesso
    // difetto che il tunnel ha avuto nell'ordine DC, a rovescio.
    final quantoInCima = MediaQuery.of(context).padding.top + kToolbarHeight;
    return Stack(
      fit: StackFit.expand,
      children: [
        // **LA SCENA A SCHERMO PIENO**, ordine DE voce 01. L'immagine vera
        // quando c'e', il bosco dipinto finche' non c'e': lo slot e' lo
        // stesso di prima, e' il riquadro che non c'e' piu'.
        const Positioned.fill(
          child: SfondoDelMondoDiSotto(key: Key('viaggio_bosco')),
        ),
        // **I DODICI PASSANO NELLA FASCIA ALTA, dove il bosco e' leggibile.**
        Positioned(
          top: quantoInCima + SpacingTokens.lg,
          left: 0,
          right: 0,
          child: GirandolaDegliAnimali(altezza: schermo.height * 0.16),
        ),
        // **IL VELO DAL BASSO.** La meta' bassa della scena e' quasi pura
        // oscurita', e il testo ci si legge sopra senza nessun fondo scuro
        // aggiuntivo: e' la riga dell'ordine, ed e' anche il motivo per cui
        // le sei domande non hanno piu' bisogno di un riquadro ognuna.
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x00060410),
                  Color(0x00060410),
                  Color(0xCC060410),
                  Color(0xF5060410),
                ],
                stops: [0.0, 0.30, 0.52, 0.78],
              ),
            ),
          ),
        ),
        // **LA LISTA COMINCIA SOTTO LA BARRA, e non dietro.** Collaudo a video
        // della 2249, 12 settembre 2026: la lista occupava tutto lo schermo,
        // barra compresa, e partiva piu' in basso solo per un margine. Appena
        // si scorreva, il testo saliva sotto la barra trasparente e ci si
        // sovrapponeva: si leggeva *"Dodici ti aspettano"* sopra *"Il Viaggio
        // dello Sciamano"*.
        //
        // **La scena resta a tutto schermo**, com'e' dall'ordine DE voce 01:
        // e' la lista che scorre a fermarsi al bordo della barra, e una lista
        // che scorre taglia da se' cio' che esce dalla sua finestra.
        Positioned(
          top: quantoInCima,
          left: 0,
          right: 0,
          bottom: 0,
          child: SingleChildScrollView(
            key: const Key('viaggio_soglia_scorre'),
            padding: const EdgeInsets.fromLTRB(SpacingTokens.lg,
                SpacingTokens.lg, SpacingTokens.lg, SpacingTokens.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Lo spazio della fascia alta, dove passano i dodici: il testo
                // comincia sotto di loro.
                SizedBox(height: schermo.height * 0.22),
                _laPromessaDellaSoglia(palette, primo: primo),
                const SizedBox(height: SpacingTokens.lg),
                // **A CHE PUNTO SEI, in quattro segni prima che in una frase.**
                _iQuattroSegni(palette),
                const SizedBox(height: SpacingTokens.sm),
                Text(
                  IQuattroViaggi.aChePunto(_diario.quanteDiscese),
                  key: const Key('viaggio_a_che_punto'),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.didascalia()
                      .copyWith(color: ColorTokens.textSecondary),
                ),
                // **SI RICOMINCIA DA CAPO, E SOLO IN DEMO.** Ordine DG voce 08.
                //
                // **Sta qui e non nelle impostazioni** perche' e' qui che si
                // guarda quante discese mancano: il comando che le riporta a
                // zero deve stare accanto al numero che azzera, non tre
                // schermate piu' in la'.
                if (AppFlags.isDemo && _diario.quanteDiscese > 0) ...[
                  const SizedBox(height: SpacingTokens.sm),
                  TextButton.icon(
                    key: const Key('viaggio_ricomincia_demo'),
                    onPressed: _ricominciaInDemo,
                    icon: const Icon(Icons.restart_alt_rounded, size: 18),
                    label: const Text('Ricomincia il viaggio (Demo)'),
                    style: TextButton.styleFrom(
                        foregroundColor: ColorTokens.textSecondary),
                  ),
                ],
                // **L'AVVISO DELL'ANIMALE LONTANO STA ALL'APERTURA**, sopra
                // la scelta della domanda: chi legge deve saperlo **prima** di
                // scegliere con che cosa scendere, non dopo essere risalito.
                if (_laDistanza(palette) != null) ...[
                  const SizedBox(height: SpacingTokens.lg),
                  _laDistanza(palette)!,
                ],
                const SizedBox(height: SpacingTokens.xl),
                _leTreVie(palette, primo: primo),
                if (perche != null && _temaScelto.isEmpty) ...[
                  const SizedBox(height: SpacingTokens.sm),
                  Text(perche,
                      key: const Key('viaggio_perche_non_si_scende'),
                      textAlign: TextAlign.center,
                      style: TypographyTokens.didascalia()
                          .copyWith(color: palette.goldSoft)),
                ],
                if (!siPuo && _caricato) ...[
                  const SizedBox(height: SpacingTokens.md),
                  DepthCard(
                    padding: const EdgeInsets.all(SpacingTokens.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // **LA RIGA DEL TETTO DI OGGI**, che dice quale dei due
                        // limiti ha parlato: il metodo oppure il piano.
                        if (percheNoOggi != null)
                          ParagrafiDiLettura(
                            key: const Key('viaggio_tetto_di_oggi'),
                            testo: percheNoOggi,
                            stile: TypographyTokens.lettura()
                                .copyWith(color: palette.goldSoft),
                          ),
                        if (percheNoOggi != null)
                          const SizedBox(height: SpacingTokens.sm),
                        // **E LA FONTE DELL'ATTESA**, che resta e vale solo per
                        // chi non ha ancora riconosciuto: a chi ha finito le
                        // domande del piano, citare Harner sarebbe una scusa.
                        if (!_riconosciuto)
                          ParagrafiDiLettura(
                            key: const Key('viaggio_non_oggi'),
                            testo: IQuattroViaggi.percheSiAspetta,
                            stile: TypographyTokens.lettura()
                                .copyWith(color: ColorTokens.textSecondary),
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: SpacingTokens.lg),
                FilledButton.icon(
                  key: const Key('viaggio_scendi'),
                  onPressed: pronto
                      ? () => setState(() => _fase = FaseDelViaggio.discesa)
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.primary,
                    foregroundColor: palette.onPrimary,
                    minimumSize: const Size.fromHeight(56),
                  ),
                  icon: const Icon(Icons.south_rounded),
                  label: Text('Scendi', style: TypographyTokens.etichetta()),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// **QUANTO E' LONTANO L'ANIMALE ADESSO.** Ordine DE voce 12.
  double get _quantoELontano =>
      NitidezzaDellaScena.dopoGiorni(_diario.giorniDiDistanza ?? 0);

  /// **IL TAMBURO, e la nitidezza migliora subito di un passo.**
  /// Ordine DE voce 12.
  Future<void> _battiIlTamburo() async {
    if (!_diario.siPuoNutrireOggi()) return;
    await _diario.nutri();
    if (!mounted) return;
    // **IL GESTO SI SENTE.** Un tamburo che non si sente sotto il dito e' un
    // pulsante qualunque, e questo non e' un pulsante qualunque: e' l'unica
    // via del ritorno che questa funzione ha.
    unawaited(PaletteSensoriale.vibra(context, SchemaAptico.tocco));
    setState(() {});
  }

  /// **L'AVVISO DELL'ANIMALE LONTANO, all'apertura.** Ordine DE voce 12.
  ///
  /// **CHE COSA C'ERA PRIMA, sotto la Regola D.** La riga della nitidezza
  /// esisteva gia' dall'ordine DC voce 08, e si leggeva **solo alla
  /// risalita**, cioe' **dopo** essere sceso: chi apriva la soglia dopo tre
  /// settimane non sapeva niente, scendeva, e solo in fondo scopriva che la
  /// scena sarebbe stata confusa. Un avviso che arriva dopo il fatto non e'
  /// un avviso.
  ///
  /// **CONSTATAZIONE, MAI RIMPROVERO**, ed e' la riga dell'ordine: non *"non
  /// ti sei preso cura di lui"*, che e' una colpa e fa chiudere l'app, ma
  /// *"e' lontano, e da lontano si sente poco"*.
  ///
  /// **E ACCANTO C'E' SEMPRE LA VIA DEL RITORNO.** Un avviso senza rimedio
  /// e' solo una brutta notizia.
  Widget? _laDistanza(MaestroPalette palette) {
    final riga = NitidezzaDellaScena.laRiga(_quantoELontano);
    if (riga == null) return null;
    final siPuo = _diario.siPuoNutrireOggi();
    return DepthCard(
      key: const Key('viaggio_animale_lontano'),
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ParagrafiDiLettura(
            key: const Key('viaggio_lontano_riga'),
            testo: riga,
            stile: TypographyTokens.lettura().copyWith(color: palette.goldSoft),
          ),
          const SizedBox(height: SpacingTokens.xs),
          // **E SI DICHIARA APERTAMENTE CHE FUNZIONA COSI'.** Ordine DE voce
          // 12: *"una funzione che peggiora in silenzio e' una funzione
          // rotta"*.
          Text(
            'Da lontano si sente poco: la scena che riporti su ha meno '
            'elementi leggibili.',
            key: const Key('viaggio_lontano_dichiarato'),
            style: TypographyTokens.didascalia()
                .copyWith(color: ColorTokens.textSecondary),
          ),
          const SizedBox(height: SpacingTokens.sm),
          OutlinedButton.icon(
            key: const Key('viaggio_tamburo'),
            onPressed: siPuo ? () => unawaited(_battiIlTamburo()) : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: palette.gold,
              side: BorderSide(color: palette.gold.withValues(alpha: 0.55)),
              minimumSize: const Size.fromHeight(48),
            ),
            icon: const Icon(Icons.graphic_eq_rounded),
            label: Text(
              siPuo ? 'Richiamalo col tamburo' : 'Lo hai richiamato oggi',
              style: TypographyTokens.etichetta(),
            ),
          ),
        ],
      ),
    );
  }

  /// **LA PROMESSA SULLA SOGLIA, e prima della prima discesa sono tre righe.**
  /// Ordine DE voce 02.
  ///
  /// *"Sulla soglia, prima della prima discesa, la persona deve sapere tre
  /// cose, dette come promessa e mai come compito: che in quattro discese
  /// conoscera' il nome del suo animale, che quell'animale restera' con lei da
  /// li' in avanti, e che potra' consultarlo e prendersene cura."*
  ///
  /// **Dalla seconda discesa in poi le tre righe spariscono**: chi e' gia'
  /// sceso le ha gia' lette, e ripetere una promessa a chi l'ha gia' accettata
  /// e' il modo piu' rapido di farla sembrare una reclame.
  Widget _laPromessaDellaSoglia(MaestroPalette palette, {required bool primo}) {
    const tre = LaPromessaDelViaggio.treCoseDaSapere;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'IL MONDO DI SOTTO',
          style: TypographyTokens.etichetta()
              .copyWith(color: palette.goldSoft, letterSpacing: 2.4),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          LaPromessaDelViaggio.descrizionePer(_diario.quanteDiscese),
          key: const Key('viaggio_promessa'),
          style: TypographyTokens.titoloScheda()
              .copyWith(color: ColorTokens.textPrimary),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          'Dodici ti aspettano. Uno verrà con te.',
          key: const Key('viaggio_i_dodici'),
          style:
              TypographyTokens.didascalia().copyWith(color: palette.goldSoft),
        ),
        if (primo) ...[
          const SizedBox(height: SpacingTokens.md),
          for (var i = 0; i < tre.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Icon(Icons.circle,
                        size: 5, color: palette.gold.withValues(alpha: 0.8)),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: Text(
                      tre[i],
                      key: Key('viaggio_promessa_$i'),
                      style: TypographyTokens.corpo()
                          .copyWith(color: ColorTokens.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }

  // **IL BOSCO NEL RIQUADRO NON C'E' PIU'.** Ordine DE voce 01, 11 settembre
  // 2026. Qui viveva '_ilBoscoDellaSoglia', un ClipRRect con un AspectRatio
  // 1.15 che teneva la scena dentro una card in cima a una colonna che
  // scorreva. Il fondatore: *"la soglia esce dal riquadro e diventa una scena
  // piena"*. Adesso lo sfondo, i dodici e il velo stanno in '_laSoglia', e
  // sono uno Stack che riempie la finestra invece di una riga della colonna.
  //
  // **Non si e' perso niente**: i tre pezzi sono gli stessi tre, e lo slot
  // dell'immagine e' sempre 'SfondoDelMondoDiSotto'.

  /// **IL CAMMINO DELLE QUATTRO IMPRONTE.** Ordine DE voce 09.
  ///
  /// **CHE COSA C'ERA PRIMA, sotto la Regola D.** Quattro trattini d'oro in
  /// fila, accesi quanti erano i viaggi: dicevano a che punto si e' ed erano
  /// **una barra di avanzamento**, cioe' proprio la cosa che l'ordine DC voce
  /// 04 aveva vietato al Passaporto.
  ///
  /// **Adesso sono un percorso che sale verso dove l'animale aspetta**, e
  /// ogni impronta e' la sagoma vera dell'ombra seguita quella volta. La
  /// frase che dice a che punto si e' resta sotto, per chi legge: la voce
  /// DC.04 la vuole, e un disegno non e' un testo.
  Widget _iQuattroSegni(MaestroPalette palette) => LeQuattroImpronte(
        key: const Key('viaggio_i_quattro_segni'),
        seguiti: _diario.scelteInOrdine,
        riconosciuto: _riconosciuto,
      );

  /// **LE TRE VIE, dichiarate come tre.**
  ///
  /// Un selettore in cima dice quante sono e quale si sta usando, e sotto si
  /// apre soltanto quella scelta. Prima erano un campo, sei pulsanti di testo
  /// e una settima riga, tutti allo stesso livello: **chi guardava non poteva
  /// sapere che erano tre strade diverse**, e infatti il fondatore le ha viste
  /// come domande buttate li'.
  Widget _leTreVie(MaestroPalette palette, {required bool primo}) {
    final vie = [
      (ViaDellaDomanda.scelta, 'Scegli'),
      (ViaDellaDomanda.scritta, 'Scrivila tu'),
      (ViaDellaDomanda.incontro, 'Solo incontro'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'CON CHE COSA SCENDI',
          style: TypographyTokens.etichetta()
              .copyWith(color: palette.goldSoft, letterSpacing: 2.0),
        ),
        if (!primo) ...[
          const SizedBox(height: 2),
          Text(
            'Dal secondo viaggio la domanda è la porta.',
            style: TypographyTokens.didascalia()
                .copyWith(color: ColorTokens.textSecondary),
          ),
        ],
        const SizedBox(height: SpacingTokens.sm),
        SegmentedButton<ViaDellaDomanda>(
          key: const Key('viaggio_le_tre_vie'),
          segments: [
            for (final v in vie)
              ButtonSegment<ViaDellaDomanda>(
                  value: v.$1,
                  label: Text(v.$2, style: TypographyTokens.didascalia())),
          ],
          selected: {_via},
          showSelectedIcon: false,
          // **IL SELETTORE HA IL COLORE DEL MAESTRO.** Con lo stile di
          // fabbrica la voce scelta era grigio lavanda su un dominio rosso e
          // oro: sul telefono si leggeva come un pezzo di un'altra app.
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((stati) =>
                stati.contains(WidgetState.selected)
                    ? palette.gold.withValues(alpha: 0.34)
                    : Colors.transparent),
            foregroundColor: WidgetStateProperty.resolveWith((stati) =>
                stati.contains(WidgetState.selected)
                    ? palette.gold
                    : palette.goldSoft.withValues(alpha: 0.75)),
            side: WidgetStatePropertyAll(
                BorderSide(color: palette.gold.withValues(alpha: 0.45))),
          ),
          onSelectionChanged: (scelte) => setState(() {
            _via = scelte.first;
            _domanda.clear();
            _temaScelto = _via == ViaDellaDomanda.incontro
                ? LaDomandaDelViaggio.idSoloPerIncontrarlo
                : '';
          }),
        ),
        const SizedBox(height: SpacingTokens.md),
        switch (_via) {
          ViaDellaDomanda.scelta => _leSeiDomande(palette),
          ViaDellaDomanda.scritta => _ilCampoLibero(palette, primo: primo),
          ViaDellaDomanda.incontro => DepthCard(
              key: const Key('viaggio_solo_incontro'),
              padding: const EdgeInsets.all(SpacingTokens.md),
              child: ParagrafiDiLettura(
                testo: 'Scendo soltanto per incontrarlo. La scena parlerà '
                    'del momento che stai vivendo.',
                stile: TypographyTokens.lettura()
                    .copyWith(color: ColorTokens.textSecondary),
              ),
            ),
        },
      ],
    );
  }

  /// **LE SEI DOMANDE, come sei riquadri toccabili.**
  ///
  /// Quello scelto si accende. Prima erano sei righe di testo identiche a
  /// qualunque altra riga di testo della schermata.
  Widget _leSeiDomande(MaestroPalette palette) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final d in LaDomandaDelViaggio.gliaScritte) ...[
            _unaDomanda(palette, d),
            const SizedBox(height: SpacingTokens.xs),
          ],
        ],
      );

  Widget _unaDomanda(MaestroPalette palette, DomandaScritta d) {
    final scelta = _temaScelto == d.tema;
    return Material(
      color: scelta
          ? palette.gold.withValues(alpha: 0.16)
          : Colors.white.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
      child: InkWell(
        key: Key('viaggio_domanda_${d.id}'),
        // **NIENTE CLICK DI SISTEMA.** Ordine CQ voce 1.08: il Cerchio ha le
        // sue voci, e il tocco di fabbrica di Android non e' una di quelle.
        enableFeedback: false,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        onTap: () => setState(() {
          _domanda.text = d.testo;
          _temaScelto = d.tema;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            border: Border.all(
                color: scelta
                    ? palette.gold
                    : palette.gold.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Icon(
                scelta
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 18,
                color: scelta
                    ? palette.gold
                    : palette.goldSoft.withValues(alpha: 0.5),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.tema,
                        style: TypographyTokens.corpo()
                            .copyWith(color: ColorTokens.textPrimary)),
                    if (scelta) ...[
                      const SizedBox(height: 2),
                      Text(d.testo,
                          style: TypographyTokens.didascalia()
                              .copyWith(color: palette.goldSoft)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// **IL CAMPO LIBERO, con una cornice sua.**
  Widget _ilCampoLibero(MaestroPalette palette, {required bool primo}) =>
      TextField(
        key: const Key('viaggio_domanda'),
        controller: _domanda,
        maxLength: LaDomandaDelViaggio.quantoPuoEssereLunga,
        maxLines: 2,
        minLines: 2,
        onChanged: (_) => setState(() => _temaScelto = ''),
        style:
            TypographyTokens.corpo().copyWith(color: ColorTokens.textPrimary),
        decoration: InputDecoration(
          hintText: primo
              ? 'Che cosa vuoi chiedere, se hai una domanda'
              : 'Che cosa vuoi chiedere',
          hintStyle: TypographyTokens.corpo()
              .copyWith(color: ColorTokens.textSecondary),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.04),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            borderSide: BorderSide(color: palette.gold.withValues(alpha: 0.22)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            borderSide: BorderSide(color: palette.gold.withValues(alpha: 0.22)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            borderSide: BorderSide(color: palette.gold),
          ),
        ),
      );

  /// **LA DISCESA: il tunnel, e risponde alla mano.**
  Widget _laDiscesa(MaestroPalette palette) => GestureDetector(
        key: const Key('viaggio_dito'),
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _premi(),
        onTapUp: (_) => _lascia(),
        onTapCancel: _lascia,
        child: Stack(
          children: [
            Positioned.fill(
              child: TunnelCheScende(quantoSiEScesi: _scesi, senzaMoto: false),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(SpacingTokens.xl),
                child: Text(
                  _discesa == null ? 'Tieni premuto per scendere' : 'Scendi',
                  key: const Key('viaggio_istruzione_discesa'),
                  style: TypographyTokens.etichetta()
                      .copyWith(color: palette.goldSoft, letterSpacing: 1.4),
                ),
              ),
            ),
          ],
        ),
      );

  /// **LA NEBBIA, che la mano apre.**
  Widget _laNebbia(MaestroPalette palette) => GestureDetector(
        key: const Key('viaggio_nebbia'),
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (d) => _ilDitoDirada(d.delta.distance),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                // Qui il vincolo e' gia' stretto e la misura non servirebbe.
                // Si scrive lo stesso: la regola vale per il componente, e
                // una regola con un'eccezione tacita e' una regola che
                // qualcuno copiera' nel posto sbagliato.
                size: Size.infinite,
                painter: PittoreDellaNebbia(
                  apertura: _nebbia,
                  senzaMoto: false,
                  densita: NitidezzaDellaScena.dopoGiorni(
                      _diario.giorniDiDistanza ?? 0),
                ),
              ),
            ),
            // **LA GALLERIA CHE SVANISCE SOPRA LA NEBBIA.** Ordine DG voce
            // 09, 12 settembre 2026: *"quando si scende, dovrebbe esserci una
            // dissolvenza che introduce la nebbia"*. Il tunnel resta fermo al
            // fondo della discesa e perde corpo, e sotto di lui c'e' gia' la
            // nebbia intera.
            if (_entraLaNebbia < 1)
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    key: const Key('viaggio_dissolvenza_della_nebbia'),
                    opacity: (1 - _entraLaNebbia).clamp(0.0, 1.0),
                    child: const TunnelCheScende(
                        quantoSiEScesi: 1, senzaMoto: true),
                  ),
                ),
              ),
            // **L'ISTRUZIONE ARRIVA A DISSOLVENZA FINITA**, non prima: dire
            // *"passa la mano"* mentre si vede ancora la galleria sarebbe dire
            // una cosa falsa.
            if (_entraLaNebbia >= 1)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(SpacingTokens.xl),
                  // **CORTA, PERCHE' E' UN'ETICHETTA.** La guardia
                  // `etichette_e_lettura` pretende una riga sola: *"Passa la
                  // mano: la nebbia si apre"* ne occupava due.
                  child: Text('Passa la mano',
                      key: const Key('viaggio_istruzione_nebbia'),
                      style: TypographyTokens.etichetta().copyWith(
                          color: palette.goldSoft, letterSpacing: 1.4)),
                ),
              ),
          ],
        ),
      );

  /// **L'INCONTRO: UNA SOLA OMBRA, ED E' SEMPRE LA SUA.** Ordine DG voce 02,
  /// 11 settembre 2026.
  ///
  /// **Qui c'erano tre ombre fra cui sceglierne una**, e le quattro scelte
  /// decidevano quale animale sarebbe stato assegnato. Era la seconda porta
  /// dell'animale guida: il Passaporto diceva Lupo e il Viaggio consegnava
  /// Aquila.
  ///
  /// **Una sola, e la ragione non e' la semplicita'.** Con l'animale deciso
  /// dalla nascita, scegliere fra tre sarebbe stata **una scelta che non
  /// cambia niente**: la persona crede di decidere e non decide, che e' peggio
  /// del non farla decidere affatto. In Harner il riconoscimento sta nel
  /// **ritorno** dell'animale, non nella selezione fra candidati.
  ///
  /// **Cosa cambia allora fra una discesa e l'altra:** quanta luce le arriva
  /// addosso, e quanto se ne scopre con la lente. Il file e' sempre lo stesso.
  Widget _lIncontro(MaestroPalette palette) {
    final suo = _suoAnimale;
    final quale = _diario.quanteDiscese;
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            key: Key('viaggio_ombra_${suo.name}'),
            behavior: HitTestBehavior.opaque,
            onTap: () => _segui(suo.name),
            // **L'OMBRA E' IL FILE DELL'ARCHITETTO**, ordine DG: la sagoma
            // esatta della sua illustrazione, col filo di luce oro sul bordo.
            // Se quel file mancasse, `OmbraDellAnimale` cadrebbe sul canale
            // alpha dell'illustrazione a colori, che e' la stessa forma.
            child: OmbraDellAnimale(
              key: Key('viaggio_sagoma_${suo.name}'),
              immagine: suo.ombraPath,
              giaSagoma: true,
              quantaLuce: 0.35 + 0.2 * quale,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: ParagrafiDiLettura(
            key: const Key('viaggio_come_si_mostra'),
            testo: IQuattroViaggi.comeSiMostraAlla(quale),
            textAlign: TextAlign.center,
            stile: TypographyTokens.lettura().copyWith(color: palette.goldSoft),
          ),
        ),
      ],
    );
  }

  /// **LA LENTE: SPOSTA E SCOPRI.** Ordine DE voce 03.
  ///
  /// L'animale occupa la scena piena sotto un velo scuro e sfocato, e il dito
  /// muove una lente che rivela in chiaro **solo cio' che copre** e **solo
  /// dentro l'area concessa a questa discesa**.
  ///
  /// **La testa non si vede prima della quarta**, e non per una regola scritta
  /// qui: per costruzione. Tutte e tre le aree stanno sotto il punto piu'
  /// basso della testa di quell'animale, e il centro della lente e' tenuto
  /// dentro l'area rientrato del proprio raggio. Vedi `DoveStaLaTesta`.
  Widget _laLente(MaestroPalette palette) {
    final quale = _diario.quanteDiscese;
    final animale = _animale(_seguito);
    if (animale == null) {
      // **UN NOME SENZA ARTE NON BLOCCA LA DISCESA**, ordine DC voce 16: si
      // risale e basta, e la scena del ritorno arriva lo stesso.
      WidgetsBinding.instance
          .addPostFrameCallback((_) => unawaited(_risaliDallaLente()));
      return const SizedBox.shrink();
    }
    return Stack(
      children: [
        Positioned.fill(
          child: LenteCheScopre(
            key: Key('viaggio_lente_${animale.name}'),
            nome: animale.name,
            immagine: animale.fullPath,
            discesa: quale,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  quale > DoveStaLaTesta.quanteFasce
                      ? 'Il velo è caduto.'
                      : quale == DoveStaLaTesta.quanteFasce
                          ? 'Oggi la lente scopre il suo volto.'
                          : 'Passa il dito: la lente scopre solo dove può, oggi.',
                  key: const Key('viaggio_istruzione_lente'),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.etichetta()
                      .copyWith(color: palette.goldSoft, letterSpacing: 1.2),
                ),
                const SizedBox(height: SpacingTokens.md),
                FilledButton.icon(
                  key: const Key('viaggio_risali'),
                  onPressed: () => unawaited(_risaliDallaLente()),
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.primary,
                    foregroundColor: palette.onPrimary,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  icon: const Icon(Icons.north_rounded),
                  label: Text('Risali', style: TypographyTokens.etichetta()),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// **LA RISALITA: la scena che si riporta su.**
  Widget _laRisalita(MaestroPalette palette) {
    final scena = _scena;
    if (scena == null) return const SizedBox.shrink();
    final nome = IQuattroViaggi.nomeDopoLeQuattroDiscese(
        _diario.quanteDiscese, _suoAnimale.name);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // **LA SCENA CHE SI RIPORTA SU HA DENTRO L'ANIMALE.**
          //
          // Difetto visto sul telefono 767f596c il 10 settembre 2026: al
          // ritorno c'era **solo testo**, e l'animale che si era appena
          // seguito non compariva da nessuna parte. La regola di casa vuole
          // il livello visivo prima del testo in ogni responso che conti, e
          // questo e' il responso del viaggio.
          //
          // **QUI VIVE LA PIENA LUCE DELLA QUARTA DISCESA**, e qui la guardia
          // misura il sessanta per cento dell'altezza: nella scena del
          // ritorno l'animale e' uno, non uno di tre.
          // **LA SCENA CHE SI RIPORTA SU HA DENTRO L'ANIMALE VERO.**
          // Ordine DE voce 03: prima era la sagoma della formula, e non era
          // il ritratto di nessuno. Adesso e' l'illustrazione, velata finche'
          // non lo si e' riconosciuto e **in piena luce alla quarta**.
          if (_animale(_seguito) != null)
            SizedBox(
              width: double.infinity,
              child: AspectRatio(
                aspectRatio: 1.35,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
                  child: _riconosciuto
                      ? Image.asset(_animale(_seguito)!.fullPath,
                          key: const Key('viaggio_animale_del_ritorno'),
                          fit: BoxFit.contain)
                      : OmbraDellAnimale(
                          key: const Key('viaggio_animale_del_ritorno'),
                          immagine: _animale(_seguito)!.fullPath,
                          quantaLuce: 0.35 +
                              0.2 * (_diario.quanteDiscese - 1).clamp(0, 3),
                        ),
                ),
              ),
            ),
          const SizedBox(height: SpacingTokens.xxl),
          // **IL TITOLO, che a colpo d'occhio e' gia' una risposta.**
          // Ordine DG voce 07, e la gerarchia e' quella dettata dal fondatore
          // il 3 settembre: *"titolo accattivante che riassume la risposta e
          // poi risposta descrittiva diretta"*.
          TitoloCheNonSiRompe(
            key: const Key('viaggio_titolo_della_risposta'),
            testo: LaVoceDelMondoDiSotto.titolo(
              scena,
              LaVoceDelMondoDiSotto.temaDi(_temaScelto),
              giornoDellaDiscesa: _giornoDellaScena,
            ),
            stile: TypographyTokens.titoloScheda()
                .copyWith(color: ColorTokens.textPrimary),
          ),
          const SizedBox(height: SpacingTokens.md),
          // **LA RISPOSTA, IL GESTO, LA FONTE**, ordine S voci 15 e 16.
          //
          // **Qui c'era `scena.testo` e basta**, cioe' una riga sola: la
          // scena senza la domanda, senza un gesto da fare e senza dire da
          // dove veniva. Parole del fondatore: *"le risposte fanno cagare,
          // scarne e non seguono le regole delle risposte"*.
          for (final paragrafo in LaVoceDelMondoDiSotto.paragrafi(
            scena: scena,
            temaDomanda: LaVoceDelMondoDiSotto.temaDi(_temaScelto),
            temaInLettere: LaVoceDelMondoDiSotto.temaInLettereDi(_temaScelto),
            giornoDellaDiscesa: _giornoDellaScena,
          )) ...[
            ParagrafiDiLettura(
              key: Key('viaggio_scena_${paragrafo.hashCode}'),
              testo: paragrafo,
              textAlign: TextAlign.center,
              stile: TypographyTokens.lettura()
                  .copyWith(color: ColorTokens.textPrimary, height: 1.5),
            ),
            const SizedBox(height: SpacingTokens.md),
          ],
          // **IL RICHIAMO SI LEGGE SUBITO SOTTO LA SCENA**, ordine DE voce
          // 11: *"quando il richiamo c'e', le due righe di Caligo lo
          // nominano, cosi' la persona capisce che non e' un caso"*.
          if (_ilRichiamo != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            ParagrafiDiLettura(
              key: const Key('viaggio_richiamo'),
              testo: _ilRichiamo!,
              textAlign: TextAlign.center,
              // **ORO CHIARO E NON ORO PIENO**, ed e la stessa lezione che il
              // censimento dei grigi aveva gia dato alla riga del nome: su un
              // fondo di Maestro l oro pieno arriva a 5,42 contro i 7,0 che il
              // corpo di lettura pretende. Misurato di nuovo qui, e lo ha
              // preso il censimento con cinque righe rosse.
              stile:
                  TypographyTokens.lettura().copyWith(color: palette.goldSoft),
            ),
          ],
          if (NitidezzaDellaScena.laRiga(scena.nitidezza) != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            // **UN TESTO DA LEGGERE PER INTERO PORTA LA MISURA DEL
            // RESPONSO**, e non quella della didascalia: due misure per lo
            // stesso genere di testo si leggono come due voci diverse.
            ParagrafiDiLettura(
                testo: NitidezzaDellaScena.laRiga(scena.nitidezza)!,
                key: const Key('viaggio_nitidezza'),
                textAlign: TextAlign.center,
                stile: TypographyTokens.lettura()
                    .copyWith(color: palette.goldSoft)),
          ],
          const SizedBox(height: SpacingTokens.lg),
          // **IL NOME SOLO ALLA QUARTA**, ordine DC voce 04.
          if (nome != null)
            ParagrafiDiLettura(
              key: const Key('viaggio_il_nome'),
              // **L'ARTICOLO E IL PRONOME VENGONO DALL'ANIMALE**, ordine DE voce
              // 08: qui c'era scritto *"E' il $nome. Adesso lo conosci"*, e sulla
              // Lince diventava *"E' il Lince"*. Vedi `GuideAnimal.articolo`.
              testo:
                  'È ${_articoloDi(nome)}$nome. Adesso ${_pronomeDi(nome)} conosci.',
              textAlign: TextAlign.center,
              // **ORO CHIARO E NON ORO PIENO**, e lo ha chiesto il censimento
              // dei grigi: su un fondo di Maestro l'oro pieno arriva a 5,42
              // contro i 7,0 che il corpo di lettura pretende.
              stile:
                  TypographyTokens.lettura().copyWith(color: palette.goldSoft),
            )
          else
            ParagrafiDiLettura(
              key: const Key('viaggio_ancora_no'),
              testo: IQuattroViaggi.aChePunto(_diario.quanteDiscese),
              textAlign: TextAlign.center,
              stile: TypographyTokens.lettura()
                  .copyWith(color: ColorTokens.textSecondary),
            ),
          // **LA CARD DELLA RIVELAZIONE, e solo alla quarta.**
          // Ordine DE voce 08. Non e' una card di risultato come le altre:
          // e' l'unica che una persona pubblica **per dire chi e'**, e per
          // questo arriva una volta sola, nel momento in cui il nome si e'
          // appena saputo.
          if (nome != null && _animale(nome) != null) ...[
            const SizedBox(height: SpacingTokens.lg),
            Center(
              child: RepaintBoundary(
                key: _cornice,
                child: CardDellaRivelazione(
                  animale: _animale(nome)!,
                  quando: _adesso,
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            OutlinedButton.icon(
              key: const Key('viaggio_condividi_rivelazione'),
              onPressed: () => unawaited(_condividiLaRivelazione(nome)),
              style: OutlinedButton.styleFrom(
                foregroundColor: palette.goldSoft,
                side: BorderSide(color: palette.gold.withValues(alpha: 0.6)),
                minimumSize: const Size.fromHeight(48),
              ),
              icon: const Icon(Icons.ios_share_rounded, size: 18),
              label: Text('Di\' chi sei', style: TypographyTokens.etichetta()),
            ),
          ],
          if (_seguito != null) const SizedBox(height: SpacingTokens.md),
        ],
      ),
    );
  }

  /// **SPEDISCE LA CARD DELLA RIVELAZIONE, dal punto unico.**
  /// Ordine DE voce 08, ordine P voce 28.
  Future<void> _condividiLaRivelazione(String nome) async {
    final andata = await condividiLaRivelazione(
      boundaryKey: _cornice,
      // **Il testo che accompagna dice la stessa cosa della card**, cosi' chi
      // la riceve in una chat che non mostra le immagini capisce lo stesso.
      testo: 'Mi ha trovato $nome.',
    );
    if (!mounted || !andata) return;
    // **IL PREMIO SI PAGA SOLO A CONDIVISIONE AVVENUTA**, ed e' il motivo per
    // cui la porta torna un booleano invece di non tornare niente.
    unawaited(RegiaDelCammino.dopoUnGesto(context, 'condivisione',
        dettagli: {'cosa': 'rivelazione', 'animale': nome}));
  }

  /// **LE FONTI, tutte e due nominate.** Ordine DC voce 01.
  static const String _fonti =
      'Il metodo del viaggio viene dal core shamanism di Michael Harner, The '
      'Way of the Shaman, 1980: si scende da un\'apertura nella terra, si '
      'incontra un animale. Lo si riconosce quando si è mostrato almeno '
      'quattro volte.\n\n'
      'La cosmologia dei tre mondi, con il Mondo di Sotto raggiunto per un '
      'tunnel, è documentata da Mircea Eliade in Le Chamanisme et les '
      'techniques archaiques de l\'extase, 1951.\n\n'
      'Il viaggio è un\'esperienza di immaginazione guidata dentro una '
      'cornice di crescita personale. Non è una pratica clinica e non '
      'sostituisce nessuna cura.';
}

/// Il catalogo degli animali, per chi legge questa schermata: sta qui solo
/// come promemoria del fatto che le ombre vengono da li' e non da un elenco
/// scritto a mano.
List<GuideAnimal> get animaliDelCerchio => AnimalCatalog.animals;
