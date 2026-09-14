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
  'questo', 'questa', 'quanto', 'quanta', 'tanto', 'tanta', 'tutto',
  'tutta', 'molto', 'molta', 'poco', 'poca', 'visto', 'vista', 'giusto',
  'giusta', 'posto', 'posta', 'canto', 'conto', 'conta', 'punto', 'punta',
  'santo', 'santa', 'volto', 'volta', 'mondo', 'gesto', 'gesta', 'testo',
  'resto', 'resta', 'costo', 'costa', 'lato', 'adesso', 'spesso',
  'processo', 'successo', 'interesse',
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
final RegExp _verboDa = RegExp(
    "(?<![$_l'])(?:$_v2) da ($_gen)(?![$_l])",
    caseSensitive: false);
final RegExp _infinitoSempre = RegExp(
    "(?<![$_l'])(?:$_viSempre) $_avv($_gen)(?![$_l])",
    caseSensitive: false);
final RegExp _infinito =
    RegExp("(?<![$_l'])(?:$_vi) $_avv($_gen)(?![$_l])", caseSensitive: false);
final RegExp _secondaPersona = RegExp(
    '(?<![$_l])(ti|tu|sei|hai|puoi|vuoi|devi|sai|riesci|aspetti|temi|rischi|'
    'smetti|provi|cerchi|preferisci|scegli|serve)(?![$_l])',
    caseSensitive: false);
final RegExp _stesso =
    RegExp('(?<![$_l])(te stess[oa]|tu stess[oa])(?![$_l])', caseSensitive: false);
final RegExp _vocativo =
    RegExp(r'(?:^|[.!?]\s+|\n)\s*(Benvenut[oa]|Bentornat[oa]|Car[oa])(?=[ ,!])');

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
List<String> formeContrarieAllaForma(String testo, CourtesyForm forma) {
  final forme = formeDelGenere(testo);
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
