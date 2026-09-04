import 'package:esoteric_circle/core/astro/prossimi_eventi.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/cio_che_arriva.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **I MAESTRI SANNO COSA ARRIVA.** Ordine CQ voce 2.15, 4 settembre 2026.
///
/// **La regola 8 del fondatore**, dal manifesto dell'ordine CP: i Maestri
/// devono sapere i traguardi e gli eventi in arrivo. Il motore delle date
/// esisteva da tre ordini, `ProssimiEventi`, con un orizzonte di
/// quattrocento giorni, e lo usavano il Calendario e la barra dell'identita':
/// **il ponte verso il contesto delle chat no.** Chiedere a Medora "cosa mi
/// aspetta" otteneva una risposta che delle date vere non sapeva niente.
///
/// **Cosa si misura, e su cio' che il modello riceve davvero.** Non che la
/// classe del ponte esista: che il blocco compaia dentro l'istruzione di
/// sistema, che nomini un evento vero e il prossimo passo del Cammino, e che
/// **non compaia affatto** quando non c'e' niente da dire.
void main() {
  final profilo = UserProfile(displayName: 'Mauro');

  String istruzione(NatalContext natal) => MaestroPersona.systemInstruction(
        maestro: Maestro.medora,
        profile: profilo,
        memory: MaestroMemory.empty,
        natal: natal,
      );

  test('il blocco entra nell istruzione di sistema, con un evento vero', () {
    final natal = const NatalContext(sunSign: 'Leone');
    final testo = istruzione(natal);
    final eventi = ProssimiEventi.da(adesso: DateTime.now(), segno: Zodiac.leo);
    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.15: eventi calcolati per il Leone '
        '${eventi.length}, il blocco compare nell istruzione '
        '${testo.contains("CIO' CHE ARRIVA")}');
    cardinaleMinimo(eventi.length, 1,
        cosa: 'eventi in arrivo calcolati per un segno',
        perche: 'Con nessun evento il blocco sarebbe vuoto per assenza, e la '
            'prova direbbe che il ponte non c e mentre e il cielo a tacere.');
    expect(testo.contains("CIO' CHE ARRIVA"), isTrue,
        reason: 'l istruzione di sistema non porta il blocco di cio che '
            'arriva: il ponte esiste e nessuno lo attraversa');
    expect(testo.contains('Non promettere nessun esito'), isTrue,
        reason: 'il blocco non vieta la promessa: un modello che riceve una '
            'data accanto a un esito li lega da solo');
  });

  test('e nomina il prossimo passo del Cammino quando c e', () {
    final testo = istruzione(const NatalContext(
      sunSign: 'Leone',
      prossimoTraguardo: 'La tua carta e nata',
      cosaApreIlProssimoTraguardo: 'La lettura della tua carta natale',
    ));
    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.15: il Cammino compare nell istruzione '
        '${testo.contains("La tua carta e nata")}');
    expect(testo.contains('La tua carta e nata'), isTrue,
        reason: 'il prossimo passo del Cammino non arriva al Maestro: la '
            'meta personale della regola 8 resta scoperta');
    // La prima lettera scende a minuscola perche' la riga la incastona in una
    // frase: "e apre la lettura...". Si guarda il resto, che e il contenuto.
    expect(testo.contains('lettura della tua carta natale'), isTrue,
        reason: 'il Maestro sa il nome del gradino e non cosa apre, quindi '
            'non puo dire perche vale la pena');
  });

  test('e senza niente da dire il blocco NON compare', () {
    // **UN TITOLO VUOTO INSEGNA AL MODELLO CHE VA RIEMPITO**, ed e' il modo
    // piu' rapido di farsi inventare un evento. Senza segno non si calcola
    // nessun evento, e senza Cammino non c e nessun gradino: l intestazione
    // non deve comparire.
    final testo = istruzione(NatalContext.none);
    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.15: senza dati il blocco compare '
        '${testo.contains("CIO' CHE ARRIVA")}');
    expect(testo.contains("CIO' CHE ARRIVA"), isFalse,
        reason: 'senza niente da dire l istruzione porta comunque il titolo '
            'del blocco, e un titolo vuoto e un invito a inventare');
  });

  test('il ponte non versa un elenco: al massimo tre eventi', () {
    final tanti = [
      for (var i = 0; i < 12; i++)
        EventoInArrivo(
            evento: 'evento_$i',
            quando: DateTime(2026, 1, 1).add(Duration(days: i)),
            fraQuantiGiorni: i,
            personale: false),
    ];
    final blocco = CioCheArriva.blocco(eventi: tanti);
    final righe =
        blocco.split(String.fromCharCode(10)).where((r) => r.startsWith('- '));
    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.15: con dodici eventi il blocco ne porta '
        '${righe.length}, il tetto dichiarato e ${CioCheArriva.quantiEventi}');
    expect(righe.length, CioCheArriva.quantiEventi,
        reason: 'il blocco versa ${righe.length} righe: un elenco lungo dentro '
            'un istruzione di sistema diventa rumore che il modello ripete');
  });
}
