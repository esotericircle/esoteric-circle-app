import '../tempo/confine_del_giorno.dart';
import '../astro/moon_phase.dart';
import '../astro/night_sky.dart';
import '../rituals/sunset_rune.dart';
import 'chakra_del_giorno.dart';
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
/// 2. **L'invito a tornare**, che compone l'app. E' agganciato a qualcosa che
///    cambia da solo: il cielo di domani per Medora, la runa della sera per
///    Caligo, il chakra del giorno per Aura. **E' diverso perche' il mondo e'
///    diverso**, non perche' il modello ha pescato un sinonimo, ed e' il
///    motivo per cui non lo si lascia scrivere a lui: un modello a cui si
///    chiede di variare produce sinonimi, non fatti nuovi.
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

  static const _principali = {
    'Primo quarto',
    'Luna piena',
    'Ultimo quarto',
    'Luna nuova',
  };

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

  /// Il prossimo segno in cui la Luna entra.
  static ProssimoCambioDellaLuna ingresso(DateTime da) {
    final adesso = NightSky.moonSign(da);
    for (var h = 1; h <= _oreMassime; h++) {
      final t = DateTime(da.year, da.month, da.day, da.hour + h);
      final segno = NightSky.moonSign(t);
      if (segno != adesso) {
        return ProssimoCambioDellaLuna._(segno.italianName, _giorni(da, t));
      }
    }
    // La Luna cambia segno ogni due giorni e mezzo: qui non si arriva.
    return ProssimoCambioDellaLuna._(adesso.italianName, 0);
  }

  /// La prossima fase principale che comincia.
  static ProssimoCambioDellaLuna fase(DateTime da) {
    final adesso = MoonPhase.forDate(da).italianName;
    for (var h = 1; h <= _oreMassime; h++) {
      final t = DateTime(da.year, da.month, da.day, da.hour + h);
      final nome = MoonPhase.forDate(t).italianName;
      if (nome != adesso && _principali.contains(nome)) {
        return ProssimoCambioDellaLuna._(_colSuoArticolo(nome), _giorni(da, t));
      }
    }
    return ProssimoCambioDellaLuna._(_colSuoArticolo(adesso), 0);
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
      '- Quella riga riassume in modo DIRETTO ciò che hai appena detto, in una '
      'frase sola e breve. Niente immagini, niente poesia: è la risposta '
      'immediata per chi legge solo quella.\n'
      '- Non aggiungere altro dopo di essa. All\'invito a tornare non pensare '
      'tu: ci pensa l\'app, che sa cosa cambia nel cielo di domani.';

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
      case Maestro.caligo:
        // Senza segno, come l'arte: ordine EA voce 05. La runa che Caligo
        // annuncia e' quella che il Tramonto dara' davvero.
        final estrazione = SunsetRune.estrai(
          domani.add(const Duration(hours: 18)),
          identita: identita,
        );
        final nome = estrazione.rune.name;
        final forme = <String>[
          'Torna domani sera: la runa che scende è $nome.',
          'Domani al tramonto ti aspetta $nome: portala con te.',
          'Rivediamoci quando cala il sole, con $nome sulla soglia.',
        ];
        return forme[giro % forme.length];
      case Maestro.aura:
        final chakra = ChakraDelGiorno.di(domani);
        final forme = <String>[
          'Torna domani: si apre ${chakra.italiano}, che governa '
              '${chakra.governa}.',
          'Domani lavora ${chakra.italiano}: rileggi con quello acceso.',
          'Ripassa quando sarà il giorno di ${chakra.nome}, '
              '${chakra.governa}.',
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
  }) {
    final corpo = corpoDa(testo);
    if (corpo.trim().isEmpty && sintesiDa(testo) == null) return '';
    final invito =
        invitoDelRitorno(maestro, quando: quando, identita: identita);
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
    return '$chiusa $invito';
  }
}
