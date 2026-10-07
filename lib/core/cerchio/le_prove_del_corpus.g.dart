// GENERATO da tool/gli_enigmi_dal_corpus.py su
// docs/corpus/Corpus_Le_Prove.md. Non si modifica a mano.
// ignore_for_file: lines_longer_than_80_chars

import 'la_prova.dart';

/// I sei temi, nell'ordine dei criteri del cielo.
const List<TemaDellaProva> temiDelCorpus = [
  TemaDellaProva(
    numero: 1,
    nome: 'Le parole che non arrivano',
    domande: [
      DomandaDellaProva(
          1, 'Una cosa ti ha dato fastidio e la persona non se ne è accorta.', [
        RispostaDellaProva('Lascio perdere, passerà', 0),
        RispostaDellaProva('Aspetto di capire se era davvero importante', 1),
        RispostaDellaProva('Lo dico appena trovo il momento buono', 2),
        RispostaDellaProva('Lo dico subito, anche se il momento è pessimo', 3),
      ]),
      DomandaDellaProva(
          2, 'Hai mandato un messaggio e non ti rispondono da ore.', [
        RispostaDellaProva('Mi convinco di avere detto la cosa sbagliata', 0),
        RispostaDellaProva('Rileggo quello che ho scritto', 1),
        RispostaDellaProva('Penso che sia occupato e basta', 2),
        RispostaDellaProva('Ne mando un altro', 3),
      ]),
      DomandaDellaProva(3, 'Una persona ti fraintende davanti ad altri.', [
        RispostaDellaProva('Non dico niente e me ne faccio una ragione', 0),
        RispostaDellaProva('Chiarisco dopo, in privato', 1),
        RispostaDellaProva('Chiarisco subito, con calma', 2),
        RispostaDellaProva('Chiarisco subito e alzo la voce', 3),
      ]),
      DomandaDellaProva(
          4, 'Devi dire una cosa scomoda a qualcuno a cui tieni.', [
        RispostaDellaProva('Rimando finché non si risolve da sola', 0),
        RispostaDellaProva('Giro intorno e spero che capisca', 1),
        RispostaDellaProva('Lo dico, preparandomi le parole prima', 2),
        RispostaDellaProva('Lo dico come viene, anche male', 3),
      ]),
      DomandaDellaProva(
          5, 'In una riunione hai capito che stanno sbagliando.', [
        RispostaDellaProva('Me lo tengo per me', 0),
        RispostaDellaProva('Lo dico a qualcuno dopo', 1),
        RispostaDellaProva('Lo dico, ma solo se me lo chiedono', 2),
        RispostaDellaProva('Lo dico lì, anche se non è il mio turno', 3),
      ]),
      DomandaDellaProva(
          6, 'Ti fanno un complimento che non ti sembra sincero.', [
        RispostaDellaProva('Ringrazio e cambio discorso', 0),
        RispostaDellaProva('Ringrazio e ci penso per giorni', 1),
        RispostaDellaProva('Lo prendo per buono comunque', 2),
        RispostaDellaProva('Chiedo cosa intendeva davvero', 3),
      ]),
      DomandaDellaProva(7,
          'Quante volte rileggi un messaggio importante prima di mandarlo.', [
        RispostaDellaProva('Lo riscrivo da capo almeno una volta', 0),
        RispostaDellaProva('Due o tre volte', 1),
        RispostaDellaProva('Una volta', 2),
        RispostaDellaProva('Mando e basta', 3),
      ]),
      DomandaDellaProva(8, 'Una vecchia discussione torna a galla dopo mesi.', [
        RispostaDellaProva('Fingo di averla dimenticata', 0),
        RispostaDellaProva('Dico che non ha senso riparlarne', 1),
        RispostaDellaProva('La riprendo, perché non era chiusa', 2),
        RispostaDellaProva(
            'La riapro io [per primo|per prima|senza aspettare]', 3),
      ]),
      DomandaDellaProva(
          9, 'Ti accorgi di avere offeso qualcuno senza volerlo.', [
        RispostaDellaProva('Spero che non se ne sia accorto', 0),
        RispostaDellaProva('Aspetto che sia lui a dirmelo', 1),
        RispostaDellaProva('Mi scuso appena posso', 2),
        RispostaDellaProva('Mi scuso subito e spiego cosa intendevo', 3),
      ]),
      DomandaDellaProva(
          10, 'Qualcuno racconta una cosa su di te che non è vera.', [
        RispostaDellaProva('Lascio correre, chi mi conosce lo sa', 0),
        RispostaDellaProva('Lo correggo solo se me ne danno occasione', 1),
        RispostaDellaProva('Lo correggo lì per lì', 2),
        RispostaDellaProva('Lo correggo e chiedo perché l\'ha detto', 3),
      ]),
      DomandaDellaProva(11, 'Hai una buona notizia.', [
        RispostaDellaProva('Non la dico finché non è certa', 0),
        RispostaDellaProva('La dico a una persona sola', 1),
        RispostaDellaProva('La dico a chi mi va di dirla', 2),
        RispostaDellaProva('La dico a tutti, subito', 3),
      ]),
      DomandaDellaProva(12, 'Devi chiedere un favore.', [
        RispostaDellaProva(
            'Non lo chiedo e faccio [da solo|da sola|per conto mio]', 0),
        RispostaDellaProva('Lo chiedo girandoci intorno', 1),
        RispostaDellaProva('Lo chiedo chiaramente', 2),
        RispostaDellaProva(
            'Lo chiedo chiaramente e dico anche perché mi serve', 3),
      ]),
    ],
    fasce: [
      FasciaDellaProva(0, 25, 'Il Pozzo',
          'Quello che hai dentro resta dentro e non per paura: perché non tutto va detto. Chi ti conosce lo sa e viene a cercarti.'),
      FasciaDellaProva(26, 50, 'La Soglia',
          'Parli quando ne vale la pena e prima pesi. Chi ti ascolta sa che se apri bocca c\'è un motivo.'),
      FasciaDellaProva(51, 75, 'Il Ponte',
          'Le cose le dici e le dici in tempo. È la posizione più scomoda e la più utile a chi ti sta intorno.'),
      FasciaDellaProva(76, 100, 'Il Vento',
          'Esce tutto e subito. A volte arriva prima delle parole giuste, ma nessuno deve indovinare cosa pensi.'),
    ],
  ),
  TemaDellaProva(
    numero: 2,
    nome: 'Come ami adesso',
    domande: [
      DomandaDellaProva(1, 'La sera perfetta con la persona a cui tieni.', [
        RispostaDellaProva('Ognuno per conto suo nella stessa stanza', 0),
        RispostaDellaProva('A casa, senza programmi', 1),
        RispostaDellaProva('Fuori, in un posto nuovo', 2),
        RispostaDellaProva('Fuori, con altra gente intorno', 3),
      ]),
      DomandaDellaProva(
          2, 'Cosa ti manca di più quando una persona non c\'è.', [
        RispostaDellaProva(
            'Niente, mi trovo bene [da solo|da sola|per conto mio]', 0),
        RispostaDellaProva('Sapere che c\'è', 1),
        RispostaDellaProva('Le cose di tutti i giorni insieme', 2),
        RispostaDellaProva('La sua presenza fisica, continua', 3),
      ]),
      DomandaDellaProva(3, 'Un legame si capisce da.', [
        RispostaDellaProva('Quanto resiste al silenzio', 0),
        RispostaDellaProva('Quanto resiste alle difficoltà', 1),
        RispostaDellaProva('Quanto ci si diverte insieme', 2),
        RispostaDellaProva('Quanto si sente appena ci si vede', 3),
      ]),
      DomandaDellaProva(4, 'Ti innamori.', [
        RispostaDellaProva('Quasi mai e me ne accorgo tardi', 0),
        RispostaDellaProva('Piano, dopo mesi', 1),
        RispostaDellaProva('Quando capisco come ragiona', 2),
        RispostaDellaProva('Subito, al primo sguardo', 3),
      ]),
      DomandaDellaProva(5, 'Nel legame hai bisogno di.', [
        RispostaDellaProva('Molto spazio mio', 0),
        RispostaDellaProva('Uno spazio mio e uno comune', 1),
        RispostaDellaProva('Fare quasi tutto insieme', 2),
        RispostaDellaProva('Non staccarmi mai', 3),
      ]),
      DomandaDellaProva(6, 'La gelosia.', [
        RispostaDellaProva('Non la provo e non la capisco', 0),
        RispostaDellaProva('La provo e me la tengo', 1),
        RispostaDellaProva('La provo e la dico', 2),
        RispostaDellaProva('La provo forte e si vede', 3),
      ]),
      DomandaDellaProva(
          7,
          '[Cosa ti fa sentire amato|Cosa ti fa sentire amata|Cosa ti fa sentire l\'affetto di una persona].',
          [
            RispostaDellaProva('Che mi lascino in pace quando serve', 0),
            RispostaDellaProva('Che si ricordino le cose che ho detto', 1),
            RispostaDellaProva('Che mi cerchino', 2),
            RispostaDellaProva('Che me lo dicano a parole', 3),
          ]),
      DomandaDellaProva(8, 'Una storia finisce.', [
        RispostaDellaProva('Chiudo e non ne parlo più', 0),
        RispostaDellaProva('Ci metto mesi ma non lo faccio vedere', 1),
        RispostaDellaProva('Ne parlo con chi mi vuole bene', 2),
        RispostaDellaProva('Ci sto male davanti a tutti', 3),
      ]),
      DomandaDellaProva(9, 'Il primo appuntamento.', [
        RispostaDellaProva('Non li faccio, le cose nascono da sole', 0),
        RispostaDellaProva('In un posto che conosco', 1),
        RispostaDellaProva('In un posto nuovo per tutti e due', 2),
        RispostaDellaProva('Dove capita, l\'importante è esserci', 3),
      ]),
      DomandaDellaProva(10, 'Una persona ti piace ma non lo sa.', [
        RispostaDellaProva('Non lo saprà mai', 0),
        RispostaDellaProva('Aspetto che se ne accorga', 1),
        RispostaDellaProva('Mi faccio notare senza dirlo', 2),
        RispostaDellaProva('Glielo dico', 3),
      ]),
      DomandaDellaProva(11, 'Cosa perdoni più facilmente.', [
        RispostaDellaProva('Niente, io ricordo', 0),
        RispostaDellaProva('Un errore fatto in buona fede', 1),
        RispostaDellaProva('Una parola detta di getto', 2),
        RispostaDellaProva('Quasi tutto, se c\'è affetto', 3),
      ]),
      DomandaDellaProva(12, 'L\'amore che vorresti.', [
        RispostaDellaProva('Tranquillo, senza scosse', 0),
        RispostaDellaProva('Solido, costruito nel tempo', 1),
        RispostaDellaProva('Vivo, che cambia insieme a noi', 2),
        RispostaDellaProva('Forte, che si sente addosso', 3),
      ]),
    ],
    fasce: [
      FasciaDellaProva(0, 25, 'La Radice',
          'Ami stando, non dicendo. Chi ti sceglie deve avere la pazienza di accorgersene e chi la trova non se ne va più.'),
      FasciaDellaProva(26, 50, 'La Casa',
          'Costruisci piano e tieni. Non è freddezza, è il modo in cui le cose durano.'),
      FasciaDellaProva(51, 75, 'Il Cammino',
          'Ami muovendoti insieme. Hai bisogno che un legame vada da qualche parte, non solo che resti.'),
      FasciaDellaProva(76, 100, 'Il Fuoco',
          'Ami forte e si vede da fuori. Dai molto e chiedi altrettanto. Con te nessuno resta nel dubbio.'),
    ],
  ),
  TemaDellaProva(
    numero: 3,
    nome: 'Dove metti la forza',
    domande: [
      DomandaDellaProva(
          1, 'Un ostacolo inatteso a metà di una cosa importante.', [
        RispostaDellaProva('Mi fermo e aspetto che si sistemi', 0),
        RispostaDellaProva('Cerco un\'altra strada', 1),
        RispostaDellaProva('Lo affronto di petto', 2),
        RispostaDellaProva('Lo affronto subito e con rabbia', 3),
      ]),
      DomandaDellaProva(2, 'Qualcuno ti tratta male senza motivo.', [
        RispostaDellaProva('Me ne vado', 0),
        RispostaDellaProva('Rispondo freddo', 1),
        RispostaDellaProva('Gli chiedo cosa c\'è', 2),
        RispostaDellaProva('Rispondo con la stessa moneta', 3),
      ]),
      DomandaDellaProva(
          3, 'Dove finisce la tua energia in una giornata storta.', [
        RispostaDellaProva('Si spegne, mi chiudo', 0),
        RispostaDellaProva('La metto in una cosa pratica', 1),
        RispostaDellaProva('La metto nel sistemare il problema', 2),
        RispostaDellaProva('La butto fuori, muovendomi', 3),
      ]),
      DomandaDellaProva(4, 'Una cosa che vuoi e che non arriva.', [
        RispostaDellaProva('Smetto di volerla', 0),
        RispostaDellaProva('Aspetto il momento buono', 1),
        RispostaDellaProva('Insisto in modo diverso', 2),
        RispostaDellaProva('Insisto finché non cedo io o cede lei', 3),
      ]),
      DomandaDellaProva(5, 'In una discussione accesa.', [
        RispostaDellaProva('Esco dalla stanza', 0),
        RispostaDellaProva('Taccio e ascolto', 1),
        RispostaDellaProva('Tengo il punto con calma', 2),
        RispostaDellaProva('Alzo la voce', 3),
      ]),
      DomandaDellaProva(
          6,
          '[Quando sei stanco|Quando sei stanca|Quando arriva la stanchezza].',
          [
            RispostaDellaProva('Mi fermo e basta', 0),
            RispostaDellaProva('Rallento', 1),
            RispostaDellaProva('Finisco quello che ho cominciato', 2),
            RispostaDellaProva('Vado avanti anche oltre il dovuto', 3),
          ]),
      DomandaDellaProva(7, 'Una ingiustizia che non ti riguarda.', [
        RispostaDellaProva('Non è affar mio', 0),
        RispostaDellaProva('Ne parlo con qualcuno', 1),
        RispostaDellaProva('Mi metto in mezzo', 2),
        RispostaDellaProva('Mi metto in mezzo subito e senza pensarci', 3),
      ]),
      DomandaDellaProva(8, 'La competizione.', [
        RispostaDellaProva('La evito', 0),
        RispostaDellaProva('Partecipo senza guardare gli altri', 1),
        RispostaDellaProva('Mi diverte', 2),
        RispostaDellaProva('Devo vincere', 3),
      ]),
      DomandaDellaProva(9, 'Qualcuno ti dice che non ce la farai.', [
        RispostaDellaProva('Forse ha ragione', 0),
        RispostaDellaProva('Me lo segno', 1),
        RispostaDellaProva('Mi carica', 2),
        RispostaDellaProva('Lo faccio solo per dimostrargli che sbaglia', 3),
      ]),
      DomandaDellaProva(10, 'Il tuo modo di cominciare una cosa nuova.', [
        RispostaDellaProva('Guardo gli altri farla prima', 0),
        RispostaDellaProva('Studio e poi parto', 1),
        RispostaDellaProva('Parto e imparo strada facendo', 2),
        RispostaDellaProva(
            'Parto subito, [anche impreparato|anche impreparata|senza prepararmi]',
            3),
      ]),
      DomandaDellaProva(11, 'La rabbia.', [
        RispostaDellaProva('Non la sento quasi mai', 0),
        RispostaDellaProva('La sento e passa da sola', 1),
        RispostaDellaProva('La sento e la uso', 2),
        RispostaDellaProva('La sento e mi travolge', 3),
      ]),
      DomandaDellaProva(12, 'Difendere una persona cara.', [
        RispostaDellaProva('Le dico di difendersi da sola', 0),
        RispostaDellaProva('La aiuto dopo, in disparte', 1),
        RispostaDellaProva('Mi metto davanti', 2),
        RispostaDellaProva('Mi metto davanti e perdo la testa', 3),
      ]),
    ],
    fasce: [
      FasciaDellaProva(0, 25, 'L\'Acqua Ferma',
          'Non spendi forza dove non serve. Sembri cedevole e invece [sei quello che|sei quella che|sei chi] resta in piedi quando gli altri si sono consumati.'),
      FasciaDellaProva(26, 50, 'L\'Arco',
          'Tendi quando serve e lasci andare al momento giusto. La tua forza si vede solo nel risultato.'),
      FasciaDellaProva(51, 75, 'La Lama',
          'Affronti e non ti nascondi. Chi ti ha accanto sa che in una difficoltà ci sei.'),
      FasciaDellaProva(76, 100, 'Il Maglio',
          'Spingi con tutto quello che hai. Apri strade che gli altri non aprirebbero e qualche volta sfondi anche porte aperte.'),
    ],
  ),
  TemaDellaProva(
    numero: 4,
    nome: 'Quello che è maturo',
    domande: [
      DomandaDellaProva(1, 'Una cosa che va avanti per inerzia.', [
        RispostaDellaProva('Continuo, cambiare costa di più', 0),
        RispostaDellaProva('Aspetto che finisca da sola', 1),
        RispostaDellaProva('La chiudo quando trovo il modo', 2),
        RispostaDellaProva('La chiudo subito', 3),
      ]),
      DomandaDellaProva(2, 'Riconosci di avere finito un percorso.', [
        RispostaDellaProva('Non lo riconosco mai, resto', 0),
        RispostaDellaProva('Me ne accorgo molto dopo', 1),
        RispostaDellaProva('Me ne accorgo quando succede', 2),
        RispostaDellaProva('Lo sento prima che sia evidente', 3),
      ]),
      DomandaDellaProva(3, 'Una cosa ti è riuscita bene.', [
        RispostaDellaProva('Passo subito alla prossima', 0),
        RispostaDellaProva('Me ne accorgo appena', 1),
        RispostaDellaProva('Me la godo un momento', 2),
        RispostaDellaProva('La festeggio e lo dico', 3),
      ]),
      DomandaDellaProva(4, 'Buttare via cose vecchie.', [
        RispostaDellaProva('Non butto niente', 0),
        RispostaDellaProva(
            'Butto quando [sono costretto|sono costretta|non posso farne a meno]',
            1),
        RispostaDellaProva('Faccio pulizia ogni tanto', 2),
        RispostaDellaProva('Butto facilmente e senza rimpianti', 3),
      ]),
      DomandaDellaProva(5, 'Un rapporto che non dà più niente.', [
        RispostaDellaProva('Resta come è, fa parte della mia vita', 0),
        RispostaDellaProva('Lo lascio raffreddare', 1),
        RispostaDellaProva('Ne parlo apertamente', 2),
        RispostaDellaProva('Lo chiudo', 3),
      ]),
      DomandaDellaProva(6, 'Quando raccogli i frutti di una fatica.', [
        RispostaDellaProva('Mi sembra sempre poco', 0),
        RispostaDellaProva('Penso già alla prossima fatica', 1),
        RispostaDellaProva('Mi fermo a guardare', 2),
        RispostaDellaProva(
            '[Ne vado fiero|Ne vado fiera|Ne provo orgoglio] e lo dico', 3),
      ]),
      DomandaDellaProva(7, 'Una cosa che rimandi da anni.', [
        RispostaDellaProva('La rimanderò ancora', 0),
        RispostaDellaProva('Ci penso spesso e non la faccio', 1),
        RispostaDellaProva('Ho deciso quando la farò', 2),
        RispostaDellaProva('L\'ho appena fatta', 3),
      ]),
      DomandaDellaProva(8, 'Guardare indietro.', [
        RispostaDellaProva('Non guardo mai indietro', 0),
        RispostaDellaProva('Solo quando mi ci costringono', 1),
        RispostaDellaProva('Ogni tanto e mi serve', 2),
        RispostaDellaProva('Spesso e ne tiro fuori qualcosa', 3),
      ]),
      DomandaDellaProva(9, 'Cosa fai quando una fase della tua vita finisce.', [
        RispostaDellaProva('Faccio finta che non sia finita', 0),
        RispostaDellaProva('Mi adatto senza pensarci', 1),
        RispostaDellaProva('Mi prendo del tempo per capire', 2),
        RispostaDellaProva('Comincio subito quella nuova', 3),
      ]),
      DomandaDellaProva(10, 'Un debito morale verso qualcuno.', [
        RispostaDellaProva('Lo tengo e basta', 0),
        RispostaDellaProva('Ci penso e non faccio niente', 1),
        RispostaDellaProva('Cerco il modo di saldarlo', 2),
        RispostaDellaProva('Lo salderei anche se nessuno lo ricorda', 3),
      ]),
      DomandaDellaProva(11, 'Il tuo rapporto con le cose non finite.', [
        RispostaDellaProva('Ne ho tante e dormo bene', 0),
        RispostaDellaProva('Ne ho tante e mi pesano', 1),
        RispostaDellaProva('Ne ho poche', 2),
        RispostaDellaProva('Non sopporto di lasciare le cose a metà', 3),
      ]),
      DomandaDellaProva(12, 'Una verità che hai capito solo col tempo.', [
        RispostaDellaProva('Non mi è mai successo', 0),
        RispostaDellaProva('Sì, una o due', 1),
        RispostaDellaProva('Sì, parecchie', 2),
        RispostaDellaProva('Sì, hanno cambiato come vivo', 3),
      ]),
    ],
    fasce: [
      FasciaDellaProva(0, 25, 'Il Grano Fermo',
          'Tieni tutto e niente va perduto. [Sei quello che|Sei quella che|Sei chi] conserva anche quando gli altri hanno già buttato.'),
      FasciaDellaProva(26, 50, 'La Falce Lenta',
          'Raccogli quando [sei sicuro|sei sicura|hai la certezza]. Arrivi dopo, ma non sbagli raccolto.'),
      FasciaDellaProva(51, 75, 'La Luna Alta',
          'Vedi quando una cosa è arrivata e la chiudi. È la posizione di chi non si porta dietro peso inutile.'),
      FasciaDellaProva(76, 100, 'Il Campo Aperto',
          'Lasci andare prima ancora che diventi necessario. Per questo hai sempre spazio per la cosa dopo.'),
    ],
  ),
  TemaDellaProva(
    numero: 5,
    nome: 'Quello che comincia',
    domande: [
      DomandaDellaProva(1, 'Un\'occasione che non hai cercato.', [
        RispostaDellaProva('La lascio passare', 0),
        RispostaDellaProva('Ci penso finché non scade', 1),
        RispostaDellaProva('La valuto davvero', 2),
        RispostaDellaProva('La prendo', 3),
      ]),
      DomandaDellaProva(2, 'Cambiare città.', [
        RispostaDellaProva('Mai', 0),
        RispostaDellaProva('Solo [se costretto|se costretta|per necessità]', 1),
        RispostaDellaProva('Ci ho pensato più di una volta', 2),
        RispostaDellaProva('L\'ho già fatto o lo farei domani', 3),
      ]),
      DomandaDellaProva(
          3, 'Imparare una cosa da zero, [da adulto|da adulta|a questa età].', [
        RispostaDellaProva('Non ne ho voglia', 0),
        RispostaDellaProva('Se serve lo faccio', 1),
        RispostaDellaProva('Mi piace', 2),
        RispostaDellaProva('Ne comincio una all\'anno', 3),
      ]),
      DomandaDellaProva(4, 'Il primo giorno in un posto nuovo.', [
        RispostaDellaProva('Vorrei essere altrove', 0),
        RispostaDellaProva('Sto in disparte e guardo', 1),
        RispostaDellaProva('Mi guardo intorno con curiosità', 2),
        RispostaDellaProva('Mi butto subito', 3),
      ]),
      DomandaDellaProva(5, 'Una strada che non sai dove porta.', [
        RispostaDellaProva('Torno indietro', 0),
        RispostaDellaProva('Chiedo a qualcuno', 1),
        RispostaDellaProva('La faccio fino in fondo', 2),
        RispostaDellaProva('La faccio apposta perché non so dove porta', 3),
      ]),
      DomandaDellaProva(6, 'Quando hai un\'idea nuova.', [
        RispostaDellaProva('Resta un\'idea', 0),
        RispostaDellaProva('La scrivo e la lascio lì', 1),
        RispostaDellaProva('Provo a vedere se sta in piedi', 2),
        RispostaDellaProva('Comincio prima di finire di pensarla', 3),
      ]),
      DomandaDellaProva(7, 'Le persone nuove.', [
        RispostaDellaProva('Non me ne servono altre', 0),
        RispostaDellaProva('Arrivano se arrivano', 1),
        RispostaDellaProva('Mi fa piacere conoscerne', 2),
        RispostaDellaProva('Ne cerco sempre', 3),
      ]),
      DomandaDellaProva(8, 'La parola rischio.', [
        RispostaDellaProva('Mi mette in guardia', 0),
        RispostaDellaProva('Mi fa pensare', 1),
        RispostaDellaProva('Mi incuriosisce', 2),
        RispostaDellaProva('Mi attira', 3),
      ]),
      DomandaDellaProva(9, 'Ricominciare da capo dopo un fallimento.', [
        RispostaDellaProva('Non credo che lo rifarei', 0),
        RispostaDellaProva('Ci metterei molto', 1),
        RispostaDellaProva('L\'ho fatto', 2),
        RispostaDellaProva('L\'ho fatto più volte e lo rifarei', 3),
      ]),
      DomandaDellaProva(10, 'Un mestiere diverso dal tuo.', [
        RispostaDellaProva('Non ci penso', 0),
        RispostaDellaProva('Qualche volta ci fantastico', 1),
        RispostaDellaProva('So già quale', 2),
        RispostaDellaProva('Ci sto lavorando', 3),
      ]),
      DomandaDellaProva(11, 'Cosa ti ferma di solito.', [
        RispostaDellaProva('Quasi tutto', 0),
        RispostaDellaProva('Il rischio di perdere quello che ho', 1),
        RispostaDellaProva('Il tempo che non ho', 2),
        RispostaDellaProva('Niente, parto e vedo', 3),
      ]),
      DomandaDellaProva(12, 'Il tuo prossimo passo.', [
        RispostaDellaProva('Non lo so e non lo cerco', 0),
        RispostaDellaProva('Non lo so e mi preoccupa', 1),
        RispostaDellaProva('Lo sto cercando', 2),
        RispostaDellaProva('So già qual è', 3),
      ]),
    ],
    fasce: [
      FasciaDellaProva(0, 25, 'La Pietra',
          'Sai dove stai e non ti serve altro. Chi ha bisogno di un punto fermo guarda te.'),
      FasciaDellaProva(26, 50, 'La Porta Socchiusa',
          'Il nuovo ti interessa se entra piano. Non ti butti e non ti chiudi.'),
      FasciaDellaProva(51, 75, 'Il Sentiero',
          'Ti muovi verso quello che non conosci, con gli occhi aperti. È la posizione di chi cambia davvero, non per noia.'),
      FasciaDellaProva(76, 100, 'La Prua',
          '[Vai per primo|Vai per prima|Apri la strada] e gli altri ti seguono. Qualche volta arrivi dove non c\'era niente da trovare e qualche volta trovi tutto.'),
    ],
  ),
  TemaDellaProva(
    numero: 6,
    nome: 'Chi stai diventando',
    domande: [
      DomandaDellaProva(1,
          'Quanto somigli a [te stesso|te stessa|chi eri] di cinque anni fa.', [
        RispostaDellaProva(
            '[Sono identico|Sono identica|Non è cambiato niente]', 0),
        RispostaDellaProva('Qualcosa è cambiato', 1),
        RispostaDellaProva('Molto è cambiato', 2),
        RispostaDellaProva('Sono un\'altra persona', 3),
      ]),
      DomandaDellaProva(2, 'Una cosa che facevi e non fai più.', [
        RispostaDellaProva('Non me ne viene in mente nessuna', 0),
        RispostaDellaProva('Una e mi manca', 1),
        RispostaDellaProva('Diverse e va bene così', 2),
        RispostaDellaProva(
            'Quasi tutto e [ne sono contento|ne sono contenta|senza rimpianti]',
            3),
      ]),
      DomandaDellaProva(3, 'Il giudizio degli altri su di te.', [
        RispostaDellaProva('Mi pesa ancora', 0),
        RispostaDellaProva('Mi pesa meno di prima', 1),
        RispostaDellaProva('Lo ascolto e decido io', 2),
        RispostaDellaProva('Non lo considero più', 3),
      ]),
      DomandaDellaProva(
          4,
          'Una cosa di cui [andavi fiero|andavi fiera|ti vantavi] e adesso non più.',
          [
            RispostaDellaProva('Nessuna', 0),
            RispostaDellaProva('Una e non ne parlo', 1),
            RispostaDellaProva('Una e ci rido sopra', 2),
            RispostaDellaProva(
                'Diverse ed è il segno [che sono cresciuto|che sono cresciuta|della crescita]',
                3),
          ]),
      DomandaDellaProva(5, 'Chi eri a vent\'anni.', [
        RispostaDellaProva('Lo rimpiango', 0),
        RispostaDellaProva('Lo capisco', 1),
        RispostaDellaProva('Gli voglio bene ma non tornerei', 2),
        RispostaDellaProva('Quasi non lo riconosco', 3),
      ]),
      DomandaDellaProva(6, 'Cosa ti ha cambiato di più.', [
        RispostaDellaProva('Niente in particolare', 0),
        RispostaDellaProva('Le persone', 1),
        RispostaDellaProva('Una cosa che è andata male', 2),
        RispostaDellaProva('Una scelta che ho fatto io', 3),
      ]),
      DomandaDellaProva(7, 'Le cose che dicevi di non fare mai.', [
        RispostaDellaProva('Non le ho mai fatte', 0),
        RispostaDellaProva('Una l\'ho fatta', 1),
        RispostaDellaProva('Più di una', 2),
        RispostaDellaProva('Quasi tutte e ho capito perché', 3),
      ]),
      DomandaDellaProva(8, 'Il tuo carattere.', [
        RispostaDellaProva('È quello e non cambia', 0),
        RispostaDellaProva('Si è smussato', 1),
        RispostaDellaProva('L\'ho lavorato apposta', 2),
        RispostaDellaProva('L\'ho cambiato nelle cose che non mi piacevano', 3),
      ]),
      DomandaDellaProva(
          9, 'Cosa diresti a [te stesso|te stessa|chi eri] di dieci anni fa.', [
        RispostaDellaProva('Niente, non ascolterebbe', 0),
        RispostaDellaProva('Di avere pazienza', 1),
        RispostaDellaProva('Di non avere paura', 2),
        RispostaDellaProva('Che va bene così, arriverai', 3),
      ]),
      DomandaDellaProva(10, 'Le tue idee su una cosa importante.', [
        RispostaDellaProva('Sono sempre le stesse', 0),
        RispostaDellaProva('Si sono rafforzate', 1),
        RispostaDellaProva('Si sono spostate', 2),
        RispostaDellaProva('Sono ribaltate', 3),
      ]),
      DomandaDellaProva(
          11, 'Quanto conosci [te stesso|te stessa|la persona che sei].', [
        RispostaDellaProva('Poco e non ci penso', 0),
        RispostaDellaProva('Abbastanza', 1),
        RispostaDellaProva('Molto, ma mi sorprendo ancora', 2),
        RispostaDellaProva('Mi studio da anni', 3),
      ]),
      DomandaDellaProva(12, 'Fra cinque anni.', [
        RispostaDellaProva('Sarò uguale', 0),
        RispostaDellaProva('Spero di stare meglio', 1),
        RispostaDellaProva('Sarò in un altro punto', 2),
        RispostaDellaProva('Sto già andando lì', 3),
      ]),
    ],
    fasce: [
      FasciaDellaProva(0, 25, 'La Quercia',
          '[Sei rimasto quello|Sei rimasta quella|Niente è cambiato] e non è poco: in un mondo che cambia tutto, sapere dove sei tu è un valore.'),
      FasciaDellaProva(26, 50, 'Il Fiume Lento',
          'Cambi senza accorgertene e un giorno guardi indietro e la riva è lontana.'),
      FasciaDellaProva(51, 75, 'La Soglia Attraversata',
          'Hai cambiato per scelta e lo sai. Non è stato gratis e non lo rifaresti diversamente.'),
      FasciaDellaProva(76, 100, 'La Muta',
          'Hai lasciato indietro più di una pelle. Chi ti ha conosciuto prima fatica a seguirti, chi ti conosce adesso non immagina com\'eri.'),
    ],
  ),
];
