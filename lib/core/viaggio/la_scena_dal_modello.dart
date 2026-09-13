import 'dart:async';
import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';

import '../maestro/natal_context.dart';
import '../rituals/animal_catalog.dart';
import 'il_tetto_delle_chiamate.dart';
import 'la_domanda_capita.dart';
import 'scena_del_viaggio.dart';
import 'vocabolario_del_viaggio.dart';

/// **I QUATTRO PEZZI CHE IL MODELLO HA SCELTO**, per id.
typedef PezziScelti = ({
  PezzoDellaScena luogo,
  PezzoDellaScena cosa,
  PezzoDellaScena gesto,
  PezzoDellaScena momento,
});

/// La firma di una chiamata al modello per la scena, iniettabile nelle prove.
typedef ChiamataDellaScena = Future<String?> Function(
    String istruzione, String richiesta);

/// **CIO' CHE IL MODELLO SA DELLA PERSONA, per scegliere la scena.** Ordine DI
/// voce 03: *"la domanda per esteso, il tema classificato, il nome
/// dell'animale, i dati della carta natale gia' disponibili nel profilo, il
/// riassunto della memoria e gli elementi delle ultime cinque scene di quella
/// persona"*.
class CioCheSiSa {
  const CioCheSiSa({
    required this.domanda,
    required this.tema,
    required this.animale,
    required this.natale,
    required this.memoria,
    required this.ultimeScene,
  });

  final String domanda;

  /// Il tema per esteso, *Una scelta da fare*; nullo senza domanda.
  final String? tema;
  final GuideAnimal animale;
  final NatalContext natale;

  /// Il riassunto che il Diario gia' scrive per i Maestri.
  final String memoria;

  /// Gli id dei pezzi delle ultime cinque scene, dalla piu' recente.
  final List<List<String>> ultimeScene;
}

/// **LA SCENA NASCE DALLA PERSONA, NON DA UN HASH.** Ordine DI voce 03,
/// 12 settembre 2026.
///
/// **La misura dell'ordine:** *"il codice dichiara da se' che la via buona non
/// e' montata: 'La porta al modello non e' ancora aperta'. Quella che gira e'
/// ScenaSenzaModello.componi, che sceglie i quattro pezzi con quattro
/// divisioni intere su un hash di domanda, giorno e numero della discesa."*
///
/// **Adesso la porta e' aperta.** Il modello riceve cio' che si sa della
/// persona e sceglie **quattro id dal vocabolario chiuso**, e nient'altro: la
/// risposta e' vincolata a quattro elenchi (`application/json` con quattro
/// enumerazioni), quindi un id inventato non puo' uscire. Se esce lo stesso,
/// o se esce una combinazione che la composizione non accetta, si scarta tutto
/// e **si cade sulla via deterministica, dichiarata nel registro dei guasti e
/// mai alla persona**. La via deterministica resta e non si cancella.
///
/// **Il costo dichiarato dall'ordine**: circa 1.200 token in ingresso e 60 in
/// uscita, cioe' circa due decimi di centesimo a discesa.
abstract final class LaScenaDalModello {
  /// **IL MODELLO**, in una costante sola.
  ///
  /// **L'ordine nomina Gemini 3.6 Flash**, e come Gemini 3.5 Flash Lite per la
  /// domanda capita esiste soltanto sull'endpoint `global`: verificato il 12
  /// settembre 2026 contando i token. Finche' il fondatore non sceglie fra il
  /// modello dell'ordine su `global` e i dati che restano in `europe-west1`,
  /// qui c'e' `gemini-2.5-flash`, lo stesso livello del modello dell'ordine
  /// fra quelli che rispondono in Europa. Passare all'altro e' questa riga e
  /// la regione, che e' quella della domanda capita.
  static const String modello = 'gemini-2.5-flash';

  static String get regione => LaDomandaCapita.regione;

  /// **QUANTO SI ASPETTA.** La chiamata parte quando finisce la discesa e la
  /// scena serve alla risalita: in mezzo ci sono la nebbia e l'incontro, e il
  /// tempo che resta alla risalita e' questo.
  static const Duration pazienza = Duration(seconds: 2);

