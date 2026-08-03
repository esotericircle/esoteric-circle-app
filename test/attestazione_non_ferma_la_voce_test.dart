import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/diagnostics_dialog.dart';
import 'package:esoteric_circle/services/ai/registro_dei_guasti.dart';
import 'package:esoteric_circle/services/firebase/attestazione.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// L'attestazione che non riesce NON ferma la voce.
///
/// **Il dato.** Build 2132, dal pannello di messa a punto sul telefono:
/// `reply: FirebaseException [firebase_app_check/unknown] Error returned from
/// API. code: 403 body: App attestation failed.`
///
/// **Dove nasce, letto nel sorgente dell'SDK.** In
/// `firebase_ai-3.13.1/lib/src/base_model.dart:292` il costruttore delle
/// intestazioni fa `await effectiveAppCheck.getToken()` senza guardia: se
/// quella riga solleva, la chiamata all'AI non parte nemmeno.
void main() {
  test('Su una build che non puo\' attestare, non si installa', () {
    // In release, cioe' la build che arriva da App Distribution: Play Integrity
    // non puo' attestare un'app fuori dal Play Store.
    expect(Attestazione.vaInstallata(releaseMode: true), isFalse);
    // Fuori dalla release il fornitore di debug funziona, e serve.
    expect(Attestazione.vaInstallata(releaseMode: false), isTrue);
  });

  test('La scelta e\' reversibile con UN interruttore', () {
    // La condizione che chiude il compromesso: quando l'app sara' sul Play
    // Store si rimette questo a vero, e non c'e' altro da toccare.
    expect(Attestazione.installaSempre, isFalse);
  });

  test('Una scelta dichiarata NON entra fra i guasti', () async {
    // **QUESTA PROVA DICEVA IL CONTRARIO, e cristallizzava il difetto.**
    //
    // Chiedeva che la scelta finisse nel registro, con la ragione giusta: un
    // pannello che tace su cio' che non e' installato mente per omissione. La
    // conclusione pero' era sbagliata, e il 3 agosto 2026 si e' vista a
    // schermo: il pannello diceva "Voce del Maestro: accesa ma in guasto" con
    // ultimo guasto `attestazione: StateError`, mentre la voce funzionava.
    // Dichiarare e REGISTRARE COME GUASTO non sono la stessa cosa: la prima si
    // fa con l'esito, che torna a chi chiama ed e' quello che il pannello
    // mostra nella sua riga; la seconda dice che qualcosa e' andato storto.
    //
    // Se il registro porta anche le decisioni, chi lo legge non puo' piu'
    // fidarsi di cio' che dice, ed e' `isReady => true` rovesciato: prima
    // dichiarava attivo cio' che non lo era, poi rotto cio' che non lo e'.
    final registro = RegistroDeiGuasti();
    final esito = await Attestazione.installa(
      releaseMode: true,
      installatore: _InstallatoreCheNonVieneChiamato(),
      registro: registro,
    );
    // 1. La scelta si DICHIARA, e l'esito e' come si dichiara.
    expect(esito, EsitoAttestazione.nonInstallataPerScelta);
    expect(Attestazione.ragioneDi(esito), isNotEmpty,
        reason: 'la ragione esiste e il pannello la mostra: senza, si '
            'tornerebbe a mentire per omissione');
    // 2. E il registro dei GUASTI resta pulito, perche' non e' successo niente
    //    di storto.
    expect(registro.haGuasti, isFalse,
        reason: 'una decisione presa apposta non e\' un guasto, e finche\' ci '
            'sta dentro il pannello dichiara rotta una voce che funziona');
  });

  test('Se l\'attestazione SOLLEVA, non si propaga e la voce resta viva',
      () async {
    final registro = RegistroDeiGuasti();
    final installatore = _InstallatoreCheSolleva();
    final esito = await Attestazione.installa(
      // Fuori dalla release si installa davvero, quindi qui il fornitore viene
      // chiamato e fallisce: e' il caso che il 2 agosto fermava ogni chiamata.
      releaseMode: false,
      installatore: installatore,
      registro: registro,
    );
    expect(installatore.chiamato, isTrue,
        reason: 'se il fornitore non viene chiamato la prova non percorre il '
            'ramo che deve misurare');
    expect(esito, EsitoAttestazione.fallita);
    expect(registro.haGuasti, isTrue);
    // E soprattutto: NON ha sollevato. Se `installa` rilanciasse, l'avvio
    // dell'app morirebbe qui e la chat non esisterebbe nemmeno.
  });

  test('Ogni esito ha una ragione, e nessuna e\' vuota', () {
    for (final esito in EsitoAttestazione.values) {
      expect(Attestazione.ragioneDi(esito).trim(), isNotEmpty,
          reason: 'il pannello mostra questa riga: senza, tace');
    }
    // La ragione della scelta porta la CONDIZIONE che la chiude.
    expect(
      Attestazione.ragioneDi(EsitoAttestazione.nonInstallataPerScelta),
      contains('Play Store'),
      reason: 'un compromesso senza la condizione che lo chiude non e\' un '
          'compromesso, e\' una resa',
    );
  });

  test('UN SOLO punto del progetto tocca FirebaseAppCheck.instance', () {
    // E' la ragione per cui "non installare" basta: il servizio si registra sul
    // FirebaseApp solo quando qualcuno tocca `instance`, e `firebase_ai` lo
    // cerca con `app.getService<FirebaseAppCheck>()`. Se un secondo punto lo
    // toccasse, il servizio si registrerebbe lo stesso e la correzione
    // sparirebbe senza che nessuno se ne accorga.
    final colpe = <String>[];
    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final percorso = file.path.replaceAll(r'\', '/');
      final righe = file
          .readAsLinesSync()
          .where((r) => !r.trimLeft().startsWith('//'))
          .join('\n');
      if (righe.contains('FirebaseAppCheck.instance')) {
        colpe.add(percorso);
      }
    }
    expect(colpe, ['lib/services/app_services.dart'],
        reason: 'chi tocca FirebaseAppCheck.instance registra il servizio, e '
            'da quel momento ogni chiamata dell\'AI torna a chiedere il token');
  });

  group('L\'intestazione del pannello segue l\'ultimo guasto VERO', () {
    Future<void> monta(
      WidgetTester tester, {
      required RegistroDeiGuasti guasti,
      required EsitoAttestazione attestazione,
    }) async {
      await tester.pumpWidget(MaterialApp(
        home: MaestroScope(
          maestro: Maestro.medora,
          child: Scaffold(
            body: SingleChildScrollView(
              child: PannelloDiMessaAPunto(
                aiReady: true,
                memoryPersistent: true,
                guasti: guasti,
                attestazione: attestazione,
                nota: null,
                appCheckDebugToken: null,
              ),
            ),
          ),
        ),
      ));
      await tester.pump();
    }

    testWidgets('Con la sola scelta dichiarata, la voce risulta ATTIVA',
        (tester) async {
      // E' cio' che il fondatore ha letto il 3 agosto 2026: "accesa ma in
      // guasto" con la voce che funzionava, perche' il registro portava la
      // decisione presa apposta.
      final registro = RegistroDeiGuasti();
      await Attestazione.installa(
        releaseMode: true,
        installatore: _InstallatoreCheNonVieneChiamato(),
        registro: registro,
      );
      await monta(tester,
          guasti: registro,
          attestazione: EsitoAttestazione.nonInstallataPerScelta);

      expect(find.text('attiva'), findsOneWidget);
      expect(find.text('accesa ma in guasto'), findsNothing,
          reason: 'la voce non è in guasto: nessuno ha registrato niente '
              'che sia andato storto');
      // E la scelta resta DICHIARATA, con la sua riga e la sua ragione: non si
      // e' passati dal mentire per eccesso al tacere.
      expect(find.text('non installata, per scelta'), findsOneWidget);
      expect(
          find.text(Attestazione.ragioneDi(
              EsitoAttestazione.nonInstallataPerScelta)),
          findsOneWidget);
    });

    testWidgets('Con un guasto VERO, l\'intestazione lo dice', (tester) async {
      // Il controllo negativo: senza, una prova che dice sempre "attiva"
      // resterebbe verde anche se l'intestazione smettesse di guardare.
      final registro = RegistroDeiGuasti()
        ..registra(
            operazione: 'rispondendo', errore: StateError('la voce tace'));
      await monta(tester,
          guasti: registro, attestazione: EsitoAttestazione.installata);

      expect(find.text('accesa ma in guasto'), findsOneWidget);
      expect(find.text('attiva'), findsNothing);
    });
  });
}

class _InstallatoreCheSolleva implements InstallatoreAttestazione {
  bool chiamato = false;

  @override
  Future<void> installa() async {
    chiamato = true;
    throw Exception(
        '[firebase_app_check/unknown] code: 403 body: App attestation failed.');
  }
}

class _InstallatoreCheNonVieneChiamato implements InstallatoreAttestazione {
  @override
  Future<void> installa() async {
    fail('non doveva essere chiamato: su questa build non si installa');
  }
}
