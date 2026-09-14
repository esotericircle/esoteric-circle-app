import 'dart:async';

import 'package:firebase_ai/firebase_ai.dart';

import 'il_tema_della_domanda_libera.dart';
import 'il_tetto_delle_chiamate.dart';
import '../config/la_regione_dei_dati.dart';
import 'la_domanda_del_viaggio.dart';
import 'dart:convert';

/// **DA DOVE VIENE IL TEMA DI UNA DOMANDA LIBERA**, per il rapporto e per il
/// registro dei guasti.
enum FonteDelTema {
  /// Il modello ha risposto in tempo con uno dei sei id.
  modello,

  /// Il modello non ha risposto in tempo, o ha sbagliato, o non c'e' rete: ha
  /// deciso la tabella delle parole.
  parole,

  /// Nessuno dei due ha trovato un tema: si usa il ramo senza domanda.
  nessuna,
}

/// **LA DOMANDA CAPITA**: il tema, da dove viene, e l'oggetto della domanda
/// in due o tre parole prese dalla domanda stessa. Ordine DL voce 08.
typedef DomandaCapita = ({
  TemaDellaDomanda? tema,
  FonteDelTema fonte,
  String? oggetto,
});

/// La firma di una chiamata al modello: riceve l'istruzione e la domanda, e
/// restituisce il testo della risposta. Si inietta nelle prove, dove Firebase
/// non c'e'.
typedef ChiamataDelModello = Future<String?> Function(
    String istruzione, String domanda);

/// **LA DOMANDA LIBERA VIENE CAPITA.** Ordine DI voce 02, 12 settembre 2026.
///
/// **LA VIA PRINCIPALE E' IL MODELLO**: una chiamata secca, a temperatura zero,
/// che riceve la domanda e i sei temi con la loro descrizione e restituisce
/// **un id solo**. Non puo' scrivere altro: la risposta e' vincolata a un
/// elenco chiuso (`text/x.enum`), quindi il testo libero in uscita non esiste
/// per costruzione.
///
/// **LA VIA DI RISERVA E' LA TABELLA DELLE PAROLE**, sempre presente e sempre
/// funzionante senza rete, in `IlTemaDellaDomandaLibera`. Si cade li' **senza
/// che la persona se ne accorga** quando il modello non risponde entro
/// [pazienza], quando risponde con qualcosa che non e' uno dei sei id, o quando
/// la chiamata fallisce. Il guasto va nel registro, **mai alla persona**.
///
/// **La tabella da sola capisce una domanda su tre**, misurato su dodici
/// domande scritte dopo averla congelata, e non ne sbaglia nessuna: e' una rete
/// di sicurezza prudente, non un modo di capire. Il capire e' del modello.
abstract final class LaDomandaCapita {
  /// **IL MODELLO**, in una costante sola.
  ///
  /// **L'ordine nomina Gemini 3.5 Flash Lite**, e il modello esiste: ma a
  /// Vertex AI risponde **solo dall'endpoint `global`**, verificato il 12
  /// settembre 2026 contando i token con ogni modello. L'app fissa Vertex a
  /// `europe-west1` di proposito, e le domande libere sono dati personali.
  /// **Il fondatore ha scelto, ordine DJ voce 03**: il modello che risponde
  /// in `europe-west1`, dove stanno i dati. Vedi `LaRegioneDeiDati`.
  static const String modello = 'gemini-2.5-flash-lite';

  /// **LA REGIONE**, quella dei dati: `LaRegioneDeiDati`, ordine DJ voce 03.
  static const String regione = LaRegioneDeiDati.regione;

  /// **IL RAGIONAMENTO SI SPEGNE, per tutte le chiamate del Viaggio.**
  ///
  /// **Trovato dalla prova col modello vero della voce DI.03**, 12 settembre
  /// 2026. I modelli Flash *pensano* prima di rispondere, e i token del
  /// pensiero si contano dentro il tetto dell'uscita: con un tetto di ottanta
  /// token Gemini 3.6 Flash rispondeva *"Here"* e si fermava, trenta volte su
  /// trenta, e Gemini 2.5 Flash avrebbe fatto lo stesso nell'app, dove nessuno
  /// gli diceva di non pensare. **Ogni scena sarebbe caduta sulla riserva
  /// senza che nessuna prova se ne accorgesse**, perche' nelle prove il modello
  /// e' una finta.
  ///
  /// Qui si sceglie un elenco o si scrive una riga: il ragionamento non serve.
  /// La serie 2.5 lo spegne col budget a zero, la serie 3 col livello minimo,
  /// che e' il piu' basso che accetta.
  static ThinkingConfig ragionamentoPer(String modello) =>
      modello.startsWith('gemini-2.5')
          ? ThinkingConfig.withThinkingBudget(0)
          : ThinkingConfig.withThinkingLevel(ThinkingLevel.minimal);

