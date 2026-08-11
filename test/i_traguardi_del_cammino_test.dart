import 'package:esoteric_circle/core/sigilli/eventi_del_cielo.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter_test/flutter_test.dart';

/// I 165 TRAGUARDI, sorvegliati contando e non guardando.
///
/// Ogni prova qui dentro e' un criterio di accettazione dell'ordine O, e
/// nessuna si accontenta dell'intenzione: si misura sulla CONDIZIONE, che e'
/// un dato tipizzato, non su una promessa scritta in un commento.
///
/// **Perche' contano piu' delle altre prove.** Un traguardo sbagliato non fa
/// cadere l'app: fa perdere la ragione per cui una persona torna domani. Un
/// sentiero pieno di compiti da sbrigare in un pomeriggio sembrerebbe
/// completo e sarebbe morto.
void main() {
  const minimiPerFamiglia = {
    FamigliaDelTraguardo.cielo: 10,
    FamigliaDelTraguardo.ritorno: 8,
    FamigliaDelTraguardo.giornata: 5,
    FamigliaDelTraguardo.profondita: 8,
    FamigliaDelTraguardo.ampiezza: 5,
    FamigliaDelTraguardo.identita: 5,
    FamigliaDelTraguardo.memoria: 5,
  };

  test('165 traguardi, 55 per sentiero, nelle posizioni giuste', () {
    expect(Sentieri.tuttiITraguardi, hasLength(165),
        reason: 'i traguardi non sono 165');
    for (final sentiero in Sentieri.tutti) {
      final tutti = Sentieri.di(sentiero);
      expect(tutti, hasLength(55),
          reason: '${sentiero.titolo} non ha 55 traguardi');

      final mini = Sentieri.miniDi(sentiero);
      expect(mini, hasLength(50),
          reason: '${sentiero.titolo} non ha 50 traguardi piccoli');
      expect(mini.map((t) => t.posizione).toList(),
          List.generate(50, (i) => i + 1),
          reason: 'le posizioni dei piccoli di ${sentiero.titolo} non vanno '
              'da 1 a 50 senza buchi e senza doppioni');

      final grandi = Sentieri.grandiDi(sentiero);
      expect(grandi.map((t) => t.posizione).toList(), [10, 20, 30, 40, 50],
          reason: 'i grandi di ${sentiero.titolo} non stanno a 10, 20, 30, '
              '40 e 50');
    }
  });

  test('le otto famiglie rispettano i minimi, e il Cerchio il suo tetto', () {
    for (final sentiero in Sentieri.tutti) {
      final conta = <FamigliaDelTraguardo, int>{};
      for (final t in Sentieri.di(sentiero)) {
        conta[t.famiglia] = (conta[t.famiglia] ?? 0) + 1;
      }
      for (final minimo in minimiPerFamiglia.entries) {
        expect(conta[minimo.key] ?? 0, greaterThanOrEqualTo(minimo.value),
            reason: '${sentiero.titolo}: la famiglia ${minimo.key.name} ha '
                '${conta[minimo.key] ?? 0} traguardi contro i ${minimo.value} '
                'che l\'ordine pretende');
      }
      // IL CERCHIO E' UN TETTO, non un minimo: la condivisione e' un premio,
      // mai un pedaggio, e un sentiero pieno di inviti sarebbe una catena di
      // sant\'Antonio con le stelle.
      expect(conta[FamigliaDelTraguardo.cerchio] ?? 0, lessThanOrEqualTo(4),
          reason: '${sentiero.titolo} chiede troppe volte di condividere');
    }
  });

  test('almeno 30 traguardi per sentiero non si chiudono in giornata', () {
    for (final sentiero in Sentieri.tutti) {
      final lenti = Sentieri.miniDi(sentiero)
          .where((t) => t.condizione.chiedeUnAltroGiorno)
          .length;
      expect(lenti, greaterThanOrEqualTo(30),
          reason: '${sentiero.titolo}: solo $lenti traguardi su 50 chiedono '
              'un altro giorno. Un traguardo che si chiude nello stesso minuto '
              'in cui lo scopri non e\' un traguardo di ritorno, e\' un '
              'compito');
    }
  });

  test('almeno 10 traguardi per sentiero dipendono dal cielo vero', () {
    for (final sentiero in Sentieri.tutti) {
      final delCielo = Sentieri.di(sentiero)
          .where((t) => t.condizione.chiedeIlCielo)
          .length;
      expect(delCielo, greaterThanOrEqualTo(10),
          reason: '${sentiero.titolo} ha solo $delCielo traguardi legati a un '
              'evento del cielo: e\' la famiglia che nessuno puo\' copiare '
              'senza un motore astronomico vero');
    }
  });

  test('ogni evento nominato esiste nel catalogo del cielo', () {
    for (final t in Sentieri.tuttiITraguardi) {
      final condizione = t.condizione;
      if (condizione is FinestraDelCielo) {
        expect(EventiDelCielo.tutti, contains(condizione.evento),
            reason: '${t.id} aspetta l\'evento "${condizione.evento}", che il '
                'catalogo del cielo non sa riconoscere: quel traguardo non si '
                'accenderebbe mai');
      }
    }
  });

  test('nessun traguardo e\' la riformulazione di un altro', () {
    final visti = <String, String>{};
    final doppioni = <String>[];
    for (final t in Sentieri.tuttiITraguardi) {
      final firma = t.condizione.firma;
      if (Sentieri.agganciTrasversali.contains(firma)) continue;
      if (visti.containsKey(firma)) {
        doppioni.add('${t.id} ripete ${visti[firma]} ("$firma")');
      }
      visti[firma] = t.id;
    }
    expect(doppioni, isEmpty,
        reason: 'due traguardi chiedono la stessa identica cosa con parole '
            'diverse: $doppioni');
  });

  test('i tre aggancio si ripetono sui tre sentieri, e sono solo tre', () {
    for (final firma in Sentieri.agganciTrasversali) {
      final quanti = Sentieri.tuttiITraguardi
          .where((t) => t.condizione.firma == firma)
          .length;
      expect(quanti, 3,
          reason: 'l\'aggancio "$firma" compare $quanti volte invece di una '
              'per sentiero');
    }
  });

  test('nessuna frase wow si ripete, e nessuna e\' generica', () {
    final viste = <String, String>{};
    for (final t in Sentieri.tuttiITraguardi) {
      expect(viste.containsKey(t.frase), isFalse,
          reason: '${t.id} usa la stessa frase di ${viste[t.frase]}');
      viste[t.frase] = t.id;

      expect(t.frase.length, greaterThan(40),
          reason: '${t.id} ha una frase troppo corta per festeggiare '
              'qualcosa: "${t.frase}"');
      for (final vuota in const [
        'Congratulazioni',
        'Complimenti',
        'Bravo',
        'Ottimo lavoro',
        'Traguardo raggiunto',
      ]) {
        expect(t.frase.startsWith(vuota), isFalse,
            reason: '${t.id} apre con "$vuota", che vale per qualunque '
                'traguardo e quindi non festeggia nessuno');
      }
    }
  });

  test('la somma degli Eos torna, sentiero per sentiero e in tutto', () {
    // IL NUMERO ATTESO NASCE DALLA CURVA, non da una cifra ricopiata: con 55
    // traguardi per sentiero la curva decisa produce 2.010 e non i 1.960
    // scritti nell'ordine, che varrebbero per 45 piccoli invece di 50. La
    // contraddizione e' dichiarata accanto al codice e nel rapporto: qui si
    // verifica che i dati siano coerenti con la curva, che e' la cosa che
    // una prova puo' sorvegliare.
    final atteso = Sentieri.eosAttesiPerSentiero;
    expect(atteso, 2010,
        reason: 'la curva degli Eos non e piu quella decisa: se il cambio e '
            'voluto, va cambiato anche questo numero, e con lui il rapporto');
    for (final sentiero in Sentieri.tutti) {
      expect(Sentieri.eosDi(sentiero), atteso,
          reason: '${sentiero.titolo} vale ${Sentieri.eosDi(sentiero)} Eos '
              'invece dei $atteso che la curva produce');
    }
    expect(Sentieri.eosInTutto, atteso * 3,
        reason: 'i tre sentieri insieme non tornano');
  });

  test('la curva degli Eos e\' quella decisa, premio per premio', () {
    for (final sentiero in Sentieri.tutti) {
      final mini = Sentieri.miniDi(sentiero);
      for (final t in mini) {
        expect(t.eos, t.posizione <= 3 ? 20 : 10,
            reason: '${t.id} vale ${t.eos} Eos: i primi tre valgono venti, '
                'gli altri dieci');
      }
      expect(Sentieri.grandiDi(sentiero).map((t) => t.eos).toList(),
          [80, 150, 250, 400, 600],
          reason: 'i grandi di ${sentiero.titolo} non seguono la curva');
    }
  });

  test('ogni traguardo ha un nome proprio e un id unico', () {
    final idVisti = <String>{};
    for (final t in Sentieri.tuttiITraguardi) {
      expect(idVisti.add(t.id), isTrue, reason: 'id ripetuto: ${t.id}');
      expect(t.nome.length, greaterThan(3),
          reason: '${t.id} non ha un nome proprio');
    }
  });
}
