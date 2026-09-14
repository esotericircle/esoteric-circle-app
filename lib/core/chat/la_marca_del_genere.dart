/// **LA MARCA DEL GENERE, e l'unico punto dove si decide.** Ordine DL voci 01
/// e 02, 14 settembre 2026.
///
/// **DA DOVE NASCE.** Prima di quest'ordine l'app decideva come rivolgersi a
/// una persona in cinque posti diversi: `CourtesyForm.agree`, un secondo enum
/// `AddressForm` che nessuno salvava, due `switch` scritti a mano
/// nell'onboarding e un terzo nel blocco di cortesia del prompt. E il resto
/// dei testi non lo decideva affatto: su centodieci stringhe che dicono a chi
/// legge di essere un uomo o una donna, dieci passavano da una scelta. **La
/// stessa lettura dei Tarocchi diceva "sei scesa" a tutti**, perche' era stata
/// scritta al femminile dentro gruppi estratti a sorte.
///
/// **IL PRINCIPIO, dal fondatore.** Nell'onboarding la persona sceglie e legge
/// l'anteprima: *"Bentornata. Sei arrivata fin qui"*. Chi ha scelto il
/// femminile si aspetta quella voce in tutta l'app. Scrivere tutto al neutro
/// sarebbe stato rapido, e avrebbe trasformato quella scelta in un pulsante
/// finto: **il maschile e il femminile veri si conservano**.
///
/// ## La sintassi della marca
///
/// Tre campi fra quadre, divisi dalla barra verticale, nell'ordine maschile,
/// femminile, neutro: `[o|a|]`. Il risolutore mette al posto della marca il
/// campo della forma scelta; con la forma sconosciuta vale il neutro.
///
/// **Si marca la frase intera quando togliendo la desinenza resta una parola
/// che non esiste**, e il terzo campo porta la riformulazione:
/// `[Sei arrivato|Sei arrivata|Sei qui]`. La marca sulla sola desinenza si usa
/// solo dove il neutro e' una parola vera, ed e' rara.
///
/// **Le quadre e non le graffe**, perche' in Dart le graffe sono gia'
/// l'interpolazione. Una quadra letterale dentro un testo si raddoppia: `[[`
/// e `]]`.
///
/// ## Una regola della lingua italiana
///
/// Il risolutore non sa niente di maschile e femminile: chiede alla
/// [LinguaDellaMarca] quale dei tre campi vale. **Il giorno che l'app parlera'
/// un'altra lingua**, la stessa marca si risolve con le regole di quella
/// lingua; in inglese le tre forme coincidono e la marca sparisce, ed e'
/// [LinguaSenzaGenere].
library;

import 'user_profile.dart';

/// **COME UNA LINGUA SCEGLIE FRA I TRE CAMPI.** Una sola decisione per
/// lingua, e per l'italiano sta in [LinguaItaliana.scegli].
abstract class LinguaDellaMarca {
  const LinguaDellaMarca();

  /// Il campo che vale per [forma], fra [maschile], [femminile] e [neutro].
  String scegli(
    CourtesyForm forma, {
    required String maschile,
    required String femminile,
    required String neutro,
  });
}

/// **L'ITALIANO, e il solo `switch` sulla forma di cortesia che decide una
/// parola.** La prova `il_genere_si_decide_in_un_posto_solo` lo pretende qui e
/// da nessun'altra parte.
class LinguaItaliana extends LinguaDellaMarca {
  const LinguaItaliana();

  @override
  String scegli(
    CourtesyForm forma, {
    required String maschile,
    required String femminile,
    required String neutro,
  }) =>
      switch (forma) {
        CourtesyForm.masculine => maschile,
        CourtesyForm.feminine => femminile,
        // **LA SCELTA NON ANCORA FATTA PARLA NEUTRO**, ordine CF voce 05: il
        // genere non si indovina.
        CourtesyForm.neutral || CourtesyForm.unknown => neutro,
      };
}

/// **UNA LINGUA DOVE LE TRE FORME COINCIDONO**, come l'inglese: la marca
/// sparisce e resta il campo neutro, che li' e' la frase di tutti.
class LinguaSenzaGenere extends LinguaDellaMarca {
  const LinguaSenzaGenere();

  @override
  String scegli(
    CourtesyForm forma, {
    required String maschile,
    required String femminile,
    required String neutro,
  }) =>
      neutro;
}

/// **LA MARCA MALFORMATA**: quadre aperte e non chiuse, o due campi invece di
/// tre. Nelle prove si solleva; in produzione il testo esce com'e', perche'
/// una parentesi in piu' a schermo e' meglio di una schermata rossa. La guardia
/// `le_marche_del_genere_sono_ben_fatte` le cerca tutte prima che partano.
class MarcaMalformata implements Exception {
  MarcaMalformata(this.testo, this.dove);
  final String testo;
  final int dove;

