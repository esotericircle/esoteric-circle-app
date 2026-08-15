import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/sigilli/direzione_della_festa.dart';
import 'package:esoteric_circle/features/sigilli/pittore_della_festa.dart';
import 'package:flutter_test/flutter_test.dart';

/// TRE CELEBRAZIONI, UNA PER MAESTRO. Ordine U voce 02.
///
/// **Il difetto:** le celebrazioni erano due, una per i mini e una per i grandi,
/// e uguali per tutti e tre i Maestri. Cambiava la palette e basta, e su una
/// scena che dura meno di due secondi il colore si legge DOPO il movimento.
/// La persona deve riconoscere di chi e' la festa **prima di leggere una
/// parola**.
///
/// **La direzione e' un dato dichiarato, non un effetto che si intuisce
/// guardando**, ed e' la ragione per cui queste righe possono esistere: se
/// domani qualcuno riusa la scena di Medora per Aura, una prova cade invece che
/// passare inosservata.
void main() {
  test('i tre Maestri hanno tre direzioni diverse, e nessuna manca', () {
    var osservati = 0;
    final direzioni = <DirezioneDellaFesta, List<String>>{};
    for (final maestro in Maestro.values) {
      osservati++;
      final festa = FesteDeiMaestri.di(maestro);
      (direzioni[festa.direzione] ??= <String>[]).add(maestro.id);
    }
    // **QUANTE OSSERVAZIONI, e cade se sono zero.**
    // ignore: avoid_print
    print('ORDINE U VOCE 02: Maestri osservati $osservati, direzioni distinte '
        '${direzioni.length}');
    expect(osservati, greaterThan(0),
        reason: 'la prova non ha guardato nessun Maestro: gira a vuoto');
    expect(direzioni.length, osservati,
        reason: 'due Maestri condividono la stessa direzione, quindi le loro '
            'feste si somigliano nel movimento e restano distinguibili solo '
            'dal colore: '
            '${direzioni.entries.where((e) => e.value.length > 1).map((e) => "${e.key.name} -> ${e.value.join(", ")}").join(" | ")}');
    // E tutte e tre le direzioni dichiarate sono usate: una direzione che non
    // e' di nessuno e' una scena che nessuno vedra' mai.
    expect(direzioni.keys.toSet(), DirezioneDellaFesta.values.toSet(),
        reason: 'una direzione dichiarata non appartiene a nessun Maestro');
  });

  test('le tre materie sono diverse, e non solo le direzioni', () {
    // **Il movimento da solo non basta.** Una pioggia di scintille che cade e
    // una pioggia di scintille che sale sono la stessa festa girata: cio' che
    // scende per Caligo sono CIFRE, perche' e' il Maestro dei numeri.
    var osservati = 0;
    final materie = <MateriaDellaFesta>{};
    for (final maestro in Maestro.values) {
      osservati++;
      materie.add(FesteDeiMaestri.di(maestro).materia);
    }
    // ignore: avoid_print
    print('ORDINE U VOCE 02: materie distinte ${materie.length} su $osservati');
    expect(osservati, greaterThan(0));
    expect(materie.length, osservati,
        reason: 'due Maestri festeggiano con la stessa materia');
  });

  test('il grande e\' piu\' ampio e piu\' lungo del mini, in due numeri', () {
    // **NON "PIU' GRANDE" A PAROLE.** La differenza si dichiara: una volta e
    // mezzo le particelle, un terzo di tempo in piu'. Sono RAPPORTI e non
    // misure, quindi valgono anche se domani la durata di base cambia.
    var osservati = 0;
    for (final maestro in Maestro.values) {
      osservati++;
      final mini = FesteDeiMaestri.particelleDi(maestro, eGrande: false);
      final grande = FesteDeiMaestri.particelleDi(maestro, eGrande: true);
      expect(grande, greaterThan(mini),
          reason: '${maestro.id}: il grande non ha piu\' particelle del mini, '
              'quindi le due feste si somigliano');
      expect(grande / mini, closeTo(FesteDeiMaestri.quanteVolteIlGrande, 0.05),
          reason: '${maestro.id}: il rapporto fra grande e mini e\' '
              '${(grande / mini).toStringAsFixed(2)} invece di '
              '${FesteDeiMaestri.quanteVolteIlGrande}');
    }
    final mini = FesteDeiMaestri.millesimiDi(eGrande: false);
    final grande = FesteDeiMaestri.millesimiDi(eGrande: true);
    // ignore: avoid_print
    print('ORDINE U VOCE 02: Maestri osservati $osservati, durata mini '
        '$mini millesimi, grande $grande, rapporto '
        '${(grande / mini).toStringAsFixed(2)}');
    expect(osservati, greaterThan(0));
    expect(grande, greaterThan(mini),
        reason: 'il grande non dura piu\' del mini');
    expect(grande / mini,
        closeTo(FesteDeiMaestri.quantoDuraDiPiuIlGrande, 0.02));
  });

  test('la durata e\' scelta sul tempo di LETTURA, e si dichiara', () {
    // **UN NUMERO E NON UN GESTO.** Cio' che si scopre sotto la festa e' il nome
    // del traguardo e il premio: due righe brevi. Sotto un secondo e mezzo la
    // persona vede finire una cosa che non ha ancora cominciato a leggere, e
    // vale la regola dell'attesa che e' una scena: piu' veloce non e' piu'
    // breve, e' un difetto grafico.
    //
    // **La soglia non deriva dalla durata scelta:** viene da quanto ci mette un
    // occhio a leggere due righe brevi, che e' piu' di un secondo e mezzo.
    const minimoPerLeggere = 1500;
    expect(FesteDeiMaestri.millesimiDelMini,
        greaterThanOrEqualTo(minimoPerLeggere),
        reason: 'la festa dura ${FesteDeiMaestri.millesimiDelMini} millesimi, '
            'meno del tempo che serve a leggere cio\' che scopre');
  });

  test('degradare non è spegnere', () {
    // **Riduci Movimento e Quality Tier basso DEGRADANO la festa**, e la quota
    // che resta si legge DAL PITTORE, non ricopiata qui: due copie dello stesso
    // numero divergono, ed è l'errore che questa stessa voce ha appena corretto
    // altrove.
    expect(PittoreDellaFesta.quotaDelDegrado, greaterThan(0.0),
        reason: 'la festa degradata non ha più nessuna particella: è spenta, '
            'non degradata');
    expect(PittoreDellaFesta.quotaDelDegrado, lessThan(1.0),
        reason: 'la festa degradata ha le stesse particelle di quella piena: '
            'non degrada affatto');
  });
}