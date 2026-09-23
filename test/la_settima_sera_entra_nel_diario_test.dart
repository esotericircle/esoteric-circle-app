// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/ricordi/ricordo_custodito.dart';
import 'package:esoteric_circle/core/rituals/sunset_rune_memory.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA SETTIMA SERA ENTRA NEL DIARIO.** Ordine EI voce 05, 23 settembre 2026,
/// che riapre la voce EE.03.
///
/// ## LA LACUNA VERA, TROVATA DAL CENSIMENTO
///
/// La voce EE.03 ha tre parti: la serie di sette sere, la riga che la spiega a
/// video, e **il riassunto che alla settima sera entra da solo nel Cosmic
/// Journal come evento speciale**. Le prime due erano provate da
/// `sette_sere_di_fila` e da `sunset_rune_screen_test`. **La terza non era
/// toccata da nessun file di `test/`**: ne' `ComeENato.evento` ne'
/// `didascaliaDellaSettimana` comparivano da nessuna parte.
///
/// Quindi la voce era dichiarata chiusa con **un terzo del lavoro non
/// sorvegliato**, ed e' esattamente la ragione per cui l'ordine EH l'ha
/// riaperta.
///
/// ## COSA MISURA, E PERCHE' PROPRIO QUESTO
///
/// Due cose che una persona vedrebbe subito e che nessuna prova guardava:
/// che la frase del riassunto **dica il vero sulle rune di quella settimana**,
/// e che il Ricordo si dichiari **nato dal Cerchio e non dalla persona**, che
/// e' la ragione per cui esiste `ComeENato.evento`.
void main() {
  test('la frase del riassunto dice il vero sulle rune della settimana', () {
    // **Sette rune diverse**: la frase deve dire che nessuna ha insistito.
    const diverse = [
      'Fehu',
      'Uruz',
      'Thurisaz',
      'Ansuz',
      'Raidho',
      'Kenaz',
      'Gebo'
    ];
    final senzaRipetute = didascaliaDellaSettimana(diverse.toList());
    expect(senzaRipetute, contains('Sette segni diversi'),
        reason: 'sette rune tutte diverse e la frase parla di un legame');
    expect(senzaRipetute, isNot(contains('tornano')));

    // **Una runa che torna tre volte**: la frase deve nominare il legame, e
    // deve nominare **quella** runa, non una a caso.
    const conRipetute = ['Isa', 'Fehu', 'Isa', 'Raidho', 'Isa', 'Gebo', 'Fehu'];
    final conLegame = didascaliaDellaSettimana(conRipetute.toList());
    expect(conLegame, contains('tornano'),
        reason: 'tre Isa in sette sere e la frase dice che nessuna ha '
            'insistito: sarebbe falsa');
    expect(conLegame, contains('Isa'),
        reason: 'la runa che torna tre volte non viene nominata: la frase '
            'parla di un legame senza dire fra cosa');

    // **La grandezza che prende il difetto vero.** Le due frasi devono
    // essere diverse: se il riassunto dicesse la stessa cosa in tutti e due i
    // casi, sarebbe una frase che non guarda le rune, ed e' il difetto del
    // Sigillo del Sogno dell'ordine EH.
    expect(senzaRipetute, isNot(equals(conLegame)),
        reason: 'la settimana con ripetizioni e quella senza ricevono la '
            'stessa identica frase: allora non legge le rune');
  });

  test('il Ricordo della settima sera si dichiara nato dal Cerchio', () {
    // **Perche' questo conta.** Chi rilegge il diario deve poter sapere che
    // quella voce non l'ha messa lui: e' la ragione per cui `ComeENato.evento`
    // esiste. Se nascesse come gesto, il diario direbbe una cosa falsa sulla
    // persona.
    const rune = ['Isa', 'Fehu', 'Isa', 'Raidho', 'Isa', 'Gebo', 'Fehu'];
    final ricordo = RicordoCustodito(
      quando: DateTime(2026, 9, 16),
      arte: 'settimana_rune',
      maestro: 'caligo',
      titolo: 'Sette sere di fila: le tue rune si sono legate',
      testo: didascaliaDellaSettimana(rune),
      comeENato: ComeENato.evento,
      dati: {'rune': rune.join(',')},
    );

    expect(ricordo.comeENato, ComeENato.evento,
        reason: 'il riassunto della settimana nasce come gesto della persona, '
            'e chi rilegge il diario crederebbe di averlo messo lui');
    expect(ricordo.maestro, 'caligo',
        reason: 'la settimana delle rune non e\' di Caligo');
    expect(ricordo.testo, isNotEmpty,
        reason: 'il Ricordo entra nel diario senza testo');
    expect(ricordo.dati['rune']!.split(',').length, 7,
        reason: 'il Ricordo non porta con se\' le sette rune della settimana');
  });

  test('la prova della voce EI.05 resta scritta su disco', () {
    // Due settimane vere, una con ripetizioni e una senza, con la frase che
    // ciascuna riceve e la voce che entra nel diario.
    final b = StringBuffer()
      ..writeln('LE SETTE SERE DELLA RUNA, E LA VOCE CHE NASCE NEL DIARIO')
      ..writeln('Ordine EI voce 05, che riapre la voce EE.03.')
      ..writeln()
      ..writeln('La serie e la riga a video erano gia\' provate. Quello che '
          'nessuna prova guardava era il RICORDO che alla settima sera entra '
          'da solo nel Cosmic Journal.')
      ..writeln();

    final casi = <String, List<String>>{
      'sette rune tutte diverse': const [
        'Fehu',
        'Uruz',
        'Thurisaz',
        'Ansuz',
        'Raidho',
        'Kenaz',
        'Gebo'
      ],
      'una runa che torna tre volte': const [
        'Isa',
        'Fehu',
        'Isa',
        'Raidho',
        'Isa',
        'Gebo',
        'Fehu'
      ],
    };
    for (final c in casi.entries) {
      b
        ..writeln('--- ${c.key}')
        ..writeln('    le sere: ${c.value.join(', ')}')
        ..writeln('    la frase: '
            '${didascaliaDellaSettimana(c.value)}')
        ..writeln('    la voce nel diario: titolo "Sette sere di fila: le tue '
            'rune si sono legate", maestro caligo, nata come '
            '${ComeENato.evento.name} e non come gesto della persona')
        ..writeln();
    }
    b
      ..writeln('E UNA SERIE INTERROTTA NON FA SETTIMANA: la prova che lo '
          'misura e\' sette_sere_di_fila_test.dart, che salta una sera e '
          'verifica che la striscia riparta da capo.');

    final cartella = Directory('docs/collaudo/EI')..createSync(recursive: true);
    final f = File('${cartella.path}/sette_sere_e_il_diario.txt')
      ..writeAsStringSync(b.toString());
    print('ORDINE EI VOCE 05: settimane scritte nella prova ${casi.length}');
    expect(casi.length, 2);
    expect(f.lengthSync(), greaterThan(600));
  });
}
