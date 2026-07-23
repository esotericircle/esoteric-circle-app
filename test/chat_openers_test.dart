import 'package:esoteric_circle/features/maestri/chat/chat_openers.dart';
import 'package:flutter_test/flutter_test.dart';

/// Le prime domande contestuali con cui si apre la chat dal responso di un'arte.
void main() {
  test('Dall\'Animale Guida, col nome vero e l\'articolo giusto', () {
    expect(ChatOpeners.animale('Lupo'),
        'Il mio animale guida e\' il Lupo, cosa vuole dirmi?');
    // Femminile e vocale prendono l'articolo giusto, senza attaccare le parole.
    expect(ChatOpeners.animale('Volpe'),
        'Il mio animale guida e\' la Volpe, cosa vuole dirmi?');
    expect(ChatOpeners.animale('Aquila'),
        'Il mio animale guida e\' l\'Aquila, cosa vuole dirmi?');
  });

  test('Dal Test Archetipo, col nome con l\'articolo dell\'archetipo', () {
    expect(ChatOpeners.archetipo('Il Realista'),
        'Il mio archetipo e\' Il Realista, aiutami a capirlo meglio.');
    expect(ChatOpeners.archetipo('L\'Eroe'),
        'Il mio archetipo e\' L\'Eroe, aiutami a capirlo meglio.');
  });

  test('Dalla Costellazione del Viso, col tratto dominante vero', () {
    expect(ChatOpeners.viso('naso', 'Naso corto'),
        'Il mio tratto dominante e\' il naso corto, cosa racconta di me?');
    expect(ChatOpeners.viso('bocca', 'Bocca larga'),
        'Il mio tratto dominante e\' la bocca larga, cosa racconta di me?');
    expect(ChatOpeners.viso('grandezzaOcchi', 'Occhi grandi'),
        'Il mio tratto dominante e\' gli occhi grandi, cosa racconta di me?');
  });
}
