import 'dart:io';

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/il_filo_del_consulto.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/il_segno_dell_animale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **IL FILO ARRIVA A OGNI STRADA, E LA FRASE RIPRESA SI TROVA IN TUTTO IL
/// CONSULTO. Ordine FE voci 08 e 11.**
///
/// Le due enumerazioni dell'ordine
/// (docs/collaudo/FE/fe08_le_strade_verso_un_maestro.md e
/// fe11_le_frasi_suggerite.md) hanno trovato sette strade che non usavano la
/// memoria del consulto, e otto punti dove una frase del Maestro tornava al
/// Maestro come una domanda nuova, perche' la frase si cercava nella sola
/// ultima risposta. Qui si misurano le due cure.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    IlFiloDelConsulto.dimentica();
  });

  String sorgente(String percorso) => File(percorso).readAsStringSync();

  group('FE.11, la frase ripresa', () {
    test('si trova in una risposta che non e\' l\'ultima', () {
      final storia = [
        const ChatMessage(role: ChatRole.user, text: 'Devo cambiare lavoro?'),
        const ChatMessage(
            role: ChatRole.maestro,
            text: 'Il cielo ti chiede pazienza. Scrivi la lettera di '
                'presentazione prima della fine del mese.'),
        const ChatMessage(role: ChatRole.user, text: 'E in amore?'),
        const ChatMessage(
            role: ChatRole.maestro, text: 'Venere ti chiede ascolto.'),
      ];
      final frase = LaFraseRipresa.fraTutte(
          'Come scrivo la lettera di presentazione prima della fine del mese?',
          LaFraseRipresa.testiDelConsulto(storia));
      expect(frase, contains('lettera di presentazione'),
          reason: 'la frase della penultima risposta non si riconosce. IL '
              'ROSSO SI DIMOSTRA cercando nella sola ultima risposta');
    });

    test('si trova nel seguito di "Vai piu\' a fondo"', () {
      final storia = [
        const ChatMessage(
            role: ChatRole.maestro,
            text: 'Il Carro chiede decisione.',
            seguito: 'Domani mattina parla con il tuo responsabile del '
                'progetto nuovo, prima della riunione.'),
      ];
      expect(
          LaFraseRipresa.fraTutte(
              'Come parlo con il responsabile del progetto nuovo prima della '
              'riunione?',
              LaFraseRipresa.testiDelConsulto(storia)),
          isNotNull,
          reason: 'il seguito non entra fra le frasi del consulto');
    });

    test('si trova nelle frasi che il filo ricorda: benvenuto, invito, Parlane',
        () {
      IlFiloDelConsulto.ricordaLaFrase(
          'La Luna di stasera ti chiede di scrivere tre desideri sul quaderno.');
      expect(
          LaFraseRipresa.fraTutte('Quali desideri scrivo stasera sul quaderno?',
              LaFraseRipresa.testiDelConsulto(const [])),
          isNotNull,
          reason: 'una frase che il Maestro ha messo davanti alla persona '
              'fuori dalla storia non si riconosce');
      IlFiloDelConsulto.chiudi();
      expect(IlFiloDelConsulto.frasiDelConsulto, isEmpty,
          reason: 'Nuova chat chiude il consulto: le frasi vanno via con lui');
    });

    test('ogni risposta annotata entra fra le frasi del consulto', () {
      IlFiloDelConsulto.annota(
          maestro: Maestro.medora,
          domanda: 'Devo partire?',
          risposta: 'Parti a fine mese, quando Mercurio torna diretto.');
      expect(IlFiloDelConsulto.frasiDelConsulto,
          contains('Parti a fine mese, quando Mercurio torna diretto.'));
    });

    test('i punti dove la frase nasce la ricordano davvero', () {
      for (final (percorso, pezzo) in const [
        (
          'lib/design_system/components/riga_del_consiglio.dart',
          'IlFiloDelConsulto.ricordaLaFrase(riga)'
        ),
        (
          'lib/features/maestri/chat/maestro_chat_screen.dart',
          'IlFiloDelConsulto.ricordaLaFrase(benvenuto)'
        ),
        (
          'lib/features/ricordi/azioni_del_responso.dart',
          'IlFiloDelConsulto.ricordaLaFrase(widget.responso.testo)'
        ),
        (
          'lib/features/maestri/chat/maestro_chat_controller.dart',
          'IlFiloDelConsulto.ricordaLaFrase(nascosto)'
        ),
        (
          'lib/features/maestri/chat/maestro_chat_controller.dart',
          'IlFiloDelConsulto.ricordaLaFrase(pulito)'
        ),
      ]) {
        expect(sorgente(percorso), contains(pezzo),
            reason: '$percorso non ricorda piu\' la frase che mette davanti '
                'alla persona');
      }
    });
  });

  group('FE.08, le strade collegate al filo', () {
    test('il segno dell\'animale guida entra nel filo come parere di Calìgo',
        () async {
      final lupo = AnimalCatalog.animals.firstWhere((a) => a.name == 'Lupo');
      final segno = await GestiDelSegno.chiedi(
          animale: lupo,
          domanda: 'Devo fidarmi del mio socio?',
          giorno: DateTime(2026, 10, 6),
          prendiUnaChiamata: () async => false);
      final scheda = IlFiloDelConsulto.scheda;
      expect(scheda, isNotNull, reason: 'il segno non ha aperto il consulto');
      expect(scheda!.pareri.single.maestro, Maestro.caligo);
      expect(IlFiloDelConsulto.frasiDelConsulto, contains(segno.riga));
    });

    test('il filo entra nelle istruzioni fuori dal provider', () {
      expect(IlFiloDelConsulto.conIlFilo('ISTRUZIONE', Maestro.medora, 'x'),
          'ISTRUZIONE',
          reason: 'senza consulto l\'istruzione deve restare la stessa');
      IlFiloDelConsulto.annota(
          maestro: Maestro.caligo,
          domanda: 'Devo cambiare casa?',
          risposta: 'Cambiala prima dell\'inverno.');
      expect(
          IlFiloDelConsulto.conIlFilo(
              'ISTRUZIONE', Maestro.medora, 'Devo cambiare casa?'),
          allOf(startsWith('ISTRUZIONE'),
              contains('${Maestro.caligo.displayName} ha detto')),
          reason: 'la stesa di Medora non riceve il parere di Calìgo');
    });

    test('ogni strada collegata legge il filo e ci scrive', () {
      final provider =
          sorgente('lib/services/ai/firebase_maestro_ai_provider.dart');
      final presagio = provider
          .substring(provider.indexOf('Future<Responso> presagioDelleRune('));
      expect(presagio, contains('filo: IlFiloDelConsulto.bloccoPer('),
          reason: 'il presagio delle Rune non legge il filo');
      expect(presagio, contains('IlFiloDelConsulto.annota('),
          reason: 'il presagio delle Rune non scrive nel filo');
      final consult =
          provider.substring(provider.indexOf('Future<MaestroReply> consult('));
      expect(
          consult.substring(0, 2500), contains('fraseRipresa: LaFraseRipresa'),
          reason: 'il Consiglio non riconosce la frase ripresa');
      final stesa = sorgente('lib/core/tarot/la_lettura_dal_modello.dart');
      expect(stesa, contains('IlFiloDelConsulto.conIlFilo('),
          reason: 'la stesa col modello non legge il filo');
      expect(stesa, contains('IlFiloDelConsulto.annota('),
          reason: 'la stesa col modello non scrive nel filo');
      final controllore =
          sorgente('lib/features/maestri/chat/maestro_chat_controller.dart');
      expect(
          controllore,
          contains(
              'history: [..._filoDiPrima, ..._messages.sublist(0, indice), prima]'),
          reason: 'il seguito non riceve il filo di prima');
    });
  });
}
