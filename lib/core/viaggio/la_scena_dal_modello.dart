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

/// **I PEZZI CHE LA RISPOSTA PUO' CONTENERE**, id per id: sono gli elenchi
/// chiusi dello schema della risposta. Ordine DI voce 16: vedi
/// [LaScenaDalModello.ammessi].
typedef PezziAmmessi = ({
  List<String> luoghi,
  List<String> cose,
  List<String> gesti,
  List<String> momenti,
});

/// La firma di una chiamata al modello per la scena, iniettabile nelle prove:
/// riceve anche i pezzi ammessi, da cui la chiamata vera costruisce lo schema.
typedef ChiamataDellaScena = Future<String?> Function(
    String istruzione, String richiesta, PezziAmmessi ammessi);

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

  /// Gli id dei pezzi delle scene di prima, dalla piu' recente: **tutta la
  /// storia che il Diario conserva**, ordine DI voce 16. Al modello se ne
  /// elencano cinque; la lettura della risposta le guarda tutte.
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
  /// settembre 2026 contando i token. **Il fondatore ha scelto, ordine DJ
  /// voce 03**: `gemini-2.5-flash` in `europe-west1`, dove stanno i dati, e
  /// *"non e' un ripiego"*. Un modello nuovo si nomina solo se risponde nella
  /// regione dei dati: vedi `LaRegioneDeiDati`.
  static const String modello = 'gemini-2.5-flash';

  static String get regione => LaDomandaCapita.regione;

  /// **QUANTO SI ASPETTA: SEI SECONDI IN TUTTO, DALLA PARTENZA.** Ordine DK
  /// voce 03.
  ///
  /// **Erano due secondi per tentativo**, e la chiamata partiva a discesa
  /// finita: col modello vero la scena arrivava in tempo in 66-99 discese su
  /// cento, e i tempi scaduti si concentravano nei momenti di rete lenta.
  /// Allungare l'attesa alla fine avrebbe fatto pagare la lentezza della rete
  /// a chi vuole la risposta. **Adesso la chiamata parte al tocco di Scendi**,
  /// e fra quel tocco e la risalita ci sono gli otto secondi del filmato, la
  /// nebbia e l'incontro, in cui nessuno aspetta niente: sei secondi al
  /// modello non costano un istante a nessuno. **I sei secondi valgono per
  /// tutti e due i tentativi insieme**, contati dalla partenza: la scena
  /// scartata si richiede solo col tempo che resta.
  static const Duration pazienza = Duration(seconds: 6);

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
        'servono a non ripeterti: la scena di oggi deve essere nuova. I luoghi '
        'e i gesti delle scene precedenti non si possono ripetere; la cosa può '
        'tornare, soltanto se oggi ha un senso preciso. Non scegliere due pezzi '
        'che ripetono la stessa parola. Rispondi solo con i quattro id.');
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

  /// **I PEZZI AMMESSI OGGI**: tutti, tranne i luoghi e i gesti delle ultime
  /// cinque scene. Ordine DI voce 16, 13 settembre 2026.
  ///
  /// **La misura.** La prova a cento discese col modello vero ha trovato
  /// **scartate da 38 a 51 scene su cento**: sulla lunga distanza il modello
  /// torna sui suoi pezzi preferiti e ne riprende piu' di uno dalle cinque
  /// scene di prima, e la lettura, giustamente, lo scarta. Meta' delle discese
  /// ricadeva sulla composizione deterministica, cioe' su una scena che non
  /// nasce dalla persona. Nella prova da dieci discese della voce DI.03 non si
  /// vedeva.
  ///
  /// **Adesso la regola sta nello schema**, come gli id: la risposta non puo'
  /// contenere un luogo o un gesto gia' visto. **La cosa puo' tornare**, perche'
  /// e' l'unico pezzo che il richiamo guarda, e il momento, che ne ha quattro
  /// in tutto. Cosi' al massimo un pezzo e' ripreso, per costruzione.
  ///
  /// **MA LA COSA NON TORNA SUBITO, e non torna sempre.** Con la cosa libera
  /// del tutto il modello, per una sorella che aspetta un figlio, tornava sul
  /// seme una discesa su tre: il richiamo compariva in trentadue discese su
  /// cento, e la stessa riga quattro volte. L'ordine DE voce 11 lo vuole raro.
  /// Non torna una cosa delle **due** scene di prima, e non torna una cosa
  /// gia' tornata due volte nelle cinque.
  ///
  /// **E NON TORNA CIO' CHE TORNA SEMPRE.** Per la stessa domanda il modello
  /// si addensa sugli stessi posti e sugli stessi oggetti, la grotta e la
  /// pietra spaccata per il blocco, e appena lo schema glielo permette ci
  /// ritorna: due responsi con tre pezzi su quattro uguali superavano il
  /// quaranta per cento di somiglianza, misurato 41,3. Non torna un luogo ne'
  /// una cosa gia' usati due volte nelle ultime [memoriaDeiRitorni] scene.
  static PezziAmmessi ammessi(
      GuideAnimal animale, List<List<String>> ultimeScene) {
    final dieci = <String, int>{};
    for (final s in ultimeScene.take(memoriaDeiRitorni)) {
      for (final id in s.toSet()) {
        dieci[id] = (dieci[id] ?? 0) + 1;
      }
    }
    bool tornaTroppo(String id) => (dieci[id] ?? 0) >= 2;
    final cinque =
        ultimeScene.take(IlRichiamoDelleScene.quanteSceneIndietro).toList();
    final visti = {for (final s in cinque) ...s};
    final vicine = {for (final s in cinque.take(2)) ...s};
    final volte = <String, int>{};
    for (final s in cinque) {
      for (final id in s.toSet()) {
        volte[id] = (volte[id] ?? 0) + 1;
      }
    }
    List<String> fuori(List<PezzoDellaScena> tutti, {bool nuovi = true}) => [
          for (final p in tutti)
            if (!nuovi || !visti.contains(p.id)) p.id,
        ];
    return (
      luoghi: [
        for (final l in fuori(VocabolarioDelViaggio.luoghi))
          if (!tornaTroppo(l)) l,
      ],
      cose: [
        for (final c in VocabolarioDelViaggio.cose)
          if (!vicine.contains(c.id) &&
              (volte[c.id] ?? 0) < 2 &&
              !tornaTroppo(c.id))
            c.id,
      ],
      gesti: fuori(GestiDellAnimale.di(animale.name)),
      momenti: fuori(VocabolarioDelViaggio.momenti, nuovi: false),
    );
  }

  /// **QUANTE SCENE RICORDA LO SCHEMA PER I RITORNI**: dieci.
  static const int memoriaDeiRitorni = 10;

  /// **CHIEDE I QUATTRO PEZZI.** Nullo quando decide la via deterministica:
  /// tetto tecnico raggiunto, modello muto o lento, risposta fuori dal
  /// vocabolario, combinazione che la composizione non accetta. Il perche'
  /// va a [seGuasto].
  ///
  /// **UNA SCENA SCARTATA SI RICHIEDE UNA VOLTA**, ordine DI voce 16, senza
  /// il luogo e la cosa della risposta scartata. La prova a cento discese col
  /// modello vero: con la regola della scena rifatta la lettura ne scartava
  /// meta', e meta' delle discese tornava a nascere da un hash invece che
  /// dalla persona. Il tempo c'e': la chiamata parte a discesa finita e si
  /// aspetta solo alla risalita, dopo la nebbia, l'incontro e il velo. La
  /// seconda chiamata passa dal tetto tecnico come la prima.
  static Future<PezziScelti?> chiedi(
    CioCheSiSa s, {
    ChiamataDellaScena? chiamata,
    Future<bool> Function() prendiUnaChiamata =
        IlTettoDelleChiamate.prendiUnaChiamata,
    void Function(Object errore)? seGuasto,
    Duration attesa = pazienza,
  }) async {
    final chiedi = chiamata ?? _chiamataVera;
    var consentiti = ammessi(s.animale, s.ultimeScene);
    // **UNA SCADENZA SOLA**, dalla partenza: vedi [pazienza].
    final orologio = Stopwatch()..start();
    for (var tentativo = 0; tentativo < 2; tentativo++) {
      final resta = attesa - orologio.elapsed;
      if (resta <= Duration.zero) {
        seGuasto?.call(TimeoutException(
            'la scena scartata non ha più tempo per la seconda richiesta',
            attesa));
        return null;
      }
      if (!await prendiUnaChiamata()) return null;
      try {
        final risposta =
            await chiedi(istruzione(s.animale), richiesta(s), consentiti)
                .timeout(resta);
        final scelti = leggi(risposta, s.animale, ultimeScene: s.ultimeScene);
        if (scelti != null) return scelti;
        seGuasto?.call(ScenaFuoriDalVocabolario(risposta));
        consentiti = _senzaLaScartata(consentiti, risposta);
      } catch (errore) {
        // Un modello muto o lento non si richiama: la risalita non aspetta.
        seGuasto?.call(errore);
        return null;
      }
    }
    return null;
  }

  /// I pezzi ammessi, senza il luogo e la cosa della risposta scartata,
  /// finche' ne resta almeno uno per elenco.
  static PezziAmmessi _senzaLaScartata(PezziAmmessi a, String? risposta) {
    Object? j;
    try {
      j = risposta == null ? null : jsonDecode(risposta);
    } catch (errore) {
      // Una risposta che non e' JSON non dice cosa togliere: resta com'era.
      return a;
    }
    if (j is! Map) return a;
    List<String> senza(List<String> l, Object? id) {
      final r = [for (final x in l) if (x != id) x];
      return r.isEmpty ? l : r;
    }

    return (
      luoghi: senza(a.luoghi, j['luogo']),
      cose: senza(a.cose, j['cosa']),
      gesti: a.gesti,
      momenti: a.momenti,
    );
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
    } catch (errore) {
      // **UNA RISPOSTA CHE NON E' JSON SI SCARTA**: `chiedi` la manda al
      // registro dei guasti come scena fuori dal vocabolario, e decide la via
      // deterministica.
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
    // **NESSUNA SCENA RIFATTA**, ordine DI voce 16: per la stessa domanda il
    // modello torna, a settimane di distanza, esattamente sulla stessa scena.
    // La prova a cento discese l'ha trovata identica in tutti e quattro i
    // pezzi, e i due responsi si somigliavano al 41,3 per cento. Una scena
    // che rifa' luogo, cosa e gesto di una qualsiasi della storia si scarta,
    // e si richiede. **Il momento non si conta**: ne ha quattro in tutto, e
    // contandolo la lettura scartava meta' delle scene del modello anche
    // dopo la seconda richiesta, misurato; senza, le scene del modello sono
    // salite da 62-81 a 89-98 discese su cento, con la somiglianza piu' bassa.
    final oggi = [luogo.id, cosa.id, gesto.id];
    for (final s in ultimeScene) {
      var comuni = 0;
      for (var k = 0; k < s.length && k < 3; k++) {
        if (s[k] == oggi[k]) comuni++;
      }
      if (comuni >= 3) return null;
    }
    return (luogo: luogo, cosa: cosa, gesto: gesto, momento: momento);
  }

  static Future<String?> _chiamataVera(
      String istruzione, String richiesta, PezziAmmessi ammessi) async {
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
          'luogo': Schema.enumString(enumValues: ammessi.luoghi),
          'cosa': Schema.enumString(enumValues: ammessi.cose),
          'gesto': Schema.enumString(enumValues: ammessi.gesti),
          'momento': Schema.enumString(enumValues: ammessi.momenti),
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
