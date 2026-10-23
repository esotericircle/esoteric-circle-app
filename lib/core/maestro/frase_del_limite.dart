import 'maestro.dart';
import 'voce_del_maestro.dart';

/// Cosa dice un Maestro quando le domande del giorno sono finite.
///
/// **Il dato che ha fatto nascere questo file.** Il 2 agosto 2026, sul telefono
/// del fondatore: su Caligo alle 13:24 e su Aura alle 13:25 compare la STESSA
/// IDENTICA FRASE, parola per parola. Dopo tutto il lavoro sulle tre voci
/// distinte, il messaggio che l'utente gratuito vede piu' spesso di ogni altro
/// era anonimo. E' la voce 15 del Registro: il limite raccontato come rito
/// invece che come errore.
///
/// **Il numero si LEGGE dal dato, sempre.** Se domani il limite diventa cinque,
/// queste frasi lo dicono da sole: nessuna delle tre contiene una cifra
/// scritta a mano.
///
/// Le tre nascono dalla [LenteDelMaestro], cioe' dallo stesso dato che regge il
/// 98,3 per cento di attribuzione cieca: Medora chiude sul tempo, Aura sul
/// corpo, Caligo sul segno. Non e' un terzo elenco scritto in una schermata.
class FraseDelLimite {
  const FraseDelLimite._();

  /// Come si dice il numero: "una domanda" oppure "tre domande".
  ///
  /// Pubblica perche' la stessa forma serve alla frase e alla prova che la
  /// misura, e due copie della stessa regola divergono sempre.
  static String quante(int limite) {
    // I numeri piccoli in LETTERE: un Maestro non dice "3", dice "tre". Sopra
    // il nove la cifra e' piu' leggibile della parola, e a quel punto nessuno
    // la legge come una voce.
    const inLettere = [
      'zero',
      'una',
      'due',
      'tre',
      'quattro',
      'cinque',
      'sei',
      'sette',
      'otto',
      'nove',
    ];
    final quanto = limite >= 0 && limite < inLettere.length
        ? inLettere[limite]
        : '$limite';
    return limite == 1 ? '$quanto domanda' : '$quanto domande';
  }

  /// La frase del limite di [maestro], col numero preso da [limite].
  ///
  /// Con [limite] nullo il piano non ha limiti e non c'e' niente da annunciare:
  /// resta un congedo nella sua voce.
  static String per(Maestro maestro, {required int? limite}) {
    final lente = VoceDelMaestro.di(maestro).lente;
    if (limite == null) return _senzaLimite(lente);
    final n = quante(limite);
    switch (lente) {
      case LenteDelMaestro.motoNelTempo:
        return 'Il tuo cielo ha detto le sue cose per oggi: il tuo cammino '
            'prevede $n al giorno. Il ciclo riprende domani, con me dentro. '
            'Se vuoi che il cerchio si allarghi, si può allargare.';
      case LenteDelMaestro.effettoNelCorpo:
        return 'Per oggi ci siamo dette abbastanza: il tuo cammino prevede $n '
            'al giorno, poi il respiro chiede riposo. Torna domani, il corpo '
            'sa aspettare. Se ti serve più spazio, il cerchio può allargarsi.';
      case LenteDelMaestro.simbolo:
        return 'I segni di oggi sono stati letti: il tuo cammino prevede $n '
            'al giorno. La soglia si richiude fino a domani. Se la vuoi più '
            'larga, si può allargare.';
    }
  }

  static String _senzaLimite(LenteDelMaestro lente) {
    switch (lente) {
      case LenteDelMaestro.motoNelTempo:
        return 'Per oggi il cielo ha detto. Torna quando vuoi: il ciclo non '
            'si chiude.';
      case LenteDelMaestro.effettoNelCorpo:
        return 'Per adesso fermiamoci qui. Riprendiamo quando il respiro lo '
            'chiede: nessuna porta si chiude.';
      case LenteDelMaestro.simbolo:
        return 'La soglia resta aperta. Torna quando il segno ti chiama.';
    }
  }
}
