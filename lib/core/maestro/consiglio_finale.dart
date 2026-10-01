import '../tempo/confine_del_giorno.dart';
import '../astro/night_sky.dart';
import 'maestro.dart';

/// IL CONSIGLIO FINALE: una riga sola, in oro, preceduta da una STELLA.
///
/// **Perche' una stella e non una freccia.** La freccia promette un altrove,
/// la stella dichiara un dono. E la freccia che stava li' non era nemmeno
/// toccabile: risalendo gli antenati per rientro dentro la carta del Consiglio
/// non c'era nessun gesto, quindi era decorazione travestita da comando.
///
/// **Cosa c'e' dentro la riga, e chi la scrive.** Due pezzi, di due autori
/// diversi, ed e' la ragione per cui questo file esiste.
///
/// 1. **La sintesi**, che scrive il Maestro. Diretta, non poetica: e' la
///    risposta immediata, quella che una persona di fretta legge al posto di
///    tutto il resto. Arriva marcata dal modello e viene sollevata da qui.
/// 2. **L'invito a tornare**, che compone l'app. Per Medora e' agganciato al
///    prossimo cambio del cielo; per Caligo e Aura invita a tornare **senza
///    svelare** la runa o il centro di domani, dall'ordine EJ voce 07: ogni
///    dono si scopre nel suo momento. **Sta solo sotto l'ultima risposta**,
///    ordine EJ voce 05, perche' un congedo si dice una volta.
///
/// **Sta nella risposta breve, per tutti i livelli, Viandante compreso.** Non
/// e' un contenuto premium: e' la cosa che la persona legge se legge solo
/// quella.
///
/// **Resta SEMPRE l'ultima riga della bolla**, anche dopo che il seguito e'
/// stato rivelato. E' per questo che il testo del Maestro si spacca qui in due
/// pezzi invece di essere mostrato com'e': il seguito si infila fra il corpo e
/// il consiglio, e un consiglio in mezzo al testo non e' piu' un consiglio.
/// **IL PROSSIMO CAMBIO DELLA LUNA, cercato ora per ora.** Ordine DS voce 08.
///
/// Cosa cambia, e fra quanti giorni di calendario. Sta qui accanto all'unico
/// invito che lo usa, e chiede tutto a `NightSky` e `MoonPhase`: nessun
/// calcolo astronomico nuovo.
class ProssimoCambioDellaLuna {
  const ProssimoCambioDellaLuna._(this.cosa, this.fraGiorni);

  /// Il segno in cui la Luna entra, oppure la fase col suo articolo
  /// (*"la Luna piena"*, *"il Primo quarto"*).
  final String cosa;
  final int fraGiorni;

  /// Quanto si guarda avanti: piu' di un ciclo lunare intero.
  static const int _oreMassime = 24 * 32;

  static int _giorni(DateTime da, DateTime a) =>
      DateTime.utc(a.year, a.month, a.day)
          .difference(DateTime.utc(da.year, da.month, da.day))
          .inDays;

  static String _colSuoArticolo(String fase) => switch (fase) {
        'Primo quarto' => 'il Primo quarto',
        'Ultimo quarto' => "l'Ultimo quarto",
        'Luna piena' => 'la Luna piena',
        'Luna nuova' => 'la Luna nuova',
        _ => fase,
      };

  /// **IL MINUTO DEL CAMBIO**, ordine EV voce EV.10. Qui si cercava ora per
  /// ora a partire dall'ora piena, e il primo istante col cielo cambiato
  /// decideva il giorno: un ingresso alle 23:25 si trovava a mezzanotte, e
  /// l'invito diceva "domani" per una cosa che accadeva quella sera
  /// (`docs/collaudo/EV/inviti_del_cielo.txt`, 9 inviti sbagliati su 240 in
  /// sessanta giorni). Adesso si cerca ora per ora dall'istante vero, e fra
  /// l'ultima ora uguale e la prima diversa si scende al minuto.
  static DateTime _alMinuto(
      DateTime prima, DateTime dopo, bool Function(DateTime) cambiato) {
    var a = prima;
    var b = dopo;
    while (b.difference(a).inMinutes > 1) {
      final m = a.add(Duration(minutes: b.difference(a).inMinutes ~/ 2));
      if (cambiato(m)) {
        b = m;
      } else {
        a = m;
      }
    }
    return b;
  }

