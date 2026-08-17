import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../core/astro/natal_chart_controller.dart';
import '../../core/entitlement/question_allowance.dart';
import '../../core/entitlement/registro_degli_eos.dart';
import '../../core/sigilli/bonus_della_condivisione.dart';
import '../../core/sigilli/coda_delle_feste.dart';
import '../../core/sigilli/diario_del_cammino.dart';
import '../../core/sigilli/pezzi_dell_identita.dart';
import '../../core/sigilli/sentieri.dart';
import '../../design_system/components/volo_degli_eos.dart';
import '../../services/app_services.dart';
import 'celebrazione.dart';

/// UNA SCATOLA PER UN NUMERO CHE ARRIVA DOPO.
///
/// La festa parte prima che il server risponda, e il volo degli Eos parte quando
/// la festa se ne va: fra i due momenti c'e' l'accredito. Senza questa scatola il
/// gancio della chiusura non avrebbe modo di sapere quanti Eos sono arrivati, e
/// l'unica alternativa sarebbe far attendere la festa, che e' il difetto della
/// voce P.34 al contrario.
class _QuantiSonoArrivati {
  int quanti = 0;
}

/// LA REGIA DEL CAMMINO, in un punto solo.
///
/// **Un gesto, una porta.** Le schermate non sanno niente di traguardi: dicono
/// soltanto "ho fatto questo", e qui si segna nel diario, si guarda cosa si e'
/// acceso, si celebra e infine si accredita il premio sul server. Se ogni
/// schermata facesse da se', prima o poi una accenderebbe un Sigillo senza
/// premio, o lo celebrerebbe due volte.
///
/// **L'ORDINE E': si accende, SI CELEBRA, e solo dopo si accredita.**
/// Ordine P voce 34, e non e' una preferenza di stile.
///
/// Prima di questa voce l'accredito stava PRIMA della festa:
///
///     final saldo = await PremioDelTraguardo.accredita(porta, traguardo);
///     ...
///     await Celebrazione.festeggia(context, ...);
///
/// senza protezione attorno. `PortaDelCerchio` RILANCIA su `unauthenticated`,
/// `permission-denied`, `invalid-argument` e `failed-precondition`, e la
/// chiamata non ha un tetto proprio: con le funzioni non ancora distribuite
/// quell'attesa poteva sollevare oppure restare appesa, e il ciclo non
/// arrivava mai alla festa. Sul telefono si vedeva esattamente questo: Sigilli
/// accesi, zero celebrazioni. Un premio in Eos che arriva in ritardo e' un
/// fastidio; una festa che non arriva e' il traguardo che non e' successo.
class RegiaDelCammino {
  const RegiaDelCammino._();

  /// Da chiamare quando un gesto e' COMPIUTO, non quando una scena si apre:
  /// una scena si apre anche per sbaglio, un gesto no.
  static Future<void> dopoUnGesto(
    BuildContext context,
    String gesto, {
    String? oraRituale,
  }) async {
    // SE L'ALBERO NON PORTA IL DIARIO non si registra niente e non si cade:
    // succede in ogni prova che monta una scena d'arte da sola, e una scena
    // che casca perche' manca il provider di un traguardo sarebbe un difetto
    // peggiore del traguardo mancato.
    final DiarioDelCammino diario;
    try {
      diario = context.read<DiarioDelCammino>();
    } catch (errore) {
      return;
    }
    await diario.segna(gesto, oraRituale: oraRituale);
    if (!context.mounted) return;
    await guardaCosaSiAccende(context);
  }

