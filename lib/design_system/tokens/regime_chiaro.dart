import 'package:flutter/material.dart';

import '../../core/maestro/maestro.dart';
import '../theme/accento_del_maestro.dart';

/// IL SECONDO REGIME CROMATICO DELL'APP, DICHIARATO. Ordine P voce 12.
///
/// **Perche' esiste, e perche' non e' una tolleranza.** Esoteric Circle e'
/// un'app notturna: fondali profondi, oro, testo chiaro. Il Rito dell'Alba fa
/// eccezione, e ha una ragione narrativa che nessun'altra schermata ha: l'alba
/// e' l'unico momento in cui il buio finisce. Buttare via il pannello chiaro
/// per uniformita' impoverirebbe il prodotto.
///
/// **Ma finche' i regimi erano due e uno solo era governato dai token, nessun
/// presidio automatico poteva proteggere l'altro, ed e' cosi' che il difetto
/// e' nato.** I colori del chiaro vivevano come costanti private dentro
/// `ritual_gift_card.dart`, con nomi che non dicevano di essere un regime:
/// `_dayInk`, `_dayInkSoft`, `_dayGlass`. Una costante privata non e' un token:
/// non si enumera, non si misura e non si sorveglia.
///
/// Da qui in poi il regime chiaro ha quattro token, tre soglie dichiarate e un
/// elenco delle schermate che lo usano. Chi dipinge un fondo chiaro lo dichiara
/// qui, e `test/l_alba_si_legge_test.dart` cade col nome della classe se una
/// schermata lo dipinge senza dichiararlo.
class RegimeChiaro {
  const RegimeChiaro._();

  /// LA SUPERFICIE CHIARA, cioe' IL FONDO PEGGIORE CHE IL TESTO TROVA DAVVERO.
  ///
  /// **Non e' il colore del vetro, ed e' qui il difetto vero della voce 12.** Il
  /// vetro dichiara `0xFFFBF4E2`, ma e' semitrasparente al settantotto per
  /// cento sopra una fotografia del sole che sale: cio' che una lettera trova
  /// sotto di se' non e' il vetro, e' la composizione. Misurato sul fotogramma
  /// vero, il fondo reso va da `#FFFFFF` in cima alla scheda a `#B7B8AD` dentro
  /// l'incasso della base, dove sotto passa il mare.
  ///
  /// Finche' il colore degli accenti si calcolava sul vetro DICHIARATO, il conto
  /// tornava e la scheda non si leggeva: 4,5 a 1 sulla carta e 3,39 a 1 a
  /// schermo. Un regime cromatico che non sa su cosa poggia non e' governato,
  /// e' sperato.
  ///
  /// Da qui in poi la superficie dichiarata e' il **caso peggiore misurato**, e
  /// tutti gli inchiostri e gli accenti discendono da lei: dove il fondo e' piu'
  /// chiaro il contrasto e' migliore, non peggiore. Che la dichiarazione resti
  /// vera lo sorveglia `test/l_alba_si_legge_test.dart`, che cade se un fondo
  /// campionato risulta piu' scuro di questo.
  static const Color superficieChiara = Color(0xFFB7B8AD);

  /// Il colore che il vetro DICHIARA, cioe' quello a cui tenderebbe se sotto non
  /// ci fosse niente. Serve alle superfici che poggiano su un fondo noto.
  static const Color vetroDichiarato = AccentoDelMaestro.vetro;

  /// Il vetro come viene DIPINTO, semitrasparente e sfocato: lascia intravedere
  /// la scena sotto. L'alpha vale 0,78.
  static const Color velatura = Color(0xC7FBF4E2);

  /// Il bordo del vetro.
  static const Color bordoDellaVelatura = Color(0x4DFFFFFF);

