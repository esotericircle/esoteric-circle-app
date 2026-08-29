import 'dart:io';

import 'package:esoteric_circle/core/legal/privacy_policy.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA PRIVACY POLICY DICE IL VERO, E RESTA AGGANCIATA AL CODICE.
/// Ordine BH voce 07. La policy non e' una pagina qualunque: ogni sua
/// affermazione forte ha un'ancora nel codice, e se il codice cambia la
/// prova cade prima che la pagina diventi una bugia pubblicata.
void main() {
  test('la policy esiste, con la data e il titolare', () {
    expect(sezioniDellaPolicy.length, greaterThanOrEqualTo(9),
        reason: 'la policy ha perso delle sezioni');
    expect(dataDellaPolicy, isNotEmpty);
    expect(titolareDellaPolicy, contains('info@esotericircle.com'));
  });

  test('le affermazioni forti hanno l\'ancora nel codice', () {
    final tutto = sezioniDellaPolicy.map((s) => '${s.titolo} ${s.corpo}').join(' ');
    final server = File('functions/src/cerchio.ts').readAsStringSync();

    // 1. L'impronta antifrode: la policy la dichiara e il server la fa.
    expect(tutto.contains('SHA-256'), isTrue,
        reason: 'la policy non dichiara piu\' l\'impronta antifrode');
    expect(server.contains('createHash("sha256")'), isTrue,
        reason: 'il server non usa piu\' l\'impronta che la policy dichiara');

    // 2. La cancellazione immediata: nessun periodo di attesa.
    expect(tutto.contains('immediata'), isTrue);
    // La lapide storica nei commenti nomina chiediLOblio apposta: si
    // guarda l'export, non la parola.
    expect(server.contains('export const chiediLOblio'), isFalse,
        reason: 'e\' tornata una cancellazione ad attesa che la policy '
            'non racconta');

    // 3. La regione europea: la policy la promette e le opzioni la fissano.
    expect(tutto.contains('europe-west1'), isTrue);
    expect(server.contains('region: "europe-west1"'), isTrue);

    // 4. Il congedo anonimo: promesso e mantenuto (la guardia del menu
    // controlla che il congedo non porti l'uid).
    expect(tutto.contains('anonima'), isTrue);
  });

  test('i tempi scritti nella policy sono quelli che il codice usa', () {
    // **UNA POLICY CHE PROMETTE UN TEMPO DIVERSO DA QUELLO CHE IL CODICE FA
    // E' UNA BUGIA PUBBLICATA.** Ordine CB voce 05. Qui non si controlla che
    // la frase esista: si prende ogni numero dal listino delle scadenze e si
    // pretende che la pagina lo dica.
    final tutto =
        sezioniDellaPolicy.map((s) => '${s.titolo} ${s.corpo}').join(' ');
    final server = File('functions/src/scadenze.ts').readAsStringSync();
    final telefono =
        File('lib/core/identity/scadenze_del_telefono.dart').readAsStringSync();

    // I giorni dichiarati nel listino del server, categoria per categoria.
    final giorni = <String, int>{};
    for (final m in RegExp(r'(\w+): \{\s*nome:[^}]*?giorni: (\d+)',
            multiLine: true, dotAll: true)
        .allMatches(server)) {
      giorni[m.group(1)!] = int.parse(m.group(2)!);
    }
    // ignore: avoid_print
    print('ORDINE CB VOCE 05: scadenze del server $giorni');
    expect(giorni.length, greaterThanOrEqualTo(5),
        reason: 'il listino delle scadenze del server non si legge piu\'');

    // Come si dice quel numero a una persona: mesi se e' un multiplo tondo.
    String aParole(int g) => g == 30
        ? '30 giorni'
        : g == 365
            ? '12 mesi'
            : g == 730
                ? '24 mesi'
                : '$g giorni';

    final mute = <String>[];
    for (final voce in giorni.entries) {
      if (!tutto.contains(aParole(voce.value))) {
        mute.add('${voce.key} (${aParole(voce.value)})');
      }
    }
    // E i due tempi del telefono, che sono scritti nell'altro listino.
    for (final m in RegExp(r'giorni: (\d+)').allMatches(telefono)) {
      final quanto = aParole(int.parse(m.group(1)!));
      if (!tutto.contains(quanto)) mute.add('telefono ($quanto)');
    }
    expect(mute, isEmpty,
        reason: 'la policy non dice questi tempi, che il codice invece '
            'applica: $mute');
  });

  test('la pagina monta la policy e il sottomenu la apre', () {
    final schermo = File('lib/features/account/privacy_policy_screen.dart')
        .readAsStringSync();
    expect(schermo.contains('sezioniDellaPolicy'), isTrue,
        reason: 'la pagina non monta piu\' il testo di casa');
    final menu = File('lib/features/account/account_screen.dart')
        .readAsStringSync();
    expect(menu.contains('PrivacyPolicyScreen.route()'), isTrue,
        reason: 'dal sottomenu non si apre piu\' la policy');
  });
}
