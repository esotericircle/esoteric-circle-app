import 'package:esoteric_circle/design_system/theme/accento_del_maestro.dart';
import 'package:esoteric_circle/design_system/tokens/color_tokens.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/censimento_contrasto.dart';
import '../tool/censimento_spazi.dart';
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

  // --- IL CONTRASTO, ordine P voce 14 ---
  //
  // **Il censimento tipografico non vede questo difetto.** Misura le
  // dimensioni, e `SOTTO_IL_PAVIMENTO: 0` resta vero mentre un testo e'
  // illeggibile: un testo a 18 punti in oro su avorio si legge peggio di uno a
  // 14 in bianco su nero. Da qui in avanti anche il contrasto ha il suo
  // cricchetto, e sta in questa guardia perche' e' la stessa famiglia di
  // debito, non una guardia nuova accanto.
  group('Il contrasto', () {
    test('Le coppie sotto il contrasto non aumentano', () {
      final coppie = censisciIlContrasto();
      final sotto = coppie.where((c) => !c.passa).toList();
      final registrati = numeriDelContrasto();

      expect(sotto.length, lessThanOrEqualTo(registrati.sotto),
          reason: 'le coppie di colori sotto '
              '${sogliaDiLettura.toStringAsFixed(1)} a 1 sono passate da '
              '${registrati.sotto} a ${sotto.length}. Da qui in avanti quel '
              'numero puo\' solo scendere.\nLe peggiori:\n'
              '${sotto.take(6).map((c) => '  ${c.inchiostro.nome} su ${c.superficie.nome}: ${c.contrasto.toStringAsFixed(2)}').join('\n')}');
      expect(sotto.length, registrati.sotto,
          reason: 'le coppie sotto soglia sono scese a ${sotto.length} ma il '
              'censimento dice ancora ${registrati.sotto}: rigeneralo con\n'
              '  dart run tool/censimento_contrasto.dart\n'
              'e committalo insieme al codice, cosi\' la soglia scende con lui.');
      expect(coppie.length, registrati.censite,
          reason: 'le coppie censite sono ${coppie.length} e il documento ne '
              'dichiara ${registrati.censite}: rigenera il censimento');
    });

    test(
        'La formula dello strumento e quella dell\'app dicono lo stesso numero',
        () {
      // **DUE COPIE DELLA STESSA ARITMETICA DIVERGONO.** Lo strumento gira
      // sulla VM senza motore grafico, quindi non puo' importare
      // `AccentoDelMaestro` e la formula WCAG e' scritta due volte. Questa prova
      // e' cio' che rende sopportabile la seconda copia: se un giorno le due
      // smettessero di dire lo stesso numero, si saprebbe subito.
      const campioni = [
        [ColorTokens.textPrimary, ColorTokens.medoraDeepest],
        [ColorTokens.textMuted, ColorTokens.auraSurface],
        [ColorTokens.gold, ColorTokens.caligoDeep],
        [ColorTokens.goldDeep, ColorTokens.neutralSurface],
        [ColorTokens.textSecondary, ColorTokens.medoraSurface],
      ];
      for (final coppia in campioni) {
        final a = coppia[0];
        final b = coppia[1];
        final dallApp = AccentoDelMaestro.contrastoFra(a, b);
        final dalloStrumento = contrastoFra(
          ColoreDichiarato(
              nome: 'a',
              file: '',
              riga: 0,
              valore: 0xFF000000 |
                  ((a.r * 255).round() << 16) |
                  ((a.g * 255).round() << 8) |
                  (a.b * 255).round()),
          ColoreDichiarato(
              nome: 'b',
              file: '',
              riga: 0,
              valore: 0xFF000000 |
                  ((b.r * 255).round() << 16) |
                  ((b.g * 255).round() << 8) |
                  (b.b * 255).round()),
        );
        expect(dalloStrumento, closeTo(dallApp, 0.01),
            reason: 'lo strumento dice ${dalloStrumento.toStringAsFixed(3)} e '
                'l\'app ${dallApp.toStringAsFixed(3)}: le due copie della '
                'formula WCAG hanno smesso di essere d\'accordo');
      }
    });
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

  test('Il testo che si legge non torna piccolo', () {
    // LA QUARTA GRANDEZZA, e dice una cosa diversa dalle altre tre: quelle
    // misurano il debito, questa misura se l'app si LEGGE. Un totale che scende
    // mentre questa sale vorrebbe dire che si stanno togliendo misure a mano
    // dalle etichette e lasciando piccolo il testo narrato.
    final lettura = censisci().where(sottoLaLettura).length;
    final registrato = numeriRegistrati().letturaSotto16;
    expect(lettura, lessThanOrEqualTo(registrato),
        reason: 'il testo di lettura sotto i sedici punti passa da '
            '$registrato a $lettura: qualcosa si e\' rimpicciolito');
    expect(lettura, registrato,
        reason: 'il testo di lettura sotto i sedici punti scende a $lettura '
            'ma il censimento dice ancora $registrato: rigeneralo e committalo');
  });

  test('I vuoti verticali non crescono', () {
    // Il gemello della guardia tipografica, sul documento dei vuoti: stessa
    // regola, il numero puo' solo scendere e il documento va rigenerato quando
    // scende, altrimenti resta scritto un numero che non e' piu' vero.
    final vuoti = censisciVuoti();
    final eccessivi =
        vuoti.where((v) => v.punti > sogliaDelVuotoEccessivo).length;
    final registrati = vuotiRegistrati();
    expect(vuoti.length, registrati.totale,
        reason: 'i vuoti verticali dichiarati sono ${vuoti.length} e il '
            'documento ne registra ${registrati.totale}: rigeneralo con '
            'dart run tool/censimento_spazi.dart');
    expect(eccessivi, lessThanOrEqualTo(registrati.eccessivi),
        reason: 'i vuoti oltre la soglia di $sogliaDelVuotoEccessivo punti '
            'sono passati da ${registrati.eccessivi} a $eccessivi');
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
    expect(tabella.letturaSotto16, marche.letturaSotto16,
        reason: 'la tabella somma ${tabella.letturaSotto16} misure di lettura '
            'sotto i sedici e la marca ne dichiara ${marche.letturaSotto16}');
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
  test('Nessun ruolo scende al pavimento, e l\'etichetta vale quattordici', () {
    // **L'ETICHETTA NON E' PIU' IL PAVIMENTO. Ordine CQ voce 2.11**, 3
    // settembre 2026. Valeva dodici, cioe' esattamente il pavimento, e il
    // fondatore ha detto per la quarta volta che i caratteri sono piccoli.
    // Adesso vale quattordici: il pavimento resta dodici ed e' il limite
    // sotto cui l'assert dei token non lascia scendere nessuno, ma **nessun
    // ruolo lo tocca piu'**, che e' il modo giusto di avere un pavimento.
    expect(TypographyTokens.etichetta().fontSize,
        TypographyTokens.misuraEtichetta,
        reason: 'l\'etichetta non vale piu\' quattordici punti');
    expect(TypographyTokens.misuraEtichetta,
        greaterThan(TypographyTokens.pavimento),
        reason: 'l\'etichetta e\' tornata a valere il pavimento');
    for (final ruolo in <MapEntry<String, double?>>[
      MapEntry(
          'cerimonialeGrande', TypographyTokens.cerimonialeGrande().fontSize),
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
