import 'dart:io';

import 'package:esoteric_circle/core/chat/il_blocco_di_cortesia.dart';
import 'package:esoteric_circle/core/l10n/la_lingua_del_modello.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/magic/il_sigillo_dal_modello.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/il_segno_dell_animale.dart';
import 'package:esoteric_circle/core/viaggio/la_scena_dal_modello.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:esoteric_circle/services/ricordi/penna_vera_del_mese.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// **OGNI PROMPT DI PROSA DICHIARA LA FORMA.** Ordine DL voce 04, 14 settembre
/// 2026.
///
/// **Il fatto.** Il blocco di cortesia esisteva in un punto solo, e lo
/// ricevevano tre prompt su sei fra quelli che scrivono per la persona. La
/// lettura del mese imponeva il femminile a chiunque, con parole scritte: *"dove
/// e' tornata spesso"*, *"parla a lei in seconda persona"*. Il segno
/// dell'animale chiedeva il neutro a tutti, anche a chi aveva scelto.
///
/// **Le due prove.** La prima chiama ogni prompt di prosa con le tre forme e
/// pretende il blocco con la riga giusta, e nessuna delle altre due. La seconda
/// conta i posti di `lib` che mandano un'istruzione di sistema al modello:
/// sono dichiarati tutti qui sotto, e un prompt nuovo che nascesse senza
/// passare da questa prova la fa cadere.
void main() {
  const lupo = GuideAnimal(
      name: 'Lupo', summary: 's', meaning: 'm', stem: 'ani_lupo_v1');

  /// I prompt che scrivono testo letto dalla persona, per nome.
  final prosa = <String, String Function(CourtesyForm)>{
    'la chat dei Maestri': (f) => MaestroPersona.systemInstruction(
        maestro: Maestro.medora,
        profile: UserProfile(displayName: 'Sofia', courtesyForm: f),
        memory: MaestroMemory.empty),
    'il consulto': (f) => MaestroPersona.consultInstruction(
        maestro: Maestro.aura,
        profile: UserProfile(courtesyForm: f),
        memory: MaestroMemory.empty),
    'il presagio delle rune': (f) => MaestroPersona.presagioInstruction(
        profile: UserProfile(courtesyForm: f), memory: MaestroMemory.empty),
    'la sintesi comparativa': (f) =>
        MaestroPersona.synthesisInstruction(forma: f),
    'il distillato di memoria': (f) => MaestroPersona.distillInstruction(
        Maestro.caligo, UserProfile(courtesyForm: f)),
    'la lettura del mese': (f) =>
        PennaVeraDelMese.istruzione(Maestro.medora, forma: f),
    'il segno dell\'animale': (f) => GestiDelSegno.istruzione(lupo, forma: f),
    'la scena, il titolo, la risposta e il gesto del Viaggio': (f) =>
        LaScenaDalModello.istruzione(lupo, forma: f),
    // **I TRE TESTI DEL SIGILLO**, ordine DO voci 09 e 10.
    'il titolo e il responso del Sigillo': (f) =>
        IlSigilloDalModello.istruzioneDeiTesti(f),
    'il testo del compimento del Sigillo': (f) =>
        IlSigilloDalModello.istruzioneDelCompimento(f),
    'la riformulazione del Sigillo': (f) =>
        IlSigilloDalModello.istruzioneDellaRiformulazione(f),
  };

  test('ogni prompt di prosa porta il blocco con la forma scelta', () {
    final colpe = <String>[];
    const forme = [
      CourtesyForm.masculine,
      CourtesyForm.feminine,
      CourtesyForm.neutral,
    ];
    for (final voce in prosa.entries) {
      for (final f in forme) {
        final testo = voce.value(f);
        if (!testo.contains(IlBloccoDiCortesia.intestazione)) {
          colpe.add('${voce.key} ($f): senza blocco di cortesia');
          continue;
        }
        if (!testo.contains(IlBloccoDiCortesia.riga(f))) {
          colpe.add('${voce.key} ($f): il blocco non dice la forma scelta');
        }
        for (final altra in forme.where((a) => a != f)) {
          if (testo.contains(IlBloccoDiCortesia.riga(altra))) {
            colpe.add('${voce.key} ($f): dice anche la forma $altra');
          }
        }
        // **DEL GENERE SI PARLA SOLO NEL BLOCCO.** La lettura del mese
        // imponeva il femminile con una frase sua, fuori da ogni blocco:
        // un'istruzione di genere scritta altrove contraddice la forma
        // scelta, e nessuna prova sulle frasi di ieri la vede.
        //
        // **L'UNICA ESENZIONE, E PERCHE' NON E' UNA SOGLIA ABBASSATA.**
        // Ordine EE voce 10, 23 settembre 2026: la regola sul genere dei
        // numeri delle carte nomina il maschile, e questa guardia l'ha presa
        // il 22 settembre come se fosse un'istruzione sulla persona. **Non lo
        // e': parla delle carte, non di chi legge.** La grandezza giusta non
        // e' "quante volte compare la parola maschile", e' "si dice alla
        // persona di che genere e', fuori dal blocco che lo decide". Quindi
        // si toglie quella costante per intero, come si toglie la riga del
        // blocco, **e l'esenzione ha il suo cancello qui sotto**: se un
        // giorno qualcuno ci infilasse dentro un'istruzione sulla persona,
        // questa guardia smetterebbe di vederla, ed e' precisamente il modo
        // in cui un'esenzione diventa un buco.
        final fuori = testo
            .replaceAll(IlBloccoDiCortesia.riga(f), '')
            .replaceAll(LaLinguaDelModello.ilGenereDelleCarte, '');
        final genere = RegExp(r'(femminil|maschil)', caseSensitive: false)
            .firstMatch(fuori);
        if (genere != null) {
          colpe.add('${voce.key} ($f): parla di genere fuori dal blocco, '
              '"${fuori.substring((genere.start - 40).clamp(0, fuori.length), (genere.end + 20).clamp(0, fuori.length))}"');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE DL VOCE 04: prompt di prosa guardati ${prosa.length}, per '
        'tre forme ciascuno; colpe ${colpe.length}');
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  /// **IL CANCELLO DELL'UNICA ESENZIONE.** Ordine EE voce 10.
  ///
  /// La prova qui sopra toglie `ilGenereDelleCarte` prima di cercare il
  /// genere, perche' quella regola parla delle carte. **Un'esenzione senza
  /// cancello e' un buco**: qui si pretende che quella costante resti cio'
  /// che dice di essere, cioe' che parli di carte e non di chi legge.
  test('l\'esenzione sul genere delle carte parla di carte, non di chi legge',
      () {
    final regola = LaLinguaDelModello.ilGenereDelleCarte.toLowerCase();
    expect(regola, contains('carte'),
        reason: 'se non parla piu\' di carte non e\' piu\' l\'esenzione che '
            'la prova qui sopra si sente autorizzata a togliere');
    // Le parole con cui un'istruzione si rivolge alla persona. Se compaiono
    // qui dentro, la regola non sta piu' parlando di un mazzo.
    const allaPersona = [
      'la persona',
      'l\'utente',
      'chi legge',
      'chi ti parla',
      'ti rivolgi',
      'rivolgiti',
      'parla di te',
      'di lei',
      'di lui',
    ];
    final trovate = [
      for (final p in allaPersona)
        if (regola.contains(p)) p
    ];
    // ignore: avoid_print
    print('ORDINE EE VOCE 10: parole rivolte alla persona nella regola del '
        'genere delle carte ${trovate.length}');
    expect(trovate, isEmpty,
        reason: 'la regola sul genere delle carte si rivolge alla persona '
            '($trovate): cosi\' l\'esenzione della prova qui sopra nasconde '
            'proprio il difetto che quella prova esiste per prendere');
  });

  test('la lettura del mese non impone piu\' il femminile', () {
    final testo = PennaVeraDelMese.istruzione(Maestro.medora,
        forma: CourtesyForm.masculine);
    for (final vietata in const ['è tornata spesso', 'Parla a lei']) {
      expect(testo.contains(vietata), isFalse,
          reason: 'la lettura del mese dice ancora "$vietata" a chi ha '
              'scelto il maschile');
    }
  });

  /// **I POSTI DI `lib` CHE MANDANO UN'ISTRUZIONE AL MODELLO**, e perche'.
  /// Chi ne aggiunge uno lo dichiara qui: se scrive prosa, entra anche in
  /// [prosa] sopra.
  const mandanti = <String, String>{
    'lib/services/ai/firebase_maestro_ai_provider.dart':
        'chat, consulto, sintesi, distillato e presagio: tutti in prosa',
    'lib/services/ricordi/penna_vera_del_mese.dart': 'la lettura del mese',
    'lib/core/viaggio/il_segno_dell_animale.dart': 'la riga del segno',
    'lib/core/viaggio/la_scena_dal_modello.dart':
        'la scena del Viaggio col titolo, la risposta e il gesto',
    'lib/core/magic/il_sigillo_dal_modello.dart':
        'il titolo, il responso, il compimento e la riformulazione del '
            'Sigillo: tutti in prosa',
    // **FUORI, E DICHIARATO**: il classificatore della domanda restituisce
    // un identificatore di tema e l'oggetto della domanda preso dalle sue
    // parole. Non scrive una frase per la persona.
    'lib/core/viaggio/la_domanda_capita.dart':
        'il tema della domanda: un identificatore, non prosa',
    // **FUORI, E DICHIARATO**, ordine DZ voce 04: il titolo di una
    // conversazione nomina il tema in poche parole e non si rivolge alla
    // persona, quindi non ha una forma di cortesia da rispettare.
    'lib/services/ai/titoli_da_gemini.dart':
        'il titolo di una conversazione: un nome del tema, non prosa',
  };

  test('nessun prompt nasce senza essere dichiarato', () {
    final trovati = <String>{};
    for (final f in sorgentiDiLib()) {
      final percorso = f.path.replaceAll(r'\', '/');
      if (f.readAsStringSync().contains('Content.system(')) {
        trovati.add(percorso);
      }
    }
    expect(trovati.difference(mandanti.keys.toSet()), isEmpty,
        reason: 'un prompt nuovo manda istruzioni al modello e non e\' '
            'dichiarato: se scrive per la persona deve portare il blocco di '
            'cortesia');
    for (final dichiarato in mandanti.keys) {
      expect(File(dichiarato).existsSync(), isTrue,
          reason:
              'la prova dichiara un file che non c\'e\' piu\': $dichiarato');
    }
  });
}
