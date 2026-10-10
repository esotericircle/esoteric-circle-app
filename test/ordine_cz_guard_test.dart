import 'guardia_del_manifesto.dart';

/// **LA GUARDIA PROPRIA DELL'ORDINE CZ.** Scritta dall'ordine DS voce 01, 17
/// settembre 2026: l'ordine CZ si era chiuso senza, e nessuna prova se ne
/// accorgeva. Sorveglia che il manifesto chiuso resti quello che e' stato
/// chiuso.
void main() {
  sorvegliaIlManifesto(
    file: 'ORDINE_CZ_MANIFESTO.md',
    voci: 16,
    marcatori: {
      'VOCI_TOTALI': 16,
      'VOCI_CHIUSE': 15,
      'VOCI_APERTE': 0,
      'VOCI_FERMATE_SU_PREMESSA_FALSA': 0,
      'VOCI_FERMATE_IN_ATTESA_DI_DECISIONE': 0,
      'VOCI_FERMATE_SU_LAVORO_NON_MONTATO': 1,
    },
  );
}