  /// **QUANTO SI ASPETTA IL MODELLO**: due secondi, dall'ordine. Oltre, si cade
  /// sulla tabella.
  static const Duration pazienza = Duration(seconds: 2);

  /// **L'ISTRUZIONE**, costruita dalle sei domande scritte: i temi e le loro
  /// parole non si ricopiano qui a mano.
  ///
  /// **CON L'OGGETTO DELLA DOMANDA**, ordine DL voce 08: la ripresa del
  /// responso nominava la categoria, *"la scelta"*, e mai la sorella di cui
  /// si era chiesto. **E CON DUE ESEMPI IN PIU'**, ordine DL voce 09, della
  /// stessa famiglia del primo: domande che parlano di un'altra persona e
  /// chiedono quando o se una cosa arrivera'.
  static String get istruzione {
    final b = StringBuffer(
        'Sei un classificatore. Ricevi una domanda scritta da una persona '
        'prima di un viaggio interiore. Scegli UNO SOLO di questi sei '
        'identificatori: quello che dice cosa la persona sta chiedendo, non di '
        'chi o di cosa parla.\n');
    for (final d in LaDomandaDelViaggio.gliaScritte) {
      b.writeln('- ${d.id}: ${d.tema}. Per esempio: ${d.testo}');
    }
    b
      ..writeln('Esempio: "Mia sorella diventerà presto mamma?" parla di una '
          'persona ma chiede quando: quindi è attesa.')
      ..writeln('Esempio: "Mio figlio troverà lavoro entro l\'estate?" parla '
          'di una persona ma chiede se e quando una cosa arriva: quindi è '
          'attesa.')
      ..writeln('Esempio: "La mia amica tornerà a scrivermi?" parla di una '
          'persona ma chiede se una cosa arriverà: quindi è attesa.')
      ..writeln('Esempio: "Io e mio fratello non ci parliamo più e non so se '
          'chiamarlo" chiede del rapporto con una persona: quindi è '
          'persona, anche se contiene "non so se".')
      ..writeln('Esempio: "Con mio zio litighiamo ogni volta che ci '
          'vediamo" parla di una persona. Ciò che si ripete è il rapporto '
          'con lei: quindi è persona, non blocco.')
      ..writeln('Esempio: "Cosa voglio fare quando avrò finito gli studi?" '
          'non nomina due strade: quindi è direzione. È scelta solo quando '
          'la domanda nomina le alternative, o chiede se fare una cosa '
          'precisa.')
      ..writeln('Scrivi anche l\'oggetto della domanda: due o tre parole prese '
          'dalla domanda stessa, voltate alla seconda persona e con '
          'l\'articolo, per esempio "tua sorella", "il tuo lavoro", '
          '"quel posto", "il trasloco", "Giulia". I nomi propri con la '
          'maiuscola. Mai la prima persona: "la mia casa" diventa "la '
          'tua casa". Non inventare parole che la domanda non contiene; se '
          'la domanda non nomina una cosa o una persona precisa, lascia '
          'l\'oggetto vuoto.')
      ..write('Rispondi solo con un oggetto JSON con due campi, "tema" e '
          '"oggetto".');
    return b.toString();
  }

  /// **IL TEMA DI UNA DOMANDA LIBERA, e da dove viene.**
  ///
  /// [chiamata] si inietta nelle prove; [seGuasto] riceve il perche' quando
  /// il modello non ha deciso, per il registro dei guasti.
  static Future<(TemaDellaDomanda?, FonteDelTema)> tema(
    String domanda, {
    ChiamataDelModello? chiamata,
    void Function(Object errore)? seGuasto,
    Future<bool> Function() prendiUnaChiamata = IlTettoDelleChiamate.sempre,
  }) async {
    final c = await capisci(domanda,
        chiamata: chiamata,
        seGuasto: seGuasto,
        prendiUnaChiamata: prendiUnaChiamata);
    return (c.tema, c.fonte);
  }

