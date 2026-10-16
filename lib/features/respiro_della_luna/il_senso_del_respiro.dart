/// **IL SENSO DEL RESPIRO, DETTO A CHI RESPIRA.** Ordine FX, voce FXA.07, 16
/// ottobre 2026.
///
/// Fonte, il fondatore il 16 ottobre 2026: *"l'utente cosa ottiene facendo
/// il Respiro della luna. Quale è il suo beneficio? E viene informato di
/// questo?"*. Il difetto: la schermata partiva con "Tieni premuto per
/// inspirare, lascia per espirare" senza dire perche'; il foglio delle fonti
/// diceva da dove viene il respiro, non a cosa serve; dopo il respiro
/// compariva solo la perla accesa.
///
/// Questo file e' il CORPUS, non la schermata: tre momenti, tutti con la voce
/// di Medora, scritti a mano (nessuna chiamata al modello, regola R2
/// dell'ordine FX).
///
/// 1. **Alla prima apertura** ([IlSensoDelRespiro.primaApertura]): due righe
///    su cosa si ottiene, nel vero. Se la prima apertura e' gia' avvenuta lo
///    dicono [IlSensoDelRespiro.primaAperturaGiaVista] e
///    [IlSensoDelRespiro.segnaPrimaAperturaVista], sulla chiave
///    [IlSensoDelRespiro.chiavePrimaApertura] (prefisso `respiro.`, gia'
///    registrato in `CioCheETuo.prefissi`, nello scarico dei dati e fra le
///    memorie del telefono di `LeMemorieCustodite`).
/// 2. **Prima del respiro** ([IlSensoDelRespiro.rigaPrima]): una riga sul
///    senso della fase di oggi, una per ciascuno dei trenta giorni del ciclo.
/// 3. **Dopo il respiro** ([IlSensoDelRespiro.rigaDopo]): una riga di
///    chiusura, da mostrare insieme alla perla che si accende.
///
/// **IL GIORNO DEL CICLO** e' `GiornoLunare.giornoLunare`, da 1 a 30, contato
/// dall'ultima Luna nuova in giorni civili locali, come lo calcola
/// `IlMotoreLunare.delGiorno` (lo stesso motore del Calendario Lunare e della
/// parola di Medora del Respiro, `LaParolaDiMedoraDelRespiro.diOggi`). La
/// porta [IlSensoDelRespiro.giornoDelCiclo] lo prende da li', senza
/// ricalcolarlo.
///
/// **LE FONTI, VERIFICATE IL 16 OTTOBRE 2026.** Dove una tradizione documenta
/// la lettura di una fase, la riga porta la fonte vera; altrimenti porta la
/// dicitura "chiave di Medora", come il resto del Respiro (il commento in
/// cima a `la_parola_di_medora_del_respiro.dart`).
///
/// - **Plinio il Vecchio, Naturalis Historia**: i passi sul lavoro dei campi
///   secondo la Luna, controllati sul testo latino riportato da Eugene
///   Tavenner, *The Roman Farmer and the Moon*, Transactions of the American
///   Philological Association 49 (1918), pp. 66-82 (penelope.uchicago.edu).
///   XVIII 314: certe semine "silente luna", a Luna che non si vede. XVIII
///   322: nei luoghi umidi si semina nell'interlunio e nei quattro giorni
///   intorno. XVII 108: le canne si piantano a Luna crescente, premute con
///   tutte e due le mani. XVIII 316: giova molto vendemmiare a Luna
///   crescente. XVIII 321: tutto cio' che si taglia, si coglie o si tosa si
///   fa con meno danno a Luna calante. XVII 215: le viti di cui si vuole
///   conservare l'uva si potano a Luna calante. XVI 190-191: il legname si
///   taglia solo dal ventesimo al trentesimo giorno della Luna.
/// - **Dane Rudhyar, The Lunation Cycle (1967)**: le otto fasi della
///   lunazione come tappe di un ciclo (nuova come emersione di un impulso,
///   crescente come spinta contro l'abitudine, primo quarto come crisi
///   nell'azione, gibbosa come perfezionamento, piena come compimento e
///   illuminazione, disseminante come il dare agli altri, ultimo quarto come
///   crisi nella coscienza e riorientamento, balsamica come rilascio e seme
///   del ciclo che viene).
///
/// Il giorno lunare per numero NON porta un significato preso da una fonte:
/// la ricerca della voce FX.07 non ne ha trovata una documentata. Quando una
/// riga nomina un giorno preciso e' perche' una fonte lo nomina (Plinio, dal
/// ventesimo al trentesimo); il resto e' chiave di Medora.
///
/// **LA REGOLA R8 DELL'ORDINE FX**: il respiro e' un rito, mai una terapia.
/// Niente salute, niente promesse sul corpo, nessun esito promesso; mai
/// gioco, sfida o punteggio. Lo pretende
/// `test/il_senso_del_respiro_test.dart`.
library;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/lunario/il_motore_lunare.dart';