  /// Guarda l'intero elenco e accende cio' che e' maturato.
  ///
  /// **Nessuno la chiama all'avvio, e il commento che lo diceva mentiva.**
  /// Verificato sui sorgenti alla voce 34: gli unici chiamanti sono
  /// `dopoUnGesto` e il guardiano della coda. Resta comunque vero che un
  /// traguardo puo' maturare quando nessuna schermata puo' ospitare la
  /// sovrimpressione, ed e' per quello che esiste la coda.
  static Future<void> guardaCosaSiAccende(BuildContext context) async {
    final DiarioDelCammino diario;
    final NatalChartController carte;
    try {
      diario = context.read<DiarioDelCammino>();
      carte = context.read<NatalChartController>();
    } catch (errore) {
      // Stessa ragione di sopra: senza l'albero completo non c'e' cammino da
      // guardare, e non c'e' niente da rompere.
      return;
    }
    final carta = carte.chart;
    // **DUE INGRESSI DELLA FOTOGRAFIA ERANO MURATI, ordine P voce 35.**
    // Qui c'era `seriePerRito: const {}`, cioe' una mappa vuota passata
    // sempre: tutti i traguardi `GiorniDiSeguito` erano irraggiungibili, i
    // cinque dell'alba, i cinque dell'oracolo, i cinque del tramonto. E i
    // pezzi dell'identita' non venivano passati affatto, quindi nemmeno i
    // TRE SIGILLI DI AGGANCIO TRASVERSALI, che sono i primi tre traguardi che
    // una persona incontra, potevano accendersi. E' la stessa famiglia della
    // stesa scollegata: un dato che nessuno alimentava.
    final stato = diario.statoDelCammino(
      carta: carta,
      segno: carta?.sunSign,
      seriePerRito: diario.seriePerRito,
      pezziDellIdentita: pezziDellIdentitaMaturi(diario, carta != null),
    );
    // La porta, la borsa e la coda si prendono PRIMA di qualunque attesa:
    // leggere il contesto dopo un await e' il modo classico di parlare a un
    // albero che non c'e' piu'.
    final servizi = context.read<AppServices>();
    final porta = servizi.porta;
    final borsa = context.read<QuestionAllowance>();
    // IL REGISTRO DEI GUASTI, la stessa porta che raccoglie i silenzi della
    // voce: un secondo registro dividerebbe i guasti e nessun pannello li
    // mostrerebbe tutti.
    final guasti = servizi.guasti;
    // IL REGISTRO DEI MOVIMENTI si prende qui con gli altri, PRIMA di
    // qualunque attesa: chiederlo dopo un await vorrebbe dire leggere un albero
    // che potrebbe non esserci piu'.
    final RegistroDegliEos? registro = _registro(context);
    final CodaDelleFeste? coda = _codaSeCe(context);
    final nuovi = await diario.quelliCheSiAccendono(stato);
    if (nuovi.isEmpty) return;

    // **PRIMA SI ACCENDE TUTTO, POI SI CELEBRA UNA VOLTA.** Ordine AC voce
    // 04, decisione di Mauro del 16 agosto: due celebrazioni di seguito danno
    // gia' fastidio. Il caso non e' teorico e non nasce da due Maestri: due
    // traguardi dello STESSO sentiero maturano sullo stesso gesto, come
    // cal_1 e cal_8 su una gettata col sogno gia' fatto, o ogni volta che un
    // gesto cade dentro una finestra del cielo. La raffica vista da Mauro il
    // 16 sera dopo l'onboarding e' la conferma sul campo. Si unisce la
    // FESTA, non il premio: l'accredito resta per traguardo, qui sotto.
    final primoInAssoluto = diario.accesi.isEmpty;
    final accesi = <Traguardo>[];
    for (final traguardo in nuovi) {
      if (await diario.accendi(traguardo.id)) accesi.add(traguardo);
    }
    if (accesi.isEmpty) return;

    // **QUANTI EOS SONO ARRIVATI, e si sapra' solo dopo.** Il volo parte alla
    // CHIUSURA della festa, e a quel punto l'accredito e' quasi sempre gia'
    // tornato: questa scatola porta il numero da la' a qui senza che la festa
    // debba attendere la rete. Con la festa unita il numero e' la SOMMA di
    // cio' che ogni accredito ha portato.
    final arrivati = _QuantiSonoArrivati();

    // 1. SI CELEBRA SUBITO, UNA VOLTA SOLA, e non si aspetta niente e
    //    nessuno. La celebrazione nomina ogni traguardo acceso e porta la
    //    somma degli Eos; l'intensita' e' quella del piu' importante.
    final festeggiato = context.mounted &&
        await Celebrazione.festeggiaInsieme(
          context,
          traguardi: accesi,
          sentieri: [for (final t in accesi) sentieroDi(t)],
          primoInAssoluto: primoInAssoluto,
          // **GLI EOS VOLANO QUANDO LA FESTA SE NE VA, ordine S voce 07.** E'
          // il momento in cui la barra torna visibile: lanciarlo prima
          // vorrebbe dire attraversare una celebrazione a schermo pieno per
          // arrivare a un borsellino coperto, e non vedrebbe niente nessuno.
          allaChiusura: () {
            if (context.mounted && arrivati.quanti > 0) {
              VoloDegliEos.lancia(context, quanti: arrivati.quanti);
            }
          },
        );

    // 2. SE NON C'ERA DOVE OSPITARLA, nessuna festa si perde: entrano in
    //    coda una per una e arrivano insieme al primo momento utile, anche
    //    dopo una chiusura dell'app.
    if (!festeggiato) {
      for (final traguardo in accesi) {
        await coda?.accoda(traguardo.id);
      }
    }

    for (final traguardo in accesi) {
      // 3. L'ACCREDITO IN FONDO, E PROTETTO, PER TRAGUARDO. Se fallisce, il Sigillo resta
      //    acceso e il premio riparte alla prossima sincronia, perche' il
      //    movimento porta gia' il suo identificativo e non si conta due
      //    volte. Quello che non deve mai succedere e' che si porti via la
      //    festa cadendo.
      // **IL FALLIMENTO SI VEDE, ordine S voce 04, primo passo.** Qui c'era un
      // `catch` che non registrava niente: se l'accredito fallisce non lo sa
      // nessuno, ne' la persona ne' un registro ne' una prova, ed e' per questo
      // che la causa del borsellino a zero era illeggibile da fuori. E' lo stesso
      // caso di inizio agosto, quando la causa dell'accesso anonimo era gia'
      // catturata in `AppServices.diagnostics` e non la leggeva nessuno. Prima si
      // rende leggibile il guasto, poi si cerca la causa: sono due passi, e il
      // primo e' una correzione a se'.
      try {
        final saldo = await PremioDelTraguardo.accredita(porta, traguardo);
        if (saldo == null) {
          guasti.registra(
            operazione: 'accredito del traguardo ${traguardo.id}',
            errore: 'il server non ha risposto: il Sigillo resta acceso e il '
                'premio si riprende alla prossima sincronia',
          );
          // **SI CONTINUA, e prima c'era un `return`.** Con piu' Sigilli
          // maturati insieme, e succede al primo gesto di un cammino nuovo,
          // un accredito muto si portava via anche gli altri: nessuna festa,
          // nessun Sigillo acceso, e un solo guasto scritto per tutti. Il
          // premio di questo si riprendera' alla prossima sincronia, e gli
          // altri non c'entrano niente.
          continue;
        }
        // DA DOVE SONO ARRIVATI GLI EOS, ordine S voce 06. Il delta si prende
        // PRIMA di applicare il saldo nuovo, perche' il server risponde col
        // totale e non con quanto ha aggiunto. Il registro porta il delta di
        // QUESTO traguardo; il volo alla chiusura porta la SOMMA, perche' la
        // festa e' una anche quando i traguardi sono di piu'.
        final delta = saldo - borsa.saldoEos;
        arrivati.quanti += delta;
        await registro?.segna(quanti: delta, perche: traguardo.nome);
        // **IL SALDO SI APPLICA SUBITO, col numero che il server ha appena
        // detto.** Prima si buttava e si chiedeva tutto lo stato con una seconda
        // chiamata: se quella non rispondeva, il numero in barra restava quello
        // vecchio e la persona vedeva "+10 Eos" nella festa e zero nel
        // borsellino.
        await borsa.applicaSaldo(saldo);
      } catch (errore) {
        // Nessun rilancio: sopra la festa e' gia' avvenuta e qui sotto non c'e'
        // piu' niente da proteggere. Ma si REGISTRA, perche' un guasto che non
        // lascia traccia e' un guasto che nessuno potra' spiegare.
        guasti.registra(
          operazione: 'accredito del traguardo ${traguardo.id}',
          errore: errore,
        );
      }
    }
  }

