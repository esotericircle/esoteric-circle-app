import '../responsi/filo_della_voce.dart';
import '../rituals/animal_catalog.dart';
import 'i_quattro_viaggi.dart';
import 'la_domanda_del_viaggio.dart';
import 'la_scena_dal_modello.dart';
import 'la_voce_del_mondo_di_sotto.dart';
import 'scena_del_viaggio.dart';

/// **IL RESPONSO DEL VIAGGIO, in un posto solo.** Ordine DI voce 16,
/// 13 settembre 2026.
///
/// La scena, il titolo, i tre paragrafi e il richiamo: tutto cio' che la
/// persona legge quando risale. **Fino all'ordine DI li metteva insieme la
/// schermata**, pezzo per pezzo dentro la risalita e dentro il disegno. La
/// prova a cento discese della voce DI.16 avrebbe dovuto rifare gli stessi
/// passi a mano: una copia che puo' divergere dall'originale senza che nessuno
/// se ne accorga. Allora la prova misurerebbe la copia. Adesso la schermata
/// e la prova chiamano questa funzione: la prova misura cio' che si legge.
///
/// **E il primo difetto l'ha trovato proprio spostandolo qui.** La schermata
/// calcolava il richiamo **dopo** aver segnato nel Diario la discesa di oggi:
/// fra le scene di prima c'era anche quella appena composta. La sua cosa
/// risultava quindi sempre gia' vista. Il richiamo compariva **in cento discese su
/// cento, anche alla prima**: *"Ti era gia' capitato di vedere la chiave"* a
/// chi scendeva per la prima volta. Veniva dall'ordine DE voce 11. Qui
/// [precedenti] sono per contratto le discese di **prima**.
class IlResponsoDelViaggio {
  const IlResponsoDelViaggio._({
    required this.scena,
    required this.titolo,
    required this.paragrafi,
    required this.richiamo,
    required this.dalModello,
  });

  final ScenaDelViaggio scena;
  final String titolo;
  final List<String> paragrafi;

  /// La riga del richiamo, o nulla quando la scena non riprende niente.
  final String? richiamo;

  /// Se i quattro pezzi li ha scelti il modello.
  final bool dalModello;

  /// **I BLOCCHI COME SI LEGGONO**, dall'alto: titolo, risposta, gesto, da dove
  /// viene; poi il richiamo quando c'e'.
  List<String> get blocchi => [titolo, ...paragrafi, if (richiamo != null) richiamo!];

  /// **QUANTE FORME HA LA FRASE CHE CUCE LA SCENA**: otto per ogni grado di
  /// nitidezza, `ScenaDelViaggio.formeIntere` e sorelle.
  static const int quanteForme = 8;

  /// **LA FORMA DELLA SCENA DI OGGI**, dalla storia. Ordine DI voce 16.
  ///
  /// **Una scena che somiglia a una di prima non si racconta con la stessa
  /// frase.** Simile vuol dire con la stessa cosa, che e' il pezzo che torna,
  /// oppure con due pezzi in comune. La prova a cento discese ha trovato
  /// coppie con la stessa cosa, o lo stesso luogo nello stesso momento,
  /// raccontate con la stessa forma: *"Sotto la pioggia arrivi al bivio
  /// insieme al Lupo"* due volte, e la somiglianza sopra il quaranta per
  /// cento. Adesso ogni scena prende la forma la cui scena simile piu'
  /// somigliante e' la meno somigliante, e a parita' quella usata piu'
  /// lontano. La prima stesura trattava tutte le somiglianze allo stesso
  /// modo: con molte scene simili riciclava la forma di una scena con la
  /// stessa cosa e lo stesso momento, e la somiglianza passava il quaranta.
  ///
  /// **Le forme di prima si ricalcolano**, dalla scena piu' vecchia alla piu'
  /// recente, con la stessa regola: il Diario conserva i pezzi, e i pezzi
  /// bastano. [precedenti] dalla piu' recente, come li da' il Diario.
  static int formaDellaScena(
      List<String> oggi, List<List<String>> precedenti) {
    final storia = [...precedenti.reversed, oggi];
    final forme = <int>[];
    for (var i = 0; i < storia.length; i++) {
      // Per ogni forma: quanto somigliava la scena piu' simile che l'ha
      // usata, e quando l'ha usata l'ultima volta.
      final peggiore = <int, int>{};
      final ultimaVolta = <int, int>{};
      for (var j = 0; j < i; j++) {
        final quanto = _quantoSomigliano(storia[j], storia[i]);
        if (quanto < 2) continue;
        final f = forme[j];
        if (quanto > (peggiore[f] ?? 0)) peggiore[f] = quanto;
        ultimaVolta[f] = j;
      }
      final cosa = storia[i].length > 1 ? storia[i][1] : '';
      final partenza = FiloDellaVoce.da([cosa, 'forma']).seme % quanteForme;
      var scelta = partenza;
      for (var k = 1; k < quanteForme; k++) {
        final f = (partenza + k) % quanteForme;
        final pf = peggiore[f] ?? 0;
        final ps = peggiore[scelta] ?? 0;
        if (pf < ps ||
            (pf == ps && (ultimaVolta[f] ?? -1) < (ultimaVolta[scelta] ?? -1))) {
          scelta = f;
        }
      }
      forme.add(scelta);
    }
    return forme.last;
  }