  /// Il prossimo segno in cui la Luna entra.
  static ProssimoCambioDellaLuna ingresso(DateTime da) {
    final adesso = NightSky.moonSign(da);
    bool cambiato(DateTime t) => NightSky.moonSign(t) != adesso;
    for (var h = 1; h <= _oreMassime; h++) {
      final t = da.add(Duration(hours: h));
      if (cambiato(t)) {
        final quando =
            _alMinuto(t.subtract(const Duration(hours: 1)), t, cambiato);
        return ProssimoCambioDellaLuna._(
            NightSky.moonSign(quando).italianName, _giorni(da, quando));
      }
    }
    // La Luna cambia segno ogni due giorni e mezzo: qui non si arriva.
    return ProssimoCambioDellaLuna._(adesso.italianName, 0);
  }

  static int _quarto(DateTime t) => NightSky.quartoDelCiclo(t);

  static const List<String> _fasiEsatte = NightSky.fasiPrincipali;

  /// **LA PROSSIMA FASE PRINCIPALE, ALL'ISTANTE ESATTO.** Ordine EV voce
  /// EV.10. Qui si guardava il nome della fase, che per regola dell'app
  /// comincia dodici ore prima dell'istante esatto: dentro quelle dodici ore
  /// la fase vera, che arrivava la sera stessa, era gia' "la fase di
  /// adesso", e l'invito saltava alla successiva (*"Ripassa fra 8 giorni,
  /// per la Luna piena"* alle 12 del 18 settembre, col Primo quarto alle 23).
  /// Adesso la fase e' l'istante in cui l'elongazione della Luna dal Sole
  /// passa per 0, 90, 180 o 270 gradi, cercato al minuto sulle effemeridi.
  static ProssimoCambioDellaLuna fase(DateTime da) {
    final adesso = _quarto(da);
    bool cambiato(DateTime t) => _quarto(t) != adesso;
    for (var h = 1; h <= _oreMassime; h++) {
      final t = da.add(Duration(hours: h));
      if (cambiato(t)) {
        final quando =
            _alMinuto(t.subtract(const Duration(hours: 1)), t, cambiato);
        return ProssimoCambioDellaLuna._(
            _colSuoArticolo(_fasiEsatte[_quarto(quando)]), _giorni(da, quando));
      }
    }
    return ProssimoCambioDellaLuna._(
        _colSuoArticolo(_fasiEsatte[(adesso + 1) % 4]), 0);
  }
}

abstract final class ConsiglioFinale {
  /// IL MARCATORE che il modello scrive, e che la persona NON vede mai.
  ///
  /// **La prima stesura lo mostrava, ed era sbagliato.** L'idea era che il
  /// carattere fosse insieme il marcatore e il segno a schermo, uno solo per
  /// non farli divergere. Ma nell'anteprima a 360 per 797 quel carattere e'
  /// uscito come un QUADRATINO VUOTO: il font del progetto non ha il glifo
  /// U+2726, e un carattere che il font non conosce diventa una scatola.
  ///
  /// Quindi i due ruoli sono due: qui vive il marcatore, che serve a sollevare
  /// la riga dal testo del Maestro, e la stella a video la disegna
  /// `RigaDelConsiglio` con un'icona che c'e' di sicuro, perche' Material la
  /// porta con se'. Il marcatore non arriva mai a schermo: `corpoDa` toglie la
  /// riga e la riga si ricompone senza di lui.
  static const String stella = '✦';

