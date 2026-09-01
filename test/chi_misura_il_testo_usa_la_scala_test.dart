import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'codice_senza_testo.dart';
import 'sorgenti_di_lib.dart';

/// **CHI MISURA IL TESTO LO MISURA ALLA SCALA CON CUI LO DIPINGE.**
/// Ordine CM voce 09, famiglia C, 1 settembre 2026.
///
/// **Il difetto, e perche' non lo vedeva nessuno.** Un `TextPainter` senza
/// `textScaler` misura il testo alla scala uno, sempre. Se quella misura serve
/// a decidere uno spazio, un corpo di carattere o una riserva, **il numero che
/// esce descrive un testo che nessuno vedra' mai**: a schermo lo stesso testo
/// viene dipinto alla scala che l'utente ha scelto nel sistema.
///
/// Il guasto e' invisibile a chi sviluppa, perche' chi sviluppa tiene il testo
/// alla scala uno. **Compare soltanto a chi il testo grande ce l'ha davvero**,
/// cioe' esattamente il pubblico di quest'app, che e' mediamente piu' anziano
/// e la misura grande la imposta sul serio.
///
/// **Trovato tre volte in un pomeriggio**, e sempre per caso, guardando i
/// traboccamenti del corredo a scala massima: la riserva del Consulto del
/// Cielo, il corpo del titolo che non si spezza, il metro delle cifre del
/// borsellino. Tre punti lontanissimi fra loro, lo stesso identico errore.
/// **Quando lo stesso errore compare in tre posti che non si conoscono, non e'
/// distrazione: e' che mancava la regola.**
///
/// **Quando invece e' giusto NON passarla.** Chi disegna su una tela a
/// geometria fissa, una ruota, un sigillo, una cartolina da condividere, deve
/// tenere il testo dentro la figura che disegna: li' la scala di sistema
/// romperebbe il disegno invece di aiutare chi legge. Quei casi stanno
/// nell'elenco qui sotto **col loro perche' scritto**, e l'elenco puo' solo
/// accorciarsi.
void main() {
  /// I file che misurano senza la scala, e la ragione per cui e' giusto.
  const perche = <String, String>{
    'lib/design_system/components/natal_wheel.dart':
        'CustomPainter: le etichette dei pianeti stanno dentro l\'anello '
            'disegnato, e l\'anello non si allarga col testo di sistema',
    'lib/features/identity/seal_painter.dart':
        'CustomPainter: il sigillo e\' un disegno, non una schermata',
    'lib/features/maestri/aura/archetype/archetype_wheel.dart':
        'CustomPainter: i nomi degli archetipi stanno sull\'astrolabio',
    'lib/features/maestri/caligo/sigillo/sigillo_intenzione_screen.dart':
        'CustomPainter: le lettere corrono lungo la ruota del sigillo',
    'lib/features/onboarding/primo_approdo.dart':
        'CustomPainter: il velo forato ritaglia una figura disegnata',
    'lib/features/onboarding/widgets/sky_thread.dart':
        'CustomPainter: il filo del cielo e\' un disegno',
    'lib/features/passport/cosmic_passport_screen.dart':
        'CustomPainter: il sigillo del sentiero di vita e\' un disegno',
    'lib/features/santuario/santuario_screen.dart':
        'CustomPainter: la mano che invita al tocco e\' un disegno',
    'lib/features/synastry/mappa_della_distanza.dart':
        'CustomPainter: i nomi stanno dentro la mappa disegnata',
    'lib/design_system/components/vip_frame.dart':
        'Cornice ad arco a geometria fissa: il nome sta nel cartiglio, e il '
            'cartiglio e\' inciso nell\'immagine',
    'lib/features/horoscope/oroscopo_share_card.dart':
        'Immagine da condividere, resa a misura fissa per l\'esportazione: '
            'esce dal telefono e va guardata altrove',
    'lib/features/identity/circle_seal_screen.dart':
        'Immagine da condividere, resa a misura fissa per l\'esportazione',
    'lib/features/santuario/sky_postcard.dart':
        'Cartolina da condividere, resa a misura fissa per l\'esportazione',
    'lib/features/tarot/tarot_cartiglio.dart':
        'Il numero e il nome vanno dentro il cartiglio inciso nell\'artwork, '
            'che ha una misura sua e non si allarga',
    'lib/features/shell/santuario_bottom_bar.dart':
        'Misura pesi RELATIVI fra voci che hanno tutte lo stesso stile: la '
            'scala li moltiplica tutti per lo stesso numero e le proporzioni '
            'restano quelle, quindi qui la scala non cambierebbe niente',
    'lib/design_system/typography/paragrafi_di_lettura.dart':
        'Conta le righe a una larghezza di riferimento per stimare il tempo '
            'di lettura: e\' una misura del testo, non dello spazio a video',
  };

  test('ogni TextPainter passa la scala, o dice perche\' non la passa', () {
    final nudi = <String>[];
    var trovati = 0;

    for (final f in sorgentiDiLib()) {
      final nudo = codiceSenzaTesto(f.readAsStringSync());
      if (!nudo.contains('TextPainter(')) continue;
      trovati++;
      final percorso = f.path.replaceAll(r'\', '/');
      final relativo = percorso.substring(percorso.indexOf('lib/'));
      if (nudo.contains('textScaler:')) continue;
      if (perche.containsKey(relativo)) continue;
      nudi.add(relativo);
    }

    cardinaleMinimo(trovati, 12,
        cosa: 'file che misurano il testo con un TextPainter',
        perche: 'Se non se ne trova piu\' nessuno, o il progetto ha smesso di '
            'misurare il testo, oppure questa guardia sta cercando un nome '
            'che non si usa piu\'.');

    expect(nudi, isEmpty,
        reason: 'QUESTI FILE MISURANO IL TESTO ALLA SCALA UNO e lo dipingono '
            'alla scala del sistema:\n${nudi.join("\n")}\n'
            'Il numero che ne esce descrive un testo che nessuno vedra\' mai, '
            'e il guasto compare **solo a chi il testo grande ce l\'ha '
            'davvero**.\n'
            'Passa `textScaler: MediaQuery.textScalerOf(context)` al '
            'TextPainter. Se invece stai disegnando su una tela a geometria '
            'fissa, e la scala di sistema romperebbe il disegno, scrivi il '
            'file nell\'elenco `perche` di questa prova **con la ragione per '
            'esteso**: una deroga senza ragione e\' un difetto con un '
            'permesso.');
  });

  test('nessuna deroga resta appesa a un file che non misura piu\'', () {
    final morte = <String>[];
    final vivi = <String, String>{};
    for (final f in sorgentiDiLib()) {
      final percorso = f.path.replaceAll(r'\', '/');
      vivi[percorso.substring(percorso.indexOf('lib/'))] =
          codiceSenzaTesto(f.readAsStringSync());
    }

    for (final voce in perche.entries) {
      final sorgente = vivi[voce.key];
      if (sorgente == null) {
        morte.add('${voce.key}: il file non esiste piu\'');
      } else if (!sorgente.contains('TextPainter(')) {
        morte.add('${voce.key}: non misura piu\' niente');
      } else if (sorgente.contains('textScaler:')) {
        morte.add('${voce.key}: ormai la scala la passa, la deroga avanza');
      }
      expect(voce.value.length, greaterThan(30),
          reason: '${voce.key} ha una ragione troppo corta per essere una '
              'ragione: ${voce.value}');
    }

    cardinaleMinimo(perche.length, 10,
        cosa: 'deroghe dichiarate',
        perche: 'Se l\'elenco si svuota questa prova non ha piu\' niente da '
            'controllare, e va tolta invece di restare verde su zero.');
    expect(morte, isEmpty,
        reason: 'queste deroghe non scusano piu'
            '\' niente, e un elenco di '
            'scuse scadute e\' il modo in cui una regola smette di '
            'significare qualcosa:\n${morte.join("\n")}');
  });
}
