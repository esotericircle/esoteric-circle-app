import 'dart:async';
import 'dart:io';

import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/identity/account_del_cerchio.dart';
import 'package:esoteric_circle/core/rituals/custode_delle_push.dart';
import 'package:esoteric_circle/core/rituals/scelta_degli_avvisi.dart';
import 'package:esoteric_circle/features/push/custode_montato.dart';
import 'package:esoteric_circle/services/push/porta_delle_push.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LE PUSH SONO MONTATE. Ordine CI voce 07.
///
/// **Il fatto che ha aperto la voce, misurato e non supposto.**
/// `CustodeDellePush` esisteva col suo corpo e le sue prove, e **nessuno lo
/// montava**: cercato in tutto `lib`, l'unico posto che lo nominava era il
/// file che lo dichiara. Le notifiche push non potevano arrivare nemmeno a
/// funzioni distribuite, perche' il dispositivo non registrava mai il proprio
/// recapito.
///
/// **Ed e' il tipo di difetto che nessuna prova vedeva**: tutte le prove del
/// custode lo costruivano a mano, quindi funzionava benissimo, provato, e non
/// serviva a nessuno. Una classe con le sue prove verdi che non e' agganciata
/// a niente e' il caso peggiore, perche' sembra fatta.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('il custode e\' montato nell\'app, e non solo dichiarato', () {
    final app = File('lib/app.dart').readAsStringSync();
    expect(app.contains('CustodeDellePush('), isTrue,
        reason: 'nessuno costruisce piu\' il custode delle push: il recapito '
            'del dispositivo non arriva al server e le notifiche non possono '
            'partire');
    expect(app.contains('CustodeMontato('), isTrue,
        reason: 'il custode e\' costruito ma nessuno lo fa vivere: costruirlo '
            'registra il recapito una volta e non lo rinnova, non lo '
            'risincronizza e non lo toglie all\'uscita');
    expect(app.contains('RecapitoVero()'), isTrue,
        reason: 'l\'app monta il custode con un recapito finto: nessun token '
            'vero raggiungerebbe il server');
  });

  testWidgets(
      'il recapito si registra, e si rinnova quando il sistema lo '
      'cambia', (tester) async {
    final porta = _PortaContata();
    final custode = CustodeDellePush(porta: porta);
    final recapito = _RecapitoFinto('primo-token');
    // Registrata oggi: dentro il mese di prova, quindi il diritto c'e'.
    await tester
        .pumpWidget(_scena(custode, recapito, registratoIl: DateTime.now()));
    // **SI ASPETTA DAVVERO**, e non solo si pompano fotogrammi: la
    // registrazione del recapito passa da SharedPreferences, cioe' da un
    // canale di piattaforma, e `pumpAndSettle` fa girare i fotogrammi ma non
    // aspetta le attese vere. Senza `runAsync` questa prova misurerebbe uno
    // stato che non e' ancora arrivato.
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();

    expect(custode.token, 'primo-token',
        reason: 'il recapito non e\' stato chiesto al sistema');
    expect(porta.mandate, greaterThan(0),
        reason: 'il recapito non e\' salito al server');

    // **IL TOKEN CHE SCADE, la parte che tutti dimenticano.**
    recapito.cambia('token-rigenerato');
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();
    expect(custode.token, 'token-rigenerato',
        reason: 'il sistema ha rigenerato il recapito e il custode ha tenuto '
            'quello vecchio: il server spingerebbe verso un indirizzo morto e '
            'la persona smetterebbe di ricevere le push senza accorgersene');
  });

  testWidgets('senza diritto il recapito NON resta sul server', (tester) async {
    final porta = _PortaContata();
    final custode = CustodeDellePush(porta: porta);
    await tester.pumpWidget(_scena(
      custode,
      _RecapitoFinto('un-token'),
      // Viandante, e nessuna registrazione: nessun diritto, nemmeno di prova.
      registratoIl: null,
    ));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();
    expect(porta.tolte, greaterThan(0),
        reason: 'chi non ha diritto alle push lascia il suo recapito sul '
            'server, e il giro notturno continua a spingergli le notifiche '
            'pagandole');
    expect(porta.mandate, 0,
        reason: 'sono state mandate scelte per chi non ha diritto');
  });
}

Widget _scena(
  CustodeDellePush custode,
  RecapitoDelDispositivo recapito, {
  DateTime? registratoIl,
}) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CustodeDellePush>.value(value: custode),
        ChangeNotifierProvider(create: (_) => SceltaDegliAvvisi()..carica()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(
          create: (_) => AccountDelCerchio(porta: _IdentitaFinta(registratoIl)),
        ),
      ],
      child: CustodeMontato(
        recapito: recapito,
        fuso: 'Europe/Rome',
        child: const SizedBox.shrink(),
      ),
    );

class _PortaContata extends PortaDelleScelte {
  int mandate = 0;
  int tolte = 0;

  @override
  Future<bool> manda(ScelteDaMandare scelte) async {
    mandate++;
    return true;
  }

  @override
  Future<bool> togli() async {
    tolte++;
    return true;
  }
}

class _RecapitoFinto extends RecapitoDelDispositivo {
  _RecapitoFinto(this._token);

  final String _token;
  final _cambi = <void Function(String)>[];

  void cambia(String nuovo) {
    for (final c in List.of(_cambi)) {
      c(nuovo);
    }
  }

  @override
  Future<String?> adesso() async => _token;

  @override
  Stream<String> quandoCambia() {
    final controllore = StreamController<String>.broadcast();
    _cambi.add(controllore.add);
    return controllore.stream;
  }
}

/// **SI APPOGGIA A `IdentitaAssente` invece di reimplementare l'interfaccia
/// intera.** Quella porta esiste gia' in `lib` e risponde a tutto senza
/// fingere niente: qui si cambia solo cio' che questa prova misura, cioe' la
/// data di nascita dell'account e la presenza di un uid. Riscrivere venti
/// membri a mano vorrebbe dire che al prossimo membro nuovo questa prova cade
/// per un motivo che non c'entra con cio' che prova.
class _IdentitaFinta extends IdentitaAssente {
  const _IdentitaFinta(this._natoIl);

  final DateTime? _natoIl;

  @override
  DateTime? get natoIl => _natoIl;

  @override
  String? get uid => 'uid-finto';

  @override
  bool get anonimo => _natoIl == null;
}
