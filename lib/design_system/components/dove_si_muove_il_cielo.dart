/// DOVE SI MUOVE IL CIELO, dichiarato in un punto solo. Ordine P voci 01 e 02.
///
/// **Perche' un elenco e non una deduzione a mente.** Il cielo in parallasse
/// si e' gia' fermato due volte, e tutte e due le volte nessuno se n'e' accorto
/// subito perche' "dove doveva muoversi" era una cosa che si sapeva a memoria.
/// Un elenco scritto ha due proprieta' che la memoria non ha: si conta, e si
/// puo' far cadere una prova quando una schermata dichiara il fondo e non lo
/// riceve in movimento.
///
/// **La storia della regressione, perche' la causa vale piu' della
/// correzione.** Il commit che fermo' il cielo e' `8326b55` dell'8 agosto 2026,
/// "Il cielo si dipinge una volta: i piani statici vivono in immagini". Quella
/// modifica era giusta e necessaria: su iOS il pittore del cosmo ridipingeva a
/// ogni fotogramma quindici nebulose sfocate e il sistema uccideva l'app a ogni
/// transizione. Portando gli strati statici in immagini di cache il costo e'
/// crollato, ma la vita del cielo e' finita dentro quelle immagini: a riposo
/// non si muoveva piu' niente, e la deriva automatica veniva spenta quando il
/// sensore risultava attivo, cioe' sempre su un telefono in mano. L'ordine M
/// dell'11 agosto ha rimesso in moto le due cose (deriva sempre viva, dimezzata
/// col sensore, piu' un sottoinsieme di stelle ridipinte vive sopra la cache).
/// La PREMESSA 1 dell'ordine P e' quindi CADUTA: il cielo si muove, misurato
/// su 29.067 campioni, e le voci 01 e 02 servono a blindarlo, non a ripararlo.
///
/// **Perche' l'elenco adesso dice anche CHI porta il cielo.** La prima
/// stesura era un elenco di nomi e basta, e il terzo lucchetto lo controllava
/// cercando la parola `CosmosBackground` dentro il file della schermata.
/// Quattro schermate cadevano, e nessuna delle quattro era rotta: due
/// ricevono il fondo dal guscio, che lo monta una volta per tutte; una lo
/// montava davvero ma da una rotta; una ha un fondale DIPINTO per scelta
/// d'arte. Misurare il testo del sorgente invece del fatto e' cio' che
/// produceva quelle quattro accuse. Adesso ognuna dichiara la sua sorgente, e
/// il lucchetto misura la sorgente giusta.
///
/// Chi tocca il movimento del cielo aggiorni questo elenco: le prove di
/// `test/il_cielo_si_muove_test.dart` e `test/i_tre_lucchetti_del_cielo_test.dart`
/// lo leggono.
library;

/// Da dove arriva il cielo a una schermata.
enum SorgenteDelCielo {
  /// La schermata monta lei stessa il fondo cosmico, o l'`ImmersiveScaffold`
  /// che lo contiene. E' il caso delle rotte spinte sopra il guscio.
  propria,

  /// Il fondo glielo da' il guscio, `AppShell`, che monta il cosmo una volta
  /// sola sotto le sue viste. Cercare `CosmosBackground` dentro queste
  /// schermate non troverebbe niente, ed e' giusto cosi': un secondo cosmo
  /// dentro il guscio sarebbe due cieli sovrapposti.
  dalGuscio,

  /// Il fondo e' un'immagine DIPINTA, e non si muove per scelta d'arte. Non
  /// e' un difetto ed e' l'unico stato che pretende una ragione scritta.
  fondaleDipinto,
}

/// Una schermata e la sua sorgente di cielo.
class CieloDiUnaSchermata {
  const CieloDiUnaSchermata(this.classe, this.sorgente, {this.perche});

  /// Il nome della classe, cosi' la prova che enumera puo' cadere col nome
  /// della schermata invece che con un numero.
  final String classe;

  final SorgenteDelCielo sorgente;

  /// Obbligatoria per il fondale dipinto: se il fondo non si muove, si dice
  /// perche', altrimenti la riga diventa un modo elegante di silenziare.
  final String? perche;
}

class DoveSiMuoveIlCielo {
  const DoveSiMuoveIlCielo._();

  /// Le schermate che portano il fondo cosmico e in cui il fondo DEVE
  /// muoversi, quando Riduci Movimento e' spento.
  static const List<CieloDiUnaSchermata> elenco = [
    // --- IL FONDO GLIELO DA' IL GUSCIO ------------------------------------
    CieloDiUnaSchermata('SantuarioScreen', SorgenteDelCielo.dalGuscio),
    CieloDiUnaSchermata('AskMaestriScreen', SorgenteDelCielo.dalGuscio),

    // --- LE ROTTE CHE SE LO PORTANO --------------------------------------
    CieloDiUnaSchermata('SkyOverviewScreen', SorgenteDelCielo.propria),
    CieloDiUnaSchermata('DomainScreen', SorgenteDelCielo.propria),
    CieloDiUnaSchermata('MaestroChatScreen', SorgenteDelCielo.propria),
    CieloDiUnaSchermata('OroscopoScreen', SorgenteDelCielo.propria),
    CieloDiUnaSchermata('StesaTreCarteScreen', SorgenteDelCielo.propria),
    CieloDiUnaSchermata('RuneDrawScreen', SorgenteDelCielo.propria),
    CieloDiUnaSchermata('DreamRiteScreen', SorgenteDelCielo.propria),
    CieloDiUnaSchermata('SentieroScreen', SorgenteDelCielo.propria),
    CieloDiUnaSchermata('CustodiaDelCieloStep', SorgenteDelCielo.propria),
    CieloDiUnaSchermata('CelebrazioneAScermoPieno', SorgenteDelCielo.propria),
    // ORDINE P VOCE 26: il Soffio si dipingeva un prato suo dentro il pittore
    // della scena, cioe' un secondo fondale da mantenere. Adesso porta il cosmo
    // condiviso come il Sigillo del Sogno, e il soffione resta dipinto da lui
    // perche' e' il gesto del rito e non lo sfondo.
    CieloDiUnaSchermata('BreathDestinyScreen', SorgenteDelCielo.propria),

    // --- IL FONDALE DIPINTO ----------------------------------------------
    CieloDiUnaSchermata(
      'SunsetRuneScreen',
      SorgenteDelCielo.fondaleDipinto,
      perche: 'Il Rito del Tramonto ha tre fondali DIPINTI, uno per momento, '
          'con l\'orizzonte allineato al 35,5 per cento su tutti e tre: è la '
          'scena del tramonto e un campo di stelle in parallasse sopra un '
          'orizzonte dipinto sarebbe due cieli nello stesso quadro. Il fondo '
          'non si muove qui perché non è il cosmo ed è una scelta '
          'd\'arte, non una regressione.',
    ),
  ];

  /// I soli nomi, per chi vuole solo contare.
  static List<String> get schermate => [for (final s in elenco) s.classe];

  /// Quante schermate dichiarano il fondo in movimento.
  static int get quante => elenco.length;

  /// Quelle in cui il cielo si muove davvero, cioe' tutte tranne i fondali
  /// dipinti.
  static List<CieloDiUnaSchermata> get colCieloVivo => [
        for (final s in elenco)
          if (s.sorgente != SorgenteDelCielo.fondaleDipinto) s,
      ];
}
