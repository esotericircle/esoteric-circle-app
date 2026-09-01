import 'dart:io';

import 'package:esoteric_circle/core/astro/city_catalog.dart';
import 'package:esoteric_circle/core/astro/luogo_attuale.dart';
import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/core/rituals/rito_alba.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL LUOGO ATTUALE CONTRO QUELLO DI NASCITA. Ordine P voce 23.
///
/// **Tre cose dentro una voce, e la terza pesa piu' delle altre due.** Il campo
/// del luogo attuale, la sua conservazione fra un avvio e l'altro, e il punto in
/// cui chiedere il permesso con garbo: senza la terza le prime due non servono a
/// niente, perche' nessuno arriva a riempire un campo che non gli viene mai
/// nominato.
///
/// **Una meta' della premessa era GIA' CADUTA, e va detto.** Il difetto
/// originale, coordinate dal luogo di NASCITA e scarto di fuso dall'orologio del
/// telefono, e' stato chiuso da un ordine precedente: `PosizioneDiStamattina`
/// garantisce per costruzione che le due cose vengano dalla stessa origine.
/// Restava il caso di gran lunga piu' frequente, che nessuno aveva chiuso: chi
/// non concede la posizione non ha nessun modo di dire dove vive, quindi non
/// vede mai l'ora del sorgere.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Il campo del luogo attuale', () {
    test('una citta\' scelta vale quanto il dispositivo per il sorgere', () {
      // La stima dal fuso non si dichiara mai; una citta' scelta si', ed e' la
      // riga che rende la fascia raggiungibile a chi dice no al permesso.
      const milano = LuogoAttuale(
          lat: 45.4642,
          lon: 9.19,
          citta: 'Milano',
          origine: OrigineDelLuogo.scelto);
      final conCitta = PosizioneDiStamattina.da(null, const Duration(hours: 2),
          dichiarato: milano);
      expect(conCitta.origine, OrigineDellAlba.dichiarata);
      expect(conCitta.oraDichiarabile, isTrue,
          reason: 'chi ha detto in che citta\' vive non deve sentirsi dire che '
              'l\'ora non si sa');
      expect(conCitta.lat, 45.4642);
      expect(conCitta.lon, 9.19);
    });

    test('il dispositivo viene PRIMA della citta\' dichiarata', () {
      // Chi e' in viaggio ha concesso la posizione: l'alba e' dove sei adesso,
      // non dove hai detto di vivere.
      const milano = LuogoAttuale(
          lat: 45.4642,
          lon: 9.19,
          citta: 'Milano',
          origine: OrigineDelLuogo.scelto);
      final posizione = PosizioneDiStamattina.da(
        const SkyPlace(latitude: -33.86, longitude: 151.2, citta: 'Sydney'),
        const Duration(hours: 10),
        dichiarato: milano,
      );
      expect(posizione.origine, OrigineDellAlba.dispositivo);
      expect(posizione.lat, -33.86);
    });

    test('senza niente resta la stima dal fuso, e NON si dichiara', () {
      final posizione =
          PosizioneDiStamattina.da(null, const Duration(hours: 2));
      expect(posizione.origine, OrigineDellAlba.stimataDalFuso);
      expect(posizione.oraDichiarabile, isFalse,
          reason: 'una longitudine dedotta dall\'offset puo\' sbagliare di '
              'mezz\'ora: un\'ora sbagliata detta come esatta e\' una promessa '
              'che non si mantiene');
    });
  });

  group('La conservazione fra un avvio e l\'altro', () {
    test('la citta\' scelta si ritrova al prossimo avvio', () async {
      // Senza questo la citta' andrebbe scelta ogni mattina, e nessuno la
      // sceglie due volte.
      expect(await DoveSonoAdesso.letto(), isNull);
      await DoveSonoAdesso.scrivi(const LuogoAttuale(
          lat: 45.4642,
          lon: 9.19,
          citta: 'Milano',
          origine: OrigineDelLuogo.scelto));
      final riletto = await DoveSonoAdesso.letto();
      expect(riletto, isNotNull);
      expect(riletto!.citta, 'Milano');
      expect(riletto.origine, OrigineDelLuogo.scelto);
      expect(riletto.lat, closeTo(45.4642, 1e-9));
    });

    test('anche il luogo del dispositivo si conserva, e dichiara di esserlo',
        () async {
      // Non e' un doppione del GPS: il servizio puo' essere spento e si puo'
      // essere in metropolitana. L'ultimo posto noto e' meglio di una stima dal
      // fuso, e la sua origine resta scritta perche' nessuno lo confonda con
      // una lettura fresca.
      await DoveSonoAdesso.scrivi(LuogoAttuale.dalDispositivo(
          const SkyPlace(latitude: 41.9, longitude: 12.5, citta: 'Roma')));
      final riletto = await DoveSonoAdesso.letto();
      expect(riletto!.origine, OrigineDelLuogo.dispositivo);
      expect(riletto.citta, 'Roma');
    });

    test('un luogo senza nome non inventa una citta\'', () async {
      final senzaNome = LuogoAttuale.dalDispositivo(
          const SkyPlace(latitude: 41.9, longitude: 12.5));
      expect(senzaNome.citta, 'dove sei adesso');
      expect(senzaNome.citta, isNotEmpty,
          reason: 'il nome si legge a schermo: vuoto sarebbe una riga muta');
    });

    test('un dato rotto non diventa un luogo', () {
      // Chi legge da un magazzino deve reggere un magazzino sporco.
      expect(LuogoAttuale.fromJson(const {'lat': 1.0}), isNull);
      expect(LuogoAttuale.fromJson(const {'lat': 1.0, 'lon': 2.0, 'nome': ''}),
          isNull);
    });
  });

  group('Il punto in cui si chiede, con garbo', () {
    test('la riga esiste e compare solo dove il rito sta tacendo', () {
      // Si legge il sorgente: la condizione di comparsa e' la ragione per cui
      // questa riga e' "con garbo" invece di essere una richiesta a tradimento.
      final alba = _sorgente('lib/features/rituals/dawn_rite_screen.dart');
      expect(alba, contains('DoveSeiAdesso('),
          reason: 'il punto in cui si chiede non c\'e\' piu\', quindi il campo '
              'del luogo attuale non lo riempira\' nessuno');
      expect(alba, contains('.oraDichiarabile'),
          reason: 'la riga non e\' piu\' legata al fatto che l\'ora non si '
              'possa dire: comparirebbe anche a chi ha gia\' dato tutto');
    });

    test('le due strade ci sono, e la seconda non chiede permessi', () {
      final riga = _sorgente('lib/features/rituals/dove_sei_adesso.dart');
      expect(riga, contains('dove_sei_permesso'));
      expect(riga, contains('dove_sei_scegli'));
      expect(riga, contains('CityCatalog.search'),
          reason: 'la seconda strada non passa dal catalogo delle citta\', '
              'quindi non e\' la stessa porta del resto dell\'app');
      // Il pre-avviso non usa il testo generico: dice l'unica cosa che questa
      // richiesta ottiene.
      expect(riga, contains('PermissionCopy('),
          reason: 'il permesso si chiede col testo generico, che parla di '
              'un\'altra cosa');
    });

    test('la seconda strada resta anche senza sensore', () {
      // `location.available` governa SOLO il primo pulsante: chi non ha il
      // sensore, o l\'ha negato per sempre, deve poter dire dove vive.
      final riga = _sorgente('lib/features/rituals/dove_sei_adesso.dart');
      final dopoIlPermesso = riga.substring(riga.indexOf('dove_sei_permesso'));
      expect(dopoIlPermesso, contains('dove_sei_scegli'),
          reason: 'la scelta della citta\' e\' finita dentro il ramo del '
              'sensore: chi non ce l\'ha resterebbe senza nessuna strada');
      expect(riga.indexOf('location.available'),
          lessThan(riga.indexOf('dove_sei_permesso')),
          reason: 'la disponibilita\' del sensore deve governare il solo primo '
              'pulsante');
    });
  });

  group('Il catalogo delle citta\' regge la scelta', () {
    test('cercando una citta\' nota si trova col suo punto', () {
      final trovate = CityCatalog.search('Milano');
      expect(trovate, isNotEmpty,
          reason: 'senza risultati la seconda strada non porta da nessuna '
              'parte');
      final milano = trovate.first;
      expect(milano.latitude, isNot(0));
      expect(milano.longitude, isNot(0));
      final luogo = LuogoAttuale.dallaCitta(milano);
      expect(luogo.origine, OrigineDelLuogo.scelto);
      expect(luogo.citta, milano.name);
    });
  });
}

String _sorgente(String percorso) => File(percorso).readAsStringSync();
