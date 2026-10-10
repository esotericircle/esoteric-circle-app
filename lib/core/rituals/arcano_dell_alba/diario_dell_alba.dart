import 'dart:math';

import '../../responsi/scelta_senza_ripetere.dart';
import 'forme_dell_alba.dart';
import 'lettura_dell_alba.dart';
import 'letture_dell_alba_dati.dart';
import 'responso_dell_alba.dart';
import 'stato_dell_alba.dart';

/// Cio' che e' stato consegnato in un giorno: le scelte, non il testo, cosi'
/// che riaprire il dono ricomponga lo stesso responso.
class ConsegnaDellAlba {
  const ConsegnaDellAlba({
    required this.giorno,
    required this.stato,
    required this.numero,
    required this.apertura,
    required this.clausola,
    this.ieri,
    this.filo = 0,
  });

  /// Il giorno civile, `aaaa-mm-gg`.
  final String giorno;
  final StatoDellAlba stato;
  final int numero;
  final int apertura;
  final int clausola;

  /// Lo stato di ieri, quando ieri c'e' stata un'estrazione.
  final StatoDellAlba? ieri;
  final int filo;

  Map<String, Object> toJson() => {
        'giorno': giorno,
        'stato': stato.id,
        'numero': numero,
        'apertura': apertura,
        'clausola': clausola,
        if (ieri != null) 'ieri': ieri!.id,
        'filo': filo,
      };

  static ConsegnaDellAlba? daJson(Object? dati) {
    if (dati is! Map) return null;
    final giorno = dati['giorno'];
    final stato = dati['stato'];
    final numero = dati['numero'];
    final apertura = dati['apertura'];
    final clausola = dati['clausola'];
    final ieri = dati['ieri'];
    final filo = dati['filo'];
    if (giorno is! String ||
        stato is! int ||
        numero is! int ||
        apertura is! int ||
        clausola is! int) {
      return null;
    }
    bool statoValido(int id) => id >= 0 && id < StatoDellAlba.quanti;
    if (!statoValido(stato) ||
        apertura < 0 ||
        apertura >= FormeDellAlba.aperture.length ||
        clausola < 0 ||
        (ieri != null && (ieri is! int || !statoValido(ieri)))) {
      return null;
    }
    return ConsegnaDellAlba(
      giorno: giorno,
      stato: StatoDellAlba.daId(stato),
      numero: numero,
      apertura: apertura,
      clausola: clausola,
      ieri: ieri is int ? StatoDellAlba.daId(ieri) : null,
      filo: filo is int ? filo : 0,
    );
  }
}

/// **IL DIARIO DELL'ARCANO DELL'ALBA, per utente.** Ordine DT voci 09, 10, 11,
/// 12, 22 e 23; **rifatto dall'ordine DU voci 11 e 12**, 17 settembre 2026.
///
/// Tiene insieme tutto cio' che la consegna deve ricordare di una persona: la
/// **coda delle letture** di ogni stato nell'ordine in cui quella persona le
/// consuma, il **registro** delle ultime consegne, l'ultima **consegna** e il
/// **contatore dei ripieghi**.
///
/// **IL SACCHETTO NON C'E' PIU', voce DU.11.** L'estrazione e' a caso fra i
/// quarantaquattro stati, ogni giorno, senza memoria: la stessa carta puo'
/// tornare domani. Cio' che non si ripete sono i testi, ed e' un'altra cosa.
///
/// **LA VARIABILE PER UTENTE E' L'ORDINE DELLE LETTURE** (voci 12 e 22). Non
/// c'e' un seme di generazione, perche' non c'e' generazione: due persone che
/// ricevono lo stesso stato nello stesso giorno si trovano in punti diversi
/// della propria sequenza, perche' ognuna ha la sua. Con dodici letture per
/// stato, due persone leggono lo stesso dono una volta su dodici.
///
/// **I REGISTRI SCELGONO, non filtrano** (voce 23). Le aperture dei tre
/// movimenti e la parola del giorno consegnate di recente sono marche usate:
/// fra le letture in coda si consegna la prima che non ne tocca nessuna, e
/// quella saltata resta in coda. **Di recente vuol dire nelle ultime
/// [finestraDelRegistro] consegne**, che e' la finestra scorrevole con cui il
/// registro ha preso il posto del ciclo del sacchetto: senza cicli, un
/// registro che non dimentica mai avrebbe finito per vietare tutto. Se
/// nessuna lettura e' libera si consegna la meno recente e si conta il
/// ripiego. **La scelta passa dall'impianto unico**, `SceltaSenzaRipetere`.
class DiarioDellAlba {
  const DiarioDellAlba._({
    required this.seme,
    required this.code,
    required this.rifornite,
    required this.registro,
    required this.ultima,
    required this.ripieghi,
    required this.consegne,
  });

