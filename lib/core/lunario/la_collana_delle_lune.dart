import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/lunario/la_luna_nel_castone.dart' show IlMeseInItaliano;
import 'il_listino_del_respiro.dart';
import 'il_motore_lunare.dart';
import 'il_respiro_della_luna.dart';
import 'le_lune_della_nasa.dart';

/// Lo stato di una perla della Collana delle Lune.
enum StatoDellaPerla {
  /// Il giorno e' stato respirato: la perla porta la Luna vera di quel
  /// giorno.
  accesa,

  /// Il giorno e' passato e non e' stato respirato: nessun rimprovero,
  /// resta solo una perla spenta (FX.05: "nessuna punizione").
  spenta,

  /// Il giorno e' oggi o non e' ancora arrivato: non e' ancora deciso se
  /// si accendera'.
  inAttesa,
}

/// Una perla della collana, un giorno della lunazione in corso.
class PerlaDellaCollana {
  const PerlaDellaCollana({
    required this.giorno,
    required this.stato,
    this.immagine,
  });

  /// Il giorno di calendario, a mezzanotte locale.
  final DateTime giorno;
  final StatoDellaPerla stato;

  /// La Luna vera di quel giorno (`LeLuneDellaNasa.immaginePer`), nulla per
  /// le perle che non sono accese: non hanno una Luna da mostrare.
  final String? immagine;

  Map<String, Object?> toJson() => {
        'giorno': IlRespiroDellaLuna.data(giorno),
        'stato': stato.name,
        'immagine': immagine,
      };

  static PerlaDellaCollana? fromJson(Object? j) {
    if (j is! Map) return null;
    final g = DateTime.tryParse('${j['giorno']}');
    if (g == null) return null;
    var stato = StatoDellaPerla.spenta;
    for (final s in StatoDellaPerla.values) {
      if (s.name == j['stato']) stato = s;
    }
    return PerlaDellaCollana(
      giorno: DateTime(g.year, g.month, g.day),
      stato: stato,
      immagine: j['immagine'] as String?,
    );
  }
}

/// Una collana completa, archiviata nello scrigno delle collane passate.
class CollanaArchiviata {
  const CollanaArchiviata({
    required this.nome,
    required this.inizio,
    required this.perle,
  });

  final String nome;
  final DateTime inizio;
  final List<PerlaDellaCollana> perle;

  int get perleAccese =>
      perle.where((p) => p.stato == StatoDellaPerla.accesa).length;

  Map<String, Object?> toJson() => {
        'nome': nome,
        'inizio': IlRespiroDellaLuna.data(inizio),
        'perle': [for (final p in perle) p.toJson()],
      };

  static CollanaArchiviata? fromJson(Object? j) {
    if (j is! Map) return null;
    final inizio = DateTime.tryParse('${j['inizio']}');
    if (inizio == null) return null;
    final perle = <PerlaDellaCollana>[];
    for (final p in (j['perle'] as List? ?? const [])) {
      final perla = PerlaDellaCollana.fromJson(p);
      if (perla != null) perle.add(perla);
    }
    return CollanaArchiviata(
      nome: '${j['nome']}',
      inizio: DateTime(inizio.year, inizio.month, inizio.day),
      perle: perle,
    );
  }
}

/// **LA COLLANA DELLE LUNE.** Ordine FX voce FX.05, 16 ottobre 2026.
///
/// Segue la lunazione vera: dalla Luna nuova alla prossima, ventinove o
/// trenta perle, una per giorno ([IlMotoreLunare.luneNuoveFra] dice dove
/// cade ciascuna). Ogni perla accesa porta la Luna vera di quel giorno,
/// dalla stessa libreria di fotografie del Calendario Lunare
/// ([LeLuneDellaNasa]); ogni giorno passato e non respirato resta una perla
/// spenta; i giorni che non sono ancora arrivati restano in attesa.
///
/// **Dove vive**: sul telefono, nelle preferenze locali, come il resto del
/// lunario. Il server non la conosce ancora: la ricucitura
/// ([ricuciUnaPerlaLocalmente]) aggiorna solo lo stato locale, e la spesa
/// vera in Eos resta da agganciare (vedi il TODO sul metodo). La voce FX.05
/// resta quindi APERTA IN ATTESA DI VERIFICA per la parte server, come
/// impone il Protocollo della chiusura di questo progetto.
class LaCollanaDelleLune extends ChangeNotifier {
  LaCollanaDelleLune({required this.respiro});

