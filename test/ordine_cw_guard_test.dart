import 'guardia_del_manifesto.dart';

/// **LA GUARDIA PROPRIA DELL'ORDINE CW.** Scritta dall'ordine DS voce 01, 17
/// settembre 2026: l'ordine CW si era chiuso senza, e nessuna prova se ne
/// accorgeva. Sorveglia che il manifesto chiuso resti quello che e' stato
/// chiuso.
void main() {
  sorvegliaIlManifesto(
    file: 'ORDINE_CW_MANIFESTO.md',
    voci: 10,
    marcatori: {
      'VOCI_TOTALI': 10,
      'VOCI_CHIUSE': 10,
      'VOCI_APERTE': 0,
      'VOCI_FERMATE_SU_PREMESSA_FALSA': 0,
      'VOCI_FERMATE_IN_ATTESA_DI_DECISIONE': 0,
      'VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE': 0,
    },
  );
}
