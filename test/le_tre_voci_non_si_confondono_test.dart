import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/voce_del_maestro.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter_test/flutter_test.dart';

/// LE TRE VOCI NON SI CONFONDONO. Ordine BP.
///
/// **Il fatto che ha generato l'ordine, misurato e non stimato:** l'attribuzione
/// cieca sta al 75,6 per cento di media su cinque giri contro una soglia di 85,
/// il massimo mai raggiunto e' 81,7, Aura non viene mai scambiata in cinque giri
/// su cinque e Caligo oscilla fra il 30 e il 60 per cento finendo dentro Aura.
///
/// **La causa:** il giudizio cieco pone domande NEUTRE, quindi la materia dei
/// tre non entra in gioco e restano soltanto registro e lessico. L'istruzione
/// dava a ciascuno il PROPRIO lessico di firma senza vietargli quello degli
/// altri due.
///
/// **Queste prove camminano su `Maestro.values` e non su un elenco copiato**, e
/// leggono le intestazioni dalle costanti che il prompt usa davvero: un Maestro
/// nuovo entrerebbe da solo, e un titolo cambiato non lascerebbe la prova a
/// cercare una stringa che nessuno scrive piu'.
void main() {
  /// Il blocco del prompt che comincia col titolo dichiarato e finisce alla
  /// prima riga vuota. Si estrae, non si indovina.
  String bloccoVietato(Maestro maestro) {
    final voce = MaestroPersona.voceDi(maestro);
    final inizio = voce.indexOf(VoceDelMaestro.titoloDelLessicoVietato);
    expect(inizio, greaterThanOrEqualTo(0),
        reason: 'la persona di ${maestro.id} non porta il titolo '
            '"${VoceDelMaestro.titoloDelLessicoVietato}": il divieto dei '
            'lessici non arriva al modello, quindi non esiste');
    final resto = voce.substring(inizio);
    final fine = resto.indexOf('\n\n');
    return fine < 0 ? resto : resto.substring(0, fine);
  }

  group('BP.01, il divieto incrociato dei lessici', () {
    test('Ogni Maestro riceve le dieci parole degli altri due come vietate',
        () {
      var osservati = 0;
      for (final maestro in Maestro.values) {
        final altrui = VoceDelMaestro.lessicoDegliAltri(maestro);
        expect(altrui, hasLength(10),
            reason: 'gli altri due Maestri portano ${altrui.length} parole di '
                'firma invece di dieci: o una voce ne ha perse, o i Maestri '
                'non sono piu\' tre');
        final blocco = bloccoVietato(maestro);
        for (final parola in altrui) {
          expect(blocco.toLowerCase(), contains(parola.toLowerCase()),
              reason: 'a ${maestro.id} non e\' vietata "$parola", che e\' '
                  'firma di un altro Maestro: e finche\' non gliela vieti '
                  'nulla gli impedisce di usarla');
        }
        osservati++;
      }
      // ignore: avoid_print
      print('ORDINE BP VOCE 1: Maestri con il divieto incrociato $osservati');
      expect(osservati, Maestro.values.length);
    });

    test('Nessuno si vede vietare una parola propria', () {
      // Il verso opposto, e conta quanto l'altro: un divieto che comprende le
      // parole del Maestro stesso gli toglierebbe la firma invece di
      // difendergliela, cioe' farebbe esattamente il danno che deve impedire.
      for (final maestro in Maestro.values) {
        final blocco = bloccoVietato(maestro).toLowerCase();
        for (final mia in VoceDelMaestro.di(maestro).lessicoDiFirma) {
          expect(blocco.contains(mia.toLowerCase()), isFalse,
              reason: 'a ${maestro.id} viene vietata "$mia", che e\' una '
                  'parola SUA: il divieto gli sta togliendo la firma');
        }
      }
    });

    test('L\'elenco vietato si ricava dagli altri, non e\' scritto a mano', () {
      // La prova che il divieto segua una parola di firma quando cambia. Non si
      // puo' modificare il dato costante a runtime, quindi si verifica la
      // proprieta' che lo garantisce: ogni parola vietata a un Maestro e' la
      // firma DICHIARATA di un altro, e la somma delle firme altrui e'
      // esattamente l'elenco vietato, senza aggiunte e senza mancanze.
      for (final maestro in Maestro.values) {
        final attese = <String>{
          for (final altro in Maestro.values)
            if (altro != maestro)
              ...VoceDelMaestro.di(altro).lessicoDiFirma,
        };
        expect(VoceDelMaestro.lessicoDegliAltri(maestro).toSet(), attese,
            reason: 'l\'elenco vietato a ${maestro.id} non coincide con le '
                'firme degli altri due: qualcuno lo ha scritto a mano');
      }
    });
  });
}
