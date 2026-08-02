import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Nessun catch muto nuovo, in tutto `lib`.
///
/// Un `catch (_)` butta via l'errore prima che qualcuno possa leggerlo. Per due
/// giri di lavoro la chat dei Maestri ha taciuto e nessuno ha potuto sapere
/// perche': quattro `catch (_)` in `maestro_chat_controller.dart` trasformavano
/// l'eccezione vera, che diceva quale API mancava sul progetto Google, in
/// "Le stelle si sono velate un istante".
///
/// Questa prova NON guarda quei quattro punti: guarda tutta la cartella `lib`,
/// cosi' vale anche per i catch muti che nasceranno domani. Enumerare invece di
/// campionare e' l'unico modo perche' una regola sopravviva a chi non l'ha letta.
void main() {
  /// I file dove un catch muto non e' ammesso, punto.
  ///
  /// Sono la strada che porta alla voce dei Maestri: qui un errore inghiottito
  /// non e' un fastidio, e' la ragione per cui una voce tace senza spiegarsi.
  const Set<String> tolleranzaZero = {
    'lib/features/maestri/chat/maestro_chat_controller.dart',
    'lib/features/maestri/ask/ask_maestri_screen.dart',
    'lib/services/ai/firebase_maestro_ai_provider.dart',
    'lib/services/ai/voce_sorvegliata.dart',
    'lib/services/ai/registro_dei_guasti.dart',
    'lib/services/ai/maestro_oracle.dart',
    'lib/services/ai/maestro_persona.dart',
    'lib/services/app_services.dart',
  };

  /// Il debito preesistente, misurato il 2 agosto 2026, file per file.
  ///
  /// La ragione e' la stessa per tutte le voci e si dichiara una volta sola:
  /// sono catch muti nati prima di questa regola, in punti che non riguardano
  /// la voce dei Maestri. Non li correggo tutti in questo giro, perche' un
  /// ordine che tocca ottantacinque punti in una volta non si puo' verificare.
  /// Il numero puo' solo SCENDERE: se sale, la prova cade; se scende, la prova
  /// cade lo stesso e chiede di aggiornarlo, cosi' il debito non si riapre in
  /// silenzio dopo essere stato pagato.
  const Map<String, int> debitoDichiarato = {
    'lib/core/archetypes/archetype_history.dart': 2,
    'lib/core/astro/city_catalog.dart': 1,
    'lib/core/astro/natal_chart_controller.dart': 4,
    'lib/core/astro/sky_location.dart': 2,
    'lib/core/entitlement/question_allowance.dart': 2,
    'lib/core/face/face_history.dart': 2,
    'lib/core/identity/device_id.dart': 1,
    'lib/core/identity/profile_store.dart': 7,
    'lib/core/motion/parallax_controller.dart': 1,
    'lib/core/onboarding/onboarding_controller.dart': 3,
    'lib/core/rituals/ritual_streak.dart': 2,
    'lib/core/rituals/sunset_rune_memory.dart': 3,
    'lib/core/sensi/motore_audio.dart': 2,
    'lib/core/settings/settings_controller.dart': 2,
    'lib/features/account/profile_screen.dart': 1,
    'lib/features/debug/app_check_debug_view.dart': 1,
    'lib/features/horoscope/oroscopo_screen.dart': 1,
    'lib/features/identity/circle_seal_screen.dart': 1,
    'lib/features/intro/sequenza_intro.dart': 2,
    'lib/features/maestri/aura/face/face_constellation_screen.dart': 3,
    'lib/features/maestri/caligo/rune/rune_draw_screen.dart': 1,
    'lib/features/maestri/chat/maestro_chat_screen.dart': 1,
    'lib/features/rituals/breath_destiny_screen.dart': 5,
    'lib/features/rituals/dawn_rite_screen.dart': 3,
    'lib/features/rituals/ritual_view.dart': 1,
    'lib/features/rituals/sunset_rune_screen.dart': 4,
    'lib/features/santuario/greeting_controller.dart': 1,
    'lib/features/santuario/sky_overview_screen.dart': 5,
    'lib/features/settings/settings_screen.dart': 1,
    'lib/features/synastry/sinastria_vip_screen.dart': 2,
    'lib/features/synastry/user_photo.dart': 1,
    'lib/features/tarot/stesa_choreography.dart': 1,
    'lib/features/tarot/stesa_senses.dart': 2,
    'lib/features/tarot/stesa_tre_carte_screen.dart': 1,
    'lib/services/breath_detector.dart': 2,
    'lib/services/firebase/app_check_debug.dart': 1,
    'lib/services/free_astro_client.dart': 1,
  };

  test('nessun catch muto nuovo in lib', () {
    final radice = Directory('lib');
    expect(radice.existsSync(), isTrue,
        reason: 'la prova va eseguita dalla radice del progetto');

    final conteggi = <String, int>{};
    for (final file in radice
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final percorso = file.path.replaceAll(r'\', '/');
      final quanti = _catchMutiIn(file.readAsStringSync());
      if (quanti > 0) conteggi[percorso] = quanti;
    }

    final colpe = <String>[];

    // 1. La strada della voce: zero, senza sconti.
    for (final percorso in tolleranzaZero) {
      final quanti = conteggi[percorso] ?? 0;
      if (quanti > 0) {
        colpe.add('$percorso: $quanti catch muti, e qui non ne sono ammessi. '
            'E\' la strada che porta alla voce dei Maestri: un errore '
            'inghiottito qui e\' una voce che tace senza dire perche\'.');
      }
    }

    // 2. Tutto il resto: il debito puo' solo scendere.
    for (final voce in conteggi.entries) {
      if (tolleranzaZero.contains(voce.key)) continue;
      final atteso = debitoDichiarato[voce.key] ?? 0;
      if (voce.value > atteso) {
        colpe.add('${voce.key}: ${voce.value} catch muti contro i $atteso '
            'dichiarati. Un catch muto nuovo non entra: se serve davvero '
            'ignorare un errore, scrivi `catch (errore)` e dichiara perche\' '
            'lo ignori.');
      } else if (voce.value < atteso) {
        colpe.add('${voce.key}: ${voce.value} catch muti contro i $atteso '
            'dichiarati. Il debito e\' sceso: abbassa il numero in '
            'debitoDichiarato, altrimenti si riapre in silenzio.');
      }
    }

    // 3. Un file uscito del tutto dal debito va tolto dall'elenco.
    for (final voce in debitoDichiarato.entries) {
      if (!conteggi.containsKey(voce.key)) {
        colpe.add('${voce.key}: dichiarava ${voce.value} catch muti e non ne '
            'ha piu\'. Togli la voce da debitoDichiarato.');
      }
    }

    expect(colpe, isEmpty, reason: '\n${colpe.join('\n')}\n');
  });
}

/// Quanti `catch (_)` ci sono nel sorgente, IGNORANDO commenti e stringhe.
///
/// Senza questo passaggio la prova sarebbe cieca al contrario: i commenti che
/// spiegano la regola nominano `catch (_)`, e verrebbero contati come colpe.
/// La prima stesura di questa prova contava undici colpe che erano tutte
/// documentazione.
int _catchMutiIn(String sorgente) {
  final pulito = _senzaCommentiNeStringhe(sorgente);
  return RegExp(r'catch\s*\(\s*_\s*\)').allMatches(pulito).length;
}

String _senzaCommentiNeStringhe(String sorgente) {
  final buffer = StringBuffer();
  var i = 0;
  while (i < sorgente.length) {
    final resto = sorgente.length - i;
    // Commento di riga.
    if (resto >= 2 && sorgente[i] == '/' && sorgente[i + 1] == '/') {
      while (i < sorgente.length && sorgente[i] != '\n') {
        i++;
      }
      continue;
    }
    // Commento a blocco.
    if (resto >= 2 && sorgente[i] == '/' && sorgente[i + 1] == '*') {
      i += 2;
      while (i + 1 < sorgente.length &&
          !(sorgente[i] == '*' && sorgente[i + 1] == '/')) {
        i++;
      }
      i += 2;
      continue;
    }
    // Stringa, con apici singoli o doppi. Gli escape si saltano.
    if (sorgente[i] == '\'' || sorgente[i] == '"') {
      final apice = sorgente[i];
      i++;
      while (i < sorgente.length && sorgente[i] != apice) {
        if (sorgente[i] == r'\') i++;
        i++;
      }
      i++;
      continue;
    }
    buffer.write(sorgente[i]);
    i++;
  }
  return buffer.toString();
}
