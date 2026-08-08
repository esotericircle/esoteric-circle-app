import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// OGNI FUNZIONE CHE USA UN SENSORE OFFRE UNA VIA TOCCABILE, E LO DICE.
///
/// Ordine 2166, voce 3. Nell'Indice delle Prescrizioni la riga "Ripiego
/// tattile per ogni sensore" e' marcata VIVA, ma non era riverificata dal 29
/// luglio: questa prova la riverifica a ogni giro, e soprattutto la
/// riverifica sulle funzioni che nasceranno domani.
///
/// **Si ENUMERA, non si visita.** Una prova che controlla il Soffio e le
/// Rune non dice niente sul rito che qualcuno aggiungera' fra un mese: qui si
/// cercano nel codice TUTTI i punti che si iscrivono a un sensore o chiedono
/// un permesso di sensore, e per ognuno si pretende la via toccabile e la
/// dichiarazione a schermo.
void main() {
  /// I modi in cui una schermata prende un sensore. Chi ne aggiunge uno
  /// nuovo lo mette qui, e da quel momento tutte le schermate che lo usano
  /// devono avere il loro ripiego.
  /// **LA MISURA E' STATA AFFINATA, e va detto perche'.** La prima stesura
  /// cercava "Geolocator." e denunciava la schermata delle impostazioni, che
  /// il sensore non lo usa affatto: chiama `openAppSettings`, cioe' apre la
  /// scheda dell'app. Prendere l'apertura delle impostazioni per un uso del
  /// sensore avrebbe costretto a scrivere un ripiego inesistente per una
  /// cosa che non ha bisogno di ripiego. Adesso si cercano le chiamate che
  /// LEGGONO davvero il sensore.
  const usiDiSensore = [
    'accelerometerEventStream',
    'gyroscopeEventStream',
    'AscoltatoreScuotimento',
    'BreathDetector',
    'AudioRecorder',
    'CameraController',
    'Geolocator.getCurrentPosition',
    'Geolocator.checkPermission',
    'Geolocator.requestPermission',
  ];

  /// I segni di una via toccabile dichiarata. Non basta che il ripiego
  /// esista nel codice: la schermata deve DIRLO, altrimenti sembra rotta.
  const segniDelRipiego = [
    'ripiego',
    'col tocco',
    'col dito',
    'tieni premuto',
    'toccando',
    'Tocca',
  ];

  List<File> fileConSensore() {
    final trovate = <File>[];
    for (final f in Directory('lib/features')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final testo = f.readAsStringSync();
      if (usiDiSensore.any(testo.contains)) trovate.add(f);
    }
    return trovate;
  }

  /// I file che disegnano qualcosa: sono loro a dover offrire il gesto e a
  /// doverlo dichiarare.
  bool disegna(String testo) => testo.contains('Widget build(');

  /// Chi importa un file di sola logica. **Un file che calcola non ha
  /// pulsanti, e pretenderglieli sarebbe misurare la cosa sbagliata**: il
  /// ripiego di `stesa_senses`, che legge il giroscopio, vive nella
  /// schermata della stesa che lo usa. Si risale a chi lo importa e si
  /// pretende il ripiego LI'.
  List<File> chiLoUsa(File logica) {
    final nome = logica.path.split(RegExp(r'[\\/]')).last;
    return Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart') && f.path != logica.path)
        .where((f) => f.readAsStringSync().contains(nome))
        .toList();
  }

  test('ci sono davvero schermate con sensori: la prova non gira a vuoto',
      () {
    // IL PRESIDIO CONTRO LA PROVA INERTE: se domani i nomi dei sensori
    // cambiassero, l'enumerazione tornerebbe vuota e tutto passerebbe senza
    // aver guardato niente.
    final quante = fileConSensore().length;
    // ignore: avoid_print
    print('SENSORI: schermate che usano un sensore = $quante');
    expect(quante, greaterThanOrEqualTo(6),
        reason: 'Solo $quante schermate con sensore: l\'enumerazione ha perso '
            'i nomi e questa prova non sta guardando piu\' niente.');
  });

  test('ogni funzione con un sensore offre una via toccabile e la dichiara',
      () {
    bool toccabile(String testo) =>
        testo.contains('GestureDetector') ||
        testo.contains('onTap') ||
        testo.contains('onLongPress') ||
        testo.contains('onPanUpdate') ||
        testo.contains('TextButton') ||
        testo.contains('FilledButton') ||
        testo.contains('IconButton');
    bool dichiara(String testo) =>
        segniDelRipiego.any(testo.contains) ||
        testo.contains('AvvisoDelPermesso');

    final colpe = <String>[];
    for (final f in fileConSensore()) {
      final testo = f.readAsStringSync();
      final percorso = f.path.replaceAll('\\', '/');

      if (disegna(testo)) {
        if (!toccabile(testo)) {
          colpe.add('$percorso: usa un sensore e non offre nessun gesto '
              'toccabile: chi nega il permesso resta senza l\'arte.');
        }
        if (!dichiara(testo)) {
          colpe.add('$percorso: usa un sensore e non dichiara da nessuna '
              'parte la via alternativa: il ripiego muto e\' un ripiego che '
              'nessuno trova.');
        }
        continue;
      }

      // File di sola logica: il ripiego deve stare in ALMENO UNA delle
      // schermate che lo usano, e se non lo usa nessuno e' un difetto suo.
      final usanti = chiLoUsa(f);
      if (usanti.isEmpty) {
        colpe.add('$percorso: legge un sensore e non lo usa nessuno: o e\' '
            'morto, o qualcuno lo usa in un modo che questa prova non vede.');
        continue;
      }
      final coperto = usanti.any((u) {
        final t = u.readAsStringSync();
        return toccabile(t) && dichiara(t);
      });
      if (!coperto) {
        colpe.add('$percorso: legge un sensore e NESSUNA delle schermate che '
            'lo usano offre un gesto toccabile dichiarato '
            '(${usanti.map((u) => u.path.split(RegExp(r"[\\\\/]")).last).join(", ")}).');
      }
    }
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });
}
