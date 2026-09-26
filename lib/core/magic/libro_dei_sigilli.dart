import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../entitlement/plan_catalog.dart';
import '../entitlement/tier.dart';
import '../rituals/avvisi_del_rito.dart';
import '../tempo/confine_del_giorno.dart';
import 'il_sigillo_vivo.dart';
import 'la_chiamata_del_sigillo.dart';

/// **IL LIBRO DEI SIGILLI.** Ordine DO voce 06, 15 settembre 2026.
///
/// E' il posto dove stanno i sigilli della persona, ed e' la risposta a
/// *"cosa mi rimane"*: senza di lui nessun'altra voce dell'ordine ha un posto
/// dove esistere. Vive sul telefono, come il Diario dei Viaggi: un sigillo e'
/// una cosa privata, e l'intenzione per esteso non lascia il dispositivo.
///
/// **LE CHIAMATE LE TIENE LUI**, voce DO.08: un sigillo che entra programma
/// la sua, uno che si chiude la toglie, uno che si rinnova la sposta. Stare
/// qui e non nelle schermate vuol dire che nessuna porta del Libro puo'
/// cambiare una data senza cambiare la chiamata.
///
/// [orologio] e [avvisi] si iniettano nelle prove.
class LibroDeiSigilli extends ChangeNotifier {
  LibroDeiSigilli({
    DateTime Function()? orologio,
    this.avvisi = const AvvisiSpenti(),
  }) : _orologio = orologio ?? DateTime.now;

  final DateTime Function() _orologio;
  final ServizioAvvisi avvisi;

  static const String _chiave = 'sigilli.libro';
  static const String _chiaveDeiTracciamenti = 'sigilli.tracciamenti';

  final List<SigilloVivo> _sigilli = [];
  final List<DateTime> _tracciamenti = [];
  bool _aperto = false;

  DateTime get adesso => _orologio();
  bool get aperto => _aperto;

  /// **SI APRE DAL DISCO.** Un documento che non si legge si salta: un
  /// sigillo guasto non rompe il Libro.
  Future<void> apri() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _sigilli
        ..clear()
        ..addAll([
          for (final riga in prefs.getStringList(_chiave) ?? const <String>[])
            if (_leggi(riga) case final s?) s,
        ]);
      _tracciamenti
        ..clear()
        ..addAll([
          for (final t in prefs.getStringList(_chiaveDeiTracciamenti) ??
              const <String>[])
            if (DateTime.tryParse(t) case final d?) d,
        ]);
    } catch (errore) {
      // Senza disco il Libro resta vuoto e vivo: meglio che una schermata
      // che si rompe.
    }
    _aperto = true;
    notifyListeners();
  }

  static SigilloVivo? _leggi(String riga) {
    try {
      return SigilloVivo.fromJson(
          (jsonDecode(riga) as Map).cast<String, Object?>());
    } catch (errore) {
      // Una riga guasta si salta, le altre si leggono.
      return null;
    }
  }

  Future<void> _salva() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          _chiave, [for (final s in _sigilli) jsonEncode(s.toJson())]);
      // Dei tracciamenti serve solo oggi: il resto si butta.
      final oggi = ConfineDelGiorno.chiaveDi(adesso);
      await prefs.setStringList(_chiaveDeiTracciamenti, [
        for (final t in _tracciamenti)
          if (ConfineDelGiorno.chiaveDi(t) == oggi) t.toIso8601String(),
      ]);
    } catch (errore) {
      // Il disco che rifiuta non cancella cio' che e' in memoria.
    }
  }

  List<SigilloVivo> get tutti => List.unmodifiable(_sigilli);

  SigilloVivo? diId(String id) {
    for (final s in _sigilli) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// **I VIVI**, con la data che si avvicina per prima.
  List<SigilloVivo> get vivi => [
        for (final s in _sigilli)
          if (s.statoA(adesso) == StatoDelSigillo.vivo) s,
      ]..sort((a, b) => a.scadenza.compareTo(b.scadenza));

  /// **ARRIVATI ALLA LORO DATA**, e la persona non ha ancora risposto: la
  /// domanda della voce DO.05 aspetta qui.
  List<SigilloVivo> get scaduti => [
        for (final s in _sigilli)
          if (s.statoA(adesso) == StatoDelSigillo.scaduto) s,
      ]..sort((a, b) => a.scadenza.compareTo(b.scadenza));

  /// **COMPIUTI E LASCIATI**, in ordine di tempo, dal piu' recente.
  List<SigilloVivo> get chiusi => [
        for (final s in _sigilli)
          if (s.dichiarato != null) s,
      ]..sort((a, b) =>
          (b.chiusoIl ?? b.nascita).compareTo(a.chiusoIl ?? a.nascita));

  /// **QUANTI OCCUPANO LO SPAZIO**: i vivi e gli scaduti senza risposta.
  /// Uno scaduto non e' chiuso finche' la persona non lo chiude.
  int get aperti => vivi.length + scaduti.length;

  /// I tracciamenti di oggi, per il tetto tecnico della voce DO.11.
  int get tracciamentiOggi {
    final oggi = ConfineDelGiorno.chiaveDi(adesso);
    return _tracciamenti
        .where((t) => ConfineDelGiorno.chiaveDi(t) == oggi)
        .length;
  }

  /// **UN SIGILLO NUOVO NEL LIBRO**, tracciato adesso.
  Future<void> aggiungi(SigilloVivo sigillo) async {
    _sigilli.add(sigillo);
    _tracciamenti.add(adesso);
    await _salva();
    notifyListeners();
    await LaChiamataDelSigillo.programma(sigillo, avvisi, adesso: adesso);
  }

  /// **LA CARICA COL GESTO**, una al giorno per sigillo vivo. Falso se oggi
  /// era gia' stata fatta o se il sigillo non e' vivo.
  Future<bool> caricaIlSigillo(String id) async {
    final i = _sigilli.indexWhere((s) => s.id == id);
    if (i < 0 || !_sigilli[i].siPuoCaricareA(adesso)) return false;
    _sigilli[i] = _sigilli[i].conCarica(adesso);
    await _salva();
    notifyListeners();
    return true;
  }

  /// Il titolo e il responso scritti dal modello, quando arrivano.
  Future<void> scriviITesti(String id, String titolo, String responso) async {
    final i = _sigilli.indexWhere((s) => s.id == id);
    if (i < 0) return;
    _sigilli[i] = _sigilli[i].conITesti(titolo, responso);
    await _salva();
    notifyListeners();
  }

  Future<void> dichiara(String id, StatoDelSigillo stato,
      {String? testoDelCompimento}) async {
    assert(
        stato == StatoDelSigillo.compiuto || stato == StatoDelSigillo.lasciato);
    final i = _sigilli.indexWhere((s) => s.id == id);
    if (i < 0) return;
    _sigilli[i] = _sigilli[i]
        .dichiara(stato, adesso, testoDelCompimento: testoDelCompimento);
    await _salva();
    notifyListeners();
    await LaChiamataDelSigillo.annulla(id, avvisi);
  }

  Future<void> rinnova(String id, DateTime nuovaScadenza) async {
    final i = _sigilli.indexWhere((s) => s.id == id);
    if (i < 0) return;
    _sigilli[i] = _sigilli[i].rinnova(nuovaScadenza);
    await _salva();
    notifyListeners();
    // Stesso id, quindi la chiamata vecchia si sovrascrive con la nuova.
    await LaChiamataDelSigillo.programma(_sigilli[i], avvisi, adesso: adesso);
  }

  /// **IL COMANDO DI COLLAUDO**: la scadenza a oggi, per provare la domanda
  /// della voce DO.05 senza aspettare la data. Solo nella Demo.
  Future<void> anticipaLaScadenzaPerIlCollaudo(String id) async {
    final i = _sigilli.indexWhere((s) => s.id == id);
    if (i < 0) return;
    _sigilli[i] = _sigilli[i].conScadenza(adesso);
    await _salva();
    notifyListeners();
  }
}

