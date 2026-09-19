import '../astro/zodiac.dart';
import '../rituals/runes.dart';
import '../tarot/tarot_card.dart';

/// COME ARRIVA A VIDEO IL TESTO DI UN RESPONSO.
///
/// **Il dato che ha fatto nascere questo file.** Il 3 agosto 2026 Caligo
/// consegnava `**Laguz**` e la bolla mostrava gli asterischi, perche' la chat
/// non rende il Markdown. Renderlo sarebbe stata la correzione sbagliata: la
/// porta si sarebbe aperta anche a titoli ed elenchi, e una superficie fatta
/// per leggersi come prosa sarebbe diventata un documento.
///
/// **Tre difese, e ciascuna serve a una cosa diversa.**
///
/// 1. Il modello non lo scrive, perche' glielo si vieta nella persona come
///    VINCOLO DI FORMATO e non come regola di voce. La differenza l'abbiamo
///    gia' pagata una volta: le regole comuni di voce fanno scivolare i
///    registri, ed e' cosi' che la chiusura generica ha portato Medora al 70
///    per cento di attribuzione.
/// 2. Se lo scrive lo stesso, e prima o poi succede, [pulisci] lo toglie al
///    confine. Un filtro non e' un ripiego muto: e' l'ultima riga di difesa di
///    una cosa che dipende da un modello, cioe' da qualcosa che non
///    controlliamo.
/// 3. **L'enfasi sui nomi noti e' NOSTRA.** Non si spera che il modello
///    evidenzi la runa giusta: si prende l'elenco delle entita' che l'app gia'
///    conosce, rune, arcani e segni, e si evidenziano quelle. Cosi' Laguz si
///    vede meglio che in grassetto, e senza un asterisco a schermo.
class TestoDelResponso {
  const TestoDelResponso._();

  /// IL VINCOLO DI FORMATO per la persona del Maestro.
  ///
  /// **Sta qui e non fra le regole di voce, ed e' una distinzione che abbiamo
  /// gia' pagato.** Le regole comuni di voce sono il posto dove una riga
  /// generica si mette a comandare su quella del singolo Maestro: e' cosi' che
  /// una chiusura scritta per tutti e tre ha portato Medora dal 98,3 al 70 per
  /// cento di attribuzione. Questo non e' stile, e' cosa sa fare la superficie
  /// che mostra il testo, quindi va detto come un fatto tecnico, in un blocco
  /// suo, dove non ha niente da contendere alla voce.
  static const String vincoloDiFormato =
      'FORMA DEL TESTO, VINCOLO TECNICO E NON DI STILE:\n'
      '- L\'app mostra il tuo testo come prosa semplice e NON interpreta il '
      'Markdown: un asterisco che scrivi tu arriva a schermo come asterisco.\n'
      '- Quindi niente asterischi per il grassetto o il corsivo, niente '
      'trattini bassi, niente cancelletti per i titoli, niente apici inversi, '
      'niente elenchi puntati o numerati.\n'
      '- I nomi importanti, una runa o un arcano o un segno, li mette in '
      'risalto l\'app da sola: tu scrivili normali, con la maiuscola.';

  /// I marcatori che AVVOLGONO una parola, e che non devono mai arrivare a
  /// video in nessuna posizione.
  ///
  /// **Solo quelli senza ambiguita'.** Un asterisco singolo o un trattino
  /// basso in mezzo a una frase italiana possono capitare per altre ragioni, e
  /// pretendere che non compaiano mai darebbe falsi allarmi: una prova che
  /// grida al lupo si finisce per allentarla. Quelli qui sotto invece non
  /// hanno nessun uso legittimo in prosa.
  ///
  /// Enumerati e pubblici: la prova che setaccia le risposte li percorre tutti
  /// invece di cercarne uno a campione.
  static const List<String> marcatoriVietati = ['**', '__', '~~', '`'];

  /// Il corsivo a un segno solo, che si toglie solo quando ABBRACCIA una
  /// parola, e il titolo, che si toglie solo a inizio riga. Stanno separati
  /// dai precedenti perche' si riconoscono dalla POSIZIONE e non dalla sola
  /// presenza: metterli nello stesso elenco vorrebbe dire cercarli nel modo
  /// sbagliato, ed e' esattamente l'errore che questa separazione ha fatto
  /// emergere quando la prova costruiva "##Laguz##".
  static const List<String> segniDiCorsivo = ['*', '_'];

  /// Vero se [testo] porta un marcatore che a video si vedrebbe.
  static bool portaUnMarcatore(String testo) =>
      marcatoriVietati.any(testo.contains);

