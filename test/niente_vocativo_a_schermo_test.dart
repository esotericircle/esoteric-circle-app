import 'dart:io';

import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

/// La parola "vocativo" non si mostra a nessuno.
///
/// E' un termine di grammatica, e nessuno si rivolge a se' stesso con un
/// termine di grammatica.
///
/// **Quante porte c'erano.** Tre occorrenze dentro letterali in tutto `lib`, di
/// cui una sola visibile: il sottotitolo del passo. Le altre due sono
/// `titoloEvocativo` della Costellazione del Viso, che e' un'altra parola, e la
/// chiave di un widget, che non si vede. In un ordine precedente avevo corretto
/// un'altra occorrenza lasciando questa: la stessa forma di difetto del nome
/// minuscolo, cioe' una regola messa in una porta mentre le porte sono piu'
/// d'una.
///
/// Questo test guarda TUTTO il codice, non un file: e' la sola difesa che vale.
void main() {
  /// Ogni letterale mostrato a schermo che contenga la parola.
  List<String> porteAperte() {
    final trovate = <String>[];
    final letterale = RegExp("'[^']*'");
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final righe = f.readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        final t = righe[i].trimLeft();
        if (t.startsWith('//')) continue;
        for (final m in letterale.allMatches(righe[i])) {
          final s = m.group(0)!.toLowerCase();
          // "evocativo" e' un'altra parola, e una chiave di widget non si vede.
          if (!s.contains('vocativ')) continue;
          if (s.contains('evocativ')) continue;
          if (s.startsWith("'vocativo_")) continue;
          trovate.add('${f.path}:${i + 1} ${m.group(0)}');
        }
      }
    }
    return trovate;
  }

  test('Nessun testo mostrato contiene la parola vocativo', () {
    final porte = porteAperte();
    expect(porte, isEmpty,
        reason: 'la parola compare ancora in ${porte.length} punti mostrati a '
            'schermo:\n${porte.join("\n")}');
  });

  test('La forma neutra non elenca participi', () {
    // "Benvenuto/Benvenuta" farebbe scegliere alla persona quale meta' della
    // barra le appartiene, che e' il contrario di una forma neutra.
    for (final forma in CourtesyForm.values) {
      final benvenuto = forma.welcome;
      expect(benvenuto.contains('/'), isFalse,
          reason: 'la forma ${forma.name} elenca due participi: $benvenuto');
    }
    expect(CourtesyForm.neutral.welcome, 'Ti do il benvenuto',
        reason: 'la forma neutra non e\' una frase senza desinenza');
  });

  test('Nessun testo mostrato elenca participi con la barra', () {
    // La regola vale per tutti i testi, non solo per il benvenuto.
    final sospette = <String>[];
    final letterale = RegExp(r"'[^']*[a-z](o/a|a/o|o/e|to/ta)[^']*'");
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final righe = f.readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        if (righe[i].trimLeft().startsWith('//')) continue;
        if (righe[i].contains('import ')) continue;
        for (final m in letterale.allMatches(righe[i])) {
          // **UN PERCORSO DI FILE NON E' UN TESTO MOSTRATO**, e la prova ne
          // accusava uno: `'lib/features/maestri/caligo/animal/guide_animal_screen.dart'`
          // contiene `o/a` fra "caligo" e "animal", cioe' due lettere separate
          // da una barra che non sono due desinenze. Il registro delle arti
          // dichiara le schermate per percorso, ed e' giusto che lo faccia.
          // Cambiata la grandezza misurata, non la soglia: si scartano le
          // stringhe che sono percorsi, e la regola sui participi resta intera.
          final trovata = m.group(0)!;
          if (trovata.contains('.dart') || trovata.contains('lib/')) continue;
          sospette.add('${f.path}:${i + 1} $trovata');
        }
      }
    }
    expect(sospette, isEmpty,
        reason: 'testi che elencano due desinenze:\n${sospette.join("\n")}');
  });

  test('Nessun testo mostrato elenca participi con la virgola', () {
    // "Sei arrivata fin qui, o arrivato" non ha barre, quindi la ricerca
    // precedente non lo vedeva: cercavo "o/a" e la forma qui e' un elenco
    // separato da una virgola piu' la conginzione. Le porte erano due, di
    // nuovo.
    final sospette = <String>[];
    final elenco = RegExp(r"[a-z]+(?:ata|ato|uta|uto|ita|ito),\s*o\s+[a-z]+(?:ata|ato|uta|uto|ita|ito)");
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final righe = f.readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        if (righe[i].trimLeft().startsWith('//')) continue;
        for (final m in elenco.allMatches(righe[i])) {
          sospette.add('${f.path}:${i + 1} ${m.group(0)}');
        }
      }
    }
    expect(sospette, isEmpty,
        reason: 'testi che elencano due participi: ${sospette.join(', ')}');
  });
}
