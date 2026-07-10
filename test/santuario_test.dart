import 'package:esoteric_circle/features/santuario/santuario_stage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Appuntamento del Santuario', () {
    test('segue l\'ora del giorno', () {
      expect(
          santuarioAppointment(hour: 6, fullMoon: false, solarReturn: false),
          'Rito dell\'Alba');
      expect(
          santuarioAppointment(hour: 10, fullMoon: false, solarReturn: false),
          'Oracolo del Giorno');
      expect(
          santuarioAppointment(hour: 15, fullMoon: false, solarReturn: false),
          'Carta del Pomeriggio');
      expect(
          santuarioAppointment(hour: 19, fullMoon: false, solarReturn: false),
          'Runa del Tramonto');
      expect(
          santuarioAppointment(hour: 23, fullMoon: false, solarReturn: false),
          'Soffio della Notte');
    });

    test('la Luna piena e il ritorno solare hanno la precedenza', () {
      expect(
          santuarioAppointment(hour: 15, fullMoon: true, solarReturn: false),
          'Rito della Luna Piena');
      expect(
          santuarioAppointment(hour: 3, fullMoon: true, solarReturn: true),
          'Il tuo Ritorno Solare');
    });
  });
}
