import 'package:esoteric_circle/core/sensi/catalogo_musiche.dart';
import 'package:esoteric_circle/features/shell/quale_musica_suona.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dart:io';

import 'codice_senza_testo.dart';

/// **LA MUSICA NON SUONA SOTTO L'INTRO, E PARTE QUANDO L'INTRO FINISCE.**
/// Ordine CO voce 01, 3 settembre 2026.
///
/// Nasce da un difetto che era verde e leggibile. L'ordine CN aveva messo
/// nella mappa delle schermate una riga per `SequenzaIntro`, che dichiarava
/// silenzio. Sensata a leggerla, e **morta**: quella mappa si interroga col
/// nome della schermata in cima alla pila del Navigator, e l'intro non e' una
/// schermata della pila, e' un velo che avvolge il Navigator intero. Il nome
/// non ci arrivava mai. Sul telefono del fondatore lo Shaman partiva insieme
/// alla voce del principio, due suoni sopra la stessa apertura.
///
/// **Percio' questa guardia guarda due cose diverse**, e la seconda e' quella
/// che il difetto di CN.03 avrebbe presa: non basta che la decisione sia
/// giusta, deve anche essere COLLEGATA a chi la prende. Una regola giusta che
/// nessuno alza e nessuno ascolta e' esattamente quel che c'era prima.
void main() {
  group('la decisione', () {
    tearDown(() => veloCheZittisce.value = false);

    test('col velo alzato tace anche la schermata che vuole una traccia', () {
      veloCheZittisce.value = false;
      expect(cosaSuonaSu('OnboardingScreen', null).cosa,
          CosaSuonaQui.unaTraccia,
          reason: 'senza velo il Risveglio deve portare lo Shaman: se gia' 
              ' qui tace, la prova che segue non dimostrerebbe niente');

      veloCheZittisce.value = true;
      final voce = cosaSuonaSu('OnboardingScreen', null);
      expect(voce.cosa, CosaSuonaQui.silenzio,
          reason: 'mentre l\u0027intro copre lo schermo, la schermata di sotto '
              'non e\u0027 la cosa che si sta guardando, e la sua traccia non '
              'e\u0027 la cosa che si deve ascoltare');
      expect(voce.traccia, isNull);
    });

    test('il velo vince anche su un Maestro che dichiara', () {
      veloCheZittisce.value = true;
      expect(cosaSuonaSu('DomainScreen', null).cosa, CosaSuonaQui.silenzio);
    });

    test('caduto il velo, lo Shaman torna senza che nulla venga spinto', () {
      veloCheZittisce.value = true;
      expect(cosaSuonaSu('SantuarioScreen', null).cosa, CosaSuonaQui.silenzio);
      veloCheZittisce.value = false;
      expect(cosaSuonaSu('SantuarioScreen', null).traccia,
          MusicaDelCerchio.home);
    });
  });

  group('il collegamento, che e\u0027 la parte che mancava', () {
    test('l\u0027intro alza il velo e lo lascia cadere alla dissolvenza', () {
      final codice = codiceSenzaTesto(
          File('lib/features/intro/sequenza_intro.dart').readAsStringSync());
      expect(codice, contains('veloCheZittisce.value = true'),
          reason: 'nessuno alza il velo: la regola del silenzio sotto '
              'l\u0027intro esiste e non la applica nessuno, che e\u0027 '
              'esattamente il difetto della voce CN.03');
      expect(codice.split('veloCheZittisce.value = false').length - 1,
          greaterThanOrEqualTo(2),
          reason: 'il velo non cade, o cade da un posto solo: deve cadere alla '
              'fine dell\u0027intro E allo smontaggio, altrimenti una strada '
              'che non passa dalla fine lascia l\u0027app muta per sempre');
    });

    test('il custode si sveglia quando il velo cade', () {
      final codice = codiceSenzaTesto(
          File('lib/features/shell/custode_della_musica.dart').readAsStringSync());
      expect(codice, contains('veloCheZittisce.addListener'),
          reason: 'il custode ascolta solo la pila delle rotte, ma quando '
              'l\u0027intro finisce NESSUNA rotta viene spinta: resterebbe '
              'fermo davanti a un velo caduto, in silenzio, fino al primo '
              'tocco della persona');
      expect(codice, contains('veloCheZittisce.removeListener'),
          reason: 'chi si mette in ascolto si toglie, o la prova lascia dietro '
              'di se\u0027 un ascoltatore su un notificatore statico');
    });

    test('la riga morta di CN.03 non e\u0027 tornata', () {
      final codice =
          File('lib/features/shell/quale_musica_suona.dart')
              .readAsStringSync();
      expect(codice, isNot(contains("'SequenzaIntro':")),
          reason: 'la mappa si interroga col nome della schermata in cima alla '
              'pila, e l\u0027intro non e\u0027 una schermata della pila: '
              'quella riga non puo\u0027 valere niente, e sembrare vera e\u0027 '
              'il suo unico effetto');
    });
  });
}