  /// **IL TEMA, LA SUA FONTE E L'OGGETTO DELLA DOMANDA.** Ordine DL voce
  /// 08: un campo in piu' nella stessa risposta, nessuna chiamata in piu'.
  /// L'oggetto c'e' solo se lo da' il modello e regge a [oggettoValido]:
  /// la tabella delle parole il tema lo trova, l'oggetto no.
  static Future<DomandaCapita> capisci(
    String domanda, {
    ChiamataDelModello? chiamata,
    void Function(Object errore)? seGuasto,
    Future<bool> Function() prendiUnaChiamata = IlTettoDelleChiamate.sempre,
  }) async {
    final testo = domanda.trim();
    if (testo.isEmpty) {
      return (tema: null, fonte: FonteDelTema.nessuna, oggetto: null);
    }
    DomandaCapita dallaTabella() {
      final dalleParole = IlTemaDellaDomandaLibera.perParole(testo);
      return (
        tema: dalleParole,
        fonte: dalleParole == null ? FonteDelTema.nessuna : FonteDelTema.parole,
        oggetto: null,
      );
    }

    // **IL TETTO TECNICO**, ordini DI voce 15 e DL voce 09: oltre il tetto
    // il modello non si chiama, decide la tabella, e la persona non se ne
    // accorge.
    if (!await prendiUnaChiamata()) return dallaTabella();
    try {
      final risposta = await (chiamata ?? _chiamataVera)(istruzione, testo)
          .timeout(pazienza);
      final (id, oggetto) = _leggi(risposta);
      final dalModello = TemaDellaDomanda.daId(id);
      if (dalModello != null) {
        return (
          tema: dalModello,
          fonte: FonteDelTema.modello,
          oggetto: oggetto == null ? null : oggettoInForma(oggetto, testo),
        );
      }
      seGuasto?.call(RispostaFuoriDaiSei(risposta));
    } catch (errore) {
      // **IL GUASTO VA NEL REGISTRO, MAI ALLA PERSONA.** Timeout, rete
      // assente, servizio spento: la persona non se ne accorge, perche' la
      // tabella risponde lo stesso.
      seGuasto?.call(errore);
    }
    return dallaTabella();
  }

  /// **L'ID E L'OGGETTO DELLA RISPOSTA.** La risposta e' un oggetto JSON;
  /// una risposta che e' soltanto un id, come quelle delle prove scritte
  /// prima dell'ordine DL, vale come id senza oggetto.
  static (String?, String?) _leggi(String? risposta) {
    if (risposta == null) return (null, null);
    try {
      final j = jsonDecode(risposta);
      if (j is Map) {
        final o = j['oggetto'];
        return (
          _pulisci(j['tema'] as String?),
          o is String && o.trim().isNotEmpty ? o.trim() : null,
        );
      }
      if (j is String) return (_pulisci(j), null);
    } catch (errore) {
      // Non e' JSON: e' l'id da solo.
    }
    return (_pulisci(risposta), null);
  }

  /// Le parole che l'oggetto puo' avere senza che la domanda le contenga:
  /// articoli, preposizioni e possessivi, perche' *"mia sorella"* diventa
  /// *"tua sorella"*.
  static const Set<String> _paroleDiCornice = {
    'il',
    'lo',
    'la',
    'i',
    'gli',
    'le',
    'l',
    'un',
    'una',
    'uno',
    'tuo',
    'tua',
    'tuoi',
    'tue',
    'quel',
    'quella',
    'quello',
    'quei',
    'quelle',
    'questo',
    'questa',
    'del',
    'della',
    'dello',
    'dei',
    'delle',
    'di',
    'a',
    'da',
    'su',
    'per',
    'con',
    'in',
    'e',
    'al',
    'alla',
    'nel',
    'nella',
  };

