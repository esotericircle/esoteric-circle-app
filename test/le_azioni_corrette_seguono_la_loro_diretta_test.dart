// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/rituals/le_risposte_dirette.g.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LE AZIONI CORRETTE SEGUONO LA LORO DIRETTA, E LE FRASI DEL LETTORE SONO
/// FUORI.** Ordine GA voce GA.06, riapertura delle Rune di Caligo, ultimo
/// giro, 21 ottobre 2026.
///
/// Il lettore cieco indipendente, sulle dodici gettate varie: solo 17 schede
/// su 35 avevano il "Cosa fare" legato alla domanda, e almeno sei non
/// seguivano nemmeno la risposta della propria scheda (Isa "uno sguardo
/// esterno" sopra "scrivi tre righe su come ti senti", Gebo "un ringraziamento
/// sincero" sopra "parli tu per cinque minuti e poi ascolti", Eihwaz "quanta
/// attenzione puoi dare" sopra "di' a chi e' coinvolto...", Tiwaz "a viso
/// aperto" sopra "scegli un impegno", Algiz, Fehu). Padre: le voci di
/// `azione.md` del secondo giro (GA.06, 511229c2), scritte da piu' mani e
/// numerate a coppie con la diretta senza che nessuno le leggesse accostate:
/// in molti gruppi le azioni stavano scalate di un posto.
///
/// **Cio' che questa guardia sa e cio' che non sa.** L'accordo fra una
/// risposta e la sua azione e' un fatto di senso: nessuna misura sulle parole
/// lo prende (provato: la sovrapposizione di radici da' 84 violazioni sul
/// corpus di prima e 96 su quello curato, cioe' non distingue). Qui stanno le
/// coppie che il lettore ha contato e che la cura ha rifatto: per ognuna, la
/// parola della diretta e quella che l'azione deve riprendere. Le coppie non
/// lette (l'allineamento delle altre e' debito dichiarato nel rapporto)
/// restano a chi le legge.
void main() {
  // gruppo, numero, la parola della diretta, la parola che l'azione riprende.
  final coppie = <(String, int, RegExp, RegExp)>[
    ('Isa/dritta/come', 7, RegExp('sguardo esterno'), RegExp('persona|fidata')),
    ('Isa/dritta/come', 5, RegExp('chiarezza fredda'), RegExp('una sola cosa')),
    ('Gebo/dritta/come', 7, RegExp('ringraziamento'), RegExp('ricevuto|serv')),
    ('Gebo/dritta/come', 3, RegExp('patto chiaro'), RegExp('offri.*aspetti')),
    (
      'Gebo/dritta/come',
      6,
      RegExp('chiedi anche'),
      RegExp('di cui hai bisogno')
    ),
    (
      'Eihwaz/dritta/come',
      7,
      RegExp('quanta attenzione'),
      RegExp('quanto tempo e quanta attenzione')
    ),
    (
      'Eihwaz/dritta/come',
      3,
      RegExp('punto fermo'),
      RegExp('ripeti la stessa')
    ),
    ('Tiwaz/dritta/come', 2, RegExp('viso aperto'), RegExp('prima persona')),
    (
      'Hagalaz/dritta/come',
      5,
      RegExp('nomina con franchezza'),
      RegExp('punto che non regge')
    ),
    (
      'Hagalaz/dritta/come',
      6,
      RegExp('lasciala uscire'),
      RegExp('scrivi tutto|strappalo')
    ),
    (
      'Ansuz/dritta/come',
      3,
      RegExp('dire esattamente'),
      RegExp('richiesta precisa')
    ),
    (
      'Ansuz/dritta/come',
      4,
      RegExp('parola preparata'),
      RegExp('prepara tre frasi')
    ),
    (
      'Algiz/dritta/come',
      2,
      RegExp('fermezza gentile'),
      RegExp('questa frase')
    ),
    ('Algiz/dritta/come', 3, RegExp('circondandoti'), RegExp('persona')),
    (
      'Uruz/dritta/previsione',
      5,
      RegExp('ti rimette in piedi'),
      RegExp('hai retto')
    ),
    (
      'Nauthiz/dritta/previsione',
      5,
      RegExp('ciò che resta nelle tue mani'),
      RegExp('cinque cose')
    ),
    (
      'Perthro/dritta/previsione',
      1,
      RegExp('tavolo da gioco'),
      RegExp('amica|ridi')
    ),
    (
      'Jera/dritta/previsione',
      8,
      RegExp('cammino, non il traguardo'),
      RegExp('quattro fasi')
    ),
  ];

  test('1. L\'AZIONE RIPRENDE LA PAROLA DELLA SUA DIRETTA', () {
    final colpe = <String>[];
    for (final (gruppo, n, inD, inA) in coppie) {
      final d = leRisposteDirette['diretta']![gruppo]![n - 1].toLowerCase();
      final a = leRisposteDirette['azione']![gruppo]![n - 1].toLowerCase();
      if (!inD.hasMatch(d)) {
        colpe.add('$gruppo/$n: la diretta non dice piu\' «${inD.pattern}»: $d');
      } else if (!inA.hasMatch(a)) {
        colpe.add('$gruppo/$n: l\'azione non riprende «${inA.pattern}»: $a');
      }
    }
    print('ORDINE GA VOCE GA.06, RUNE: coppie corrette lette ${coppie.length}, '
        'azioni che non seguono la diretta ${colpe.length}');
    cardinaleMinimo(coppie.length, 15, cosa: 'coppie corrette lette');
    expect(colpe, isEmpty, reason: colpe.take(6).join('\n'));
  });

  test('2. LE FRASI CHE IL LETTORE HA CONTATO COME PRESUPPOSTI NON CI SONO',
      () {
    final vietate =
        RegExp(r'la sera prima di ogni passaggio importante|niente ricerche '
            r'notturne, niente messaggi per sapere|un no gentile ma netto|'
            r'Sotto la superficie gelata|un ponte largo che regge|'
            r'le tre persone che contano|alla prima richiesta che ti pesa|'
            r'un aiuto pratico, una parola chiara');
    var voci = 0;
    final colpe = <String>[];
    for (final campo in leRisposteDirette.entries) {
      for (final gruppo in campo.value.entries) {
        for (var i = 0; i < gruppo.value.length; i++) {
          voci++;
          if (vietate.hasMatch(gruppo.value[i])) {
            colpe.add('${campo.key}/${gruppo.key}/${i + 1}: '
                '${gruppo.value[i]}');
          }
        }
      }
    }
    print('ORDINE GA VOCE GA.06, RUNE: voci dirette e azioni lette $voci, con '
        'una frase contata dal lettore ${colpe.length}');
    cardinaleMinimo(voci, 3000, cosa: 'voci dirette e azioni lette');
    expect(colpe, isEmpty, reason: colpe.take(6).join('\n'));
  });
}
