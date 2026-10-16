import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:esoteric_circle/core/sensi/catalogo_musiche.dart';
import 'package:esoteric_circle/core/sensi/catalogo_suoni.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL SUONO DICE IL VERO.** Ordine CN voci 01, 02, 04 e 06.
///
/// **Perche' la misura sta in un registro e non qui dentro.** Una prova Dart
/// non puo' misurare la sonorita' di un MP3: servirebbe ffmpeg sulla macchina
/// che prova, e una guardia che si dichiara non eseguita quando ffmpeg manca
/// sarebbe verde proprio dove serve. La misura si fa una volta, con lo
/// strumento giusto, e si scrive in `docs/sonorita.json`.
///
/// **E il registro non e' aggirabile**, perche' porta l'impronta di ogni file.
/// Chi sostituisce un asset senza rimisurarlo fa cadere questa prova, invece di
/// ereditare la misura di un file che non c'e' piu'. **E' la differenza fra un
/// registro e un ricordo.**
void main() {
  final registro = json.decode(
    File('docs/sonorita.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  Map<String, dynamic> voceDi(String famiglia, String file) =>
      (registro[famiglia] as Map<String, dynamic>)[file]
          as Map<String, dynamic>;

  String improntaDi(File f) => sha1.convert(f.readAsBytesSync()).toString();

  test('ogni suono del catalogo ha il suo file, e ogni file un suo suono', () {
    final suiDischi = Directory('assets/audio')
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .where((n) => n.endsWith('.mp3'))
        .toSet();
    cardinaleMinimo(suiDischi.length, 13,
        cosa: 'effetti sonori dentro assets/audio',
        perche: 'Il catalogo ne dichiara tredici: se sul disco ce ne sono '
            'meno, questa prova sta guardando una cartella che si e\' '
            'svuotata.');

    final senzaFile = <String>[];
    for (final s in SuonoDelCerchio.values) {
      if (!suiDischi.contains(s.file)) senzaFile.add(s.file);
    }
    expect(senzaFile, isEmpty,
        reason: 'IL CATALOGO PROMETTE SUONI CHE NON ESISTONO: $senzaFile.\n'
            'Il motore ha il ripiego silenzioso, quindi non si rompe niente '
            'e non si sente niente: e\' esattamente come `pietra.mp3` ha '
            'vissuto venticinque giorni, dichiarata e muta.');

    final nomiDelCatalogo = SuonoDelCerchio.values.map((s) => s.file).toSet();
    final orfani = suiDischi.difference(nomiDelCatalogo);
    expect(orfani, isEmpty,
        reason: 'QUESTI FILE NON SONO NEL CATALOGO: $orfani.\n'
            'Un asset che nessuno dichiara pesa nell\'archivio e non suona '
            'da nessuna parte, oppure suona da un posto che ha aggirato il '
            'catalogo, che e\' peggio.');
  });

  test('ogni anello d\'ambiente ha il suo file, e viceversa', () {
    final suiDischi = Directory('assets/music')
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .where((n) => n.endsWith('.mp3'))
        .toSet();
    cardinaleMinimo(suiDischi.length, 4,
        cosa: 'anelli d\'ambiente dentro assets/music');
    expect(suiDischi, MusicaDelCerchio.values.map((m) => m.file).toSet(),
        reason: 'l\'elenco sul disco e quello del catalogo non coincidono');
  });

  test('la sonorita\' di ogni effetto sta dentro la tolleranza', () {
    final bersaglio = registro['bersaglioEffetti'] as num;
    final tolleranza = registro['tolleranzaEffetti'] as num;
    final fuori = <String>[];
    var misurati = 0;

    for (final s in SuonoDelCerchio.values) {
      final v = voceDi('effetti', s.file);
      final sonorita = v['sonorita'] as num?;
      if (sonorita == null) {
        // **NON E' UNA DEROGA DI COMODO, E' UN FATTO DELLA MISURA.** La
        // sonorita' momentanea si calcola su una finestra di 400 ms: un
        // suono piu' breve non ne ha una. Per lui vale il picco, e il
        // registro deve dirlo invece di tacere.
        expect(v['sottoLaFinestra'], isTrue,
            reason: '${s.file} non ha una sonorita\' misurata e non dichiara '
                'di essere sotto la finestra: e\' una misura mancante, non '
                'una misura che non esiste');
        expect(v['picco'], isNotNull,
            reason: '${s.file} senza nemmeno il picco');
        continue;
      }
      misurati++;
      // **CHI ACCOMPAGNA STA SOTTO CHI ANNUNCIA, e si dichiara per nome.**
      // Ordine CO voce 04, 3 settembre 2026.
      //
      // Il fondatore ha sentito le monete troppo forti sul telefono, e le
      // misure gli davano torto: `eos` stava a -16,29, cioe' in famiglia con
      // tutti gli altri. **Aveva ragione lui, e il numero non era sbagliato:
      // era la grandezza a non dire la cosa giusta per questo suono.**
      //
      // La sonorita' momentanea pesa lo spettro come lo pesa l'orecchio in
      // media, e undici degli altri dodici suoni sono tenute e code, dove
      // quella media funziona. Le monete sono due secondi di transienti
      // brillanti fitti, e a parita' di numero l'orecchio le sente piu' forti.
      // Il picco lo diceva gia': -1,9 contro i -4,7 e -7,8 delle tenute.
      //
      // **E c'e' la ragione di specie, che e' quella vera.** Gli altri suoni
      // ANNUNCIANO: una soglia varcata, un responso arrivato, un rito
      // compiuto. Questo ACCOMPAGNA, e accompagna una cosa che si guarda,
      // il volo delle monete verso il borsellino a festa chiusa. Un
      // accompagnamento che si sente quanto un annuncio si mette davanti a
      // cio' che accompagna.
      //
      // Percio' `eos` sta a -20,91, quattro decibel e sei sotto dov'era, e
      // resta l'unico nome in questa lista. **Un secondo nome qui dentro
      // deve portare la sua ragione scritta**, come questo: la lista esiste
      // per costringere a scriverla, non per far passare i file scomodi.
      const accompagnanoInveceDiAnnunciare = {SuonoDelCerchio.eos};
      if (accompagnanoInveceDiAnnunciare.contains(s)) {
        expect(sonorita, lessThan(bersaglio - tolleranza),
            reason: '${s.file} e\' dichiarato fra quelli che accompagnano, e '
                'sta dentro la famiglia di quelli che annunciano: o e\' '
                'tornato forte, o non aveva bisogno di stare in questa lista');
        continue;
      }
      if ((sonorita - bersaglio).abs() > tolleranza) {
        fuori.add('${s.file}: $sonorita LUFS-M, bersaglio $bersaglio');
      }
    }

    cardinaleMinimo(misurati, 12,
        cosa: 'effetti con una sonorita\' misurata',
        perche: 'Se il registro smette di misurarli, questa prova non trova '
            'nessuno fuori tolleranza perche\' non ha guardato nessuno.');
    expect(fuori, isEmpty,
        reason: 'QUESTI EFFETTI SONO FUORI SCALA:\n${fuori.join("\n")}\n'
            'Sui file di origine lo scarto fra il piu\' forte e il piu\' '
            'debole era di quindici decibel e mezzo: il sigillo del '
            'Custodisci non si sentiva e le pietre facevano saltare in aria. '
            'Non si allarga questa tolleranza: si rinormalizza il file.');
  });

  test('la musica sta piu\' in basso degli effetti, di sette decibel', () {
    final musica = registro['bersaglioMusica'] as num;
    final effetti = registro['bersaglioEffetti'] as num;
    expect(effetti - musica, greaterThanOrEqualTo(5),
        reason: 'la musica non sta piu\' abbastanza sotto gli effetti: il '
            'rapporto fra i due deve essere gia\' giusto PRIMA che i cursori '
            'intervengano, e non e\' compito di chi ascolta rimediare');

    final tolleranza = registro['tolleranzaMusica'] as num;
    for (final m in MusicaDelCerchio.values) {
      final v = voceDi('musica', m.file);
      expect((v['sonorita'] as num) - musica, lessThan(tolleranza + 0.5),
          reason: '${m.file} sta a ${v['sonorita']} contro un bersaglio di '
              '$musica');
    }
  });

  test('gli anelli girano davvero, cioe\' la giunta non fa un salto', () {
    final tolleranza = registro['tolleranzaGiunta'] as num;
    final saltano = <String>[];
    for (final m in MusicaDelCerchio.values) {
      final v = voceDi('musica', m.file);
      final scarto = v['scartoDellaGiunta'] as num;
      if (scarto > tolleranza) saltano.add('${m.file}: $scarto dB');
    }
    expect(saltano, isEmpty,
        reason: 'A OGNI GIRO QUESTI ANELLI SI FERMANO E RIPARTONO, E SI '
            'SENTE:\n${saltano.join("\n")}\n'
            'Prima dell\'ordine CN tre su quattro attaccavano di colpo e '
            'sfumavano a zero: Medora saltava di 65 decibel, Caligo di 63, '
            'la home di 30. Si chiude l\'anello con una dissolvenza '
            'incrociata, non si allarga questa tolleranza.');
  });

  test('il registro misura i file che ci sono adesso, non quelli di ieri', () {
    final scaduti = <String>[];
    var confrontati = 0;
    for (final famiglia in const [
      ('effetti', 'assets/audio'),
      ('musica', 'assets/music'),
    ]) {
      final voci = registro[famiglia.$1] as Map<String, dynamic>;
      for (final voce in voci.entries) {
        final f = File('${famiglia.$2}/${voce.key}');
        if (!f.existsSync()) {
          scaduti.add('${voce.key}: il registro lo misura, il file non c\'e\'');
          continue;
        }
        confrontati++;
        final vera = improntaDi(f);
        final scritta = (voce.value as Map<String, dynamic>)['sha1'];
        if (vera != scritta) {
          scaduti.add('${voce.key}: il file e\' cambiato dopo la misura');
        }
      }
    }
    cardinaleMinimo(confrontati, 17,
        cosa: 'asset sonori riaperti e confrontati con la loro impronta',
        perche: 'Questa prova vive dei file che apre: se il registro non ne '
            'nomina piu\' nessuno, non trova disallineamenti perche\' non ha '
            'confrontato niente.');
    expect(scaduti, isEmpty,
        reason: 'IL REGISTRO SONORO NON DESCRIVE PIU\' I FILE '
            'VERI:\n${scaduti.join("\n")}\n'
            'Rigenera le misure invece di correggere il registro a mano: una '
            'cifra aggiustata a mano vale quanto nessuna cifra.');
  });

  test('i due respiri dichiarano la durata VERA, coi silenzi tolti', () {
    for (final coppia in const [
      (SuonoDelCerchio.respiroDentro, 4.9),
      (SuonoDelCerchio.respiroFuori, 6.8),
    ]) {
      final v = voceDi('effetti', coppia.$1.file);
      final vera = (v['durata'] as num).toDouble();
      final dichiarata = coppia.$1.durataAttesa.inMilliseconds / 1000.0;
      expect((vera - dichiarata).abs(), lessThan(0.05),
          reason: '${coppia.$1.file} dura $vera secondi e il catalogo ne '
              'dichiara $dichiarata.\n'
              '**QUESTO NUMERO NON E\' DECORATIVO**: e\' quello con cui si '
              'accorda la velocita\' di riproduzione alla fase che la figura '
              'sta disegnando. Se mente, il suono del respiro e la figura che '
              'si espande dicono due cose diverse nello stesso istante, che '
              'e\' il difetto gia\' corretto nel Soffio del Destino.');
      expect(vera, greaterThan(coppia.$2),
          reason: '${coppia.$1.file} si e\' accorciato: dentro il file di '
              'origine il respiro vero durava ${coppia.$2} secondi e il '
              'resto era silenzio');
    }
  });

  test(
      'gli effetti restano sotto il mezzo megabyte, la musica si conta a '
      'parte', () {
    var effetti = 0;
    for (final f in Directory('assets/audio').listSync().whereType<File>()) {
      if (f.path.endsWith('.mp3')) effetti += f.lengthSync();
    }
    var musica = 0;
    for (final f in Directory('assets/music').listSync().whereType<File>()) {
      if (f.path.endsWith('.mp3')) musica += f.lengthSync();
    }

    expect(effetti, greaterThan(200000),
        reason: 'gli effetti pesano $effetti byte in tutto: sono troppo '
            'pochi perche\' i tredici ci siano davvero');
    expect(effetti, lessThan(512000),
        reason: 'GLI EFFETTI SFONDANO IL MEZZO MEGABYTE: $effetti byte. '
            'Sono suoni puntuali in mono, e se crescono cosi\' o qualcuno li '
            'ha messi in stereo o ne ha aggiunti senza contarli.');

    // **I DUE PESI NON SI SOMMANO IN UN BUDGET SOLO**, ordine CN voce 10: la
    // musica pesa venti volte gli effetti, e un tetto unico nasconderebbe
    // tutti e due. Qui si guardano separati, e il numero della musica sta
    // scritto perche' qualcuno lo legga, non per farlo passare.
    expect(musica, lessThan(9000000),
        reason: 'i quattro anelli pesano $musica byte, oltre i nove megabyte '
            'previsti: o ne e\' entrato un quinto, o qualcuno li ha '
            'riconvertiti a un bitrate piu\' alto');
  });
}
