import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/server/porta_del_cerchio.dart';
import '../astro/zodiac.dart';
import '../brand/brand.dart';
import '../condivisione/porta_della_condivisione.dart';
import '../identity/birth_identity.dart';
import '../maestro/maestro.dart';
import 'l_arte_di_adesso.dart';

/// **IL SEMAFORINO ACCANTO AL NOME, ordine EY voce 05.** Quattro stati, come
/// li vede chi guarda. **Il rosso non esiste negli elenchi**: vive solo
/// nell'elenco delle persone bloccate, dentro il menu' del profilo.
enum Semaforo {
  /// Nessuna relazione.
  spento,

  /// L'ho invitato io e aspetto: il tocco non fa niente oltre a dirlo.
  arancioneChiaro,

  /// Mi ha invitato: il tocco apre accetta oppure rifiuta.
  arancionePieno,

  /// Amici: il tocco apre la sua scheda.
  verde;

  static Semaforo da(Object? nome) =>
      values.firstWhere((s) => s.name == nome, orElse: () => Semaforo.spento);
}

/// La visibilita' della presenza. **Il valore predefinito, per tutti, e'
/// "amici"**; l'invisibilita' e' gratuita per tutti i piani.
enum VisibilitaNelCerchio {
  amici,
  tutti,
  invisibile;

  static VisibilitaNelCerchio da(Object? nome) =>
      values.firstWhere((v) => v.name == nome,
          orElse: () => VisibilitaNelCerchio.amici);
}

/// Perche' una persona simile compare nella tendina: il criterio si dichiara
/// a schermo, una riga sotto ogni nome.
enum CriterioDiSomiglianza {
  stessoSegno('Stesso segno'),
  stessoMaestro('Stesso Maestro'),
  stessoGradino('Stesso gradino del Cammino'),
  affinitaAlta('Affinità alta col tuo cielo di oggi');

  const CriterioDiSomiglianza(this.riga);
  final String riga;

  static CriterioDiSomiglianza? da(Object? nome) {
    for (final c in values) {
      if (c.name == nome) return c;
    }
    return null;
  }
}

/// Il mio profilo nel Cerchio, come lo mostra il menu' del profilo.
@immutable
class ProfiloNelCerchio {
  const ProfiloNelCerchio({
    required this.uid,
    required this.sigillo,
    required this.nome,
    required this.icona,
    required this.visibilita,
    required this.visibilitaEffettiva,
    required this.soloColSigillo,
    required this.nomeSiRiapre,
    required this.primoNomeLibero,
  });

  final String uid;
  final String sigillo;
  final String nome;
  final String icona;
  final VisibilitaNelCerchio visibilita;

  /// Quella che vale davvero: per un minorenne "tutti" vale "amici".
  final VisibilitaNelCerchio visibilitaEffettiva;
  final bool soloColSigillo;

  /// Il giorno in cui il cambio del nome si riapre, o nullo se e' aperto.
  final DateTime? nomeSiRiapre;
  final bool primoNomeLibero;

  bool get haUnNome => nome.isNotEmpty;

  factory ProfiloNelCerchio.da(Map<String, Object?> d) => ProfiloNelCerchio(
        uid: d['uid'] as String? ?? '',
        sigillo: d['sigillo'] as String? ?? '',
        nome: d['nome'] as String? ?? '',
        icona: d['icona'] as String? ?? 'segno:0',
        visibilita: VisibilitaNelCerchio.da(d['visibilita']),
        visibilitaEffettiva: VisibilitaNelCerchio.da(d['visibilitaEffettiva']),
        soloColSigillo: d['chiPuoInvitare'] == 'sigillo',
        nomeSiRiapre: d['nomeSiRiapre'] is num
            ? DateTime.fromMillisecondsSinceEpoch(
                (d['nomeSiRiapre'] as num).toInt())
            : null,
        primoNomeLibero: d['primoNomeLibero'] == true,
      );
}