  /// L'istruzione che va al Maestro. Vive qui, accanto al lettore che la
  /// sollevera': chi cambia la forma vede subito chi la legge.
  static const String istruzione =
      'IL CONSIGLIO FINALE, SEMPRE, IN OGNI RISPOSTA:\n'
      '- Chiudi con una riga a sé, l\'ultima, che comincia col carattere $stella '
      'seguito da uno spazio.\n'
      // **NESSUN ESEMPIO DA RICOPIARE. Ordine EQ voce 01.** Qui c'era
      // "per esempio Stasera scrivi su un foglio le tre cose che vuoi
      // dirgli", e il modello lo ricopiava: nelle catture del fondatore
      // Calìgo ha chiuso quattro risposte su quattro con "Scrivi su un foglio
      // di carta bianca tre cose che vorresti realizzare", e nei collaudi
      // degli ordini EJ ed EK la riga "Stasera scrivi su un foglio le tre
      // cose che vuoi dirle" torna parola per parola. Un esempio sullo stesso
      // tema viene ricopiato e non capito, come l'ordine EK ha gia' visto per
      // l'apertura di Medora.
      '- Quella riga è il PASSO CONCRETO: un\'azione precisa che la persona può '
      'fare, con un oggetto, un momento o un modo definiti, nata da ciò che '
      'la persona ti ha appena scritto. Una frase sola e breve, niente '
      'immagini, niente poesia. Mai un invito generico come "trova la tua '
      'strada" o "parti da te".\n'
      '- Non ripetere mai una riga con $stella già scritta in questa '
      'conversazione. Non darne nemmeno una che proponga lo stesso gesto con '
      'altre parole.\n'
      // **IL PASSO GIA' FATTO NON SI RIFA'. Ordine EQ voce 01.** A "Ok, le
      // ho scritte e adesso cosa faccio?" Calìgo ha risposto "Il tuo gesto è
      // compiuto" e ha chiuso chiedendo di scriverle di nuovo.
      '- Se la persona ti dice che ha appena fatto un passo, non chiederle di '
      'rifarlo: il passo nuovo comincia da ciò che ha fatto.\n'
      '- Non aggiungere altro dopo di essa. All\'invito a tornare non pensare '
      'tu: ci pensa l\'app, che sa cosa cambia nel cielo di domani.\n'
      // **L'UNICA ECCEZIONE, ordine EN voce 07.** A "Chi sono gli altri
      // maestri oltre a te?" Calìgo ha chiuso con Perthro e "Apri una pagina
      // bianca, scrivi il tuo nome e bruciala": questa riga, che dice
      // SEMPRE, lo pretendeva. Una domanda su chi sono i Maestri non chiede
      // un passo. **Allargata dall'ordine EQ voce 01**: a "Ciao, chi sei?
      // Come puoi aiutarmi?" Calìgo ha chiuso con un passo, perche' "come
      // puoi aiutarmi" non era fra le parole dell'eccezione.
      '- Unica eccezione: quando la persona ti saluta o ti chiede soltanto '
      'chi sei, che cosa fai, come puoi aiutarla o chi sono gli altri '
      'Maestri, non c\'è un passo da dare e questa riga non si scrive.';

  /// **LE RIGHE D'ORO GIA' SCRITTE**, dai testi delle risposte precedenti
  /// della conversazione, per chiedere al modello di non ripeterle. Ordine EJ
  /// voce 05. Vuota quando non ce ne sono.
  static String righeGiaScritte(Iterable<String> testi) {
    final righe = [
      for (final t in testi)
        if (sintesiDa(t) case final r?) r,
    ];
    if (righe.isEmpty) return '';
    return 'RIGHE CON $stella GIÀ SCRITTE IN QUESTA CONVERSAZIONE: NON '
        'RIPETERNE NESSUNA E NON RIFORMULARLE, IL PASSO DI OGGI È UN ALTRO:\n'
        '${righe.map((r) => '- $r').join('\n')}';
  }

  /// La sintesi che il Maestro ha marcato, oppure null se non l'ha scritta.
  static String? sintesiDa(String testo) {
    final righe = testo.split('\n');
    for (var i = righe.length - 1; i >= 0; i--) {
      final r = righe[i].trim();
      if (!r.startsWith(stella)) continue;
      final dentro = r.substring(stella.length).trim();
      return dentro.isEmpty ? null : dentro;
    }
    return null;
  }

  /// Il corpo della risposta, cioe' tutto tranne la riga del consiglio.
  static String corpoDa(String testo) {
    final righe = testo.split('\n');
    final tenute = <String>[];
    for (final r in righe) {
      if (r.trim().startsWith(stella)) continue;
      tenute.add(r);
    }
    return tenute.join('\n').trim();
  }