  factory DiarioDellAlba.nuovo({String? seme}) => DiarioDellAlba._(
        seme: seme ?? _semeNuovo(),
        code: const {},
        rifornite: const {},
        registro: const [],
        ultima: null,
        ripieghi: 0,
        consegne: 0,
      );

  /// **QUANTE CONSEGNE RICORDA IL REGISTRO.** Quarantaquattro, cioe' quanti
  /// sono gli stati: e' il giro con cui una persona attraversa il mazzo intero
  /// nei due versi, e dentro quel giro nessuna apertura e nessuna parola
  /// torna.
  static int get finestraDelRegistro => StatoDellAlba.quanti;

  /// **IL SEME DELLA PERSONA**: da qui nasce l'ordine in cui consuma le
  /// letture e le aperture. Nasce una volta sola, a caso, e viaggia col
  /// diario: chi cambia telefono ritrova la sua sequenza, e non serve un
  /// account per averne una.
  final String seme;

  static String _semeNuovo() {
    final caso = Random.secure();
    return List.generate(16, (_) => caso.nextInt(16).toRadixString(16)).join();
  }

  /// Per stato, i numeri delle letture ancora da consegnare, in ordine.
  final Map<int, List<int>> code;

  /// Per stato, quante volte la coda e' stata rifornita: cambia il
  /// mescolamento del giro dopo, cosi' dodici letture non tornano sempre
  /// nello stesso ordine.
  final Map<int, int> rifornite;

  /// Le marche delle ultime consegne, la piu' recente in fondo: una lista per
  /// consegna, lunga al massimo [finestraDelRegistro].
  final List<List<String>> registro;

  final ConsegnaDellAlba? ultima;

  /// **Quante volte il corpus non ha avuto una lettura libera.** Un corpus
  /// scritto bene lo tiene a zero, e la prova lo pretende.
  final int ripieghi;

  /// **Quante carte ha ricevuto questa persona, da sempre.** Cresce di uno a
  /// ogni consegna e non torna mai indietro: e' il metro con cui il Cerchio
  /// decide quale di due diari e' piu' avanti, ora che non c'e' piu' il ciclo
  /// del sacchetto a dirlo.
  final int consegne;

  /// Le marche ancora in vigore, cioe' quelle delle consegne ricordate.
  Set<String> get marcheInVigore => {for (final r in registro) ...r};

