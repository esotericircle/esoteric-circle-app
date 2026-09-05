import 'package:flutter/foundation.dart';

import 'archetype.dart';

/// Il ritratto di un archetipo, in cinque campi.
///
/// L'Ombra non e' un personaggio nuovo: e' lo stesso archetipo distorto, quindi
/// vive qui dentro come campo e non come voce a se'. A video si rende con la
/// stessa statua trattata in ombra, mai con un'immagine diversa.
@immutable
class ArchetypeRitratto {
  const ArchetypeRitratto({
    required this.archetipo,
    required this.essenza,
    required this.luce,
    required this.ombra,
    required this.amore,
    required this.lavoro,
    required this.quotidianita,
  });

  final Archetype archetipo;

  /// Una riga sola, quella che sta sulla card e sotto il nome.
  final String essenza;

  final String luce;
  final String ombra;
  final String amore;
  final String lavoro;

  /// Come l'archetipo vive la giornata, coerente con essenza, luce e ombra.
  final String quotidianita;
}

/// Il corpus dei dodici, come dati e non come testo sparso nelle schermate.
///
/// Zero AI a runtime: quel che si legge nel responso e' scritto qui, uguale a
/// se stesso su ogni dispositivo e a ogni esecuzione.
class ArchetypeCorpus {
  const ArchetypeCorpus._();

