import 'cielo_evolutivo.dart';
import 'il_composito_e_keplero.dart';
import 'la_lettura_evolutiva.dart';
import 'oggi_e_il_momento.dart';

/// Una barra dell'infografica: che cosa misura e quanto, fra zero e uno.
class BarraDellaSinastria {
  const BarraDellaSinastria(this.etichetta, this.valore);

  final String etichetta;

  /// Fra zero (nessun contatto) e uno (il contatto all'angolo esatto).
  final double valore;

  @override
  String toString() => '$etichetta ${(valore * 1000).round()} per mille';
}

/// **LE BARRE DELLA SINASTRIA EVOLUTIVA.** Ordine GD voce GD.19, 23 ottobre
/// 2026. Il fondatore: *"Il responso mostrerà già all'inizio o quasi, magari
/// dopo il titolo, le barre di infografica. E ogni bolla dovrà avere la sua
/// infografica"* e poi *"usa la stessa, così l'utente non deve imparare a
/// leggerne una diversa per ogni bolla nella stessa funzionalità"*.
///
/// **UN TIPO SOLO, I DATI DI OGNI BOLLA.** Ogni bolla della lettura porta lo
/// stesso grafico, barre orizzontali da zero a uno e ogni barra e' un
/// numero del calcolo della sinastria, mai un numero scritto a mano:
/// - in cima al responso, una barra per capitolo: la forza del contatto piu'
///   stretto fra le coppie del capitolo (lo stesso che decide il suo tono);
/// - in ogni capitolo, una barra per ciascuna delle sue tre coppie di punti;
/// - in Oggi fra voi, quanto i transiti di oggi accendono ogni capitolo;
/// - nelle consonanze di Keplero, quanto ogni corda e' vicina alla sua
///   consonanza (zero fuori da ogni consonanza);
/// - nel cielo comune, la forza dell'aspetto che parla;
/// - nel Momento giusto, quanto e' acceso ciascuno dei giorni.
///
/// **LA FORZA** e' quella gia' dichiarata per la sinastria
/// ([AspettoEvolutivo.forzaCon] con gli orbi di [AspettiEvolutivi.orbo]):
/// uno all'angolo esatto, zero al limite dell'orbo.
abstract final class LeBarreDellaSinastria {
  /// La forza di un aspetto della sinastria, con l'orbo del suo tipo.
  static double forza(AspettoEvolutivo a) =>
      a.forzaCon(AspettiEvolutivi.orbo[a.tipo]!);

  /// La barra di ogni capitolo, nell'ordine dei capitoli.
  static List<BarraDellaSinastria> deiCapitoli(
      CieloEvolutivo tuo, CieloEvolutivo suo) {
    final aspetti = AspettiEvolutivi.fra(tuo, suo);
    return [
      for (final c in Capitolo.values)
        BarraDellaSinastria(
          c.nome,
          aspetti
              .where(c.tocca)
              .map(forza)
              .fold<double>(0, (m, f) => f > m ? f : m),
        ),
    ];
  }

  /// Le barre delle tre coppie di punti del capitolo [c]: per ogni coppia,
  /// nelle due direzioni, l'aspetto piu' forte; zero se non si guardano.
  static List<BarraDellaSinastria> delCapitolo(
      Capitolo c, CieloEvolutivo tuo, CieloEvolutivo suo) {
    final aspetti = AspettiEvolutivi.fra(tuo, suo);
    return [
      for (final (x, y) in c.coppie)
        BarraDellaSinastria(
          nomeDellaCoppia(x, y),
          aspetti
              .where((a) =>
                  (a.tuo == x && a.suo == y) || (a.tuo == y && a.suo == x))
              .map(forza)
              .fold<double>(0, (m, f) => f > m ? f : m),
        ),
    ];
  }

  /// Le barre di Oggi fra voi: quanto i transiti del [giorno] accendono
  /// ogni capitolo ([OggiFraVoi.accensioneDeiCapitoli]).
  static List<BarraDellaSinastria> diOggi(
      CieloEvolutivo tuo, CieloEvolutivo suo, DateTime giorno) {
    final accesi =
        OggiFraVoi.accensioneDeiCapitoli(tuo: tuo, suo: suo, giorno: giorno);
    return [
      for (final c in Capitolo.values)
        BarraDellaSinastria(c.nome, accesi[c] ?? 0),
    ];
  }

  /// Le barre delle corde di Keplero: uno sulla consonanza esatta, zero al
  /// limite del suo orbo ([IntervalliDiKeplero.orbo]) o fuori da ogni
  /// consonanza. [chi] da' il nome della corda, come lo scrive la lettura.
  static List<BarraDellaSinastria> diKeplero(
      List<Corda> corde, String Function(Corda) chi) {
    return [
      for (final c in corde)
        BarraDellaSinastria(
          chi(c),
          c.consonanza == null
              ? 0
              : (1 -
                      (c.separazione - c.consonanza!.gradi).abs() /
                          IntervalliDiKeplero.orbo)
                  .clamp(0.0, 1.0),
        ),
    ];
  }

  /// La barra del cielo comune: la forza dell'aspetto che parla, con l'orbo
  /// del suo tipo; zero se nessuno dei dieci e' nell'orbo.
  static List<BarraDellaSinastria> delComposito(IlComposito composito) {
    final a = composito.aspetto;
    if (a == null) {
      return const [BarraDellaSinastria('Il vostro cielo comune', 0)];
    }
    final ammesso = AspettiEvolutivi.orbo[a.tipo]!;
    return [
      BarraDellaSinastria(
        '${a.a.nome} e ${a.b.nome} in ${a.tipo.italianName.toLowerCase()}',
        ammesso <= 0 ? 0 : (1 - a.orbo / ammesso).clamp(0.0, 1.0),
      ),
    ];
  }

  /// Le barre del Momento giusto: un giorno, una barra
  /// ([GiornoFavorevole.forza]).
  static List<BarraDellaSinastria> delMomento(
      List<GiornoFavorevole> giorni, String Function(DateTime) data) {
    return [
      for (final g in giorni) BarraDellaSinastria(data(g.giorno), g.forza),
    ];
  }

  /// "Venere e Marte", "Le due Lune": il nome di una coppia di punti.
  static String nomeDellaCoppia(
      PuntoDelCieloEvolutivo x, PuntoDelCieloEvolutivo y) {
    if (x != y) return '${x.nome} e ${y.nome}';
    return switch (x) {
      PuntoDelCieloEvolutivo.sole => 'I due Soli',
      PuntoDelCieloEvolutivo.luna => 'Le due Lune',
      PuntoDelCieloEvolutivo.venere => 'Le due Veneri',
      _ => 'I due ${x.nome}',
    };
  }
}