  /// I giorni respirati: la sola verita' su quali perle si accendono.
  final IlRespiroDellaLuna respiro;

  static const String _chiaveRicuciture = 'respiro.ricuciture';
  static const String _chiaveUltimoCicloConsegnato =
      'respiro.ultimoCicloConsegnato';
  static const String _chiaveScrigno = 'respiro.scrignoDelleCollane';

  /// Quante collane passate si tengono nello scrigno: un anno, abbondante.
  static const int massimeCollaneNelloScrigno = 12;

  /// Le ricuciture fatte in ogni ciclo, per chiave del ciclo (la data della
  /// Luna nuova che lo apre) -> le date ricucite.
  final Map<String, List<String>> _ricuciture = {};

  /// L'ultimo ciclo per cui la scena della consegna e' partita (la data
  /// della Luna nuova che lo apre), nullo se non e' mai partita.
  String? _ultimoCicloConsegnato;

  final List<CollanaArchiviata> _scrigno = [];

  bool _letto = false;
  bool get letto => _letto;

  List<CollanaArchiviata> get scrigno => List.unmodifiable(_scrigno);

  Future<void> leggi() async {
    try {
      final p = await SharedPreferences.getInstance();
      final r = p.getString(_chiaveRicuciture);
      if (r != null) {
        (jsonDecode(r) as Map).forEach((k, v) {
          _ricuciture['$k'] = [for (final g in (v as List)) '$g'];
        });
      }
      _ultimoCicloConsegnato = p.getString(_chiaveUltimoCicloConsegnato);
      final s = p.getString(_chiaveScrigno);
      if (s != null) {
        for (final j in (jsonDecode(s) as List)) {
          final c = CollanaArchiviata.fromJson(j);
          if (c != null) _scrigno.add(c);
        }
      }
    } catch (errore) {
      debugPrint('Collana delle Lune: lo stato non si legge ($errore)');
    }
    _letto = true;
    notifyListeners();
  }

