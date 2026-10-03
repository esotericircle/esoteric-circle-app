import 'dart:io';

import 'controlli_ej.dart';
import 'la_voce_vera_di_gemini.dart';

/// **I GIUDICI DEL COLLAUDO EJ, tarati.** Ordine EJ voci 06 e 08, 24
/// settembre 2026.
///
/// **Perche' sono stati rifatti.** La prima domanda sulla risposta diretta,
/// senza ragionamento, bocciava da un giro all'altro sei risposte su sei poi
/// due su sei della stessa Medora, anche su risposte come *"Lascia che sia
/// lui a esporre le sue argomentazioni, senza interrompere"*. Una misura che
/// oscilla cosi' non chiude una voce. Adesso la domanda dice che cosa conta
/// come diretto, il giudice ragiona un poco prima di rispondere, ed e'
/// tarato su esempi veri delle trascrizioni in `taraturaDeiGiudici`.
///
/// **Lo stesso metro giudica il prima e il dopo**: le trascrizioni del prima
/// si rigiudicano con questi stessi giudici, in `rigiudica_ej.dart`.
const int ragionamentoDelGiudice = 512;

/// **A MAGGIORANZA SU TRE.** Anche a temperatura zero, col ragionamento
/// acceso, il giudice ha sbagliato una taratura su tre: una misura che
/// sbaglia un caso su tre non chiude una voce. Tre voti, vince la
/// maggioranza.
Future<bool> _aMaggioranza(Future<bool> Function() voto) async {
  var si = 0;
  for (var i = 0; i < 3; i++) {
    if (await voto()) si++;
  }
  return si >= 2;
}

Future<bool> giudicaDiretta(
        VoceVeraDiGemini voce, String domanda, String risposta) =>
    _aMaggioranza(() => voce.giudica(
          'Domanda della persona: "$domanda".\n'
          'Qui sotto c\'e\' la risposta. E\' DIRETTA se nelle prime due frasi dice '
          'alla persona, in modo specifico per questa domanda, che cosa fare, '
          'che cosa succedera\' o che cosa significa. NON e\' diretta se le prime '
          'due frasi sono premesse, massime, descrizioni del cielo o dei simboli '
          'che non rispondono ancora, o frasi che andrebbero bene per chiunque. '
          'La risposta e\' diretta? Rispondi con una parola sola, SI oppure NO.',
          risposta,
          ragionamento: ragionamentoDelGiudice,
        ));

Future<bool> giudicaPasso(VoceVeraDiGemini voce, String risposta) =>
    _aMaggioranza(() => voce.giudica(
          'Qui sotto c\'e\' la risposta di un consulente. L\'ultima riga, quella '
          'dopo il segno ✦, e\' un passo concreto che la persona puo\' fare, '
          'cioe\' un\'azione precisa con un oggetto, un momento o un modo '
          'definiti? NON lo e\' un invito generico come "trova la tua strada", '
          '"ascolta te stesso" o "porta con te un simbolo". IGNORA '
          'l\'eventuale invito a tornare in fondo alla riga ("Torna domani", '
          '"Ripassa fra", "Rivediamoci", "Domani al tramonto"): lo aggiunge '
          'l\'app e non conta come passo. Rispondi con una parola sola, SI '
          'oppure NO.',
          risposta,
          ragionamento: ragionamentoDelGiudice,
        ));

/// Una risposta riletta da una trascrizione: la domanda e cio' che la
/// persona legge.
class ScambioLetto {
  ScambioLetto(this.domanda, this.letta);
  final String domanda;
  final RispostaLetta letta;
}

/// Rilegge gli scambi da una trascrizione scritta da `collaudo_ej.dart`.
List<ScambioLetto> scambiDa(File file) {
  final scambi = <ScambioLetto>[];
  for (final blocco in file.readAsStringSync().split('## Scambio ').skip(1)) {
    final righe = blocco.split('\n');
    final persona = righe
        .firstWhere((r) => r.startsWith('**Persona:** '))
        .substring('**Persona:** '.length);
    final citate = [
      for (final r in righe)
        if (r.startsWith('>')) r.length > 2 ? r.substring(2) : '',
    ];
    final riga =
        citate.lastWhere((r) => r.startsWith('✦ '), orElse: () => '✦ ');
    final corpo = citate.where((r) => !r.startsWith('✦ ')).join('\n').trim();
    scambi.add(ScambioLetto(
        persona, RispostaLetta(corpo: corpo, riga: riga.substring(2))));
  }
  return scambi;
}

/// **IL GIUDICE DELLA GRAMMATICA, severo.** La prima stesura chiedeva un
/// elenco libero, e il giudice segnalava anche frasi che lui stesso diceva
/// corrette: dodici "errori" su sei risposte di Aura, quasi tutti falsi.
/// Adesso vuole righe nella forma `sbagliato => giusto`, solo errori certi, e
/// si contano solo le righe in cui le due parti sono diverse. E' tarato in
/// `tool/collaudo_ej.dart`, test `taratura del giudice`, su due testi noti.
Future<List<String>> erroriDiGrammatica(
    VoceVeraDiGemini voce, String testo) async {
  final elenco = await voce.elenca(
    'Sei un correttore di bozze italiano. Trova SOLO gli errori certi di '
    'grammatica o di ortografia: accordo di genere o di numero, articolo '
    'sbagliato, preposizione sbagliata, parola scritta male. NON segnalare '
    'stile, maiuscole dei segni zodiacali, parole rare, frasi poetiche o '
    'frasi che potresti migliorare. Scrivi un errore per riga, nella forma '
    'esatta: parole sbagliate => parole corrette. Se non ci sono errori '
    'certi, scrivi soltanto NESSUNO.',
    testo,
  );
  return [
    for (final r in elenco.split('\n'))
      if (r.contains('=>') &&
          r.split('=>')[0].trim().toLowerCase() !=
              r.split('=>')[1].trim().toLowerCase())
        r.trim(),
  ];
}
