/// **LE PAROLE CHE DICONO IL GENERE DI CHI LEGGE.** Ordine DL voce 06.
///
/// Il dizionario e il criterio della guardia `il_genere_non_si_indovina`. **Stanno
/// in `lib`** perche' li usano anche le guardie dei testi che scrive il modello,
/// voci DL.07 e DL.13: un criterio scritto due volte smette presto di contare
/// la stessa cosa.
///
/// **IL DIZIONARIO E' QUELLO DELL'ORDINE**, e non si allenta: se una parola
/// compare dove non riguarda chi legge, si restringe il criterio. **Il
/// criterio**, in tre forme:
///
/// 1. un verbo alla seconda persona (*sei, eri, sarai, ti senti, ti sei,
///    resti, rimani, diventi...*), anche dopo un avverbio o dopo *da*, seguito
///    da una parola del dizionario o da un participio in *-ato -uto -ito -eso
///    -esso -otto -sto -nto*; tranne dopo un pronome oggetto, perche' *te lo
///    sei portato* si accorda con la cosa e non con chi legge;
/// 2. un infinito seguito da una parola del dizionario: i riflessivi
///    (*sentirti, trovarti, fatti trovare*) sempre, gli altri (*essere,
///    restare, stare...*) solo a inizio frase, dopo *di*, o dopo un verbo alla
///    seconda persona nella stessa frase. Cosi' *"Restare solo"* conta, e
///    *"la foto, senza mai essere caricata"* no;
/// 3. *te stesso*, *te stessa*, *tu stesso*, *tu stessa*, e i vocativi in
///    apertura, *Benvenuto*, *Bentornato*, *Caro*, coi femminili.
///
/// **Gli aggettivi che non cambiano col genere** (*socievole, essenziale,
/// forte*) stanno nel dizionario dell'ordine ma da soli non dicono niente: il
/// genere lo porta il compagno accordato nella stessa frase, *"sei socievole e
/// caloroso"*, ed e' quello che si prende.
library;

import 'user_profile.dart';

/// Il dizionario dell'ordine DL voce 06, al maschile.
const List<String> dizionarioDelGenere = [
  // participi
  'arrivato', 'nato', 'sceso', 'andato', 'tornato', 'stato', 'rimasto',
  'uscito', 'venuto', 'entrato', 'disposto', 'chiamato', 'protetto',
  'difeso', 'riconosciuto', 'guadagnato', 'caricato', 'speso', 'imposto',
  'diventato', 'scordato',
  // aggettivi
  'pronto', 'sicuro', 'solo', 'stanco', 'curioso', 'attento', 'bloccato',
  'assediato', 'sopraffatto', 'libero', 'generoso', 'concentrato',
  'espressivo', 'socievole', 'caloroso', 'essenziale', 'misurato',
  'raccolto', 'prezioso', 'onesto', 'deluso', 'forte',
];

/// I vocativi dell'ordine.
const List<String> vocativiDelGenere = ['Benvenuto', 'Bentornato', 'Caro'];

const Set<String> _invariabili = {'socievole', 'essenziale', 'forte'};

/// Le parole che il participio generico prende e che non sono participi
/// riferiti a chi legge: *sei adesso*, *sei spesso*.
const Set<String> _nonParticipi = {
  'questo',
  'questa',
  'quanto',
  'quanta',
  'tanto',
  'tanta',
  'tutto',
  'tutta',
  'molto',
  'molta',
  'poco',
  'poca',
  'visto',
  'vista',
  'giusto',
  'giusta',
  'posto',
  'posta',
  'canto',
  'conto',
  'conta',
  'punto',
  'punta',
  'santo',
  'santa',
  'volto',
  'volta',
  'mondo',
  'gesto',
  'gesta',
  'testo',
  'resto',
  'resta',
  'costo',
  'costa',
  'lato',
  'adesso',
  'spesso',
  // *"diventi presto mamma"*: un avverbio, dalla misura dell'ordine DN.
  'presto',
  'processo',
  'successo',
  'interesse',
};

const String _l = 'a-zàèéìòù';

final List<String> _parole = [
  for (final p in dizionarioDelGenere)
    if (!_invariabili.contains(p)) ...[p, '${p.substring(0, p.length - 1)}a'],
];

const String _v2 = r'sei|eri|sarai|saresti|fossi|ti senti|ti sentirai|'
    r'ti sentiresti|ti sentivi|ti sei|ti eri|resti|rimani|diventi|diventerai|'
    r'sembri|ti trovi|ti ritrovi|ti scopri|ti scoprirai|sentendoti';
const String _viSempre = r'sentirti|esserti|ritrovarti|trovarti|'
    r'farti trovare|fatti trovare|sentendoti';
const String _vi = r'essere|esserne|stare|restare|rimanere|diventare|'
    r'restando|rimanendo';
const String _avv = r'(?:(?:più|così|già|molto|troppo|ancora|davvero|anche|'
    r'sempre|mai|poco|tanto|meno|ben|abbastanza|di nuovo|forse|oggi|qui|sì|'
    r'stat[oa]) )*';