  /// IL TESTO SU CHIARO: l'inchiostro forte, quello che si legge per intero.
  ///
  /// Contrasto su [superficieChiara]: 11,1 a 1, cioe' oltre il doppio della
  /// soglia di lettura. Non e' generosita': su questa superficie il testo
  /// convive con una scena luminosa che si muove sotto la velatura, e il
  /// margine e' cio' che lo tiene leggibile quando il sole sale.
  static const Color testoSuChiaro = Color(0xFF2A2213);

  /// Il tono di partenza dell'inchiostro muto, quello scelto per il colore.
  static const Color _tonoMuto = Color(0xFF6E5B33);

  /// IL TESTO MUTO SU CHIARO: le note, i valori di servizio.
  ///
  /// **NON E' UN COLORE SCELTO A MANO.** Il tono e' `_tonoMuto`, poi la porta di
  /// [AccentoDelMaestro] lo porta giu' finche' non regge la soglia delle
  /// etichette sulla superficie peggiore. Scritto a mano valeva `0xFF6E5B33`, che
  /// sul vetro dichiarato misurava 4,25 a 1 e sul fondo reso 3,82: due numeri
  /// sotto la soglia, e nessuno dei due si vedeva perche' nessuno li aveva
  /// misurati.
  ///
  /// La soglia e' quella delle ETICHETTE e non quella della lettura, anche se
  /// questo inchiostro serve entrambe: fra due soglie possibili si prende la
  /// piu' severa, altrimenti la stessa costante sarebbe a norma in un punto e
  /// fuori norma in quello accanto.
  static Color get testoMutoSuChiaro =>
      AccentoDelMaestro.portatoSu(_tonoMuto, superficieChiara, sogliaEtichette);

  /// L'ACCENTO SU CHIARO: il colore del Maestro del giorno, portato dove si
  /// legge.
  ///
  /// Passa dalla porta unica di [AccentoDelMaestro], che scurisce il colore
  /// finche' il contrasto non basta. Non si sceglie a mano un colore per Maestro:
  /// e' il modo di sbagliarne uno senza accorgersene.
  static Color accentoSuChiaro(Maestro maestro) =>
      AccentoDelMaestro.su(maestro, superficie: superficieChiara);

  /// La superficie interna, un velo caldo dentro il vetro.
  static const Color incassoSuChiaro = Color(0x14000000);

  // NON ESISTE UN "INCASSO COMPOSTO", e la prima stesura lo aveva.
  //
  // L'idea era comporre il velo dell'incasso sopra [superficieChiara] per avere
  // il fondo vero delle righe della base. Ma [superficieChiara] E' GIA' il caso
  // peggiore misurato, e il caso peggiore e' stato misurato PROPRIO dentro
  // l'incasso della base: comporre il velo una seconda volta contava due volte
  // la stessa cosa, e il conto tornava 3,86 su una soglia di 4,5 per un fondo
  // che a schermo non esiste. Un token che descrive un colore che nessuno vede
  // e' peggio di un token mancante.

  // --- LE TRE SOGLIE, dall'ordine P voce 12 ---

  /// Testo di lettura e di corpo: 4,5 a 1.
  static const double sogliaLettura = 4.5;

  /// Titoli da 24 punti in su, oppure da 19 in grassetto: 3 a 1.
  static const double sogliaTitoli = 3.0;

  /// ETICHETTE: 4,5 a 1 SENZA SCONTI, perche' sono le piu' piccole.
  ///
  /// Vale quanto la lettura e non e' un doppione: sta scritta a parte perche' la
  /// tentazione di applicare alle etichette lo sconto dei titoli e' esattamente
  /// il difetto che l'ordine chiude. Un'etichetta e' piccola, quindi ha bisogno
  /// di piu' contrasto di un titolo, non di meno.
  static const double sogliaEtichette = 4.5;

  /// Da quanti punti un titolo puo' scendere a 3 a 1.
  static const double titoloGrande = 24;