/// Una persona del Cerchio come la vede chi guarda. **Il sigillo c'e' per
/// disegnare il glifo del legame, ma non si mostra sotto il nome negli
/// elenchi**: si mostra solo nel profilo e nella ricerca col sigillo.
@immutable
class PersonaDelCerchio {
  const PersonaDelCerchio({
    required this.uid,
    required this.nome,
    required this.icona,
    this.segno,
    this.maestro,
    this.gradino = 0,
    this.sigillo,
    this.semaforo = Semaforo.spento,
    this.tratti = 0,
    this.arte,
    this.criterio,
    this.invitabile = false,
  });

  final String uid;
  final String nome;
  final String icona;
  final Zodiac? segno;
  final Maestro? maestro;
  final int gradino;
  final String? sigillo;
  final Semaforo semaforo;

  /// I tratti accesi del glifo del legame (EY.14).
  final int tratti;

  /// Cosa sta facendo, in forma generica, quando e' presente.
  final ArteDellaPresenza? arte;
  final CriterioDiSomiglianza? criterio;

  /// Chi accetta inviti da tutti si puo' invitare dalla tendina.
  final bool invitabile;

  factory PersonaDelCerchio.da(Map<String, Object?> d) => PersonaDelCerchio(
        uid: d['uid'] as String? ?? '',
        nome: (d['nome'] as String?) ?? 'Una persona del Cerchio',
        icona: d['icona'] as String? ?? 'segno:0',
        segno:
            d['segno'] is String ? Zodiac.fromId(d['segno'] as String) : null,
        maestro: _maestro(d['maestro']),
        gradino: (d['gradino'] as num?)?.toInt() ?? 0,
        sigillo: d['sigillo'] as String?,
        semaforo: Semaforo.da(d['semaforo']),
        tratti: (d['tratti'] as num?)?.toInt() ?? 0,
        arte: d['arte'] is String
            ? ArteDellaPresenza.values.firstWhere((a) => a.name == d['arte'],
                orElse: () => ArteDellaPresenza.cerchio)
            : null,
        criterio: CriterioDiSomiglianza.da(d['criterio']),
        invitabile: d['invitabile'] == true,
      );

  PersonaDelCerchio conSemaforo(Semaforo s) => PersonaDelCerchio(
      uid: uid,
      nome: nome,
      icona: icona,
      segno: segno,
      maestro: maestro,
      gradino: gradino,
      sigillo: sigillo,
      semaforo: s,
      tratti: tratti,
      arte: arte,
      criterio: criterio,
      invitabile: invitabile);
}

Maestro? _maestro(Object? id) {
  for (final m in Maestro.values) {
    if (m.name == id) return m;
  }
  return null;
}

/// Un segno passato fra due amici, mandato o ricevuto.
@immutable
class SegnoScambiato {
  const SegnoScambiato({
    required this.id,
    required this.segno,
    required this.ricevuto,
    required this.con,
    required this.nomeCon,
    required this.maestroCon,
    required this.quando,
    this.risposta,
    this.reazione,
  });

  final String id;
  final String segno;
  final bool ricevuto;
  final String con;
  final String nomeCon;
  final Maestro? maestroCon;
  final DateTime? quando;
  final int? risposta;
  final String? reazione;

  bool get risposto => risposta != null || reazione != null;

  factory SegnoScambiato.da(Map<String, Object?> d) => SegnoScambiato(
        id: d['id'] as String? ?? '',
        segno: d['segno'] as String? ?? '',
        ricevuto: d['verso'] == 'ricevuto',
        con: d['con'] as String? ?? '',
        nomeCon: d['nomeCon'] as String? ?? 'Una persona del Cerchio',
        maestroCon: _maestro(d['maestroCon']),
        quando: d['quando'] is num
            ? DateTime.fromMillisecondsSinceEpoch((d['quando'] as num).toInt())
            : null,
        risposta: (d['risposta'] as num?)?.toInt(),
        reazione: d['reazione'] as String?,
      );
}

/// Un dono ricevuto: resta nel profilo come ornamento.
@immutable
class DonoRicevuto {
  const DonoRicevuto(
      {required this.id, required this.dono, required this.nomeDa});
  final String id;
  final String dono;
  final String nomeDa;