  Future<void> _scrivi() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_chiaveRicuciture, jsonEncode(_ricuciture));
      if (_ultimoCicloConsegnato != null) {
        await p.setString(
            _chiaveUltimoCicloConsegnato, _ultimoCicloConsegnato!);
      }
      await p.setString(
          _chiaveScrigno, jsonEncode([for (final c in _scrigno) c.toJson()]));
    } catch (errore) {
      debugPrint('Collana delle Lune: lo stato non si scrive ($errore)');
    }
  }

  // ---------------------------------------------------------------------
  // IL CICLO VERO, dalla Luna nuova alla prossima.
  // ---------------------------------------------------------------------

  /// L'inizio e la fine del ciclo che contiene [istante]: la Luna nuova
  /// appena passata (o di oggi) e la prossima.
  ({DateTime inizio, DateTime fine}) cicloDi(DateTime istante) {
    final giorno = DateTime(istante.year, istante.month, istante.day);
    // Una lunazione non supera mai 29,83 giorni (la stessa nota sta in
    // IlMotoreLunare): quaranta giorni prima e dopo bastano con largo
    // margine per trovare le due Lune nuove che racchiudono il giorno.
    final prima = giorno.subtract(const Duration(days: 40));
    final dopo = giorno.add(const Duration(days: 40));
    final lune = IlMotoreLunare.luneNuoveFra(prima, dopo);
    DateTime? inizio;
    DateTime? fine;
    for (final l in lune) {
      final g = DateTime(l.year, l.month, l.day);
      if (!g.isAfter(giorno)) {
        inizio = g;
      } else {
        fine ??= g;
      }
    }
    // Ripiego, che con una finestra di quaranta giorni non dovrebbe mai
    // servire: meglio una collana imprecisa che uno schianto.
    inizio ??= giorno;
    fine ??= inizio.add(const Duration(days: 30));
    return (inizio: inizio, fine: fine);
  }

  /// Il ciclo appena prima di [inizioCorrente].
  ({DateTime inizio, DateTime fine}) _cicloPrecedente(
      DateTime inizioCorrente) {
    final prima = inizioCorrente.subtract(const Duration(days: 40));
    final lune = IlMotoreLunare.luneNuoveFra(prima, inizioCorrente);
    var inizioPrec = inizioCorrente.subtract(const Duration(days: 29));
    for (final l in lune) {
      final g = DateTime(l.year, l.month, l.day);
      if (g.isBefore(inizioCorrente)) inizioPrec = g;
    }
    return (inizio: inizioPrec, fine: inizioCorrente);
  }

  /// Quante perle ha un ciclo: la differenza in giorni interi fra le due
  /// Lune nuove, ventinove o trenta (FX.05).
  int numeroDiPerle(DateTime inizio, DateTime fine) =>
      fine.difference(inizio).inDays;

  /// Il nome del ciclo, dal mese della Luna nuova che lo apre. Scelta di
  /// Code: e' il nome che l'ordine da' come esempio ("Collana di ottobre").
  String nomeDelCiclo(DateTime inizio) =>
      'Collana di ${IlMeseInItaliano.mesi[inizio.month - 1].toLowerCase()}';

  // ---------------------------------------------------------------------
  // LE PERLE.
  // ---------------------------------------------------------------------

  PerlaDellaCollana _perlaDel(DateTime giorno, DateTime oggi) {
    if (respiro.eRespirato(giorno)) {
      final mezzogiorno = DateTime(giorno.year, giorno.month, giorno.day, 12);
      final immagine = LeLuneDellaNasa.immaginePer(
          IlMotoreLunare.elongazione(mezzogiorno));
      return PerlaDellaCollana(
          giorno: giorno, stato: StatoDellaPerla.accesa, immagine: immagine);
    }
    if (giorno.isBefore(oggi)) {
      return PerlaDellaCollana(giorno: giorno, stato: StatoDellaPerla.spenta);
    }
    // Oggi, o un giorno che non e' ancora arrivato: non e' ancora deciso.
    return PerlaDellaCollana(giorno: giorno, stato: StatoDellaPerla.inAttesa);
  }

  /// Le perle del ciclo che contiene [now], una per ogni giorno del ciclo.
  List<PerlaDellaCollana> perle(DateTime now) {
    final ciclo = cicloDi(now);
    final oggi = DateTime(now.year, now.month, now.day);
    final n = numeroDiPerle(ciclo.inizio, ciclo.fine);
    return [
      for (var i = 0; i < n; i++)
        _perlaDel(ciclo.inizio.add(Duration(days: i)), oggi),
    ];
  }

  /// Quante perle sono accese nel ciclo di [now].
  int perleAccese(DateTime now) =>
      perle(now).where((p) => p.stato == StatoDellaPerla.accesa).length;

  // ---------------------------------------------------------------------
  // LA RICUCITURA, FX.05.
  // ---------------------------------------------------------------------

  /// I giorni spenti ricucibili nel ciclo di [now]: passati, non
  /// respirati, dentro la finestra consentita, col tetto per ciclo non
  /// ancora raggiunto.
  List<DateTime> giorniRicucibili(DateTime now) {
    final ciclo = cicloDi(now);
    final chiaveCiclo = IlRespiroDellaLuna.data(ciclo.inizio);
    final giaFatte = _ricuciture[chiaveCiclo]?.length ?? 0;
    if (giaFatte >= IlListinoDelRespiro.massimePerleRicucitePerCiclo) {
      return const [];
    }
    final oggi = DateTime(now.year, now.month, now.day);
    final limite = oggi
        .subtract(const Duration(days: IlListinoDelRespiro.massimoGiorniIndietro));
    return [
      for (final p in perle(now))
        if (p.stato == StatoDellaPerla.spenta && !p.giorno.isBefore(limite))
          p.giorno,
    ];
  }

  /// **RICUCISCE UNA PERLA**, aggiornando SOLO lo stato locale.
  ///
  /// **TODO integrazione**: qui si assume che la spesa in Eos sia gia'
  /// andata a buon fine. Un altro agente dello stesso ordine FX ha gia'
  /// scritto il lato del borsellino,
  /// `lib/features/respiro_della_luna/gli_eos_del_respiro.dart`
  /// (`GliEosDelRespiro.perleRicucite` e `.consumaUnaPerlaRicucita()`): chi
  /// integra chiama `consumaUnaPerlaRicucita()` PRIMA di chiamare questo
  /// metodo, e lo chiama solo se quello torna vero (un credito gia' comprato
  /// da spendere), con la chiamata al server che paga quel credito ancora da
  /// scrivere. Fino a quel momento questa voce resta "aperta in attesa di
  /// verifica" per la parte server.
  ///
  /// Torna falso se [giorno] non e' ricucibile in questo momento (fuori
  /// dalla finestra consentita, gia' acceso, o il tetto del ciclo e' pieno):
  /// in quel caso non spende e non segna niente.
  Future<bool> ricuciUnaPerlaLocalmente(DateTime giorno,
      {DateTime? now}) async {
    final adesso = now ?? DateTime.now();
    final giornoPuro = DateTime(giorno.year, giorno.month, giorno.day);
    final ricucibili = giorniRicucibili(adesso);
    if (!ricucibili.any((g) => g == giornoPuro)) return false;
    final ciclo = cicloDi(adesso);
    final chiaveCiclo = IlRespiroDellaLuna.data(ciclo.inizio);
    final fatte = _ricuciture.putIfAbsent(chiaveCiclo, () => []);
    fatte.add(IlRespiroDellaLuna.data(giornoPuro));
    await respiro.segnaRespirato(giornoPuro);
    notifyListeners();
    await _scrivi();
    return true;
  }

  // ---------------------------------------------------------------------
  // LA CONSEGNA, ALLA LUNA NUOVA.
  // ---------------------------------------------------------------------

  /// Vero se, al tempo [now], la scena della consegna del ciclo appena
  /// chiuso deve ancora partire: il ciclo precedente ha almeno una perla
  /// accesa e la sua consegna non e' mai partita.
  bool consegnaInAttesa(DateTime now) {
    final ciclo = cicloDi(now);
    final chiaveCicloCorrente = IlRespiroDellaLuna.data(ciclo.inizio);
    if (_ultimoCicloConsegnato == chiaveCicloCorrente) return false;
    final precedente = _cicloPrecedente(ciclo.inizio);
    // Se il ciclo corrente e' lo stesso del precedente (primo avvio, prima
    // di qualunque Luna nuova vera osservata), non c'e' niente da
    // consegnare.
    if (!precedente.inizio.isBefore(ciclo.inizio)) return false;
    final n = numeroDiPerle(precedente.inizio, precedente.fine);
    for (var i = 0; i < n; i++) {
      if (respiro.eRespirato(precedente.inizio.add(Duration(days: i)))) {
        return true;
      }
    }
    return false;
  }

  /// Le perle del ciclo appena chiuso, da mostrare nella scena della
  /// consegna.
  List<PerlaDellaCollana> perleDelCicloAppenaChiuso(DateTime now) {
    final ciclo = cicloDi(now);
    final precedente = _cicloPrecedente(ciclo.inizio);
    final n = numeroDiPerle(precedente.inizio, precedente.fine);
    return [
      for (var i = 0; i < n; i++)
        _perlaDel(precedente.inizio.add(Duration(days: i)), precedente.fine),
    ];
  }

  /// Segna la consegna come fatta per il ciclo appena chiuso, e archivia la
  /// collana nello scrigno delle collane passate.
  Future<void> segnaConsegnata(DateTime now) async {
    final ciclo = cicloDi(now);
    final precedente = _cicloPrecedente(ciclo.inizio);
    final perleDelCiclo = perleDelCicloAppenaChiuso(now);
    _scrigno.add(CollanaArchiviata(
      nome: nomeDelCiclo(precedente.inizio),
      inizio: precedente.inizio,
      perle: perleDelCiclo,
    ));
    while (_scrigno.length > massimeCollaneNelloScrigno) {
      _scrigno.removeAt(0);
    }
    _ultimoCicloConsegnato = IlRespiroDellaLuna.data(ciclo.inizio);
    notifyListeners();
    await _scrivi();
  }
}