  /// Il giorno civile di [d].
  static String iso(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// **LA MARCA DI UN'APERTURA**: le prime due parole, in minuscolo e senza
  /// accenti. Due parole e non tre: con tre, diciotto chiusure di Medora su
  /// centotrentadue cominciavano con *"Ciò che"* e il registro non lo vedeva.
  static String apertura(String testo) {
    const accenti = {
      'à': 'a', 'è': 'e', 'é': 'e', 'ì': 'i', 'ò': 'o', 'ù': 'u', //
    };
    final basso =
        testo.toLowerCase().split('').map((c) => accenti[c] ?? c).join();
    return RegExp(r'[a-z]+')
        .allMatches(basso)
        .take(2)
        .map((m) => m.group(0))
        .join(' ');
  }

  /// Le marche di una lettura per i registri.
  static Set<String> marcheDi(LetturaDellAlba l) => {
        '2:${apertura(l.dono)}',
        '3:${apertura(l.medora)}',
        if (l.parola != null) 'p:${apertura(l.parola!)}',
      };

  static String _marcaDellApertura(int i) =>
      '1:${apertura(FormeDellAlba.aperture[i])}';

  /// **Un numero stabile da testi**: FNV-1a a trentadue bit. Deterministico
  /// fra avvii, dispositivi e piattaforme, che `String.hashCode` non promette.
  static int impronta(List<Object> parti) {
    var h = 0x811C9DC5;
    for (final c in parti.join('|').codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    return h;
  }

  /// **L'ORDINE IN CUI [utente] CONSUMA** gli elementi di [numeri], mescolati
  /// da un seme che nasce dall'utente e da [chiave].
  static List<int> ordineDellUtente(
      String utente, Object chiave, List<int> numeri) {
    final lista = [...numeri];
    final caso = Random(impronta([utente, chiave]));
    for (var i = lista.length - 1; i > 0; i--) {
      final j = caso.nextInt(i + 1);
      final t = lista[i];
      lista[i] = lista[j];
      lista[j] = t;
    }
    return lista;
  }

  /// Il responso della consegna [c], ricomposto dalle sue scelte.
  static ResponsoDellAlba? responsoDi(ConsegnaDellAlba c,
      {List<LetturaDellAlba> corpus = lettureDellAlba}) {
    final letture = ResponsoDellAlba.lettureDi(c.stato, corpus: corpus);
    if (letture.isEmpty) return null;
    final lettura = letture.firstWhere((l) => l.numero == c.numero,
        orElse: () => letture.first);
    return ResponsoDellAlba.componi(lettura,
        apertura: c.apertura, clausola: c.clausola, ieri: c.ieri, filo: c.filo);
  }

  /// La consegna di [giorno], se oggi l'estrazione c'e' gia' stata: senza
  /// estrarre. E' la porta da cui leggono la Carta del giorno di Medora e il
  /// Sigillo del Sogno, perche' la carta di oggi e' una sola.
  ResponsoDellAlba? diOggi(DateTime giorno,
          {List<LetturaDellAlba> corpus = lettureDellAlba}) =>
      diGiorno(iso(giorno), corpus: corpus);

  /// La consegna del giorno [giorno], `aaaa-mm-gg`, se e' l'ultima.
  ResponsoDellAlba? diGiorno(String giorno,
      {List<LetturaDellAlba> corpus = lettureDellAlba}) {
    final gia = ultima;
    if (gia == null || gia.giorno != giorno) return null;
    return responsoDi(gia, corpus: corpus);
  }

  /// **IL DONO DI OGGI.** Se oggi e' gia' stato estratto, torna quello e non
  /// si estrae di nuovo: una sola carta al giorno, e la Carta del giorno di
  /// Medora la legge da qui. [utente] e' il seme dell'ordine delle letture:
  /// l'archivio passa quello del diario.
  ({ResponsoDellAlba responso, DiarioDellAlba dopo}) estrai({
    required String utente,
    required DateTime giorno,
    required Random caso,
    List<LetturaDellAlba> corpus = lettureDellAlba,
  }) {
    final oggi = iso(giorno);
    final gia = ultima;
    if (gia != null && gia.giorno == oggi) {
      final responso = responsoDi(gia, corpus: corpus);
      if (responso != null) return (responso: responso, dopo: this);
    }

    // **A CASO FRA TUTTI, ogni giorno**, voce DU.11.
    final stato = StatoDellAlba.aCaso(caso);
    final usate = marcheInVigore;
    var ripieghi = this.ripieghi;

    final letture = ResponsoDellAlba.lettureDi(stato, corpus: corpus);
    final tutti = [for (final l in letture) l.numero];
    final inCoda = [
      for (final n in code[stato.id] ?? const <int>[])
        if (tutti.contains(n)) n,
    ];
    // La coda finita si rifornisce, mescolata in un ordine nuovo: dodici
    // letture prima di rivedere un testo, e mai lo stesso giro due volte.
    final giri = rifornite[stato.id] ?? 0;
    final coda = inCoda.isNotEmpty
        ? inCoda
        : ordineDellUtente(utente, 'letture ${stato.id} giro $giri', tutti);
    LetturaDellAlba perNumero(int n) =>
        letture.firstWhere((l) => l.numero == n);

    final libera =
        SceltaSenzaRipetere.primoLibero(coda.map(perNumero), marcheDi, usate);
    final lettura = libera ?? perNumero(coda.first);
    if (libera == null) ripieghi++;

    final ordineDelleAperture = ordineDellUtente(utente, 'aperture',
        List.generate(FormeDellAlba.aperture.length, (i) => i));
    final aperturaLibera = SceltaSenzaRipetere.primoLibero(
        ordineDelleAperture, (int i) => {_marcaDellApertura(i)}, usate);
    final apertura = aperturaLibera ?? ordineDelleAperture.first;
    if (aperturaLibera == null) ripieghi++;

    final ieri = gia != null &&
            gia.giorno ==
                iso(DateTime(giorno.year, giorno.month, giorno.day - 1))
        ? gia.stato
        : null;
    final consegna = ConsegnaDellAlba(
      giorno: oggi,
      stato: stato,
      numero: lettura.numero,
      apertura: apertura,
      clausola: impronta([utente, stato.id, lettura.numero]) % 4,
      ieri: ieri,
      filo: impronta([utente, oggi]) % 2,
    );

    final restanti = [
      for (final n in coda)
        if (n != lettura.numero) n,
    ];
    final marche = [...marcheDi(lettura), _marcaDellApertura(apertura)];
    final ricordate = [...registro, marche];
    final dopo = DiarioDellAlba._(
      seme: seme,
      code: {...code, stato.id: restanti},
      rifornite: {
        ...rifornite,
        // Il giro si conta quando la coda si e' appena rifornita.
        stato.id: inCoda.isEmpty ? giri + 1 : giri,
      },
      registro: ricordate.length > finestraDelRegistro
          ? ricordate.sublist(ricordate.length - finestraDelRegistro)
          : ricordate,
      ultima: consegna,
      ripieghi: ripieghi,
      consegne: consegne + 1,
    );
    return (responso: responsoDi(consegna, corpus: corpus)!, dopo: dopo);
  }

  Map<String, Object> toJson() => {
        'seme': seme,
        'code': {
          for (final e in code.entries) '${e.key}': e.value,
        },
        'rifornite': {
          for (final e in rifornite.entries) '${e.key}': e.value,
        },
        'registro': registro,
        if (ultima != null) 'ultima': ultima!.toJson(),
        'ripieghi': ripieghi,
        'consegne': consegne,
      };

  /// **LEGGE UN DIARIO SALVATO, e non si fida.** Una coda, un registro o una
  /// consegna che non tornano si lasciano cadere, perche' mai bloccare vale
  /// anche qui.
  ///
  /// **E legge anche i diari della 2266 e della 2267**, che portavano il
  /// sacchetto e un registro piatto: il sacchetto si ignora, perche' non
  /// esiste piu', e il registro piatto entra come una consegna sola. Chi
  /// aggiorna l'app non perde il suo seme ne' le sue code.
  static DiarioDellAlba daJson(Object? dati) {
    if (dati is! Map) return DiarioDellAlba.nuovo();
    Map<int, List<int>> leggiCode(Object? grezze) {
      final code = <int, List<int>>{};
      if (grezze is! Map) return code;
      for (final e in grezze.entries) {
        final stato = int.tryParse('${e.key}');
        final numeri = e.value;
        if (stato == null ||
            stato < 0 ||
            stato >= StatoDellAlba.quanti ||
            numeri is! List ||
            numeri.any((n) => n is! int)) {
          continue;
        }
        code[stato] = numeri.cast<int>();
      }
      return code;
    }

    final rifornite = <int, int>{};
    final giri = dati['rifornite'];
    if (giri is Map) {
      for (final e in giri.entries) {
        final stato = int.tryParse('${e.key}');
        final quante = e.value;
        if (stato == null ||
            stato < 0 ||
            stato >= StatoDellAlba.quanti ||
            quante is! int ||
            quante < 0) {
          continue;
        }
        rifornite[stato] = quante;
      }
    }

    // Il registro di oggi e' una lista di consegne; quello delle build
    // precedenti era una lista piatta di marche.
    final grezzo = dati['registro'];
    final registro = <List<String>>[];
    if (grezzo is List) {
      final piatte = grezzo.whereType<String>().toList();
      if (piatte.isNotEmpty) registro.add(piatte);
      for (final r in grezzo.whereType<List>()) {
        final marche = r.whereType<String>().toList();
        if (marche.isNotEmpty) registro.add(marche);
      }
    }
    final ripieghi = dati['ripieghi'];
    final seme = dati['seme'];
    return DiarioDellAlba._(
      seme: seme is String && seme.isNotEmpty ? seme : _semeNuovo(),
      code: leggiCode(dati['code']),
      rifornite: rifornite,
      registro: registro.length > finestraDelRegistro
          ? registro.sublist(registro.length - finestraDelRegistro)
          : registro,
      ultima: ConsegnaDellAlba.daJson(dati['ultima']),
      ripieghi: ripieghi is int ? ripieghi : 0,
      // I diari della 2266 e della 2267 non lo portavano: si riparte dal
      // numero delle consegne ricordate, che e' un minimo onesto.
      consegne: dati['consegne'] is int
          ? dati['consegne']! as int
          : registro.length,
    );
  }
}
