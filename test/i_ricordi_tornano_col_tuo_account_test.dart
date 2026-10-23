import 'package:esoteric_circle/core/ricordi/registro_dei_ricordi.dart';
import 'package:esoteric_circle/core/ricordi/voce_del_ricordo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **I RICORDI TORNANO COL TUO ACCOUNT.** Ordine EV, dal censimento delle
/// memorie dopo il fatto del fondatore sulla Runa del Tramonto: la timeline
/// del Cosmic Journal non arrivava mai al Cerchio (`sincronizza` non aveva
/// chiamanti) e su un telefono nuovo non tornava. Il telefono reinstallato ha
/// una riga di oggi, il Cerchio ne custodisce due del mese prima: dopo la
/// ripresa ci sono tutte e tre, e la riga di oggi e' partita verso il Cerchio.
class _Cerchio extends PortaDeiRicordi {
  final Map<String, List<VoceDelRicordo>> mesi = {};
  final mandati = <String>[];

  @override
  Future<bool> manda(String mese, List<VoceDelRicordo> righe) async {
    mandati.add(mese);
    (mesi[mese] ??= []).addAll(righe);
    return true;
  }

  @override
  Future<List<VoceDelRicordo>> leggi(String mese) async => mesi[mese] ?? [];
}

VoceDelRicordo _voce(DateTime quando, String titolo) => VoceDelRicordo(
      quando: quando,
      arte: 'tramonto',
      maestro: 'caligo',
      titolo: titolo,
      tipo: TipoDelRicordo.gesto,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('il telefono reinstallato riprende i Ricordi del Cerchio', () async {
    SharedPreferences.setMockInitialValues(const {});
    final cerchio = _Cerchio()
      ..mesi['2026-09'] = [
        _voce(DateTime(2026, 9, 28, 19), 'La runa del tramonto'),
        _voce(DateTime(2026, 9, 29, 19), 'La runa del tramonto, seconda sera'),
      ];
    final registro = RegistroDeiRicordi(
        orologio: () => DateTime(2026, 10, 1, 20), porta: cerchio);
    await registro.carica();
    await registro.segna(_voce(DateTime(2026, 10, 1, 19), 'Stasera'));
    final prima = registro.tutte.length;
    final entrate = await registro.riprendiDalCerchio();
    // ignore: avoid_print
    print('ORDINE EV, RICORDI: righe sul telefono prima $prima, entrate dal '
        'Cerchio $entrate, dopo ${registro.tutte.length}; mesi mandati '
        '${cerchio.mandati}');
    expect(prima, 1);
    expect(registro.tutte.length, 3,
        reason: 'i Ricordi custoditi dal Cerchio non tornano sul telefono');
    expect(cerchio.mandati, contains('2026-10'),
        reason: 'la riga di oggi non parte verso il Cerchio');
  });
}