  /// Celebra cio' che era rimasto in attesa. La chiama il guardiano quando una
  /// schermata capace di ospitare la sovrimpressione e' finalmente montata.
  ///
  /// **TUTTE INSIEME, IN UNA FESTA SOLA.** Ordine AC voce 04: qui c'era il
  /// ciclo che le serviva una alla volta, in fila, ed era la raffica che
  /// Mauro ha visto la sera del 16 dopo l'onboarding. Adesso si prende
  /// l'intera coda e si celebra una volta, coi nomi di tutte.
  static Future<void> svuotaLaCoda(BuildContext context) async {
    final coda = _codaSeCe(context);
    if (coda == null || coda.vuota) return;
    final diario = context.read<DiarioDelCammino>();
    final traguardi = await coda.prendiTutte();
    if (traguardi.isEmpty) return;
    if (!context.mounted) {
      // Si rimettono dov'erano: una festa presa e non mostrata sarebbe persa.
      for (final traguardo in traguardi) {
        await coda.accoda(traguardo.id);
      }
      return;
    }
    final festeggiato = await Celebrazione.festeggiaInsieme(
      context,
      traguardi: traguardi,
      sentieri: [for (final t in traguardi) sentieroDi(t)],
      // Il primo in assoluto: quando tutti gli accesi del diario sono quelli
      // di questa festa, la persona non aveva niente prima, e il primo
      // premio deve sembrare grande. Era `<= 1` quando la festa era una.
      primoInAssoluto: diario.accesi.length <= traguardi.length,
      attendiLaFine: true,
    );
    if (!festeggiato) {
      for (final traguardo in traguardi) {
        await coda.accoda(traguardo.id);
      }
    }
  }

