import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../core/astro/natal_chart_controller.dart';
import '../../core/entitlement/question_allowance.dart';
import '../../core/misura/misura_del_ritorno.dart';
import '../../core/misura/registro_del_ritorno.dart';
import '../../core/entitlement/registro_degli_eos.dart';
import '../../core/sigilli/bonus_della_condivisione.dart';
import '../../core/sigilli/coda_delle_feste.dart';
import '../../core/sigilli/distanza_fra_le_feste.dart';
import '../../core/sigilli/diario_del_cammino.dart';
import '../../core/sigilli/libro_degli_accrediti.dart';
import '../../core/sigilli/pezzi_dell_identita.dart';
import '../../core/sigilli/sentieri.dart';
import '../../design_system/components/volo_degli_eos.dart';
import '../../services/app_services.dart';
import 'celebrazione.dart';
import '../../core/sensi/voce_del_responso.dart';
import '../../core/sensi/palette_sensoriale.dart';

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
    // **LA VOCE DEL RESPONSO, ordine BX voce 05.**
    //
    // **Sta QUI e in nessun altro posto, ed e' la ragione per cui la voce
    // esiste.** Il fatto del fondatore era "gli effetti sonori ci sono solo
    // su alcune funzioni e mancano sugli altri responsi": degli otto
    // responsi ne suonava UNO, l'Oroscopo. Otto chiamate sparse in otto
    // schermate sarebbero diventate sette il giorno che qualcuno ne
    // dimentica una, ed e' la famiglia di difetto che questo progetto ha
    // gia' incontrato molte volte. **Ogni responso passa di qui**, perche'
    // ogni responso e' un gesto che arriva al cammino.
    //
    // **Non suona ogni gesto**: suonano solo quelli che il dato
    // `VoceDelResponso.deiResponsi` dichiara responsi. Un suono a ogni
    // gesto sarebbe il rumore che il catalogo dei suoni vieta dal primo
    // giorno, e quella regola non e' cambiata.
    final maestroDelResponso = VoceDelResponso.deiResponsi[gesto];
    if (maestroDelResponso != null) {
      // **IL RITO COMPIUTO SI SEGNA QUI. Ordine CC voce 09.**
      //
      // Dentro questo `if` e non fuori, e la ragione e' doppia. La prima: la
      // documentazione di questo metodo dice "da chiamare quando un gesto e'
      // COMPIUTO, non quando una scena si apre", ma i gesti sono molti piu'
      // dei riti, e contarli tutti come riti finiti darebbe un numero che
      // nessuno puo' confrontare con i riti cominciati. La seconda: dentro
      // questo `if` il nome del gesto e' per costruzione una chiave di
      // `VoceDelResponso.deiResponsi`, quindi il contesto viene da un elenco
      // chiuso, che e' il vincolo di questa voce.
      RegistroDelRitorno.segnalo(EventoDelRitorno.ritoCompiuto,
          contesto: gesto);
      // **NON SI ASPETTA.** La voce e la vibrazione non devono ritardare di
      // un giro cio' che viene dopo: aspettarle spostava la festa del
      // cammino e lasciava un temporizzatore acceso nella cattura
      // dell'Oroscopo.
      unawaited(PaletteSensoriale.responso(context, maestroDelResponso));
    }
    await guardaCosaSiAccende(context, gesto: gesto);
  }

  /// Guarda l'intero elenco e accende cio' che e' maturato.
  ///
  /// **Nessuno la chiama all'avvio, e il commento che lo diceva mentiva.**
  /// Verificato sui sorgenti alla voce 34: gli unici chiamanti sono
  /// `dopoUnGesto` e il guardiano della coda. Resta comunque vero che un
  /// traguardo puo' maturare quando nessuna schermata puo' ospitare la
  /// sovrimpressione, ed e' per quello che esiste la coda.
  static Future<void> guardaCosaSiAccende(BuildContext context,
      {String? gesto}) async {
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
    // **GLI INVITI ACCOLTI ENTRANO NEL CAMMINO PRIMA DI GUARDARE, ordine BX
    // voce 02**: il conto arriva dal server con lo stato, e tre voci lo
    // aspettano. Allinearlo dopo vorrebbe dire accorgersene un gesto dopo.
    await diario.allineaGliInviti(borsa.invitiAccolti,
        perMaestro: borsa.invitiPerMaestro);
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

    // **1. SI CELEBRA UN TRAGUARDO SOLO. Ordine AU voce 06**, decisione del
    //    fondatore del 22 agosto, e SOSTITUISCE quella del 16 agosto sulla
    //    celebrazione unica che li nominava tutti. Sulla 2188 si e' vista una
    //    card che ne nominava CINQUE con centoventi Eos: una festa a raffica
    //    smette di essere un premio, e una card che ne nomina cinque non e'
    //    piu' una festa, e' un rendiconto.
    //
    //    **Chi va per primo**: il piu' importante, cioe' il primo grande se
    //    c'e', e a parita' il primo per posizione nel cammino. E' la stessa
    //    regola che sceglieva l'intensita' della festa unita, quindi la scena
    //    resta quella che il fondatore ha gia' approvato.
    final perImportanza = [...accesi]..sort((a, b) {
        if (a.eGrande != b.eGrande) return a.eGrande ? -1 : 1;
        return a.posizione.compareTo(b.posizione);
      });
    final questaVolta = perImportanza.first;
    final inAttesa = perImportanza.skip(1).toList();
    // **LA DISTANZA FRA DUE FESTE, e senza di lei la coda non serve**: si
    // svuoterebbe tutta nella stessa schermata, cioe' cinque feste in fila
    // invece di una card con cinque nomi. Cambierebbe la forma del fastidio.
    // **UNA MATURAZIONE FRESCA FESTEGGIA SEMPRE.** Ordine BD voce 08,
    // decisione del fondatore: "festa sempre, subito". La distanza non si
    // guarda piu' qui: trattenere una festa nell'istante del gesto era
    // esattamente cio' che sulla 2198 si leggeva come "le feste non
    // funzionano". A trattenere resta solo FesteInCorso, dentro
    // festeggiaInsieme: se una festa e' gia' a schermo questa entra in coda
    // e riparte appena quella si chiude.
    // **LA FESTA DEL GESTO SI PORTA DIETRO CHI ASPETTAVA. Ordine BW voce
    // 02**, fatto osservato dal fondatore sulla 2210: quattro feste
    // consecutive in sessanta secondi, centocinquanta Eos, tre della famiglia
    // del cielo e di due Maestri diversi. Non nascevano dal gesto: erano
    // maturate prima, erano rimaste in coda perche' una riflessione occupava
    // la scena, e la catena della chiusura le apriva una dietro l'altra.
    //
    // **Adesso la coda non fa una fila di scene, entra in QUESTA.** Legge del
    // fondatore: non deve crearsi la condizione in cui una persona vede piu'
    // di una festa di seguito. Nessun premio si perde, perche' gli Eos e il
    // Sigillo sono gia' accreditati per traguardo; quello che si unisce e' la
    // scena, e ogni nome resta scritto dentro.
    final chiAspettava = await coda?.prendiTutte() ?? const <Traguardo>[];
    final insieme = <Traguardo>[
      questaVolta,
      for (final t in chiAspettava)
        if (t.id != questaVolta.id) t,
    ];
    final festeggiato = context.mounted &&
        await Celebrazione.festeggiaInsieme(
          context,
          traguardi: insieme,
          sentieri: [for (final t in insieme) sentieroDi(t)],
          primoInAssoluto: primoInAssoluto,
          // **GLI EOS VOLANO QUANDO LA FESTA SE NE VA, ordine S voce 07.** E'
          // il momento in cui la barra torna visibile: lanciarlo prima
          // vorrebbe dire attraversare una celebrazione a schermo pieno per
          // arrivare a un borsellino coperto, e non vedrebbe niente nessuno.
          allaChiusura: () {
            if (context.mounted && arrivati.quanti > 0) {
              VoloDegliEos.lancia(context, quanti: arrivati.quanti);
            }
            // **QUI NON RIPARTE PIU' NIENTE. Ordine BW voce 02**, e
            // SOSTITUISCE la catena dell'ordine BD voce 08: era lei a
            // trasformare tre traguardi in attesa in tre scene di fila.
            // Chi aspettava e' gia' dentro questa festa.
          },
        );

    // **2. TUTTI GLI ALTRI IN CODA, IN ORDINE, e nessuno si perde.** Ordine
    //    AU voce 06: un traguardo in attesa NON e' perso. Il Sigillo si e'
    //    gia' acceso qui sopra e gli Eos si accreditano qui sotto: in attesa
    //    c'e' soltanto la festa, che e' il modo di dire "non hai perso niente,
    //    te lo racconto dopo".
    if (festeggiato) {
      // **IL REGISTRO, ordine BU voce 05**: chi ha generato questa festa e
      // quando. Serve a rispondere con un numero alla domanda se due feste
      // attaccate nascano dallo stesso gesto.
      RegistroDelleFeste.segna(
          gesto: gesto ?? 'ignoto', traguardo: questaVolta.id);
      await DistanzaFraLeFeste.segnaFesta();
    } else {
      // Se la festa non e' comparsa, o perche' non c'era dove ospitarla o
      // perche' la scena era occupata, tornano in coda TUTTI quelli che
      // sarebbero stati nominati: una festa presa e non mostrata sarebbe
      // persa, e quelli che aspettavano da prima aspettano ancora.
      for (final t in insieme) {
        await coda?.accoda(t.id);
      }
    }
    for (final traguardo in inAttesa) {
      await coda?.accoda(traguardo.id);
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
        // **UN DELTA NON NASCE MAI DA UN SALDO NON ANCORA LETTO.**
        // Ordine BB voce 03, dal fatto del fondatore: quattro movimenti nel
        // borsellino, tutti con lo stesso importo, **e quell'importo era il
        // SALDO e non il guadagno**.
        //
        // La sottrazione qui sopra e' giusta finche' `borsa.saldoEos` e' il
        // saldo vero. **Ma se il borsellino non ha ancora sentito il server
        // vale zero**, e allora il delta diventa il totale: quattro premi da
        // pochi Eos si scrivono tutti e quattro come "piu' quattrocento-
        // quarantacinque". Non e' un errore del riquadro che li mostra, che
        // legge onestamente `movimento.quanti`: e' questa riga a scrivere il
        // numero sbagliato.
        //
        // **Quando il saldo non e' noto si usa cio' che il traguardo
        // dichiara**, che e' il suo premio: il listino lo conosce, e un
        // importo dichiarato e' sempre meglio di una sottrazione fra un
        // numero vero e uno zero che non e' un saldo ma un'assenza.
        final saldoNoto = borsa.saldoEos > 0;
        final delta =
            saldoNoto ? saldo - borsa.saldoEos : traguardo.eos;
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
  /// **UNA SOLA, E LE ALTRE ASPETTANO.** Ordine AU voce 06, e SOSTITUISCE la
  /// regola dell'ordine AC voce 04, che qui prendeva l'intera coda e ne
  /// celebrava una che le nominava tutte.
  ///
  /// **Le due regole vietavano cose diverse.** Quella di agosto vietava la
  /// RAFFICA, cioe' cinque scene di fila, e per evitarla univa i nomi in una
  /// scena sola: cosi' e' nata la card che ne nominava cinque con centoventi
  /// Eos, vista sulla 2188. Questa vieta i DUE NOMI nella stessa card, e la
  /// raffica la tiene lontana in un altro modo, con la distanza fra le feste:
  /// una per apertura dell'app, e tre ore di orologio fra l'una e l'altra.
  static Future<void> svuotaLaCoda(BuildContext context,
      {bool appenaChiusaUna = false}) async {
    final coda = _codaSeCe(context);
    if (coda == null || coda.vuota) return;
    final diario = context.read<DiarioDelCammino>();
    // **PRIMA SI CHIEDE IL PERMESSO, POI SI PRENDE.** Prendere una festa dalla
    // coda e poi rimetterla dentro perche' e' troppo presto e' un giro che
    // funziona finche' non cade a meta': si guarda l'orologio prima di
    // toccare la coda.
    //
    // **APPENA CHIUSA UNA, LA PROSSIMA NON ASPETTA.** Ordine BD voce 08: la
    // distanza di novanta secondi vale per il guardiano che riparte a
    // freddo, non per chi ha appena congedato una festa con altre in coda.
    if (!appenaChiusaUna && !await DistanzaFraLeFeste.siPuoFesteggiare()) {
      return;
    }
    // **TUTTA LA CODA IN UNA SCENA SOLA. Ordine BW voce 02.** Prima si
    // prendeva la prossima e la chiusura chiamava di nuovo questa funzione:
    // era una catena, e la catena e' quello che il fondatore ha visto come
    // quattro feste consecutive.
    final inCoda = await coda.prendiTutte();
    if (inCoda.isEmpty) return;
    final traguardo = inCoda.first;
    if (!context.mounted) {
      // Si rimettono dov'erano: una festa presa e non mostrata sarebbe persa.
      for (final t in inCoda) {
        await coda.accoda(t.id);
      }
      return;
    }
    final festeggiato = await Celebrazione.festeggiaInsieme(
      context,
      traguardi: inCoda,
      sentieri: [for (final t in inCoda) sentieroDi(t)],
      // Nessuna catena: dopo questa non c'e' nessun'altra da aprire.
      // **IL PRIMO IN ASSOLUTO SI CONTA TOGLIENDO CHI ASPETTA ANCORA.**
      // Ordine AU voce 06: da quando si celebra un traguardo alla volta, il
      // diario puo' averne tre accesi mentre la persona non ha ancora visto
      // NESSUNA festa, perche' gli altri due sono in coda. Contando i soli
      // accesi, la prima festa della vita finiva nella forma breve invece che
      // a schermo pieno, e il primo premio non sembrava piu' grande.
      primoInAssoluto:
          diario.accesi.length - coda.inAttesa.length <= 1,
      attendiLaFine: true,
    );
    if (festeggiato) {
      // **IL REGISTRO, ordine BU voce 05**: chi ha generato questa festa e
      // quando. Serve a rispondere con un numero alla domanda se due feste
      // attaccate nascano dallo stesso gesto.
      // **QUI IL GESTO NON SI SA, e si dichiara invece di indovinarlo**: la
      // festa arriva dalla coda, cioe' da un gesto compiuto prima. Scrivere
      // quello di adesso farebbe sembrare che due feste nascano insieme.
      RegistroDelleFeste.segna(gesto: 'dalla coda', traguardo: traguardo.id);
      await DistanzaFraLeFeste.segnaFesta();
    } else {
      // **TORNANO DENTRO TUTTI, non solo il primo. Ordine BW voce 02**: da
      // quando la scena li nomina tutti, prenderli in blocco e rimetterne
      // dentro uno solo vorrebbe dire buttare via le feste degli altri.
      for (final t in inCoda) {
        await coda.accoda(t.id);
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
    // **IL SALDO SI CHIEDE ANCHE QUANDO NON SI E' RIPRESO NIENTE.** Ordine AS
    // voce 03, ed e' la parte della cura che vale a prescindere dalla causa
    // del rifiuto.
    //
    // Prima qui c'era l'uscita anticipata a premi ripresi zero: se il server
    // rifiutava TUTTI gli accrediti, e succede quando il listino dei premi sul
    // server e' piu' vecchio dei motivi che il telefono manda, la sincronia
    // usciva senza nemmeno chiedere quanto sa il server. Il numero in barra
    // restava quello scritto sul disco, e poteva restare indietro per sempre:
    // non per i premi rifiutati, che quelli mancano davvero, ma per tutto cio'
    // che il server sapesse e il telefono no (il benvenuto, l'accredito del
    // giorno, una sessione su un altro dispositivo).
    //
    // **Il saldo del server e' l'unico numero sovrano**, e chiederlo costa una
    // chiamata sola dentro una sincronia che gira una volta per apertura.
    final statoNuovo = await porta.stato();
    if (statoNuovo == null) {
      guasti.registra(
        operazione: 'saldo dopo la ripresa dei premi',
        errore: 'il server non ha detto il saldo: la pillola si aggiorna '
            'alla prossima apertura',
      );
      return;
    }
    if (ripresi == 0) {
      // Nessun premio ripreso: il saldo del server si applica lo stesso, ma
      // non si canta vittoria con un volo di Eos che non sono arrivati adesso.
      if (statoNuovo.saldoEos != borsa.saldoEos) {
        await borsa.applicaSaldo(statoNuovo.saldoEos);
      }
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
    // **IL SIGILLO DEL CERCHIO E LA LUNA NATALE HANNO UNA PORTA VERA.**
    // Ordine BD voce 05: si scoprivano "col Passaporto pieno", cioe'
    // maturavano in blocco con tutto il resto. Adesso il Sigillo matura
    // aprendo la sua schermata e la Luna aprendo il portale del cielo di
    // nascita: gesti che il passaporto segna alle sue porte.
    if (diario.haFatto('sigillo_del_cerchio')) pezzi.add('sigillo_del_cerchio');
    if (diario.haFatto('luna_natale')) pezzi.add('luna_natale');
    // Il nome proprio matura al primo saluto per nome nel Santuario: e' li'
    // che il Cerchio dimostra di custodirlo. Ordine BD voce 05.
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
