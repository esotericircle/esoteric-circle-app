import 'dart:io';

import 'package:esoteric_circle/core/diagnosi/briciole.dart';
import 'package:flutter_test/flutter_test.dart';

/// LE BRICIOLE SCRIVONO E SI RILEGGONO, attraverso due corse.
///
/// E' la sola garanzia che serve alla build diagnostica: una tappa lasciata
/// prima dell'uccisione si deve ritrovare alla corsa dopo. La scrittura e'
/// SINCRONA, perche' l'uccisione non aspetta una coda.
void main() {
  tearDown(Briciole.azzera);

  test('la tappa lasciata in una corsa si rilegge nella corsa dopo', () async {
    final cartella = Directory.systemTemp.createTempSync('briciole_prova');
    addTearDown(() => cartella.deleteSync(recursive: true));

    // Prima corsa: nessuna briciola precedente, si lascia una tappa.
    await Briciole.prepara(cartella: cartella);
    expect(Briciole.dellaCorsaPrecedente, isNull,
        reason: 'Alla prima corsa non deve esserci nessun racconto.');
    Briciole.lascia('risveglio_d_immagine_totem');

    // Seconda corsa: la tappa della prima si rilegge, con l'orario.
    Briciole.azzera();
    await Briciole.prepara(cartella: cartella);
    final racconto = Briciole.dellaCorsaPrecedente;
    expect(racconto, isNotNull,
        reason: 'La briciola della corsa precedente e\' andata persa: '
            'l\'uccisione resterebbe muta, che e\' il difetto da vedere.');
    expect(racconto, startsWith('risveglio_d_immagine_totem|'),
        reason: 'La briciola non porta la tappa lasciata.');
    expect(racconto!.split('|').length, 2,
        reason: 'La briciola non porta l\'orario accanto alla tappa.');
  });

  test('ogni tappa sovrascrive la precedente: sul disco vive solo l\'ultima',
      () async {
    final cartella = Directory.systemTemp.createTempSync('briciole_prova2');
    addTearDown(() => cartella.deleteSync(recursive: true));
    await Briciole.prepara(cartella: cartella);
    Briciole.lascia('main_avviato');
    Briciole.lascia('intro_montata');
    Briciole.azzera();
    await Briciole.prepara(cartella: cartella);
    expect(Briciole.dellaCorsaPrecedente, startsWith('intro_montata|'),
        reason: 'La briciola non e\' l\'ULTIMA tappa: se si accumulassero, '
            'il racconto direbbe la storia intera invece del punto di '
            'morte.');
  });

  test('senza prepara, lascia non tocca il disco: e\' il ramo delle prove',
      () {
    // Nessuna prepara: la chiamata non deve sollevare ne' scrivere altrove.
    Briciole.lascia('tappa_senza_casa');
    expect(Briciole.dellaCorsaPrecedente, isNull);
  });
}
