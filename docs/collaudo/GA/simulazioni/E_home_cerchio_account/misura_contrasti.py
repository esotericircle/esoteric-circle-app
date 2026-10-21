# Misura del contrasto WCAG sulle catture renderizzate (GA.10), gruppo E.
# Rettangoli dati nelle coordinate della vista con cui sono stati letti: scala H=1,2 per la cattura vista a 900x2000,
# scala S=2 per i fogli di miniature a 540x1200 (coordinate locali del pannello). Si moltiplica per la scala e si
# ottengono i pixel pieni 1080x2400.
# Per ogni rettangolo: sfondo = colore piu' frequente (modale) e, per scene variabili, il punto piu' chiaro
# (98 percentile della luminanza dei pixel sul lato dello sfondo) o piu' scuro (2 percentile) se il testo e' scuro;
# testo = media dei pixel piu' lontani dallo sfondo modale (3 per cento per distanza).
import sys, os
import numpy as np
from PIL import Image
D = os.path.dirname(os.path.abspath(__file__))
def lin(c):
    c = c/255.0
    return np.where(c <= 0.03928, c/12.92, ((c+0.055)/1.055)**2.4)
def lum(rgb):
    r,g,b = lin(rgb[...,0]), lin(rgb[...,1]), lin(rgb[...,2])
    return 0.2126*r+0.7152*g+0.0722*b
def ratio(l1,l2):
    a,b = max(l1,l2), min(l1,l2)
    return (a+0.05)/(b+0.05)
