import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/lunario/il_giorno_lunare.dart';
import '../../core/lunario/il_motore_lunare.dart';
import '../../core/lunario/le_attivita_del_lunario.dart';
import '../../core/rituals/avvisi_del_rito.dart';

/// Un'attivita' fissata su un giorno d'oro (FV.08).
class PromemoriaDelLunario {
  const PromemoriaDelLunario({required this.giorno, required this.attivita});

  /// Il giorno d'oro, a mezzanotte locale.
  final DateTime giorno;
  final AttivitaDelLunario attivita;

  String get chiave => '${IPromemoriaDelLunario.data(giorno)}|${attivita.name}';

  Map<String, String> toJson() =>
      {'giorno': IPromemoriaDelLunario.data(giorno), 'attivita': attivita.name};

  static PromemoriaDelLunario? fromJson(Object? j) {
    if (j is! Map) return null;
    final g = DateTime.tryParse('${j['giorno']}');
    final nome = j['attivita'];
    AttivitaDelLunario? a;
    for (final x in AttivitaDelLunario.values) {
      if (x.name == nome) a = x;
    }
    if (g == null || a == null) return null;
    return PromemoriaDelLunario(
        giorno: DateTime(g.year, g.month, g.day), attivita: a);
  }
}

/// Come e' andata la programmazione di un avviso del Calendario.
enum EsitoDelPromemoria {
  /// L'avviso arrivera' sul telefono.
  programmato,

  /// Il permesso degli avvisi non c'e': il promemoria resta segnato sul mese
  /// e la schermata lo dice (FV.08, senza vicoli ciechi).
  senzaPermesso,

  /// Il giorno prima e' gia' passato: resta segnato sul mese, nessun avviso.
  troppoTardi,
}

/// **I PROMEMORIA E L'INTENZIONE DEL CALENDARIO LUNARE.** Ordine FV voci
/// FV.08 e FV.09, 15 ottobre 2026.
///
/// **Dove stanno**: sul telefono, nelle preferenze locali, sotto il prefisso
/// `lunario.` dichiarato in `CioCheETuo.prefissi` (sono cose tue: se ne
/// vanno con te). Non vanno al server, non vanno sulla card, non vanno al
/// Cerchio.
///
/// **Gli avvisi passano dal punto unico** `ServizioAvvisi` (in app
/// `avvisiDelCerchio`, sopra `flutter_local_notifications`) e dalla stessa
/// richiesta del permesso del Sigillo dell'Intenzione
/// (`LaChiamataDelSigillo`): se il permesso c'e' si programma, se non c'e' si
/// chiede una volta, se la persona dice no il promemoria resta sul mese.
///
/// **L'ORA DEL PROMEMORIA: LE 20 DEL GIORNO PRIMA.** Scelta di Code, con la
/// ragione: l'avviso dice "domani", e la sera e' il momento in cui il giorno
/// dopo si prepara (le sementi pronte, l'appuntamento dal parrucchiere, il
/// barattolo sterilizzato); alle 20 la giornata di lavoro e' finita e non si
/// e' ancora a letto. Un avviso alle 9 del giorno prima arriverebbe quando
/// "domani" e' ancora lontano un giorno e mezzo. La consegna e' approssimata
/// (`inexactAllowWhileIdle`, la ragione sta accanto ad `AvvisiDelRito`).
///
/// **L'ORA DELL'INTENZIONE: LE 21 DEL GIORNO DELLA LUNA PIENA**, quando la
/// Luna piena e' gia' alta in cielo e si vede.
class IPromemoriaDelLunario extends ChangeNotifier {
  IPromemoriaDelLunario({required this.avvisi});

  final ServizioAvvisi avvisi;

  /// Il canale di sistema, dichiarato in `AvvisiLocali.canali`.
  static const String canale = 'lunario';

  /// Il carico che l'apertura riceve: riporta al Calendario.
  static const String carico = 'lunario:calendario';

  /// L'ora del promemoria, il giorno prima (vedi la ragione sopra).
  static const int oraDelPromemoria = 20;

