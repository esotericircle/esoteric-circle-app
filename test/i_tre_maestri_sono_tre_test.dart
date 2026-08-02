import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/frase_di_ripiego.dart';
import 'package:esoteric_circle/core/maestro/maestro_welcome.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/core/maestro/voce_del_maestro.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter_test/flutter_test.dart';

/// I tre Maestri sono TRE, e lo si prova senza chiamare l'AI.
///
/// Le personalita' vivevano in tre blocchi di prosa dentro una funzione privata:
/// leggibili, non interrogabili. Nessuno si era accorto che Caligo rivendicava
/// gli Archetipi, che sono un'arte di Aura, e nessuna prova poteva accorgersene
/// perche' non c'era niente da chiamare.
///
/// Adesso la voce e' un dato, e questa prova enumera i tre. Vale anche per un
/// quarto Maestro che nascesse domani: non nomina Medora, Aura ne' Caligo, cammina
/// su `Maestro.values`.
void main() {
  /// Le parole di una stringa, minuscole e senza punteggiatura.
  Set<String> paroleDi(String testo) => testo
      .toLowerCase()
      .split(RegExp(r'[^a-zàèéìòù]+'))
      .where((p) => p.length > 3)
      .toSet();

  /// Quanto due testi si somigliano, da 0 a 1. Si misura sulla VOCE, non
  /// sull'istruzione intera: le regole comuni sono identiche per tutti e tre e
  /// diluirebbero la misura fino a farla passare sempre.
  double somiglianza(String a, String b) {
    final pa = paroleDi(a);
    final pb = paroleDi(b);
    if (pa.isEmpty || pb.isEmpty) return 0;
    final comuni = pa.intersection(pb).length;
    return comuni / pa.union(pb).length;
  }

  /// I campi che il Maestro dichiara di se stesso. NON comprendono l'elenco di
  /// cio' che non dice: li' i domini altrui compaiono apposta, come confine.
  List<String> campiPropri(VoceDelMaestro v) => [
        v.timbro,
        v.registro,
        v.materia,
        ...v.lessicoDiFirma,
        v.apertura,
        v.chiusura,
      ];

  test('Nessuna delle tre voci ha un campo vuoto', () {
    for (final maestro in Maestro.values) {
      final v = VoceDelMaestro.di(maestro);
      for (final campo in campiPropri(v)) {
        expect(campo.trim(), isNotEmpty,
            reason: 'un campo vuoto in ${maestro.id}');
      }
      expect(v.lessicoDiFirma, isNotEmpty, reason: '${maestro.id} senza firma');
      expect(v.maiDice, isNotEmpty,
          reason: '${maestro.id} non dichiara cosa non dice');
      expect(VoceDelMaestro.artiDi(maestro).length, 3,
          reason: 'ogni Maestro ha TRE arti, e vengono da Maestro.domainArts');
    }
  });

  test('Due voci non sono mai uguali ne\' quasi', () {
    // Si misura sui campi DICHIARATI, non sulla prosa composta: le intestazioni,
    // il divieto delle promesse e la chiave di lettura sono uguali per tutti e
    // tre per costruzione, e gonfierebbero ogni somiglianza di una ventina di
    // punti facendo passare anche due voci davvero gemelle.
    for (final uno in Maestro.values) {
      for (final altro in Maestro.values) {
        if (uno.index >= altro.index) continue;
        final s = somiglianza(
          campiPropri(VoceDelMaestro.di(uno)).join(' '),
          campiPropri(VoceDelMaestro.di(altro)).join(' '),
        );
        expect(s, lessThan(0.35),
            reason: 'le voci di ${uno.id} e ${altro.id} si somigliano al '
                '${(s * 100).round()} per cento: un lettore non le '
                'distinguerebbe senza il nome');
      }
    }
  });

  test('Nessun Maestro rivendica un\'arte di un altro', () {
    for (final maestro in Maestro.values) {
      final proprio = campiPropri(VoceDelMaestro.di(maestro))
          .join(' ')
          .toLowerCase();
      for (final arte in VoceDelMaestro.artiDegliAltri(maestro)) {
        expect(proprio.contains(arte.toLowerCase()), isFalse,
            reason: '${maestro.id} nomina "$arte", che e\' arte di un altro '
                'Maestro. Il confine si dichiara in maiDice, non nel proprio '
                'dominio.');
      }
      // E le sue TRE arti devono comparire nell'istruzione composta, altrimenti
      // il Maestro non sa cosa gli appartiene.
      final istruzione = MaestroPersona.voceDi(maestro).toLowerCase();
      for (final arte in VoceDelMaestro.artiDi(maestro)) {
        expect(istruzione.contains(arte.toLowerCase()), isTrue,
            reason: '${maestro.id} non dichiara la sua arte "$arte"');
      }
    }
  });

  test('Il lessico di firma e\' davvero di uno solo', () {
    for (final maestro in Maestro.values) {
      final mio = VoceDelMaestro.di(maestro).lessicoDiFirma;
      // 1. Nessuna parola di firma sta fra cio' che lo stesso Maestro non dice.
      final nonDico = VoceDelMaestro.di(maestro).maiDice.join(' ').toLowerCase();
      for (final parola in mio) {
        expect(nonDico.contains(parola.toLowerCase()), isFalse,
            reason: '${maestro.id} usa "$parola" come firma e insieme la '
                'dichiara fra cio\' che non dice');
      }
      // 2. Nessun altro Maestro usa quella parola nei campi propri.
      for (final altro in Maestro.values) {
        if (altro == maestro) continue;
        final suoi = campiPropri(VoceDelMaestro.di(altro)).join(' ').toLowerCase();
        for (final parola in mio) {
          expect(suoi.contains(parola.toLowerCase()), isFalse,
              reason: '"$parola" e\' la firma di ${maestro.id} ma compare '
                  'anche in ${altro.id}: allora non e\' una firma');
        }
      }
    }
  });

  test('Nessuna promessa vietata entra nella voce di un Maestro', () {
    for (final maestro in Maestro.values) {
      final proprio =
          campiPropri(VoceDelMaestro.di(maestro)).join(' ').toLowerCase();
      for (final promessa in VoceDelMaestro.promesseVietate) {
        expect(proprio.contains(promessa.toLowerCase()), isFalse,
            reason: '${maestro.id} promette "$promessa" nel proprio dominio');
      }
      // La promessa vietata deve comparire UNA volta sola, nel divieto.
      expect(
        MaestroPersona.voceDi(maestro),
        contains('Nessuna promessa di'),
        reason: '${maestro.id} non porta il divieto dentro la persona: '
            'filtrare a valle taglia la frase, non impedisce la promessa',
      );
    }
  });

  test('Le voci rispettano le regole di lingua, prompt compresi', () {
    // La regola vale anche per cio' che la persona non legge: un prompt che
    // scrive "Profondita'" con l'apostrofo insegna al modello a scrivere cosi'.
    final virgolaE = RegExp(r',\s+ed?\b', caseSensitive: false);
    // Apostrofo usato come accento. Si ENUMERANO le parole accentate della
    // lingua invece di cercare una forma generica: una regola generica
    // colpirebbe le troncature legittime, "po'" e "di'", e la prima stesura di
    // questa prova cadeva proprio su quelle.
    final parolePerdute = [
      'perche', 'poiche', 'benche', 'affinche', 'finche', 'nonche',
      'piu', 'gia', 'cosi', 'puo', 'cio', 'li',
      'sara', 'fara', 'dara', 'potra', 'verra', 'andra',
      'verita', 'citta', 'liberta', 'qualita', 'quantita', 'meta',
      'profondita', 'volonta', 'entita', 'polarita', 'realta', 'novita',
      'identita', 'possibilita', 'responsabilita', 'eta', 'meta',
    ];
    final apostrofoPerAccento = RegExp(
      '\\b(${parolePerdute.join('|')})\'',
      caseSensitive: false,
    );

    for (final maestro in Maestro.values) {
      final testo = MaestroPersona.voceDi(maestro);
      expect(virgolaE.hasMatch(testo), isFalse,
          reason: 'virgola davanti a "e" nella voce di ${maestro.id}, vicino a '
              '"${virgolaE.firstMatch(testo)?.group(0)}"');
      final apice = apostrofoPerAccento.firstMatch(testo);
      expect(apice, isNull,
          reason: 'apostrofo al posto dell\'accento nella voce di '
              '${maestro.id}: "${apice?.group(0)}". Vale anche nei prompt.');
      expect(testo.contains('—'), isFalse,
          reason: 'trattino lungo nella voce di ${maestro.id}');
    }
  });

  group('Nessuna risposta comincia come le altre', () {
    // I temi su cui si interroga l'oracolo deterministico. Non sono inventati
    // per la prova: sono il genere di domanda con cui una persona arriva.
    const temi = [
      'ho paura di sbagliare',
      'oggi mi sento fermo',
      'cosa mi manca',
      'non so se restare',
      'mi sento solo',
      'ho perso la direzione',
      'sono stanco di aspettare',
      'non mi fido di me',
    ];

    test('Il corpus deterministico non usa nessuna apertura vietata', () {
      const oracolo = MaestroOracle();
      final colpe = <String>[];

      // 1. Le tre lenti dell'oracolo su ogni tema, tutti e tre gli strati.
      for (final tema in temi) {
        final consulto =
            oracolo.consult(theme: tema, maestri: Maestro.values.toList());
        for (final lente in consulto.lenses) {
          final strati = <String, String>{
            'colpo d occhio': lente.glance,
            'lettura': lente.reading,
            'invito': lente.invite,
          };
          for (final voce in strati.entries) {
            final vietata = VoceDelMaestro.aperturaVietataDi(voce.value);
            if (vietata != null) {
              colpe.add('oracolo ${lente.maestro.id}, ${voce.key}, tema '
                  '"$tema": comincia con "$vietata"');
            }
          }
        }
      }

      // 2. Le frasi di ripiego dei tre Maestri, che una persona legge nel
      //    momento peggiore, cioe' quando la voce non arriva.
      for (final maestro in Maestro.values) {
        final ripieghi = <String, String>{
          'silenzio': RipiegoDelMaestro.silenzioDi(maestro),
          'non configurato': RipiegoDelMaestro.nonConfiguratoDi(maestro),
        };
        for (final voce in ripieghi.entries) {
          final vietata = VoceDelMaestro.aperturaVietataDi(voce.value);
          if (vietata != null) {
            colpe.add('ripiego ${maestro.id}, ${voce.key}: '
                'comincia con "$vietata"');
          }
        }
      }

      // 3. Le aperture del benvenuto.
      for (final apertura in MaestroWelcome.openings) {
        final vietata = VoceDelMaestro.aperturaVietataDi(apertura);
        if (vietata != null) {
          colpe.add('benvenuto: "$apertura" comincia con "$vietata"');
        }
      }

      expect(colpe, isEmpty, reason: '\n${colpe.join('\n')}\n');
    });

    test('Il controllo riconosce davvero un apertura vietata', () {
      // Senza questa, la prova qui sopra passerebbe anche con un controllo che
      // non guarda niente, ed e' un modo di sbagliare abbastanza comune da
      // meritare una riga di codice.
      for (final vietata in VoceDelMaestro.apertureVietate) {
        expect(VoceDelMaestro.aperturaVietataDi('$vietata, ascolta il cielo.'),
            vietata);
      }
      expect(VoceDelMaestro.aperturaVietataDi('Il cielo si è coperto.'), isNull);
    });

    test('Il divieto entra nella persona di tutti e tre', () {
      for (final maestro in Maestro.values) {
        final voce = MaestroPersona.voceDi(maestro);
        for (final vietata in VoceDelMaestro.apertureVietate) {
          expect(voce.contains('"$vietata"'), isTrue,
              reason: '${maestro.id} non porta il divieto su "$vietata": '
                  'un elenco che non arriva al modello non e un divieto');
        }
      }
    });
  });

  group('Ogni Maestro chiude a modo suo', () {
    test('I tre tipi di chiusura sono tre, e nessuno si ripete', () {
      final tipi = <TipoDiChiusura>{};
      for (final maestro in Maestro.values) {
        tipi.add(VoceDelMaestro.di(maestro).tipoDiChiusura);
      }
      expect(tipi.length, Maestro.values.length,
          reason: 'due Maestri che chiudono allo stesso modo non hanno due '
              'impronte, ne hanno una sola');
    });

    test('Ogni Maestro ha il tipo giusto per la sua materia', () {
      // Chi legge il tempo e' uno solo, e cosi' chi consegna un simbolo.
      const atteso = {
        Maestro.medora: TipoDiChiusura.direzioneNelTempo,
        Maestro.aura: TipoDiChiusura.gestoDelCorpo,
        Maestro.caligo: TipoDiChiusura.simboloDaPortare,
      };
      for (final maestro in Maestro.values) {
        expect(VoceDelMaestro.di(maestro).tipoDiChiusura, atteso[maestro],
            reason: 'la chiusura di ${maestro.id} non e la sua impronta');
      }
    });

    test('La chiusura arriva al modello, ed e obbligatoria', () {
      for (final maestro in Maestro.values) {
        final voce = MaestroPersona.voceDi(maestro);
        expect(voce.contains(VoceDelMaestro.di(maestro).chiusura), isTrue,
            reason: '${maestro.id}: la chiusura dichiarata non entra nella '
                'persona, quindi vive solo nel dato e non a runtime');
        expect(voce.contains('facoltativa'), isTrue,
            reason: '${maestro.id}: la chiusura e suggerita, non imposta');
      }
    });
  });
}
