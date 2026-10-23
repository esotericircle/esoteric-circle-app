import '../chat/la_marca_del_genere.dart';
import 'cielo_evolutivo.dart';
import 'il_composito_e_keplero.dart';
import 'la_lettura_evolutiva.dart';
import 'legame_e_eta.dart';

/// **LA PROFONDITA' DELLA SINASTRIA EVOLUTIVA.** Ordine GD voce GD.17.
enum ProfonditaDellaSinastria {
  breve('Breve'),
  lunga('Lunga');

  const ProfonditaDellaSinastria(this.etichetta);
  final String etichetta;
}

/// **LA LUNGA DELLA SINASTRIA EVOLUTIVA.** Ordine GD voce GD.17, 23 ottobre
/// 2026. Il fondatore: *"Inoltre ci sarà il selettore di profondità breve o
/// lunga. Lunga sarà esclusiva degli utenti premium a pagamento che
/// aggiungerà solo alla prima risposta del responso 2 paragrafi di cui il
/// secondo in riquadro con titolo"*; il titolo lo ha lasciato a Code ("scegli
/// tu"): [titoloDelRiquadro].
///
/// **TUTTO DAL CORPUS, MAI DAL MODELLO.** La Sinastria evolutiva non chiama
/// nessun modello (`la_lettura_evolutiva.dart`, "Tutto deterministico"): la
/// Lunga e' composta qui, con o senza rete e non ha un ripiego che possa
/// perderla. L'ordine GD ha trovato la Lunga della Stesa e dell'Oracolo che
/// spariva proprio sul ripiego, con le prove verdi su una risposta finta del
/// modello: qui una strada del modello non c'e' e la guardia
/// `gd_la_sinastria_evolutiva_test.dart` pretende che non nasca.
///
/// **I DUE PARAGRAFI, dalla stessa coppia di cieli**, sempre gli stessi per la
/// stessa coppia (come il resto della lettura):
/// - il primo approfondisce il primo capitolo col SECONDO contatto che lo
///   tocca (il primo e' gia' nel capitolo); se il capitolo ha un contatto
///   solo, o nessuno, con un'altra apertura dello stesso tono, diversa da
///   quella gia' letta;
/// - il secondo, nel riquadro, e' il filo del cielo comune: il Tema
///   Composito della coppia ([IlComposito]), con la variante che il
///   capitolo del cielo comune non usa (quella prende la prima).
abstract final class LaLungaDellaSinastria {
  static const String titoloDelRiquadro = 'Il filo che vi lega';

  /// I due paragrafi della Lunga per il [primo] capitolo gia' letto.
  static ({String approfondimento, String filo}) per({
    required CieloEvolutivo tuo,
    required CieloEvolutivo suo,
    required String nomeSuo,
    required Legame legame,
    required CapitoloLetto primo,
    required CorpusDellaSinastria corpus,
  }) {
    final c = primo.capitolo;
    final seme = LetturaEvolutiva.semeDellaCoppia(tuo, suo);
    final contatti = AspettiEvolutivi.fra(tuo, suo).where(c.tocca).toList();
    String? approfondimento;
    if (contatti.length > 1) {
      final a = contatti[1];
      final coppia = c.coppie.firstWhere((x) =>
          (a.tuo == x.$1 && a.suo == x.$2) || (a.tuo == x.$2 && a.suo == x.$1));
      final file = c.index <= Capitolo.mente.index
          ? 'contatti_cuore_e_mente'
          : 'contatti_durata_e_destino';
      final v = corpus['$file|${nomeNelCorpus(coppia.$1)}-'
          '${nomeNelCorpus(coppia.$2)} ${aspettoNelCorpus(a.tipo)}|testo'];
      if (v != null && v.isNotEmpty) {
        final scelto = _pulito(v[seme % v.length], nomeSuo);
        if (!primo.paragrafi.contains(scelto)) approfondimento = scelto;
      }
    }
    if (approfondimento == null) {
      final v = corpus[
          'capitolo_${c.name}|${legame.name} ${primo.tono.name}|apertura']!;
      final altre = [
        for (final t in v)
          if (_pulito(t, nomeSuo) != primo.paragrafi.first) _pulito(t, nomeSuo),
      ];
      approfondimento = altre.isEmpty
          ? _pulito(v.first, nomeSuo)
          : altre[seme % altre.length];
    }
    final composito = IlComposito.fra(tuo, suo);
    final testi = corpus['composito|${composito.cella}|testo']!;
    final filo = _pulito(testi.length > 1 ? testi[1] : testi.first, nomeSuo);
    return (approfondimento: approfondimento, filo: filo);
  }

  static String _pulito(String testo, String nomeSuo) =>
      LaMarcaDelGenere.risolvi(testo.replaceAll('{nome}', nomeSuo));
}
