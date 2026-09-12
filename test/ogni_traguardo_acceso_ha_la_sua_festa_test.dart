import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **OGNI TRAGUARDO ACCESO HA LA SUA FESTA.** Ordine CZ, voce 05.
///
/// **Il fatto del fondatore**: raggiunge traguardi e non vede nessuna festa.
/// Ha provato anche di proposito, entrando nel sentiero di un Maestro e
/// compiendo il gesto che mancava: Eos accreditati, perla accesa, **nessuna
/// festa**.
///
/// **MISURATO PRIMA DELLA CURA**: su un anno, 2080 traguardi accesi e **985
/// persi**, il quarantasette virgola quattro per cento, tutti per la scala
/// lineare. Dopo la cura: 2080 su 2080. La misura sta in
/// `test/quante_feste_si_perdono_test.dart`.
///
/// **QUESTA PROVA APPLICA LA REGOLA H**, nata in questo stesso ordine: una
/// guardia che dimostra una presenza deve dimostrare anche l'assenza altrove.
/// Qui la presenza e' la festa, e l'assenza e' **il tetto**: non basta che le
/// feste arrivino oggi, deve essere impossibile che un conto le trattenga
/// domani, con qualunque nome e in qualunque file.
///
/// **E' un lucchetto contro il TERZO ritorno.** Il tetto e' stato tolto il 23
/// agosto 2026 con l'ordine BD voce 08, ed e' tornato il 3 settembre con
/// l'ordine CQ voce 2.13, con un altro nome e in un altro file. Se torna una
/// terza volta, la terza prova qui sotto cade.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ({DiarioDelCammino diario, void Function(DateTime) sposta}) conOrologio(
      DateTime partenza) {
    var adesso = partenza;
    final diario = DiarioDelCammino(orologio: () => adesso);
    return (diario: diario, sposta: (DateTime q) => adesso = q);
  }

  test('UNO: un traguardo che non e\' il prossimo festeggia lo stesso',
      () async {
    SharedPreferences.setMockInitialValues(const {});
    final o = conOrologio(DateTime(2026, 6, 15, 10));
    await o.diario.carica();

    // Si cerca un traguardo soddisfatto che **non sia** il primo del suo
    // sentiero: e' esattamente il caso che il fondatore ha provato a mano, e
    // fino a ieri era quello che non festeggiava mai.
    for (final gesto in const [
      'carta_natale', 'viso', 'animale_guida', 'oroscopo', 'stesa', 'gettata',
      'alba', 'soffio', 'meditazione', 'tramonto', 'sogno', 'oracolo',
    ]) {
      await o.diario.segna(gesto);
    }
    final stato = o.diario.statoDelCammino(
        segno: Zodiac.leo,
        pezziDellIdentita: const {'carta_natale', 'viso', 'animale_guida'});
    final pronti = await o.diario.quelliCheSiAccendono(stato);
    expect(pronti.length, greaterThan(1),
        reason: 'si e\' acceso un traguardo solo: senza almeno due non esiste '
            'un "non primo" da provare, e questa prova non misurerebbe niente');

    Traguardo? nonIlPrimo;
    for (final t in pronti) {
      final suo = Sentiero.values.firstWhere(
          (s) => Sentieri.di(s).any((x) => x.id == t.id));
      if (o.diario.prossimoDi(suo)?.id != t.id) {
        nonIlPrimo = t;
        break;
      }
    }
    expect(nonIlPrimo, isNotNull,
        reason: 'fra i ${pronti.length} accesi nessuno e\' fuori dalla testa '
            'del suo sentiero: la premessa di questa prova non regge, e il '
            'caso del fondatore non e\' stato riprodotto');

    expect(o.diario.meritaLaScena(nonIlPrimo!), isTrue,
        reason: 'il traguardo ${nonIlPrimo.id} si e\' acceso e non merita la '
            'scena perche\' non e\' il prossimo del suo sentiero. E\' il '
            'difetto per intero: accensione sparsa e festa lineare non '
            'possono convivere');
  });

  test('DUE: cinque traguardi in un giorno fanno cinque feste, in coda o a '
      'schermo', () async {
    SharedPreferences.setMockInitialValues(const {});
    final o = conOrologio(DateTime(2026, 6, 15, 10));
    await o.diario.carica();

    var accesi = 0;
    var meritano = 0;
    // **UNA SETTIMANA, E IL NUMERO DELL'ORDINE RESTA QUELLO.**
    //
    // L'ordine chiede cinque traguardi. Sul dato vero, una prima giornata di
    // uso completo ne accende **quattro**, e due giornate ancora quattro:
    // nella revisione F il costo in giorni cresce lungo la posizione, quindi
    // il quinto arriva piu' avanti. **Non si abbassa il cinque dell'ordine**,
    // si allarga la finestra fino a dove quel numero esiste davvero. La
    // pretesa che conta, qui sotto, non cambia di una virgola.
    for (final giorno in const [15, 16, 17, 18, 19, 20, 21]) {
      o.sposta(DateTime(2026, 6, giorno, 10));
      for (final gesto in const [
        'carta_natale', 'viso', 'animale_guida', 'oroscopo', 'stesa',
        'gettata', 'alba', 'soffio', 'meditazione', 'tramonto', 'sogno',
        'oracolo', 'sinastria', 'angelo_custode', 'archetipo', 'due_volti',
        'bosco', 'sigillo', 'runa_girata', 'ascendente',
      ]) {
        await o.diario.segna(gesto);
        final stato = o.diario.statoDelCammino(
            segno: Zodiac.leo,
            pezziDellIdentita: const {'carta_natale', 'viso', 'animale_guida'});
        for (final t in await o.diario.quelliCheSiAccendono(stato)) {
          accesi++;
          if (o.diario.meritaLaScena(t)) meritano++;
          await o.diario.accendi(t.id);
          await o.diario.congeda(t.id);
        }
      }
    }
    expect(accesi, greaterThanOrEqualTo(5),
        reason: 'in una settimana si sono accesi solo $accesi traguardi: '
            'sotto cinque questa prova non puo\' misurare cio\' che dice');
    expect(meritano, accesi,
        reason: 'si sono accesi $accesi traguardi e solo $meritano hanno una '
            'festa: ${accesi - meritano} sono spariti senza scena e senza '
            'coda, che e\' esattamente cio\' che il fondatore non vede');
  });

  test('TRE, IL LUCCHETTO: nessun conto puo\' trattenere una festa', () {
    // **REGOLA H: si prova l'ASSENZA, non la presenza.** Le due prove qui
    // sopra dimostrano che oggi le feste arrivano. Questa dimostra che
    // **nessun conto esiste per trattenerle domani**, ed e' la meta' che alle
    // guardie di questo progetto e' mancata tre volte.
    //
    // Il tetto e' gia' tornato una volta sotto un altro nome e in un altro
    // file: il 23 agosto l'ordine BD voce 08 lo aveva tolto, il 3 settembre
    // l'ordine CQ voce 2.13 lo ha rimesso come `_scenePerSentieroOggi`. Per
    // questo qui non si cerca un nome, **si cercano tutti i modi di contare
    // le scene** nei due file dove la decisione vive.
    for (final percorso in const [
      'lib/core/sigilli/diario_del_cammino.dart',
      'lib/features/sigilli/regia_del_cammino.dart',
    ]) {
      final file = File(percorso);
      expect(file.existsSync(), isTrue,
          reason: 'il file $percorso non esiste piu\': questa prova starebbe '
              'guardando il nulla e sarebbe verde per cecita\'');
      final sorgente = file.readAsStringSync();
      expect(sorgente.length, greaterThan(1000),
          reason: '$percorso e\' vuoto o non e\' stato letto');

      // **I COMMENTI SI TOLGONO PRIMA DI CERCARE.** Nove volte in questo
      // progetto un'asserzione che cerca testo nel sorgente ha pescato il
      // commento che la spiega: qui sopra c'e' scritto
      // `_scenePerSentieroOggi`, e senza questa riga la prova accuserebbe se
      // stessa.
      final codice = sorgente
          .split('\n')
          .where((r) => !r.trimLeft().startsWith('//'))
          .where((r) => !r.trimLeft().startsWith('///'))
          .join('\n');

      for (final conto in const [
        '_scenePerSentieroOggi',
        'scenePerSentiero',
        'scenePerGiorno',
        'sceneDiOggi',
        'tettoDelleScene',
        'massimoDiScene',
      ]) {
        expect(codice.contains(conto), isFalse,
            reason: 'in $percorso e\' tornato un conto delle scene, "$conto". '
                'Il tetto e\' gia' 'tornato una volta con un altro nome: il '
                'fondatore dichiara di non aver mai approvato nessun tetto '
                'numerico, e la sola regola che ha dato e\' che non si vedano '
                'due feste di fila');
      }
    }
  });
}
