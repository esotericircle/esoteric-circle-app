import 'dart:math';

import '../../responsi/scelta_senza_ripetere.dart';
import 'forme_dell_alba.dart';
import 'lettura_dell_alba.dart';
import 'letture_dell_alba_dati.dart';
import 'responso_dell_alba.dart';
import 'sacchetto_dell_alba.dart';

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
    bool statoValido(int id) => id >= 0 && id < SacchettoDellAlba.stati;
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

/// **IL DIARIO DELL'ARCANO DELL'ALBA, per utente.** Ordine DT voci 05, 09,
/// 10, 11, 12, 22 e 23, 17 settembre 2026.
///
/// Tiene insieme tutto cio' che l'estrazione deve ricordare di una persona: il
/// **sacchetto** dei quarantaquattro stati, la **coda delle letture** di ogni
/// stato nell'ordine in cui quella persona le consuma, i **registri** del
/// ciclo, l'ultima **consegna** e il **contatore dei ripieghi**.
///
/// **LA VARIABILE PER UTENTE E' L'ORDINE DELLE LETTURE** (voci 12 e 22). Non
/// c'e' un seme di generazione, perche' non c'e' generazione: due persone che
/// ricevono lo stesso stato nello stesso giorno si trovano in punti diversi
/// della propria sequenza, perche' ognuna ha la sua. Il residuo di collisione
/// dipende da quante letture ha lo stato, ed e' un numero che decide Mauro.
///
/// **I REGISTRI SCELGONO, non filtrano** (voce 23). Le aperture dei tre
/// movimenti e la parola del giorno consegnate nel ciclo sono marche usate: fra
/// le letture in coda si consegna la prima che non ne tocca nessuna, e quella
/// saltata resta in coda. Se nessuna e' libera il corpus e' insufficiente, e
/// si consegna la meno recente contando il caso. **La scelta passa
/// dall'impianto unico** della voce 27, `SceltaSenzaRipetere`.
class DiarioDellAlba {
  const DiarioDellAlba._({
    required this.seme,
    required this.sacchetto,
    required this.code,
    required this.registro,
    required this.cicloDelRegistro,
    required this.ultima,
    required this.ripieghi,
  });

  factory DiarioDellAlba.nuovo({String? seme}) => DiarioDellAlba._(
        seme: seme ?? _semeNuovo(),
        sacchetto: SacchettoDellAlba.nuovo(),
        code: const {},
        registro: const {},
        cicloDelRegistro: 0,
        ultima: null,
        ripieghi: 0,
      );

  /// **IL SEME DELLA PERSONA**: da qui nasce l'ordine in cui consuma le
  /// letture e le aperture. Nasce una volta sola, a caso, e viaggia col
  /// diario: chi cambia telefono ritrova la sua sequenza, e non serve un
  /// account per averne una.
  final String seme;

  static String _semeNuovo() {
    final caso = Random.secure();
    return List.generate(16, (_) => caso.nextInt(16).toRadixString(16)).join();
  }

  final SacchettoDellAlba sacchetto;

  /// Per stato, i numeri delle letture ancora da consegnare, in ordine.
  final Map<int, List<int>> code;

  /// Le marche consegnate nel ciclo del registro.
  final Set<String> registro;
  final int cicloDelRegistro;
  final ConsegnaDellAlba? ultima;

  /// **Quante volte il corpus non ha avuto una lettura libera.** Un corpus
  /// scritto bene lo tiene a zero su un ciclo intero, e la prova lo pretende.
  final int ripieghi;

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

  /// **IL DONO DI OGGI.** Se oggi e' gia' stato estratto, torna quello, e il
  /// sacchetto non si tocca: una sola estrazione al giorno, e la Carta del
  /// giorno di Medora la legge da qui. [utente] e' il seme dell'ordine delle
  /// letture: l'archivio passa quello del diario.
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

    final estratto = sacchetto.estrai(caso);
    final stato = estratto.stato;
    final ciclo = estratto.dopo.ciclo;
    final usate = ciclo == cicloDelRegistro ? {...registro} : <String>{};
    var ripieghi = this.ripieghi;

    final letture = ResponsoDellAlba.lettureDi(stato, corpus: corpus);
    final tutti = [for (final l in letture) l.numero];
    final inCoda = [
      for (final n in code[stato.id] ?? const <int>[])
        if (tutti.contains(n)) n,
    ];
    final coda = inCoda.isNotEmpty
        ? inCoda
        : ordineDellUtente(utente, 'letture ${stato.id}', tutti);
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

    final dopo = DiarioDellAlba._(
      seme: seme,
      sacchetto: estratto.dopo,
      code: {
        ...code,
        stato.id: [
          for (final n in coda)
            if (n != lettura.numero) n,
        ],
      },
      registro: {
        ...usate,
        ...marcheDi(lettura),
        _marcaDellApertura(apertura),
      },
      cicloDelRegistro: ciclo,
      ultima: consegna,
      ripieghi: ripieghi,
    );
    return (responso: responsoDi(consegna, corpus: corpus)!, dopo: dopo);
  }

  Map<String, Object> toJson() => {
        'seme': seme,
        'sacchetto': sacchetto.toJson(),
        'code': {
          for (final e in code.entries) '${e.key}': e.value,
        },
        'registro': registro.toList(),
        'cicloDelRegistro': cicloDelRegistro,
        if (ultima != null) 'ultima': ultima!.toJson(),
        'ripieghi': ripieghi,
      };

  /// **LEGGE UN DIARIO SALVATO, e non si fida.** Il sacchetto si ricompone da
  /// se' se e' illeggibile; una coda, un registro o una consegna che non
  /// tornano si lasciano cadere, perche' mai bloccare vale anche qui.
  static DiarioDellAlba daJson(Object? dati) {
    if (dati is! Map) return DiarioDellAlba.nuovo();
    final code = <int, List<int>>{};
    final grezze = dati['code'];
    if (grezze is Map) {
      for (final e in grezze.entries) {
        final stato = int.tryParse('${e.key}');
        final numeri = e.value;
        if (stato == null ||
            stato < 0 ||
            stato >= SacchettoDellAlba.stati ||
            numeri is! List ||
            numeri.any((n) => n is! int)) {
          continue;
        }
        code[stato] = numeri.cast<int>();
      }
    }
    final registro = dati['registro'];
    final ciclo = dati['cicloDelRegistro'];
    final ripieghi = dati['ripieghi'];
    final seme = dati['seme'];
    return DiarioDellAlba._(
      seme: seme is String && seme.isNotEmpty ? seme : _semeNuovo(),
      sacchetto: SacchettoDellAlba.daJson(dati['sacchetto']),
      code: code,
      registro: registro is List ? registro.whereType<String>().toSet() : {},
      cicloDelRegistro: ciclo is int ? ciclo : 0,
      ultima: ConsegnaDellAlba.daJson(dati['ultima']),
      ripieghi: ripieghi is int ? ripieghi : 0,
    );
  }
}
