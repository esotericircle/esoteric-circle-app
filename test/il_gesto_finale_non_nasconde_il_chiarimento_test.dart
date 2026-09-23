// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/chat/la_risposta_che_chiede.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL GESTO FINALE NON NASCONDE IL CHIARIMENTO.** Ordine EI voce 02, 23
/// settembre 2026, che riapre la voce EB.06.
///
/// ## IL DIFETTO, TROVATO DA UN COLLAUDO VERO E NON DA UNA LETTURA
///
/// Il 23 settembre 2026 il collaudo delle sedici mosse ha girato contro Gemini
/// vero. Alla mossa 8, il messaggio incomprensibile, **tutti e tre i Maestri
/// hanno chiesto un chiarimento e tutti e tre hanno fatto scendere il
/// contatore di uno**. La regola della voce EE.07 dice il contrario: chi non
/// ha ricevuto nessuna lettura non paga.
///
/// **La causa.** `eUnaDomanda` guardava la fine del testo, e ogni risposta dei
/// Maestri si chiude con la riga del gesto, quella che comincia con la stella.
/// Quella riga **non e' mai una domanda**, e' un'azione. Quindi la fine
/// guardata era sempre il gesto, e il chiarimento non scattava **mai** su una
/// risposta vera dell'app.
///
/// ## E LA PROVA CHE AVREBBE DOVUTO PRENDERLO PROMETTEVA PIU' DI QUANTO
/// MISURASSE
///
/// In `il_chiarimento_non_costa` c'era gia' una prova intitolata *"e la
/// chiusura col gesto non nasconde la domanda"*. **Non metteva nessun gesto**:
/// provava uno spazio in coda e una virgoletta di chiusura. Il nome copriva
/// un caso che il corpo non guardava, e chi leggeva l'elenco delle prove
/// smetteva di cercare proprio li'.
///
/// **Padre del difetto: ordine EE voce 07.**
void main() {
  /// Le tre risposte **vere**, copiate dalle trascrizioni del collaudo del 23
  /// settembre 2026, `docs/collaudo/ED/mossa-08-*.md`. Sono la ragione per cui
  /// questa prova non usa esempi inventati: un esempio inventato avrebbe
  /// avuto il punto interrogativo, e il difetto sarebbe rimasto nascosto.
  const chiarimentiVeri = <String, String>{
    'medora': 'Il cielo questa volta non offre parole chiare, ne\' le carte '
        'hanno disegnato un percorso riconoscibile.\n'
        'Sembra che tu abbia digitato qualcosa che non riesco a interpretare. '
        'Se desideri, puoi riformulare la tua domanda.\n'
        '\n'
        '✦ Riformula la tua domanda.',
    'aura': 'Non ho compreso il tuo messaggio, che appare come una sequenza '
        'di lettere. Per poterti accompagnare, ho bisogno di sentire la tua '
        'domanda, cio\' che porta il tuo centro a cercare.\n'
        '\n'
        '✦ Ascolta il tuo respiro.',
    'caligo': 'Chiarisci il tuo intento, formula una domanda definita. Ti '
        'guidero\' attraverso i segni.\n'
        '\n'
        '✦ Ti offro la runa Kenaz, la fiaccola che illumina il cammino.',
  };

  /// Risposte vere che sono **letture**, non richieste: queste devono
  /// continuare a pagare, o la cura avrebbe regalato ogni risposta.
  const lettureVere = <String, String>{
    'medora, la stesa interpretata':
        'Il cielo si schiude rivelando una riflessione profonda sul tuo '
            'percorso professionale. Il Papa suggerisce un periodo in cui la '
            'saggezza si fa strada. Si tratta di una rivelazione, non di una '
            'condanna.\n'
            '\n'
            '✦ Riconosci la conclusione di un ciclo.',
    'una lettura con una domanda retorica in mezzo':
        'Ti chiedi se sia il momento giusto? Il cielo dice di si\'. La Luna '
            'in Cancro custodisce quello che hai costruito, e il Sole lo '
            'illumina senza fretta.\n'
            '\n'
            '✦ Custodisci quello che hai.',
  };

  test('i tre chiarimenti veri dei Maestri si riconoscono tutti', () {
    final nonVisti = <String>[];
    for (final e in chiarimentiVeri.entries) {
      if (!LaRispostaCheChiede.eUnaDomanda(e.value)) nonVisti.add(e.key);
    }
    print('ORDINE EI VOCE 02: chiarimenti veri riconosciuti '
        '${chiarimentiVeri.length - nonVisti.length} su '
        '${chiarimentiVeri.length}');
    // Il cardinale: tre Maestri, tre risposte. Se la mappa si svuotasse,
    // questa prova sarebbe verde senza aver guardato niente.
    expect(chiarimentiVeri.length, 3);
    expect(nonVisti, isEmpty,
        reason: 'questi Maestri chiedono un chiarimento e la persona lo paga: '
            '$nonVisti');
  });

  test('e la riga del gesto da sola non basta a farne una domanda', () {
    // **La grandezza che tiene onesta la cura.** Se bastasse togliere il
    // gesto, qualunque risposta che finisce con un punto diventerebbe un
    // chiarimento e non si pagherebbe piu' niente.
    final paganti = <String>[];
    for (final e in lettureVere.entries) {
      if (LaRispostaCheChiede.eUnaDomanda(e.value)) paganti.add(e.key);
    }
    print('ORDINE EI VOCE 02: letture vere che restano a pagamento '
        '${lettureVere.length - paganti.length} su ${lettureVere.length}');
    expect(lettureVere.length, 2);
    expect(paganti, isEmpty,
        reason: 'queste sono letture vere e non si pagano piu\': la cura ha '
            'regalato la risposta invece del chiarimento: $paganti');
  });

  test('una domanda col punto interrogativo sotto il gesto si vede ancora', () {
    // Il caso che il codice gia' copriva, tenuto perche' la cura non deve
    // toglierlo.
    const conDomanda = 'Per leggere le carte mi serve sapere una cosa.\n'
        'Qual e\' la domanda che avevi in mente?\n'
        '\n'
        '✦ Dimmi la tua domanda.';
    expect(LaRispostaCheChiede.eUnaDomanda(conDomanda), isTrue);
  });

  test('la prova della voce EI.02 resta scritta su disco', () {
    final b = StringBuffer()
      ..writeln('IL MAESTRO CHIEDE CIO\' CHE GLI MANCA, E QUEL TURNO NON COSTA')
      ..writeln('Ordine EI voce 02, che riapre la voce EB.06.')
      ..writeln()
      ..writeln('LE TRE RISPOSTE VERE, dal collaudo con Gemini del 23 '
          'settembre 2026, mossa 8, il messaggio incomprensibile.')
      ..writeln('Prima della cura tutte e tre facevano scendere il contatore '
          'di 1. Dopo, nessuna.')
      ..writeln();
    for (final e in chiarimentiVeri.entries) {
      b
        ..writeln('--- ${e.key}')
        ..writeln(e.value)
        ..writeln('    riconosciuto come chiarimento: '
            '${LaRispostaCheChiede.eUnaDomanda(e.value)}')
        ..writeln();
    }
    b
      ..writeln('E LE LETTURE VERE CONTINUANO A PAGARE, o la cura avrebbe '
          'regalato ogni risposta:')
      ..writeln();
    for (final e in lettureVere.entries) {
      b.writeln('--- ${e.key}: riconosciuto come chiarimento: '
          '${LaRispostaCheChiede.eUnaDomanda(e.value)}');
    }

    final cartella = Directory('docs/collaudo/EI')..createSync(recursive: true);
    final f = File('${cartella.path}/il_chiarimento_non_costa.txt')
      ..writeAsStringSync(b.toString());
    expect(f.lengthSync(), greaterThan(800));
  });
}