const String _part = '[$_l]{2,}(?:at|ut|it|es|ess|ott|st|nt)[oa]';

final String _gen = _parole.join('|');

final RegExp _verbo = RegExp(
    "(?<![$_l'])(?<!\\blo )(?<!\\bla )(?<!\\bli )(?<!\\ble )(?<!l')"
    '(?:$_v2) $_avv($_gen|$_part)(?![$_l])',
    caseSensitive: false);
final RegExp _verboDa =
    RegExp("(?<![$_l'])(?:$_v2) da ($_gen)(?![$_l])", caseSensitive: false);
final RegExp _infinitoSempre = RegExp(
    "(?<![$_l'])(?:$_viSempre) $_avv($_gen)(?![$_l])",
    caseSensitive: false);
final RegExp _infinito =
    RegExp("(?<![$_l'])(?:$_vi) $_avv($_gen)(?![$_l])", caseSensitive: false);
final RegExp _secondaPersona = RegExp(
    '(?<![$_l])(ti|tu|sei|hai|puoi|vuoi|devi|sai|riesci|aspetti|temi|rischi|'
    'smetti|provi|cerchi|preferisci|scegli|serve)(?![$_l])',
    caseSensitive: false);
final RegExp _stesso = RegExp('(?<![$_l])(te stess[oa]|tu stess[oa])(?![$_l])',
    caseSensitive: false);
final RegExp _vocativo = RegExp(
    r'(?:^|[.!?]\s+|\n)\s*(Benvenut[oa]|Bentornat[oa]|Car[oa])(?=[ ,!])');

/// **LA MARCA**, tre campi fra quadre: cio' che sta dentro e' concordato.
final RegExp marcaDelGenere = RegExp(r'\[[^\[\]|]*\|[^\[\]|]*\|[^\[\]]*\]');

/// Le forme di [testo] che dicono il genere di chi legge, fuori dalle marche.
List<String> formeDelGenere(String testo) {
  final t = testo.replaceAll(marcaDelGenere, '');
  final colpi = <String>[];
  for (final m in _verbo.allMatches(t)) {
    if (_nonParticipi.contains(m.group(1)!.toLowerCase())) continue;
    colpi.add(m.group(0)!);
  }
  for (final m in _verboDa.allMatches(t)) {
    colpi.add(m.group(0)!);
  }
  for (final m in _infinitoSempre.allMatches(t)) {
    colpi.add(m.group(0)!);
  }
  for (final m in _infinito.allMatches(t)) {
    final inizio = [
      t.lastIndexOf('.', m.start),
      t.lastIndexOf('!', m.start),
      t.lastIndexOf('?', m.start),
      t.lastIndexOf('\n', m.start),
    ].reduce((a, b) => a > b ? a : b);
    final prima = t.substring(inizio + 1, m.start);
    if (prima.trim().isEmpty ||
        _secondaPersona.hasMatch(prima) ||
        prima.endsWith(' di ')) {
      colpi.add(m.group(0)!);
    }
  }
  for (final m in _stesso.allMatches(t)) {
    colpi.add(m.group(0)!);
  }
  for (final m in _vocativo.allMatches(t)) {
    colpi.add(m.group(1)!);
  }
  return colpi;
}

/// **LE FORME CHE CONTRADDICONO LA FORMA SCELTA**, per i testi che scrive il
/// modello. Ordine DL voci 07 e 13.
///
/// Il modello riceve il blocco di cortesia e scrive nella forma della persona:
/// al maschile con chi ha scelto il maschile, al femminile con chi ha scelto
/// il femminile. **Si scarta la riga che la contraddice**: col neutro ogni
/// forma accordata, col maschile quelle al femminile, col femminile quelle al
/// maschile.
final RegExp _cliticoConParticipio = RegExp(
    r'(?<![a-zàèéìòù])ti (?:ha|hanno|abbia|abbiano|avrà|avranno) '
    r'(vist[oa]|sentit[oa]|trovat[oa]|lasciat[oa]|res[oa]|fatt[oa]) '
    r'([a-zàèéìòù]+)',
    caseSensitive: false);

/// **IL CLITICO COL VERBO CHE REGGE UN PREDICATIVO**, ordine DN voce 08:
/// *"Cosa ti tiene legata"*, titolo del modello alla prova a video della
/// build 2252, a un profilo neutro. Il verbo e' della cosa, e l'aggettivo e'
/// di chi legge.
final RegExp _cliticoCheRegge = RegExp(
    r'(?<![a-zàèéìòù])ti (?:tiene|tengono|terrà|rende|rendono|renderà|lascia|'
    r'lasciano|lascerà|fa sentire|fanno sentire|vuole|vogliono|trova|trovano|'
    r'vede|vedono) '
    // *"ti fa sentire piu' leggero"*, alla riprova a video della 2259:
    // l'avverbio in mezzo nascondeva l'aggettivo.
    r'(?:(?:più|meno|così|troppo|molto|tanto|ancora|già|davvero) )?'
    r'([a-zàèéìòù]+)',
    caseSensitive: false);

