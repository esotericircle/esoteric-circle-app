import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../core/astro/natal_chart_controller.dart';
import '../../core/entitlement/question_allowance.dart';
import '../../core/entitlement/registro_degli_eos.dart';
import '../../core/sigilli/bonus_della_condivisione.dart';
import '../../core/sigilli/coda_delle_feste.dart';
import '../../core/sigilli/diario_del_cammino.dart';
import '../../core/sigilli/libro_degli_accrediti.dart';
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
  /// **IL GESTO PORTA CON SE' CIO' CHE LA SCENA SA. Ordine AR voce 11.**
  ///
  /// Fino a qui arrivava solo il NOME del gesto e l'ora: "una stesa e'
  /// avvenuta". Con quel poco si possono chiedere solo quantita', e infatti i
  /// traguardi che ne nascevano erano conteggi nudi, che Mauro ha bocciato.
  /// Le condizioni che valgono qualcosa chiedono altro: tutti e quattro i
  /// semi, la stessa carta in due stese, tutti i modi della gettata provati.
  /// Sono domande sui DETTAGLI, e i dettagli li ha in mano la scena
  /// nell'istante in cui registra il gesto.
  ///
  /// **Ogni punto passa cio' che ha gia'**, senza andarselo a cercare
  /// altrove e senza aprire una seconda porta: dove un dato utile non c'e',
  /// non si inventa. Le chiavi sono libere ma i nomi vanno tenuti stabili,
  /// perche' una condizione li nomina.
  static Future<void> dopoUnGesto(
    BuildContext context,
    String gesto, {
    String? oraRituale,
    Map<String, Object?> dettagli = const {},
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
    await diario.segna(gesto, oraRituale: oraRituale, dettagli: dettagli);
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
        // IL LIBRO SA COSA E' ARRIVATO, ordine AL voce 05: senza questo segno
        // la sincronia non saprebbe quali premi riprendere e quali no.
        await LibroDegliAccrediti.segna(traguardo.id);
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

  /// LA SINCRONIA DEI PREMI PERSI, ordine AL voce 05.
  ///
  /// **La promessa senza meccanismo.** In tre punti di questo file sta scritto
  /// "il premio si riprende alla prossima sincronia", e la sincronia non
  /// esisteva: `accredita` aveva un solo chiamante, l'accensione. Sulla 2179
  /// ogni chiamata moriva respinta alla porta di Cloud Run, quindi ogni
  /// Sigillo acceso di Mauro e' rimasto senza premio, e nessuno li avrebbe
  /// mai ripresi. Qui la promessa diventa vera: si guardano i traguardi
  /// ACCESI che non stanno nel libro degli accrediti e si riprova, una volta
  /// per sessione. Il doppio conto non esiste perche' il movimento porta
  /// l'identificativo 'traguardo-<id>' e il server ripete la risposta di
  /// allora.
  ///
  /// **Il saldo finale viene dal server, non dai pezzi.** Una risposta
  /// ripetuta porta il saldo di ALLORA, che oggi puo' essere piu' basso del
  /// vero: applicarla regredirebbe la pillola. Percio' dopo le riprese si
  /// chiede lo stato intero e si applica quello, che e' l'unico numero
  /// sovrano.
  static Future<void> riprendiIPremiPersi(BuildContext context) async {
    if (ripresaTentata) return;
    ripresaTentata = true;
    final DiarioDelCammino diario;
    final AppServices servizi;
    final QuestionAllowance borsa;
    try {
      diario = context.read<DiarioDelCammino>();
      servizi = context.read<AppServices>();
      borsa = context.read<QuestionAllowance>();
    } catch (errore) {
      return;
    }
    final porta = servizi.porta;
    final guasti = servizi.guasti;
    final RegistroDegliEos? registro = _registro(context);
    // **PRIMA SI ASPETTA CHE IL DIARIO SIA PRONTO, ordine AN voce 04.**
    // Il guardiano gira al primo fotogramma utile, e a quel punto il
    // caricamento del diario da disco e' ancora in volo: senza questa
    // attesa la sincronia guardava un cammino VUOTO, concludeva che non
    // c'era niente da riprendere e bruciava il suo catenaccio per tutta la
    // sessione. E' il difetto che Mauro ha visto sulla 2181: al riavvio con
    // le porte aperte il saldo e' rimasto a zero, e l'arretrato e' arrivato
    // solo col traguardo successivo.
    await diario.pronto;
    if (!porta.viva) {
      // La porta spenta non e' un guasto: senza server si riprova alla
      // prossima apertura, e la sessione resta segnata per non girare a
      // vuoto.
      return;
    }
    final gia = await LibroDegliAccrediti.accreditati();
    final persi = [
      for (final t in Sentieri.tuttiITraguardi)
        if (diario.eAcceso(t.id) && !gia.contains(t.id)) t,
    ];
    if (persi.isEmpty) return;
    final saldoPrima = borsa.saldoEos;
    var ripresi = 0;
    for (final traguardo in persi) {
      try {
        final saldo = await PremioDelTraguardo.accredita(porta, traguardo);
        if (saldo == null) {
          guasti.registra(
            operazione: 'ripresa del premio ${traguardo.id}',
            errore: 'il server non ha risposto: si riprova alla prossima '
                'apertura',
          );
          continue;
        }
        ripresi++;
        await LibroDegliAccrediti.segna(traguardo.id);
      } catch (errore) {
        guasti.registra(
          operazione: 'ripresa del premio ${traguardo.id}',
          errore: errore,
        );
      }
    }
    if (ripresi == 0) return;
    final statoNuovo = await porta.stato();
    if (statoNuovo == null) {
      guasti.registra(
        operazione: 'saldo dopo la ripresa dei premi',
        errore: 'il server non ha detto il saldo: la pillola si aggiorna '
            'alla prossima apertura',
      );
      return;
    }
    final delta = statoNuovo.saldoEos - saldoPrima;
    await borsa.applicaSaldo(statoNuovo.saldoEos);
    if (delta > 0) {
      await registro?.segna(quanti: delta, perche: 'Premi ritrovati');
      if (context.mounted) {
        VoloDegliEos.lancia(context, quanti: delta);
      }
    }
  }

  /// Vero quando la sincronia di questa sessione e' gia' partita: una volta
  /// per apertura basta, il resto lo fanno le accensioni nuove.
  @visibleForTesting
  static bool ripresaTentata = false;

  /// **PERMETTE UN ALTRO GIRO DELLA SINCRONIA, ordine AP voce 02.** Il
  /// catenaccio di sopra vale per sessione, ed e' giusto: al secondo avvio
  /// non c'e' niente di nuovo da riprendere. Ma quando l'identita' CAMBIA,
  /// cioe' dopo un riconoscimento, il Cerchio e' un altro e i Sigilli appena
  /// tornati non hanno ancora avuto il loro premio. Il doppio pagamento
  /// resta impossibile: ogni movimento porta il suo identificativo e il
  /// server ripete la risposta di allora.
  static void riprendiDaCapo() => ripresaTentata = false;

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
    // **I PEZZI COMPOSTI DEL CORPUS NUOVO, ordine AR voce 02.** La revisione C
    // nomina cose che la persona TROVA nel Passaporto, non gesti che compie:
    // la nascita scritta per intero, il Sigillo del Cerchio, la Luna che
    // vegliava, il numero che l'accompagna. Sono composizioni di pezzi che
    // gia' esistono, e nascono qui invece che nel dato: il corpus dice cosa
    // la persona vede, il codice sa di cosa e' fatto.
    if (pezzi.contains('ora_di_nascita') &&
        pezzi.contains('luogo_di_nascita') &&
        pezzi.contains('carta_natale')) {
      pezzi.add('nascita_completa');
    }
    // Il Sigillo del Cerchio e la Luna natale si scoprono col Passaporto
    // pieno: e' li' che il Cerchio li mostra.
    if (pezzi.contains('passaporto')) {
      pezzi.add('sigillo_del_cerchio');
      pezzi.add('luna_natale');
    }
    // Il nome proprio: se il profilo ha un nome, il Cerchio lo custodisce.
    if (diario.haFatto('nome_proprio')) pezzi.add('nome_proprio');
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
    // LA SINCRONIA DEI PREMI, ordine AL voce 05: il guardiano e' il primo
    // momento della sessione in cui l'albero e' intero, ed e' qui che i
    // premi rimasti indietro si riprendono. Sta FUORI dal catenaccio delle
    // feste, e non e' pignoleria: non celebra niente, e tenerlo dentro
    // allungava il catenaccio di un soffio che bastava a far slittare una
    // festa fin sopra la schermata dopo, misurato dalla prova del
    // Passaporto. Dentro c'e' il suo catenaccio, quindi girare piu' volte
    // non costa niente.
    if (mounted) {
      await RegiaDelCammino.riprendiIPremiPersi(context);
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
