import '../archetypes/archetype.dart';
import '../astro/zodiac.dart';
import '../identity/birth_identity.dart';
import '../rituals/animal_catalog.dart';
import '../rituals/carta_di_nascita_dei_tarocchi.dart';
import '../rituals/runes.dart';
import 'i_nomi_iniziatici.dart';

/// **IL NOME INIZIATICO, ordine EY voce 01.** Il nome che il Cerchio propone
/// a chi arriva, nel campo gia' compilato: "Questo è il nome che il Cerchio ti
/// ha dato: tienilo, oppure scrivine uno tuo".
///
/// **Tre parti**: un appellativo, un simbolo, una qualita'. Il simbolo si
/// pesca dai set che il progetto possiede gia', e dove la persona ha un suo
/// simbolo per nascita si prende quello: il segno solare, l'animale guida del
/// segno, la carta di nascita dei Tarocchi. Le rune e gli archetipi si
/// pescano dal seme.
///
/// **Deterministico dai dati che l'app ha gia'**: la stessa nascita da' lo
/// stesso nome. Il `tentativo` serve al pulsante che ne chiede un altro.
///
/// **Il nome proposto non contiene mai il nome proprio della persona**, e sta
/// sempre nei venti caratteri del nome del Cerchio.
abstract final class IlNomeIniziatico {
  static const int lunghezzaMassima = 20;

  /// I simboli di una famiglia, per la persona.
  static List<String> _simboli(int famiglia, BirthIdentity? identita) {
    final segno = identita?.sunSign;
    switch (famiglia) {
      case 0:
        return segno != null
            ? [segno.italianName]
            : [for (final z in Zodiac.values) z.italianName];
      case 1:
        // **L'ANIMALE GUIDA NON SI SVELA QUI.** Si dice dopo le quattro
        // discese del Viaggio: il nome pesca fra tutti e dodici, mai
        // quello della persona derivato dal segno (la guardia
        // `l_animale_resta_velato_ovunque` lo ha trovato).
        return [for (final a in AnimalCatalog.animals) a.name];
      case 2:
        if (identita != null && !identita.isExample) {
          final n =
              CartaDiNascitaDeiTarocchi.cartaDi(identita.birthDate).majorNumber;
          final breve = INomiIniziatici.arcaniBrevi[n];
          if (breve != null) return [breve];
        }
        return INomiIniziatici.arcaniBrevi.values.toList();
      case 3:
        return [for (final r in kElderFuthark) r.name];
      default:
        return [for (final a in Archetype.values) a.nome];
    }
  }

  /// Il seme dalla nascita: data, ora se c'e', luogo se c'e'. Senza nascita
  /// il seme e' zero, e il nome resta comunque uno solo e sempre lo stesso.
  static int seme(BirthIdentity? identita) {
    if (identita == null) return 0;
    final m = identita.birthMoment;
    final luogo = identita.birthPlace;
    final testo = [
      m.year,
      m.month,
      m.day,
      if (identita.hasBirthTime) ...[m.hour, m.minute],
      if (luogo != null) ...[
        (luogo.latitude * 100).round(),
        (luogo.longitude * 100).round(),
      ],
    ].join('|');
    // FNV-1a a 32 bit: uguale su ogni telefono e in ogni versione di Dart,
    // a differenza di hashCode.
    var h = 0x811c9dc5;
    for (final c in testo.codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0xffffffff;
    }
    return h;
  }

  /// La forma per il confronto col nome proprio: minuscole senza accenti,
  /// solo lettere.
  static String _piana(String s) {
    const accenti = {
      'à': 'a', 'á': 'a', 'è': 'e', 'é': 'e', 'ì': 'i', 'í': 'i', //
      'ò': 'o', 'ó': 'o', 'ù': 'u', 'ú': 'u',
    };
    final b = StringBuffer();
    for (final c in s.toLowerCase().split('')) {
      b.write(accenti[c] ?? c);
    }
    return b.toString().replaceAll(RegExp('[^a-z]'), '');
  }

  /// Il nome proposto. [nomeProprio] e' il nome che la persona ha scritto nel
  /// campo sopra: il nome iniziatico non lo contiene mai. Un nome proprio di
  /// una o due lettere non si cerca dentro le parole, dove starebbe ovunque
  /// senza essere riconoscibile.
  static String per({
    BirthIdentity? identita,
    String? nomeProprio,
    int tentativo = 0,
  }) {
    final s = seme(identita) + tentativo * 7919;
    final proprio = _piana(nomeProprio ?? '');
    final famiglia = s % 5;
    // Il simbolo della persona per primo; se con lui il nome non si puo'
    // fare (una Leone del segno del Leone), gli altri della stessa famiglia,
    // poi quelli delle altre famiglie.
    final simboli = <String>{
      ..._simboli(famiglia, identita),
      ..._simboli(famiglia, null),
      for (var f = 1; f < 5; f++) ..._simboli((famiglia + f) % 5, null),
    }.toList();
    const appellativi = INomiIniziatici.appellativi;
    const qualita = INomiIniziatici.qualita;
    final da = s ~/ 5;
    // Si scorrono le combinazioni a partire dal seme finche' una sta nei
    // venti caratteri e non contiene il nome proprio: le parole corte
    // dell'elenco garantiscono che una c'e' sempre.
    final personali = _simboli(famiglia, identita).length;
    for (var j = 0; j < simboli.length; j++) {
      final simbolo = j < personali
          ? simboli[(da + j) % personali]
          : simboli[personali + (da + j) % (simboli.length - personali)];
      for (var i = 0; i < appellativi.length; i++) {
        final a = appellativi[(da + i) % appellativi.length];
        final q = qualita[(da ~/ 7 + i * 13) % qualita.length];
        final nome = '$a $simbolo $q';
        if (nome.length > lunghezzaMassima) continue;
        if (proprio.length >= 3 && _piana(nome).contains(proprio)) continue;
        return nome;
      }
    }
    // Non succede con gli elenchi di oggi (una prova lo misura su mille
    // nascite): se un giorno succedesse, il nome resta di due parti e lo
    // dichiara il commento, non un nome lungo che il server rifiuterebbe.
    return '${appellativi[da % appellativi.length]} '
        '${qualita[da % qualita.length]}';
  }
}
