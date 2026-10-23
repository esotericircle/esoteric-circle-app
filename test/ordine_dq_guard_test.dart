import 'guardia_del_manifesto.dart';

/// **LA GUARDIA PROPRIA DELL'ORDINE DQ.** Scritta dall'ordine DS voce 01, 17
/// settembre 2026: l'ordine DQ si era chiuso senza, e nessuna prova se ne
/// accorgeva. Sorveglia che il manifesto chiuso resti quello che e' stato
/// chiuso.
void main() {
  sorvegliaIlManifesto(
    file: 'ORDINE_DQ_MANIFESTO.md',
    voci: 16,
    marcatori: {
      'VOCI_TOTALI': 16,
      'VOCI_CHIUSE': 14,
      'VOCI_IN_ATTESA_DELL_ARCHIVIO': 2,
      'VOCI_SBLOCCATE_E_APERTE': 0,
    },
  );
}