  /// LA PRIMA FRASE DEL CORPO. **NON e' piu' il ripiego del consiglio.**
  ///
  /// **Una prova vecchia ha bocciato l'idea, ed era giusto.** Il ripiego
  /// prendeva la prima frase quando il Maestro dimenticava il marcatore: ma la
  /// prima frase sta gia' a schermo, in bianco, due centimetri sopra. La
  /// persona la leggeva DUE VOLTE, e la seconda in oro, cioe' col rilievo di
  /// una cosa nuova. Meglio mezza riga vera che una riga intera che ripete.
  ///
  /// Resta pubblica perche' e' una misura utile e perche' la prova che
  /// sorveglia il difetto la usa per dire cosa NON deve ricomparire.
  static String primaFraseDi(String corpo) {
    final t = corpo.trim();
    if (t.isEmpty) return '';
    for (var i = 0; i < t.length; i++) {
      if (!const ['.', '!', '?', '…'].contains(t[i])) continue;
      final dopo = i + 1 < t.length ? t[i + 1] : ' ';
      if (dopo != ' ' && dopo != '\n') continue;
      return t.substring(0, i + 1);
    }
    return t;
  }

  /// L'INVITO A TORNARE, composto dall'app sul mondo di domani.
  ///
  /// [quando] e' il giorno da cui si guarda: l'invito parla del giorno dopo.
  /// [identita] serve alla runa della sera, che e' gia' deterministica per
  /// persona e per giorno, e non si ripesca da nessuna parte.
  static String invitoDelRitorno(
    Maestro maestro, {
    required DateTime quando,
    required String identita,
  }) {
    final domani = DateTime(quando.year, quando.month, quando.day)
        .add(const Duration(days: 1));
    // La formula ruota col giorno, cosi' due giorni vicini non si somigliano
    // nemmeno nella forma: il dato cambia, e cambia anche il modo di dirlo.
    // ORDINE BL: dalla porta unica, con la BASE del 2026 intatta. Anche
    // qui il giorno era gia' normalizzato e il difetto era il passo nei
    // giorni del cambio d'ora, non l'ora dentro la giornata.
    final giro = ConfineDelGiorno.giorniDa(DateTime(2026), domani);
    switch (maestro) {
      // **IL PROSSIMO CAMBIO DEL CIELO, CALCOLATO. Ordine DS voce 08.**
      //
      // Le tre forme di prima guardavano il cielo di DOMANI e lo davano per
      // un cambio: *"Torna domani: la Luna passa in Capricorno"* anche quando
      // la Luna era in Capricorno da due giorni, e *"Ripassa quando sara'
      // luna crescente"* il 17 settembre, con la Luna crescente gia' da una
      // settimana. Un fondatore l'ha letta sotto una risposta che parlava del
      // Primo quarto in arrivo: le due frasi si smentivano, e la sbagliata
      // era dell'app.
      //
      // **Adesso l'invito dice QUANDO il cielo cambia davvero**: il prossimo
      // ingresso della Luna in un segno, oppure la prossima fase principale,
      // cercati ora per ora dalla stessa porta dell'astronomia. **E non e' un
      // consiglio sulla lettura**: *"quel che vedi cambia con lei"* se n'e'
      // andato, perche' identico sotto due letture diverse sembrava parlare
      // di quelle. Resta un appuntamento col cielo, e il verificatore
      // `IlCieloDetto` lo controlla per un anno intero.
      case Maestro.medora:
        final cambio = giro.isEven
            ? ProssimoCambioDellaLuna.ingresso(quando)
            : ProssimoCambioDellaLuna.fase(quando);
        final dopo = switch (cambio.fraGiorni) {
          0 => 'oggi, più tardi',
          1 => 'domani',
          final n => 'fra $n giorni',
        };
        // Le due forme cominciano con due parole diverse: due giorni vicini
        // dicono due cambi diversi, e la guardia della somiglianza vuole che
        // non si leggano come la stessa frase.
        return giro.isEven
            ? 'Rivediamoci $dopo: la Luna entra in ${cambio.cosa}.'
            : 'Ripassa $dopo, per ${cambio.cosa}.';
      // **NESSUN DONO SI SVELA PRIMA DEL SUO MOMENTO.** Ordine EJ voce 07,
      // decisione del fondatore del 17 settembre 2026 sui Doni del Giorno.
      // Qui Caligo annunciava la runa che il Tramonto avrebbe dato domani
      // (*"Torna domani sera: la runa che scende è Fehu"*) e Aura il centro
      // del giorno dopo (*"Torna domani: si apre la gola"*): il fondatore le
      // ha lette nelle catture della 2278. Adesso invitano a tornare, e basta.
      case Maestro.caligo:
        final forme = <String>[
          'Torna domani sera: la runa che scende la scopri solo allora.',
          'Domani al tramonto una runa nuova ti aspetta.',
          'Rivediamoci quando cala il sole.',
        ];
        return forme[giro % forme.length];
      case Maestro.aura:
        final forme = <String>[
          'Torna domani: il corpo avrà un altro centro da ascoltare.',
          'Domani rileggi con il respiro di un giorno nuovo.',
          'Ripassa domani, quando il corpo è di nuovo in ascolto.',
        ];
        return forme[giro % forme.length];
    }
  }