  @override
  String toString() => 'marca del genere malformata al carattere $dove: '
      '"$testo"';
}

/// **LA PORTA DEL GENERE.** Chi stampa un testo che puo' portare una marca lo
/// fa passare da qui.
abstract final class LaMarcaDelGenere {
  /// **LA FORMA DELLA PERSONA CHE STA USANDO L'APP ADESSO.** La tiene
  /// aggiornata `ProfileController`, al caricamento e a ogni cambio di
  /// profilo; finche' nessuno la scrive vale la forma sconosciuta, cioe' il
  /// neutro.
  ///
  /// **Sta qui, e non in ogni schermata**, perche' i testi con la marca sono
  /// dentro i corpora, e un corpus non ha un `BuildContext`: se ogni lettore
  /// dovesse andare a prendersi la forma, il primo che se ne dimenticasse
  /// stamperebbe le quadre.
  static CourtesyForm formaCorrente = CourtesyForm.unknown;

  /// La lingua con cui si risolve. Oggi l'italiano.
  static LinguaDellaMarca lingua = const LinguaItaliana();

  /// **L'UNICA DECISIONE.** `CourtesyForm.agree`, il blocco di cortesia del
  /// prompt e il risolutore passano tutti di qui.
  static String scegli({
    required String maschile,
    required String femminile,
    required String neutro,
    CourtesyForm? forma,
  }) =>
      lingua.scegli(forma ?? formaCorrente,
          maschile: maschile, femminile: femminile, neutro: neutro);

  /// Vero se [testo] contiene almeno una marca.
  static bool haMarche(String testo) {
    for (var i = 0; i < testo.length; i++) {
      if (testo.codeUnitAt(i) != _aperta) continue;
      if (i + 1 < testo.length && testo.codeUnitAt(i + 1) == _aperta) {
        i++;
        continue;
      }
      return true;
    }
    return false;
  }

  /// **RISOLVE LE MARCHE DI [testo], attraversandolo una volta sola.**
  ///
  /// `[[` e `]]` diventano una quadra letterale. Una marca e' tutto cio' che
  /// sta fra una quadra aperta e la sua chiusa, e deve avere tre campi.
  static String risolvi(String testo, {CourtesyForm? forma}) {
    // La via breve: la maggior parte dei testi non ha quadre, e allora non
    // si costruisce niente.
    if (!testo.contains('[') && !testo.contains(']')) return testo;
    final esce = StringBuffer();
    final campi = <String>[];
    StringBuffer? campo;
    var inizio = -1;
    for (var i = 0; i < testo.length; i++) {
      final c = testo.codeUnitAt(i);
      final raddoppiata =
          i + 1 < testo.length && testo.codeUnitAt(i + 1) == c;
      if (campo == null) {
        if (c == _aperta) {
          if (raddoppiata) {
            esce.write('[');
            i++;
            continue;
          }
          campo = StringBuffer();
          campi.clear();
          inizio = i;
          continue;
        }
        if (c == _chiusa) {
          if (raddoppiata) i++;
          esce.write(']');
          continue;
        }
        esce.writeCharCode(c);
        continue;
      }
      // Dentro una marca.
      if (c == _barra) {
        campi.add(campo.toString());
        campo = StringBuffer();
        continue;
      }
      if (c == _chiusa && !raddoppiata) {
        campi.add(campo.toString());
        campo = null;
        if (campi.length != 3) {
          return _malformata(testo, inizio);
        }
        esce.write(scegli(
            maschile: campi[0],
            femminile: campi[1],
            neutro: campi[2],
            forma: forma));
        continue;
      }
      if ((c == _aperta || c == _chiusa) && raddoppiata) {
        campo.writeCharCode(c);
        i++;
        continue;
      }
      if (c == _aperta) return _malformata(testo, i);
      campo.writeCharCode(c);
    }
    if (campo != null) return _malformata(testo, inizio);
    return esce.toString();
  }

  /// **LA MARCA SI SCRIVE ANCHE COSI'**, per chi compone un testo in codice
  /// invece di scriverlo in un corpus.
  static String marca(String maschile, String femminile, String neutro) =>
      '[$maschile|$femminile|$neutro]';

  /// Vero nelle prove: li' una marca malformata deve fermare tutto.
  static bool severa = false;

  static String _malformata(String testo, int dove) {
    if (severa) throw MarcaMalformata(testo, dove);
    return testo;
  }

  static const int _aperta = 0x5B; // [
  static const int _chiusa = 0x5D; // ]
  static const int _barra = 0x7C; // |
}
