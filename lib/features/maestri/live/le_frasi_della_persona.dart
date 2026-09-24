import 'dart:typed_data';

/// **LE FRASI DELLA PERSONA, CHE SI UNISCONO QUANDO RIPRENDE A PARLARE.**
/// Ordine EJ voce 01, 24 settembre 2026.
///
/// Sul Realme, nel secondo giro di prove, il microfono si chiudeva a ogni
/// frase per trascriverla: in quel secondo e mezzo la persona che riprendeva
/// a parlare non era ascoltata da nessuno, e l'inizio della domanda andava
/// perso. Adesso il microfono resta aperto, e ogni frase chiusa dal silenzio
/// passa di qui:
///
/// - si trascrive **tutto cio' che la persona ha detto finora**, non solo
///   l'ultimo pezzo;
/// - se mentre la trascrizione torna la persona ha ripreso a parlare, non si
///   manda niente: il pezzo nuovo, quando si chiude, si trascrive insieme ai
///   vecchi, e la domanda arriva intera;
/// - se la trascrizione e' vuota era rumore: si butta e si continua ad
///   ascoltare, senza che il Maestro risponda a niente;
/// - una trascrizione vecchia, superata da un pezzo piu' nuovo, non conta.
class LeFrasiDellaPersona {
  final _pezzi = <Uint8List>[];
  int _giro = 0;

  /// Quanti pezzi aspettano di diventare una domanda.
  int get pezziInAttesa => _pezzi.length;

  /// Una frase si e' chiusa col silenzio. Torna tutto l'audio da trascrivere
  /// e il biglietto con cui la trascrizione dovra' presentarsi.
  ({Uint8List pcm, int biglietto}) chiusa(Uint8List pcm) {
    _pezzi.add(pcm);
    final tutto = BytesBuilder(copy: false);
    for (final p in _pezzi) {
      tutto.add(p);
    }
    return (pcm: tutto.toBytes(), biglietto: ++_giro);
  }

  /// La trascrizione del [biglietto] e' tornata con [testo]. Torna la domanda
  /// da mandare al Maestro, oppure null se si deve continuare ad ascoltare.
  /// [parlaDiNuovo] dice se in questo momento la persona sta di nuovo
  /// parlando.
  String? trascritta(int biglietto, String testo,
      {required bool parlaDiNuovo}) {
    if (biglietto != _giro) return null;
    if (parlaDiNuovo) return null;
    final detto = testo.trim();
    _pezzi.clear();
    return detto.isEmpty ? null : detto;
  }

  /// Si ricomincia da capo: il Maestro risponde, o la sessione finisce.
  void dimentica() {
    _pezzi.clear();
    _giro++;
  }
}
