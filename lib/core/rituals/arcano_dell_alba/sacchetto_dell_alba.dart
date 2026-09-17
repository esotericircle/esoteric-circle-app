import 'dart:math';

import 'attribuzioni_degli_arcani.dart';

/// Uno dei quarantaquattro stati dell'Arcano dell'Alba: una carta dei
/// maggiori, diritta o rovescia.
class StatoDellAlba {
  const StatoDellAlba(this.carta, {required this.rovescio});

  factory StatoDellAlba.daId(int id) =>
      StatoDellAlba(id ~/ 2, rovescio: id.isOdd);

  /// L'indice della carta fra i maggiori, nell'ordine del mazzo.
  final int carta;
  final bool rovescio;

  int get id => carta * 2 + (rovescio ? 1 : 0);

  @override
  bool operator ==(Object other) => other is StatoDellAlba && other.id == id;

  @override
  int get hashCode => id;

  @override
  String toString() => 'StatoDellAlba($carta${rovescio ? ' rovescia' : ''})';
}

/// **IL SACCHETTO DELL'ARCANO DELL'ALBA.** Ordine DT voce 05, 17 settembre
/// 2026.
///
/// Quarantaquattro stati, ventidue carte per due versi, estratti **senza
/// reimbussolamento**: ogni stato esce una volta per ciclo, e il ciclo dura
/// quanti sono gli stati. **La stessa carta, in qualunque verso, non torna
/// prima di un quarto del ciclo**: undici estrazioni, cioe' undici giorni
/// almeno, perche' se ne estrae una al giorno. Il vincolo vale anche a cavallo
/// fra un ciclo e il successivo, per questo il sacchetto ricorda le ultime
/// carte uscite.
///
/// **Nessun numero e' scritto a mano**: gli stati vengono dalle attribuzioni,
/// la distanza dagli stati.
///
/// **IL CASO NON BASTA, e non si estrae a caso fra tutti i rimasti.** Verso la
/// fine del ciclo una carta con entrambi i versi ancora dentro deve avere
/// undici posti fra le sue due uscite: un'estrazione cieca puo' chiudersi in
/// un vicolo. Per questo si estrae a caso **solo fra gli stati che lasciano il
/// resto del ciclo componibile**, e la prova e' costruttiva: il resto si
/// compone davvero, per intero, prima di accettare la scelta.
///
/// **Mai bloccare.** Un sacchetto vuoto si ricompone al ciclo successivo; uno
/// illeggibile si ricompone da capo; e se un sacchetto leggibile non avesse
/// piu' nessuna scelta componibile, si ricompone il ciclo invece di fermarsi.
class SacchettoDellAlba {
  const SacchettoDellAlba._({
    required this.rimasti,
    required this.ultimeCarte,
    required this.ciclo,
  });

  /// Un sacchetto pieno, al primo ciclo.
  factory SacchettoDellAlba.nuovo() => SacchettoDellAlba._(
        rimasti: List.unmodifiable(List.generate(stati, (i) => i)),
        ultimeCarte: const [],
        ciclo: 1,
      );

  /// Quante carte ci sono: i maggiori che hanno un'attribuzione.
  static int get carte => AttribuzioneDellArcano.tutte.length;

  /// Quanti stati: ogni carta nei due versi.
  static int get stati => carte * 2;

  /// La distanza minima fra due uscite della stessa carta: un quarto del
  /// ciclo.
  static int get distanzaMinima => stati ~/ 4;

  /// Gli stati ancora dentro, per id.
  final List<int> rimasti;

  /// Le carte uscite nelle ultime estrazioni, la piu' recente in fondo: al
  /// massimo [distanzaMinima] meno una, perche' e' quella la finestra in cui
  /// una carta non puo' tornare.
  final List<int> ultimeCarte;

  /// Il numero del ciclo in corso, dal primo.
  final int ciclo;

  /// **ESTRAE UNO STATO** e restituisce il sacchetto dopo l'estrazione.
  ///
  /// [caso] e' la sola fonte d'incertezza: chi riceve la carta non la vede,
  /// non la sceglie e non la puo' prevedere.
  ({StatoDellAlba stato, SacchettoDellAlba dopo}) estrai(Random caso) {
    var sacchetto = this;
    if (sacchetto.rimasti.isEmpty) sacchetto = sacchetto._cicloSuccessivo();
    var id = sacchetto._primaComponibile(caso);
    if (id == null) {
      sacchetto = sacchetto._cicloSuccessivo();
      id = sacchetto._primaComponibile(caso);
    }
    // Un sacchetto ricomposto e' sempre componibile, lo prova la sua guardia.
    // Questa riga esiste perche' mai bloccare vuol dire mai.
    id ??= sacchetto.rimasti[caso.nextInt(sacchetto.rimasti.length)];
    final stato = StatoDellAlba.daId(id);
    final finestra = [...sacchetto.ultimeCarte, stato.carta];
    final tenute = finestra.length > distanzaMinima - 1
        ? finestra.sublist(finestra.length - (distanzaMinima - 1))
        : finestra;
    return (
      stato: stato,
      dopo: SacchettoDellAlba._(
        rimasti:
            List.unmodifiable(sacchetto.rimasti.where((r) => r != id).toList()),
        ultimeCarte: List.unmodifiable(tenute),
        ciclo: sacchetto.ciclo,
      ),
    );
  }

