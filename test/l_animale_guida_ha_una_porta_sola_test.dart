/// **L'ANIMALE GUIDA HA UNA PORTA SOLA.** Ordine DG voce 01,
/// 11 settembre 2026. Riscritta per intero dall'ordine FZ voce 01 e 02,
/// 17 ottobre 2026.
///
/// **PERCHE' LA VECCHIA FORMA DI QUESTA GUARDIA E' DIVENTATA FALSA.** Fino
/// all'ordine FZ la porta unica era `GuideAnimalDerivation.forSign`: il
/// segno decideva per sempre, e una "seconda porta" era qualunque codice che
/// provasse a scegliere l'animale dalle scelte della persona (i nomi vietati
/// erano `seguitoDaLeQuattroScelte`, `treOmbre`, `PittoreDellAnimale`).
///
/// **IL FONDATORE HA ROVESCIATO QUELLA REGOLA IL 17 OTTOBRE 2026, PER UNA
/// RAGIONE DIVERSA DA QUELLA DI DC.** *"La 2."*: l'animale si rivela nel
/// viaggio, con la regola delle quattro apparizioni di Harner, e le tre
/// ombre proposte a ogni discesa nascono da quali ombre la persona ha gia'
/// seguito, non dal cielo. `treOmbre*` non e' piu' una seconda porta: e' IL
/// meccanismo della porta unica nuova. Tenere la vecchia guardia com'era
/// l'avrebbe fatta cadere sul proprio lavoro giusto, e una guardia che
/// accusa chi la rispetta insegna a ignorarla.
///
/// **LA PORTA UNICA ADESSO E' `AnimaleDiPotere`** (e, sotto di lei, le
/// funzioni pure di `LeOmbreCheRitornano`): nessun altro file deve calcolare
/// "chi e' il suo animale" per conto proprio. `GuideAnimalDerivation.forSign`
/// non decide piu' l'animale di nessuno: resta viva solo dentro
/// `l_animale_di_potere.dart`, per la migrazione una tantum di chi aveva
/// gia' concluso col vecchio sistema.
///
/// **VISTA ROSSA DAVVERO, non per deduzione**: eseguendo questa stessa
/// guardia PRIMA di scrivere `AnimaleDiPotere` e la nuova regola, le due
/// prove vecchie ("chi deriva l'animale dal segno sa che puo' doverlo
/// tacere" e "nessun file apre una seconda porta") sono cadute esattamente
/// sulle righe che questo ordine ha scritto: la prima perche' il cardinale
/// minimo di cinque derivazioni dal segno si e' svuotato a una sola (la
/// migrazione), la seconda perche' `treOmbreProposte` conteneva la
/// sottostringa vietata `treOmbre`. Il rosso e' la controprova che la
/// vecchia guardia misurava davvero qualcosa, non un rosso simulato.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/le_ombre_che_ritornano.dart';

import 'sorgenti_di_lib.dart';

