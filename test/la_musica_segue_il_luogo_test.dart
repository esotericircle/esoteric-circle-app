import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/sensi/catalogo_musiche.dart';
import 'package:esoteric_circle/core/sensi/regia_della_musica.dart';
import 'package:esoteric_circle/features/shell/quale_musica_suona.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'codice_senza_testo.dart';
import 'sorgenti_di_lib.dart';

/// **LA MUSICA SEGUE IL LUOGO, E TACE DOVE DEVE TACERE.**
/// Ordine CN voci 03 e 11.
void main() {
  test('ogni Maestro ha il suo anello, e sono tre diversi', () {
    final tracce = <MusicaDelCerchio>{};
    for (final m in Maestro.values) {
      final voce = cosaSuonaSu('DomainScreen', m);
      expect(voce.cosa, CosaSuonaQui.unaTraccia,
          reason: 'il dominio di $m non sa cosa suonare');
      tracce.add(voce.traccia!);
    }
    expect(tracce.length, Maestro.values.length,
        reason: 'due Maestri condividono lo stesso anello: il tappeto e\' il '
            'modo in cui si capisce di essere entrati da qualcun altro, e se '
            'e\' lo stesso non lo dice');
  });

  test('nella Meditazione la musica TACE, e non e\' un "non mi importa"', () {
    // **LA DIFFERENZA FRA SILENZIO E INDIFFERENZA E' TUTTO IL PUNTO.** La
    // Meditazione sta dentro il dominio di Aura: se dicesse "non decido", si
    // porterebbe dietro il bambu' del dominio da cui si e' entrati, e
    // coprirebbe il battito binaurale a 7 Hz che il telefono genera, che e'
    // esattamente la cosa che si va ad ascoltare.
    final voce = cosaSuonaSu('MeditationScreen', Maestro.aura);
    expect(voce.cosa, CosaSuonaQui.silenzio,
        reason: 'la Meditazione non pretende piu\' il silenzio: la '
            'prescrizione del 31 agosto 2026 vuole il volume della musica a '
            'ZERO li\' dentro, e il fondatore l\'ha confermata il 1 '
            'settembre.');
    expect(voce.traccia, isNull);

    // E il bambu' di Aura suona invece nel suo dominio, che e' l'altra meta'
    // della stessa regola.
    expect(cosaSuonaSu('DomainScreen', Maestro.aura).traccia,
        MusicaDelCerchio.aura);
  });

  test('lo Shaman copre il Risveglio e la home senza interruzioni', () {
    for (final schermata in const [
      'OnboardingScreen',
      'SantuarioScreen',
      'CosmicPassport'
    ]) {
      final voce = cosaSuonaSu(schermata, null);
      expect(voce.traccia, MusicaDelCerchio.home,
          reason: '$schermata non porta lo Shaman: l\'ordine CN vuole che '
              'parta con la PRIMA schermata del Risveglio e prosegua senza '
              'interrompersi fino alla home compresa. Tre schermate diverse, '
              'una traccia sola, quindi nessuna dissolvenza fra loro.');
    }
  });

  test('i Doni del Giorno non spengono cio\' che gia\' suona', () {
    // Nessuno dei Doni e' dichiarato nella mappa: chi non ha niente da dire
    // lascia continuare. Spegnere la musica su un Dono ne farebbe un buco di
    // silenzio proprio nel momento in cui l'app deve sembrare piu' viva.
    for (final dono in const [
      'BreathDestinyScreen',
      'DawnRiteScreen',
      'DreamRiteScreen',
      'DayOracleScreen',
      'SunsetRuneScreen',
    ]) {
      final voce = cosaSuonaSu(dono, null);
      expect(voce.cosa, CosaSuonaQui.cioCheGiaSuona,
          reason: '$dono ha cominciato a decidere della musica: nessun Dono '
              'del Giorno ha una traccia sua, e l\'ordine CN lo dice per '
              'esteso.');
    }
  });

  test('la musica scende sotto un effetto, e non a scatto', () {
    expect(RegiaDellaMusica.quotaAbbassata, lessThan(0.6),
        reason: 'la musica non scende abbastanza: un effetto che suona sopra '
            'un tappeto quasi intero non si stacca');
    expect(RegiaDellaMusica.quotaAbbassata, greaterThan(0.1),
        reason: 'la musica sparisce invece di scendere: l\'ordine chiede che '
            'passi sotto, non che si spenga');
    expect(RegiaDellaMusica.discesa.inMilliseconds, lessThan(400),
        reason: 'la discesa e\' cosi\' lenta che l\'attacco dell\'effetto, '
            'che e\' la parte che si riconosce, resterebbe coperto');
    expect(RegiaDellaMusica.risalita, greaterThan(RegiaDellaMusica.discesa),
        reason: 'la risalita deve essere piu\' lenta della discesa: un '
            'tappeto che torna di colpo si nota, e un tappeto che si nota '
            'non e\' piu\' un tappeto');
    expect(RegiaDellaMusica.passo.inMilliseconds, lessThanOrEqualTo(50),
        reason: 'a passi piu\' larghi l\'orecchio sente una scala invece di '
            'una rampa');
  });

  test('nessun selettore di brani, ed e\' un vincolo di licenza', () {
    // **CN.11.** La licenza Envato Elements esclude l'uso on demand, cioe'
    // quello in cui e' la persona a scegliere il contenuto. Musica fissa per
    // schermata sta dentro; un elenco da cui scegliere il brano no.
    //
    // Si cerca il gesto, non la parola: chi scorre l'elenco delle tracce per
    // costruirci qualcosa a schermo sta costruendo un selettore, comunque lo
    // chiami.
    final sospetti = <String>[];
    var guardati = 0;
    for (final f in sorgentiDiLib()) {
      final nudo = codiceSenzaTesto(f.readAsStringSync());
      if (!nudo.contains('MusicaDelCerchio')) continue;
      guardati++;
      final percorso = f.path.replaceAll(r'\', '/');
      // Il catalogo e la mappa dei luoghi NOMINANO tutte le tracce per
      // mestiere: sono le due porte, non un selettore.
      if (percorso.endsWith('catalogo_musiche.dart')) continue;
      if (percorso.endsWith('quale_musica_suona.dart')) continue;
      if (nudo.contains('MusicaDelCerchio.values')) {
        sospetti.add(percorso.substring(percorso.indexOf('lib/')));
      }
    }

    cardinaleMinimo(guardati, 3,
        cosa: 'sorgenti che nominano il catalogo della musica',
        perche: 'Se nessuno lo nomina piu\', o la musica e\' sparita dal '
            'progetto, oppure questa guardia sta cercando un nome che non si '
            'usa piu\'.');
    expect(sospetti, isEmpty,
        reason: 'QUESTI SORGENTI SCORRONO L\'ELENCO DELLE TRACCE: $sospetti.\n'
            'Scorrere il catalogo fuori dalle sue due porte serve quasi '
            'sempre a costruire una lista da cui scegliere, e **la licenza '
            'Envato Elements esclude l\'uso on demand**, cioe\' proprio '
            'quello in cui e\' la persona a scegliere il contenuto. Se ti '
            'serve per un altro motivo, dichiaralo qui sopra con la ragione.');
  });
}
