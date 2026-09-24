/// **I CONTROLLI DEL COLLAUDO DELLE RISPOSTE, ordine EJ voci 05, 06, 07 e
/// 08.** 24 settembre 2026.
///
/// Stanno qui, senza rete, perche' una prova li possa vedere rossi su testi
/// scritti apposta (regola A): il collaudo con Gemini vero costa, e non si
/// aspetta che il modello sbagli per sapere se un controllo guarda.
///
/// Misurano **cio' che la persona legge**, cioe' il corpo della risposta piu'
/// la riga d'oro in fondo, invito a tornare compreso: le catture del
/// fondatore mostravano la stessa riga d'oro sotto cinque risposte di fila, e
/// quella riga la scrive l'app, non il modello.
library;

import 'package:esoteric_circle/core/maestro/chakra_del_giorno.dart';
import 'package:esoteric_circle/core/maestro/voce_del_maestro.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';

/// Una risposta come la legge la persona: il corpo e la riga d'oro.
class RispostaLetta {
  const RispostaLetta({required this.corpo, required this.riga});

  final String corpo;
  final String riga;

  String get intera => riga.isEmpty ? corpo : '$corpo\n$riga';
}

/// Le frasi di un testo, tagliate alla punteggiatura forte.
List<String> frasiDi(String testo) => testo
    .split(RegExp(r'(?<=[.!?…])\s+|\n+'))
    .map((f) => f.trim())
    .where((f) => f.isNotEmpty)
    .toList();

String _norma(String s) => s
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-zàèéìòù0-9 ]'), ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

/// **VOCE 05, LE CHIUSURE RIPETUTE.** Quante frasi della riga d'oro di una
/// risposta erano gia' comparse nella riga d'oro di una risposta precedente
/// della stessa conversazione.
int chiusureRipetute(List<RispostaLetta> conversazione) {
  final viste = <String>{};
  var ripetute = 0;
  for (final r in conversazione) {
    for (final f in frasiDi(r.riga)) {
      final n = _norma(f);
      if (n.isEmpty) continue;
      if (!viste.add(n)) ripetute++;
    }
  }
  return ripetute;
}

/// **VOCE 05, LE FRASI VIETATE.** Le aperture che la voce dei Maestri vieta
/// per nome, trovate all'inizio di una qualunque frase, non solo della prima.
List<String> frasiVietate(RispostaLetta r) => [
      for (final f in frasiDi(r.intera))
        if (VoceDelMaestro.aperturaVietataDi(f) != null) f,
    ];

/// I dati della persona che il collaudo sa riconoscere, ognuno con le parole
/// che lo nominano.
class DatoDellaPersona {
  const DatoDellaPersona(this.nome, this.parole);
  final String nome;
  final List<String> parole;
}

/// **VOCE 05, I DATI RIPETUTI.** Per ogni risposta, quanti dati della
/// persona erano gia' stati nominati in una risposta precedente. Il primo
/// incontro con un dato non conta: conta il ritorno.
int datiRipetuti(
    List<RispostaLetta> conversazione, List<DatoDellaPersona> dati) {
  final gia = <String>{};
  var ripetuti = 0;
  for (final r in conversazione) {
    final t = r.intera.toLowerCase();
    final qui = <String>{
      for (final d in dati)
        if (d.parole.any((p) => t.contains(p.toLowerCase()))) d.nome,
    };
    ripetuti += qui.where(gia.contains).length;
    gia.addAll(qui);
  }
  return ripetuti;
}

/// **VOCE 07, LE ANTICIPAZIONI.** Frasi che parlano di domani o di un ritorno
/// e nominano una runa, un chakra o una carta: e' il dono svelato prima del
/// suo momento.
List<String> anticipazioni(RispostaLetta r) {
  // Solo parole che portano davvero nel futuro. La prima stesura aveva anche
  // "scende" e "torna": "lasciala scendere verso il centro del tuo cuore,
  // Anahata" parla di adesso, ed e' stata contata come anticipazione.
  final futuro = RegExp(
      r'\b(domani|dopodomani|prossim\w*|fra \d+ giorn\w*|quando sar\w*|'
      r'arriver\w*|ti aspetta)',
      caseSensitive: false);
  final nomi = <String>[
    for (final runa in kElderFuthark) runa.name,
    for (final c in ChakraDelGiorno.tutti) ...[c.nome, c.italiano],
    'la carta di domani',
    'il dono di domani',
  ];
  return [
    for (final f in frasiDi(r.intera))
      if (futuro.hasMatch(f) &&
          nomi.any((n) =>
              RegExp('\\b${RegExp.escape(n)}\\b', caseSensitive: false)
                  .hasMatch(f)))
        f,
  ];
}

/// **VOCE 08, LE REGOLE DI LINGUA DEL PROGETTO**, quelle che si contano
/// senza un giudice: il trattino lungo, la virgola prima di "e" o "ed", e
/// l'apostrofo al posto dell'accento nelle parole piu' comuni.
List<String> erroriDiRegola(RispostaLetta r) {
  final t = r.intera;
  final errori = <String>[];
  if (t.contains('—')) errori.add('trattino lungo');
  for (final m in RegExp(r',\s+(e|ed)\s', caseSensitive: false).allMatches(t)) {
    errori.add('virgola prima di "${m.group(1)}"');
  }
  for (final m in RegExp(r"\b(e|perche|pero|piu|gia|cosi|puo|citta|verita)'",
          caseSensitive: false)
      .allMatches(t)) {
    errori.add('apostrofo al posto dell\'accento: "${m.group(0)}"');
  }
  return errori;
}

/// I dati della persona del collaudo, quella delle catture: Ascendente
/// Gemelli, Sole in Cancro, numero della vita 3.
const datiDellaPersona = [
  DatoDellaPersona('ascendente', ['Gemelli']),
  DatoDellaPersona('sole', ['Cancro']),
  DatoDellaPersona('numero', ['numero della vita', 'Creativo', 'numero 3']),
];