  /// **L'OGGETTO COME SI SCRIVE NELLA RIPRESA**, o nullo se non regge.
  ///
  /// Ordine DL voce 08, dal banco col modello vero: *"giulia nella tua
  /// vita"* senza la maiuscola, *"dove sto andando"* alla prima persona,
  /// *"tuo lavoro"* senza l'articolo, che nella ripresa diventava *"la
  /// domanda su tuo lavoro"*. Qui l'oggetto riprende le maiuscole dei nomi
  /// propri dalla domanda e prende l'articolo davanti al possessivo, tranne
  /// che coi nomi di parentela al singolare: *"il tuo lavoro"*, ma *"tua
  /// sorella"*. **Deve cominciare da un articolo, da un possessivo, da un
  /// dimostrativo o da un nome proprio**: una parola qualunque in testa non
  /// si sa cucire a una preposizione, e allora vale la categoria.
  static String? oggettoInForma(String oggetto, String domanda) {
    if (!oggettoValido(oggetto, domanda)) return null;
    final maiuscole = <String, String>{};
    final nellaDomanda = RegExp(r"[A-Za-zÀ-ÿ]+").allMatches(domanda).toList();
    for (var k = 0; k < nellaDomanda.length; k++) {
      final w = nellaDomanda[k].group(0)!;
      // La prima parola della domanda ha la maiuscola comunque.
      if (k > 0 && w[0] != w[0].toLowerCase()) maiuscole[w.toLowerCase()] = w;
    }
    final parole = [
      for (final w in oggetto.trim().split(RegExp(r'\s+')))
        maiuscole[w.toLowerCase()] ??
            (w[0] != w[0].toLowerCase() &&
                    nellaDomanda.isNotEmpty &&
                    nellaDomanda.first.group(0) == w
                ? w
                : w.toLowerCase()),
    ];
    final prima = parole.first;
    final testa = prima.split("'").first;
    final eUnNome = prima[0] != prima[0].toLowerCase();
    if (!eUnNome && !_testeAmmesse.contains(testa)) return null;
    // **L'ARTICOLO DAVANTI AL POSSESSIVO**, tranne la parentela al singolare.
    final articolo = _articoloDelPossessivo[prima];
    if (articolo != null &&
        !(parole.length > 1 && _parentela.contains(parole[1]))) {
      parole.insert(0, articolo);
    }
    return _possessivoGiustificato(parole, domanda).join(' ');
  }

  /// **IL "TUO" SOLO SE LA DOMANDA DICEVA "MIO".** Ordine DL voce 08, dal
  /// banco col modello vero: *"Mio figlio trovera' lavoro?"* diventava *"la
  /// domanda riguardava il tuo lavoro"*, e il lavoro era del figlio. Il
  /// possessivo resta quando nella domanda un *"mio"* sta al massimo due
  /// parole prima della stessa parola; altrimenti si toglie, e l'articolo
  /// si accorda con la parola che segue: *"il tuo amico"* diventa
  /// *"l'amico"*.
  static List<String> _possessivoGiustificato(
      List<String> parole, String domanda) {
    final p = parole.indexWhere(_articoloDelPossessivo.containsKey);
    if (p < 0 || p + 1 >= parole.length) return parole;
    final cosa = parole[p + 1].toLowerCase();
    final q = [
      for (final m in RegExp("[a-zàèéìòù]+").allMatches(domanda.toLowerCase()))
        m.group(0)!,
    ];
    for (var k = 0; k < q.length; k++) {
      if (!const {'mio', 'mia', 'miei', 'mie'}.contains(q[k])) continue;
      if (q.skip(k + 1).take(2).contains(cosa)) return parole;
    }
    final r = [...parole];
    final possessivo = r.removeAt(p);
    var a = p - 1;
    if (a < 0) {
      // La parentela senza articolo: *"tua sorella"* diventa *"la
      // sorella"*.
      r.insert(0, _articoloDelPossessivo[possessivo]!);
      a = 0;
    }
    final dopo = r[a + 1];
    final vocale =
        RegExp('^[aeiouàèéìòùh]', caseSensitive: false).hasMatch(dopo);
    final impura =
        RegExp(r'^(s[^aeiouàèéìòù]|z|gn|ps|x|y)', caseSensitive: false)
            .hasMatch(dopo);
    switch (r[a]) {
      case 'il' || 'la' when vocale:
        r[a] = "l'$dopo";
        r.removeAt(a + 1);
      case 'il' when impura:
        r[a] = 'lo';
      case 'i' when vocale || impura:
        r[a] = 'gli';
    }
    return r;
  }

  /// Le parole con cui un oggetto puo' cominciare.
  static const Set<String> _testeAmmesse = {
    'il',
    'lo',
    'la',
    'l',
    'i',
    'gli',
    'le',
    'un',
    'una',
    'uno',
    'tuo',
    'tua',
    'tuoi',
    'tue',
    'quel',
    'quella',
    'quello',
    'quell',
    'quei',
    'quegli',
    'quelle',
    'questo',
    'questa',
    'questi',
    'queste',
  };

  static const Map<String, String> _articoloDelPossessivo = {
    'tuo': 'il',
    'tua': 'la',
    'tuoi': 'i',
    'tue': 'le',
  };

