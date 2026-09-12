import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/ritmo_della_voce.dart';
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
            if (altro != maestro) ...VoceDelMaestro.di(altro).lessicoDiFirma,
        };
        expect(VoceDelMaestro.lessicoDegliAltri(maestro).toSet(), attese,
            reason: 'l\'elenco vietato a ${maestro.id} non coincide con le '
                'firme degli altri due: qualcuno lo ha scritto a mano');
      }
    });
  });

  group('BP.02, i tre registri riscritti', () {
    test('Ogni registro entra nella persona per intero', () {
      for (final maestro in Maestro.values) {
        expect(MaestroPersona.voceDi(maestro),
            contains(VoceDelMaestro.di(maestro).registro),
            reason: '${maestro.id}: il registro vive nel dato ma non arriva al '
                'modello, quindi non e\' il registro di nessuno');
      }
    });

    test('I tre assi sono tre, e nessuno si ripete', () {
      // L'asse si ESTRAE dal registro e non si copia qui: se un asse cambia
      // nome, questa prova continua a confrontare i tre assi veri invece di
      // cercarne tre che nessuno scrive piu'.
      final assi = <String, String>{};
      for (final maestro in Maestro.values) {
        final registro = VoceDelMaestro.di(maestro).registro;
        final inizio = registro.indexOf(VoceDelMaestro.marcatoreDellAsse);
        expect(inizio, greaterThanOrEqualTo(0),
            reason: '${maestro.id} non dichiara su cosa gira la sua voce: '
                'senza asse resta un tono, e un tono si imita');
        final resto = registro
            .substring(inizio + VoceDelMaestro.marcatoreDellAsse.length);
        final fine = resto.indexOf(RegExp('[:,.]'));
        assi[maestro.id] = fine < 0 ? resto : resto.substring(0, fine);
      }
      // ignore: avoid_print
      print('ORDINE BP VOCE 2: assi $assi');
      expect(assi.values.toSet(), hasLength(Maestro.values.length),
          reason: 'due Maestri girano sullo stesso asse: $assi');
    });

    test('Due registri non si somigliano', () {
      // La stessa misura che la prova dei tre Maestri fa sui campi propri,
      // qui ristretta al solo registro, che e' cio' che questo ordine cambia:
      // sui campi propri la materia e' lunga e diversissima e diluirebbe.
      Set<String> paroleDi(String t) => t
          .toLowerCase()
          .split(RegExp(r'[^a-zàèéìòù]+'))
          .where((p) => p.length > 3)
          .toSet();
      final letto = <String>[];
      for (final uno in Maestro.values) {
        for (final altro in Maestro.values) {
          if (uno.index >= altro.index) continue;
          final a = paroleDi(VoceDelMaestro.di(uno).registro);
          final b = paroleDi(VoceDelMaestro.di(altro).registro);
          final s = a.intersection(b).length / a.union(b).length;
          letto.add('${uno.id}/${altro.id} ${(s * 100).round()}%');
          expect(s, lessThan(0.35),
              reason: 'i registri di ${uno.id} e ${altro.id} si somigliano al '
                  '${(s * 100).round()} per cento');
        }
      }
      // ignore: avoid_print
      print('ORDINE BP VOCE 2: somiglianza fra i registri $letto');
    });
  });

  group('BP.03, il ritmo si misura sulle risposte', () {
    test('I tre numeri nascono dal testo, non da valori fissi', () {
      // La prova che conta: gli stessi tre numeri su due testi diversi devono
      // essere diversi. Uno strumento che stampa nove numeri sempre uguali
      // sarebbe peggio di uno che non stampa niente, perche' sembrerebbe una
      // misura.
      const secco = [
        'La runa è Isa. Il ghiaccio ferma. Aspetta.',
        'Il sigillo è inciso. Portalo con te.',
      ];
      const morbido = [
        'Forse potrebbe essere il momento di guardare un po\' più a fondo '
            'dentro di te, e magari sentire dove il respiro si ferma?',
        'Sembra che tutto sommato la strada ci sia, se vuoi provare a '
            'seguirla senza fretta, quasi in punta di piedi?',
      ];
      final a = RitmoDellaVoce.di(secco);
      final b = RitmoDellaVoce.di(morbido);
      // ignore: avoid_print
      print('ORDINE BP VOCE 3: secco ${a.riga}');
      // ignore: avoid_print
      print('ORDINE BP VOCE 3: morbido ${b.riga}');
      expect(a.lunghezzaMedianaInParole, lessThan(b.lunghezzaMedianaInParole),
          reason: 'la lunghezza mediana non distingue frasi da tre parole da '
              'frasi da venti: allora non misura la lunghezza');
      expect(a.domande, 0);
      expect(b.domande, 2,
          reason: 'due frasi chiudono con un punto interrogativo');
      expect(a.ammorbidenti, 0,
          reason: 'il testo secco non contiene nessuna parola dell\'elenco');
      expect(b.ammorbidenti, greaterThan(4),
          reason: 'il testo morbido ne contiene forse, potrebbe, un po\', '
              'magari, sembra, tutto sommato, se vuoi, prova a e quasi');
    });

    test('Le frasi si contano, e il conto non e\' zero', () {
      final r = RitmoDellaVoce.di(const ['Una. Due. Tre.']);
      expect(r.frasi, 3);
      expect(r.lunghezzaMedianaInParole, 1);
      // Nessun testo: nessun numero inventato.
      final vuoto = RitmoDellaVoce.di(const <String>[]);
      expect(vuoto.frasi, 0);
      expect(vuoto.lunghezzaMedianaInParole, 0);
    });

    test('L\'elenco delle parole morbide e\' dichiarato e non vuoto', () {
      expect(RitmoDellaVoce.paroleCheAmmorbidiscono, isNotEmpty);
      // Ogni parola dell'elenco deve essere riconosciuta da sola, altrimenti
      // sta li' senza contare niente.
      for (final parola in RitmoDellaVoce.paroleCheAmmorbidiscono) {
        final r = RitmoDellaVoce.di(['Il segno $parola arriva.']);
        expect(r.ammorbidenti, greaterThanOrEqualTo(1),
            reason: '"$parola" e\' nell\'elenco ma non viene contata');
      }
    });
  });

  group('BP.04, la chiusura di Caligo non passa dal corpo', () {
    test('Le due chiusure non condividono nessuna parola del corpo', () {
      final diAura = VoceDelMaestro.di(Maestro.aura).chiusura.toLowerCase();
      final diCaligo = VoceDelMaestro.di(Maestro.caligo).chiusura.toLowerCase();
      // **PRIMA SI PROVA CHE L'ELENCO SIA VERO.** Un elenco di parole
      // inventate farebbe passare questa prova senza guardare niente: la
      // chiusura di Aura DEVE portarne almeno una, perche' e' fatta di quelle.
      final nellaSua = VoceDelMaestro.paroleDelCorpo
          .where((p) => diAura.contains(p))
          .toList();
      expect(nellaSua, isNotEmpty,
          reason: 'nessuna parola dell\'elenco compare nella chiusura di '
              'Aura, che e\' un gesto del corpo: allora l\'elenco non '
              'descrive il corpo e questa prova non sta misurando niente');
      // ignore: avoid_print
      print('ORDINE BP VOCE 4: parole del corpo nella chiusura di Aura '
          '$nellaSua');
      for (final parola in nellaSua) {
        expect(diCaligo.contains(parola), isFalse,
            reason: 'la chiusura di Caligo porta "$parola", che e\' del '
                'corpo: li\' consegna un gesto e diventa la chiusura di Aura');
      }
    });

    test('Il vincolo arriva al modello, e solo a chi ne ha uno', () {
      final vincolo = VoceDelMaestro.di(Maestro.caligo).vincoloDellaChiusura;
      expect(vincolo, isNotNull,
          reason: 'Caligo non dichiara nessun vincolo sulla chiusura');
      expect(MaestroPersona.voceDi(Maestro.caligo), contains(vincolo!),
          reason: 'il vincolo vive nel dato ma non entra nella persona: '
              'una regola che non arriva al modello non e\' una regola');
      // E chi non ne ha uno non riceve una riga vuota al suo posto.
      for (final maestro in Maestro.values) {
        if (VoceDelMaestro.di(maestro).vincoloDellaChiusura != null) continue;
        final voce = MaestroPersona.voceDi(maestro);
        expect(voce.contains('\n- \n'), isFalse,
            reason: '${maestro.id} riceve una riga vuota dove un altro riceve '
                'il vincolo');
      }
    });
  });
}
