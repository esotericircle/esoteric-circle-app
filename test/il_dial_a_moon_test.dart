// IL DIAL-A-MOON, ORA PER ORA, MA SENZA RETE NEI TEST. Ordine FX voce FX.03,
// 16 ottobre 2026.
//
// La guardia pretende, offline e deterministica (nessuna vera chiamata di
// rete: un client finto iniettato, come `IMazziScaricati`):
// - col fotogramma della NASA raggiungibile, l'immagine torna una
//   NetworkImage sull'indirizzo giusto (fotogramma, formato e misura);
// - col ripiego forzato (client finto che risponde sempre con un errore, o
//   un istante fuori dalla serie 2026), l'immagine torna una AssetImage
//   sulla luna locale piu' vicina per elongazione, la stessa che
//   `LeLuneDellaNasa.immaginePer` avrebbe scelto per quell'istante;
// - la rotazione di 180 gradi per l'emisfero sud si applica in entrambi i
//   casi, sempre dalla latitudine, mai dalla fonte della foto.

import 'package:esoteric_circle/core/lunario/il_dial_a_moon.dart';
import 'package:esoteric_circle/core/lunario/il_motore_lunare.dart';
import 'package:esoteric_circle/core/lunario/le_lune_della_nasa.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('il fotogramma e l\'indirizzo', () {
    test('il primo gennaio 2026 a mezzanotte e il fotogramma 1', () {
      expect(
        IlDialAMoon.fotogrammaPer(DateTime.utc(2026, 1, 1)),
        1,
      );
      expect(
        IlDialAMoon.indirizzoPer(DateTime.utc(2026, 1, 1)).toString(),
        'https://svs.gsfc.nasa.gov/vis/a000000/a005500/a005587/'
        'frames/730x730_1x1_30p/moon.0001.jpg',
      );
    });

    test('un istante del 2026 torna il fotogramma della sua ora esatta', () {
      // Lo stesso istante gia' annotato in le_lune_della_nasa.g.dart come
      // fotogramma 6797.
      final istante = DateTime.utc(2026, 10, 11, 4);
      expect(IlDialAMoon.fotogrammaPer(istante), 6797);
      expect(
        IlDialAMoon.indirizzoPer(istante).toString(),
        'https://svs.gsfc.nasa.gov/vis/a000000/a005500/a005587/'
        'frames/730x730_1x1_30p/moon.6797.jpg',
      );
    });

    test('fuori dal 2026 non c\'e\' nessun indirizzo verificato', () {
      expect(IlDialAMoon.fotogrammaPer(DateTime.utc(2025, 12, 31, 23)), null);
      expect(IlDialAMoon.fotogrammaPer(DateTime.utc(2027, 1, 1)), null);
      expect(IlDialAMoon.indirizzoPer(DateTime.utc(2027, 1, 1)), null);
    });
  });

  group('la NASA risponde', () {
    test('torna la NetworkImage sull\'indirizzo del fotogramma', () async {
      final istante = DateTime.utc(2026, 10, 11, 4);
      final client = MockClient((request) async {
        expect(
          request.url.toString(),
          IlDialAMoon.indirizzoPer(istante).toString(),
        );
        return http.Response('finta immagine', 200);
      });
      final dialAMoon = IlDialAMoon(client: client);

      final foto = await dialAMoon.perIstante(istante, latitudine: 45);

      expect(foto.daNasa, true);
      expect(foto.immagine, isA<NetworkImage>());
      expect(
        (foto.immagine as NetworkImage).url,
        IlDialAMoon.indirizzoPer(istante).toString(),
      );
      expect(foto.ruota, false); // emisfero nord
    });
  });

  group('il ripiego, senza rete', () {
    test('un errore del client ricade sulla luna locale piu\' vicina',
        () async {
      final istante = DateTime.utc(2026, 10, 11, 4);
      final client = MockClient((request) async {
        throw Exception('nessuna rete');
      });
      final dialAMoon = IlDialAMoon(client: client);

      final foto = await dialAMoon.perIstante(istante, latitudine: 10);

      final elongazione = IlMotoreLunare.elongazione(istante);
      final attesa = LeLuneDellaNasa.immaginePer(elongazione);
      expect(attesa, isNotNull);
      expect(foto.daNasa, false);
      expect(foto.immagine, isA<AssetImage>());
      expect((foto.immagine as AssetImage).assetName, attesa);
    });

    test('una risposta non 200 ricade sul ripiego', () async {
      final istante = DateTime.utc(2026, 6, 1, 12);
      final client = MockClient((request) async => http.Response('', 503));
      final dialAMoon = IlDialAMoon(client: client);

      final foto = await dialAMoon.perIstante(istante, latitudine: 10);

      expect(foto.daNasa, false);
      expect(foto.immagine, isA<AssetImage>());
    });

    test('un istante fuori dalla serie 2026 non chiama nemmeno il client',
        () async {
      var chiamate = 0;
      final client = MockClient((request) async {
        chiamate++;
        return http.Response('', 200);
      });
      final dialAMoon = IlDialAMoon(client: client);
      final istante = DateTime.utc(2027, 3, 1, 8);

      final foto = await dialAMoon.perIstante(istante, latitudine: -20);

      expect(chiamate, 0);
      expect(foto.daNasa, false);
      final elongazione = IlMotoreLunare.elongazione(istante);
      final attesa = LeLuneDellaNasa.immaginePer(elongazione);
      expect((foto.immagine as AssetImage).assetName, attesa);
    });

    test('nell\'emisfero sud la rotazione si applica anche al ripiego',
        () async {
      final client = MockClient((request) async => http.Response('', 503));
      final dialAMoon = IlDialAMoon(client: client);
      final istante = DateTime.utc(2026, 6, 1, 12);

      final foto = await dialAMoon.perIstante(istante, latitudine: -33.9);

      expect(foto.ruota, true);
      expect(LeLuneDellaNasa.ruotaPer(-33.9), true);
    });

    test('nell\'emisfero sud la rotazione si applica anche con la NASA',
        () async {
      final istante = DateTime.utc(2026, 10, 11, 4);
      final client = MockClient((request) async => http.Response('ok', 200));
      final dialAMoon = IlDialAMoon(client: client);

      final foto = await dialAMoon.perIstante(istante, latitudine: -33.9);

      expect(foto.daNasa, true);
      expect(foto.ruota, true);
    });
  });
}
