import '../astro/zodiac.dart';
import 'ancoraggio.dart';

/// Che COSA si disegna per un ancoraggio, mentre il Maestro consulta.
///
/// E' un dato e non un widget: la scelta di quale arte mostrare si prova senza
/// montare uno schermo, e la vista si limita a dipingere cio' che questo
/// oggetto ha gia' deciso.
///
/// **Non si inventa mai un'immagine.** Se per un ancoraggio non esiste arte a
/// bundle si usa il trattamento che il cielo gia' da' ai corpi senza figura,
/// cioe' un punto luminoso con la sua etichetta: mai il vuoto, mai arte finta.
sealed class CorpoDelConsulto {
  const CorpoDelConsulto();

  /// Che cosa mostrare per questo [ancoraggio].
  ///
  /// Riusa l'arte che esiste gia' a bundle: i dodici emblemi zodiacali che
  /// l'Oroscopo mostra in testa, e il disco lunare col terminatore vero del
  /// Rito del Sogno. Nessuna arte nuova.
  static CorpoDelConsulto per(Ancoraggio ancoraggio) {
    switch (ancoraggio.nome) {
      case 'ascendente':
      case 'segno lunare':
      case 'segno solare':
        final segno = _segnoDa(ancoraggio.valore);
        if (segno != null) return CorpoSegno(segno);
        return const CorpoPunto();
      case 'fase lunare di nascita':
        return const CorpoLuna();
      default:
        // Numero della vita, fatto di memoria, pianeta di transito: dati veri
        // per cui non esiste arte. Un punto luminoso, come nel cielo.
        return const CorpoPunto();
    }
  }

  /// Il segno dal suo nome italiano. Nullo se non lo riconosce, e in quel caso
  /// si cade sul punto invece di indovinare.
  static Zodiac? _segnoDa(String nomeItaliano) {
    final cercato = nomeItaliano.trim().toLowerCase();
    for (final z in Zodiac.values) {
      if (z.italianName.toLowerCase() == cercato) return z;
    }
    return null;
  }
}

/// L'emblema 3D del segno, lo stesso che l'Oroscopo mostra in testa.
class CorpoSegno extends CorpoDelConsulto {
  const CorpoSegno(this.segno);
  final Zodiac segno;
}

/// Il disco lunare con la fase vera e il terminatore, dal Rito del Sogno.
class CorpoLuna extends CorpoDelConsulto {
  const CorpoLuna();
}

/// Un punto luminoso con la sua etichetta, come i corpi senza figura nel cielo.
/// E' il ripiego DICHIARATO: non e' il vuoto, ed e' meglio di un'arte inventata.
class CorpoPunto extends CorpoDelConsulto {
  const CorpoPunto();
}
