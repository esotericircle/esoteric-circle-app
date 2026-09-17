import 'guardia_del_manifesto.dart';

/// **LA GUARDIA PROPRIA DELL'ORDINE DB.** Scritta dall'ordine DS voce 01, 17
/// settembre 2026: l'ordine DB si era chiuso senza, e nessuna prova se ne
/// accorgeva. Sorveglia che il manifesto chiuso resti quello che e' stato
/// chiuso.
void main() {
  sorvegliaIlManifesto(
    file: 'ORDINE_DB_MANIFESTO.md',
    voci: 13,
    marcatori: {
      'VOCI_TOTALI': 13,
      'VOCI_CHIUSE': 12,
      'VOCI_PROPOSTE_E_NON_MONTATE': 1,
      'VOCI_APERTE': 0,
    },
  );
}