  /// Da quanti punti un titolo in grassetto puo' scendere a 3 a 1.
  static const double titoloGrandeInGrassetto = 19;

  /// Il peso da cui un carattere e' grassetto.
  static const double grassetto = 600;

  /// LA SOGLIA CHE VALE PER UN TESTO, dato il suo ruolo e la sua misura.
  ///
  /// Un punto solo che decide, cosi' il censimento del contrasto e le prove
  /// dell'Alba non possono applicare due regole diverse allo stesso testo.
  static double sogliaPer({
    required bool etichetta,
    required double misura,
    required double peso,
  }) {
    if (etichetta) return sogliaEtichette;
    final grande = misura >= titoloGrande ||
        (misura >= titoloGrandeInGrassetto && peso >= grassetto);
    return grande ? sogliaTitoli : sogliaLettura;
  }
}

/// LE SCHERMATE CHE DIPINGONO UN FONDO CHIARO, dichiarate una per una.
///
/// **Ordine P voce 12: ogni schermata che usa il regime chiaro lo dichiara
/// esplicitamente.** Un elenco scritto si conta e si sorveglia; una convenzione
/// tenuta a memoria no, ed e' esattamente cosi' che il pannello dell'Alba e'
/// rimasto per settimane l'unica superficie chiara dell'app senza che nessun
/// presidio la vedesse.
enum SuperficieChiara {
  /// La scheda del dono **del solo Rito dell'Alba**: e' la superficie chiara
  /// vera e propria, il vetro caldo col testo scuro.
  ///
  /// **NON E' PIU' CONDIVISA CON IL SOFFIO.** Ordine BB voce 09: era la stessa
  /// scheda per tutti e cinque i Doni, ed e' il motivo per cui il fondatore ha
  /// visto il Soffio somigliare all'Alba. Adesso solo l'Alba porta il chiaro,
  /// che e' l'unica ad averne la ragione, e gli altri quattro sono tornati
  /// notturni come il resto dell'app.
  schedaDelDono(
    classe: 'RitualGiftCard',
    file: 'lib/features/rituals/ritual_gift_card.dart',
    perche: 'a gesto compiuto la scena è luce piena e il dono si legge su '
        'vetro chiaro: è il rovescio dell\'invito, chiaro sul buio',
  ),

  /// La riga che dichiara chi parla, montata dentro la scheda del dono e quindi
  /// anche lei sul chiaro.
  rigaDelDono(
    classe: 'RigaDelDono',
    file: 'lib/design_system/components/riga_del_dono.dart',
    perche: 'vive dentro la scheda del dono, quindi eredita la sua superficie: '
        'la riceve dichiarata invece di indovinarla dal tema',
  ),

  /// **L'ABITO DEL RESPONSO, che il chiaro lo SCEGLIE per uno solo.**
  ///
  /// Ordine BB voce 09. E' l'unico punto che decide quale dei cinque Doni
  /// porta il regime chiaro e quali quattro tornano notturni, quindi e' anche
  /// il solo che nomina i token del chiaro fuori dalle schermate. Sta in
  /// questo elenco per la stessa ragione delle altre due: chi tocca il chiaro
  /// si dichiara, se no il presidio non puo' sorvegliarlo.
  abitoDelResponso(
    classe: 'AbitoDelResponso',
    file: 'lib/design_system/theme/abito_del_responso.dart',
    perche: 'decide quale Dono veste di giorno. Per farlo deve nominare i '
        'colori del giorno: e la porta del regime chiaro, non una schermata',
  );

  const SuperficieChiara({
    required this.classe,
    required this.file,
    required this.perche,
  });

  /// Il nome della classe che dipinge il fondo chiaro. La prova cade con questo
  /// nome, non con un messaggio generico.
  final String classe;

  final String file;

  /// Perche' questa schermata ha il diritto di schiarire. Senza una ragione
  /// narrativa una superficie chiara in un'app notturna e' una svista.
  final String perche;
}
