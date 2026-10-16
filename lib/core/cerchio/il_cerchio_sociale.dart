import 'dart:convert';

import '../entitlement/il_consenso_della_spesa.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/server/porta_del_cerchio.dart';
import '../astro/zodiac.dart';
import '../brand/brand.dart';
import '../condivisione/porta_della_condivisione.dart';
import '../identity/birth_identity.dart';
import '../maestro/maestro.dart';
import 'gli_enigmi_del_cerchio.dart';
import 'il_nome_iniziatico.dart';
import 'le_icone_del_cerchio.dart';
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

  /// [segno] e' il segno solare di chi guarda: un'icona che non vale piu'
  /// diventa il suo emblema (ordine FA voce 01).
  factory ProfiloNelCerchio.da(Map<String, Object?> d, {Zodiac? segno}) =>
      ProfiloNelCerchio(
        uid: d['uid'] as String? ?? '',
        sigillo: d['sigillo'] as String? ?? '',
        nome: d['nome'] as String? ?? '',
        icona: IconaDelProfilo.valida(d['icona'] as String?, segno: segno),
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
        icona: IconaDelProfilo.valida(d['icona'] as String?,
            segno: d['segno'] is String
                ? Zodiac.fromId(d['segno'] as String)
                : null),
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
      {required this.id, required this.dono, required this.nomeDa, this.carta});
  final String id;
  final String dono;
  final String nomeDa;

  /// Il numero dell'angelo, da 1 a 72, quando il dono e' una carta degli
  /// Angeli (ordine FU voce FU.09); nullo per gli altri doni.
  final int? carta;

  factory DonoRicevuto.da(Map<String, Object?> d) => DonoRicevuto(
        id: d['id'] as String? ?? '',
        dono: d['dono'] as String? ?? 'cenno',
        nomeDa: d['nomeDa'] as String? ?? 'Una persona del Cerchio',
        carta: (d['carta'] as num?)?.toInt(),
      );
}

/// Chi ha risposto a una proposta del giorno insieme (FV.10): il suo nome e
/// la sua risposta, oppure nulla se non ha risposto ancora.
@immutable
class RispostaAlGiorno {
  const RispostaAlGiorno(
      {required this.nome, required this.risposta, this.altroGiorno});

  final String nome;

  /// 'si', 'no' oppure 'altroGiorno'.
  final String risposta;
  final DateTime? altroGiorno;

  factory RispostaAlGiorno.da(Map<String, Object?> d) => RispostaAlGiorno(
        nome: d['nome'] as String? ?? 'Una persona del Cerchio',
        risposta: d['risposta'] as String? ?? '',
        altroGiorno: DateTime.tryParse('${d['altroGiorno']}'),
      );
}

/// **UNA PROPOSTA DI "TROVA IL GIORNO INSIEME"** (FV.10), mandata o
/// ricevuta: l'attivita', il giorno proposto, chi l'ha mandata e con chi, le
/// risposte di chi l'ha ricevuta.
@immutable
class PropostaDelGiorno {
  const PropostaDelGiorno({
    required this.id,
    required this.attivita,
    required this.giorno,
    required this.ricevuta,
    required this.da,
    required this.nomeDa,
    required this.con,
    this.rispostaMia,
    this.altroGiornoMio,
    this.risposte = const [],
  });

  final String id;

  /// Il nome di `AttivitaDelLunario`, per esempio 'viaggi' o 'nozze'.
  final String attivita;
  final DateTime giorno;

  /// Vero per chi l'ha ricevuta, falso per chi l'ha mandata.
  final bool ricevuta;
  final String da;
  final String nomeDa;

  /// Gli altri nella proposta: per chi manda, tutti gli amici scelti; per
  /// chi riceve, solo chi l'ha mandata.
  final List<({String uid, String? nome})> con;

  /// La mia risposta, quando l'ho ricevuta e ho risposto.
  final String? rispostaMia;
  final DateTime? altroGiornoMio;

  /// Le risposte di chi l'ha ricevuta, quando l'ho mandata io.
  final List<RispostaAlGiorno> risposte;

  factory PropostaDelGiorno.da(Map<String, Object?> d) {
    final con = d['con'];
    final risposte = d['risposte'];
    return PropostaDelGiorno(
      id: d['id'] as String? ?? '',
      attivita: d['attivita'] as String? ?? '',
      giorno: DateTime.tryParse('${d['giorno']}') ?? DateTime(1970),
      ricevuta: d['verso'] == 'ricevuta',
      da: d['da'] as String? ?? '',
      nomeDa: d['nomeDa'] as String? ?? 'Una persona del Cerchio',
      con: con is List
          ? [
              for (final x in con)
                if (x is Map)
                  (uid: x['uid'] as String? ?? '', nome: x['nome'] as String?),
            ]
          : const [],
      rispostaMia: d['risposta'] as String?,
      altroGiornoMio: DateTime.tryParse('${d['altroGiorno']}'),
      risposte: risposte is Map
          ? [
              for (final e in risposte.entries)
                if (e.value is Map)
                  RispostaAlGiorno.da(
                      Map<String, Object?>.from(e.value as Map)),
            ]
          : const [],
    );
  }
}

