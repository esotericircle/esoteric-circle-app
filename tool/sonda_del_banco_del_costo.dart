// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/config/la_regione_dei_dati.dart';
import 'package:esoteric_circle/services/ai/l_etichetta_della_funzione.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_test/flutter_test.dart';

import 'il_banco_del_costo_comune.dart';

/// La sonda: una chiamata vera di Flash-Lite con l'app Firebase finta.
void main() {
  test('la sonda del banco del costo', () async {
    await preparaIlBanco();
    final m = FirebaseAI.vertexAI(location: LaRegioneDeiDati.regione)
        .generativeModel(
            model: 'gemini-2.5-flash-lite',
            httpClient: ClientConEtichetta('sonda'));
    final r = await m.generateContent([Content.text('Rispondi solo: ok')]);
    print(
        'SONDA: testo ${r.text}; registro ${registro.map((c) => '${c.funzione} ${c.modello} ${c.uso}').toList()}');
    expect(registro, isNotEmpty);
  });
}
