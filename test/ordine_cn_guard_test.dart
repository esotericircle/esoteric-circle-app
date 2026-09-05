import 'dart:io';

import 'package:esoteric_circle/core/sensi/catalogo_musiche.dart';
import 'package:esoteric_circle/core/sensi/catalogo_suoni.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA GUARDIA DELL'ORDINE CN.** 1 settembre 2026.
///
/// Non racconta l'ordine: lo verifica. Ogni cosa che il manifesto dichiara
/// fatta viene riaperta e ricontata.
void main() {
  final manifesto = File('docs/ordini/ORDINE_CN_MANIFESTO.md');

  String testo() {
    expect(manifesto.existsSync(), isTrue,
        reason: 'il manifesto dell\'ordine CN non esiste');
    return manifesto.readAsStringSync();
  }

  test('il manifesto nomina tutte e sedici le voci', () {
    final t = testo();
    final mancanti = <String>[];
    for (var i = 1; i <= 16; i++) {
      if (!t.contains('VOCE ${i.toString().padLeft(2, '0')}')) {
        mancanti.add('VOCE ${i.toString().padLeft(2, '0')}');
      }
    }
    expect(mancanti, isEmpty,
        reason: 'il manifesto non nomina queste voci: $mancanti');
  });

  test('le cinque premesse hanno il loro esito', () {
    final t = testo();
    for (var i = 1; i <= 5; i++) {
      final riga = RegExp('\\*\\*R$i\\.[^*]*\\*\\*').firstMatch(t);
      expect(riga, isNotNull, reason: 'la premessa R$i non ha la sua riga');
      final corpo = riga!.group(0)!;
      expect(
          corpo.contains('VERA') ||
              corpo.contains('FALSA') ||
              corpo.contains('Decaduta'),
          isTrue,
          reason: 'la premessa R$i non dice come e\' andata: $corpo');
    }
  });

  test('CN.01: il catalogo ha tredici voci e nessuna e\' nata fuori', () {
    expect(SuonoDelCerchio.values.length, 13,
        reason: 'il catalogo non ha piu\' tredici voci: l\'ordine CN le porta '
            'da sette a tredici, e un suono che nasce fuori dal catalogo e\' '
            'un suono che nessuno sa piu\' dove suona');
    final nomi = SuonoDelCerchio.values.map((s) => s.file).toSet();
    expect(nomi.length, SuonoDelCerchio.values.length,
        reason: 'due voci del catalogo puntano allo stesso file');
  });

  test('CN.03: gli anelli sono quattro, e la Meditazione non e\' fra loro', () {
    expect(MusicaDelCerchio.values.length, 4,
        reason: 'gli anelli d\'ambiente non sono piu\' quattro. La correzione '
            'del fondatore del 1 settembre 2026 dice che sono e restano '
            'quattro, e che nessuna traccia della Meditazione entra '
            'nell\'app.');
    final file = MusicaDelCerchio.values.map((m) => m.file).join(' ');
    for (final vietata in const ['theta', '432', '528', 'meditation']) {
      expect(file.toLowerCase().contains(vietata), isFalse,
          reason: 'una traccia della Meditazione e\' entrata negli anelli '
              'd\'ambiente: "$vietata" compare in $file. **Nessuna delle tre '
              'entra**, per decisione del fondatore.');
    }
  });

  test('CN.05 annullata: la Meditazione non e\' stata toccata', () {
    // **LA PROVA PIU' IMPORTANTE DI QUEST'ORDINE, ed e' una prova di ASSENZA.**
    // La correzione del fondatore annulla per intero la voce CN.05: il
    // battito binaurale resta, la prescrizione del volume zero resta, nessun
    // riferimento va tolto. Qui si verifica che tutto cio' sia ancora dove
    // era.
    final audio =
        File('lib/features/maestri/aura/meditation/meditation_audio.dart')
            .readAsStringSync();
    expect(audio.contains('thetaBeat'), isTrue,
        reason: 'il preset del battito theta e\' sparito dalla Meditazione');
    expect(audio.contains('leftHz: 210'), isTrue,
        reason: 'la portante sinistra del battito non e\' piu\' 210 Hz');
    expect(audio.contains('rightHz: 217'), isTrue,
        reason: 'la portante destra non e\' piu\' 217 Hz, quindi il battito '
            'non vale piu\' 7 Hz: la premessa R2 dell\'ordine CN ha verificato '
            'che quei 7 Hz sono generati davvero, ed e\' quello che l\'app '
            'dichiara');
    expect(audio.contains('binaural: true'), isTrue,
        reason: 'nessun preset si dichiara piu\' binaurale');

    final schermo =
        File('lib/features/maestri/aura/meditation/meditation_screen.dart')
            .readAsStringSync();
    expect(schermo.contains('binaurale'), isTrue,
        reason: 'il riferimento al battito binaurale e\' sparito dalla '
            'schermata della Meditazione. **La correzione del fondatore dice '
            'che resta**: la voce CN.05 e\' annullata per intero, e non c\'e\' '
            'nessun superamento da scrivere.');

    final generatore =
        File('lib/features/maestri/aura/meditation/tone_generator.dart')
            .readAsStringSync();
    expect(generatore.contains('leftHz'), isTrue);
    expect(generatore.contains('rightHz'), isTrue,
        reason: 'il generatore non scrive piu\' due canali diversi: senza, il '
            'battito binaurale non esisterebbe davvero, e sarebbe la promessa '
            'scritta che la premessa R2 doveva escludere');
  });

  test('CN.07: i volumi di partenza sono quelli decisi', () {
    final s = SettingsController();
    expect(s.volumeMusica, 0.6,
        reason: 'la musica non parte piu\' al sessanta per cento');
    expect(s.volumeEffetti, 1.0,
        reason: 'gli effetti non partono piu\' al cento per cento');
    expect(s.musicaAttiva, isTrue,
        reason: 'la musica non nasce piu\' accesa. **Nascerla spenta '
            'cancellerebbe il disegno dell\'ordine CN**, cioe\' lo Shaman che '
            'parte con la prima schermata del Risveglio e prosegue fino alla '
            'home. Se la decisione cambia, cambiala nel manifesto insieme.');
    expect(s.effettiSonori, isTrue,
        reason: 'gli effetti non nascono piu\' accesi. **La decisione del '
            '2 settembre 2026 supera la voce BZ.05**, che li voleva spenti '
            '"almeno fino a quando non ne scegliero qualcuno decente": '
            'l\'ordine CN ha soddisfatto quella condizione, quindi la '
            'ragione di allora e\' scaduta.');
    expect(s.musicaPermessa, isTrue);
    expect(s.suonoPermesso, isTrue,
        reason: 'con tutti e due gli interruttori accesi un suono deve '
            'poter uscire');
  });

  test('CN.07: il sottomenu\' esiste e la lista non si e\' allungata', () {
    final schermo =
        File('lib/features/settings/settings_screen.dart').readAsStringSync();
    expect(schermo.contains('SuonoScreen.route()'), isTrue,
        reason: 'le Impostazioni non aprono piu\' il sotto menu\' del suono');
    expect(schermo.contains('settings_effetti_sonori'), isFalse,
        reason: 'la riga degli effetti e\' tornata nelle Impostazioni oltre a '
            'stare nel sotto menu\': sono due porte per lo stesso comando');

    final sotto =
        File('lib/features/settings/suono_screen.dart').readAsStringSync();
    for (final chiave in const [
      'suono_effetti',
      'suono_musica',
      'suono_volume_effetti',
      'suono_volume_musica',
    ]) {
      expect(sotto.contains(chiave), isTrue,
          reason: 'il sotto menu\' del suono ha perso "$chiave": l\'ordine ne '
              'chiede quattro, due interruttori e due cursori');
    }
  });

  test('CN.12: le card da condividere si disegnano a misura fissa', () {
    final senza = <String>[];
    var guardate = 0;
    for (final f in Directory('lib/features')
        .listSync(recursive: true)
        .whereType<File>()) {
      final percorso = f.path.replaceAll(r'\', '/');
      if (!percorso.endsWith('_share_card.dart')) continue;
      guardate++;
      // **O DIRETTAMENTE, O DALLA PORTA CHE LA CONTIENE. Ordine CQ voce
      // 6.26, 4 settembre 2026.**
      //
      // `CardDaMandare` avvolge `CardAMisuraFissa` al suo interno: una card
      // che passa da li' e' protetta quanto una che la nomina, e pretendere
      // il nome invece del fatto costringerebbe a scrivere due volte la
      // stessa protezione.
      final testo = f.readAsStringSync();
      if (!testo.contains('CardAMisuraFissa') &&
          !testo.contains('CardDaMandare(')) {
        senza.add(percorso.substring(percorso.indexOf('lib/')));
      }
    }
    cardinaleMinimo(guardate, 6,
        cosa: 'card da condividere',
        perche: 'Se non se ne trova piu\' nessuna, questa prova non trova '
            'nessuna card fuori regola perche\' non ne ha guardata una.');
    expect(senza, isEmpty,
        reason: 'QUESTE CARD SEGUONO ANCORA LA SCALA DEL TESTO DI CHI LE '
            'CREA: $senza.\n'
            'Sono immagini guardate da altri, sui loro schermi: cuocere '
            'dentro l\'immagine un\'impostazione personale di accessibilita\' '
            'produrrebbe card di proporzioni diverse per ogni utente.');
  });

  test('l\'ordine CN non e\' finito finche\' una voce resta aperta', () {
    final fermate =
        RegExp(r'VOCE \d\d[^\n]*FERMATA').allMatches(testo()).length;
    expect(fermate, 0,
        reason: 'restano $fermate voci fermate: questa prova e\' rossa per '
            'legge di consegna finche\' tutte e sedici non hanno uno stato '
            'terminale.');
  });
}
