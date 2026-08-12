import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../core/astro/natal_chart_controller.dart';
import '../../core/entitlement/question_allowance.dart';
import '../../core/sigilli/bonus_della_condivisione.dart';
import '../../core/sigilli/coda_delle_feste.dart';
import '../../core/sigilli/diario_del_cammino.dart';
import '../../core/sigilli/sentieri.dart';
import '../../services/app_services.dart';
import 'celebrazione.dart';

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
      pezziDellIdentita: _pezziDellIdentita(diario, carta != null),
    );
    // La porta, la borsa e la coda si prendono PRIMA di qualunque attesa:
    // leggere il contesto dopo un await e' il modo classico di parlare a un
    // albero che non c'e' piu'.
    final porta = context.read<AppServices>().porta;
    final borsa = context.read<QuestionAllowance>();
    final CodaDelleFeste? coda = _codaSeCe(context);
    final nuovi = await diario.quelliCheSiAccendono(stato);
    if (nuovi.isEmpty) return;

    for (final traguardo in nuovi) {
      final primoInAssoluto = diario.accesi.isEmpty;
      if (!await diario.accendi(traguardo.id)) continue;

      // 1. SI CELEBRA SUBITO, e non si aspetta niente e nessuno. La
      //    celebrazione non deve mai attendere la rete, e non deve mai poter
      //    essere saltata da un errore di rete.
      final festeggiato = context.mounted &&
          await Celebrazione.festeggia(
            context,
            traguardo: traguardo,
            sentiero: sentieroDi(traguardo),
            primoInAssoluto: primoInAssoluto,
          );

      // 2. SE NON C'ERA DOVE OSPITARLA, la festa non si perde: entra in coda
      //    e arriva al primo momento utile, anche dopo una chiusura dell'app.
      if (!festeggiato) await coda?.accoda(traguardo.id);

      // 3. L'ACCREDITO IN FONDO, E PROTETTO. Se fallisce, il Sigillo resta
      //    acceso e il premio riparte alla prossima sincronia, perche' il
      //    movimento porta gia' il suo identificativo e non si conta due
      //    volte. Quello che non deve mai succedere e' che si porti via la
      //    festa cadendo.
      try {
        final saldo = await PremioDelTraguardo.accredita(porta, traguardo);
        if (saldo != null) await borsa.sincronizza();
      } catch (errore) {
        // Nessun rilancio: qui sotto non c'e' piu' niente da proteggere, e
        // sopra la festa e' gia' avvenuta.
      }
    }
  }

  /// Celebra cio' che era rimasto in attesa. La chiama il guardiano quando una
  /// schermata capace di ospitare la sovrimpressione e' finalmente montata.
  static Future<void> svuotaLaCoda(BuildContext context) async {
    final coda = _codaSeCe(context);
    if (coda == null || coda.vuota) return;
    final diario = context.read<DiarioDelCammino>();
    while (context.mounted) {
      final traguardo = await coda.prendiLaProssima();
      if (traguardo == null) return;
      if (!context.mounted) {
        // Si rimette dov'era: una festa presa e non mostrata sarebbe persa.
        await coda.accoda(traguardo.id);
        return;
      }
      final festeggiato = await Celebrazione.festeggia(
        context,
        traguardo: traguardo,
        sentiero: sentieroDi(traguardo),
        primoInAssoluto: diario.accesi.length <= 1,
        // IN FILA: le feste in attesa si mostrano una dopo l'altra, altrimenti
        // due scene a schermo pieno si accavallerebbero.
        attendiLaFine: true,
      );
      if (!festeggiato) {
        await coda.accoda(traguardo.id);
        return;
      }
    }
  }

  /// I PEZZI DELL'IDENTITA' GIA' COMPLETI.
  ///
  /// Passano tutti dal diario, cioe' dallo stesso registro dei gesti: la carta
  /// natale e' l'unica che si legge dal suo controllore, perche' esiste anche
  /// per chi l'ha creata prima che questo registro nascesse. Un pezzo che
  /// avesse una porta propria sarebbe la seconda porta sullo stesso dato.
  static Set<String> _pezziDellIdentita(
    DiarioDelCammino diario,
    bool haLaCarta,
  ) =>
      {
        if (haLaCarta || diario.haFatto('carta_natale')) 'carta_natale',
        for (final pezzo in const [
          'passaporto',
          'angelo_custode',
          'animale_guida',
          'archetipo',
          'viso',
          'numero_della_vita',
          'ora_di_nascita',
          'luogo_di_nascita',
        ])
          if (diario.haFatto(pezzo)) pezzo,
      };

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
