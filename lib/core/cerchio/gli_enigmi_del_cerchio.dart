/// GLI ENIGMI DEL CERCHIO, cio' che il telefono riceve e come lo dice.
/// Ordine FF, 8 ottobre 2026.
///
/// Il server (`functions/src/il_cerchio_sociale.ts`, parte E) manda solo
/// identificativi e numeri: il numero di un tratto, un elemento, un
/// archetipo, un punteggio. Le parole le compone questo file, e ogni testo
/// dei due corpora passa dalla porta `IlTestoDegliEnigmi`: la forma
/// dichiarata a chi gioca, il neutro in ogni indizio su un'altra persona.
library;

import '../archetypes/archetype.dart';
import '../chat/la_marca_del_genere.dart';
import 'il_ritratto.dart';
import 'il_testo_degli_enigmi.dart';

int _intero(Object? v, [int altrimenti = 0]) =>
    v is num ? v.toInt() : altrimenti;

String _stringa(Object? v) => v is String ? v : '';

List<Map<String, Object?>> _elenco(Object? v) => v is List
    ? [
        for (final e in v)
          if (e is Map) Map<String, Object?>.from(e),
      ]
    : const [];

/// Un volto dell'indovinello: il nome e l'icona scelta, mai quella del segno.
class VoltoDellEnigma {
  const VoltoDellEnigma({required this.uid, required this.nome, this.icona});

  factory VoltoDellEnigma.da(Map<String, Object?> d) => VoltoDellEnigma(
      uid: _stringa(d['uid']),
      nome: _stringa(d['nome']),
      icona: d['icona'] is String ? d['icona'] as String : null);

  final String uid;
  final String nome;
  final String? icona;
}

/// La domanda di un indovinello: il tipo e il valore che il server ha scelto.
class DomandaDellEnigma {
  const DomandaDellEnigma(this.tipo, this.valore);

  factory DomandaDellEnigma.da(Object? d) {
    final m = d is Map ? d : const {};
    return DomandaDellEnigma(_stringa(m['tipo']), _stringa(m['valore']));
  }

  final String tipo;
  final String valore;

  /// **LA DOMANDA A VIDEO.** Il tratto esce nel neutro: chi gioca non
  /// conosce il genere della persona da indovinare.
  String get testo => switch (tipo) {
        'tratto' => 'Chi di loro dice: «${_tratto(valore)}»?',
        'elemento' => 'Chi di loro ha il Sole in un segno di $valore?',
        'archetipo' => 'Chi di loro è ${_archetipo(valore)}?',
        'animale' => 'Chi di loro ha ${_animale(valore)} come animale guida?',
        _ => 'Chi di loro è la persona giusta?',
      };
}

/// Il tratto citato fra virgolette, nel neutro e senza il punto finale: la
/// frase che lo cita ha gia' il suo.
String _tratto(String numero) {
  final t = IlRitratto.tratto(int.tryParse(numero) ?? 0);
  return t == null
      ? ''
      : _senzaPunto(IlTestoDegliEnigmi.comeIndizio(t.testoMarcato));
}

String _senzaPunto(String s) =>
    s.endsWith('.') ? s.substring(0, s.length - 1) : s;

/// L'archetipo con l'articolo, minuscolo: sta in mezzo a una frase ("Chi di
/// loro è il Mago?"), mentre `conArticolo` e' scritto per un titolo.
String _archetipo(String id) {
  for (final a in Archetype.values) {
    if (a.name == id) {
      return a.conArticolo[0].toLowerCase() + a.conArticolo.substring(1);
    }
  }
  return id;
}

/// L'animale con l'articolo giusto, dai dodici della tabella di
/// `GuideAnimalDerivation` (scritti in minuscolo sul server).
const Map<String, String> _animaliConArticolo = {
  'falco': 'il Falco',
  'orso': 'l’Orso',
  'volpe': 'la Volpe',
  'lupo': 'il Lupo',
  'aquila': 'l’Aquila',
  'gufo': 'il Gufo',
  'cervo': 'il Cervo',
  'serpente': 'il Serpente',
  'cavallo': 'il Cavallo',
  'tartaruga': 'la Tartaruga',
  'corvo': 'il Corvo',
  'lince': 'la Lince',
};