/// **IL RESPIRO COLLETTIVO, ordine FX voce FX.09.** Quante persone in tutto
/// il Cerchio stanno respirando in questo momento, e quali amici veri fra
/// loro: [amiciDentro] porta solo i loro uid (mai un dato in più di quello
/// che il Cerchio mostra altrove), e chi lo mostra risolve i nomi dal suo
/// `IlMioCerchio.amici`, che li ha gia'.
///
/// // TODO integrazione: la UI la costruisce un altro file, nella schermata
/// del Respiro della Luna. Legge [IlCerchioSociale.respiroInsiemeConteggio].
@immutable
class RespiroInsiemeStato {
  const RespiroInsiemeStato({this.quante = 0, this.amiciDentro = const []});

  /// Quante persone, in tutto il Cerchio, stanno respirando adesso.
  final int quante;

  /// Gli uid degli amici veri fra loro.
  final List<String> amiciDentro;

  factory RespiroInsiemeStato.da(Map<String, Object?> d) =>
      RespiroInsiemeStato(
        quante: (d['quante'] as num?)?.toInt() ?? 0,
        amiciDentro: d['amiciDentro'] is List
            ? [
                for (final x in d['amiciDentro'] as List)
                  if (x is String) x,
              ]
            : const [],
      );
}

/// **UNA COLLANA A DUE, ordine FX voce FX.09.** Nasce da un invito fra due
/// amici veri del Cerchio per il ciclo in corso (la Luna piena che lo
/// governa, [ciclo], in forma 'AAAA-MM-GG'); la sua perla del giorno si
/// accende solo nei giorni di [giorniAccesi], cioe' quando ENTRAMBE le
/// persone hanno segnalato il respiro fatto.
///
/// // TODO integrazione: la card con i due nomi la disegna un altro file
/// (la UI del Respiro della Luna). [conUid] e' il solo dato che porta
/// sull'altra persona: chi mostra la card risolve il nome dal suo
/// `IlMioCerchio.amici`. Legge [IlCerchioSociale.leCollaneADue].
@immutable
class CollanaADue {
  const CollanaADue({
    required this.id,
    required this.ciclo,
    required this.conUid,
    required this.stato,
    required this.iniziataDaMe,
    this.giorniAccesi = const [],
  });

  final String id;

  /// La Luna piena che governa il ciclo, in forma 'AAAA-MM-GG'.
  final String ciclo;

  /// L'uid dell'altra persona nella collana.
  final String conUid;

  /// 'invitata', 'attiva' oppure 'rifiutata'.
  final String stato;

  /// Vero se sono io ad aver mandato l'invito.
  final bool iniziataDaMe;

  /// I giorni (in forma 'AAAA-MM-GG') in cui la perla e' davvero accesa.
  final List<String> giorniAccesi;