void main() {
  test(
      'MILLE ESECUZIONI, a parita di diario, la porta nuova da sempre lo '
      'stesso animale', () {
    // **DETERMINISMO DELLA PORTA NUOVA**, lo stesso spirito della prova
    // "mille esecuzioni" di prima, ma sulla funzione pura che decide oggi:
    // `LeOmbreCheRitornano.trovaIlRiconosciuto`. Nessun Diario, nessun
    // SharedPreferences: solo liste di nomi, come l'ordine FZ.01 chiede per
    // la prova a cento persone.
    const scelte = [
      'Lupo',
      'Aquila',
      'Lupo',
      'Orso',
      'Lupo',
      'Aquila',
      'Lupo',
    ];
    final primo = LeOmbreCheRitornano.trovaIlRiconosciuto(scelte);
    expect(primo, 'Lupo');
    var giri = 0;
    for (var i = 0; i < 1000; i++) {
      expect(LeOmbreCheRitornano.trovaIlRiconosciuto(scelte), primo,
          reason: 'la stessa sequenza di scelte ha dato due animali diversi');
      giri++;
    }
    // ignore: avoid_print
    print('ORDINE FZ VOCE 01: $giri esecuzioni sulla stessa sequenza, '
        'sempre lo stesso animale');
    expect(giri, 1000);
  });

  test(
      'IL CASO DI RIFERIMENTO: la stessa ombra seguita quattro volte, non '
      'una sola in meno', () {
    // **IL DATO E' NOMINATO E NON DEDOTTO.** L'ordine: "l'animale e'
    // riconosciuto quando la stessa ombra e' stata seguita quattro volte,
    // non per forza di fila". Qui si tiene ferma la soglia: se qualcuno la
    // abbassasse a tre, il riconoscimento arriverebbe un passo prima senza
    // che nessuno se ne accorga leggendo solo il codice che lo usa.
    for (final a in AnimalCatalog.animals) {
      for (var volte = 0; volte < 4; volte++) {
        expect(
            LeOmbreCheRitornano.trovaIlRiconosciuto(List.filled(volte, a.name)),
            isNull,
            reason: 'a $volte volte "${a.name}" non deve essere ancora '
                'riconosciuto');
      }
      expect(LeOmbreCheRitornano.trovaIlRiconosciuto(List.filled(4, a.name)),
          a.name);
    }
  });

  test(
      'NESSUN FILE DI lib DERIVA PIU\' L\'ANIMALE DAL SEGNO, tranne la '
      'migrazione', () {
    // **LA GRANDEZZA MISURATA E' QUASI L'ASSENZA**, ed e' il motivo per cui
    // questa e' una guardia e non una prova: se qualcuno rimettesse un
    // punto che deriva l'animale di una persona dal suo segno solare, il
    // resto della suite resterebbe verde.
    //
    // **UNA SOLA ESENZIONE, dichiarata per nome**: `l_animale_di_potere.dart`
    // e' il ponte di migrazione di FZ.02, l'unico punto in cui la vecchia
    // porta e' ancora legittima.
    const dovLaMigrazioneVive = 'lib/core/viaggio/l_animale_di_potere.dart';
    final colpevoli = <String>[];
    var guardati = 0;
    for (final f in sorgentiDiLib()) {
      guardati++;
      final p = f.path.replaceAll(Platform.pathSeparator, '/');
      final righe = f.readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        final r = righe[i];
        final st = r.trimLeft();
        // I commenti possono nominarla: e' li' che sta scritto perche' non
        // decide piu' niente.
        if (st.startsWith('//') || st.startsWith('///')) continue;
        if (r.contains('GuideAnimalDerivation.forSign') &&
            p != dovLaMigrazioneVive) {
          colpevoli.add('$p riga ${i + 1}: $r');
        }
      }
    }
    expect(guardati, greaterThan(500),
        reason: 'i file di lib trovati sono troppo pochi');
    // ignore: avoid_print
    print('ORDINE FZ VOCE 01 E 02: guardati $guardati file di lib, '
        'derivazioni dal segno fuori dalla migrazione trovate '
        '${colpevoli.length}');
    expect(colpevoli, isEmpty,
        reason: 'questi file derivano ancora l\'animale di una persona dal '
            'suo segno solare, fuori dal ponte di migrazione:\n'
            '${colpevoli.join('\n')}');
  });

  test(
      'LA PORTA UNICA, `AnimaleDiPotere`, e nessun\'altra via che ricalcoli '
      'il riconoscimento a mano', () {
    // **SE TORNASSE UN CALCOLO FATTO A MANO**, per esempio un confronto
    // diretto `IQuattroViaggi.nomeDopoLeQuattroDiscese(apparizioni, nome)`
    // con un nome indovinato da qualche altra parte, due schermate
    // potrebbero di nuovo disaccordarsi: e' esattamente il difetto
    // dell'ordine DC che questa guardia, nella sua forma precedente,
    // sorvegliava.
    final colpevoli = <String>[];
    var guardati = 0;
    for (final f in sorgentiDiLib()) {
      final p = f.path.replaceAll(Platform.pathSeparator, '/');
      if (p == 'lib/core/viaggio/i_quattro_viaggi.dart' ||
          p == 'lib/core/viaggio/il_nome_si_puo_dire.dart' ||
          p == 'lib/core/viaggio/il_responso_del_viaggio.dart' ||
          p == 'lib/core/viaggio/diario_dei_viaggi.dart') {
        continue;
      }
      guardati++;
      final codice = f.readAsLinesSync();
      var trovato = false;
      for (final r in codice) {
        final st = r.trimLeft();
        if (st.startsWith('//') || st.startsWith('///')) continue;
        if (r.contains('nomeDopoLeQuattroDiscese')) trovato = true;
      }
      if (trovato) colpevoli.add(p);
    }
    expect(guardati, greaterThan(500),
        reason: 'i file di lib trovati sono troppo pochi');
    // ignore: avoid_print
    print('ORDINE FZ VOCE 01: guardati $guardati file fuori dalla porta '
        'unica, chiamano ancora il confronto a mano: ${colpevoli.length}');
    expect(colpevoli, isEmpty,
        reason: 'questi file ricalcolano il riconoscimento a mano invece di '
            'chiedere ad AnimaleDiPotere:\n${colpevoli.join('\n')}');
  });
}