String _animale(String id) => _animaliConArticolo[id] ?? id;

/// Un indizio arrivato dal server.
class IndizioDellEnigma {
  const IndizioDellEnigma(this.fonte, this.valore);

  factory IndizioDellEnigma.da(Object? d) {
    final m = d is Map ? d : const {};
    return IndizioDellEnigma(_stringa(m['fonte']), _stringa(m['valore']));
  }

  final String fonte;
  final String valore;

  /// **L'INDIZIO A VIDEO**, sempre nel neutro: parla di un'altra persona.
  String get testo => switch (fonte) {
        'ritratto' => '«${_tratto(valore)}»',
        'elemento' => 'Il suo Sole sta in un segno di $valore.',
        'modalita' => 'Il suo Sole sta in un segno $valore.',
        'animale' => 'Il suo animale guida è ${_animale(valore)}.',
        'archetipoSecondario' =>
          'Il suo secondo archetipo è ${_archetipo(valore)}.',
        _ => '',
      };
}

/// Una partita di Chi del Cerchio.
class PartitaDellEnigma {
  const PartitaDellEnigma({
    required this.id,
    required this.facce,
    required this.domanda,
    required this.indizi,
    required this.costoProssimo,
    required this.chiusa,
    this.era,
    this.punti,
  });

  factory PartitaDellEnigma.da(Map<String, Object?> d) => PartitaDellEnigma(
        id: _stringa(d['partita']),
        facce: [for (final f in _elenco(d['facce'])) VoltoDellEnigma.da(f)],
        domanda: DomandaDellEnigma.da(d['domanda']),
        indizi: [for (final i in _elenco(d['indizi'])) IndizioDellEnigma.da(i)],
        costoProssimo:
            d['costoProssimo'] is num ? _intero(d['costoProssimo']) : null,
        chiusa: d['chiusa'] == true,
        era: d['era'] is String ? d['era'] as String : null,
        punti: d['punti'] is num ? (d['punti'] as num).toDouble() : null,
      );

  final String id;
  final List<VoltoDellEnigma> facce;
  final DomandaDellEnigma domanda;
  final List<IndizioDellEnigma> indizi;

  /// Quanto costa il prossimo indizio; nullo quando sono finiti.
  final int? costoProssimo;
  final bool chiusa;

  /// Chi era, a partita chiusa.
  final String? era;
  final double? punti;

  PartitaDellEnigma conIndizio(IndizioDellEnigma i, int? costoProssimo) =>
      PartitaDellEnigma(
          id: id,
          facce: facce,
          domanda: domanda,
          indizi: [...indizi, i],
          costoProssimo: costoProssimo,
          chiusa: chiusa);

  PartitaDellEnigma chiusaCon(String era, double punti) => PartitaDellEnigma(
      id: id,
      facce: facce,
      domanda: domanda,
      indizi: indizi,
      costoProssimo: null,
      chiusa: true,
      era: era,
      punti: punti);
}

/// **L'ESITO DI UN ENIGMA RICONOSCIUTO**, con quanti indizi. Il fondatore,
/// 8 ottobre 2026: niente punti a video, gli Enigmi non sono un gioco. I
/// punti restano nel server, dove ordinano chi legge il Cerchio.
String lettoConGliIndizi(int indizi) => switch (indizi) {
      0 => 'Riconosciuto senza indizi.',
      1 => 'Riconosciuto con un indizio.',
      2 => 'Riconosciuto con due indizi.',
      _ => 'Riconosciuto con tre indizi.',
    };

/// Chi ti ha indovinato, per una domanda: il numero e i segni scoperti.
class VoceDelRitorno {
  const VoceDelRitorno(
      {required this.chiave,
      required this.quanti,
      required this.segni,
      required this.daScoprire});

  factory VoceDelRitorno.da(Map<String, Object?> d) => VoceDelRitorno(
      chiave: _stringa(d['chiave']),
      quanti: _intero(d['quanti']),
      segni: [
        for (final s in (d['segni'] is List ? d['segni'] as List : const []))
          '$s',
      ],
      daScoprire: _intero(d['daScoprire']));