/// **PERCHE' UN SIGILLO NUOVO SI PUO' TRACCIARE O NO.** Ordine DO voce 11.
enum EsitoDelTracciamento {
  si,

  /// I sigilli aperti sono gia' quanti il piano ne tiene insieme: si porta
  /// la persona al Libro, a chiuderne uno.
  pieno,

  /// Dieci tracciamenti oggi, contando tutto: la difesa dai costi.
  tettoTecnico,
}

/// **I LIMITI, E SONO DI SPAZIO E NON DI TEMPO.** Ordine DO voce 11, parole
/// del fondatore: *"quanti sigilli vivi insieme, non quanti al mese"*.
abstract final class ILimitiDelSigillo {
  /// Quanti sigilli vivi insieme per [tier], letti dalla matrice dei piani,
  /// che resta la fonte unica.
  static int viviInsiemePer(Tier tier) =>
      PlanCatalog.limiteGiornaliero(RigaDelPiano.sigilliVivi, tier) ?? 0;

  /// **IL TETTO TECNICO OLTRE IL PIANO**: dieci tracciamenti al giorno,
  /// contando tutto. Non e' un'offerta, e' la difesa dai costi.
  static const int tettoTecnicoAlGiorno = 10;

  static EsitoDelTracciamento puoTracciare(Tier tier, LibroDeiSigilli libro) {
    if (libro.tracciamentiOggi >= tettoTecnicoAlGiorno) {
      return EsitoDelTracciamento.tettoTecnico;
    }
    if (libro.aperti >= viviInsiemePer(tier)) return EsitoDelTracciamento.pieno;
    return EsitoDelTracciamento.si;
  }
}

/// Un identificativo per un sigillo nuovo, dal suo istante di nascita.
String idDelSigillo(DateTime nascita) =>
    's${nascita.microsecondsSinceEpoch.toRadixString(36)}';

/// Per le prove: il Libro scritto su un disco finto.
@visibleForTesting
Future<void> svuotaIlLibroPerLeProve() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(LibroDeiSigilli._chiave);
  await prefs.remove(LibroDeiSigilli._chiaveDeiTracciamenti);
}
