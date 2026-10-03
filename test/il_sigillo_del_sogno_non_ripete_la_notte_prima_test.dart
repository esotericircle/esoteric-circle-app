// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/rituals/dream_rite_corpus.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL SIGILLO DEL SOGNO NON RIPETE LA NOTTE PRIMA.** Ordine EH voce 01, 24
/// settembre 2026.
///
/// ## IL FATTO DEL FONDATORE, E PERCHE' LA MIA PROVA NON L'AVEVA PRESO
///
/// > *"sto facendo dei test sul dono sigillo del sogno e mi sembra il testo
/// > uguale a ieri"*
///
/// Aveva ragione. **E la colpa e' di una cura mia**: l'ordine EE voce 04 ha
/// portato *"Oggi hai..."* e *"Se guardi indietro, hai..."* dal segno della
/// Luna di stanotte a quello della **Luna di nascita**. La sorgente e'
/// giusta, e' il segno sotto cui quella persona guarda il proprio giorno; ma
/// **la Luna di nascita non cambia mai**, quindi da allora quelle due frasi
/// erano identiche ogni notte, per sempre, per ciascuno.
///
/// **La misura che chiudeva la EE.04 diceva il vero e rispondeva a un'altra
/// domanda**: *"nella stessa notte, dieci nascite ricevono dieci saluti
/// diversi"*. Misurava che **due persone** leggessero cose diverse. Il
/// fondatore guardava **una persona in due notti**.
///
/// **Questa prova misura la sua domanda.** Stessa persona, notti diverse.
void main() {
  /// La stessa persona, sempre.
  final nascita = DateTime(1988, 7, 5, 14, 30);

  /// Sette notti di fila, che e' piu' dei due giorni e mezzo in cui la Luna
  /// resta in un segno: dentro ci sono per forza notti col segno uguale, che
  /// sono quelle difficili.
  final notti = [
    for (var g = 0; g < 7; g++) DateTime(2026, 9, 23 + g, 22, 47),
  ];

  test('sette notti di fila non danno mai due saluti identici', () {
    final saluti = [
      for (final n in notti) DreamRiteCorpus.saluto(n, nascita: nascita),
    ];
    final gemelli = <String>[];
    for (var i = 0; i < saluti.length; i++) {
      for (var j = i + 1; j < saluti.length; j++) {
        if (saluti[i] == saluti[j]) {
          gemelli.add('la notte ${i + 1} e la notte ${j + 1} dicono la stessa '
              'identica cosa');
        }
      }
    }
    print('ORDINE EH VOCE 01: notti guardate ${saluti.length}, '
        'saluti distinti ${saluti.toSet().length}, '
        'coppie identiche ${gemelli.length}');
    // Il cardinale: se il ciclo girasse a vuoto questa prova sarebbe verde
    // senza aver guardato niente.
    expect(saluti.length, 7);
    expect(gemelli, isEmpty, reason: gemelli.join('\n'));
  });

  test('e nemmeno la frase su cio\' che hai fatto oggi si ripete sempre', () {
    // **La grandezza che prende il difetto vero.** Due saluti interi possono
    // gia' differire per il solo segno della Luna, e allora la prova sopra
    // sarebbe verde mentre la frase sulla persona resta identica per sempre:
    // **era esattamente lo stato in cui il fondatore l'ha trovata.** Qui si
    // guarda quel pezzo e basta.
    final pezzi = <String>{};
    for (final n in notti) {
      final s = DreamRiteCorpus.saluto(n, nascita: nascita);
      final da = s.indexOf('Oggi ');
      final a = s.indexOf('Stanotte la Luna', da);
      if (da >= 0 && a > da) pezzi.add(s.substring(da, a).trim());
    }
    print('ORDINE EH VOCE 01: modi distinti di dire la giornata su sette '
        'notti: ${pezzi.length}');
    expect(pezzi.length, greaterThanOrEqualTo(3),
        reason: 'su sette notti la frase che dice cosa hai fatto oggi prende '
            'solo ${pezzi.length} forme: viene da un dato che non cambia, ed '
            'e\' il difetto dell\'ordine EE voce 04');
  });

  test('la riga che spiega la figura dice il vero, e tace quando non serve',
      () {
    // **Decisione del fondatore del 24 settembre 2026**: la costellazione
    // resta quella del segno lunare, e all'utente si dice perche' la rivede
    // uguale. Qui si misura che la riga compaia quando la Luna non si muove e
    // sparisca quando si muove: una spiegazione che non serve e' rumore.
    var conLaRiga = 0, senza = 0;
    for (var g = 0; g < 30; g++) {
      final quando = DateTime(2026, 9, 23 + g, 22, 47);
      final riga = DreamRiteCorpus.perchePosaLaStessaFigura(quando);
      final cambia = DreamRiteCorpus.notteInCuiLaLunaCambiaSegno(quando);
      if (riga == null) {
        senza++;
        expect(cambia, lessThanOrEqualTo(1),
            reason: 'la riga tace ma la Luna resta ferma ancora $cambia '
                'notti: chi rivede la stessa figura non sa perche\'');
      } else {
        conLaRiga++;
        expect(riga, contains('La Luna resta in'));
        expect(cambia, greaterThan(1),
            reason: 'la riga dice che la Luna resta ferma, e invece stanotte '
                'cambia segno: e\' una riga falsa');
      }
    }
    print('ORDINE EH VOCE 01: su trenta notti la riga della figura compare '
        '$conLaRiga volte e tace $senza volte');
    expect(conLaRiga, greaterThan(0));
    expect(senza, greaterThan(0),
        reason: 'la riga non tace mai: allora non dipende dal cielo');
  });

  test('la prova della voce EH.01 resta scritta su disco', () {
    // **La regola nuova della casa, ordine EH voce 02**: una voce si scrive
    // CHIUSA solo con una prova che si puo' aprire. Questa e' quella prova, e
    // nasce qui invece di essere copiata a mano.
    final b = StringBuffer()
      ..writeln('IL SIGILLO DEL SOGNO, SETTE NOTTI DI FILA, STESSA PERSONA')
      ..writeln('Ordine EH voce 01, nascita 5 luglio 1988.')
      ..writeln();
    for (final n in notti) {
      b
        ..writeln('--- ${n.toIso8601String()}')
        ..writeln(DreamRiteCorpus.saluto(n, nascita: nascita))
        ..writeln(DreamRiteCorpus.perchePosaLaStessaFigura(n) ??
            '(la Luna cambia segno stanotte: nessuna riga da mostrare)')
        ..writeln();
    }
    final cartella = Directory('docs/collaudo/EH')..createSync(recursive: true);
    File('${cartella.path}/sette_notti.txt').writeAsStringSync(b.toString());
    expect(File('${cartella.path}/sette_notti.txt').lengthSync(),
        greaterThan(500));
  });
}
