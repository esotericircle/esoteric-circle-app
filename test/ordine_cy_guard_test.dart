import 'guardia_del_manifesto.dart';

/// **LA GUARDIA PROPRIA DELL'ORDINE CY.** Scritta dall'ordine DS voce 01, 17
/// settembre 2026: l'ordine CY si era chiuso senza, e nessuna prova se ne
/// accorgeva. Sorveglia che il manifesto chiuso resti quello che e' stato
/// chiuso.
void main() {
  sorvegliaIlManifesto(
    file: 'ORDINE_CY_MANIFESTO.md',
    voci: 5,
    marcatori: {
      'VOCI_TOTALI': 5,
      'VOCI_CHIUSE': 4,
      'VOCI_APERTE': 0,
      'VOCI_FERMATE_SU_PREMESSA_FALSA': 0,
      'VOCI_FERMATE_IN_ATTESA_DI_DECISIONE': 0,
      'VOCI_FERMATE_SU_MISURA_MANCANTE': 1,
    },
  );
}