  factory DonoRicevuto.da(Map<String, Object?> d) => DonoRicevuto(
        id: d['id'] as String? ?? '',
        dono: d['dono'] as String? ?? 'cenno',
        nomeDa: d['nomeDa'] as String? ?? 'Una persona del Cerchio',
      );
}

/// Il mio Cerchio: amici, inviti, bloccati, segni e doni recenti.
@immutable
class IlMioCerchio {
  const IlMioCerchio({
    this.amici = const [],
    this.ricevuti = const [],
    this.inviati = const [],
    this.bloccati = const [],
    this.posti = 3,
    this.segniOggi = 0,
    this.segniAlGiorno = 5,
    this.segni = const [],
    this.doni = const [],
  });

  final List<PersonaDelCerchio> amici;
  final List<PersonaDelCerchio> ricevuti;
  final List<PersonaDelCerchio> inviati;
  final List<PersonaDelCerchio> bloccati;
  final int posti;
  final int segniOggi;
  final int segniAlGiorno;
  final List<SegnoScambiato> segni;
  final List<DonoRicevuto> doni;

  static List<T> _lista<T>(Object? v, T Function(Map<String, Object?>) fai) =>
      v is List
          ? [
              for (final x in v)
                if (x is Map) fai(Map<String, Object?>.from(x)),
            ]
          : <T>[];

  factory IlMioCerchio.da(Map<String, Object?> d) => IlMioCerchio(
        amici: _lista(d['amici'], PersonaDelCerchio.da),
        ricevuti: _lista(d['ricevuti'], PersonaDelCerchio.da),
        inviati: _lista(d['inviati'], PersonaDelCerchio.da),
        bloccati: _lista(d['bloccati'], PersonaDelCerchio.da),
        posti: (d['posti'] as num?)?.toInt() ?? 3,
        segniOggi: (d['segniOggi'] as num?)?.toInt() ?? 0,
        segniAlGiorno: (d['segniAlGiorno'] as num?)?.toInt() ?? 5,
        segni: _lista(d['segni'], SegnoScambiato.da),
        doni: _lista(d['doni'], DonoRicevuto.da),
      );

  /// Il semaforo di una persona, come lo vedo io.
  Semaforo semaforoDi(String uid) {
    if (amici.any((p) => p.uid == uid)) return Semaforo.verde;
    if (ricevuti.any((p) => p.uid == uid)) return Semaforo.arancionePieno;
    if (inviati.any((p) => p.uid == uid)) return Semaforo.arancioneChiaro;
    return Semaforo.spento;
  }
}

/// La tendina dell'indicatore online (EY.08).
@immutable
class LaTendina {
  const LaTendina({
    this.amiciPresenti = const [],
    this.perArte = const {},
    this.somiglianti = const [],
    this.visibilita = VisibilitaNelCerchio.amici,
  });

  final List<PersonaDelCerchio> amiciPresenti;
  final Map<ArteDellaPresenza, int> perArte;
  final List<PersonaDelCerchio> somiglianti;

  /// La mia visibilita' effettiva: l'invisibile lo legge nella sua riga.
  final VisibilitaNelCerchio visibilita;

  factory LaTendina.da(Map<String, Object?> d) {
    final perArte = <ArteDellaPresenza, int>{};
    final grezzo = d['perArte'];
    if (grezzo is Map) {
      for (final e in grezzo.entries) {
        for (final a in ArteDellaPresenza.values) {
          if (a.name == e.key && e.value is num) {
            perArte[a] = (e.value as num).toInt();
          }
        }
      }
    }
    final io = d['io'];
    return LaTendina(
      amiciPresenti:
          IlMioCerchio._lista(d['amiciPresenti'], PersonaDelCerchio.da),
      perArte: perArte,
      somiglianti: IlMioCerchio._lista(d['somiglianti'], PersonaDelCerchio.da),
      visibilita: VisibilitaNelCerchio.da(io is Map ? io['visibilita'] : null),
    );
  }
}