  /// L'ora dell'avviso dell'intenzione, il giorno della Luna piena.
  static const int oraDellIntenzione = 21;

  static const String _chiavePromemoria = 'lunario.promemoria';
  static const String _chiaveIntenzioni = 'lunario.intenzioni';

  /// **GLI ID STANNO DA 91000 A 91999**, lontano dai Doni (1100 e seguenti),
  /// dalle chiamate (1001-1004), dai Sigilli (2000-6999), dalla prova
  /// (90001) e dalle chiamate del cielo (90510 e 90520).
  static int idDi(String chiave) {
    var h = 0x811c9dc5;
    for (final c in chiave.codeUnits) {
      h = ((h ^ c) * 0x01000193) & 0xffffffff;
    }
    return 91000 + h % 1000;
  }

  static String data(DateTime g) =>
      '${g.year.toString().padLeft(4, '0')}-'
      '${g.month.toString().padLeft(2, '0')}-'
      '${g.day.toString().padLeft(2, '0')}';

  final List<PromemoriaDelLunario> _fissati = [];
  final Map<String, String> _intenzioni = {};
  bool _letto = false;

  /// L'esito dell'ultima programmazione, per la riga della schermata.
  EsitoDelPromemoria? ultimoEsito;

  List<PromemoriaDelLunario> get fissati => List.unmodifiable(_fissati);

  /// Le intenzioni scritte, per giorno della Luna nuova (`aaaa-mm-gg`).
  Map<String, String> get intenzioni => Map.unmodifiable(_intenzioni);

  bool get letto => _letto;

  Future<void> leggi() async {
    try {
      final p = await SharedPreferences.getInstance();
      final grezzi = p.getString(_chiavePromemoria);
      if (grezzi != null) {
        for (final j in (jsonDecode(grezzi) as List)) {
          final r = PromemoriaDelLunario.fromJson(j);
          if (r != null) _fissati.add(r);
        }
      }
      final ii = p.getString(_chiaveIntenzioni);
      if (ii != null) {
        (jsonDecode(ii) as Map).forEach((k, v) => _intenzioni['$k'] = '$v');
      }
    } catch (errore) {
      debugPrint('Calendario Lunare: i promemoria non si leggono ($errore)');
    }
    _letto = true;
    notifyListeners();
  }