  /// I PEZZI DELL'IDENTITA' GIA' COMPLETI.
  ///
  /// Passano tutti dal diario, cioe' dallo stesso registro dei gesti: la carta
  /// natale e' l'unica che si legge dal suo controllore, perche' esiste anche
  /// per chi l'ha creata prima che questo registro nascesse. Un pezzo che
  /// avesse una porta propria sarebbe la seconda porta sullo stesso dato.
  @visibleForTesting
  static Set<String> pezziDellIdentitaMaturi(
    DiarioDelCammino diario,
    bool haLaCarta,
  ) {
    final pezzi = {
      // **LA LISTA NON STA PIU' QUI.** Ordine U voce 01, coda: viveva scritta a
      // mano in questo punto, ed era l'unico posto che sapesse quali gesti
      // completano un pezzo dell'identita'. La prova che sorveglia "un gesto,
      // una festa, un pagamento" ha bisogno dello stesso legame, e ricopiarlo
      // la' dentro avrebbe aperto la seconda porta sullo stesso dato.
      if (haLaCarta || diario.haFatto('carta_natale')) 'carta_natale',
      for (final pezzo in PezziDellIdentita.daSoloGesto)
        if (diario.haFatto(pezzo)) pezzo,
    };
    // **IL PASSAPORTO E' COMPOSTO, ordine AL voce 03.** Il suo gesto scatta a
    // ogni visita della schermata, quindi da solo non dice niente: matura
    // quando ogni tessera del documento e' viva, e le tessere stanno
    // enumerate in un punto solo, PezziDellIdentita.tessereDelPassaporto.
    // Il confronto e' sui PEZZI e non sui gesti, cosi' la carta natale
    // arrivata dal profilo conta come quella arrivata dal gesto.
    if (!PezziDellIdentita.tessereDelPassaporto.every(pezzi.contains)) {
      pezzi.remove('passaporto');
    }
    return pezzi;
  }

  /// IL REGISTRO DEI MOVIMENTI, se l'albero lo porta.
  ///
  /// Stessa ragione della coda: una prova che monta una scena d'arte da sola non
  /// ha l'albero intero, e un traguardo non deve mai mancare perche' manca il
  /// provider di una riga del portafoglio.
  static RegistroDegliEos? _registro(BuildContext context) {
    try {
      return context.read<RegistroDegliEos>();
    } catch (errore) {
      return null;
    }
  }

  static CodaDelleFeste? _codaSeCe(BuildContext context) {
    try {
      return context.read<CodaDelleFeste>();
    } catch (errore) {
      return null;
    }
  }

  static Sentiero sentieroDi(Traguardo traguardo) {
    for (final sentiero in Sentieri.tutti) {
      if (Sentieri.di(sentiero).any((t) => t.id == traguardo.id)) {
        return sentiero;
      }
    }
    return Sentiero.costellazione;
  }
}

/// IL GUARDIANO DELLE FESTE: non disegna niente, guarda soltanto la coda.
///
/// Al primo fotogramma in cui esiste un Overlay, e ogni volta che la coda
/// cambia, porta a schermo cio' che era rimasto in attesa. Vive nel guscio e
/// non dentro una schermata d'arte perche' **la festa non deve dipendere da
/// quale schermata e' aperta**: deve arrivare al primo momento utile,
/// qualunque esso sia.
///
/// **Sta SOTTO il Navigator, e la prima stesura sbagliava proprio qui.** Messo
/// nel `builder` del MaterialApp, cioe' sopra il Navigator, il suo contesto
/// non vedeva nessun Overlay e `Overlay.maybeOf` tornava sempre nullo: la coda
/// non si svuotava mai e la festa restava in attesa per sempre. Lo ha trovato
/// la prova, non la lettura. Da dentro il guscio l'Overlay c'e', ed e' quello
/// della radice: cio' che vi si inserisce compare sopra ogni rotta spinta.
class GuardianoDelleFeste extends StatefulWidget {
  const GuardianoDelleFeste({super.key, required this.child});

  final Widget child;

  @override
  State<GuardianoDelleFeste> createState() => _GuardianoDelleFesteState();
}

class _GuardianoDelleFesteState extends State<GuardianoDelleFeste> {
  bool _staCelebrando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _guarda());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _guarda());
  }

  Future<void> _guarda() async {
    if (!mounted || _staCelebrando) return;
    // Senza Overlay non c'e' dove ospitare niente: si riprova al prossimo
    // momento utile, che e' esattamente il patto della coda.
    if (Overlay.maybeOf(context) == null) return;
    _staCelebrando = true;
    try {
      await RegiaDelCammino.svuotaLaCoda(context);
    } finally {
      _staCelebrando = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // SI GUARDA LA CODA, cosi' una festa accodata mentre l'app e' gia' aperta
    // arriva subito invece di aspettare il prossimo avvio.
    final coda = context.watch<CodaDelleFeste?>();
    if (coda != null && !coda.vuota) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _guarda());
    }
    return widget.child;
  }
}