  static const Map<Archetype, ArchetypeRitratto> _per = {
    Archetype.innocente: ArchetypeRitratto(
      archetipo: Archetype.innocente,
      essenza: 'La fiducia che apre il mondo.',
      luce:
          'Porti uno sguardo pulito che sa ancora vedere il buono dove altri hanno smesso di cercarlo. La tua fiducia non è ingenuità ma una scelta coraggiosa, perché credere che le cose possano andare bene apre porte che la paura tiene chiuse. Dove arrivi porti leggerezza, speranza e la rara forza di ricominciare senza rancore.',
      ombra: 'Nega i problemi, resta ingenuo e dipendente.',
      amore:
          'In amore ti apri con una fiducia disarmante, senza calcoli né seconde intenzioni. Credi nel bene di chi ami e gli lasci lo spazio di mostrarlo. La tua tenerezza mette a proprio agio e scioglie le difese dell\'altro. Il rischio è idealizzare il partner e chiudere gli occhi sui segnali scomodi. Impara a fidarti restando lucido, così la fiducia diventa forza invece che ferita.',
      lavoro:
          'Sul lavoro porti entusiasmo fresco e uno sguardo che vede possibilità dove altri vedono soltanto ostacoli. La tua energia positiva contagia il gruppo e tiene alto il morale nei momenti difficili. Rendi al meglio negli ambienti dove si può ancora sognare e costruire. Il tuo limite è sottovalutare i rischi concreti e le scadenze dure. Un pizzico di realismo trasforma lo slancio in risultati che durano.',
      quotidianita:
          'Nella quotidianità cerchi le cose semplici che fanno stare bene: una passeggiata, una piccola gioia, un momento di pace. Affronti la giornata con leggerezza e un ottimismo che non si spegne facilmente. Ti fidi delle persone e del corso naturale delle cose. Fatichi quando la realtà ti chiede diffidenza o durezza. Il tuo equilibrio nasce dal proteggere quella purezza senza negare i problemi.',
    ),
    Archetype.esploratore: ArchetypeRitratto(
      archetipo: Archetype.esploratore,
      essenza: 'L\'orizzonte è casa.',
      luce:
          'Non ti accontenti di ciò che ti hanno detto, vuoi vederlo con i tuoi occhi. La libertà per te è un bisogno vitale: ogni orizzonte nuovo è una domanda a cui rispondi partendo. Cerchi esperienze vere, non comode. In quel cercare scopri chi sei, un pezzo di strada alla volta.',
      ombra: 'Fugge sempre, non si lega, sradicato.',
      amore:
          'In amore hai bisogno di spazio e di un compagno di viaggio, non di un porto che ti trattiene. Ti leghi a chi condivide la tua sete di scoperta e cammina al tuo fianco. Detesti la routine che spegne e le gabbie travestite da sicurezza. Il rischio è scappare appena il legame si fa profondo, scambiando l\'intimità per una trappola. La libertà vera la trovi restando, quando scegli di esplorare in due.',
      lavoro:
          'Sul lavoro dai il meglio dove puoi muoverti, cambiare e inventare, lontano dagli schemi rigidi. Ami i progetti nuovi, i territori inesplorati e le sfide che nessuno ha ancora affrontato. La tua curiosità apre strade che gli altri non vedevano. Il tuo limite è mollare prima di finire, attratto dalla prossima avventura. Imparare a portare a termine ciò che inizi rende preziosa la tua irrequietezza.',
      quotidianita:
          'Nella quotidianità mal sopporti le abitudini fisse e cerchi sempre una variazione, un percorso diverso, un\'esperienza da provare. Ti muovi molto, dentro e fuori di casa, con un bisogno costante di aria e di orizzonte. La monotonia ti pesa più di ogni fatica. Il tuo rischio è non radicarti mai in nulla e restare sradicato. Trovi pace quando fai della tua vita un viaggio che ha comunque una casa.',
    ),
    Archetype.saggio: ArchetypeRitratto(
      archetipo: Archetype.saggio,
      essenza: 'La verità è la via.',
      luce:
          'Prima di giudicare, guardi e capisci. Cerchi la verità delle cose, non la versione più comoda. Sai mettere ordine dove gli altri vedono confusione. Le persone vengono da te per un consiglio, perché dirai ciò che è vero e non ciò che fa piacere. La tua forza è vedere lontano.',
      ombra: 'Freddo e dogmatico, giudica e non agisce.',
      amore:
          'In amore vai in profondità e cerchi una mente con cui capirti oltre le parole. Ti innamori di chi ti fa pensare e con cui puoi condividere il senso delle cose. La tua lealtà è solida, ma tieni le emozioni a distanza per proteggerti. Il rischio è analizzare il sentimento invece di viverlo, restando spettatore. Impari ad amare quando scaldi la testa col cuore e ti lasci toccare davvero.',
      lavoro:
          'Sul lavoro sei il consigliere e lo stratega, quello che vede lontano e mette ordine nella confusione. Le persone vengono da te per capire, perché dici ciò che è vero e non ciò che conviene. La tua lucidità evita errori che agli altri sfuggono. Il tuo limite è restare nel pensiero senza passare all\'azione, in attesa della certezza perfetta. Il tuo valore cresce quando la conoscenza diventa decisione.',
      quotidianita:
          'Nella quotidianità ti ritagli spazi di silenzio per leggere, riflettere e capire il mondo. Osservi prima di parlare e non ti fai trascinare dalla fretta o dalla moda del momento. Hai bisogno di senso in ciò che fai, altrimenti ti annoi. Il tuo rischio è isolarti sui libri e giudicare chi vive di pancia. Stai bene quando la tua saggezza scende dalla mente e diventa vita concreta.',
    ),
    Archetype.eroe: ArchetypeRitratto(
      archetipo: Archetype.eroe,
      essenza: 'Il coraggio prima della paura.',
      luce:
          'Quando arriva la prova non ti volti dall\'altra parte. La paura la senti come tutti, ma scegli di agire lo stesso. In quel gesto trovi la tua misura. Proteggi chi ti sta accanto, non ti arrendi. Trasformi una difficoltà in un riscatto. La tua forza è il coraggio che passa all\'azione.',
      ombra: 'Vede nemici ovunque, spietato e arrogante.',
      amore:
          'In amore ti batti per chi ami e lo proteggi con tutto te stesso, pronto a metterti in gioco. La tua dedizione è totale e non ti tiri indietro davanti alle difficoltà del legame. Vuoi essere all\'altezza e a volte trasformi la relazione in una prova da superare. Il rischio è la durezza, il voler vincere invece che incontrare l\'altro. Impari ad amare quando alla forza aggiungi la dolcezza e la resa.',
      lavoro:
          'Sul lavoro eccelli sotto pressione, quando la posta è alta e serve qualcuno che agisca. Non ti spaventano le sfide difficili, anzi ti danno la misura di ciò che vali. Guidi con l\'esempio e trascini il gruppo verso il risultato. Il tuo limite è vedere nemici e competizione ovunque, anche dove servirebbe collaborare. Diventi grande quando metti il coraggio al servizio di tutti, non solo della vittoria.',
      quotidianita:
          'Nella quotidianità affronti la giornata di petto e trasformi ogni ostacolo in una sfida da vincere. Non rimandi, agisci, ti senti vivo quando c\'è qualcosa per cui lottare. La calma e l\'attesa ti pesano più della fatica. Il tuo rischio è vivere sempre in tensione e cercare battaglie che non servono. Trovi equilibrio quando impari che non tutto va combattuto e che a volte basta esserci.',
    ),
    Archetype.ribelle: ArchetypeRitratto(
      archetipo: Archetype.ribelle,
      essenza: 'Rompere per liberare.',
      luce:
          'Vedi ciò che è ingiusto e non riesci a far finta di niente. Dici le verità scomode che gli altri tacciono. Rompi le regole che hanno smesso di avere senso. Non distruggi per capriccio, ma per aprire spazio a qualcosa di più vero. La tua forza è il coraggio di cambiare ciò che tutti accettano.',
      ombra: 'Distrugge per distruggere, si autodanneggia.',
      amore:
          'In amore rifiuti gli schemi e cerchi un legame autentico, senza finzioni né regole imposte da fuori. Ti dai a chi ti accetta com\'è, libero e senza maschere. La convenzione ti soffoca e la falsità ti fa fuggire. Il rischio è rompere ogni cosa appena ti senti stretto, distruggendo anche ciò che ha valore. Impari ad amare quando capisci che la vera libertà può vivere dentro un impegno scelto.',
      lavoro:
          'Sul lavoro innovi e sfidi le regole che hanno smesso di avere senso, perché vedi ciò che va cambiato. La tua voglia di rompere lo status quo porta idee che gli altri non osano. Sei prezioso dove serve scuotere un sistema fermo. Il tuo limite è distruggere senza costruire, opporti per principio invece che per scopo. Il tuo talento fiorisce quando la ribellione viene incanalata verso un fine chiaro.',
      quotidianita:
          'Nella quotidianità mal sopporti le imposizioni e fai le cose a modo tuo, contro le abitudini di tutti. Dici quello che pensi anche quando è scomodo e non ti pieghi al conformismo. La routine imposta ti fa sentire ingabbiato. Il tuo rischio è opporti a tutto per riflesso, danneggiando anche te stesso. Stai bene quando la tua indipendenza diventa costruzione di qualcosa di più vero.',
    ),
    Archetype.mago: ArchetypeRitratto(
      archetipo: Archetype.mago,
      essenza: 'Ciò che immagini può accadere.',
      luce:
          'Dove gli altri vedono muri, tu vedi possibilità. Sai che le cose, tu stesso compreso, possono trasformarsi, mentre unisci la visione alla volontà per far accadere ciò che immagini. Leggi in profondità persone e situazioni. Sai cambiare il corso di ciò che sembrava già scritto. La tua forza è dare forma all\'invisibile.',
      ombra: 'Manipola per il potere, inganna.',
      amore:
          'In amore vivi legami intensi e trasformativi, di quelli che cambiano chi li attraversa. Sai leggere l\'altro in profondità e portarlo dove non pensava di poter andare. La tua presenza è magnetica e crea una connessione fuori dal comune. Il rischio è usare quella lettura per manipolare invece che per unire. Ami davvero quando metti il tuo potere al servizio della crescita di entrambi.',
      lavoro:
          'Sul lavoro sei il visionario che apre strade e vede possibilità dove gli altri vedono muri. Trasformi le situazioni e trovi soluzioni che sembravano impossibili. La tua intuizione cambia il corso di ciò che pareva già scritto. Il tuo limite è la tentazione di manipolare e di prendere scorciatoie per il potere. Diventi grande quando la visione resta onesta e serve un bene più ampio del tuo.',
      quotidianita:
          'Nella quotidianità cerchi il senso nascosto delle cose e non ti fermi alla superficie di ciò che accade. Sperimenti, trasformi, provi a far accadere quello che immagini. La banalità ripetuta ti spegne e hai bisogno di profondità. Il tuo rischio è perderti in mondi tuoi o forzare la realtà con l\'inganno. Stai bene quando la tua magia resta ancorata a intenzioni pulite e concrete.',
    ),
    Archetype.realista: ArchetypeRitratto(
      archetipo: Archetype.realista,
      essenza: 'Restare umani, insieme.',
      luce:
          'Hai conosciuto la vita per quello che è. Ne sei uscito concreto e vero senza smettere di essere umano. Non ti servono maschere né piedistalli, stai tra gli altri da pari con empatia e buon senso. Sei quello su cui si può contare, che tiene i piedi per terra quando tutti perdono la testa. La tua forza è restare autentico e vicino.',
      ombra: 'Vittimismo e cinismo, si perde nella massa.',
      amore:
          'In amore cerchi appartenenza vera, un legame concreto fatto di presenza e di fiducia reciproca. Non ami le grandi scene, preferisci i gesti quotidiani che dicono ci sono. Stai bene con chi ti accetta senza pretese e resta accanto nel tempo. Il rischio è accontentarti o lasciarti trascinare dal cinismo quando resti deluso. Ami davvero quando resti aperto e vicino, senza alzare muri per difenderti.',
      lavoro:
          'Sul lavoro sei affidabile e tieni unito il gruppo, quello su cui tutti sanno di poter contare. Porti buon senso, empatia e concretezza dove servono i piedi per terra. Non cerchi il palco, cerchi che le cose funzionino davvero. Il tuo limite è il vittimismo o il cinismo quando ti senti poco riconosciuto. Il tuo valore emerge quando resti autentico e fai da collante umano della squadra.',
      quotidianita:
          'Nella quotidianità stai tra gli altri da pari, senza maschere né piedistalli, con empatia e semplicità. Tieni i piedi per terra quando tutti perdono la testa e riporti al concreto. Ti bastano cose vere e rapporti sinceri per stare bene. Il tuo rischio è perderti nella massa o lasciarti indurire dalla delusione. Trovi equilibrio quando resti umano e vicino senza rinunciare a te stesso.',
    ),
    Archetype.amante: ArchetypeRitratto(
      archetipo: Archetype.amante,
      essenza: 'Nel legame, la vita.',
      luce:
          'Vivi le cose con intensità: il legame con gli altri è dove ti senti davvero vivo. Sai creare bellezza e intimità, ti doni con passione e fai sentire l\'altro visto e importante. Per te un rapporto non è un contorno della vita, è la vita stessa. La tua forza è la capacità di amare e di unire.',
      ombra: 'Ossessivo e geloso, si smarrisce nell\'altro.',
      amore:
          'In amore sei nel tuo territorio: vivi il legame con una passione totale che riempie la vita. Sai creare intimità e bellezza. Fai sentire l\'altro visto, desiderato e importante. Ti doni per intero e cerchi una connessione profonda, non un contorno. Il rischio è annullarti nell\'altro o soffocarlo con gelosia e possesso. Ami davvero quando resti te stesso mentre ti unisci, senza perderti.',
      lavoro:
          'Sul lavoro crei armonia e relazioni: sai tenere insieme le persone attraverso il sentire. Porti calore, estetica e attenzione a chi ti sta accanto, così rendi bello l\'ambiente. Dai il meglio dove contano i legami e la cura del clima umano. Il tuo limite è farti travolgere dalle emozioni o dipendere dall\'approvazione. Il tuo talento brilla quando la passione diventa collaborazione e non dramma.',
      quotidianita:
          'Nella quotidianità cerchi bellezza, intimità e momenti profondi con le persone a cui tieni. Vivi di sensazioni, di piaceri veri e di connessioni che scaldano la giornata. La freddezza e la distanza ti fanno appassire. Il tuo rischio è misurare tutto dall\'affetto ricevuto e smarrirti nell\'altro. Stai bene quando coltivi legami intensi senza dimenticare di amare anche te stesso.',
    ),
    Archetype.giullare: ArchetypeRitratto(
      archetipo: Archetype.giullare,
      essenza: 'Vivere l\'attimo, col sorriso.',
      luce:
          'Sai che la vita va vissuta adesso, così porti allegria dove c\'è pesantezza. Con l\'ironia dici verità che altri non oserebbero. Con una battuta sciogli le tensioni e riporti tutti al presente. Dietro il gioco c\'è intelligenza, non superficialità. La tua forza è alleggerire il mondo senza smettere di guardarlo.',
      ombra: 'Irresponsabile e sfuggente, evita tutto.',
      amore:
          'In amore porti leggerezza e gioia: sai far ridere chi ami anche nei giorni storti. Vivi il rapporto con spontaneità, senza pesi né drammi costruiti. La tua ironia scioglie le tensioni e tiene fresco il legame. Il rischio è restare in superficie e scappare quando le cose si fanno serie. Ami davvero quando dietro il gioco lasci entrare la profondità e resti anche nel difficile.',
      lavoro:
          'Sul lavoro allenti le tensioni e riporti tutti al presente, perché sei il respiro del gruppo. Con una battuta sblocchi un clima teso e fai vedere le cose da un\'altra angolazione. Dietro lo scherzo c\'è un\'intelligenza che coglie ciò che gli altri non dicono. Il tuo limite è la fuga dalle responsabilità e la mancanza di un\'ancora. Il tuo valore cresce quando all\'ironia unisci costanza e serietà quando serve.',
      quotidianita:
          'Nella quotidianità vivi l\'attimo e prendi la giornata con il sorriso, senza caricarti di pesi inutili. Sai godere delle piccole cose e trasformare un momento grigio in una risata. La solennità e la rigidità ti stanno strette. Il tuo rischio è evitare tutto ciò che è scomodo e non prendere niente sul serio. Trovi equilibrio quando alla leggerezza aggiungi il coraggio di guardare anche il difficile.',
    ),
    Archetype.custode: ArchetypeRitratto(
      archetipo: Archetype.custode,
      essenza: 'Prendersi cura è la forza.',
      luce:
          'La tua forza è prenderti cura. Proteggi, sostieni e nutri chi ti sta intorno. Sai esserci senza chiedere nulla in cambio. Dove c\'è qualcuno in difficoltà, tu ci sei, con una presenza calda e affidabile. Il tuo dono è far sentire gli altri al sicuro: è una forza vera, non una debolezza.',
      ombra: 'Il martire che soffoca e ricatta col senso di colpa.',
      amore:
          'In amore ti dai con dedizione totale e metti il bene dell\'altro davanti al tuo. Proteggi, sostieni e nutri chi ami con una presenza calda e costante. La tua cura fa sentire l\'altro al sicuro come pochi sanno fare. Il rischio è soffocare con le attenzioni o dimenticare del tutto i tuoi bisogni. Ami davvero quando impari a ricevere e non solo a dare, lasciandoti curare a tua volta.',
      lavoro:
          'Sul lavoro sei il collante della squadra, quello che tiene insieme le persone e le sostiene. Ti accorgi di chi è in difficoltà e ci sei, con generosità e senza clamore. Crei un ambiente sicuro dove gli altri possono dare il meglio. Il tuo limite è caricarti troppo e diventare il martire che si sacrifica. Il tuo dono fiorisce quando la cura resta scelta libera e non un debito da riscuotere.',
      quotidianita:
          'Nella quotidianità pensi agli altri prima che a te stesso e ti prendi cura di chi ti circonda. La casa, gli affetti e la vicinanza sono il tuo centro, il posto dove dai il meglio. Ti riempie il gesto di esserci per qualcuno che ne ha bisogno. Il tuo rischio è annullarti e ricattare con il senso di colpa quando non sei riconosciuto. Stai bene quando ti prendi cura anche di te con la stessa tenerezza.',
    ),
    Archetype.sovrano: ArchetypeRitratto(
      archetipo: Archetype.sovrano,
      essenza: 'L\'ordine che protegge.',
      luce:
          'Sai guidare, senza tirarti indietro davanti alla responsabilità. Metti ordine dove c\'è caos, crei stabilità intorno a te e ti prendi sulle spalle il peso delle decisioni. Le persone ti seguono perché sentono che sai dove andare. La tua forza è portare un ordine che protegge e fa crescere.',
      ombra: 'Il tiranno rigido, teme il caos e schiaccia.',
      amore:
          'In amore sei leale e stabile: offri un legame solido su cui l\'altro può appoggiarsi. Proteggi la relazione e ti prendi la responsabilità di farla durare nel tempo. La tua presenza dà sicurezza e senso di casa. Il rischio è voler controllare e non lasciare all\'altro il suo spazio di libertà. Ami davvero quando guidi senza dominare e permetti al partner di crescere accanto a te.',
      lavoro:
          'Sul lavoro sei il leader che fa crescere, quello che mette ordine e crea stabilità intorno a sé. Ti prendi sulle spalle il peso delle decisioni e dai una direzione chiara. Le persone ti seguono perché sentono che sai dove andare. Il tuo limite è la rigidità e la paura del caos, che ti fa schiacciare invece che guidare. Diventi grande quando l\'ordine che crei protegge e libera, invece di controllare.',
      quotidianita:
          'Nella quotidianità organizzi, pianifichi e tieni tutto in ordine, perché il caos ti mette a disagio. Ti assumi le responsabilità e dai struttura a ciò che ti circonda. Stai bene quando le cose hanno un posto e una regola sensata. Il tuo rischio è irrigidirti e voler comandare anche dove basterebbe lasciar fare. Trovi equilibrio quando l\'ordine resta al servizio delle persone e non del solo controllo.',
    ),
    Archetype.creatore: ArchetypeRitratto(
      archetipo: Archetype.creatore,
      essenza: 'Dare forma a ciò che non c\'è.',
      luce:
          'Hai bisogno di dare forma a ciò che non esiste ancora. Le idee in te diventano opere. Trasformi l\'immaginazione in qualcosa di reale che prima non c\'era. Vivi per creare bellezza e senso. Nel fare trovi te stesso. La tua forza è l\'immaginazione che si fa mano, poi mondo.',
      ombra: 'Perfezionismo ossessivo, non finisce, o crea per fuggire.',
      amore:
          'In amore porti immaginazione e profondità: vedi nell\'altro possibilità che nessuno aveva colto. Costruisci una relazione come un\'opera, con cura, bellezza e senso. Ti doni con intensità e cerchi un legame che abbia anima. Il rischio è il perfezionismo che pretende dall\'altro ciò che hai idealizzato. Ami davvero quando accetti l\'imperfezione e crei insieme invece di plasmare da solo.',
      lavoro:
          'Sul lavoro sei l\'innovatore e l\'artigiano, quello che trasforma le idee in qualcosa di reale. Immagini ciò che non esiste ancora e gli dai forma con dedizione e talento. Porti bellezza e senso dove altri vedono solo funzione. Il tuo limite è il perfezionismo che non finisce mai o il creare per fuggire dal resto. Il tuo genio si compie quando porti a termine l\'opera e la lasci vivere nel mondo.',
      quotidianita:
          'Nella quotidianità hai sempre qualcosa da creare: trasformi le idee in gesti concreti. Cerchi bellezza in ciò che fai e mal sopporti il vuoto e la ripetizione senza senso. Nel dare forma alle cose trovi te stesso e il tuo equilibrio. Il tuo rischio è perderti nel perfezionismo o usare la creazione come rifugio dalla vita. Stai bene quando crei con gioia e lasci che l\'opera sia finita, non eterna.',
    ),
  };

  /// Il ritratto di un archetipo. C'e' sempre, per tutti e dodici.
  static ArchetypeRitratto di(Archetype a) => _per[a]!;

  /// I dodici ritratti nell'ordine canonico.
  static List<ArchetypeRitratto> get tutti =>
      [for (final a in Archetype.values) _per[a]!];

  /// La riga di trasparenza, aperta dalla piccola icona "Fonti e metodo".
  ///
  /// Non e' un disclaimer che si ripete: quello legale sta una volta sola
  /// all'onboarding. Questa dice da dove viene il metodo e cosa non e'.
  static const String fontiEMetodo =
      'La teoria degli archetipi è di Carl Gustav Jung. I dodici archetipi e la '
      'forma del test vengono dalla tradizione di Carol Pearson e Margaret Mark '
      '(Pearson-Marr Archetype Indicator). Non è una diagnosi: indica gli '
      'archetipi più attivi in te adesso.';
}