/// Una riga di Medora con la sua fonte.
@immutable
class RigaDelSenso {
  const RigaDelSenso(this.testo, this.fonte);

  /// La frase che la persona legge.
  final String testo;

  /// Da dove viene: una fonte di [IlSensoDelRespiro.fontiCitate], oppure
  /// [IlSensoDelRespiro.chiaveDiMedora].
  final String fonte;

  /// Vero se la riga non viene da una fonte citabile.
  bool get eChiaveDiMedora => fonte == IlSensoDelRespiro.chiaveDiMedora;
}

/// Le quattro fasi con cui Medora legge il senso del giorno.
enum FaseDelSenso {
  /// Fare spazio.
  nuova,

  /// Accogliere e far crescere.
  crescente,

  /// Riconoscere cio' che e' maturo.
  piena,

  /// Lasciar andare.
  calante,
}

abstract final class IlSensoDelRespiro {
  /// La dicitura di cio' che non viene da una fonte citabile.
  static const String chiaveDiMedora = 'chiave di Medora';

  static const String _rudhyar = 'Dane Rudhyar, The Lunation Cycle (1967)';
  static const String _plinio = 'Plinio il Vecchio, Naturalis Historia';
  static const String _plinioXVIII314 = '$_plinio, XVIII 314';
  static const String _plinioXVIII322 = '$_plinio, XVIII 322';
  static const String _plinioXVII108 = '$_plinio, XVII 108';
  static const String _plinioXVIII316 = '$_plinio, XVIII 316';
  static const String _plinioXVIII321 = '$_plinio, XVIII 321';
  static const String _plinioXVII215 = '$_plinio, XVII 215';
  static const String _plinioXVI190 = '$_plinio, XVI 190-191';

  /// Le sole fonti che una riga puo' citare: tutte verificate (vedi il
  /// commento in cima al file).
  static const List<String> fontiCitate = [
    _rudhyar,
    _plinioXVIII314,
    _plinioXVIII322,
    _plinioXVII108,
    _plinioXVIII316,
    _plinioXVIII321,
    _plinioXVII215,
    _plinioXVI190,
  ];

  // -------------------------------------------------------------------
  // ALLA PRIMA APERTURA
  // -------------------------------------------------------------------

  /// La prima delle due righe della prima apertura.
  static const String primaRiga =
      'Qui hai un minuto al giorno con la Luna di adesso, quella che sta '
      'sopra la tua città: respiri al suo ritmo, che cambia con la sua fase.';

  /// La seconda delle due righe della prima apertura.
  static const String secondaRiga =
      'La collana ricorda ogni giorno in cui hai respirato con lei, e alla '
      'Luna nuova te la consegno intera, come il ricordo del ciclo che si '
      'chiude.';

  /// Le due righe di Medora alla prima apertura, nell'ordine.
  static const List<String> primaApertura = [primaRiga, secondaRiga];

  /// La chiave delle preferenze che ricorda la prima apertura gia' vista.
  static const String chiavePrimaApertura = 'respiro.primaAperturaVista';