  SacchettoDellAlba _cicloSuccessivo() => SacchettoDellAlba._(
        rimasti: List.unmodifiable(List.generate(stati, (i) => i)),
        ultimeCarte: ultimeCarte,
        ciclo: ciclo + 1,
      );

  /// **Uno stato a caso fra quelli componibili**, e null se non ce n'e'.
  ///
  /// Si mescolano i rimasti e si prende il primo che la finestra lascia
  /// uscire e che lascia il resto componibile: e' la stessa distribuzione che
  /// scegliere a caso fra tutti i componibili, ma prova in media uno o due
  /// candidati invece di quarantaquattro.
  int? _primaComponibile(Random caso) {
    final mescolati = [...rimasti]..shuffle(caso);
    for (final id in mescolati) {
      if (ultimeCarte.contains(id ~/ 2)) continue;
      if (componibile(
        rimasti.where((r) => r != id).toList(),
        [...ultimeCarte, id ~/ 2],
      )) {
        return id;
      }
    }
    return null;
  }

  /// **IL RESTO SI COMPONE?** Costruisce davvero una sequenza per [rimasti]
  /// che rispetti la distanza, a partire dalle carte uscite [recenti].
  ///
  /// Ad ogni posto prende, fra le carte che la finestra lascia uscire, quella
  /// con piu' stati ancora dentro, e a parita' quella uscita da piu' tempo.
  /// Se la costruzione riesce la risposta e' certa, perche' la sequenza
  /// esiste; la guardia del sacchetto misura su migliaia di cicli che non
  /// scarti mai tutte le scelte.
  static bool componibile(List<int> rimasti, List<int> recenti) {
    final conti = <int, int>{};
    for (final id in rimasti) {
      conti.update(id ~/ 2, (n) => n + 1, ifAbsent: () => 1);
    }
    final finestra = [...recenti];
    final ultimaUscita = <int, int>{};
    for (var i = 0; i < finestra.length; i++) {
      ultimaUscita[finestra[i]] = i - finestra.length;
    }
    var posto = 0;
    var resto = rimasti.length;
    while (resto > 0) {
      final vietate = finestra.length > distanzaMinima - 1
          ? finestra.sublist(finestra.length - (distanzaMinima - 1)).toSet()
          : finestra.toSet();
      int? scelta;
      for (final entry in conti.entries) {
        if (entry.value == 0 || vietate.contains(entry.key)) continue;
        if (scelta == null) {
          scelta = entry.key;
          continue;
        }
        final n = entry.value, m = conti[scelta]!;
        final u = ultimaUscita[entry.key] ?? -1000000;
        final v = ultimaUscita[scelta] ?? -1000000;
        if (n > m || (n == m && u < v)) scelta = entry.key;
      }
      if (scelta == null) return false;
      conti[scelta] = conti[scelta]! - 1;
      finestra.add(scelta);
      ultimaUscita[scelta] = posto;
      posto++;
      resto--;
    }
    return true;
  }

  Map<String, Object> toJson() => {
        'rimasti': rimasti,
        'ultimeCarte': ultimeCarte,
        'ciclo': ciclo,
      };

  /// **LEGGE UN SACCHETTO SALVATO, e non si fida.** Ogni cosa che non torna,
  /// un id fuori dagli stati, un doppione, una carta che non esiste, un ciclo
  /// senza senso, ricompone il sacchetto: mai bloccare, mai propagare un
  /// sacchetto impossibile.
  static SacchettoDellAlba daJson(Object? dati) {
    try {
      if (dati is! Map) return SacchettoDellAlba.nuovo();
      final rimasti = (dati['rimasti'] as List).cast<num>().map((n) {
        if (n != n.toInt()) throw const FormatException('id non intero');
        return n.toInt();
      }).toList();
      final ultime = (dati['ultimeCarte'] as List)
          .cast<num>()
          .map((n) => n.toInt())
          .toList();
      final ciclo = (dati['ciclo'] as num).toInt();
      final validi = rimasti.every((id) => id >= 0 && id < stati) &&
          rimasti.toSet().length == rimasti.length &&
          ultime.every((c) => c >= 0 && c < carte) &&
          ultime.length < distanzaMinima &&
          ciclo >= 1;
      if (!validi) return SacchettoDellAlba.nuovo();
      return SacchettoDellAlba._(
        rimasti: List.unmodifiable(rimasti),
        ultimeCarte: List.unmodifiable(ultime),
        ciclo: ciclo,
      );
    } catch (errore) {
      // Si ignora apposta: un salvataggio illeggibile non e' un errore da
      // mostrare, e' un sacchetto da ricomporre. Mai bloccare.
      return SacchettoDellAlba.nuovo();
    }
  }
}