  /// Toglie i marcatori lasciando le parole.
  ///
  /// **Toglie il segno, non il contenuto.** `**Laguz**` diventa `Laguz`, non
  /// sparisce: una frase mutilata sarebbe peggio di un asterisco.
  static String pulisci(String grezzo) {
    var testo = grezzo;
    // Le coppie che circondano una parola. L'ordine conta: prima le doppie,
    // altrimenti la singola spezzerebbe la doppia e resterebbe un asterisco.
    for (final coppia in marcatoriVietati) {
      testo = testo.replaceAll(coppia, '');
    }
    // Il corsivo a una sola stella o trattino basso, solo quando ABBRACCIA una
    // parola: un trattino basso in mezzo a un nome di file non e' un corsivo, e
    // toglierlo storpierebbe la parola.
    testo = testo.replaceAllMapped(
      RegExp(r'(?<![\w*_])([*_])(?=\S)(.+?)(?<=\S)\1(?![\w*_])'),
      (m) => m.group(2)!,
    );
    // I titoli, solo a inizio riga.
    testo = testo.replaceAll(RegExp(r'^#{1,6}\s*', multiLine: true), '');
    return testo;
  }

  /// I nomi che l'app CONOSCE GIA', e che quindi puo' evidenziare con
  /// sicurezza.
  ///
  /// Si prendono dai cataloghi che esistono, non da un quarto elenco scritto a
  /// mano: le ventiquattro rune, i settantotto arcani, i dodici segni. Un
  /// elenco copiato divergerebbe dal suo originale, ed e' il difetto che questo
  /// progetto ha gia' visto piu' volte.
  /// **Fuori i nomi che in italiano sono parole comuni.** Gli Arcani maggiori
  /// si chiamano "Il Sole", "La Luna", "La Stella", "Il Mondo": messi
  /// nell'elenco accenderebbero mezza prosa, e "il tuo Sole in Cancro", che e'
  /// astrologia e non cartomanzia, si illuminerebbe come se fosse una carta.
  /// Un'enfasi che scatta sempre non e' enfasi, e' rumore. Restano fuori i nomi
  /// che cominciano con un articolo, e dentro cio' che non si confonde: le
  /// ventiquattro rune, i dodici segni, gli Arcani minori come "Asso di Coppe".
  static bool _siConfonde(String nome) => RegExp(
        r"^(il|lo|la|l'|i|gli|le)\b",
        caseSensitive: false,
      ).hasMatch(nome.trim());

  static final Set<String> nomiNoti = {
    for (final runa in kElderFuthark) runa.name,
    for (final carta in TarotDeck.cards) carta.name,
    for (final segno in Zodiac.values) segno.italianName,
  }.where((n) => n.trim().length >= 3 && !_siConfonde(n)).toSet();

  /// Vero se in [testo] c'e' almeno un nome da mettere in risalto.
  ///
  /// Serve alla bolla per NON costruire un testo ricco quando non c'e' niente
  /// da arricchire: un `Text.rich` non ha `data`, quindi ogni prova che cerca
  /// una frase a schermo smetterebbe di trovarla. Se n'e' accorta la prova del
  /// ripiego, che non c'entrava niente con l'enfasi.
  static bool portaUnNomeNoto(String testo) => pezzi(testo).any((p) => p.inOro);

  /// I pezzi in cui si spezza [testo] per l'enfasi: ogni pezzo dice se va in
  /// oro. Funzione PURA, cosi' si prova senza montare uno schermo.
  ///
  /// La ricerca e' a parola intera e distingue le maiuscole: "Toro" il segno
  /// si evidenzia, "toro" in mezzo a una frase no, e "Laguz" dentro
  /// "Laguzzo" nemmeno.
  static List<PezzoDelResponso> pezzi(String testo) {
    if (testo.isEmpty) return const [];
    final nomi = nomiNoti.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    final schema = RegExp(
        r'(?<![\p{L}])(' + nomi.map(RegExp.escape).join('|') + r')(?![\p{L}])',
        unicode: true);

    final pezzi = <PezzoDelResponso>[];
    var da = 0;
    for (final trovato in schema.allMatches(testo)) {
      if (trovato.start > da) {
        pezzi.add(PezzoDelResponso(testo.substring(da, trovato.start), false));
      }
      pezzi.add(PezzoDelResponso(trovato.group(0)!, true));
      da = trovato.end;
    }
    if (da < testo.length) {
      pezzi.add(PezzoDelResponso(testo.substring(da), false));
    }
    return pezzi;
  }
}

/// Un pezzo di responso, con la sua enfasi.
class PezzoDelResponso {
  const PezzoDelResponso(this.testo, this.inOro);

  final String testo;

  /// Vero se e' un nome che l'app conosce, e va in oro.
  final bool inOro;

  @override
  String toString() => inOro ? '[$testo]' : testo;
}