  /// **L'ISTRUZIONE**, costruita dal vocabolario e dal repertorio: niente si
  /// ricopia a mano, e il giorno che una figura cambia nome l'istruzione la
  /// segue da sola.
  static String istruzione(GuideAnimal animale) {
    final chi = '${animale.articolo}${animale.name}';
    final chiMaiuscolo = '${chi[0].toUpperCase()}${chi.substring(1)}';
    final b = StringBuffer(
        'Componi la scena di un viaggio sciamanico nel Mondo di Sotto. '
        '$chiMaiuscolo '
        'accompagna la persona. Scegli ESATTAMENTE quattro pezzi, uno per '
        'elenco, solo fra quelli scritti qui: non inventarne altri.\n');
    void elenco(String titolo, List<PezzoDellaScena> pezzi) {
      b.writeln('$titolo:');
      for (final p in pezzi) {
        b.writeln('- ${p.id}: ${p.nome}');
      }
    }

    elenco('luogo (dove ti porta)', VocabolarioDelViaggio.luoghi);
    elenco('cosa (ciò che si trova lì)', VocabolarioDelViaggio.cose);
    elenco('gesto (cosa fa $chi)', GestiDellAnimale.di(animale.name));
    elenco('momento', VocabolarioDelViaggio.momenti);
    // **LE SCENE PRECEDENTI SERVONO A NON RIPETERSI**, e lo dice la prova
    // col modello vero: con la prima stesura, *"se un elemento ha senso,
    // riprendilo"*, il modello riprendeva qualcosa in ventisei scene su
    // ventisette, e un profilo tornava dieci volte al bivio col seme.
    // L'ordine DE voce 11 vuole il richiamo raro: *"una continuita'
    // inventata vale meno di nessuna continuita'"*.
    b.write('La scena è la risposta simbolica alla domanda. Scegli i pezzi '
        'perché parlino di quella domanda e di quella persona, del suo tema, '
        'della sua carta natale e di ciò che ricorda. Le scene precedenti '
        'servono a non ripeterti: la scena di oggi deve essere nuova. Puoi '
        'riprendere al massimo UN pezzo da una scena precedente, soltanto se '
        'oggi ha un senso preciso; tutti gli altri devono essere diversi. Non '
        'scegliere due pezzi che ripetono la stessa parola. Rispondi solo con '
        'i quattro id.');
    return b.toString();
  }

  /// **LA RICHIESTA**, cioe' cio' che si sa della persona, per esteso.
  static String richiesta(CioCheSiSa s) {
    final n = s.natale;
    final b = StringBuffer()
      ..writeln('Domanda: ${s.domanda.trim().isEmpty ? 'nessuna, la '
          'discesa è soltanto per incontrarlo' : s.domanda.trim()}')
      ..writeln('Tema: ${s.tema ?? 'nessuno'}')
      ..writeln('Animale: ${s.animale.name}');
    final natale = [
      if (n.sunSign != null) 'Sole in ${n.sunSign}',
      if (n.moonSign != null) 'Luna in ${n.moonSign}',
      if (n.ascendant != null) 'Ascendente ${n.ascendant}',
      if (n.lifeNumber != null) 'numero di vita ${n.lifeNumber}',
    ];
    b.writeln('Carta natale: ${natale.isEmpty ? 'non nota' : natale.join(', ')}');
    b.writeln('Memoria: ${s.memoria.isEmpty ? 'prima discesa' : s.memoria}');
    if (s.ultimeScene.isEmpty) {
      b.write('Scene precedenti: nessuna');
    } else {
      b.writeln('Scene precedenti, dalla più recente:');
      for (final scena in s.ultimeScene.take(IlRichiamoDelleScene.quanteSceneIndietro)) {
        b.writeln('- ${scena.join(', ')}');
      }
    }
    return b.toString().trimRight();
  }

  /// **CHIEDE I QUATTRO PEZZI.** Nullo quando decide la via deterministica:
  /// tetto tecnico raggiunto, modello muto o lento, risposta fuori dal
  /// vocabolario, combinazione che la composizione non accetta. Il perche'
  /// va a [seGuasto].
  static Future<PezziScelti?> chiedi(
    CioCheSiSa s, {
    ChiamataDellaScena? chiamata,
    Future<bool> Function() prendiUnaChiamata =
        IlTettoDelleChiamate.prendiUnaChiamata,
    void Function(Object errore)? seGuasto,
  }) async {
    if (!await prendiUnaChiamata()) return null;
    try {
      final chiedi =
          chiamata ?? (String i, String r) => _chiamataVera(i, r, s.animale);
      final risposta =
          await chiedi(istruzione(s.animale), richiesta(s)).timeout(pazienza);
      final scelti = leggi(risposta, s.animale, ultimeScene: s.ultimeScene);
      if (scelti != null) return scelti;
      seGuasto?.call(ScenaFuoriDalVocabolario(risposta));
    } catch (errore) {
      seGuasto?.call(errore);
    }
    return null;
  }

