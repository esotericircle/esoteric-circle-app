import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'plan_catalog.dart';
import '../tempo/confine_del_giorno.dart';
import 'tier.dart';

/// Contatore locale delle domande ai Maestri, per tier.
///
/// Il limite giornaliero di risposte Breve a un Maestro segue la mappa dei
/// piani: Viandante 3, Iniziato 5, Adepto 10, Illuminato illimitate. Le tre del
/// Free sono spendibili anche su Maestri diversi. Il conteggio si azzera al
/// cambio di giorno. Il confronto a piu' Maestri (sintesi comparativa) resta
/// riservato al Tier a pagamento.
///
/// L'orologio e' iniettabile per i test; la persistenza e' best effort su
/// `SharedPreferences`, senza crash se non e' disponibile.
class QuestionAllowance extends ChangeNotifier {
  QuestionAllowance({
    DateTime Function()? clock,
    this.freeDailyLimit,
  }) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  /// Un limite imposto dall'esterno, solo per i test: nell'app resta nullo e
  /// il numero arriva dalla matrice.
  final int? freeDailyLimit;

  /// Il limite giornaliero per tier, oppure null se illimitato.
  ///
  /// LO LEGGE DALLA MATRICE dei piani, che e' la fonte di cio' che si promette
  /// alla persona. Prima i numeri erano scritti qui: la matrice prometteva al
  /// Viandante una domanda al giorno e questo file ne concedeva tre, quindi la
  /// promessa e l'imposizione erano due cose diverse, e a rimetterci era solo
  /// una delle due parti.
  int? dailyLimit(Tier tier) {
    if (tier == Tier.free && freeDailyLimit != null) return freeDailyLimit;
    return PlanCatalog.limiteGiornaliero(PlanCatalog.rigaDomande, tier);
  }

  /// Il limite giornaliero degli APPROFONDIMENTI, cioe' di quante volte si puo'
  /// chiedere "Vai più a fondo" sulla stessa risposta.
  ///
  /// E' un budget diverso da quello delle domande, e vive nella stessa classe
  /// apposta: il giorno e' lo stesso, quindi il ribaltamento a mezzanotte deve
  /// essere lo stesso. Due classi avrebbero avuto due rollover, e due rollover
  /// prima o poi divergono.
  ///
  /// **L'approfondimento non consuma una domanda.** Se la consumasse, la
  /// persona esiterebbe prima di toccarlo, e l'esitazione uccide l'intimita'.
  int? limiteApprofondimenti(Tier tier) =>
      PlanCatalog.limiteGiornaliero(PlanCatalog.rigaApprofondimenti, tier);

  /// Il tetto di CORRETTEZZA per chi non ha limite: non e' una restrizione
  /// commerciale, e' la difesa contro un tocco ripetuto per sbaglio o per
  /// gioco. Chi arriva qui in un giorno solo non sta piu' leggendo.
  static const int kTettoDiCorrettezza = 30;

  /// Quanti approfondimenti restano oggi.
  int approfondimentiRimasti(Tier tier) {
    _rollover();
    final limite = limiteApprofondimenti(tier);
    if (limite == null) {
      final left = kTettoDiCorrettezza - _approfondimenti;
      return left < 0 ? 0 : left;
    }
    final left = limite - _approfondimenti;
    return left < 0 ? 0 : left;
  }

  /// Vero se questo piano prevede l'approfondimento, a prescindere da quanti ne
  /// restano oggi. Serve alla UI per distinguere DUE cose che non vanno
  /// confuse: chi non ce l'ha nel piano riceve l'invito a salire, chi ce l'ha e
  /// li ha finiti riceve il numero vero e l'ora in cui torna.
  bool pianoConApprofondimento(Tier tier) {
    final limite = limiteApprofondimenti(tier);
    return limite == null || limite > 0;
  }

  /// Se si puo' approfondire adesso.
  bool puoiApprofondire(Tier tier) =>
      pianoConApprofondimento(tier) && approfondimentiRimasti(tier) > 0;

  /// Registra un approfondimento consumato. Anche i tier senza limite lo
  /// contano, perche' il tetto di correttezza vale per tutti.
  void registraApprofondimento(Tier tier) {
    if (!pianoConApprofondimento(tier)) return;
    _rollover();
    _approfondimenti++;
    notifyListeners();
    _persist();
  }

  static const _kDay = 'allowance.day';
  static const _kCount = 'allowance.count';
  static const _kApprofondimenti = 'allowance.approfondimenti';
  static const _kConfronti = 'allowance.confronti';

  int _count = 0;
  int _approfondimenti = 0;
  int _confronti = 0;
  String _day = '';

  /// Il giorno d'uso, dal punto SOLO in cui e' definito.
  ///
  /// Era scritto qui dentro, e quando l'Eco ha avuto bisogno dello stesso
  /// confine copiarlo avrebbe voluto dire due definizioni dello stesso giorno
  /// che devono restare d'accordo. Vedi `ConfineDelGiorno`, dove sta anche la
  /// ragione per cui il confine RITUALE, a mezzogiorno, e' un'altra cosa.
  String _today() => ConfineDelGiorno.chiaveDi(_clock());