  final String chiave;
  final int quanti;
  final List<String> segni;
  final int daScoprire;

  /// **LA FRASE DEL RITORNO**: "Due persone hanno capito che sei il Mago."
  /// Parla a chi e' stato indovinato, nella sua forma.
  String get frase {
    final i = chiave.indexOf(':');
    final tipo = i < 0 ? chiave : chiave.substring(0, i);
    final valore = i < 0 ? '' : chiave.substring(i + 1);
    final chi = quanti == 1 ? 'Una persona ha' : '$quanti persone hanno';
    final cosa = switch (tipo) {
      'tratto' => () {
          final t = IlRitratto.tratto(int.tryParse(valore) ?? 0);
          final detto = t == null
              ? ''
              : _senzaPunto(IlTestoDegliEnigmi.perChiCompila(
                  t.testoMarcato, LaMarcaDelGenere.formaCorrente));
          return 'dici «$detto»';
        }(),
      'elemento' => 'il tuo Sole sta in un segno di $valore',
      'archetipo' => 'sei ${_archetipo(valore)}',
      'animale' => 'il tuo animale guida è ${_animale(valore)}',
      _ => 'sei tu',
    };
    return '$chi capito che $cosa.';
  }
}

/// Un amico nella Prova della settimana.
class AmicoNellaProva {
  const AmicoNellaProva(
      {required this.uid,
      required this.nome,
      required this.fatta,
      this.punteggio,
      this.scommessa});

  factory AmicoNellaProva.da(Map<String, Object?> d) {
    final s = d['scommessa'];
    return AmicoNellaProva(
        uid: _stringa(d['uid']),
        nome: _stringa(d['nome']),
        fatta: d['fatta'] == true,
        punteggio: d['punteggio'] is num ? _intero(d['punteggio']) : null,
        scommessa:
            s is Map && s['valore'] is num ? _intero(s['valore']) : null);
  }

  final String uid;
  final String nome;
  final bool fatta;
  final int? punteggio;

  /// La tua scommessa sul suo punteggio, se l'hai piazzata.
  final int? scommessa;
}

/// Una sfida a due aperta.
class SfidaAperta {
  const SfidaAperta(
      {required this.id,
      required this.da,
      required this.a,
      required this.scade,
      required this.tua,
      required this.haiStimato});

  factory SfidaAperta.da(Map<String, Object?> d) => SfidaAperta(
      id: _stringa(d['id']),
      da: _stringa(d['da']),
      a: _stringa(d['a']),
      scade: DateTime.fromMillisecondsSinceEpoch(_intero(d['scade'])),
      tua: d['tua'] == true,
      haiStimato: d['haiStimato'] == true);

  final String id;
  final String da;
  final String a;
  final DateTime scade;

  /// Vero se l'hai lanciata tu.
  final bool tua;
  final bool haiStimato;
}

/// Un posto nella classifica o nel Pellegrinaggio.
class PostoNelCerchio {
  const PostoNelCerchio(
      {required this.uid,
      required this.nome,
      required this.tu,
      required this.quanti});

  factory PostoNelCerchio.da(Map<String, Object?> d, String campo) =>
      PostoNelCerchio(
          uid: _stringa(d['uid']),
          nome: _stringa(d['nome']),
          tu: d['tu'] == true,
          quanti: _intero(d[campo]));

  final String uid;
  final String nome;
  final bool tu;
  final int quanti;
}

/// Il Pellegrinaggio verso la luna piena.
class IlPellegrinaggio {
  const IlPellegrinaggio(
      {required this.luna,
      required this.meta,
      required this.totale,
      required this.arrivato,
      required this.passi});

  static IlPellegrinaggio? da(Object? d) {
    if (d is! Map) return null;
    final m = Map<String, Object?>.from(d);
    return IlPellegrinaggio(
        luna: DateTime.tryParse(_stringa(m['luna'])) ?? DateTime(2000),
        meta: _intero(m['meta'], 1),
        totale: _intero(m['totale']),
        arrivato: m['arrivato'] == true,
        passi: [
          for (final p in _elenco(m['passi'])) PostoNelCerchio.da(p, 'passi')
        ]);
  }

