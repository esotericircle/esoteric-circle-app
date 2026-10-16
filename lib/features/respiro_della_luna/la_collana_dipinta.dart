/// LA COLLANA DIPINTA. Ordine FX aggiunta FXA.01, 16 ottobre 2026.
///
/// Il fondatore, sull'anteprima della collana composta dal codice: *"Che
/// cos'e' questa merda? Non avevo chiesto di evitare grafica procedurale?"*,
/// e poi sulle trentadue perle della pittura: *"Lasciamola cosi'"*.
///
/// **IL CODICE NON COMPONE FIGURE.** La collana e' la pittura dello scrigno
/// con la collana tutta spenta (`collana_nello_scrigno_spenta_v2`), intera,
/// adattata allo spazio senza ritagli. Ogni perla accesa e' un RITAGLIO TONDO
/// della pittura gemella tutta accesa, preparato una volta fuori dall'app da
/// `tool/gli_asset_dell_aggiunta_fxa.py` (opaco fino al raggio della perla,
/// sfumato fino al raggio della maschera) e posato qui nel suo centro
/// misurato. Nessuna forma, alone o cerchio disegnato: Flutter posa
/// immagini, ne sceglie le parti e ne fa sfumare l'opacita'.
///
/// **LE POSIZIONI** stanno nel file `le_perle_della_collana_v2.json`
/// accanto alle pitture, e qui nella sua copia Dart generata
/// (`le_perle_della_collana.g.dart`): una lettura asincrona del file
/// lascerebbe il primo fotogramma senza perle. Una prova pretende che i due
/// dicano la stessa cosa.
///
/// **I GIORNI** seguono il file: dal fermaglio i giorni 1-15 scendono a
/// sinistra, i giorni 16-30 risalgono a destra. In un ciclo di 29 giorni la
/// perla 30 si accende col compimento. Le due perle accanto alla medaglia e
/// la medaglia si accendono solo quando la collana e' completa.
library;

import 'package:flutter/widgets.dart';

part 'le_perle_della_collana.g.dart';

const String _collana = 'assets/img/respiro_della_luna/collana/';

/// La posizione di un ritaglio sulla pittura, in pixel della pittura.
class PosizioneDellaPerla {
  const PosizioneDellaPerla(this.x, this.y, this.raggioMaschera);
  final double x;
  final double y;
  final double raggioMaschera;
}

/// Le posizioni e gli asset della collana dipinta.
abstract final class LePerleDellaCollana {
  static const String file = '${_collana}le_perle_della_collana_v2.json';
  static const String pitturaSpenta =
      '${_collana}collana_nello_scrigno_spenta_v2.webp';
  static const String pitturaAccesa =
      '${_collana}collana_nello_scrigno_accesa_v2.webp';

  static const double larghezza = _larghezzaDellaPittura;
  static const double altezza = _altezzaDellaPittura;

  /// I centri dei giorni 1-30, nell'ordine.
  static const List<PosizioneDellaPerla> giorni = _giorni;
  static const List<PosizioneDellaPerla> compimento = _compimento;
  static const PosizioneDellaPerla medaglia = _medaglia;

  static String ritaglioDelGiorno(int giorno) =>
      '${_collana}perle_accese/perla_giorno_${giorno.toString().padLeft(2, '0')}_v2.webp';
  static String ritaglioDelCompimento(int i) =>
      '${_collana}perle_accese/perla_compimento_${i}_v2.webp';
  static const String ritaglioDellaMedaglia =
      '${_collana}perle_accese/medaglia_v2.webp';
}

/// **LA COLLANA**, la pittura con le perle accese. [accesi] sono i giorni del
/// ciclo respirati (1-30); [completa] accende la perla 30 di un ciclo di 29
/// giorni, le due perle del compimento e la medaglia. [sopra] sta sopra la
/// pittura, nelle sue stesse proporzioni (il testo della card, i tocchi
/// della ricucitura) e riceve la scala, pixel a schermo per pixel di pittura.
class LaCollanaDipinta extends StatelessWidget {
  const LaCollanaDipinta({
    super.key,
    required this.accesi,
    required this.completa,
    this.numeroDiPerle = 30,
    this.sopra,
  });

  final Set<int> accesi;
  final bool completa;
  final int numeroDiPerle;
  final Widget Function(BuildContext context, double scala)? sopra;

  static const Duration dissolvenza = Duration(milliseconds: 900);

  bool _acceso(int giorno) =>
      accesi.contains(giorno) || (completa && giorno > numeroDiPerle);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: LePerleDellaCollana.larghezza / LePerleDellaCollana.altezza,
      child: LayoutBuilder(builder: (context, vincoli) {
        final scala = vincoli.maxWidth / LePerleDellaCollana.larghezza;
        Widget ritaglio(
                String asset, PosizioneDellaPerla p, bool acceso, Key chiave) =>
            Positioned(
              left: (p.x - p.raggioMaschera) * scala,
              top: (p.y - p.raggioMaschera) * scala,
              width: 2 * p.raggioMaschera * scala,
              height: 2 * p.raggioMaschera * scala,
              child: AnimatedOpacity(
                // Chiave stabile: al cambio di stato la stessa perla sfuma,
                // non viene ricreata.
                key: chiave,
                opacity: acceso ? 1 : 0,
                duration: dissolvenza,
                curve: Curves.easeInOut,
                child: Image.asset(asset,
                    fit: BoxFit.fill,
                    gaplessPlayback: true,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink()),
              ),
            );
        return Stack(
          children: [
            Positioned.fill(
              child: Image.asset(LePerleDellaCollana.pitturaSpenta,
                  fit: BoxFit.fill,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink()),
            ),
            for (var g = 1; g <= LePerleDellaCollana.giorni.length; g++)
              ritaglio(
                  LePerleDellaCollana.ritaglioDelGiorno(g),
                  LePerleDellaCollana.giorni[g - 1],
                  _acceso(g),
                  Key('collana_perla_$g')),
            for (var i = 1; i <= LePerleDellaCollana.compimento.length; i++)
              ritaglio(
                  LePerleDellaCollana.ritaglioDelCompimento(i),
                  LePerleDellaCollana.compimento[i - 1],
                  completa,
                  Key('collana_compimento_$i')),
            ritaglio(
                LePerleDellaCollana.ritaglioDellaMedaglia,
                LePerleDellaCollana.medaglia,
                completa,
                const Key('collana_medaglia')),
            if (sopra != null) Positioned.fill(child: sopra!(context, scala)),
          ],
        );
      }),
    );
  }
}