  /// Vero se le due righe della prima apertura sono gia' state mostrate su
  /// questo telefono. Se le preferenze non si leggono risponde falso: meglio
  /// rileggere due righe che non leggerle mai.
  static Future<bool> primaAperturaGiaVista() async {
    try {
      final p = await SharedPreferences.getInstance();
      return p.getBool(chiavePrimaApertura) ?? false;
    } catch (errore) {
      debugPrint('Il senso del Respiro: la prima apertura non si legge '
          '($errore)');
      return false;
    }
  }

  /// Segna la prima apertura come vista. Idempotente.
  static Future<void> segnaPrimaAperturaVista() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(chiavePrimaApertura, true);
    } catch (errore) {
      debugPrint('Il senso del Respiro: la prima apertura non si scrive '
          '($errore)');
    }
  }

  // -------------------------------------------------------------------
  // IL GIORNO DEL CICLO E LA FASE
  // -------------------------------------------------------------------

  /// Il giorno del ciclo di [adesso], da 1 a 30: e'
  /// `IlMotoreLunare.delGiorno(adesso).giornoLunare`, in ora locale.
  static int giornoDelCiclo(DateTime adesso) =>
      IlMotoreLunare.delGiorno(adesso).giornoLunare;

  /// Riporta qualunque intero dentro 1..30 (il motore da' gia' 1..30: la
  /// riduzione protegge solo da un numero fuori dal contratto).
  static int _indice(int giornoDelCiclo) =>
      ((giornoDelCiclo - 1) % 30 + 30) % 30;

  /// La fase con cui Medora legge il giorno: nuova nei giorni 1, 2, 29 e 30;
  /// crescente dal 3 al 13; piena dal 14 al 17; calante dal 18 al 28.
  static FaseDelSenso faseDelGiorno(int giornoDelCiclo) {
    final g = _indice(giornoDelCiclo) + 1;
    if (g <= 2 || g >= 29) return FaseDelSenso.nuova;
    if (g <= 13) return FaseDelSenso.crescente;
    if (g <= 17) return FaseDelSenso.piena;
    return FaseDelSenso.calante;
  }

  /// La riga di Medora PRIMA del respiro, per il giorno del ciclo
  /// [giornoDelCiclo] (1..30).
  static RigaDelSenso rigaPrima(int giornoDelCiclo) =>
      righePrima[_indice(giornoDelCiclo)];

  /// La riga di Medora DOPO il respiro, da mostrare con la perla accesa.
  static RigaDelSenso rigaDopo(int giornoDelCiclo) =>
      righeDopo[_indice(giornoDelCiclo)];

  // -------------------------------------------------------------------
  // PRIMA DEL RESPIRO: una riga per giorno del ciclo, dal primo al trentesimo
  // -------------------------------------------------------------------

  static const List<RigaDelSenso> righePrima = [
    // 1, nuova
    RigaDelSenso(
        'È il primo giorno e la Luna è silente, non si vede: Plinio racconta '
        'che certe semine si facevano proprio così. Oggi fai spazio, e lascia '
        'che il seme resti al buio.',
        _plinioXVIII314),
    // 2, nuova
    RigaDelSenso(
        'Dane Rudhyar legge questi giorni come l\'emersione di un impulso '
        'nuovo, prima ancora che abbia un nome. Fai spazio e lascialo '
        'affiorare.',
        _rudhyar),
    // 3, crescente
    RigaDelSenso(
        'Il primo filo di luce torna a vedersi. Accogli una cosa piccola, una '
        'sola, e portala con te nel respiro.',
        chiaveDiMedora),
    // 4, crescente
    RigaDelSenso(
        'Plinio scrive che le canne si piantavano a Luna crescente, premute in '
        'terra con tutte e due le mani. Oggi pianta anche tu un\'intenzione, '
        'con attenzione e senza fretta.',
        _plinioXVII108),
    // 5, crescente
    RigaDelSenso(
        'Nella fase che Rudhyar chiama crescente la luce nuova si fa strada '
        'contro l\'abitudine di prima. Dai al tuo inizio un po\' di spinta, a '
        'ogni inspiro.',
        _rudhyar),
    // 6, crescente
    RigaDelSenso(
        'La falce si allarga sera dopo sera. Chiediti cosa vuoi veder '
        'crescere, e respira verso quella cosa.',
        chiaveDiMedora),
    // 7, crescente
    RigaDelSenso(
        'Una settimana dalla Luna nuova, e la luce è quasi a metà. Accogli '
        'quello che è arrivato in questi giorni, anche se è ancora acerbo.',
        chiaveDiMedora),
    // 8, crescente
    RigaDelSenso(
        'Si avvicina il primo quarto, che Rudhyar legge come una crisi '
        'nell\'azione: il momento in cui si sceglie di costruire. Respira e '
        'scegli il prossimo passo.',
        _rudhyar),
    // 9, crescente
    RigaDelSenso(
        'Metà disco in luce e metà al buio: oggi la Luna tiene insieme le due '
        'cose. Fai crescere ciò che hai scelto, e lascia il resto in attesa.',
        chiaveDiMedora),
    // 10, crescente
    RigaDelSenso(
        'È il tempo del primo quarto, la decisione che Rudhyar vede in questa '
        'fase: ciò che hai cominciato chiede una forma. Dagliela con calma, a '
        'ogni respiro.',
        _rudhyar),
    // 11, crescente
    RigaDelSenso(
        'La luce supera il buio. Accogli l\'aiuto che arriva, le parole buone, '
        'le occasioni piccole: anche loro fanno crescere.',
        chiaveDiMedora),
    // 12, crescente
    RigaDelSenso(
        'Rudhyar legge la Luna gibbosa come il tempo del perfezionare: si '
        'rifinisce, si aggiusta, si dà ancora un po\' di tempo. Respira sul '
        'dettaglio che conta.',
        _rudhyar),
    // 13, crescente
    RigaDelSenso(
        'Plinio annota che giova molto vendemmiare a Luna crescente: il frutto '
        'si coglie mentre la luce sale. Oggi cogli anche tu una cosa buona, '
        'prima della piena.',
        _plinioXVIII316),
    // 14, piena
    RigaDelSenso(
        'La Luna è quasi tonda. Comincia a guardare cosa è maturato da quando '
        'era nuova, senza ancora giudicarlo.',
        chiaveDiMedora),
    // 15, piena
    RigaDelSenso(
        'È la Luna piena, che Rudhyar chiama compimento e illuminazione: ciò '
        'che era seme adesso si vede. Riconosci quello che è maturo, e '
        'respiralo.',
        _rudhyar),
    // 16, piena
    RigaDelSenso(
        'Tutta la luce è fuori, niente resta in ombra. Oggi guarda una cosa di '
        'te con chiarezza, e dalle il suo nome.',
        chiaveDiMedora),
    // 17, piena
    RigaDelSenso(
        'Rudhyar dice che alla piena si vede con occhi oggettivi, come davanti '
        'a uno specchio. Riconosci ciò che hai portato a compimento in questo '
        'ciclo.',
        _rudhyar),
    // 18, calante
    RigaDelSenso(
        'Plinio scrive che tutto ciò che si taglia, si coglie o si tosa si fa '
        'con meno danno a Luna calante. Oggi comincia a lasciar andare ciò che '
        'non ti serve più.',
        _plinioXVIII321),
    // 19, calante
    RigaDelSenso(
        'La luce comincia a ritirarsi dal bordo. Respira più a lungo '
        'sull\'espiro, e lascia che qualcosa se ne vada insieme al fiato.',
        chiaveDiMedora),
    // 20, calante
    RigaDelSenso(
        'Rudhyar chiama disseminante questa fase: ciò che hai capito si dà '
        'agli altri. Lascia andare un consiglio, un grazie, una parola che '
        'tenevi per te.',
        _rudhyar),
    // 21, calante
    RigaDelSenso(
        'Plinio riferisce che il legname si tagliava solo dal ventesimo al '
        'trentesimo giorno della Luna. Sei dentro quei giorni: scegli un ramo '
        'secco della tua settimana e lascialo cadere.',
        _plinioXVI190),
    // 22, calante
    RigaDelSenso(
        'La Luna cala e sorge più tardi ogni notte. Lascia che anche i '
        'pensieri arrivino più lenti, e non trattenerli.',
        chiaveDiMedora),
    // 23, calante
    RigaDelSenso(
        'Si arriva all\'ultimo quarto, che Rudhyar legge come una crisi nella '
        'coscienza: si rivede ciò in cui si crede. Lascia andare un\'idea che '
        'non ti somiglia più.',
        _rudhyar),
    // 24, calante
    RigaDelSenso(
        'Plinio ricorda che le viti di cui si voleva conservare l\'uva si '
        'potavano a Luna calante. Pota anche tu: togli una cosa, perché quello '
        'che resta duri.',
        _plinioXVII215),
    // 25, calante
    RigaDelSenso(
        'Di nuovo metà disco, ma rivolto verso l\'alba. Lascia andare un '
        'impegno che porti soltanto per abitudine.',
        chiaveDiMedora),
    // 26, calante
    RigaDelSenso(
        'Rudhyar vede in questi giorni un riorientamento: ci si volta verso '
        'ciò che verrà. Lascia andare la strada vecchia, almeno per il tempo '
        'di un respiro.',
        _rudhyar),
    // 27, calante
    RigaDelSenso(
        'Comincia la fase che Rudhyar chiama balsamica, il tempo del rilascio '
        'e del seme per il ciclo che viene. Lascia andare, e tieni solo ciò '
        'che vuoi seminare.',
        _rudhyar),
    // 28, calante
    RigaDelSenso(
        'Resta una falce sottile, visibile solo prima dell\'alba. Lascia '
        'andare le ultime cose di questo ciclo, una per ogni espiro.',
        chiaveDiMedora),
    // 29, nuova
    RigaDelSenso(
        'Plinio consiglia di seminare i luoghi umidi nell\'interlunio e nei '
        'quattro giorni intorno. L\'interlunio è vicino: fai spazio, come si '
        'libera la terra prima della semina.',
        _plinioXVIII322),
    // 30, nuova
    RigaDelSenso(
        'La Luna sta per sparire nella luce del Sole. Fai spazio dentro di te: '
        'fra poco si ricomincia.',
        chiaveDiMedora),
  ];

  // -------------------------------------------------------------------
  // DOPO IL RESPIRO: una riga per giorno del ciclo, con la perla accesa
  // -------------------------------------------------------------------

  static const List<RigaDelSenso> righeDopo = [
    // 1
    RigaDelSenso(
        'La prima perla di un ciclo nuovo è accesa. Lo spazio che hai fatto '
        'oggi resta, anche al buio.',
        chiaveDiMedora),
    // 2
    RigaDelSenso(
        'Hai respirato con una Luna che ancora non si vede: la perla di oggi '
        'lo ricorda per te.',
        chiaveDiMedora),
    // 3
    RigaDelSenso(
        'La perla di oggi brilla col primo filo di luce. Porta con te la cosa '
        'piccola che hai accolto.',
        chiaveDiMedora),
    // 4
    RigaDelSenso(
        'Hai piantato il tuo respiro nel giorno in cui la luce torna. La perla '
        'lo tiene.',
        chiaveDiMedora),
    // 5
    RigaDelSenso(
        'Un\'altra perla, un altro passo della luce. Quello che hai cominciato '
        'ha un giorno in più.',
        chiaveDiMedora),
    // 6
    RigaDelSenso(
        'La falce cresce, e la collana con lei. La Luna di domani sarà un poco '
        'più larga.',
        chiaveDiMedora),
    // 7
    RigaDelSenso(
        'Una settimana di luce dalla Luna nuova: la perla di oggi ne porta il '
        'segno.',
        chiaveDiMedora),
    // 8
    RigaDelSenso(
        'La perla di oggi sta sulla soglia del primo quarto. Il passo che hai '
        'scelto è tuo.',
        chiaveDiMedora),
    // 9
    RigaDelSenso(
        'Metà luce e metà ombra, e una perla in più. Hai respirato con tutte e '
        'due.',
        chiaveDiMedora),
    // 10
    RigaDelSenso(
        'Hai dato una forma al tuo respiro: la perla di oggi la custodisce.',
        chiaveDiMedora),
    // 11
    RigaDelSenso('La luce ha superato il buio, e la tua collana se lo ricorda.',
        chiaveDiMedora),
    // 12
    RigaDelSenso(
        'Una perla per il giorno in cui si rifinisce. Quello che hai aggiustato '
        'oggi conta.',
        chiaveDiMedora),
    // 13
    RigaDelSenso(
        'Hai colto la tua cosa buona prima della piena. La perla di oggi è '
        'sua.',
        chiaveDiMedora),
    // 14
    RigaDelSenso(
        'La Luna è quasi tonda e la collana si allunga. Domani la luce sarà '
        'ancora di più.',
        chiaveDiMedora),
    // 15
    RigaDelSenso(
        'Hai respirato con la Luna piena. La perla di oggi porta tutta la sua '
        'luce.',
        chiaveDiMedora),
    // 16
    RigaDelSenso(
        'Hai dato un nome a ciò che è chiaro. La perla lo tiene con sé.',
        chiaveDiMedora),
    // 17
    RigaDelSenso(
        'Ciò che hai portato a compimento ha la sua perla. Guardala quando '
        'vuoi.',
        chiaveDiMedora),
    // 18
    RigaDelSenso(
        'È la prima perla della luce che cala. Ciò che hai lasciato andare non '
        'pesa sulla collana.',
        chiaveDiMedora),
    // 19
    RigaDelSenso(
        'Hai respirato con l\'espiro lungo. La perla di oggi è leggera.',
        chiaveDiMedora),
    // 20
    RigaDelSenso(
        'Hai dato qualcosa di tuo agli altri, almeno nel pensiero: la perla lo '
        'ricorda.',
        chiaveDiMedora),
    // 21
    RigaDelSenso(
        'Il ramo secco è caduto, la perla di oggi resta.', chiaveDiMedora),
    // 22
    RigaDelSenso(
        'La Luna sorge più tardi, e il tuo respiro l\'ha aspettata. Una perla '
        'in più.',
        chiaveDiMedora),
    // 23
    RigaDelSenso(
        'All\'ultimo quarto hai lasciato un\'idea vecchia. La perla di oggi è '
        'nuova.',
        chiaveDiMedora),
    // 24
    RigaDelSenso(
        'Hai potato, e quello che resta ha più spazio. La perla lo segna.',
        chiaveDiMedora),
    // 25
    RigaDelSenso('Un impegno in meno, una perla in più.', chiaveDiMedora),
    // 26
    RigaDelSenso(
        'Il tuo respiro si è voltato verso ciò che verrà. La perla di oggi '
        'guarda avanti.',
        chiaveDiMedora),
    // 27
    RigaDelSenso(
        'Una perla della fase balsamica, il tempo del seme. Tienila per il '
        'ciclo che viene.',
        _rudhyar),
    // 28
    RigaDelSenso(
        'Le ultime cose di questo ciclo se ne sono andate col respiro. La '
        'collana è quasi chiusa.',
        chiaveDiMedora),
    // 29
    RigaDelSenso(
        'Hai fatto spazio prima della semina. La perla di oggi aspetta con te '
        'la Luna nuova.',
        chiaveDiMedora),
    // 30
    RigaDelSenso(
        'L\'ultima perla del ciclo è accesa: la lunazione si chiude, e la '
        'collana con lei.',
        chiaveDiMedora),
  ];
}