/// L'esito di un gesto sociale: riuscito, oppure la riga che dice perche'
/// no. **Mai un esito finto**: quando il Cerchio non risponde lo si dice.
@immutable
class EsitoDelGesto {
  const EsitoDelGesto({required this.ok, this.riga, this.dati = const {}});

  final bool ok;
  final String? riga;
  final Map<String, Object?> dati;

  /// **IL RIPIEGO DICHIARATO**: senza rete o con la funzione non ancora
  /// pubblicata il gesto non parte, e la persona lo legge.
  static const EsitoDelGesto silenzio = EsitoDelGesto(
      ok: false, riga: 'Il Cerchio non risponde adesso: riprova fra poco.');
}

/// **IL MOTORE SOCIALE DEL CERCHIO, dal lato del telefono. Ordine EY.**
///
/// Il telefono propone e il server decide: ogni gesto passa da una porta del
/// server con il suo tetto (EY.16), e qui si tiene solo cio' che il server
/// ha risposto. Nessun gesto si compie sul telefono da solo.
class IlCerchioSociale extends ChangeNotifier {
  IlCerchioSociale({required PortaDelCerchio porta}) : _porta = porta {
    // **LA CARD PORTA IL LINK, ordine EY voce 15**: la porta unica della
    // condivisione chiede il codice qui, e lo aggiunge lei.
    PortaDellaCondivisione.codiceDellInvito = codiceDelLink;
  }

  final PortaDelCerchio _porta;

  /// La chiave del nome scelto nell'onboarding, prima che il server lo
  /// riceva: il telefono lo propone alla prima occasione.
  static const String chiaveDelNomeProposto = 'cerchio.nomeProposto';

  /// La chiave del Maestro rivelato nel Risveglio: il Maestro di riferimento
  /// del profilo pubblico.
  static const String chiaveDelMaestro = 'cerchio.maestroDiRiferimento';

  ProfiloNelCerchio? _profilo;
  IlMioCerchio _cerchio = const IlMioCerchio();
  LaTendina? _tendina;

  ProfiloNelCerchio? get profilo => _profilo;
  IlMioCerchio get cerchio => _cerchio;
  LaTendina? get tendina => _tendina;
  bool get vivo => _porta.viva;

  Future<EsitoSociale?> _chiedi(String porta,
      [Map<String, Object?> corpo = const {}]) async {
    try {
      return await _porta.sociale(porta, corpo);
    } catch (errore) {
      debugPrint('Cerchio: $porta non risponde. $errore');
      return null;
    }
  }

  EsitoDelGesto _esito(EsitoSociale? e) {
    if (e == null) return EsitoDelGesto.silenzio;
    if (e.rifiutato) {
      return EsitoDelGesto(ok: false, riga: e.rigaDaMostrare, dati: e.dati);
    }
    return EsitoDelGesto(
        ok: e.dati['ok'] != false,
        riga: e.dati['riga'] as String?,
        dati: e.dati);
  }

  /// **MAGGIORENNE, dalla data di nascita che il profilo ha gia'**, senza
  /// chiedere niente in piu'. Senza data nessuno e' maggiorenne: la presenza
  /// pubblica resta chiusa invece di aprirsi per un dato che manca.
  static bool maggiorenne(BirthIdentity? identita, DateTime oggi) {
    if (identita == null || identita.isExample) return false;
    final n = identita.birthDate;
    var anni = oggi.year - n.year;
    if (oggi.month < n.month || (oggi.month == n.month && oggi.day < n.day)) {
      anni--;
    }
    return anni >= 18;
  }