  /// LA RIGA INTERA, come la persona la legge.
  ///
  /// Sintesi del Maestro piu' invito dell'app, in una riga sola. Se il testo
  /// e' vuoto resta vuota: una stella senza niente accanto sarebbe la
  /// decorazione da cui questa riga e' nata per liberarci.
  static String componi(
    Maestro maestro, {
    required String testo,
    required DateTime quando,
    required String identita,
    bool conInvito = true,
  }) {
    final corpo = corpoDa(testo);
    if (corpo.trim().isEmpty && sintesiDa(testo) == null) return '';
    final invito = conInvito
        ? invitoDelRitorno(maestro, quando: quando, identita: identita)
        : '';
    // **SENZA MARCATORE RESTA IL SOLO INVITO**, e non e' un ripiego muto: e'
    // una scelta fra due cose degradate. La sintesi del Maestro non c'e', e
    // l'unica altra frase che potremmo mettere qui sta gia' a schermo poche
    // righe sopra: ripeterla in oro darebbe a una cosa gia' letta il rilievo
    // di una cosa nuova. L'invito a tornare invece e' vero comunque, perche'
    // lo compone l'app e non dipende da cio' che il Maestro ha scritto.
    final sintesi = sintesiDa(testo);
    if (sintesi == null || sintesi.trim().isEmpty) return invito;
    final chiusa =
        const ['.', '!', '?', '…'].contains(sintesi[sintesi.length - 1])
            ? sintesi
            : '$sintesi.';
    return invito.isEmpty ? chiusa : '$chiusa $invito';
  }

  /// **SOTTO QUALE RISPOSTA VA L'INVITO A TORNARE.** Ordine EJ voce 05.
  ///
  /// [posizione] e' l'indice della risposta nella conversazione,
  /// [ultimaDelMaestro] quello dell'ultima risposta vera del Maestro. La
  /// bolla della chat e il collaudo chiedono qui, cosi' misurano la stessa
  /// cosa.
  ///
  /// **Solo sotto l'ultima.** L'invito stava sotto ogni risposta, e il
  /// fondatore ha letto *"Ripassa fra 2 giorni, per la Luna piena."* in fondo
  /// a cinque risposte di fila; il collaudo EJ ha contato cinque chiusure
  /// ripetute su sei scambi, per tutti e tre i Maestri. Un invito a tornare
  /// e' un congedo, e un congedo si dice una volta, alla fine.
  ///
  /// **E MAI SOTTO UNA RISPOSTA DETTA A VOCE. Ordine ES voce 20.** Il
  /// fondatore: *"Invito a tornare nella chat del LIVE: esce, perché la chat
  /// deve dire solo quello che dice la voce"*, "Confermo tutto". Sul Realme,
  /// sotto l'ultima risposta di Calìgo nel LIVE, la chat mostrava l'invito
  /// che la voce non aveva detto.
  static bool invitoSotto({
    required int posizione,
    required int ultimaDelMaestro,
    bool dettoNelLive = false,
  }) =>
      posizione == ultimaDelMaestro && !dettoNelLive;
}