  final DateTime luna;
  final int meta;
  final int totale;
  final bool arrivato;
  final List<PostoNelCerchio> passi;
}

/// **LA VISTA DEGLI ENIGMI**, come la manda la porta `gliEnigmi`.
class VistaDegliEnigmi {
  const VistaDegliEnigmi({
    required this.ritrattoCompilato,
    required this.indovinelli,
    required this.indovinelliAlGiorno,
    required this.scommesse,
    required this.scommesseAlGiorno,
    required this.ritorno,
    required this.settimana,
    required this.tema,
    required this.provaFatta,
    required this.punteggio,
    required this.figura,
    required this.amici,
    required this.sfide,
    required this.puoiSfidare,
    required this.pellegrinaggio,
    required this.classifica,
  });

  factory VistaDegliEnigmi.da(Map<String, Object?> d) {
    final oggi = d['oggi'] is Map
        ? Map<String, Object?>.from(d['oggi'] as Map)
        : const <String, Object?>{};
    final prova = d['prova'] is Map
        ? Map<String, Object?>.from(d['prova'] as Map)
        : const <String, Object?>{};
    final sfide = d['sfide'] is Map
        ? Map<String, Object?>.from(d['sfide'] as Map)
        : const <String, Object?>{};
    return VistaDegliEnigmi(
      ritrattoCompilato: d['ritrattoCompilato'] == true,
      indovinelli: _intero(oggi['indovinelli']),
      indovinelliAlGiorno: _intero(oggi['indovinelliAlGiorno']),
      scommesse: _intero(oggi['scommesse']),
      scommesseAlGiorno: _intero(oggi['scommesseAlGiorno']),
      ritorno: [for (final r in _elenco(d['ritorno'])) VoceDelRitorno.da(r)],
      settimana: _stringa(prova['settimana']),
      tema: prova['tema'] is num ? _intero(prova['tema']) : null,
      provaFatta: prova['fatta'] == true,
      punteggio: prova['punteggio'] is num ? _intero(prova['punteggio']) : null,
      figura: prova['figura'] is String ? prova['figura'] as String : null,
      amici: [for (final a in _elenco(prova['amici'])) AmicoNellaProva.da(a)],
      sfide: [for (final s in _elenco(sfide['aperte'])) SfidaAperta.da(s)],
      puoiSfidare: sfide['puoiSfidare'] == true,
      pellegrinaggio: IlPellegrinaggio.da(d['pellegrinaggio']),
      classifica: [
        for (final c in _elenco(d['classifica']))
          PostoNelCerchio.da(c, 'indovinati')
      ],
    );
  }

  final bool ritrattoCompilato;
  final int indovinelli;
  final int indovinelliAlGiorno;
  final int scommesse;
  final int scommesseAlGiorno;
  final List<VoceDelRitorno> ritorno;
  final String settimana;
  final int? tema;
  final bool provaFatta;
  final int? punteggio;
  final String? figura;
  final List<AmicoNellaProva> amici;
  final List<SfidaAperta> sfide;
  final bool puoiSfidare;
  final IlPellegrinaggio? pellegrinaggio;
  final List<PostoNelCerchio> classifica;

  int get indovinelliRimasti =>
      (indovinelliAlGiorno - indovinelli).clamp(0, indovinelliAlGiorno);
}

/// Il tempo che resta, detto in chiaro: "2 giorni e 4 ore", "5 ore", "12
/// minuti".
String ilTempoCheResta(Duration d) {
  if (d <= Duration.zero) return 'scaduto';
  final giorni = d.inDays;
  final ore = d.inHours % 24;
  final minuti = d.inMinutes % 60;
  String n(int q, String uno, String molti) => q == 1 ? '1 $uno' : '$q $molti';
  if (giorni > 0) {
    return ore > 0
        ? '${n(giorni, 'giorno', 'giorni')} e ${n(ore, 'ora', 'ore')}'
        : n(giorni, 'giorno', 'giorni');
  }
  if (d.inHours > 0) return n(d.inHours, 'ora', 'ore');
  return n(minuti < 1 ? 1 : minuti, 'minuto', 'minuti');
}