  // Se e' cambiato il giorno, azzera il conteggio.
  void _rollover() {
    final t = _today();
    if (t != _day) {
      _day = t;
      _count = 0;
      // I TRE budget ribaltano INSIEME, perche' il giorno e' lo stesso.
      //
      // Un secondo confine del giorno accanto a questo divergerebbe alla prima
      // ora legale: `ConfineDelGiorno` e' uno, e questi tre contatori lo
      // guardano tutti da qui.
      _approfondimenti = 0;
      _confronti = 0;
    }
  }

  /// Domande consumate oggi.
  int usedToday() {
    _rollover();
    return _count;
  }

  /// Domande singole ancora disponibili oggi. Per un tier illimitato restituisce
  /// un numero molto alto.
  int remaining(Tier tier) {
    final limit = dailyLimit(tier);
    if (limit == null) return 1 << 30;
    _rollover();
    final left = limit - _count;
    return left < 0 ? 0 : left;
  }

  /// Se l'utente puo' porre un'altra domanda singola adesso.
  bool canAsk(Tier tier) {
    final limit = dailyLimit(tier);
    if (limit == null) return true;
    _rollover();
    return _count < limit;
  }

  /// Se il PIANO comprende il confronto a piu' Maestri.
  ///
  /// **Adesso lo legge dalla matrice, e prima lo decideva da solo.** Diceva
  /// `tier != Tier.free`, cioe' era un secondo posto dove si stabiliva chi
  /// puo' cosa, accanto a quello vero. Un secondo sistema diverge sempre dal
  /// primo, ed e' la stessa correzione gia' fatta per la memoria dei Maestri.
  bool canCompare(Tier tier) =>
      PlanCatalog.limiteGiornaliero(PlanCatalog.rigaConfronti, tier) != 0;

  /// Quanti confronti al giorno prevede il piano, oppure null se illimitato.
  int? limiteConfronti(Tier tier) =>
      PlanCatalog.limiteGiornaliero(PlanCatalog.rigaConfronti, tier);

  /// Quanti confronti restano oggi.
  ///
  /// **Perche' esiste un tetto separato.** Un confronto non consuma domande in
  /// piu' di quella gia' pagata nella chat, ed e' misurato: aprendo il
  /// Consiglio dalla conversazione le altre due letture arrivano senza
  /// contare, quindi il numero e' zero e non tre. Senza un tetto suo il gesto
  /// sarebbe gratuito e ripetibile all'infinito, mentre ogni tocco sono due
  /// chiamate al modello.
  int confrontiRimasti(Tier tier) {
    _rollover();
    final limite = limiteConfronti(tier);
    if (limite == null) {
      final resta = kTettoDiCorrettezza - _confronti;
      return resta < 0 ? 0 : resta;
    }
    final resta = limite - _confronti;
    return resta < 0 ? 0 : resta;
  }

  /// Se si puo' fare un altro confronto adesso.
  bool puoiConfrontare(Tier tier) =>
      canCompare(tier) && confrontiRimasti(tier) > 0;

  /// Registra un confronto consumato.
  void registraConfronto(Tier tier) {
    if (!canCompare(tier)) return;
    _rollover();
    _confronti++;
    notifyListeners();
    _persist();
  }

  /// COME SI DICE IL RESIDUO, prima del tocco.
  ///
  /// **Una formula sola, senza accordo grammaticale.** "Oggi te ne resta 1 su
  /// 3" vale per uno come per tre: non c'e' nessun singolare da tenere
  /// d'accordo con un plurale, quindi non c'e' nessun posto dove il plurale si
  /// possa dimenticare. E' la stessa scelta gia' fatta per le domande.
  ///
  /// Nullo quando non c'e' un numero da dire: senza il piano non e' un
  /// residuo, e' un lucchetto, e lo dice la porta. Senza limite non e' un
  /// residuo, e' un cammino senza conto da tenere.
  String? residuoDeiConfronti(Tier tier) {
    if (!canCompare(tier)) return null;
    final limite = limiteConfronti(tier);
    if (limite == null) return null;
    return 'Oggi te ne resta ${confrontiRimasti(tier)} su $limite';
  }

  /// Registra una domanda consumata. I tier con un limite finito intaccano il
  /// contatore; quello illimitato no.
  void record(Tier tier) {
    if (dailyLimit(tier) == null) return;
    _rollover();
    _count++;
    notifyListeners();
    _persist();
  }

  /// Carica il conteggio salvato, best effort.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _day = prefs.getString(_kDay) ?? '';
      _count = prefs.getInt(_kCount) ?? 0;
      _approfondimenti = prefs.getInt(_kApprofondimenti) ?? 0;
      _confronti = prefs.getInt(_kConfronti) ?? 0;
      _rollover();
      notifyListeners();
    } catch (_) {
      // Nessuna persistenza: si resta sui valori in memoria.
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kDay, _day);
      await prefs.setInt(_kCount, _count);
      await prefs.setInt(_kApprofondimenti, _approfondimenti);
      await prefs.setInt(_kConfronti, _confronti);
    } catch (_) {
      // Best effort.
    }
  }
}
