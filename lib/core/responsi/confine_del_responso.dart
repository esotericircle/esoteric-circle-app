/// IL CONFINE, E NON SI SUPERA MAI. Ordine S voce 17.
///
/// **Perche' esiste, e proprio adesso.** Il registro dei responsi diventa molto
/// piu' diretto: si parla in seconda persona, si indica un'azione, si dice cosa
/// rimandare. Un registro diretto avvicina il confine, quindi il confine va
/// scritto nel codice e presidiato, non lasciato al buon senso di chi scrive la
/// prossima riga di corpus.
///
/// **SI PUO'**: parlare in seconda persona, essere concreti, indicare un'azione,
/// dire cosa la lettura suggerisce di osservare o di rimandare.
///
/// **NON SI PUO' MAI**: annunciare un evento futuro come certo; dare indicazioni
/// mediche, legali o finanziarie; parlare di malattia, morte, gravidanza, denaro
/// altrui o esiti giudiziari come previsioni.
///
/// Ammesso: "questa runa ti chiede di rimandare la decisione di qualche giorno".
/// Vietato: "nei prossimi giorni perderai il lavoro".
library;

/// UNA VIOLAZIONE TROVATA, con la sua ragione e il pezzo di testo che la mostra.
class ViolazioneDelConfine {
  const ViolazioneDelConfine({
    required this.regola,
    required this.trovato,
    required this.intorno,
  });

  /// Quale regola e' stata superata, in parole.
  final String regola;

  /// Il pezzo esatto che l'ha superata.
  final String trovato;

  /// Il testo attorno, per capire senza aprire il corpus.
  final String intorno;

  @override
  String toString() => '$regola: «$trovato» in «$intorno»';
}

/// IL CONFINE DEL RESPONSO, in un punto solo.
class ConfineDelResponso {
  const ConfineDelResponso._();

  /// COSA SI PUO' FARE, dichiarato perche' un confine che elenca solo divieti
  /// insegna la paura e non il mestiere.
  static const List<String> siPuo = [
    'parlare in seconda persona',
    'essere concreti',
    'indicare un\'azione',
    'dire cosa la lettura suggerisce di osservare o di rimandare',
  ];

  /// COSA NON SI PUO' MAI.
  static const List<String> nonSiPuoMai = [
    'annunciare un evento futuro come certo',
    'dare indicazioni mediche, legali o finanziarie',
    'parlare di malattia, morte, gravidanza, denaro altrui o esiti giudiziari '
        'come previsioni',
  ];

  /// I TEMI DELICATI, e sono RADICI perche' l'italiano declina.
  ///
  /// **NON sono parole vietate, e la differenza e' tutta la voce.** L'ordine
  /// vieta di parlare di malattia, morte, gravidanza, denaro altrui o esiti
  /// giudiziari **come previsioni**: e' il rivolgerli alla persona che li rende
  /// una previsione, non il nominarli.
  ///
  /// **LO HA DETTO LA PRIMA MISURA, e va scritto.** La prima stesura vietava le
  /// radici in assoluto e ha accusato venticinque responsi delle rune per la
  /// parola "eredita'": e' il significato tradizionale di **Othala**, "l'eredita'
  /// e la casa", che non promette niente a nessuno. Una prova che accusa il falso
  /// insegna a ignorarla, quindi la grandezza misurata e' cambiata: un tema
  /// delicato e' una violazione quando nella STESSA FRASE e' rivolto alla
  /// persona.
  static const List<String> temiDelicati = [
    'malatt', // malattia, malattie
    'diagnos', // diagnosi, diagnostico
    'guarigion', // guarigione
    'morir', // morirai, morire
    'morte',
    'gravidanz', // gravidanza
    'incinta',
    'divorzi', // divorzio, divorzierai
    'tribunale',
    'processo penale',
    'eredit', // eredita', erediterai
    'licenziat', // licenziato, licenziamento
    'investiment', // investimenti
    'mutuo',
  ];

  /// COME SI RICONOSCE CHE UNA FRASE E' RIVOLTA ALLA PERSONA.
  ///
  /// La seconda persona: il pronome, il possessivo, o un verbo alla seconda. E'
  /// il segno che distingue il significato di un simbolo ("l'eredita' e la
  /// casa") da una previsione su di te ("l'eredita' ti aspetta").
  static final RegExp rivoltaATe =
      RegExp(r'\b(ti|te|tu|tuo|tua|tuoi|tue|avrai|sarai)\b',
          caseSensitive: false);

