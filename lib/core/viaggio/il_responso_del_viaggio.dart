import '../responsi/filo_della_voce.dart';
import '../rituals/animal_catalog.dart';
import 'diario_dei_viaggi.dart';
import 'i_quattro_viaggi.dart';
import 'la_domanda_del_viaggio.dart';
import 'la_scena_dal_modello.dart';
import 'la_voce_del_mondo_di_sotto.dart';
import 'scena_del_viaggio.dart';
import 'le_guardie_del_responso.dart';

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
    required this.risposta,
    required this.gesto,
    required this.fonti,
    required this.oggetto,
  });

  final ScenaDelViaggio scena;
  final String titolo;
  final List<String> paragrafi;

  /// La risposta e l'azione come stanno nei loro elenchi: il Diario le
  /// conserva perche' la voce se le ricordi. Ordine DJ voce 02.
  final String risposta;
  final String gesto;

  /// La riga del richiamo, o nulla quando la scena non riprende niente.
  final String? richiamo;

  /// Se i quattro pezzi li ha scelti il modello.
  final bool dalModello;

  /// **DA QUALE VIA E' NATO OGNI PEZZO**, ordine DL voce 14: vedi
  /// `UnViaggio.fonti`.
  final Map<String, String> fonti;

  /// L'oggetto della domanda, ordine DL voce 08, o nulla.
  final String? oggetto;

  /// **I BLOCCHI COME SI LEGGONO**, dall'alto: titolo, risposta, gesto, da dove
  /// viene; poi il richiamo quando c'e'.
  List<String> get blocchi =>
      [titolo, ...paragrafi, if (richiamo != null) richiamo!];

  /// **LA DISCESA COME SI CONSERVA NEL DIARIO**, coi pezzi della scena e con
  /// cio' che la voce deve ricordarsi: il titolo, la risposta e l'azione.
  /// Ordine DJ voce 02. **La chiamano la schermata e la prova a cento
  /// discese**, e non una copia per ciascuna: se una delle due dimenticasse
  /// un campo, la memoria della voce non lo vedrebbe.
  UnViaggio comeSiConserva({
    required DateTime quando,
    required String domanda,
    required String temaDellaDomanda,
    required String animaleSeguito,
    required double nitidezza,
  }) =>
      UnViaggio(
        quando: quando,
        domanda: domanda,
        temaDellaDomanda: temaDellaDomanda,
        pezzi: scena.idDeiPezzi,
        animaleSeguito: animaleSeguito,
        nitidezza: nitidezza,
        titolo: titolo,
        risposta: risposta,
        gesto: gesto,
        oggetto: oggetto,
        fonti: fonti,
      );

  /// **QUANTE FORME HA LA FRASE CHE CUCE LA SCENA** per ogni grado di
  /// nitidezza: sedici dall'ordine DJ voce 06, e il numero lo dicono gli
  /// elenchi, `ScenaDelViaggio.quanteForme`.
  static int get quanteForme => ScenaDelViaggio.quanteForme;

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
  static int formaDellaScena(List<String> oggi, List<List<String>> precedenti) {
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
            (pf == ps &&
                (ultimaVolta[f] ?? -1) < (ultimaVolta[scelta] ?? -1))) {
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
  /// giorno. [storia] sono le discese di **prima**, dalla piu' recente,
  /// **senza quella di oggi**: i loro pezzi fanno il richiamo e la forma
  /// della scena, i loro titoli, risposte e azioni la memoria della voce,
  /// ordine DJ voce 02.
  static IlResponsoDelViaggio componi({
    required PezziScelti? dalModello,
    required String domanda,
    required DateTime giorno,
    required double nitidezza,
    required int discesa,
    required int giaOggi,
    required GuideAnimal animale,
    required TemaDellaDomanda? tema,
    required List<UnViaggio> storia,
    TestiDelModello scritti = TestiDelModello.nessuno,
    String? oggetto,
    Map<String, String> fontiGiaNote = const {},
  }) {
    final precedenti = [for (final v in storia) v.pezzi];
    // Il nome si dice alla quarta: questa discesa e' ancora da contare. **Da
    // `IQuattroViaggi.siPuoNominare`**, ordine DJ voce 05: qui la regola era
    // riscritta a mano, e la funzione che la dice non la chiamava nessuno.
    final siPuoDire = IQuattroViaggi.siPuoNominare(discesa);
    // Senza domanda, nessuna chiusura parla della domanda.
    final conDomanda = tema != null;
    final id = LaVoceDelMondoDiSotto.temaDi(tema);
    final letti = <ResponsoLetto>[
      for (final v in storia)
        (
          tema: v.temaDellaDomanda,
          titolo: v.titolo,
          risposta: v.risposta,
          gesto: v.gesto,
        ),
    ];
    // **IL TITOLO NON CONTIENE UN PEZZO DELLA SCENA DI QUELLA DISCESA.**
    // Ordine DN voce 03. Il titolo di casa e' obbligato dal mazzo, che non
    // ripete prima di ventiquattro discese: **non si salta il titolo, e' la
    // scena che lo evita**. La scena di riserva salta i pezzi che il titolo
    // nomina; quella del modello tiene il titolo del modello solo se non ne
    // nomina un pezzo, e se nemmeno il titolo di casa regge, si rifa' dalla
    // riserva evitandolo.
    final titoloDiCasa = LaVoceDelMondoDiSotto.titoloDelGiorno(id, giorno,
        giaOggi: giaOggi, letti: letti);
    bool tocca(String t, ScenaDelViaggio s) =>
        LeGuardieDelResponso.titoloToccaLaScena(
            t, LaVoceDelMondoDiSotto.nomiDeiPezzi(s));
    ScenaDelViaggio diRiserva(String titolo) => ScenaSenzaModello.componi(
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
          evita: (pezzo) =>
              LeGuardieDelResponso.titoloToccaLaScena(titolo, [pezzo.nome]),
        );
    ScenaDelViaggio scena;
    String titolo;
    var scenaRifatta = false;
    if (dalModello != null) {
      scena = ScenaSenzaModello.daiPezzi(
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
      );
      if (scritti.titolo != null && !tocca(scritti.titolo!, scena)) {
        titolo = scritti.titolo!;
      } else {
        titolo = titoloDiCasa;
        if (tocca(titolo, scena)) {
          scena = diRiserva(titolo);
          scenaRifatta = true;
        }
      }
    } else {
      titolo = scritti.titolo ?? titoloDiCasa;
      scena = diRiserva(titolo);
    }
    final forma = formaDellaScena(scena.idDeiPezzi, precedenti);
    final voce = LaVoceDelMondoDiSotto.alGiorno(
      scena: scena,
      temaDomanda: id,
      temaInLettere: LaVoceDelMondoDiSotto.temaInLettereDi(tema),
      giornoDellaDiscesa: giorno,
      giaOggi: giaOggi,
      formaDellaScena: forma,
      letti: letti,
      oggettoDellaDomanda: oggetto,
    );
    // **IL TITOLO, LA RISPOSTA E IL GESTO DEL MODELLO**, ordine DL voci 07 e
    // 13: ognuno prende il posto di quello di casa soltanto se ha retto alle
    // guardie. La scena resta dove sta, in fondo, come fonte.
    final paragrafi = [...voce.paragrafi];
    if (scritti.risposta != null && paragrafi.isNotEmpty) {
      paragrafi[0] = scritti.risposta!;
    }
    if (scritti.azione != null && paragrafi.length > 1) {
      paragrafi[1] = LaVoceDelMondoDiSotto.gestoDelModello(scritti.azione!,
          FiloDellaVoce.da([...scena.idDeiPezzi, 'gesto del modello']).seme);
    }
    String fonte(String pezzo, bool dalModello) {
      if (dalModello) return 'modello';
      final scarto = scritti.scarti
          .where((r) => r.pezzo == pezzo)
          .map((r) => r.motivo.name)
          .firstOrNull;
      return scarto == null ? 'riserva' : 'riserva: $scarto';
    }

    final titoloDelModello = scritti.titolo != null && titolo == scritti.titolo;
    const anticipa = 'riserva: titoloAnticipaLaScena';
    final fonti = <String, String>{
      'scena': dalModello == null
          ? 'riserva'
          : scenaRifatta
              ? anticipa
              : 'modello',
      'titolo': scritti.titolo != null && !titoloDelModello
          ? anticipa
          : fonte('titolo', titoloDelModello),
      'risposta': fonte('risposta', scritti.risposta != null),
      'gesto': fonte('azione', scritti.azione != null),
      ...fontiGiaNote,
    };
    return IlResponsoDelViaggio._(
      scena: scena,
      dalModello: dalModello != null && !scenaRifatta,
      titolo: titolo,
      paragrafi: paragrafi,
      // **NEL DIARIO VA CIO' CHE SI E' LETTO**, parola per parola: chi
      // riapre una discesa di sei mesi fa rilegge il testo del modello, e
      // non se ne scrive uno nuovo. Ordine DL voce 07.
      risposta: scritti.risposta ?? voce.risposta,
      gesto: scritti.azione ?? voce.gesto,
      fonti: fonti,
      oggetto: oggetto,
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