  /// **QUANTO SI SOMIGLIANO DUE SCENE**: i pezzi in comune, e un punto in
  /// piu' se hanno la stessa cosa, che e' il pezzo che si vede e che torna.
  /// Da due in su si somigliano.
  static int _quantoSomigliano(List<String> a, List<String> b) {
    var comuni = 0;
    for (var k = 0; k < a.length && k < b.length; k++) {
      if (a[k] == b[k]) comuni++;
    }
    if (a.length > 1 && b.length > 1 && a[1] == b[1]) comuni++;
    return comuni;
  }

  /// **COMPONE IL RESPONSO DI UNA DISCESA.**
  ///
  /// [dalModello] sono i quattro pezzi del modello quando sono arrivati in
  /// tempo e dentro il vocabolario, ordine DI voce 03; nullo, decide la via
  /// deterministica, che resta la rete di sicurezza. [discesa] e' quante
  /// discese c'erano prima di questa, [giaOggi] quante di queste nello stesso
  /// giorno. [precedenti] sono gli id dei pezzi delle discese di **prima**,
  /// dalla piu' recente, **senza quella di oggi**.
  static IlResponsoDelViaggio componi({
    required PezziScelti? dalModello,
    required String domanda,
    required DateTime giorno,
    required double nitidezza,
    required int discesa,
    required int giaOggi,
    required GuideAnimal animale,
    required TemaDellaDomanda? tema,
    required List<List<String>> precedenti,
  }) {
    // Il nome si dice alla quarta: questa discesa e' ancora da contare.
    final siPuoDire = discesa + 1 >= IQuattroViaggi.quanteDiscese;
    // Senza domanda, nessuna chiusura parla della domanda.
    final conDomanda = tema != null;
    final scena = dalModello != null
        ? ScenaSenzaModello.daiPezzi(
            luogo: dalModello.luogo,
            cosa: dalModello.cosa,
            gesto: dalModello.gesto,
            momento: dalModello.momento,
            domanda: domanda,
            giorno: giorno,
            nitidezza: nitidezza,
            discesa: discesa,
            animale: animale,
            siPuoDire: siPuoDire,
            conDomanda: conDomanda,
          )
        : ScenaSenzaModello.componi(
            domanda: domanda,
            giorno: giorno,
            nitidezza: nitidezza,
            // **IL NUMERO DELLA DISCESA ENTRA NEL SEME.** Ordine DF voce 05:
            // senza, due discese nello stesso giorno con la stessa domanda
            // riportavano su la stessa identica scena, parola per parola.
            discesa: discesa,
            // **L'ANIMALE ENTRA NELLA SCENA**, ordine DI voce 04: sceglie i
            // gesti che il suo corpo sa fare. Dopo la quarta discesa le da'
            // il suo nome.
            animale: animale,
            siPuoDire: siPuoDire,
            conDomanda: conDomanda,
          );
    final id = LaVoceDelMondoDiSotto.temaDi(tema);
    final forma = formaDellaScena(scena.idDeiPezzi, precedenti);
    return IlResponsoDelViaggio._(
      scena: scena,
      dalModello: dalModello != null,
      titolo: LaVoceDelMondoDiSotto.titolo(scena, id,
          giornoDellaDiscesa: giorno, giaOggi: giaOggi),
      paragrafi: LaVoceDelMondoDiSotto.paragrafi(
        scena: scena,
        temaDomanda: id,
        temaInLettere: LaVoceDelMondoDiSotto.temaInLettereDi(tema),
        giornoDellaDiscesa: giorno,
        giaOggi: giaOggi,
        formaDellaScena: forma,
      ),
      // **IL RICHIAMO: questa scena riprende un elemento di una di prima?**
      // Ordine DE voce 11: si guarda cinque scene indietro e non di piu'.
      richiamo: IlRichiamoDelleScene.laRiga(
        precedenti: precedenti,
        oggi: scena.idDeiPezzi,
        nomeDellElemento: scena.cosa.nome,
        quale: 1,
      ),
    );
  }
}
