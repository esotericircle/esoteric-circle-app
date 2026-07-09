import 'package:esoteric_circle/core/astro/place_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Il repository dei comuni carica e cerca a completamento', () async {
    final repo = ItalianComuniRepository();
    await repo.ensureLoaded();

    final roma = repo.search('rom');
    expect(roma.any((p) => p.label == 'Roma' && p.province == 'RM'), isTrue);
    // I risultati che iniziano con la query vengono prima.
    expect(roma.first.label.toLowerCase().startsWith('rom'), isTrue);

    // Insensibile agli accenti.
    final forli = repo.search('forli');
    expect(forli.any((p) => p.label.startsWith('Forl')), isTrue);

    // Ogni comune ha coordinate e fuso italiano.
    final milano = repo.search('Milano').first;
    expect(milano.timezone, 'Europe/Rome');
    expect(milano.latitude, isNot(0));
  });
}
