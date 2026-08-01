import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/core/astro/night_sky.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/sky.dart';
import 'package:esoteric_circle/features/santuario/sky_overview_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// NIENTE SI DISEGNA SENZA POTER DIRE DOV'ERA.
///
/// **La segnalazione.** Nel cielo di nascita il fondatore tocca l'Ariete e la
/// scheda mostra il solo nome: nessun grado, nessuna direzione, nessuna ora,
/// mentre gli altri corpi della stessa schermata rispondono.
///
/// **La causa, verificata prima di correggere.** La SELEZIONE dei corpi e la
/// loro SCHEDA leggevano due fonti diverse. La selezione viene da
/// `constellationsHighTonight`, che ricava le figure all'opposizione dalla
/// longitudine del Sole, un calcolo simbolico che non guarda l'orizzonte; la
/// scheda le cerca nell'istantanea vera. Se una figura scelta ha tutte le
/// stelle sotto il suolo non compare nell'istantanea, il ciclo non la trova, e
/// il metodo tornava NULLO: la figura veniva disegnata lo stesso, perche' gli
/// slot vanno riempiti, e restava muta.
///
/// **Misurato**: al 15 giugno 1990 alle 14:30 da 45,67 e 8,83 la selezione
/// sceglie Leone, Vergine e Cancro, e la Vergine sta a meno 1,4 gradi; la Luna
/// dello stesso istante e' del tutto sotto il suolo. Due corpi disegnati che
/// l'istantanea colloca sotto l'orizzonte.
///
/// **QUESTA PROVA NON GUARDA L'ARIETE**: enumera tutti i corpi di tutti e due i
/// cieli e cade se anche uno solo mostra il nome e basta. Una prova sull'Ariete
/// sarebbe verde il giorno in cui tace la Vergine.
void main() {
  const luogo = BirthPlace(
    label: 'Verifica',
    latitude: 45.6736,
    longitude: 8.8348,
    timezone: 'Europe/Rome',
  );

  late SkyCatalog catalogo;
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    catalogo = await SkyCatalog.load();
  });

  /// Cio' che la scheda direbbe di ogni corpo disegnato a [istante].
  Map<String, String?> schedeDei(DateTime istante, {required bool birth}) {
    final cielo = buildSkyFor(catalogo, istante, luogo);
    final schede = <String, String?>{};
    for (final sign in NightSky.constellationsHighTonight(istante)) {
      schede[sign.italianName] = testoDellaScheda(sign, cielo,
          catalogo: catalogo, birth: birth);
    }
    return schede;
  }

  /// Un testo che dice dov'era: o gradi e direzione, o la dichiarazione che
  /// stava sotto l'orizzonte.
  void pretendiCheDicaDovEra(String corpo, String? testo) {
    expect(testo, isNotNull,
        reason: '$corpo viene disegnato e la sua scheda non dice niente: '
            'e\' il difetto del solo nome');
    final t = testo!.toLowerCase();
    final haINumeri = t.contains('gradi sopra il suolo');
    final dichiaraSotto = t.contains("sotto l'orizzonte");
    expect(haINumeri || dichiaraSotto, isTrue,
        reason: '$corpo mostra "$testo": non ci sono i gradi e non c\'e\' la '
            'dichiarazione che stava sotto l\'orizzonte');
    if (haINumeri) {
      expect(t.contains('a mezzanotte') || t.contains('ora di nascita'), isTrue,
          reason: '$corpo da\' un numero senza dire a che ora si riferisce, '
              'quindi nessuno lo puo\' verificare');
    }
  }

  test('Cielo di NASCITA: nessun corpo mostra il solo nome', () {
    // L'istante misurato in cui un corpo selezionato sta sotto l'orizzonte.
    // Questa prova e' rossa sul codice di prima, dove la Vergine restava muta.
    final schede = schedeDei(DateTime(1990, 6, 15, 14, 30), birth: true);
    expect(schede, isNotEmpty);
    schede.forEach(pretendiCheDicaDovEra);
  });

  test('Cielo di STANOTTE: nessun corpo mostra il solo nome', () {
    // LA SECONDA PORTA, ed e' il punto dell'ordine: la regola non vale per la
    // porta da cui e' arrivata la segnalazione, vale per costruzione. E' la
    // quindicesima volta che questo progetto incontra la stessa forma.
    final schede = schedeDei(
        mezzanotteDellaNotteCheViene(DateTime(2026, 8, 1, 18, 4)),
        birth: false);
    expect(schede, isNotEmpty);
    schede.forEach(pretendiCheDicaDovEra);
  });

  test('Su un anno intero, in tutti e due i cieli', () {
    // Non si sceglie un istante fortunato: si passa l'anno. Se una sola
    // combinazione di data e figura tace, questa cade.
    for (var g = 0; g < 365; g += 11) {
      final t = DateTime(2026, 1, 1, 21, 0).add(Duration(days: g));
      for (final birth in [true, false]) {
        schedeDei(t, birth: birth).forEach(pretendiCheDicaDovEra);
      }
    }
  });

  test('Chi sta sotto dice anche QUANDO sorge', () {
    // La strada scelta e' la (b): il corpo compare e dichiara. Senza l'ora di
    // sorgere la dichiarazione sarebbe una scusa, non un dato.
    final cielo = buildSkyFor(catalogo, DateTime(1990, 6, 15, 14, 30), luogo);
    final t = sottoLOrizzonte(Zodiac.virgo, cielo, catalogo: catalogo, birth: true);
    expect(t, contains("sotto l'orizzonte"));
    expect(RegExp(r'\d{2}:\d{2}').hasMatch(t), isTrue,
        reason: 'la dichiarazione non porta l\'ora in cui il corpo sorge: '
            '"$t"');
  });

  test('L\'ora di sorgere e\' un vero attraversamento dell\'orizzonte', () {
    // Il minuto prima sotto, il minuto dopo sopra: altrimenti e' un numero
    // qualunque messo li' per riempire la frase.
    //
    // NON SI SCEGLIE A MANO UN CORPO CHE SI CREDE SOTTO: si cerca. Al primo
    // giro avevo preso la Vergine del 1990, che sta a meno 1,4 gradi, cioe'
    // SOPRA la soglia dell'orizzonte, e la prova denunciava giustamente che
    // due minuti prima era gia' sopra. Il caso lo trova la prova.
    DateTime? sorge;
    String? figura;
    DateTime? partenza;
    for (var g = 0; g < 365 && sorge == null; g += 3) {
      final t = DateTime(2026, 1, 1, 21, 0).add(Duration(days: g));
      final cielo = buildSkyFor(catalogo, t, luogo);
      for (final sign in NightSky.constellationsHighTonight(t)) {
        final nome = sign.italianName;
        final presente = cielo.constellations
            .where((c) => c.name.toLowerCase() == nome.toLowerCase());
        final sotto =
            presente.isEmpty || puntoDellaFigura(presente.first.stars) == null;
        if (!sotto) continue;
        final trovato = quandoSorge(catalogo, nome, t, luogo);
        if (trovato == null) continue;
        sorge = trovato;
        figura = nome;
        partenza = t;
        break;
      }
    }
    expect(sorge, isNotNull,
        reason: 'in un anno intero nessuna figura selezionata sta sotto '
            'l\'orizzonte: se fosse vero, questa voce non esisterebbe');

    bool sopra(DateTime t) {
      final c = buildSkyFor(catalogo, t, luogo);
      for (final con in c.constellations) {
        if (con.name.toLowerCase() != figura!.toLowerCase()) continue;
        return puntoDellaFigura(con.stars) != null;
      }
      return false;
    }

    expect(sopra(partenza!), isFalse,
        reason: '$figura non stava sotto: il caso e\' stato scelto male');
    expect(sopra(sorge!), isTrue,
        reason: '$figura all\'ora dichiarata non e\' sopra l\'orizzonte');
    expect(sopra(sorge.subtract(const Duration(minutes: 2))), isFalse,
        reason: '$figura due minuti prima era gia\' sopra: l\'ora dichiarata '
            'non e\' quella in cui sorge');
  });
}