  /// **LEGGE LA RISPOSTA**, e la scarta tutta al primo pezzo che non torna.
  ///
  /// Non basta che i quattro id esistano: il gesto deve essere uno che quel
  /// corpo sa fare, e nessun pezzo deve ripetere una parola piena di un altro.
  /// Sono le stesse regole della composizione deterministica, ordine DI voci
  /// 04 e 05, e valgono per il modello come per lei.
  ///
  /// **E NON PIU' DI UN PEZZO GIA' VISTO** nelle ultime cinque scene, fra
  /// luogo, cosa e gesto: il momento ne ha quattro in tutto e si ripete per
  /// forza. E' la stessa regola che l'istruzione chiede, letta sull'uscita.
  static PezziScelti? leggi(String? risposta, GuideAnimal animale,
      {List<List<String>> ultimeScene = const []}) {
    if (risposta == null) return null;
    final Object? j;
    try {
      j = jsonDecode(risposta);
    } catch (_) {
      return null;
    }
    final dati = j is Map ? j : null;
    if (dati == null) return null;
    PezzoDellaScena? tra(List<PezzoDellaScena> tutti, Object? id) =>
        tutti.where((p) => p.id == id).firstOrNull;
    final luogo = tra(VocabolarioDelViaggio.luoghi, dati['luogo']);
    final cosa = tra(VocabolarioDelViaggio.cose, dati['cosa']);
    final gesto = tra(GestiDellAnimale.di(animale.name), dati['gesto']);
    final momento = tra(VocabolarioDelViaggio.momenti, dati['momento']);
    if (luogo == null || cosa == null || gesto == null || momento == null) {
      return null;
    }
    if (ScenaSenzaModello.siRipetono(cosa, [luogo]) ||
        ScenaSenzaModello.siRipetono(gesto, [luogo, cosa, momento])) {
      return null;
    }
    final visti = {
      for (final s in ultimeScene.take(IlRichiamoDelleScene.quanteSceneIndietro))
        ...s,
    };
    final ripresi =
        [luogo, cosa, gesto].where((p) => visti.contains(p.id)).length;
    if (ripresi > 1) return null;
    return (luogo: luogo, cosa: cosa, gesto: gesto, momento: momento);
  }

  static Future<String?> _chiamataVera(
      String istruzione, String richiesta, GuideAnimal animale) async {
    List<String> id(List<PezzoDellaScena> p) => [for (final x in p) x.id];
    final m = FirebaseAI.vertexAI(location: regione).generativeModel(
      model: modello,
      systemInstruction: Content.system(istruzione),
      generationConfig: GenerationConfig(
        temperature: 0.8,
        maxOutputTokens: 256,
        thinkingConfig: LaDomandaCapita.ragionamentoPer(modello),
        responseMimeType: 'application/json',
        // **QUATTRO ELENCHI CHIUSI**: l'uscita ammessa sono quattro id e
        // nient'altro, per costruzione.
        responseSchema: Schema.object(properties: {
          'luogo': Schema.enumString(enumValues: id(VocabolarioDelViaggio.luoghi)),
          'cosa': Schema.enumString(enumValues: id(VocabolarioDelViaggio.cose)),
          'gesto':
              Schema.enumString(enumValues: id(GestiDellAnimale.di(animale.name))),
          'momento':
              Schema.enumString(enumValues: id(VocabolarioDelViaggio.momenti)),
        }),
      ),
    );
    final r = await m.generateContent([Content.text(richiesta)]);
    return r.text;
  }
}

/// Il modello ha risposto fuori dal vocabolario, o con una combinazione che la
/// composizione non accetta.
class ScenaFuoriDalVocabolario implements Exception {
  const ScenaFuoriDalVocabolario(this.risposta);
  final String? risposta;
  @override
  String toString() => 'la scena del modello non è nel vocabolario: "$risposta"';
}
