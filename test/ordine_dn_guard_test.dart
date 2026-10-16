import 'guardia_del_manifesto.dart';

/// **LA GUARDIA PROPRIA DELL'ORDINE DN.** Scritta dall'ordine DS voce 01, 17
/// settembre 2026: l'ordine DN si era chiuso senza, e nessuna prova se ne
/// accorgeva. Sorveglia che il manifesto chiuso resti quello che e' stato
/// chiuso.
void main() {
  sorvegliaIlManifesto(
    file: 'ORDINE_DN_MANIFESTO.md',
    voci: 11,
    nota:
        'DICHIARA IL FALSO, riportato al fondatore dall\'ordine DS: undici intestazioni da DN.00 a DN.10, tutte CHIUSA, e VOCI_TOTALI ne dice dieci. Non corretto',
    marcatori: {
      'VOCI_TOTALI': 10,
      'VOCI_CHIUSE': 10,
      'VOCI_SBLOCCATE_E_APERTE': 0,
    },
  );
}
