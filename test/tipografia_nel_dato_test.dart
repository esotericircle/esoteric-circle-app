import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/censimento_tipografia.dart';

/// LA TIPOGRAFIA VIVE NEL DATO, E IL DEBITO PUO' SOLO SCENDERE.
///
/// Il posto che un testo occupa nella pagina si dichiara con un RUOLO
/// (`TypographyTokens.lettura`, `titoloScheda`, `etichetta`), e la misura e' una
/// conseguenza. Ogni misura scritta a mano nel codice e' un pezzo di quel
/// sistema deciso altrove, cioe' debito: `docs/tipografia/censimento.md` li
/// elenca tutti e ne registra il totale, e questa guardia impedisce che quel
/// totale cresca.
///
/// **Perche' il numero sta nel documento e non qui.** Perche' il censimento e la
/// soglia devono essere la stessa cosa: se la soglia vivesse in questo file,
/// rigenerare il documento e alzare la soglia sarebbero due gesti separati, e il
/// giorno che qualcuno ne facesse uno solo il documento direbbe una cosa e la
/// guardia un'altra.
///
/// **Il rosso e' stato eseguito davvero**, aggiungendo un `fontSize: 15` dentro
/// `lib/design_system/components/status_badge.dart`: il totale e' salito da 683
/// a 684 e la prova e' caduta nominando il file e la riga. Tolta la misura, e'
/// tornata verde.
void main() {
  test('Le misure tipografiche scritte a mano non aumentano', () {
    final misure = censisci();
    final registrato = numeriRegistrati().totale;

    expect(
      misure.length,
      lessThanOrEqualTo(registrato),
      reason: 'Le misure tipografiche scritte a mano sono passate da '
          '$registrato a ${misure.length}. Da qui in avanti quel numero puo\' '
          'solo scendere: usa un ruolo di TypographyTokens invece di scrivere '
          'una misura. Se il ruolo che ti serve non esiste, nasce in '
          'typography_tokens.dart e vale per tutta l\'app, non in una schermata '
          'sola.\nUltime aggiunte possibili:\n'
          '${misure.map((m) => '  $m').take(40).join('\n')}',
    );

    // Se il debito SCENDE va bene, ma il documento va rigenerato, altrimenti
    // resta scritto un numero che non e' piu' vero e la guardia diventa lasca.
    expect(
      misure.length,
      registrato,
      reason: 'Il debito e\' sceso a ${misure.length} ma il censimento dice '
          'ancora $registrato: rigeneralo con\n'
          '  dart run tool/censimento_tipografia.dart\n'
          'e committa il documento insieme al codice, cosi\' la soglia scende '
          'con lui e non resta indietro.',
    );
  });


  test('Il debito non si sparge su piu\' file', () {
    // IL TOTALE DA SOLO SI LASCIA AGGIRARE: spostando una misura da un file
    // all'altro non cambia di un'unita', mentre il debito si allarga a una
    // schermata in piu'. Questo numero dice se si sta spargendo.
    final file = censisci().map((m) => m.file).toSet().length;
    final registrato = numeriRegistrati().file;
    expect(file, lessThanOrEqualTo(registrato),
        reason: 'i file che portano misure a mano sono passati da $registrato '
            'a $file: il debito si sta spargendo su schermate nuove');
    expect(file, registrato,
        reason: 'i file sono scesi a $file ma il censimento dice ancora '
            '$registrato: rigeneralo e committalo insieme al codice');
  });

  test('Sotto il pavimento non torna nessuno', () {
    // La terza grandezza, e la piu' grave: le altre due misurano il debito,
    // questa misura il testo illeggibile.
    final sotto = censisci().where(sottoIlPavimentoDellApp).length;
    final registrato = numeriRegistrati().sottoIlPavimento;
    expect(sotto, lessThanOrEqualTo(registrato),
        reason: 'le misure sotto il pavimento sono passate da $registrato a '
            '$sotto: qualcuno ha rimesso a video del testo che non si legge');
    expect(sotto, registrato,
        reason: 'le misure sotto il pavimento sono scese a $sotto ma il '
            'censimento dice ancora $registrato: rigeneralo e committalo');
  });

  test('Il documento non si contraddice', () {
    // **IL DOCUMENTO SOVRANO DEL DEBITO DICEVA DUE COSE.** Il riepilogo in
    // cima dichiarava zero misure sotto il pavimento e la riga di
    // `tarot_cartiglio.dart`, nella tabella in fondo, ne dichiarava una: due
    // numeri veri per due definizioni diverse dello stesso zero. Adesso la
    // definizione e' una sola, e questa prova impedisce che tornino a essere
    // due, confrontando le marche in cima con le somme della tabella in fondo.
    final marche = numeriRegistrati();
    final tabella = sommeDellaTabella();
    expect(tabella.totale, marche.totale,
        reason: 'la tabella per file somma ${tabella.totale} misure e la marca '
            'in cima ne dichiara ${marche.totale}: il documento si contraddice');
    expect(tabella.file, marche.file,
        reason: 'la tabella ha ${tabella.file} righe e la marca dichiara '
            '${marche.file} file');
    expect(tabella.sottoIlPavimento, marche.sottoIlPavimento,
        reason: 'la tabella somma ${tabella.sottoIlPavimento} misure sotto il '
            'pavimento e la marca ne dichiara ${marche.sottoIlPavimento}: e\' '
            'esattamente la contraddizione che l\'ordine C ha chiuso');
  });

  test('Il pavimento dello strumento e\' quello dei token', () {
    // Lo strumento gira senza Flutter e non puo' importare i token, quindi si
    // porta il numero in copia: qui si verifica che le due copie coincidano,
    // altrimenti il censimento misurerebbe un pavimento che l'app non ha.
    expect(pavimentoDellApp, TypographyTokens.pavimento);
  });
  test('Il pavimento e\' il ruolo piu\' piccolo che esista', () {
    // Non e' una tautologia: dice che nessuno puo' abbassare un ruolo sotto il
    // pavimento senza accorgersene, perche' il pavimento e' l'etichetta.
    expect(TypographyTokens.etichetta().fontSize, TypographyTokens.pavimento,
        reason: 'l\'etichetta non vale piu\' il pavimento: o e\' scesa sotto la '
            'soglia di leggibilita\', o il pavimento si e\' alzato senza che i '
            'ruoli lo seguissero');
    for (final ruolo in <MapEntry<String, double?>>[
      MapEntry('cerimonialeGrande', TypographyTokens.cerimonialeGrande().fontSize),
      MapEntry('cerimoniale', TypographyTokens.cerimoniale().fontSize),
      MapEntry('titoloSezione', TypographyTokens.titoloSezione().fontSize),
      MapEntry('titoloScheda', TypographyTokens.titoloScheda().fontSize),
      MapEntry('lettura', TypographyTokens.lettura().fontSize),
      MapEntry('corpo', TypographyTokens.corpo().fontSize),
      MapEntry('didascalia', TypographyTokens.didascalia().fontSize),
      MapEntry('etichetta', TypographyTokens.etichetta().fontSize),
    ]) {
      expect(ruolo.value, isNotNull);
      expect(ruolo.value!, greaterThanOrEqualTo(TypographyTokens.pavimento),
          reason: 'il ruolo ${ruolo.key} sta sotto il pavimento dell\'app');
    }
  });

  test('La lettura respira piu\' del corpo', () {
    // L'interlinea larga non e' un vezzo: e' la ragione per cui il ruolo
    // lettura esiste accanto a corpo. Se qualcuno le pareggiasse, resterebbero
    // due nomi per la stessa cosa.
    expect(TypographyTokens.lettura().height, 1.55);
    expect(TypographyTokens.corpo().height, 1.5);
    expect(TypographyTokens.lettura().fontSize!,
        greaterThan(TypographyTokens.corpo().fontSize!));
  });
}
