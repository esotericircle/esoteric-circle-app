// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/night_sky.dart';
import 'package:esoteric_circle/core/maestro/cio_che_arriva.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:esoteric_circle/core/maestro/il_respiro_di_oggi.dart';
import 'package:esoteric_circle/core/maestro/memoria_del_respiro.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/core/rituals/dream_rite_corpus.dart';
import 'package:esoteric_circle/core/rituals/relazione_lunare.dart';
import 'package:esoteric_circle/core/ricordi/arti_con_responso.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **IL SIGILLO DEL SOGNO DICE IL VERO. Ordine ES voce 18, 29 settembre
/// 2026.**
///
/// Il fondatore: "code deve controllare ancora tutto il funzionamento del
/// sigillo del sogno e le risposte!", con le sue domande: "trasparenza,
/// coerenza, verità e funzionalità", "c'è qualcosa di inventato?".
/// L'ispezione ha trovato quattordici punti; qui una prova per ognuno di
/// quelli curati nel codice.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues(const {}));

  test('la Runa del Tramonto non promette che il Sigillo la nominera\'', () {
    // Dalla ES.16 il Sigillo di Medora non parla di rune.
    expect(DailyElement.rune.cosaTiResta.contains('Sigillo'), isFalse,
        reason: DailyElement.rune.cosaTiResta);
  });

  test('niente "cielo notturno reale": reali sono la Luna e il segno', () {
    final testi = <String>[
      DailyElement.night.description,
      DreamRiteCorpus.daDoveNasce(
          DreamRiteCorpus.lunaDi(DateTime(2026, 9, 29, 23))),
      File('lib/features/rituals/dream_rite_card.dart').readAsStringSync(),
    ];
    final falsi = testi.where((t) => t.contains('cielo notturno reale'));
    print('ORDINE ES VOCE 18: testi che dicono "cielo notturno reale" '
        '${falsi.length} su ${testi.length}');
    expect(falsi, isEmpty);
  });

  /// **IL PUNTO NON SI RADDOPPIA.** Visto sul Realme il 30 settembre 2026 nel
  /// foglio "Da dove nasce questo dono": *"(Senti con curiosità e parole: le
  /// emozioni si fanno racconto.)."*. Padre il commit `c49de157` del 24
  /// luglio, il Rito del Sogno rifatto: la frase del segno lunare entrava fra
  /// parentesi col suo punto. Trenta notti, cioe' la Luna in tutti e dodici
  /// i segni, per ogni rapporto con la Luna di nascita.
  test('il foglio non scrive un punto dentro e fuori la parentesi', () {
    final rotti = <String>[];
    final segni = <Object>{};
    var fogli = 0;
    for (var k = 0; k < 30; k++) {
      final luna = DreamRiteCorpus.lunaDi(DateTime(2026, 10, 1 + k, 23));
      segni.add(luna.sign);
      for (final t in [
        DreamRiteCorpus.daDoveNasce(luna),
        for (final r in RelazioneLunare.values)
          DreamRiteCorpus.daDoveNasceCon(luna, r),
      ]) {
        fogli++;
        if (RegExp(r'[.!?]\)').hasMatch(t)) rotti.add(t);
      }
    }
    print('IL SIGILLO DEL SOGNO: fogli col punto dentro la parentesi '
        '${rotti.length} su $fogli, segni della Luna ${segni.length}');
    expect(segni.length, 12);
    expect(rotti, isEmpty, reason: rotti.take(2).join('\n'));
  });

  test('il foglio nomina l\'aspetto con l\'articolo giusto e dice la sorgente',
      () {
    final luna = DreamRiteCorpus.lunaDi(DateTime(2026, 9, 29, 23));
    final rotti = <String>[];
    for (final r in RelazioneLunare.values) {
      final t = DreamRiteCorpus.daDoveNasceCon(luna, r);
      for (final errore in const [
        'un congiunzione',
        'un quadratura',
        'un opposizione',
        'un nessun',
      ]) {
        if (t.contains(errore)) rotti.add('${r.name}: "$errore"');
      }
      if (!t.contains('Luna del tuo giorno di nascita')) {
        rotti.add('${r.name}: non dice che le righe vengono dalla Luna di '
            'nascita');
      }
    }
    print('ORDINE ES VOCE 18: fogli con l\'aspetto sgrammaticato o senza la '
        'sorgente ${rotti.length} su ${RelazioneLunare.values.length}');
    expect(rotti, isEmpty, reason: rotti.join('\n'));
    expect(RelazioneLunare.opposizione.riga.contains('esattamente'), isFalse,
        reason: 'l\'aspetto si calcola per segno intero, non e\' esatto');
  });

  test('la riga della figura conta le notti che restano davvero', () {
    var righe = 0;
    final sbagliate = <String>[];
    for (var h = 0; h < 24 * 60; h += 7) {
      final quando = DateTime(2026, 9, 1, 23).add(Duration(hours: h));
      final riga = DreamRiteCorpus.perchePosaLaStessaFigura(quando);
      if (riga == null) continue;
      righe++;
      // Le notti in cui la Luna resta nel segno, dopo stanotte.
      final segno = NightSky.moonSign(quando);
      var restano = 0;
      while (
          NightSky.moonSign(quando.add(Duration(days: restano + 1))) == segno) {
        restano++;
      }
      final detto = riga.contains('ancora una notte')
          ? 1
          : int.parse(
              RegExp(r'ancora (\d+) notti').firstMatch(riga)!.group(1)!);
      if (detto != restano) sbagliate.add('$quando: detto $detto, $restano');
    }
    cardinaleMinimo(righe, 50, cosa: 'righe della figura');
    print('ORDINE ES VOCE 18: righe della figura con le notti sbagliate '
        '${sbagliate.length} su $righe');
    expect(sbagliate, isEmpty, reason: sbagliate.take(5).join('\n'));
  });

  test('il nome del Dono e\' uno solo: Sigillo del Sogno', () {
    final arte = ArtiConResponso.di('sogno')!;
    final card =
        File('lib/features/rituals/dream_rite_card.dart').readAsStringSync();
    final scena =
        File('lib/features/rituals/dream_rite_screen.dart').readAsStringSync();
    final vecchi = [
      if (arte.titolo != 'Sigillo del Sogno') 'ricordi: ${arte.titolo}',
      if (card.contains('RITO DEL SOGNO')) 'card: RITO DEL SOGNO',
      if (scena.contains('Rito della Notte')) 'custodia: Rito della Notte',
    ];
    print('ORDINE ES VOCE 18: nomi vecchi del Dono ${vecchi.length}');
    expect(vecchi, isEmpty, reason: vecchi.join('\n'));
  });

  test('fra mezzanotte e le cinque la notte e\' ancora quella di ieri',
      () async {
    final m = MemoriaDelRespiro();
    await m.segna(SessioneDiRespiro(
      quando: DateTime(2026, 9, 10, 21),
      centro: 3,
      durata: const Duration(minutes: 5),
      compiuta: true,
      guidato: false,
    ));
    final prima = IlRespiroDiOggi.laRiga(m, DateTime(2026, 9, 10, 23, 50));
    final dopo = IlRespiroDiOggi.laRiga(m, DateTime(2026, 9, 11, 0, 40));
    expect(prima, isNotNull);
    expect(dopo, prima,
        reason: 'a mezzanotte e quaranta il respiro della sera sparisce');
    expect(prima, contains('Aura'),
        reason: 'la riga viene dalla meditazione di Aura e non lo dice');
    final saluto = DreamRiteCorpus.saluto(DateTime(2026, 9, 10, 23, 50),
        nascita: DateTime(1990, 3, 15));
    final saluto2 = DreamRiteCorpus.saluto(DateTime(2026, 9, 11, 0, 40),
        nascita: DateTime(1990, 3, 15));
    // La Luna si muove di mezzo grado in cinquanta minuti: il saluto e' lo
    // stesso se non cambia segno o fase; qui si guarda la prima frase, che
    // viene dal seme della notte.
    expect(saluto2.split('.').first, saluto.split('.').first,
        reason: 'il saluto cambia a mezzanotte sotto gli occhi di chi legge');
  });

  test('il Maestro non riceve promesse di funzioni che non esistono', () {
    // Tutti i "cosa apre" del corpus del Cammino, letti dai sorgenti: nessuno
    // arriva al Maestro (99 su 165 nominano funzioni che non esistono, e
    // nessun traguardo sblocca niente: docs/collaudo/ES/cosa_apre.txt).
    final testi = Directory('lib/core/sigilli')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.contains('sentiero_'))
        .expand((f) => RegExp(r"cosaApre:\s*'(.+?)',")
            .allMatches(f.readAsStringSync())
            .map((m) => m.group(1)!))
        .toList();
    cardinaleMinimo(testi.length, 165, cosa: 'cosaApre del Cammino');
    final arrivati = <String>[];
    for (final p in testi) {
      final b = CioCheArriva.blocco(prossimoTraguardo: 'Un passo', cosaApre: p);
      final pezzo = p.substring(1, p.length < 20 ? p.length : 20);
      if (b.contains(pezzo)) arrivati.add(p);
    }
    print('ORDINE ES VOCE 18: "cosa apre" che arrivano al Maestro '
        '${arrivati.length} su ${testi.length}');
    expect(arrivati, isEmpty, reason: arrivati.take(5).join('\n'));
    // Il nome del passo arriva.
    expect(CioCheArriva.blocco(prossimoTraguardo: 'Un passo', cosaApre: 'x'),
        contains('"Un passo"'));
  });

  test('la chiusura dei Maestri non chiede di nominare un arcano mai uscito',
      () {
    // Dopo il Sigillo Medora chiudeva con "l'arcano del Carro" e "l'Arcano
    // della Giustizia", che nessuno aveva estratto: la regola della chiusura
    // le chiedeva il nome di un arcano. In tre giri prima della cura, un
    // arcano inventato per giro; in due giri dopo, zero su sedici risposte
    // (docs/collaudo/ES/sigillo_risposte_*.md).
    for (final m in Maestro.values) {
      final i = MaestroPersona.systemInstruction(
        maestro: m,
        profile: UserProfile(),
        memory: MaestroMemory.empty,
        natal: NatalContext.none,
      );
      expect(
          i.contains('oppure il nome proprio di una runa, di un segno o di '
              'un arcano'),
          isFalse,
          reason: m.name);
      expect(
          i.contains('non nominarne mai uno che la persona non ha '
              'estratto'),
          isTrue,
          reason: m.name);
    }
  });
}