  /// **I NOMI DI PARENTELA AL SINGOLARE**, che col possessivo non vogliono
  /// l'articolo: *"tua sorella"*, *"tuo padre"*.
  static const Set<String> _parentela = {
    'sorella',
    'fratello',
    'madre',
    'padre',
    'figlio',
    'figlia',
    'marito',
    'moglie',
    'nonno',
    'nonna',
    'zio',
    'zia',
    'cugino',
    'cugina',
    'nipote',
    'suocero',
    'suocera',
    'cognato',
    'cognata',
    'genero',
    'nuora',
  };

  /// Le parole della prima persona, pronomi e verbi, che nell'oggetto non
  /// ci stanno.
  static const Set<String> _primaPersona = {
    'io',
    'me',
    'mi',
    'mio',
    'mia',
    'miei',
    'mie',
    'noi',
    'ci',
    'nostro',
    'nostra',
    'nostri',
    'nostre',
    'sto',
    'ho',
    'sono',
    'devo',
    'posso',
    'voglio',
    'faccio',
    'vado',
    'so',
    'riesco',
    'sento',
    'penso',
    'credo',
    'aspetto',
    'comincio',
    'resto',
    'tengo',
  };

  /// **LE PAROLE CHE NON NOMINANO NIENTE**: si possono scrivere, ma non
  /// bastano. *"niente di tuo"*, dal banco col modello vero, non e' un
  /// oggetto.
  static const Set<String> _paroleVuote = {
    'niente',
    'nulla',
    'qualcosa',
    'qualcuno',
    'tutto',
    'cosa',
    'cose',
  };

  /// **L'OGGETTO E' PRESO DALLA DOMANDA, E NON INVENTATO.** Da una a
  /// quattro parole; ogni parola piena viene dalla domanda, per radice:
  /// *"quel lavoro"* da *"il mio lavoro"*, *"il trasloco"* da *"traslocare"*
  /// no, perche' la radice e' diversa, e allora vale la categoria.
  static bool oggettoValido(String oggetto, String domanda) {
    final o = oggetto.trim();
    if (o.isEmpty || o.length > 40 || o.contains(RegExp(r'[\[\]|:?!.]'))) {
      return false;
    }
    final parole = o.toLowerCase().split(RegExp(r"[\s']+"));
    if (parole.isEmpty || parole.length > 4) return false;
    String radice(String w) => w.length > 5 ? w.substring(0, 5) : w;
    final nellaDomanda = {
      for (final m in RegExp('[a-zàèéìòù]+').allMatches(domanda.toLowerCase()))
        radice(m.group(0)!),
    };
    var piene = 0;
    for (final w in parole) {
      // **MAI LA PRIMA PERSONA**: la ripresa parla alla persona, e *"la
      // domanda su dove sto andando"* le rimette in bocca le sue parole.
      if (_primaPersona.contains(w)) return false;
      if (_paroleDiCornice.contains(w) || _paroleVuote.contains(w)) continue;
      piene++;
      if (!nellaDomanda.contains(radice(w))) return false;
    }
    return piene > 0;
  }

  /// Toglie spazi, virgolette e maiuscole: l'elenco chiuso rende il testo
  /// libero impossibile, ma una virgoletta di troppo non deve costare il tema.
  static String? _pulisci(String? s) =>
      s?.trim().replaceAll(RegExp(r'''["'`.\s]'''), '').toLowerCase();

  static Future<String?> _chiamataVera(
      String istruzione, String domanda) async {
    final m = FirebaseAI.vertexAI(location: regione).generativeModel(
      model: modello,
      systemInstruction: Content.system(istruzione),
      generationConfig: GenerationConfig(
        temperature: 0,
        maxOutputTokens: 96,
        thinkingConfig: ragionamentoPer(modello),
        // **L'ELENCO CHIUSO PER IL TEMA**: il tema non puo' essere altro che
        // uno dei sei id. L'oggetto e' testo, ordine DL voce 08, e passa da
        // `oggettoValido`: se non viene dalla domanda, si scarta.
        responseMimeType: 'application/json',
        responseSchema: Schema.object(properties: {
          'tema': Schema.enumString(enumValues: [
            for (final t in TemaDellaDomanda.values) t.name,
          ]),
          'oggetto': Schema.string(),
        }),
      ),
    );
    final r = await m.generateContent([Content.text(domanda)]);
    return r.text;
  }
}

/// Il modello ha risposto con qualcosa che non e' uno dei sei id.
class RispostaFuoriDaiSei implements Exception {
  const RispostaFuoriDaiSei(this.risposta);
  final String? risposta;
  @override
  String toString() => 'il modello ha risposto "$risposta", che non è uno '
      'dei sei temi';
}
