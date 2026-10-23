/// LA TIMELINE A QUATTRO LIVELLI E LA RICERCA. Ordine CG voci 02 e 05.
///
/// **Le misure di accettazione, contate e non stimate.** Zero letture di
/// Firestore per aprire l'anno a indice caldo; zero chiamate all'AI a
/// qualunque livello; un giorno da 250 voci non piu' alto di tre volte un
/// giorno da 14; una ricerca su 1.200 voci sotto i 100 millesimi.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:esoteric_circle/core/ricordi/conti_delle_arti.dart';
import 'package:esoteric_circle/core/ricordi/registro_dei_ricordi.dart';
import 'package:esoteric_circle/core/ricordi/riassunti_del_tempo.dart';
import 'package:esoteric_circle/core/ricordi/vista_dei_ricordi.dart';
import 'package:esoteric_circle/core/ricordi/voce_del_ricordo.dart';

/// Una porta che conta le letture e non tocca la rete.
class _PortaContata extends PortaDeiRicordi {
  int letture = 0;

  @override
  Future<bool> manda(String mese, List<VoceDelRicordo> righe) async => true;

  @override
  Future<List<VoceDelRicordo>> leggi(String mese) async {
    letture++;
    return const [];
  }
}

VoceDelRicordo _voce(
  DateTime quando, {
  String arte = 'gettata',
  String maestro = 'caligo',
  String titolo = 'Una gettata di rune',
  TipoDelRicordo tipo = TipoDelRicordo.gesto,
}) =>
    VoceDelRicordo(
      quando: quando,
      arte: arte,
      maestro: maestro,
      titolo: titolo,
      tipo: tipo,
    );

Future<RegistroDeiRicordi> _registroCon(List<VoceDelRicordo> voci,
    {PortaDeiRicordi? porta}) async {
  final r = RegistroDeiRicordi(
      orologio: () => DateTime(2026, 8, 31),
      porta: porta ?? const PortaSpentaDeiRicordi());
  await r.carica();
  for (final v in voci) {
    await r.segna(v);
  }
  return r;
}

