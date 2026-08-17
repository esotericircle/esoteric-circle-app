import 'package:esoteric_circle/core/sigilli/coda_delle_feste.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// NESSUN TRAGUARDO CELEBRA DUE VOLTE. Ordine AC voce 05.
///
/// La coda rifiuta gia' di accodare due volte lo stesso identificativo, ma
/// nessuna prova diceva che il rifiuto valga anche ATTRAVERSO UNA CHIUSURA
/// dell'app, che e' il caso in cui il difetto farebbe piu' danno: una festa
/// gia' celebrata che risorge dal disco al riavvio e' un premio ripetuto, e
/// una festa ripetuta e' peggio di una festa mancata.
///
/// La prova enumera il percorso intero: accoda, accoda di nuovo (rifiutato),
/// celebra, salva su disco, ricarica da disco, e pretende che quel traguardo
/// non torni mai in coda. Ogni passo dichiara quante copie vede.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('un traguardo celebrato non torna in coda dopo la chiusura', () async {
    SharedPreferences.setMockInitialValues(const {});
    final prima = CodaDelleFeste();
    await prima.carica();
    final traguardo = Sentieri.miniDi(Sentiero.loto).first;

    // 1. SI ACCODA, E SI RIACCODA: il rifiuto del doppione da vivo.
    await prima.accoda(traguardo.id);
    await prima.accoda(traguardo.id);
    var copie = prima.inAttesa.where((id) => id == traguardo.id).length;
    // ignore: avoid_print
    print('ORDINE AC VOCE 05: copie in coda dopo il doppio accoda: $copie');
    expect(copie, 1,
        reason: 'accodare due volte lo stesso identificativo deve lasciarne '
            'UNA copia, non $copie');

    // 2. IL RIFIUTO REGGE ANCHE ATTRAVERSO LA CHIUSURA, da coda ancora piena:
    //    un'altra istanza e' cio' che succede al riavvio.
    final riaperta = CodaDelleFeste();
    await riaperta.carica();
    await riaperta.accoda(traguardo.id);
    copie = riaperta.inAttesa.where((id) => id == traguardo.id).length;
    // ignore: avoid_print
    print('ORDINE AC VOCE 05: copie dopo riavvio e nuovo accoda: $copie');
    expect(copie, 1,
        reason: 'dopo la ricarica da disco il rifiuto del doppione non regge '
            'piu\': le copie sono $copie');

    // 3. SI CELEBRA: la festa esce dalla coda e la rimozione va su disco.
    final celebrati = await riaperta.prendiTutte();
    expect(celebrati.map((t) => t.id), contains(traguardo.id));

    // 4. SI RICHIUDE E SI RIAPRE: il traguardo celebrato NON deve tornare.
    final dopoLaChiusura = CodaDelleFeste();
    await dopoLaChiusura.carica();
    copie =
        dopoLaChiusura.inAttesa.where((id) => id == traguardo.id).length;
    // ignore: avoid_print
    print('ORDINE AC VOCE 05: copie dopo celebrazione e chiusura: $copie');
    expect(copie, 0,
        reason: 'il traguardo ${traguardo.id} era gia\' stato celebrato e al '
            'riavvio e\' tornato in coda: celebrerebbe due volte');
    expect(dopoLaChiusura.vuota, isTrue,
        reason: 'la coda doveva essere vuota dopo la celebrazione, e porta '
            'ancora ${dopoLaChiusura.inAttesa}');
  });
}