H=1.2; S=2.0
# (cattura, testo, x0,y0,x1,y1, soglia, scala)
R = [
 # HOME
 ("home_01_aperta","I TUOI DONI DEL GIORNO (titolo striscia)",170,195,730,235,3.0,H),
 ("home_01_aperta","ALBA (etichetta dono)",85,385,190,425,4.5,H),
 ("home_01_aperta","SOFFIO (etichetta dono)",315,385,462,425,4.5,H),
 ("home_01_aperta","TRAMONTO (etichetta dono)",545,385,745,425,4.5,H),
 ("home_01_aperta","IL CIELO SOPRA DI TE, ADESSO (titolo)",160,480,740,520,3.0,H),
 ("home_01_aperta","GIBBOSA CRESCENTE (titolo)",225,695,678,735,3.0,H),
 ("home_01_aperta","La giusta ora per chi nasce sotto Gemelli (corsivo)",125,740,775,782,4.5,H),
 ("home_01_aperta","DIVINAZIONE (etichetta sul carosello)",30,1250,308,1288,3.0,H),
 ("home_01_aperta","ENERGIA (etichetta sul carosello)",695,1250,870,1288,3.0,H),
 ("home_01_aperta","Astrologia, Cartomanzia, Destino (sottotitolo)",145,1408,815,1452,3.0,H),
 ("home_01_aperta","Entra nel Dominio di Medora (pulsante)",150,1510,630,1560,4.5,H),
 ("home_01_aperta","IL CERCHIO (voce barra in basso)",45,1825,222,1860,4.5,H),
 ("home_01_aperta","MEDORA (voce barra in basso)",250,1825,382,1860,4.5,H),
 ("home_02_giu","OROSCOPO UNIVERSALE (etichetta scheda)",38,858,245,925,4.5,H),
 ("home_02_giu","MAPPA DEL VISO (etichetta scheda)",385,865,668,900,4.5,H),
 ("home_02_giu","TROVA UNA RISPOSTA (titolo riga)",40,1005,612,1055,3.0,H),
 ("home_02_giu","Vedi tutto (riga)",678,1015,850,1050,4.5,H),
 ("home_02_giu","ESTRAZIONE RUNE (etichetta scheda)",38,1300,350,1335,4.5,H),
 ("home_02_giu","PER PARTNER E AMICI (titolo riga)",40,1445,615,1490,3.0,H),
 ("home_03_preferite","LE ARTI PREFERITE (titolo riga)",42,975,535,1025,3.0,H),
 ("home_03_preferite","Vedi tutto (arti preferite)",678,985,850,1022,4.5,H),
 ("home_03_preferite","OROSCOPO UNIVERSALE (etichetta)",38,1480,245,1550,4.5,H),
 ("home_04_scegli_arti","LE ARTI PREFERITE (titolo foglio)",62,380,605,435,3.0,H),
 ("home_04_scegli_arti","Scegline fino a 9... (testo foglio)",62,470,825,640,4.5,H),
 ("home_04_scegli_arti","MEDORA (sezione del foglio)",62,718,205,750,4.5,H),
 ("home_04_scegli_arti","Oroscopo Universale (riga del foglio)",62,795,410,840,4.5,H),
 ("home_06_tetto_9","Calendario Lunare Personale (riga non scelta)",62,820,540,860,4.5,H),
 ("home_06_tetto_9","AURA (sezione del foglio)",62,935,155,965,4.5,H),
 ("home_06_tetto_9","FATTO (pulsante testo)",683,1725,808,1765,4.5,H),
 ("home_10_doni_aiuto","ARCANO DELL'ALBA (titolo del foglio)",275,600,520,695,3.0,H),
 ("home_10_doni_aiuto","ALLE 7:00",215,738,410,778,4.5,H),
 ("home_10_doni_aiuto","Guidato da Medora (blu su nero)",160,815,472,852,4.5,H),
 ("home_10_doni_aiuto","Un arcano maggiore scelto al mattino... (testo)",160,900,715,1065,4.5,H),
 ("home_10_doni_aiuto","HO CAPITO (pulsante)",485,1140,710,1178,4.5,H),
 ("home_13_fondo","LA TUA INTENZIONE (titolo riga)",42,585,580,632,3.0,H),
 ("home_13_fondo","SIGILLO DELL'INTENZIONE (etichetta)",38,1090,335,1160,4.5,H),
 ("home_13_fondo","AFFERMAZIONI DEL GIORNO (etichetta)",385,1100,715,1165,4.5,H),
 ("home_13_fondo","IL TUO DESTINO (titolo riga)",42,1240,470,1285,3.0,H),
 ("home_13_fondo","LETTURA KARMICA (etichetta)",38,1535,352,1565,4.5,H),
 ("home_14_inarrivo_girata","I Nodi Lunari: da dove vieni... (scheda girata)",80,1255,640,1350,4.5,H),
 ("home_14_inarrivo_girata","IN ARRIVO, FASE 2 (scheda girata)",83,1390,405,1428,4.5,H),
 ("home_17_cima","IL CIELO SOPRA DI TE, ADESSO (titolo, tinta verde)",160,480,740,520,3.0,H),
 ("home_17_cima","Chi nasce sotto Gemelli cerca quiete (corsivo)",160,740,740,782,4.5,H),
 ("home_17_cima","Entra nel Dominio di Aura (pulsante)",172,1510,605,1560,4.5,H),
 # ACCOUNT
 ("account_01","IL TUO ACCOUNT (titolo)",135,138,410,170,3.0,S),
 ("account_01","Il tuo cielo non e ancora custodito / Vive solo su questo telefono",85,225,415,290,4.5,S),
 ("account_01","REGISTRA E CONSERVA IL TUO CERCHIO (titolo carta)",155,368,415,450,3.0,S),
 ("account_01","Alla prima registrazione, 250 Eos in dono... (carta)",155,468,430,590,4.5,S),
 ("account_01","PROFILO / Nome, avatar e dati personali",155,660,430,725,4.5,S),
 ("account_01","I TUOI DATI DI NASCITA / Giorno e ora esatta",155,800,420,925,4.5,S),
 ("account_02_giu","DIARIO COSMICO / Il tuo cammino e i tuoi ricordi",155,415,410,515,4.5,S),
 ("account_02_giu","NOTIFICHE / Gli appuntamenti dei doni del giorno",155,582,410,680,4.5,S),
 ("account_02_giu","IMPOSTAZIONI / Preferenze, lingua, qualita grafica",155,748,405,845,4.5,S),
 ("account_02_giu","PRIVACY E DATI / La policy, i tuoi dati, le cancellazioni",155,915,385,1010,4.5,S),
 # NOTIFICHE
 ("notifiche_01_aperta","NOTIFICHE (titolo)",190,140,350,170,3.0,S),
 ("notifiche_01_aperta","I Doni del giorno hanno ciascuno la sua ora... (testo)",35,240,465,335,4.5,S),
 ("notifiche_01_aperta","Il telefono non mi lascia ancora avvisarti... (banner)",120,405,430,505,4.5,S),
 ("notifiche_01_aperta","07:00 (ora)",62,598,145,628,4.5,S),
 ("notifiche_01_aperta","Arcano dell'Alba / Scegli fra i ventidue arcani (carta)",160,592,385,695,4.5,S),
 ("notifiche_05_fondo","DAL CIELO DELL'OROSCOPO (titolo)",38,255,325,330,3.0,S),
 ("notifiche_05_fondo","L'ora d'oro / Prima della tua ora d'oro... (carta)",60,375,380,515,4.5,S),
 ("notifiche_05_fondo","LE CHIAMATE ARRIVANO? (titolo carta)",60,800,390,825,3.0,S),
 ("notifiche_05_fondo","Non l'ho ancora guardata. (testo)",60,845,310,875,4.5,S),
 ("notifiche_05_fondo","GUARDA LA CODA (pulsante)",80,918,295,940,4.5,S),
 ("notifiche_05_fondo","PROVALA ADESSO (pulsante)",80,990,288,1012,4.5,S),
 # IMPOSTAZIONI
 ("impost_01_aperta","IMPOSTAZIONI (titolo)",155,138,385,168,3.0,S),
 ("impost_01_aperta","IL TUO PIANO (etichetta di sezione)",85,220,290,245,4.5,S),
 ("impost_01_aperta","Quanto lontano portare il cammino. (sottotitolo)",37,262,382,288,4.5,S),
 ("impost_01_aperta","PIANO VIANDANTE / Vedi i piani del Cerchio (carta)",118,335,400,430,4.5,S),
 ("impost_01_aperta","ASPETTO (etichetta di sezione)",85,508,215,533,4.5,S),
 ("impost_01_aperta","Come si muove e si mostra il cerchio.",37,550,385,575,4.5,S),
 ("impost_01_aperta","RIDUCI ANIMAZIONI / Meno movimento e parallasse",118,610,385,710,4.5,S),
 ("impost_01_aperta","LINGUA (etichetta di sezione)",85,905,200,932,4.5,S),
 ("impost_01_aperta","In che lingua parla il Cerchio.",37,948,316,975,4.5,S),
 ("impost_03_giu","VOCE E SOTTOTITOLI (etichetta di sezione)",85,262,405,288,4.5,S),
 ("impost_03_giu","La voce dei Maestri arrivera presto.",37,302,363,328,4.5,S),
 ("impost_03_giu","SUONO E VIBRAZIONE (etichetta di sezione)",85,528,413,553,4.5,S),
 ("impost_03_giu","Il comando grande spegne tutto. Sotto, i soli suoni.",37,570,455,630,4.5,S),
 ("impost_03_giu","SUONO / Effetti e musica, con un volume per ognuno",118,928,420,1030,4.5,S),
 ("impost_04_suono","SUONO (titolo)",212,138,327,168,3.0,S),
 ("impost_04_suono","GLI EFFETTI (etichetta di sezione)",85,197,260,222,4.5,S),
 ("impost_04_suono","I suoni che rispondono a un gesto.",37,240,362,262,4.5,S),
 ("impost_04_suono","EFFETTI SONORI / I tredici suoni del Cerchio",118,298,390,398,4.5,S),
 ("impost_04_suono","VOLUME DEGLI EFFETTI 100%",60,462,470,490,4.5,S),
 ("impost_04_suono","LA MUSICA (etichetta di sezione)",85,638,245,663,4.5,S),
 ("impost_04_suono","Il tappeto d'ambiente, sotto tutto il resto.",37,680,428,702,4.5,S),
 ("impost_04_suono","MUSICA D'AMBIENTE / Un anello per luogo",118,740,360,880,4.5,S),
 ("impost_04_suono","La musica parte piu bassa degli effetti di... (nota)",37,1110,413,1135,4.5,S),
 ("impost_07_fondo","ACCOUNT (etichetta di sezione)",85,295,235,320,4.5,S),
 ("impost_07_fondo","IL TUO ACCOUNT / Profilo, accesso e dati di nascita",118,410,415,470,4.5,S),
 ("impost_07_fondo","MESSA A PUNTO (etichetta di sezione)",85,543,323,568,4.5,S),
 ("impost_07_fondo","Cosa sta facendo il movimento del cielo, adesso.",37,585,487,610,4.5,S),
 ("impost_07_fondo","SENSORE VIVO / Mano: 0,0 e 0,0 gradi... (riquadro)",60,672,445,1000,4.5,S),
 ("impost_10_lingua_menu","Italiano (menu a tendina)",373,305,445,330,4.5,S),
 ("impost_10_lingua_menu","English (menu a tendina)",373,378,441,402,4.5,S),
 # PRIVACY
 ("privacy_01","PRIVACY E DATI (titolo)",135,138,405,168,3.0,S),
 ("privacy_01","PRIVACY POLICY / Cosa sappiamo di te",155,248,400,340,4.5,S),
 ("privacy_01","SCARICA I TUOI DATI / Tutto cio che il Cerchio sa di te",155,645,430,770,4.5,S),
 ("privacy_01","CANCELLA I TUOI DATI / Il cammino riparte da zero",155,842,410,965,4.5,S),
 ("privacy_02_permessi","PRIVACY E PERMESSI (titolo)",110,138,430,168,3.0,S),
 ("privacy_02_permessi","COSA DICIAMO DI NOI (etichetta)",85,197,420,222,4.5,S),
 ("privacy_02_permessi","Una volta sola, non su ogni carta.",37,238,350,262,4.5,S),
 ("privacy_02_permessi","Cornice di intrattenimento e crescita personale... (disclaimer)",110,320,460,535,4.5,S),
 ("privacy_02_permessi","LEGGI IL DISCLAIMER PER ESTESO (link)",112,550,408,600,4.5,S),
 ("privacy_02_permessi","COSA CONTIAMO (etichetta)",85,685,330,710,4.5,S),
 ("privacy_02_permessi","Contiamo cinque gesti in numeri per giorno... (riquadro)",60,805,480,1045,4.5,S),
 ("privacy_03_permessi_giu","DA DOVE VENGONO I NUMERI (etichetta)",85,230,400,285,4.5,S),
 ("privacy_03_permessi_giu","GeoNames. Creative Commons... (riquadro)",60,375,480,540,4.5,S),
  ("privacy_05b_cancella_dati_ferma","RICOMINCIARE DA ZERO? (titolo del dialogo)",195,785,740,905,3.0,1.0),
 ("privacy_05b_cancella_dati_ferma","Spariscono il tuo cammino... (testo del dialogo)",195,955,880,1350,4.5,1.0),
 ("privacy_05b_cancella_dati_ferma","LASCIA TUTTO (pulsante)",500,1465,860,1520,4.5,1.0),
 ("privacy_05b_cancella_dati_ferma","RICOMINCIA (pulsante)",545,1610,860,1660,4.5,1.0),
 # PROFILO
 ("profilo_01","PROFILO (titolo)",200,138,340,168,3.0,S),
 ("profilo_01","PROVA (nome)",215,440,325,470,3.0,S),
 ("profilo_01","Metti il tuo volto nel Cerchio... (testo)",45,490,495,555,4.5,S),
 ("profilo_01","Il tuo nome nel Cerchio (riga)",118,630,350,660,4.5,S),
 ("profilo_01","Scatta o scegli una foto (riga)",118,735,340,765,4.5,S),
 ("profilo_02_nome_cerchio","PROVAFZE (nome)",158,385,380,425,3.0,S),
 ("profilo_02_nome_cerchio","IL TUO SIGILLO: 314S",110,433,430,458,4.5,S),
 ("profilo_02_nome_cerchio","Il nome puo essere di piu persone... (testo)",40,468,500,530,4.5,S),
 ("profilo_02_nome_cerchio","IL NOME (etichetta)",25,572,132,595,4.5,S),
 ("profilo_02_nome_cerchio","Il primo cambio e libero, poi uno ogni trenta giorni.",25,695,500,760,4.5,S),
 ("profilo_02_nome_cerchio","CAMBIA IL NOME (pulsante)",293,785,497,808,4.5,S),
 ("profilo_02_nome_cerchio","CHI TI VEDE (etichetta)",25,873,178,897,4.5,S),
 ("profilo_03_giu","Non compari da nessuna parte... (testo)",132,195,475,295,4.5,S),
 ("profilo_03_giu","CHI PUO INVITARTI (etichetta)",25,348,272,370,4.5,S),
 ("profilo_03_giu","SOLO CHI HA IL TUO SIGILLO / Oggi ti puo invitare chiunque",25,400,470,510,4.5,S),
 ("profilo_03_giu","IL TUO RITRATTO / Le venti caratteristiche...",25,563,490,670,4.5,S),
 ("profilo_03_giu","APRI IL TUO RITRATTO (pulsante)",43,698,317,722,4.5,S),
 ("profilo_03_giu","IL TUO LINK D'INVITO / Vale trenta giorni...",25,787,490,893,4.5,S),
 ("profilo_03_giu","RINNOVA (pulsante)",45,922,153,945,4.5,S),
 ("profilo_03_giu","REVOCA (pulsante)",192,922,288,945,4.5,S),
 ("profilo_03_giu","LE PERSONE BLOCCATE (etichetta)",25,1010,295,1033,4.5,S),
 ("profilo_03_giu","Nessuna.",25,1058,92,1082,4.5,S),
 # CERCHIO
 ("cerchio_01_aperto","IL TUO CERCHIO (titolo)",140,138,400,168,3.0,S),
 ("cerchio_01_aperto","0 amici su 3 posti del tuo piano",122,383,418,408,4.5,S),
 ("cerchio_01_aperto","CHIAMA NEL TUO CERCHIO (pulsante oro)",120,460,450,482,4.5,S),
 ("cerchio_01_aperto","GLI ENIGMI DEL CERCHIO (pulsante)",128,548,440,573,4.5,S),
 ("cerchio_01_aperto","I TUOI AMICI (etichetta)",25,637,190,660,4.5,S),
 ("cerchio_01_aperto","Il tuo Cerchio e ancora vuoto... (testo)",25,683,505,775,4.5,S),
 ("cerchio_02_chiama","CHIAMA NEL CERCHIO (titolo)",110,138,465,168,3.0,S),
 ("cerchio_02_chiama","CHIAMA CHI CONOSCI (titolo carta)",115,257,440,282,3.0,S),
 ("cerchio_02_chiama","APRI LA RUBRICA (pulsante oro)",167,337,375,357,4.5,S),
 ("cerchio_02_chiama","MANDA IL TUO INVITO (titolo carta)",115,470,445,495,3.0,S),
 ("cerchio_02_chiama","MANDA IL LINK (pulsante oro)",177,550,363,570,4.5,S),
 ("cerchio_02_chiama","SIETE VICINI (titolo carta)",115,683,300,708,3.0,S),
 ("cerchio_02_chiama","MOSTRA IL MIO CODICE (pulsante)",127,762,415,783,4.5,S),
 ("cerchio_02_chiama","INQUADRA IL SUO CODICE (pulsante)",112,852,428,873,4.5,S),
 ("cerchio_02_chiama","HAI IL SUO SIGILLO? (titolo carta)",115,987,410,1012,3.0,S),
 ("cerchio_02_chiama","Quattro caratteri dal suo profilo.",50,1040,360,1065,4.5,S),
 ("cerchio_05_codice_dopo10s","FYSXMW (codice)",148,820,395,860,3.0,S),
 ("cerchio_05_codice_dopo10s","Vale ancora 4:40.",190,888,350,910,4.5,S),
 # ENIGMI
 ("enigmi_02_dopo","GLI ENIGMI DEL CERCHIO (titolo)",110,138,515,168,3.0,S),
 ("enigmi_02_dopo","IL TUO RITRATTO (etichetta)",25,237,245,260,4.5,S),
 ("enigmi_02_dopo","Per entrare negli Enigmi serve il tuo Ritratto... (testo)",25,283,515,372,4.5,S),
 ("enigmi_02_dopo","COMPILA IL RITRATTO (pulsante oro)",110,417,420,440,4.5,S),
 ("enigmi_02_dopo","CHI DEL CERCHIO (etichetta)",25,505,253,527,4.5,S),
 ("enigmi_02_dopo","Ti restano 3 enigmi oggi.",25,550,260,575,4.5,S),
 ("enigmi_02_dopo","APRI CHI DEL CERCHIO (pulsante spento)",145,620,425,642,4.5,S),
 ("enigmi_02_dopo","LA PROVA DELLA SETTIMANA (etichetta)",25,708,388,730,4.5,S),
 ("enigmi_02_dopo","LE PAROLE CHE NON ARRIVANO (titolo gioco)",25,748,435,772,3.0,S),
 ("enigmi_02_dopo","Finisce fra 4 giorni e 13 ore.",25,782,285,805,4.5,S),
 ("enigmi_02_dopo","FAI LA PROVA (pulsante spento)",205,850,365,872,4.5,S),
 ("enigmi_02_dopo","IL PELLEGRINAGGIO (etichetta)",25,937,280,960,4.5,S),
 ("enigmi_02_dopo","Verso la luna piena del 26 ottobre: 1 passi di 15.",25,985,475,1042,4.5,S),
 ("enigmi_02_dopo","Tu: un passo",25,1100,147,1122,4.5,S),
 ("enigmi_04_ritratto_dopo","IL TUO RITRATTO (titolo)",132,138,408,168,3.0,S),
 ("enigmi_04_ritratto_dopo","Venti caratteristiche che dicono come sei fatto... (testo)",25,203,510,292,4.5,S),
 ("enigmi_04_ritratto_dopo","Otto le abbiamo segnate dalla tua carta natale... (oro)",25,313,510,375,4.5,S),
 ("enigmi_04_ritratto_dopo","LE TUE SCELTE (etichetta)",25,420,210,442,4.5,S),
 ("enigmi_04_ritratto_dopo","Mi spaventa l'idea di legarmi troppo. (scelta)",75,475,420,500,4.5,S),
 ("enigmi_04_ritratto_dopo","Dalla tua carta (nota oro)",75,510,212,532,4.5,S),
 ("enigmi_04_ritratto_dopo","Ne hai scelte 8 di 20: ne mancano 12.",95,998,445,1022,4.5,S),
 ("enigmi_04_ritratto_dopo","CHIUDI IL RITRATTO (pulsante grigio)",145,1062,395,1085,4.5,S),
 ("enigmi_12_prova","LA PROVA DELLA SETTIMANA (titolo barra)",183,235,860,278,3.0,H),
 ("enigmi_12_prova","LE PAROLE CHE NON ARRIVANO (titolo)",42,335,780,480,3.0,H),
 ("enigmi_12_prova","Finisce fra 4 giorni e 13 ore.",42,505,478,545,4.5,H),
 ("enigmi_12_prova","DOMANDA 1 DI 10",42,618,408,655,4.5,H),
 ("enigmi_12_prova","UNA COSA TI HA DATO FASTIDIO... (domanda)",42,685,860,775,4.5,H),
 ("enigmi_12_prova","Lascio perdere, passera (risposta)",125,810,490,855,4.5,H),
 ("enigmi_12_prova","Lo dico subito, anche se il momento e pessimo (risposta)",125,1110,860,1155,4.5,H),
 # PIANI
 ("piani_01_aperta","I PIANI DEL CERCHIO (titolo)",110,138,445,168,3.0,S),
 ("piani_01_aperta","Scegli quanto lontano portare il tuo cammino... (testo)",37,225,475,290,4.5,S),
 ("piani_01_aperta","DEMO (titolo carta)",125,365,230,400,3.0,S),
 ("piani_01_aperta","Tutte le funzioni attive, per la presentazione.",73,410,355,475,4.5,S),
 ("piani_01_aperta","VIANDANTE (titolo carta)",73,575,280,610,3.0,S),
 ("piani_01_aperta","PIANO ATTUALE (badge)",92,637,285,660,4.5,S),
 ("piani_01_aperta","Esplora la soglia. (oro)",73,682,230,705,4.5,S),
 ("piani_01_aperta","Accesso al Cerchio con i tre Maestri (voce)",115,738,450,765,4.5,S),
 ("piani_01_aperta","Nella demo i piani sono visibili... (piede)",40,1050,500,1115,4.5,S),
 ("piani_03_viandante_fine","Con piccolo banner inferiore e video reward (voce)",115,445,460,500,4.5,S),
 ("piani_03_viandante_fine","Accesso base, con un piccolo banner in basso.",72,535,435,595,4.5,S),
 ("piani_03_viandante_fine","L'INIZIATO (titolo carta)",73,698,255,732,3.0,S),
 ("piani_03_viandante_fine","CONSIGLIATO (badge)",93,760,258,782,4.5,S),
 ("piani_03_viandante_fine","I Maestri ti conoscono e ti ricordano. (oro)",72,802,422,830,4.5,S),
 ("piani_04_iniziato_fine","SETTIMANA 2,99 EUR (casella prezzo)",83,283,180,335,4.5,S),
 ("piani_04_iniziato_fine","ANNO 99,99 EUR 8,33 al mese sconto 17% (casella)",360,285,460,475,4.5,S),
 ("piani_04_iniziato_fine","SCEGLI L'INIZIATO, 99,99 EUR ALL'ANNO (pulsante)",107,538,435,590,4.5,S),
 ("piani_04_iniziato_fine","L'ADEPTO (titolo carta)",73,710,235,740,3.0,S),
 ("piani_04_iniziato_fine","I Maestri ti parlano, anche con la voce. (oro)",73,757,435,782,4.5,S),
 ("piani_10_illuminato_mese","Albero della Vita dinamico, esclusivo (voce)",115,318,463,342,4.5,S),
 ("piani_10_illuminato_mese","SETTIMANA 6,99 EUR (casella prezzo)",72,672,192,725,4.5,S),
 ("piani_10_illuminato_mese","ANNO 279,99 EUR 23,33 al mese sconto 22% (casella)",350,672,465,860,4.5,S),
 ("piani_10_illuminato_mese","SCEGLI L'ILLUMINATO, 29,99 EUR AL MESE (pulsante)",125,925,415,978,4.5,S),
 ("piani_09_matrice_destra","Correlazione mood-transiti (riga matrice)",55,255,190,312,4.5,S),
 ("piani_09_matrice_destra","Con la lettura del mese e il report (cella)",350,355,485,440,4.5,S),
 ("piani_09_matrice_destra","Eos in dono alla sottoscrizione (riga)",55,735,210,790,4.5,S),
 # BORSELLINO
 ("borsellino_01","115 EOS (titolo)",100,255,265,300,3.0,S),
 ("borsellino_01","Il tuo saldo nel Cerchio. (testo)",38,325,268,350,4.5,S),
 ("borsellino_01","LA PROSSIMA RICARICA (etichetta)",38,392,312,418,4.5,S),
 ("borsellino_01","Il tuo piano non porta Eos ogni mese... (testo)",38,440,478,505,4.5,S),
 ("borsellino_01","SE GLI EOS NON BASTANO (etichetta)",38,545,340,568,4.5,S),
 ("borsellino_01","I pacchetti di Eos arrivano con la pubblicazione... (testo)",38,592,505,725,4.5,S),
 ("borsellino_01","Manciata di Eos, 300 Eos / 2,99 EUR (riga)",78,752,505,780,4.5,S),
 ("borsellino_01","COSA PUOI FARE OGGI (etichetta)",38,1018,298,1045,4.5,S),
 ("borsellino_02_giu","Non ti resta nessuna domanda ai Maestri, oggi. (testo)",38,482,480,545,4.5,S),
 ("borsellino_02_giu","GLI ULTIMI EOS (etichetta)",38,1038,220,1062,4.5,S),
 ("borsellino_03_fondo","+10 Il tuo volto letto (riga)",38,422,290,448,4.5,S),
 ("borsellino_03_fondo","Con un piano i tetti si allargano... (testo)",38,792,490,885,4.5,S),
 ("borsellino_03_fondo","GUARDA I PIANI (pulsante)",253,928,448,952,4.5,S),
 ("borsellino_03_fondo","Chiudi (pulsante testo)",233,1038,310,1062,4.5,S),
 # CHAT (prova D1)
 ("chat_03_menu","Nuova chat (menu)",175,168,305,190,4.5,S),
 ("chat_03_menu","Il mio archetipo... Oggi (menu)",180,250,450,275,4.5,S),
 ("chat_03_menu","Chat precedenti (menu)",175,333,355,355,4.5,S),
 ("chat_03_menu","LIVE con Aura (menu)",175,400,348,422,4.5,S),
 ("chat_03_menu","Anima del Cerchio, quello che provi ha un posto... (benvenuto sul ritratto)",38,480,500,670,4.5,S),
 ("chat_03_menu","PARLAGLI COME PARLERESTI A UNA PERSONA (titolo suggerimento)",110,740,410,815,3.0,S),
 ("chat_03_menu","Non servono parole giuste... (testo suggerimento)",110,835,400,970,4.5,S),
 ("chat_09_riaperta_collassata","Non ti resta nessuna domanda ai Maestri, oggi (riga di stato)",70,207,380,247,4.5,S),
 ("chat_09_riaperta_collassata","LIVE (lucchetto)",415,215,485,240,4.5,S),
 ("chat_09_riaperta_collassata","Il mio archetipo e Il Giullare... (messaggio)",98,297,405,415,4.5,S),
 ("chat_09_riaperta_collassata","Il tuo archetipo del Giullare t... (risposta ripiegata)",110,505,420,530,4.5,S),
 ("chat_09_riaperta_collassata","Scrivi ad Aura (campo)",128,900,300,925,4.5,S),
]
for cap, nome, x0,y0,x1,y1, soglia, K in R:
    p = os.path.join(D, cap+".png")
    if not os.path.exists(p) or x1-x0 < 5 or y1-y0 < 5:
        print(f"{cap}|{nome}|CATTURA MANCANTE")
        continue
    im = np.array(Image.open(p).convert("RGB")).astype(float)
    a = im[int(y0*K):int(y1*K), int(x0*K):int(x1*K)].reshape(-1,3)
    q = (a//16).astype(int)
    key = q[:,0]*256+q[:,1]*16+q[:,2]
    vals, cnt = np.unique(key, return_counts=True)
    m = vals[cnt.argmax()]
    bg = a[key==m].mean(axis=0)
    d = np.sqrt(((a-bg)**2).sum(axis=1))
    n = max(5, int(len(d)*0.03))
    idx = np.argsort(d)[-n:]
    tx = a[idx].mean(axis=0)
    L = lum(a)
    lbg = lum(bg[None,:])[0]; ltx = lum(tx[None,:])[0]
    sel = L[d < 0.5*d.max()]
    if lbg < ltx:
        lw = np.percentile(sel, 98) if len(sel) else lbg
    else:
        lw = np.percentile(sel, 2) if len(sel) else lbg
    r1 = ratio(ltx,lbg); r2 = ratio(ltx,lw)
    esito = "OK" if min(r1,r2) >= soglia else "SOTTO"
    print(f"{cap}|{nome}|modale {r1:.2f}|peggiore {r2:.2f}|soglia {soglia}|{esito}|bg {bg.astype(int).tolist()} tx {tx.astype(int).tolist()}")