  /// Sincronizza il profilo: il segno (mai la data), il Maestro, il gradino
  /// del Cammino e la maggiore eta'. Se l'onboarding ha lasciato un nome da
  /// proporre e il server non ne ha ancora uno, lo propone adesso.
  Future<void> sincronizza({
    BirthIdentity? identita,
    Maestro? maestro,
    int gradino = 0,
    DateTime? oggi,
  }) async {
    if (!vivo) return;
    final segno = identita?.sunSign;
    final esito = await _chiedi('ilMioProfiloNelCerchio', {
      if (segno != null) 'segno': segno.id,
      if (maestro != null) 'maestro': maestro.name,
      'gradino': gradino,
      'maggiorenne': maggiorenne(identita, oggi ?? DateTime.now()),
    });
    if (esito == null || esito.rifiutato) return;
    _profilo = ProfiloNelCerchio.da(esito.dati);
    notifyListeners();
    if (!_profilo!.haUnNome) {
      final proposto = await _nomeProposto();
      if (proposto != null) await scegliIlNome(proposto);
    }
  }

  static Future<String?> _nomeProposto() async {
    try {
      final p = await SharedPreferences.getInstance();
      final v = p.getString(chiaveDelNomeProposto);
      return v == null || v.trim().isEmpty ? null : v;
    } catch (errore) {
      return null;
    }
  }

