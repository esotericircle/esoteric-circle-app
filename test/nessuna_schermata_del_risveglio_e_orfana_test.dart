import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **NESSUNA SCHERMATA DELL'ONBOARDING RESTA ORFANA, E OGNI TAPPA E'
/// RAGGIUNTA.** Ordine DG voce 03, 12 settembre 2026.
///
/// **Parole del fondatore, 11 settembre 2026:** *"nell'onboarding manca anche
/// la schermata di rivelazione della carta di nascita. ti avevo dato ordine
/// con istruzioni dettagliate se non sbaglio"*.
///
/// **Aveva ragione, e la cosa era peggio di un difetto.**
/// `RivelazioneCartaDiNascita` esisteva dal 10 settembre, era la voce DC.14,
/// aveva **una guardia che confrontava 576 istanti dell'animazione coi numeri
/// del calcolo**, e non la chiamava nessuno. Il rapporto di quell'ordine
/// scriveva *"vive nell'onboarding"*, e non era vero. Un lavoro finito,
/// provato, e mai montato.
///
/// **PERCHE' NESSUNA GUARDIA SE N'ERA ACCORTA.** Perche' tutte guardavano il
/// **contenuto**: che l'animazione dicesse il vero, che i numeri venissero dal
/// calcolo. Nessuna guardava **la strada**. Una schermata giusta che nessuno
/// apre passa ogni prova che le si scriva addosso.
///
/// **LE DUE COSE CHE QUESTA GUARDIA MISURA.**
///
/// **Uno, l'orfano**: ogni widget pubblico dichiarato in
/// `lib/features/onboarding` deve essere **nominato da almeno un altro file**
/// di `lib`. Chi non lo e' e' codice che non si vede mai.
///
/// **Due, la tappa mai raggiunta**: ogni valore di `_Phase` nel Risveglio deve
/// essere **assegnato da qualche parte**, non solo avere il suo ramo nello
/// `switch`. Un ramo senza assegnazione e' una schermata scritta, montabile,
/// e irraggiungibile: la stessa famiglia dell'orfano, un livello piu' giu'.
void main() {
  /// **I FILE CHE NON DICHIARANO SCHERMATE**, e la ragione per ognuno.
  ///
  /// Sono i due che *sono* l'onboarding invece di starci dentro: chi li monta
  /// sta in `app`, e cercarne il nome fra i loro pari non proverebbe niente.
  const nonSonoSchermate = <String>{
    'onboarding_flow.dart',
    'onboarding_controller.dart',
  };

  /// **IL CENSIMENTO DEGLI ORFANI E' VUOTO, e ci e' voluto un lavoro per
  /// vuotarlo.** Ordine DG, 12 settembre 2026.
  ///
  /// **Alla nascita questa guardia ne ha trovati quattro**, oltre a quello che
  /// l'ha fatta nascere. Tre erano veri: `IntertwinedAuras`, `SkyThread` e
  /// `StardustName`, tre animazioni decorative del **vecchio** onboarding. La
  /// storia lo dice per nome: erano montate nei commit `202dc99c`, `70f3f9a9`
  /// e `7d15c077`, poi la rilavorazione dell'arco di onboarding ha cancellato
  /// le schermate che le montavano **lasciando i file**. Non erano lavoro
  /// perso da riagganciare: erano tre disegni la cui parete non esiste piu'.
  /// **Tolti il 12 settembre 2026**, e la storia di Git se li tiene.
  ///
  /// **Il quarto non era un orfano**, e crederlo tale e' stato un mio errore
  /// di lettura durato mezza giornata. `DomandaDellInvito` non e' montata da
  /// nessuno **perche' il fondatore l'ha fatta togliere**: *"e' una demo per
  /// ora, si toglie e accettiamo che per ora nessuno riscuote i 60 EOS"*. C'e'
  /// gia' una guardia, `l_invito_porta_il_suo_premio`, che **pretende** che il
  /// Santuario non la chiami, e la strada a mano resta nel menu' Account. Una
  /// decisione presa non e' una dimenticanza: qui non si tocca.
  ///
  /// **Un censimento vuoto non e' una formalita'.** Finche' resta vuoto, ogni
  /// nome che compare in questa prova e' un difetto nuovo, e nessuno deve
  /// chiedersi se sia invece uno vecchio che qualcuno aveva accettato.
  const orfaniGiaCensiti = <String>{};

  test('nessun widget dell\'onboarding e\' senza chiamanti', () {
    final cartella = Directory('lib/features/onboarding');
    expect(cartella.existsSync(), isTrue,
        reason: 'LA CARTELLA DELL\'ONBOARDING NON C\'E\', e questa prova sta '
            'per essere verde su niente.');

    final tuttoLib = {
      for (final f in sorgentiDiLib())
        f.path.replaceAll(Platform.pathSeparator, '/'): f.readAsStringSync(),
    };

    final dichiarazione =
        RegExp(r'^class ([A-Z]\w+) extends (Stateful|Stateless)Widget');

    final orfani = <String, String>{};
    var quanti = 0;

    for (final voce in tuttoLib.entries) {
      if (!voce.key.contains('lib/features/onboarding/')) continue;
      final nome = voce.key.split('/').last;
      if (nonSonoSchermate.contains(nome)) continue;
      for (final riga in senzaCommenti(voce.value).split('\n')) {
        final m = dichiarazione.firstMatch(riga.trim());
        if (m == null) continue;
        final classe = m.group(1)!;
        quanti++;
        if (orfaniGiaCensiti.contains(classe)) continue;
        // **CHI LO COSTRUISCE**, cioe' chi scrive `NomeClasse(`.
        //
        // **Anche il suo stesso file conta**, e non e' una concessione: un
        // widget montato dieci righe piu' sotto, dentro la schermata che lo
        // dichiara, e' visto eccome. La prima stesura di questa guardia
        // cercava solo **fuori** e accusava `StepDots`, che sta a schermo in
        // ogni passo dell'onboarding.
        //
        // **COME SI DISTINGUE LA DICHIARAZIONE DALL'USO**, che e' l'unica cosa
        // difficile qui: la dichiarazione del costruttore **apre la riga**,
        // `const StepDots({`, mentre l'uso ha sempre qualcosa davanti,
        // `child: StepDots(` oppure `=> const DomandaDellInvito()`. La seconda
        // stesura filtrava per forma della riga e accusava sei widget vivi.
        final apreLaRiga = RegExp('^(const\\s+)?$classe\\s*\\(');
        final nominato = RegExp('\\b$classe\\s*\\(');
        var quantiLoCostruiscono = 0;
        for (final altro in tuttoLib.entries) {
          for (final r in senzaCommenti(altro.value).split('\n')) {
            final t = r.trim();
            if (!nominato.hasMatch(t)) continue;
            // **IL FILTRO VALE SOLO DENTRO IL FILE CHE LO DICHIARA.** Una
            // riga che si apre col nome della classe, in un altro file, e'
            // una costruzione indentata dentro un elenco di figli, e la
            // terza stesura di questa guardia le scartava tutte: accusava
            // `NatureEmblem`, che sta dentro la carta natale, e `PrimoApprodo`,
            // che sta in `app.dart`.
            if (altro.key == voce.key && apreLaRiga.hasMatch(t)) continue;
            if (t.contains('State<$classe>')) continue;
            quantiLoCostruiscono++;
          }
        }
        if (quantiLoCostruiscono == 0) orfani[classe] = voce.key;
      }
    }

    cardinaleMinimo(
      quanti,
      12,
      cosa: 'widget pubblici dichiarati in lib/features/onboarding',
      perche: 'Se l\'onboarding non dichiara piu\' schermate, o e\' stato '
          'spostato, e questa guardia sta sorvegliando una cartella vuota.',
    );

    expect(
      orfani,
      isEmpty,
      reason: 'QUESTE SCHERMATE DELL\'ONBOARDING NON LE APRE NESSUNO.\n'
          '${orfani.entries.map((e) => '  ${e.key}  (${e.value})').join('\n')}\n\n'
          'Una schermata giusta che nessuno monta passa ogni prova che le si '
          'scriva addosso, e non si vede mai. E\' successo con '
          '`RivelazioneCartaDiNascita`: scritta il 10 settembre 2026, con una '
          'guardia che confrontava 576 istanti dell\'animazione coi numeri del '
          'calcolo, e zero chiamanti. Il fondatore l\'ha trovata rifacendo '
          'l\'onboarding: "manca anche la schermata di rivelazione della '
          'carta di nascita".',
    );
  });

  test('ogni tappa del Risveglio e\' raggiunta da qualcuno', () {
    final f = File('lib/features/onboarding/risveglio_journey.dart');
    expect(f.existsSync(), isTrue,
        reason: 'IL RISVEGLIO E\' STATO SPOSTATO, e questa guardia non sa '
            'piu\' dove guardare.');
    final codice = senzaCommenti(f.readAsStringSync());

    // Le tappe, lette dall'enum e non riscritte a mano.
    final enumeratore =
        RegExp(r'enum _Phase \{([^}]*)\}', multiLine: true, dotAll: true)
            .firstMatch(codice);
    expect(enumeratore, isNotNull,
        reason: 'L\'ENUM DELLE TAPPE NON SI TROVA PIU\' nel Risveglio.');
    final tappe = enumeratore!
        .group(1)!
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    cardinaleMinimo(tappe.length, 6,
        cosa: 'tappe del Risveglio',
        perche: 'Con meno di sei tappe il Risveglio non e\' piu\' quello che '
            'questa guardia sorveglia.');

    // **LA PRIMA NON HA BISOGNO DI ESSERE RAGGIUNTA**: ci si arriva entrando.
    final prima = RegExp(r'_Phase _phase = _Phase\.(\w+)').firstMatch(codice);
    expect(prima, isNotNull,
        reason: 'IL RISVEGLIO NON DICHIARA PIU\' DA QUALE TAPPA COMINCIA.');

    final irraggiungibili = <String>[];
    final senzaRamo = <String>[];
    for (final tappa in tappe) {
      if (tappa != prima!.group(1) &&
          !RegExp('_phase = _Phase\\.$tappa\\b').hasMatch(codice)) {
        irraggiungibili.add(tappa);
      }
      if (!codice.contains('case _Phase.$tappa:')) senzaRamo.add(tappa);
    }

    expect(
      irraggiungibili,
      isEmpty,
      reason: 'QUESTE TAPPE DEL RISVEGLIO NON LE ASSEGNA NESSUNO: '
          '${irraggiungibili.join(", ")}.\n'
          'Hanno il loro ramo nello switch e la loro schermata pronta, e '
          'nessuna strada che ci porti. E\' l\'orfano fatto un livello piu\' '
          'giu\': non un file che nessuno importa, una tappa che nessuno '
          'raggiunge.',
    );
    expect(
      senzaRamo,
      isEmpty,
      reason: 'QUESTE TAPPE DEL RISVEGLIO NON HANNO UNA SCHERMATA: '
          '${senzaRamo.join(", ")}.',
    );

    // **E L'ORDINE CHE IL FONDATORE HA CHIESTO**, l'11 settembre 2026: *"la
    // schermata c'e' con l'animale oscurato, ma andrebbe messa dopo la
    // rivelazione degli angeli"*.
    final angeli = tappe.indexOf('angeli');
    final animale = tappe.indexOf('animale');
    expect(angeli, greaterThanOrEqualTo(0),
        reason: 'LA TAPPA DEGLI ANGELI NON C\'E\' PIU\'.');
    expect(animale, angeli + 1,
        reason: 'LA SCHEDA DELL\'ANIMALE NON VIENE SUBITO DOPO GLI ANGELI: '
            'l\'ordine e ${tappe.join(", ")}.\n'
            'Il fondatore lo ha chiesto per nome l\'11 settembre 2026, dopo '
            'aver rifatto l\'onboarding e averla trovata dopo la rivelazione '
            'del Maestro: "andrebbe messa dopo la rivelazione degli angeli".',
    );
  });
}