  Future<void> _scrivi() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_chiavePromemoria,
          jsonEncode([for (final r in _fissati) r.toJson()]));
      await p.setString(_chiaveIntenzioni, jsonEncode(_intenzioni));
    } catch (errore) {
      debugPrint('Calendario Lunare: i promemoria non si scrivono ($errore)');
    }
  }

  bool eFissato(DateTime giorno, AttivitaDelLunario a) =>
      _fissati.any((r) => r.chiave == PromemoriaDelLunario(
              giorno: giorno, attivita: a)
          .chiave);

  List<PromemoriaDelLunario> delGiorno(DateTime g) => [
        for (final r in _fissati)
          if (r.giorno.year == g.year &&
              r.giorno.month == g.month &&
              r.giorno.day == g.day)
            r,
      ];

  /// Il testo dell'avviso, nella voce di Medora.
  static String testoDelPromemoria(AttivitaDelLunario a) =>
      'Domani la Luna è giusta per ${a.nome.toLowerCase()}. Te lo ricordo '
      'io, come avevi chiesto.';

  /// Quando suona il promemoria di [g]: il giorno prima, alle 20.
  static DateTime quandoPer(DateTime g) =>
      DateTime(g.year, g.month, g.day - 1, oraDelPromemoria);

  /// **FISSA L'ATTIVITA'** sul giorno d'oro e programma l'avviso.
  Future<EsitoDelPromemoria> fissa(PromemoriaDelLunario r,
      {DateTime? adesso}) async {
    if (!eFissato(r.giorno, r.attivita)) _fissati.add(r);
    notifyListeners();
    await _scrivi();
    final quando = quandoPer(r.giorno);
    ultimoEsito = await _programma(
      id: idDi(r.chiave),
      quando: quando,
      titolo: 'Il Calendario di Medora',
      testo: testoDelPromemoria(r.attivita),
      adesso: adesso,
    );
    notifyListeners();
    return ultimoEsito!;
  }

  /// **TOGLIE L'ATTIVITA'** con un tocco, e il suo avviso.
  Future<void> togli(PromemoriaDelLunario r) async {
    _fissati.removeWhere((x) => x.chiave == r.chiave);
    notifyListeners();
    await _scrivi();
    try {
      if (avvisi.disponibile) await avvisi.annulla(idDi(r.chiave));
    } catch (errore) {
      debugPrint('Calendario Lunare: l\'avviso non si toglie ($errore)');
    }
  }

  /// **L'INTENZIONE ALLA LUNA NUOVA** (FV.09): una riga, privata. Alla Luna
  /// piena seguente un avviso la ricorda; una riga vuota la toglie, e con lei
  /// l'avviso. Nessun richiamo a chi non scrive.
  Future<EsitoDelPromemoria?> scriviLIntenzione(DateTime lunaNuova, String riga,
      {DateTime? adesso}) async {
    final k = data(lunaNuova);
    final id = idDi('intenzione|$k');
    final testo = riga.trim();
    if (testo.isEmpty) {
      _intenzioni.remove(k);
      notifyListeners();
      await _scrivi();
      try {
        if (avvisi.disponibile) await avvisi.annulla(id);
      } catch (errore) {
        debugPrint('Calendario Lunare: l\'avviso non si toglie ($errore)');
      }
      return null;
    }
    _intenzioni[k] = testo;
    notifyListeners();
    await _scrivi();
    final piena = laLunaPienaDopo(lunaNuova);
    ultimoEsito = await _programma(
      id: id,
      quando: DateTime(piena.year, piena.month, piena.day, oraDellIntenzione),
      titolo: 'La Luna è piena',
      // Il testo non porta l'intenzione: una notifica si legge sulla
      // schermata di blocco, davanti a chiunque passi (come il Sigillo).
      testo: 'Ricordi che cosa avevi affidato alla Luna nuova? È qui, nel '
          'Calendario.',
      adesso: adesso,
    );
    notifyListeners();
    return ultimoEsito;
  }

  /// Il giorno della Luna piena dopo [lunaNuova]: quello che il motore segna
  /// come piena; se il motore non lo segna ancora, il giorno con
  /// l'elongazione piu' vicina a 180 gradi nei venti giorni seguenti.
  static DateTime laLunaPienaDopo(DateTime lunaNuova) {
    GiornoLunare? migliore;
    for (var i = 1; i <= 20; i++) {
      final g = IlMotoreLunare.delGiorno(
          DateTime(lunaNuova.year, lunaNuova.month, lunaNuova.day + i));
      if (g.lunaPiena) return g.giorno;
      if (migliore == null ||
          (g.elongazione - 180).abs() < (migliore.elongazione - 180).abs()) {
        migliore = g;
      }
    }
    return migliore!.giorno;
  }

  Future<EsitoDelPromemoria> _programma({
    required int id,
    required DateTime quando,
    required String titolo,
    required String testo,
    DateTime? adesso,
  }) async {
    try {
      if (!quando.isAfter(adesso ?? DateTime.now())) {
        return EsitoDelPromemoria.troppoTardi;
      }
      if (!avvisi.disponibile) return EsitoDelPromemoria.senzaPermesso;
      if (!await avvisi.permessoConcesso() && !await avvisi.chiediPermesso()) {
        return EsitoDelPromemoria.senzaPermesso;
      }
      await avvisi.programma(
        id: id,
        quando: quando,
        titolo: titolo,
        testo: testo,
        canale: canale,
        carico: carico,
      );
      return EsitoDelPromemoria.programmato;
    } catch (errore) {
      // Un avviso che non si programma non toglie il promemoria dal mese:
      // resta segnato, e la schermata dice che l'avviso non arrivera'.
      debugPrint('Calendario Lunare: l\'avviso non si programma ($errore)');
      return EsitoDelPromemoria.senzaPermesso;
    }
  }
}