  /// Il nome scelto nell'onboarding resta qui finche' il server lo riceve.
  static Future<void> proponiIlNome(String nome) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(chiaveDelNomeProposto, nome.trim());
    } catch (errore) {
      debugPrint('Cerchio: il nome proposto non si salva. $errore');
    }
  }

  static Future<void> ricordaIlMaestro(Maestro maestro) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(chiaveDelMaestro, maestro.name);
    } catch (errore) {
      debugPrint('Cerchio: il Maestro non si salva. $errore');
    }
  }

  static Future<Maestro?> ilMaestroRicordato() async {
    try {
      final p = await SharedPreferences.getInstance();
      return _maestro(p.getString(chiaveDelMaestro));
    } catch (errore) {
      return null;
    }
  }

  /// SCEGLI IL NOME (EY.01): il server decide, e la riga del rifiuto e'
  /// la sua.
  Future<EsitoDelGesto> scegliIlNome(String nome) async {
    final e = await _chiedi('scegliIlNome', {'nome': nome.trim()});
    final esito = _esito(e);
    final profilo = e?.dati['profilo'];
    if (profilo is Map) {
      _profilo = ProfiloNelCerchio.da(Map<String, Object?>.from(profilo));
      try {
        final p = await SharedPreferences.getInstance();
        await p.remove(chiaveDelNomeProposto);
      } catch (senzaQuelDato) {
        // Il dato e' facoltativo: senza, si va avanti col ripiego.
      }
      notifyListeners();
    }
    return esito;
  }

  /// L'icona, la visibilita' e chi puo' invitarti (EY.03, EY.09).
  Future<EsitoDelGesto> aggiorna({
    String? icona,
    VisibilitaNelCerchio? visibilita,
    bool? soloColSigillo,
  }) async {
    final e = await _chiedi('aggiornaIlProfiloNelCerchio', {
      if (icona != null) 'icona': icona,
      if (visibilita != null) 'visibilita': visibilita.name,
      if (soloColSigillo != null)
        'chiPuoInvitare': soloColSigillo ? 'sigillo' : 'tutti',
    });
    if (e != null && !e.rifiutato) {
      _profilo = ProfiloNelCerchio.da(e.dati);
      notifyListeners();
      return const EsitoDelGesto(ok: true);
    }
    return _esito(e);
  }

  // ---- IL CODICE DELL'INVITO, EY.04 ed EY.17 ----

  static String? _codiceDelLink;
  static DateTime? _scadenzaDelLink;

  /// Il codice del link gia' in tasca, se vale ancora: la porta della
  /// condivisione lo mette nelle card senza aspettare la rete.
  static String? get codiceDelLinkValido {
    final s = _scadenzaDelLink;
    if (_codiceDelLink == null || s == null) return null;
    return DateTime.now().isBefore(s) ? _codiceDelLink : null;
  }

  /// Per le prove: il codice del link come se il server lo avesse dato.
  @visibleForTesting
  static void codiceDelLinkPerLaProva(String? codice, {DateTime? scade}) {
    _codiceDelLink = codice;
    _scadenzaDelLink = scade ?? DateTime.now().add(const Duration(days: 1));
  }

  /// Il link d'invito di un codice: sul dominio del progetto, accanto a
  /// `/entra`. **Nel link c'e' solo il codice opaco**, mai l'uid.
  static String linkDi(String codice, {Maestro? maestro}) =>
      '${Brand.urlDegliInviti}/i/$codice'
      '${maestro == null ? '' : '.${maestro.name}'}';

  /// IL CODICE DA UN LINK O DA UN CODICE INQUADRATO, oppure nullo. Le forme:
  /// `https://esotericircle.app/i/CODICE(.maestro)`, `esotericircle://i/CODICE`
  /// e il codice nudo di sei o otto caratteri. Il formato vecchio con l'uid
  /// (`?invito=`) non apre un legame: resta del riscatto, che lo accetta
  /// ancora per compatibilita' dichiarata.
  static String? codiceDaUnLink(String grezzo) {
    final testo = grezzo.trim();
    final uri = Uri.tryParse(testo);
    String? corpo;
    if (uri != null && uri.scheme == 'esotericircle' && uri.host == 'i') {
      corpo = uri.pathSegments.isEmpty ? null : uri.pathSegments.first;
    } else if (uri != null &&
        uri.pathSegments.length >= 2 &&
        uri.pathSegments.first == 'i' &&
        (testo.startsWith(Brand.url) ||
            testo.startsWith(Brand.urlDegliInviti))) {
      corpo = uri.pathSegments[1];
    } else if (RegExp(r'^[0-9A-Za-z]{6}$|^[0-9A-Za-z]{8}$').hasMatch(testo)) {
      corpo = testo;
    }
    if (corpo == null) return null;
    final senzaPorta = corpo.split('.').first.toUpperCase();
    return RegExp(r'^[0-9A-Z]{6}$|^[0-9A-Z]{8}$').hasMatch(senzaPorta)
        ? senzaPorta
        : null;
  }

  /// Chiede al server il codice del link (trenta giorni) o quello da
  /// inquadrare (cinque minuti), lo rinnova o lo revoca.
  Future<({String? codice, DateTime? scade})?> codice({
    bool vicino = false,
    bool rinnova = false,
    bool revoca = false,
  }) async {
    final e = await _chiedi('ilCodiceDellInvito', {
      'tipo': vicino ? 'vicino' : 'link',
      if (rinnova) 'rinnova': true,
      if (revoca) 'revoca': true,
    });
    if (e == null || e.rifiutato) return null;
    final c = e.dati['codice'] as String?;
    final s = e.dati['scade'] is num
        ? DateTime.fromMillisecondsSinceEpoch((e.dati['scade'] as num).toInt())
        : null;
    if (!vicino) {
      _codiceDelLink = c;
      _scadenzaDelLink = s;
    }
    return (codice: c, scade: s);
  }

  /// Il codice del link, chiesto al server solo se quello in tasca non vale.
  Future<String?> codiceDelLink() async {
    final gia = codiceDelLinkValido;
    if (gia != null) return gia;
    if (!vivo) return null;
    return (await codice())?.codice;
  }

  /// Chi chiama con un codice, prima di decidere (EY.04).
  Future<({bool valido, PersonaDelCerchio? chi, Semaforo semaforo})>
      leggiIlCodice(String codice) async {
    final e = await _chiedi('leggiIlCodice', {'codice': codice});
    final chi = e?.dati['chi'];
    if (e == null || e.rifiutato || e.dati['valido'] != true || chi is! Map) {
      return (valido: false, chi: null, semaforo: Semaforo.spento);
    }
    return (
      valido: true,
      chi: PersonaDelCerchio.da(Map<String, Object?>.from(chi)),
      semaforo: Semaforo.da(e.dati['semaforo']),
    );
  }

  /// Chiede il legame: col codice (si diventa amici), col sigillo o dalla
  /// tendina (parte l'invito).
  Future<EsitoDelGesto> chiediIlLegame(
      {String? codice, String? sigillo, String? uid}) async {
    final e = await _chiedi('chiediIlLegame', {
      if (codice != null) 'codice': codice,
      if (sigillo != null) 'sigillo': sigillo,
      if (uid != null) 'uid': uid,
    });
    final esito = _esito(e);
    if (esito.ok) await caricaIlCerchio();
    return esito;
  }

  /// Accetta, rifiuta o togli.
  Future<EsitoDelGesto> rispondiAlLegame(String uid, String azione) async {
    final esito = _esito(
        await _chiedi('rispondiAlLegame', {'uid': uid, 'azione': azione}));
    await caricaIlCerchio();
    return esito;
  }

  Future<EsitoDelGesto> blocca(String uid, {bool sblocca = false}) async {
    final esito = _esito(await _chiedi(
        'bloccaUnaPersona', {'uid': uid, if (sblocca) 'sblocca': true}));
    await caricaIlCerchio();
    return esito;
  }

  Future<void> caricaIlCerchio() async {
    if (!vivo) return;
    final e = await _chiedi('ilMioCerchio');
    if (e == null || e.rifiutato) return;
    _cerchio = IlMioCerchio.da(e.dati);
    notifyListeners();
  }

  Future<EsitoDelGesto> caricaLaTendina() async {
    final e = await _chiedi('laTendinaDelCerchio');
    if (e == null || e.rifiutato) return _esito(e);
    _tendina = LaTendina.da(e.dati);
    notifyListeners();
    return const EsitoDelGesto(ok: true);
  }

  Future<EsitoDelGesto> compraUnPosto() async {
    final e = await _chiedi('compraUnPostoNelCerchio',
        {'idMovimento': PortaDelCerchio.nuovoIdentificativo('posto')});
    final esito = _esito(e);
    if (esito.ok) await caricaIlCerchio();
    return esito;
  }

  // ---- I GESTI, EY.10, EY.11, EY.12 ----

  Future<EsitoDelGesto> mandaUnSegno(String a, String segno) async {
    final esito =
        _esito(await _chiedi('mandaUnSegno', {'a': a, 'segno': segno}));
    if (esito.ok) await caricaIlCerchio();
    return esito;
  }

  Future<EsitoDelGesto> rispondiAlSegno(String id,
      {int? risposta, String? reazione}) async {
    final esito = _esito(await _chiedi('rispondiAlSegno', {
      'id': id,
      if (risposta != null) 'risposta': risposta,
      if (reazione != null) 'reazione': reazione,
    }));
    if (esito.ok) await caricaIlCerchio();
    return esito;
  }

  Future<EsitoDelGesto> mandaUnDono(String a, String dono) async {
    return _esito(await _chiedi('mandaUnDono', {
      'a': a,
      'dono': dono,
      'idMovimento': PortaDelCerchio.nuovoIdentificativo('dono'),
    }));
  }

  Future<EsitoDelGesto> regalaGliEos(String a, int quanti) async {
    return _esito(await _chiedi('regalaGliEos', {
      'a': a,
      'quanti': quanti,
      'idMovimento': PortaDelCerchio.nuovoIdentificativo('regalo'),
    }));
  }

  /// **CHI SE NE VA PORTA VIA ANCHE IL SUO CERCHIO**: il profilo, gli
  /// amici, i segni in memoria, il codice del link, il nome proposto e il
  /// Maestro di riferimento. Sul server se ne vanno con la cancellazione.
  Future<void> dimenticaChiSeNeVa() async {
    _profilo = null;
    _cerchio = const IlMioCerchio();
    _tendina = null;
    _codiceDelLink = null;
    _scadenzaDelLink = null;
    try {
      final p = await SharedPreferences.getInstance();
      await p.remove(chiaveDelNomeProposto);
      await p.remove(chiaveDelMaestro);
    } catch (senzaDisco) {
      // Le chiavi stanno sotto il prefisso `cerchio.` di CioCheETuo, che
      // le toglie comunque con tutte le altre.
    }
    notifyListeners();
  }

  /// Il recapito delle notifiche, quando il telefono ha gia' il permesso.
  Future<void> scriviIlToken(String token) async {
    await _chiedi('scriviIlTokenDelCerchio', {'token': token});
  }
}