  factory CollanaADue.da(Map<String, Object?> d) => CollanaADue(
        id: d['id'] as String? ?? '',
        ciclo: d['ciclo'] as String? ?? '',
        conUid: d['con'] as String? ?? '',
        stato: d['stato'] as String? ?? 'invitata',
        iniziataDaMe: d['daMe'] == true,
        giorniAccesi: d['giorniAccesi'] is List
            ? [
                for (final x in d['giorniAccesi'] as List)
                  if (x is String) x,
              ]
            : const [],
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
    this.proposteDiGiorno = const [],
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

  /// **"TROVA IL GIORNO INSIEME"** (FV.10): le proposte mandate o ricevute.
  final List<PropostaDelGiorno> proposteDiGiorno;

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
        proposteDiGiorno: _lista(d['proposteDiGiorno'], PropostaDelGiorno.da),
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

  /// **IL MOTIVO DEL RIFIUTO**, scritto dal server come parola chiave
  /// (`limite`, `eos`, `ritratto`, ...): mai mostrato, letto in un punto solo.
  String? get motivo => dati[_chiaveDelMotivo] as String?;
  static const String _chiaveDelMotivo = 'perche';

  /// **LA RIGA PER LA PERSONA**: quella del server se e' una frase, il
  /// ripiego dichiarato se e' un codice. Ordine FF, visto sul Realme l'8
  /// ottobre 2026: con la porta del Ritratto non ancora pubblicata il server
  /// rispondeva "NOT_FOUND", e il Ritratto lo mostrava cosi'.
  String get rigaPerLaPersona {
    final r = riga?.trim() ?? '';
    final frase = r.contains(' ') && r != r.toUpperCase();
    return frase ? r : silenzio.riga!;
  }

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

  /// **QUANDO E' ARRIVATA L'ULTIMA TENDINA, ordine FC voce 09.** La rubrica
  /// degli amici la riusa se ha meno di un minuto, e chi mostra l'ultimo
  /// dato noto ne dice l'ora. Nulla finche' nessuna tendina e' arrivata.
  DateTime? _tendinaArrivata;
  DateTime? get tendinaArrivata => _tendinaArrivata;

  /// **L'ULTIMA RICHIESTA DELLA TENDINA NON E' ARRIVATA**, ordine FC voce 09
  /// col vincolo del fondatore: *"Quando il tetto e' raggiunto, l'app NON
  /// mostra un errore: mostra l'ultimo dato noto con l'ora a cui e' stato
  /// preso."* Il tetto di trenta chiamate l'ora e' della porta
  /// `laTendinaDelCerchio`, e adesso la chiamano due schermate, la tendina
  /// e la rubrica degli amici: e' condiviso. Quando una richiesta non arriva
  /// (il tetto, oppure la rete), [tendina] resta l'ultima arrivata e questo
  /// e' vero; chi la mostra scrive l'ora di [tendinaArrivata] invece di un
  /// guasto. Solo quando nessuna tendina e' mai arrivata si legge
  /// [rigaDellaTendinaCheNonArriva].
  bool _tendinaNonAggiornata = false;
  bool get tendinaNonAggiornata => _tendinaNonAggiornata;

  /// La riga quando la tendina non arriva e non c'e' un ultimo dato noto.
  /// Testo del fondatore, ordine FC voce 09.
  static const String rigaDellaTendinaCheNonArriva =
      'Il Cerchio non risponde in questo momento. Riprova fra poco.';

  /// **L'ULTIMA TENDINA SUL TELEFONO**, perche' l'ultimo dato noto ci sia
  /// anche dopo una riapertura dell'app dentro l'ora del tetto. Sotto il
  /// prefisso `cerchio.`, che l'uscita toglie con tutto il resto; porta lo
  /// uid di chi l'ha ricevuta e si rilegge solo per lui.
  static const String chiaveDellUltimaTendina = 'cerchio.ultimaTendina';

  /// **LA RIGA DELL'ULTIMO DATO**, testo del fondatore (ordine FC,
  /// Aggiunta della voce FC.10, parte prima), identico nella tendina e nella
  /// rubrica: "Il Cerchio come era alle 21:47." [ora] e' l'ora in cui
  /// l'istantanea e' stata presa, gia' scritta nel formato del telefono
  /// (`l_ora_del_telefono.dart`), mai quella dell'apertura.
  static String rigaDellUltimoDato(String ora) =>
      'Il Cerchio come era alle $ora.';

  /// **L'ULTIMO DATO VALE UN'ORA.** Il fondatore: la presenza vive in una
  /// finestra di novanta secondi e il tetto e' orario, quindi un dato preso
  /// da meno di un'ora e' coerente col tetto, mentre uno del giorno prima
  /// dichiarerebbe presente chi non c'e'. Oltre l'ora non si mostra, e si
  /// cancella dalla memoria e dal telefono: l'ora da sola, senza "ieri" e
  /// senza una data, resta cosi' sempre vera.
  static const Duration vitaDellUltimoDato = Duration(hours: 1);

  /// Se l'ultima tendina e' stata presa da meno di [vitaDellUltimoDato]
  /// all'istante [adesso].
  bool ultimoDatoValido(DateTime adesso) {
    final quando = _tendinaArrivata;
    return _tendina != null &&
        quando != null &&
        adesso.difference(quando) < vitaDellUltimoDato;
  }

  /// Toglie l'ultima tendina, dalla memoria e dal telefono, se all'istante
  /// [adesso] e' piu' vecchia di un'ora.
  Future<void> scartaLUltimaSeScaduta(DateTime adesso) async {
    if (_tendina == null || ultimoDatoValido(adesso)) return;
    _tendina = null;
    _tendinaArrivata = null;
    notifyListeners();
    await _dimenticaLUltimaTendina();
  }

  Future<void> _dimenticaLUltimaTendina() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.remove(chiaveDellUltimaTendina);
    } catch (senzaDisco) {
      debugPrint('Cerchio: l\'ultima tendina non si toglie. $senzaDisco');
    }
  }

  bool get vivo => _porta.viva;

  /// **IL CERCHIO SOCIALE SI APRE A QUATTORDICI ANNI, ordine EZ voce 04.**
  ///
  /// Tutto il resto dell'app resta intero: nessuna arte si chiude, nessun
  /// responso si tocca, nessun limite cambia. Questa regola vale solo per le
  /// porte del Cerchio sociale e non e' un divieto sulle arti.
  ///
  /// Sotto i quattordici anni il consenso lo presta chi esercita la
  /// responsabilita' genitoriale, e il fondatore il 4 ottobre 2026 ha
  /// approvato di non costruire nessun meccanismo di consenso: le funzioni
  /// sociali semplicemente non si aprono. L'eta' viene SOLO dalla data di
  /// nascita che il profilo ha gia' (`quattordiciAnni`): non si chiede, non si
  /// verifica con documenti, e il compleanno apre da solo al primo ingresso
  /// utile. Nessuna etichetta dice a nessuno che una persona e' minorenne.
  static const String rigaDeiQuattordici =
      'Il Cerchio si apre a quattordici anni';

  /// **IL GIFT EOS SI DICHIARA, INVECE DI FALLIRE, ordine EZ voce 05.**
  ///
  /// La regola resta scritta sul server (`decidiIlGift` in `sociale.ts`): si
  /// regalano solo Eos comprati o quelli della dote del piano, mai quelli
  /// guadagnati gratis, da cento a cinquecento al giorno. Ma oggi nessuna
  /// porta accredita Eos comprati e la dote del piano non si accredita ancora
  /// (`DOTE_DEL_PIANO` in `borsellino.ts`): gli Eos regalabili valgono zero
  /// per tutti, per costruzione. Un pulsante che tenta e fallisce sarebbe un
  /// vicolo cieco; la voce resta visibile e dichiarata non ancora attiva, con
  /// la riga che dice da cosa si apre.
  ///
  /// **Si apre cambiando questa sola riga**, nell'ordine che rendera'
  /// acquistabili gli abbonamenti e i pacchetti di Eos: quell'ordine e' una
  /// decisione del fondatore, e questo non costruisce niente sugli acquisti.
  static bool get ilGiftEosEAperto => false;

  static const String rigaDelGiftEos =
      'Si apre quando gli abbonamenti e i pacchetti di Eos saranno '
      'acquistabili';

  /// La sola porta che resta aperta: e' quella che riceve l'eta'.
  static const String portaCheRiceveLEta = 'ilMioProfiloNelCerchio';

  bool _chiusoPerEta = false;

  /// Il segno solare di chi guarda, dall'ultima sincronizzazione: serve al
  /// ripiego dell'icona (ordine FA voce 01).
  Zodiac? _mioSegno;

  /// Vero quando la data di nascita dice meno di quattordici anni.
  bool get chiusoPerEta => _chiusoPerEta;

  /// Gli anni compiuti alla data, dalla sola data di nascita. Senza una data
  /// vera (l'identita' d'esempio) il Cerchio sociale non si apre: si apre
  /// quando la data c'e'.
  static bool quattordiciAnni(BirthIdentity? identita, DateTime oggi) =>
      _anni(identita, oggi) >= 14;

  static int _anni(BirthIdentity? identita, DateTime oggi) {
    if (identita == null || identita.isExample) return -1;
    final n = identita.birthDate;
    var anni = oggi.year - n.year;
    if (oggi.month < n.month || (oggi.month == n.month && oggi.day < n.day)) {
      anni--;
    }
    return anni;
  }

  Future<EsitoSociale?> _chiedi(String porta,
      [Map<String, Object?> corpo = const {}]) async {
    // Sotto i quattordici anni nessuna porta sociale parte dal telefono: la
    // risposta e' la riga sola, la stessa che il server darebbe.
    if (_chiusoPerEta && porta != portaCheRiceveLEta) {
      return const EsitoSociale(
          dati: {}, errore: 'sottoLaSoglia', riga: rigaDeiQuattordici);
    }
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
  static bool maggiorenne(BirthIdentity? identita, DateTime oggi) =>
      _anni(identita, oggi) >= 18;

  /// Sincronizza il profilo: il segno (mai la data), il Maestro, il gradino
  /// del Cammino e la maggiore eta'. Se l'onboarding ha lasciato un nome da
  /// proporre e il server non ne ha ancora uno, lo propone adesso.
  Future<void> sincronizza({
    BirthIdentity? identita,
    Maestro? maestro,
    int gradino = 0,
    DateTime? oggi,
    String? nomeProprio,
  }) async {
    if (!vivo) return;
    final segno = identita?.sunSign;
    _mioSegno = segno;
    final adesso = oggi ?? DateTime.now();
    final quattordici = quattordiciAnni(identita, adesso);
    if (_chiusoPerEta == quattordici) {
      _chiusoPerEta = !quattordici;
      notifyListeners();
    }
    final esito = await _chiedi(portaCheRiceveLEta, {
      // Sotto i quattordici anni viaggia solo l'eta': nessun segno, nessun
      // Maestro, nessun gradino per un profilo che non esiste.
      if (quattordici && segno != null) 'segno': segno.id,
      if (quattordici && maestro != null) 'maestro': maestro.name,
      if (quattordici) 'gradino': gradino,
      'maggiorenne': maggiorenne(identita, adesso),
      'quattordici': quattordici,
    });
    if (!quattordici || esito == null || esito.rifiutato) return;
    _profilo = ProfiloNelCerchio.da(esito.dati, segno: _mioSegno);
    notifyListeners();
    if (!_profilo!.haUnNome) {
      // **CHI ERA GIA' NEL CERCHIO PRIMA DELL'ORDINE EY** non e' passato dal
      // campo dell'onboarding: riceve il nome iniziatico dalla sua nascita,
      // come chi arriva. E' il primo nome, non un cambio: il primo cambio
      // resta libero. Visto sul Realme con la build 2296, "Ancora senza
      // nome".
      final proposto = await _nomeProposto() ??
          IlNomeIniziatico.per(identita: identita, nomeProprio: nomeProprio);
      await scegliIlNome(proposto);
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
  /// **LA LETTURA A DUE TELEFONI DELLA SINASTRIA EVOLUTIVA**, ordine FT voce
  /// FT.03. Chi condivide la propria nascita, col gesto del consenso,
  /// riceve un codice di sei caratteri che vale cinque minuti e una lettura
  /// sola (`dati['codice']`, `dati['scade']` in millisecondi). La nascita va
  /// solo al server, nel consenso: mai nel profilo pubblico.
  ///
  /// **PER L'ORACOLO DEGLI ANGELI**, ordine FU voce FU.09: con
  /// [perLOracolo] il consenso dichiara lo scopo e porta anche il minuto del
  /// giorno di nascita nel luogo ([minutoLocale], solo con l'ora nota),
  /// perche' l'Angelo dell'Intelletto si conta dall'ora locale. Senza, il
  /// corpo e' quello della Sinastria evolutiva, campo per campo.
  /// **PER "TROVA IL GIORNO INSIEME"**, ordine FV voce FV.10: con
  /// [perLoLunario] il consenso dichiara lo scopo 'lunario' e porta anche il
  /// minuto del giorno di nascita nel luogo, come per l'Oracolo: FV.07 (la
  /// fase di nascita) lo vuole esatto quando l'ora e' nota.
  Future<EsitoDelGesto> condividiLaNascita({
    required DateTime nascitaUtc,
    required DateTime giorno,
    required bool oraNota,
    required String nome,
    bool perLOracolo = false,
    bool perLoLunario = false,
    int? minutoLocale,
  }) async =>
      _esito(await _chiedi('condividiLaNascita', {
        'nascita': nascitaUtc.toUtc().toIso8601String(),
        'giorno': _giornoScritto(giorno),
        'oraNota': oraNota,
        'nome': nome.trim(),
        if (perLOracolo) 'scopo': scopoDellOracolo,
        if (perLoLunario) 'scopo': scopoDelLunario,
        if ((perLOracolo || perLoLunario) && oraNota && minutoLocale != null)
          'minutoLocale': minutoLocale,
      }));

  /// Lo scopo del consenso che presta la nascita all'Oracolo degli Angeli:
  /// la stessa parola di `scopoDa` in `functions/src/sinastria_evolutiva.ts`.
  static const String scopoDellOracolo = 'oracolo';

  /// Lo scopo del consenso che presta la nascita a "Trova il giorno
  /// insieme" del Calendario Lunare, ordine FV voce FV.10: la stessa parola
  /// di `scopoDa` in `functions/src/sinastria_evolutiva.ts`.
  static const String scopoDelLunario = 'lunario';

  /// Chi legge manda il codice e il PROPRIO giorno di nascita: il server
  /// rifa' lo sbarramento dei sedici anni sul legame amore con la nascita
  /// condivisa che ha nel consenso (FT.04), e lo dice in
  /// `dati['amoreApribile']`.
  ///
  /// Con [perLOracolo] si leggono solo i consensi dati per l'Oracolo degli
  /// Angeli (ordine FU voce FU.09), con [perLoLunario] solo quelli dati per
  /// "Trova il giorno insieme" (ordine FV voce FV.10): un consenso per una
  /// cosa sola.
  Future<EsitoDelGesto> leggiLaNascita(String codice,
          {required DateTime giornoMio,
          bool perLOracolo = false,
          bool perLoLunario = false}) async =>
      _esito(await _chiedi('leggiLaNascita', {
        'codice': codice.trim(),
        'giornoMio': _giornoScritto(giornoMio),
        if (perLOracolo) 'scopo': scopoDellOracolo,
        if (perLoLunario) 'scopo': scopoDelLunario,
      }));

  static String _giornoScritto(DateTime g) =>
      '${g.year.toString().padLeft(4, '0')}-'
      '${g.month.toString().padLeft(2, '0')}-'
      '${g.day.toString().padLeft(2, '0')}';

  Future<EsitoDelGesto> scegliIlNome(String nome) async {
    final e = await _chiedi('scegliIlNome', {'nome': nome.trim()});
    final esito = _esito(e);
    final profilo = e?.dati['profilo'];
    if (profilo is Map) {
      _profilo = ProfiloNelCerchio.da(Map<String, Object?>.from(profilo),
          segno: _mioSegno);
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
      _profilo = ProfiloNelCerchio.da(e.dati, segno: _mioSegno);
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

  /// [adesso] e' l'istante su cui si misura l'eta' dell'ultimo dato quando
  /// la richiesta non arriva: l'orologio, o quello di una prova.
  Future<EsitoDelGesto> caricaLaTendina({DateTime? adesso}) async {
    final e = await _chiedi('laTendinaDelCerchio');
    if (e == null || e.rifiutato) {
      if (_tendina == null) await _rileggiLUltimaTendina();
      _tendinaNonAggiornata = true;
      await scartaLUltimaSeScaduta(adesso ?? DateTime.now());
      notifyListeners();
      return _esito(e);
    }
    _tendina = LaTendina.da(e.dati);
    _tendinaArrivata = DateTime.now();
    _tendinaNonAggiornata = false;
    notifyListeners();
    await _conservaLUltimaTendina(e.dati, _tendinaArrivata!);
    return const EsitoDelGesto(ok: true);
  }

  Future<void> _conservaLUltimaTendina(
      Map<String, Object?> dati, DateTime quando) async {
    final uid = _profilo?.uid;
    if (uid == null) return;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(
          chiaveDellUltimaTendina,
          jsonEncode({
            'uid': uid,
            'quando': quando.millisecondsSinceEpoch,
            'dati': dati,
          }));
    } catch (senzaDisco) {
      // Senza disco resta l'ultimo dato in memoria: basta per la sessione.
      debugPrint('Cerchio: l\'ultima tendina resta in memoria. $senzaDisco');
    }
  }

  Future<void> _rileggiLUltimaTendina() async {
    final uid = _profilo?.uid;
    if (uid == null) return;
    try {
      final p = await SharedPreferences.getInstance();
      final testo = p.getString(chiaveDellUltimaTendina);
      if (testo == null) return;
      final d = jsonDecode(testo);
      if (d is! Map || d['uid'] != uid || d['dati'] is! Map) return;
      final quando = d['quando'];
      if (quando is! int) return;
      _tendina = LaTendina.da(Map<String, Object?>.from(d['dati'] as Map));
      _tendinaArrivata = DateTime.fromMillisecondsSinceEpoch(quando);
    } catch (illeggibile) {
      debugPrint('Cerchio: l\'ultima tendina non si rilegge. $illeggibile');
    }
  }

  /// Spende 100 Eos: pretende il consenso della conferma, ordine FD voce 01.
  Future<EsitoDelGesto> compraUnPosto(
      {required ConsensoDellaSpesa consenso}) async {
    final e = await _chiedi('compraUnPostoNelCerchio',
        {'idMovimento': PortaDelCerchio.nuovoIdentificativo('posto')});
    final esito = _esito(e);
    if (esito.ok) await caricaIlCerchio();
    return esito;
  }

  // ---- IL CALENDARIO LUNARE, ordine FV voci FV.10 e FV.12 ----

  /// **UN MESE DI CALENDARIO LUNARE IN PIU'** (FV.12): un acquisto singolo,
  /// come [compraUnPosto]. Costa gli Eos di
  /// `ListinoDegliEos.meseExtraDelLunario` e pretende il consenso della
  /// conferma, ordine FD voce 01.
  Future<EsitoDelGesto> compraUnMeseDelLunario(
      {required ConsensoDellaSpesa consenso}) async {
    return _esito(await _chiedi('compraUnMeseDelLunario', {
      'idMovimento': PortaDelCerchio.nuovoIdentificativo('lunario_mese'),
    }));
  }

  /// **UNA PROPOSTA INSIEME IN PIU'** (FV.12): chi non ha "Trova il giorno
  /// insieme" nel piano la apre per una proposta sola. Costa gli Eos di
  /// `ListinoDegliEos.propostaInsiemeDelLunario` e pretende il consenso
  /// della conferma, ordine FD voce 01.
  Future<EsitoDelGesto> compraUnaPropostaInsieme(
      {required ConsensoDellaSpesa consenso}) async {
    return _esito(await _chiedi('compraUnaPropostaInsiemeDelLunario', {
      'idMovimento': PortaDelCerchio.nuovoIdentificativo('lunario_insieme'),
    }));
  }

  /// **TROVA IL GIORNO INSIEME** (FV.10): manda la proposta di un'attivita'
  /// e di un giorno a uno o piu' amici veri del Cerchio. [attivita] e' il
  /// nome di `AttivitaDelLunario` (per esempio 'viaggi'); [giorno] e' il
  /// giorno proposto, a mezzanotte locale.
  Future<EsitoDelGesto> proponiGiornoInsieme({
    required List<String> amici,
    required String attivita,
    required DateTime giorno,
  }) async {
    final esito = _esito(await _chiedi('proponiGiornoInsieme', {
      'amici': amici,
      'attivita': attivita,
      'giorno': _giornoScritto(giorno),
    }));
    if (esito.ok) await caricaIlCerchio();
    return esito;
  }

  /// **RISPONDI AL GIORNO** (FV.10): sì, no, oppure un altro giorno d'oro
  /// ([altroGiorno], richiesto solo con [risposta] 'altroGiorno').
  Future<EsitoDelGesto> rispondiAlGiorno(String id,
      {required String risposta, DateTime? altroGiorno}) async {
    final esito = _esito(await _chiedi('rispondiAlGiorno', {
      'id': id,
      'risposta': risposta,
      if (altroGiorno != null) 'altroGiorno': _giornoScritto(altroGiorno),
    }));
    if (esito.ok) await caricaIlCerchio();
    return esito;
  }

  // ---- IL RESPIRO DELLA LUNA, ordine FX voce FX.09 ----

  /// **RESPIRIAMO INSIEME, SI ENTRA.** La persona dichiara di aver appena
  /// iniziato il minuto del respiro collettivo: il server scrive un
  /// documento con un TTL breve (poco più di un minuto), e scade da solo.
  Future<EsitoDelGesto> respiroInsiemeEntra() async =>
      _esito(await _chiedi('respiroInsiemeEntra'));

  /// **IL CONTEGGIO DEL RESPIRO COLLETTIVO**: quante persone stanno
  /// respirando adesso in tutto il Cerchio, e quali amici veri fra loro
  /// ([RespiroInsiemeStato.amiciDentro]). Nullo se il Cerchio non risponde.
  Future<RespiroInsiemeStato?> respiroInsiemeConteggio() async {
    final e = await _chiedi('respiroInsiemeConteggio');
    if (e == null || e.rifiutato) return null;
    return RespiroInsiemeStato.da(e.dati);
  }

  /// **INVITA UN AMICO ALLA COLLANA A DUE.** [amico] deve essere un amico
  /// vero del Cerchio; [ciclo] e' la Luna piena che governa il ciclo in
  /// corso, in forma 'AAAA-MM-GG' (la stessa forma di [_giornoScritto]).
  Future<EsitoDelGesto> invitaCollanaADue({
    required String amico,
    required DateTime ciclo,
  }) async =>
      _esito(await _chiedi('invitaCollanaADue', {
        'amico': amico,
        'ciclo': _giornoScritto(ciclo),
      }));

  /// **RISPONDI ALL'INVITO DELLA COLLANA A DUE**: [risposta] e' 'accetta'
  /// oppure 'rifiuta'. Accettando, la collana nasce attiva e diventa quella
  /// attiva di entrambi: una alla volta.
  Future<EsitoDelGesto> rispondiCollanaADue(String id,
      {required String risposta}) async {
    final esito = _esito(
        await _chiedi('rispondiCollanaADue', {'id': id, 'risposta': risposta}));
    if (esito.ok) await caricaIlCerchio();
    return esito;
  }

  /// **SEGNALA IL RESPIRO DEL GIORNO PER LA COLLANA A DUE.** Il telefono la
  /// chiama quando il respiro guidato finisce, SOLO SE la persona e' in una
  /// collana a due attiva ([leCollaneADue]): accende la sua metà della
  /// perla di [giorno]. La perla si accende per davvero solo quando anche
  /// l'altra persona segnala lo stesso giorno.
  Future<EsitoDelGesto> segnalaRespiroDelGiornoPerLaCollanaADue(
          {required DateTime giorno}) async =>
      _esito(await _chiedi('segnalaRespiroDelGiornoPerLaCollanaADue',
          {'giorno': _giornoScritto(giorno)}));

  /// **LE MIE COLLANE A DUE**: ogni collana di cui faccio parte, con lo
  /// stato, l'altra persona e i giorni in cui la perla e' davvero accesa.
  Future<List<CollanaADue>> leCollaneADue() async {
    final e = await _chiedi('leCollaneADue');
    if (e == null || e.rifiutato) return const [];
    final grezzo = e.dati['collane'];
    return grezzo is List
        ? [
            for (final x in grezzo)
              if (x is Map) CollanaADue.da(Map<String, Object?>.from(x)),
          ]
        : const [];
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

  /// IL CENNO, il solo dono gratuito (`PREZZI_DEI_DONI.cenno: 0` sul
  /// server): non consuma niente, e quindi non chiede la conferma.
  Future<EsitoDelGesto> mandaUnCenno(String a) => _mandaIlDono(a, 'cenno');

  /// Un dono che costa Eos (scintilla, sigillo): pretende il consenso della
  /// conferma, ordine FD voce 01.
  Future<EsitoDelGesto> mandaUnDono(String a, String dono,
          {required ConsensoDellaSpesa consenso}) =>
      _mandaIlDono(a, dono);

  Future<EsitoDelGesto> _mandaIlDono(String a, String dono) async {
    return _esito(await _chiedi('mandaUnDono', {
      'a': a,
      'dono': dono,
      'idMovimento': PortaDelCerchio.nuovoIdentificativo('dono'),
    }));
  }

  /// **LA CARTA DEGLI ANGELI IN DONO, ordine FU voce FU.09.** La strada e'
  /// quella dei doni (`mandaUnDono` sul server, dono `angelo`), col numero
  /// della carta e nient'altro: mai la domanda, mai la nascita. Costa gli Eos
  /// della voce `cartaDegliAngeliDaDonare` del listino e pretende il
  /// consenso della conferma, ordine FD voce 01.
  Future<EsitoDelGesto> mandaUnaCartaDegliAngeli(String a, int numero,
      {required ConsensoDellaSpesa consenso}) async {
    return _esito(await _chiedi('mandaUnDono', {
      'a': a,
      'dono': donoDellaCartaDegliAngeli,
      'carta': numero,
      'idMovimento': PortaDelCerchio.nuovoIdentificativo('dono'),
    }));
  }

  /// Il dono della carta, la stessa parola di `PREZZI_DEI_DONI` sul server.
  static const String donoDellaCartaDegliAngeli = 'angelo';

  /// Pretende il consenso della conferma, ordine FD voce 01.
  Future<EsitoDelGesto> regalaGliEos(String a, int quanti,
      {required ConsensoDellaSpesa consenso}) async {
    return _esito(await _chiedi('regalaGliEos', {
      'a': a,
      'quanti': quanti,
      'idMovimento': PortaDelCerchio.nuovoIdentificativo('regalo'),
    }));
  }

  /// **CHI SE NE VA PORTA VIA ANCHE IL SUO CERCHIO**: il profilo, gli
  /// amici, i segni in memoria, il codice del link, il nome proposto e il
  /// Maestro di riferimento. Sul server se ne vanno con la cancellazione.
  // --- GLI ENIGMI DEL CERCHIO, ordine FF ----------------------------------
  //
  // Le porte della parte E del server. I dati arrivano come identificativi e
  // numeri; le parole le compone `gli_enigmi_del_cerchio.dart`.

  /// **IL TUO RITRATTO E LE TUE SCELTE SUI GIOCHI**: senza argomenti li
  /// legge, coi campi li scrive. Il Ritratto si scrive solo intero.
  Future<EsitoDelGesto> ilMioRitratto({
    List<int>? tratti,
    bool? fuoriDaiGiochi,
    String? archetipo,
    bool togliArchetipo = false,
    String? animale,
    bool togliAnimale = false,
  }) async =>
      _esito(await _chiedi('ilMioRitratto', {
        if (tratti != null) 'tratti': tratti,
        if (fuoriDaiGiochi != null) 'fuoriDaiGiochi': fuoriDaiGiochi,
        if (archetipo != null || togliArchetipo) 'archetipo': archetipo,
        if (animale != null || togliAnimale) 'animale': animale,
      }));

  /// La vista d'insieme degli Enigmi. [lunaPiena] e' la luna piena che chiude
  /// il Pellegrinaggio, dalla porta unica del cielo: il server non ne ha una
  /// sua.
  Future<VistaDegliEnigmi?> gliEnigmi({DateTime? lunaPiena}) async {
    final e = await _chiedi('gliEnigmi', {
      if (lunaPiena != null) 'luna': _giorno(lunaPiena),
    });
    if (e == null || e.rifiutato) return null;
    return VistaDegliEnigmi.da(e.dati);
  }

  static String _giorno(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Apre un indovinello di Chi del Cerchio.
  Future<EsitoDelGesto> apriUnIndovinello() async =>
      _esito(await _chiedi('unIndovinello', {
        'azione': 'apri',
        'partita': PortaDelCerchio.nuovoIdentificativo('partita'),
      }));

  /// Il primo indizio di ogni partita e' gratis.
  Future<EsitoDelGesto> ilPrimoIndizio(String partita) => _indizio(partita);

  /// Dal secondo indizio, cinque Eos: pretende il consenso della conferma.
  Future<EsitoDelGesto> unIndizioInPiu(String partita,
          {required ConsensoDellaSpesa consenso}) =>
      _indizio(partita);

  Future<EsitoDelGesto> _indizio(String partita) async => _esito(await _chiedi(
      'unIndovinello', {'azione': 'indizio', 'partita': partita}));

  /// La risposta: [scelta] e' l'identificativo del volto toccato.
  Future<EsitoDelGesto> rispondiAllIndovinello(
          String partita, String scelta) async =>
      _esito(await _chiedi('unIndovinello',
          {'azione': 'rispondi', 'partita': partita, 'scelta': scelta}));

  /// Il segno di chi ti ha indovinato: venti Eos, col consenso.
  Future<EsitoDelGesto> scopriUnSegno(String chiave,
          {required ConsensoDellaSpesa consenso}) async =>
      _esito(await _chiedi('scopriUnSegno', {
        'chiave': chiave,
        'idMovimento': PortaDelCerchio.nuovoIdentificativo('segno'),
      }));

  /// Consegna la Prova: [scelte] sono le posizioni delle risposte nel corpus.
  Future<EsitoDelGesto> consegnaLaProva(int tema, List<int> scelte) async =>
      _esito(await _chiedi(
          'laProva', {'azione': 'consegna', 'tema': tema, 'scelte': scelte}));

  /// Scommette sul punteggio di un amico, finche' non ha fatto la Prova.
  Future<EsitoDelGesto> scommetti(String amico, int valore) async =>
      _esito(await _chiedi('laProva',
          {'azione': 'scommetti', 'amico': amico, 'valore': valore}));

  /// Sfida un amico sulla Prova: [stima] e' il punteggio che gli dai.
  Future<EsitoDelGesto> sfida(String amico, int stima) async =>
      _esito(await _chiedi('laProva', {
        'azione': 'sfida',
        'amico': amico,
        'valore': stima,
        'sfida': PortaDelCerchio.nuovoIdentificativo('sfida'),
      }));

  /// Risponde a una sfida: la stima del punteggio di chi ti ha sfidato.
  Future<EsitoDelGesto> rispondiAllaSfida(
          String sfida, String amico, int stima) async =>
      _esito(await _chiedi('laProva', {
        'azione': 'rispondiAllaSfida',
        'sfida': sfida,
        'amico': amico,
        'valore': stima,
      }));

  /// Un passo del Pellegrinaggio, dopo un rito compiuto nella settimana che
  /// porta alla luna piena.
  Future<EsitoDelGesto> unPassoDelPellegrinaggio(DateTime lunaPiena) async =>
      _esito(await _chiedi(
          'unPassoDelPellegrinaggio', {'luna': _giorno(lunaPiena)}));

  Future<void> dimenticaChiSeNeVa() async {
    _profilo = null;
    _cerchio = const IlMioCerchio();
    _tendina = null;
    _tendinaArrivata = null;
    _tendinaNonAggiornata = false;
    _codiceDelLink = null;
    _scadenzaDelLink = null;
    try {
      final p = await SharedPreferences.getInstance();
      await p.remove(chiaveDelNomeProposto);
      await p.remove(chiaveDelMaestro);
      await p.remove(chiaveDellUltimaTendina);
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