  /// LE FORME DELLA PREVISIONE CERTA.
  ///
  /// Non e' l'argomento a essere vietato, e' la CERTEZZA: "un incontro puo'
  /// cambiare la giornata" e' una lettura, "incontrerai la persona giusta" e' una
  /// previsione. Si cercano percio' i futuri indicativi in seconda persona, che
  /// sono il modo in cui una previsione certa si scrive in italiano.
  static final List<RegExp> formeDellaPrevisione = [
    // "perderai", "troverai", "riceverai", "incontrerai": futuro semplice, tu.
    RegExp(r'\b\w{3,}(erai|irai|drai|rrai)\b', caseSensitive: false),
    // "ti accadra'", "arrivera' entro", "succedera'".
    RegExp(r"\b\w{3,}(era|ira)['’]\s", caseSensitive: false),
    // "e' certo che", "sicuramente accadra'", "senza dubbio".
    RegExp(r"\b(e['’]\s+certo|sicuramente|senza\s+dubbio)\b",
        caseSensitive: false),
  ];

  /// IL DISCLAIMER GIA' IN USO, e non uno nuovo.
  ///
  /// Ordine S voce 17: ogni responso porta il disclaimer che l'app ha gia'. Vive
  /// in `ArtCatalog.disclaimerCornice` e questa costante NON lo copia: chi
  /// controlla legge quello, perche' due disclaimer diversi sono due promesse
  /// diverse sulla stessa cosa.
  static const String doveViveIlDisclaimer =
      'ArtCatalog.disclaimerCornice';

  /// Cerca le violazioni in un testo. Vuoto se il testo sta dentro il confine.
  ///
  /// **SI GUARDA FRASE PER FRASE**, e non il testo intero: un responso puo'
  /// nominare un simbolo in una frase e rivolgersi alla persona in un'altra, e
  /// prendere il testo come un blocco unico farebbe di due frasi innocenti una
  /// violazione.
  static List<ViolazioneDelConfine> violazioni(String testo) {
    final trovate = <ViolazioneDelConfine>[];
    for (final frase in _frasi(testo)) {
      final basso = frase.toLowerCase();

      // 1. LA PREVISIONE DATA PER CERTA, e questa vale da sola: non conta di
      //    cosa parla, conta che sia annunciata come certa.
      for (final forma in formeDellaPrevisione) {
        final trovato = forma.firstMatch(frase);
        if (trovato == null) continue;
        trovate.add(ViolazioneDelConfine(
          regola: 'previsione data per certa',
          trovato: trovato.group(0)!.trim(),
          intorno: frase.trim(),
        ));
      }

      // 2. IL TEMA DELICATO RIVOLTO ALLA PERSONA. Nominare Othala non e' parlare
      //    di eredita': dire che l'eredita' ti aspetta lo e'.
      if (!rivoltaATe.hasMatch(frase)) continue;
      for (final tema in temiDelicati) {
        if (!basso.contains(tema)) continue;
        trovate.add(ViolazioneDelConfine(
          regola: 'tema delicato rivolto alla persona',
          trovato: tema,
          intorno: frase.trim(),
        ));
      }
    }
    return trovate;
  }

  /// Le frasi di un testo: si spezza sui punti fermi, sugli interrogativi e sugli
  /// esclamativi, e anche sui capoversi.
  static List<String> _frasi(String testo) => testo
      .split(RegExp(r'(?<=[.!?])\s+|\n+'))
      .where((f) => f.trim().isNotEmpty)
      .toList();

  static String _intorno(String testo, int dove) {
    final da = (dove - 40).clamp(0, testo.length);
    final a = (dove + 60).clamp(0, testo.length);
    return testo.substring(da, a).replaceAll('\n', ' ');
  }

  /// IL CONFINE PER IL MODELLO, che e' lo stesso confine.
  ///
  /// Le istruzioni di sistema non riscrivono le regole con parole loro: le
  /// leggono da qui. Due copie della stessa regola divergono al primo ritocco, e
  /// a quel punto il corpus e il modello obbediscono a due confini diversi.
  static String get perIlModello => 'IL CONFINE CHE NON SI SUPERA MAI:\n'
      '${nonSiPuoMai.map((r) => '- Non $r.').join('\n')}\n'
      'Si può invece: ${siPuo.join('; ')}.';
}