VistaDeiRicordi _vista(RegistroDeiRicordi registro) => VistaDeiRicordi(
      registro: registro,
      gestiDeiDoni: ContiDelleArti.gestiDeiDoni.values.toSet(),
      orologio: () => DateTime(2026, 8, 31),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(const {}));

  test('CG.02: aprire i quattro livelli non costa NESSUNA lettura', () async {
    final porta = _PortaContata();
    final registro = await _registroCon([
      for (var g = 1; g <= 28; g++) _voce(DateTime(2026, 8, g, 9)),
      for (var m = 1; m <= 7; m++) _voce(DateTime(2026, m, 10, 9)),
    ], porta: porta);
    final vista = _vista(registro);

    // I quattro livelli, uno dopo l'altro.
    vista.scendiA(LivelloDeiRicordi.anno);
    final mesi = vista.iDodiciMesi;
    vista.scendiA(LivelloDeiRicordi.mese, quando: DateTime(2026, 8, 15));
    final settimane = vista.leSettimaneDelMese;
    vista.scendiA(LivelloDeiRicordi.settimana, quando: DateTime(2026, 8, 15));
    final giorni = vista.iGiorniDellaSettimana;
    vista.scendiA(LivelloDeiRicordi.giorno, quando: DateTime(2026, 8, 15));
    final gruppi = vista.iGruppiDelGiorno;

    expect(porta.letture, 0,
        reason: 'a indice caldo l\'apertura di un livello non deve leggere '
            'niente dal server. IL ROSSO SI DIMOSTRA facendo leggere un '
            'documento a ogni livello, e questo conto sale a quattro');
    expect(registro.lettureDalServer, 0);
    expect(mesi.length, 12, reason: 'l\'anno ha dodici caselle sempre');
    expect(settimane, isNotEmpty);
    expect(giorni.length, 7, reason: 'la settimana ha sette giorni sempre');
    expect(gruppi, isNotEmpty);
  });

  test('CG.02: un mese senza gesti mostra le sue settimane, non il vuoto',
      () async {
    final registro = await _registroCon([_voce(DateTime(2026, 8, 15, 9))]);
    final vista = _vista(registro);
    vista.scendiA(LivelloDeiRicordi.mese, quando: DateTime(2026, 2, 10));
    final settimane = vista.leSettimaneDelMese;
    expect(settimane, isNotEmpty,
        reason: 'un mese senza gesti deve mostrare le sue settimane vuote: '
            'nessuna settimana sembra un mese che non e\' mai esistito');
    expect(settimane.every((s) => s.vuoto), isTrue);
  });

  test('CG.02: un giorno da 250 voci non esplode, e il numero si legge',
      () async {
    // **La misura vera dell'ordine e' l'ALTEZZA RESA**, e sta nella prova
    // della schermata. Qui si misura la grandezza da cui l'altezza nasce,
    // cioe' QUANTE RIGHE la lista deve disegnare: se le righe non crescono,
    // l'altezza non puo' crescere.
    final poche = await _registroCon([
      for (var i = 0; i < 14; i++)
        _voce(DateTime(2026, 8, 31, 9, i), arte: 'arte$i'),
    ]);
    final vistaPoche = _vista(poche)
      ..scendiA(LivelloDeiRicordi.giorno, quando: DateTime(2026, 8, 31));
    final righePoche = vistaPoche.iGruppiDelGiorno.length;

    SharedPreferences.setMockInitialValues(const {});
    final tante = await _registroCon([
      // Duecentocinquanta voci sparse su venti arti, che e' il caso vero di
      // un Illuminato: nessuno usa duecentocinquanta arti diverse.
      for (var i = 0; i < 250; i++)
        _voce(DateTime(2026, 8, 31, 9, i), arte: 'arte${i % 20}'),
    ]);
    final vistaTante = _vista(tante)
      ..scendiA(LivelloDeiRicordi.giorno, quando: DateTime(2026, 8, 31));
    final righeTante = vistaTante.iGruppiDelGiorno.length;

    // ignore: avoid_print
    print('ORDINE CG VOCE 02: righe disegnate, giorno da 14 voci $righePoche, '
        'giorno da 250 voci $righeTante');

    expect(righeTante, lessThanOrEqualTo(righePoche * 3),
        reason: 'un giorno da 250 voci disegna $righeTante righe contro le '
            '$righePoche di un giorno da 14: sopra il triplo la schermata '
            'diventa un muro. IL ROSSO SI DIMOSTRA togliendo il '
            'raggruppamento, e le righe diventano duecentocinquanta');
  });

  test('CG.02: sotto la soglia non si raggruppa, sopra si', () {
    final poche = RiassuntiDelTempo.gruppiDelGiorno([
      for (var i = 0; i < RiassuntiDelTempo.sopraQuanteSiRaggruppa; i++)
        _voce(DateTime(2026, 8, 31, 9, i)),
    ]);
    expect(poche.every((g) => !g.chiuso), isTrue,
        reason: 'una riga che dice "due gettate" e si apre su due righe fa '
            'fare due tocchi per vedere cio\' che stava gia\' li\'');
    expect(poche.length, RiassuntiDelTempo.sopraQuanteSiRaggruppa);

    final tante = RiassuntiDelTempo.gruppiDelGiorno([
      for (var i = 0; i < RiassuntiDelTempo.sopraQuanteSiRaggruppa + 1; i++)
        _voce(DateTime(2026, 8, 31, 9, i)),
    ]);
    expect(tante.length, 1);
    expect(tante.first.chiuso, isTrue);
    expect(tante.first.quante, RiassuntiDelTempo.sopraQuanteSiRaggruppa + 1);
  });

  test('CG.02: UN GIORNO NON HA UN COLORE, e il pareggio non ne inventa uno',
      () async {
    // Decisione del fondatore del 31 agosto 2026: "e' probabile che ne usi
    // piu' di uno e l'app spinge a usarli giornalmente tutti e tre".
    final registro = await _registroCon([
      _voce(DateTime(2026, 8, 31, 9), maestro: 'caligo', arte: 'gettata'),
      _voce(DateTime(2026, 8, 31, 10), maestro: 'aura', arte: 'meditazione'),
    ]);
    final vista = _vista(registro)
      ..scendiA(LivelloDeiRicordi.giorno, quando: DateTime(2026, 8, 31));
    final giorno = vista.ilGiorno;

    expect(giorno.perMaestro.length, 2,
        reason:
            'il colore sta sulla VOCE, quindi un giorno puo\' portarne piu\' '
            'di uno');
    expect(giorno.maestroDominante, isNull,
        reason: 'in pareggio non c\'e\' un dominante: dire "soprattutto con '
            'Aura" quando Aura e Caligo stanno pari sarebbe un fatto falso, e '
            'i riassunti di questa schermata sono fatti');

    SharedPreferences.setMockInitialValues(const {});
    final sbilanciato = await _registroCon([
      _voce(DateTime(2026, 8, 31, 9), maestro: 'caligo', arte: 'gettata'),
      _voce(DateTime(2026, 8, 31, 10), maestro: 'caligo', arte: 'tramonto'),
      _voce(DateTime(2026, 8, 31, 11), maestro: 'aura', arte: 'meditazione'),
    ]);
    final vista2 = _vista(sbilanciato)
      ..scendiA(LivelloDeiRicordi.giorno, quando: DateTime(2026, 8, 31));
    expect(vista2.ilGiorno.maestroDominante, 'caligo');
  });

  test('CG.05: cercare su 1.200 voci sta sotto i cento millesimi', () async {
    final voci = <VoceDelRicordo>[
      for (var i = 0; i < 1200; i++)
        _voce(DateTime(2026, 1, 1).add(Duration(hours: i)),
            arte: 'arte${i % 20}',
            titolo: i == 700
                ? 'Perché ogni volta mi blocco prima di firmare'
                : 'Una domanda numero $i'),
    ];
    final porta = _PortaContata();
    final registro = await _registroCon(voci, porta: porta);
    final vista = _vista(registro);

    final cronometro = Stopwatch()..start();
    vista.cerca('mi blocco');
    final trovate = vista.risultati;
    cronometro.stop();

    // ignore: avoid_print
    print('ORDINE CG VOCE 05: ricerca su ${registro.tutte.length} voci in '
        '${cronometro.elapsedMilliseconds} millesimi, trovate '
        '${trovate.length}');

    expect(trovate.length, 1, reason: 'la domanda cercata e\' una sola');
    expect(
        trovate.first.titolo, 'Perché ogni volta mi blocco prima di firmare');
    expect(cronometro.elapsedMilliseconds, lessThan(100),
        reason: 'la ricerca ha impiegato ${cronometro.elapsedMilliseconds} '
            'millesimi. IL ROSSO SI DIMOSTRA facendo cercare sul contenuto '
            'pieno invece che sull\'indice: il tempo e le letture escono '
            'dalla soglia');
    expect(porta.letture, 0,
        reason: 'una ricerca a indice caldo non legge niente dal server');
  });

  test('CG.05: le pastiglie si sommano per famiglia e si moltiplicano fra loro',
      () async {
    final registro = await _registroCon([
      _voce(DateTime(2026, 8, 31, 9), maestro: 'caligo', arte: 'gettata'),
      _voce(DateTime(2026, 8, 31, 10), maestro: 'aura', arte: 'meditazione'),
      _voce(DateTime(2026, 8, 31, 11),
          maestro: 'medora',
          arte: 'oroscopo',
          tipo: TipoDelRicordo.conversazione),
    ]);
    final vista = _vista(registro);

    vista.alterna(FiltroDeiRicordi.caligo);
    vista.alterna(FiltroDeiRicordi.aura);
    expect(vista.vociVisibili.length, 2,
        reason: 'due Maestri accesi vuol dire "uno qualunque dei due", non '
            '"tutti e due insieme": senza questa regola accendere due '
            'pastiglie svuoterebbe la schermata, cioe\' il contrario di '
            'quello che il gesto promette');

    vista.alterna(FiltroDeiRicordi.conversazioni);
    expect(vista.vociVisibili, isEmpty,
        reason: 'Caligo o Aura E una conversazione: nessuna delle due voci '
            'di quei Maestri e\' una conversazione');
  });

  test('CG.02: nessun punto che costruisce un riassunto chiama il modello', () {
    // **La terza prova del rosso dell'ordine.** Si legge il sorgente dei due
    // file che costruiscono i riassunti e si pretende che non nominino
    // nessun provider di AI: una chiamata dentro il costruttore del riassunto
    // del mese costerebbe una chiamata per ogni apertura della schermata.
    const nomi = [
      'MaestroAiProvider',
      'VertexAi',
      'GenerativeModel',
      'firebase_ai',
      'services/ai/',
    ];
    for (final percorso in const [
      'lib/core/ricordi/riassunti_del_tempo.dart',
      'lib/core/ricordi/vista_dei_ricordi.dart',
    ]) {
      final sorgente = File(percorso).readAsStringSync();
      for (final nome in nomi) {
        expect(sorgente.contains(nome), isFalse,
            reason: '$percorso nomina $nome: i riassunti sono conti e fatti, '
                'mai prosa generata. IL ROSSO SI DIMOSTRA mettendo una '
                'chiamata dentro il costruttore del riassunto del mese');
      }
    }
  });
}