/// **IL RIFLESSIVO DI CHI LEGGE COL PARTICIPIO FUORI DAL DIZIONARIO**,
/// ordine DN voce 08: *"Puoi sentirti divisa"*, risposta del modello a un
/// profilo neutro alla riprova a video della build 2253. Il criterio di
/// `lib` cerca dopo *sentirti* solo le parole del dizionario; qui si guarda
/// la desinenza.
final RegExp _riflessivoCheRegge = RegExp(
    r'(?<![a-zàèéìòù])(?:sentirti|esserti|ritrovarti|trovarti|sentendoti|'
    r'ti senti|ti sentirai|ti sentiresti|ti sei sentit[oa]|'
    // *"Puoi essergli vicina"*, alla riprova della 2254.
    r'essergli|esserle|essere loro|stargli|starle|restargli|restarle) '
    r'(?:(?:più|meno|così|troppo|molto|tanto|ancora|già|davvero) )?'
    r'([a-zàèéìòù]+)',
    caseSensitive: false);

/// Le parole in *o* e in *a* che dopo *ti rende*, *sentirti* e simili non
/// dicono il genere di chi legge.
const Set<String> _nonConcordano = {
  'compagnia',
  'senza',
  'sopra',
  'sotto',
  'dentro',
  'fuori',
  'ancora',
  'meglio',
  'peggio',
  'prima',
  'dopo',
  'fino',
  'verso',
  'qualcosa',
  'qualcuno',
  'nessuno',
  'niente',
  'nulla',
  'sempre',
  'troppo',
  'ogni',
  'nella',
  'nello',
  'della',
  'dello',
  'alla',
  'allo',
  'sulla',
  'sullo',
  'dalla',
  'dallo',
  'questa',
  'questo',
  'quella',
  'quello',
  'parte',
  'tanta',
  'poca',
  'giustizia',
  'forza',
  'voglia',
  'paura',
  'fiducia',
};

bool _concorda(String parola) {
  final p = parola.toLowerCase();
  if (p.length < 4 || !RegExp(r'[oa]$').hasMatch(p)) return false;
  return !_nonParticipi.contains(p) && !_nonConcordano.contains(p);
}

List<String> formeContrarieAllaForma(String testo, CourtesyForm forma) {
  final forme = [
    ...formeDelGenere(testo),
    // **IL CLITICO COL PARTICIPIO**, ordine DN voce 06: *"le persone che
    // ti hanno visto arrabbiato"*, dalla sonda col modello vero, con la
    // forma neutra. Il criterio della guardia di `lib` cerca il verbo alla
    // seconda persona, e qui il verbo e' degli altri: si guarda solo nei
    // testi del modello.
    // Il participio dopo *avere* puo' restare al maschile: si guarda la
    // parola che segue.
    for (final m in _cliticoConParticipio.allMatches(testo)) ...[
      if (RegExp(r'(at|ut|it)[oa]$').hasMatch(m.group(2)!) ||
          dizionarioDelGenere.contains(m.group(2)!.toLowerCase()))
        m.group(2)!,
    ],
    // **DOPO IL VERBO CHE REGGE UN PREDICATIVO DI CHI LEGGE, LA DESINENZA**,
    // non piu' il dizionario: *"ti rendono fiera"*, alla riprova a video della
    // 2256, dopo *"sentirti divisa"* e *"essergli vicina"*. Il dizionario non
    // finisce mai; la desinenza in *o* e in *a* si', con l'elenco delle parole
    // che non concordano.
    for (final m in [
      ..._riflessivoCheRegge.allMatches(testo),
      ..._cliticoCheRegge.allMatches(testo),
    ])
      if (_concorda(m.group(1)!)) m.group(1)!,
    // **L'INFANZIA DI CHI LEGGE**, ordine DN voce 08: *"qualcosa che ti
    // apparteneva da piccola"*, alla riprova a video della 2258, a un profilo
    // neutro. Il modello ripeteva la parola che la persona aveva scritto, ma
    // la forma la decide il profilo.
    for (final m in RegExp(
            r'(?<![a-zàèéìòù])da (piccol[oa]|bambin[oa]|ragazzin[oa]|'
            r'ragazz[oa])(?![a-zàèéìòù])',
            caseSensitive: false)
        .allMatches(testo))
      m.group(1)!,
  ];
  // **LA DESINENZA VIETATA LA DECIDE LA PORTA**, come ogni altra scelta
  // secondo il genere: qui c'era un secondo `masculine ? 'a' : 'o'`, e la
  // guardia della porta sola l'ha visto appena il file e' entrato in `lib`.
  // Col neutro la porta da' la stringa vuota, e ogni forma accordata e'
  // contraria.
  final vietata = LaMarcaDelGenere.scegli(
      maschile: 'a', femminile: 'o', neutro: '', forma: forma);
  if (vietata.isEmpty) return forme;
  return [
    for (final f in forme)
      if (f.trim().toLowerCase().endsWith(vietata)) f,
  ];
}
