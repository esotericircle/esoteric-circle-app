import 'dart:io';

import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/registro_degli_eos.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/dimenticanza_del_telefono.dart';
import 'package:esoteric_circle/core/identity/dimenticanza_della_memoria_viva.dart';
import 'package:esoteric_circle/core/identity/identity_controller.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/core/rituals/scelta_degli_avvisi.dart';
import 'package:esoteric_circle/core/sigilli/coda_delle_feste.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// CANCELLARE DIMENTICA TUTTO, ANCHE CIO' CHE STA IN MEMORIA.
/// Ordine BC voce 02.
///
/// **Il fatto del fondatore**: "ho provato a cancellare l'account, ma i dati
/// restano. Se uno cancella l'account, tutti i dati devono essere cancellati,
/// mentre il borsellino, i traguardi e altri dati attualmente restano anche
/// dopo la conferma della cancellazione."
///
/// **LA CAUSA NON ERA QUELLA SCRITTA NELL'ORDINE**, e si dichiara. L'ordine
/// diceva che la cancellazione "esegue solo `memory.deleteAllData()`": non e'
/// piu' vero dalla build 2195, perche' l'ordine AZ voce 08 le aveva gia'
/// aggiunto la dimenticanza del disco e l'uscita.
///
/// **Il buco era un terzo posto, che nessuno guardava**: i controller vivono
/// per tutta la sessione dell'app, e nessuno li svuotava. Quello che il
/// fondatore vedeva a schermo era la memoria, non il disco; e alla prima
/// scrittura quella memoria tornava anche sul disco appena pulito.
///
/// **E c'era una mezza cura che serviva a un'altra cosa**: l'ordine AZ voce 15
/// aveva scritto `_dimenticaLaMemoriaViva` dentro la schermata dell'account,
/// che svuotava **due controller su undici**, ed era chiamata solo
/// dall'uscita e mai dalla cancellazione. Uscire puliva piu' che cancellare.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('BC.02: dimenticare svuota tutti gli undici che tengono dati',
      (tester) async {
    SharedPreferences.setMockInitialValues(const {});

    final borsa = QuestionAllowance();
    final diario = DiarioDelCammino();
    await diario.carica();
    final feste = CodaDelleFeste();
    final eos = RegistroDegliEos();
    final zodiaco = ZodiacController();
    final piano = EntitlementService();
    final identita = IdentityController();
    final avvisi = SceltaDegliAvvisi();
    await avvisi.carica();
    final carta = NatalChartController();

    // **SI RIEMPIONO PRIMA**, se no una dimenticanza che non fa niente
    // sembrerebbe funzionare: e' lo stesso inciampo della misura sui pixel
    // dell'ordine BA, dove contare zero su zero dava zero.
    identita.setName('Sofia');
    zodiaco.setSunSign(Zodiac.leo);
    piano.setTier(Tier.tier2);
    await avvisi.scegli(DailyElement.night, true);
    expect(identita.name, 'Sofia');
    expect(avvisi.chiama(DailyElement.night), isTrue);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<QuestionAllowance>.value(value: borsa),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
        ChangeNotifierProvider<CodaDelleFeste>.value(value: feste),
        ChangeNotifierProvider<RegistroDegliEos>.value(value: eos),
        ChangeNotifierProvider<ZodiacController>.value(value: zodiaco),
        ChangeNotifierProvider<EntitlementService>.value(value: piano),
        ChangeNotifierProvider<IdentityController>.value(value: identita),
        ChangeNotifierProvider<SceltaDegliAvvisi>.value(value: avvisi),
        ChangeNotifierProvider<NatalChartController>.value(value: carta),
      ],
      child: const MaterialApp(home: SizedBox(key: Key('albero'))),
    ));

    // **LA DIMENTICANZA SI CHIAMA DOPO IL PRIMO FOTOGRAMMA, non dentro il
    // build.** Ogni controller che si svuota avvisa chi lo ascolta, e
    // avvisare mentre l albero si sta costruendo fa cadere Flutter con
    // "setState called during build": la prima stesura di questa prova lo
    // faceva, e le nove eccezioni che ne uscivano nascondevano la misura.
    final quanti = DimenticanzaDellaMemoriaViva.dimentica(
        tester.element(find.byKey(const Key('albero'))));
    await tester.pump();

    // ignore: avoid_print
    print('ORDINE BC VOCE 02: dei provider montati ne sono stati dimenticati '
        '$quanti');
    expect(quanti, greaterThanOrEqualTo(9),
        reason: 'ne sono stati dimenticati solo $quanti: qualcuno non ha un '
            'modo di svuotarsi, e i suoi dati restano a schermo dopo la '
            'cancellazione');

    // **E SI GUARDA CHE SIANO DAVVERO VUOTI**, non che il metodo sia stato
    // chiamato: sono due cose diverse, e la seconda non prova la prima.
    expect(identita.name, isEmpty,
        reason: 'il nome resta: i Maestri saluterebbero col nome di un altro');
    expect(zodiaco.sunSign, isNull, reason: 'il segno resta');
    expect(piano.tier, Tier.free, reason: 'il piano resta');
    expect(avvisi.chiama(DailyElement.night), isFalse,
        reason: 'le sveglie di chi se n e andato restano accese sul telefono '
            'di chi arriva dopo');
    expect(diario.accesi, isEmpty, reason: 'i traguardi restano');
    expect(feste.inAttesa, isEmpty, reason: 'le feste in coda restano');
    expect(eos.ultimi, isEmpty, reason: 'i movimenti degli Eos restano');
  });

  test('BC.02: e TUTTE E TRE le vie che congedano la chiamano', () {
    // **ERA QUESTO IL DIFETTO.** La dimenticanza della memoria esisteva e
    // stava dentro l'uscita: cancellare l'account puliva MENO che uscire.
    //
    // **Contare le occorrenze non basta piu', e non e' un dettaglio.** Con le
    // quattro voci dell'ordine BC le vie che congedano sono TRE: uscire,
    // azzerare i dati tenendo l'account, e chiedere l'oblio. Un conto che
    // dicesse "tre" resterebbe verde anche se una funzione la chiamasse due
    // volte e un'altra nessuna: si guarda **dentro ciascuna**.
    final schermata = File('lib/features/account/account_screen.dart')
        .readAsStringSync();
    final mute = <String>[];
    for (final via in const [
      '_chiediDiUscire',
      '_azzeraIDati',
      '_chiediLOblio',
    ]) {
      final da = schermata.indexOf('Future<void> $via(BuildContext');
      expect(da, greaterThan(0), reason: 'la via "$via" non esiste piu');
      var a = schermata.indexOf('\nFuture<void> ', da + 1);
      if (a < 0) a = schermata.indexOf('\nclass ', da + 1);
      if (a < 0) a = schermata.length;
      final corpo = schermata.substring(da, a);
      if (!corpo.contains('DimenticanzaDellaMemoriaViva.dimentica')) {
        mute.add(via);
      }
    }
    // ignore: avoid_print
    print('ORDINE BC VOCE 02: le vie che congedano sono tre, e quelle che non '
        'dimenticano la memoria sono ${mute.length}');
    expect(mute, isEmpty,
        reason: 'queste vie congedano qualcuno e gli lasciano i dati a '
            'schermo: $mute');
  });

  test('BC.02: l elenco dei provider e completo, contato su app.dart', () {
    // **LA GUARDIA CHE VALE PIU' DI TUTTE.** Un elenco scritto a mano
    // invecchia al primo controller nuovo, e quel controller sara' proprio
    // quello che tiene il dato che nessuno voleva lasciare in giro. Qui i
    // provider si contano dove sono dichiarati davvero.
    final app = File('lib/app.dart').readAsStringSync();
    final porta =
        File('lib/core/identity/dimenticanza_della_memoria_viva.dart')
            .readAsStringSync();
    final dichiarati = RegExp(r'=> ([A-Z][A-Za-z]+)\(\)')
        .allMatches(app)
        .map((m) => m.group(1)!)
        .toSet();
    final scoperti = <String>[];
    for (final c in dichiarati) {
      if (DimenticanzaDellaMemoriaViva.impersonali.contains(c)) continue;
      if (porta.contains('read<$c>')) continue;
      scoperti.add(c);
    }
    // ignore: avoid_print
    print('ORDINE BC VOCE 02: provider dichiarati in app.dart '
        '${dichiarati.length}, impersonali '
        '${DimenticanzaDellaMemoriaViva.impersonali.length}, scoperti '
        '${scoperti.length}${scoperti.isEmpty ? "" : ": $scoperti"}');
    expect(dichiarati.length, greaterThanOrEqualTo(12),
        reason: 'l enumerazione ha perso i provider: ne ha trovati '
            '${dichiarati.length}');
    expect(scoperti, isEmpty,
        reason: 'questi controller tengono dati di una persona e nessuno li '
            'svuota quando se ne va: $scoperti. O si aggiungono alla porta, o '
            'si dichiarano impersonali con la ragione');
  });

  test('BC.02: e le chiavi del disco restano coperte per prefisso', () {
    // La dimenticanza del disco esisteva gia' dall'ordine AZ voce 08 e
    // funziona: si guarda solo che i prefissi non si siano assottigliati.
    for (final atteso in const [
      'account.',
      'allowance.',
      'borsellino.',
      'cammino.',
      'profile.',
      'rituale.',
      'sigilli.',
    ]) {
      expect(DimenticanzaDelTelefono.prefissiDaDimenticare, contains(atteso),
          reason: 'il prefisso "$atteso" non e piu fra quelli dimenticati');
    }
    // ignore: avoid_print
    print('ORDINE BC VOCE 02: i prefissi dimenticati sono '
        '${DimenticanzaDelTelefono.prefissiDaDimenticare.length}, quelli '
        'tenuti ${DimenticanzaDelTelefono.prefissiCheRestano}');
  });
}
