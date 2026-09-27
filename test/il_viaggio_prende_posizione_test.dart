// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/rituals/guide_animal_derivation.dart';
import 'package:esoteric_circle/core/tarot/la_lettura_dal_modello.dart';
import 'package:esoteric_circle/core/viaggio/la_scena_dal_modello.dart';
import 'package:esoteric_circle/core/viaggio/le_guardie_del_responso.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL VIAGGIO PRENDE POSIZIONE, E L'AZIONE NON E' SEMPRE IL FOGLIO.**
/// Ordine ER voci 02 e 15, 27 settembre 2026.
///
/// ER.02, parole del fondatore: *"Le persone vogliono risposte dirette,
/// Senza tanti giochi di parole e cercano consigli e guide anche su domande
/// generiche."* ER.15: quattro azioni su sei chiedevano di scrivere su un
/// foglio, perche' la regola del fuoco ne portava cinque esempi.
///
/// **La grandezza misurata qui e' cio' che il modello riceve**: la regola che
/// impediva di rispondere non c'e' piu', c'e' quella che chiede la posizione
/// nella prima frase; l'esempio del foglio e' uscito, il divieto del fuoco e'
/// rimasto; le azioni gia' date alla persona arrivano nella richiesta e la
/// lettura scarta quella che ne somiglia una. **Il merito delle risposte non
/// si misura qui**: lo misura il banco `tool/collaudo_viaggio_er.dart` col
/// modello vero, e la lettura alla cieca.
void main() {
  final animale = GuideAnimalDerivation.forSign(Zodiac.cancer);

  test('ER.02 ed ER.15: l\'istruzione chiede la posizione, senza il foglio',
      () {
    final istruzione = LaScenaDalModello.istruzione(animale);
    final vecchia = istruzione.contains('Non dire se la cosa accadrà');
    final posizione =
        istruzione.contains('LA PRIMA FRASE DELLA RISPOSTA PRENDE POSIZIONE');
    final righeDelFoglio = RegExp(
            r'strappare il foglio|sotto una pietra|gettarlo nell|chiuderlo in un cassetto')
        .allMatches(istruzione)
        .length;
    final esempiDiAzioni = istruzione
        .split('\n')
        .firstWhere((r) => r.startsWith('Azioni: '), orElse: () => '');
    print('ORDINE ER VOCI 2 E 15: regola che vietava di rispondere '
        '${vecchia ? 1 : 0}, regola della posizione ${posizione ? 1 : 0}, '
        'esempi del foglio $righeDelFoglio, esempi di azioni "$esempiDiAzioni"');
    expect(vecchia, isFalse,
        reason: 'la regola "Non dire se la cosa accadrà" e\' ancora lì');
    expect(posizione, isTrue, reason: 'nessuna regola chiede la posizione');
    expect(righeDelFoglio, 0, reason: 'l\'esempio del foglio e\' tornato');
    expect(istruzione, contains('NIENTE FUOCO'),
        reason: 'il divieto del fuoco deve restare');
    expect(esempiDiAzioni, isNotEmpty);
    expect(esempiDiAzioni.toLowerCase(), isNot(contains('scriv')),
        reason: 'fra gli esempi di azioni ce n\'e\' uno che scrive');
    // **LA POSIZIONE SI SCEGLIE NELLO SCHEMA**, prima della risposta.
    expect(
        File('lib/core/viaggio/la_scena_dal_modello.dart').readAsStringSync(),
        contains("'posizione': Schema.enumString(enumValues: posizioni)"));
    // **E SENZA GENERE SI SCRIVE COME NELLA STESA**, dal banco della sera:
    // "non sei sola" a chi non ha detto il suo genere mandava la risposta
    // in riserva.
    expect(
        LaScenaDalModello.istruzione(animale, forma: CourtesyForm.unknown),
        contains(LaLetturaDellaStesa.senzaGenere));
    expect(
        LaScenaDalModello.istruzione(animale, forma: CourtesyForm.feminine),
        isNot(contains(LaLetturaDellaStesa.senzaGenere)));
  });

  test('ER.15: le azioni gia\' date arrivano al modello e non tornano', () {
    const gia = [
      'Stasera scrivi su un foglio che cosa ti manca. Poi strappalo.',
      'Domani mattina accarezza il tuo cane per cinque minuti.',
    ];
    final richiesta = LaScenaDalModello.richiesta(CioCheSiSa(
      domanda: 'Mi trasferisco a Berlino?',
      tema: null,
      animale: animale,
      natale: const NatalContext(),
      memoria: '',
      ultimeScene: const [],
      azioniGiaDate: gia,
    ));
    expect(richiesta, contains('Azioni già date a questa persona'));
    for (final g in gia) {
      expect(richiesta, contains(g));
    }
    final simile = LeGuardieDelResponso.leggi(
      {'azione': 'Stasera scrivi su un foglio che cosa ti manca. Poi buttalo.'},
      domanda: 'Mi trasferisco a Berlino?',
      forma: CourtesyForm.unknown,
      azioniGiaDate: gia,
    );
    final nuova = LeGuardieDelResponso.leggi(
      {
        'azione': 'Entro sabato chiedi a un collega che vive a Berlino com\'è '
            'il suo primo mese.'
      },
      domanda: 'Mi trasferisco a Berlino?',
      forma: CourtesyForm.unknown,
      azioniGiaDate: gia,
    );
    print('ORDINE ER VOCE 15: azione simile scartata per '
        '${simile.scarti.map((r) => r.motivo.name).toList()}; azione nuova '
        '"${nuova.azione}"');
    expect(simile.azione, isNull);
    expect(simile.scarti.single.motivo, MotivoDelloScarto.azioneRipetuta);
    expect(nuova.azione, isNotNull);
    // **LAPIDE, dal banco del 27 settembre sera.** Qui la prova voleva che
    // una scrittura passasse quando fra le ultime tre azioni non ce n'era
    // un'altra: fra venti persone diverse la regola non scattava mai, e il
    // modello chiedeva di scrivere tre e otto volte su venti. Adesso la
    // scrittura non passa mai, con o senza scritture prima, e la seconda
    // chiamata sa perche'.
    final ancoraIlFoglio = LeGuardieDelResponso.leggi(
      {'azione': 'Entro sabato scrivi su un quaderno il nome della tua via.'},
      domanda: 'Mi trasferisco a Berlino?',
      forma: CourtesyForm.unknown,
      azioniGiaDate: gia,
    );
    final senzaFoglioPrima = LeGuardieDelResponso.leggi(
      {'azione': 'Entro sabato scrivi su un quaderno il nome della tua via.'},
      domanda: 'Mi trasferisco a Berlino?',
      forma: CourtesyForm.unknown,
    );
    print('ORDINE ER VOCE 15: scrittura dopo scrittura '
        '${ancoraIlFoglio.scarti.map((r) => r.motivo.name).toList()}, '
        'scrittura senza azioni prima '
        '${senzaFoglioPrima.scarti.map((r) => r.motivo.name).toList()}');
    expect(ancoraIlFoglio.azione, isNull);
    expect(senzaFoglioPrima.azione, isNull);
    expect(senzaFoglioPrima.scarti.single.motivo,
        MotivoDelloScarto.chiedeDiScrivere);
    expect(
        LeGuardieDelResponso.perIlModello(MotivoDelloScarto.chiedeDiScrivere),
        contains('non su un foglio'));
    // Scrivere a una persona e' un messaggio, non un foglio: passa.
    for (final messaggio in [
      'Stasera scrivi a tua sorella una riga, senza domande.',
      'Domani mattina scrivigli un messaggio corto.',
    ]) {
      expect(LeGuardieDelResponso.chiedeDiScrivereSuCarta(messaggio), isFalse,
          reason: messaggio);
    }
    for (final carta in [
      'Stasera scrivi tre cose che ti mancano.',
      'Entro domani fai la lista dei pro e dei contro.',
      'Domani scrivi a tua madre una lettera su un foglio e non spedirla.',
    ]) {
      expect(LeGuardieDelResponso.chiedeDiScrivereSuCarta(carta), isTrue,
          reason: carta);
    }
  });

  test(
      'ER.02: le guardie lasciano passare la posizione, e fermano ancora lo '
      'stato dell\'altra persona e il futuro certo', () {
    const fratello = 'Mio fratello non mi parla da mesi, lo chiamo io?';
    const berlino = 'Mi trasferisco a Berlino per lavoro?';
    const collega = 'Cosa pensa di me la mia collega?';
    MotivoDelloScarto? risposta(String t, String d) =>
        LeGuardieDelResponso.dellaRisposta(t,
            domanda: d, forma: CourtesyForm.unknown);
    // Passano: dal banco del 27 settembre, scartate prima della cura.
    final passano = {
      'I segni del viaggio dicono di fare il primo passo. Puoi chiamare tuo '
          'fratello. Non aspettare che sia lui a cercarti.': fratello,
      'I segni del viaggio dicono di no, non è il momento di cambiare città. '
          'Puoi aspettare la primavera per decidere su Berlino.': berlino,
      // Dal banco della sera: l'imperativo di chi legge in testa, la
      // decisione dell'altro che non tocca a chi legge, cio' che chi legge
      // non puo' sapere. La prima e' il gesto che l'istruzione da' per
      // esempio.
      'Chiama tuo fratello questa settimana. Puoi scegliere di non attendere. '
          'La decisione di tuo fratello non è tua da prendere.': fratello,
      'Chiama tuo fratello questa settimana. Puoi scegliere di non attendere '
          'oltre. Non puoi sapere che cosa farà lui.': fratello,
      'Chiama tuo fratello questa settimana. Puoi fare il primo passo. La '
          'scelta di riavvicinarti dipende solo da te.': fratello,
      'Chiedi alla tua collega un caffè domani. Non puoi sapere cosa pensa '
          'di te senza parlarle.': collega,
      'Chiedi alla tua collega un caffè domani. Non ti serve sapere cosa '
          'pensa di te prima.': collega,
      'Chiedi alla tua collega un caffè domani. Non la forzare se dice di '
          'no.': collega,
    };
    // Restano fuori: lo stato dell'altro detto dai segni, il futuro certo.
    final fuori = {
      'I segni del viaggio mostrano che tuo fratello ha bisogno di tempo.':
          fratello,
      'I segni del viaggio dicono che il trasferimento a Berlino ti porterà '
          'fortuna.': berlino,
      'Non è il momento di pensare a Berlino.': berlino,
      // L'imperativo non copre cio' che viene dopo: l'altro che vuole,
      // pensa o stima resta fuori anche dietro "Chiedi".
      'Chiama tuo fratello. Tuo fratello ti vuole bene.': fratello,
      'Chiedi alla collega. Lei ti stima.': collega,
      'Non puoi sapere cosa pensa la tua collega. Non ti serve saperlo.':
          collega,
    };
    final esiti = <String>[];
    for (final e in passano.entries) {
      final m = risposta(e.key, e.value);
      esiti.add('passa: ${m?.name ?? 'ammessa'}');
      expect(m, isNull, reason: '"${e.key}" e\' scartata per ${m?.name}');
    }
    for (final e in fuori.entries) {
      final m = risposta(e.key, e.value);
      esiti.add('fuori: ${m?.name ?? 'AMMESSA'}');
      expect(m, isNotNull, reason: '"${e.key}" non e\' scartata');
    }
    print('ORDINE ER VOCE 2: $esiti');
  });

  test('ER.15: la schermata passa le azioni del Diario', () {
    final sorgente = File(
            'lib/features/maestri/caligo/viaggio/viaggio_dello_sciamano_screen.dart')
        .readAsStringSync();
    expect(
        sorgente, contains('azioniGiaDate: LaScenaDalModello.azioniDalDiario('),
        reason: 'la schermata non passa al modello le azioni gia\' date');
  });
}
