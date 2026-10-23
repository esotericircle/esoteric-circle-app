# Misura del contrasto WCAG sulle catture renderizzate (GA.10), gruppo D.
# Rettangoli dati in coordinate 900x2000 (come si vede la cattura ridotta): si moltiplicano per 1,2 e danno i pixel pieni 1080x2400.
# Per ogni rettangolo: sfondo = colore piu' frequente (modale) e, per scene variabili,
# il punto piu' chiaro dello sfondo (98 percentile della luminanza dei pixel sul lato dello sfondo);
# testo = media dei pixel piu' lontani dallo sfondo modale (top 3 per cento per distanza).
import sys, os
import numpy as np
from PIL import Image
D = os.path.dirname(os.path.abspath(__file__))
K = 1.2
def lin(c):
    c = c/255.0
    return np.where(c <= 0.03928, c/12.92, ((c+0.055)/1.055)**2.4)
def lum(rgb):
    r,g,b = lin(rgb[...,0]), lin(rgb[...,1]), lin(rgb[...,2])
    return 0.2126*r+0.7152*g+0.0722*b
def ratio(l1,l2):
    a,b = max(l1,l2), min(l1,l2)
    return (a+0.05)/(b+0.05)
# (cattura, testo, x0,y0,x1,y1 in coordinate 900x2000, soglia)
R = [
 ("passaporto_01_aperto","COSMIC PASSPORT (titolo sul cielo)",62,415,735,478,3.0),
 ("passaporto_01_aperto","La tua identita cosmica, che si compone nel tempo (oro)",62,520,745,620,4.5),
 ("passaporto_01_aperto","Qui vivono i fatti identitari fissi... (corpo)",60,680,840,840,4.5),
 ("passaporto_01_aperto","PROSSIMI EVENTI COSMICI (titolo carta)",100,955,610,1075,3.0),
 ("passaporto_01_aperto","Saturno retrogrado (carta)",100,1110,405,1150,4.5),
 ("passaporto_01_aperto","oggi (carta)",733,1115,800,1150,4.5),
 ("passaporto_01_aperto","I TUOI TRAGUARDI (titolo)",143,1385,680,1440,3.0),
 ("passaporto_02_giu","Giorno per giorno, cosa hai fatto",240,280,615,380,4.5),
 ("passaporto_02_giu","Ogni gesto che compi accende una stella... (carta Costellazione)",240,535,612,880,4.5),
 ("passaporto_03_cielo_sigillo","La volta della tua prima notte (carta)",210,535,690,640,4.5),
 ("passaporto_03_cielo_sigillo","Il tuo emblema, dal segno... (carta)",275,895,715,1000,4.5),
 ("passaporto_03_cielo_sigillo","NUMERO DELLA VITA (etichetta oro)",273,1143,712,1178,4.5),
 ("passaporto_03_cielo_sigillo","Fondi e ordini: la tua forza... (carta)",270,1340,790,1470,4.5),
 ("passaporto_04","ANIMALE GUIDA (etichetta oro)",273,715,612,750,4.5),
 ("passaporto_04","Il veggente della notte (carta)",270,855,712,905,4.5),
 ("passaporto_04","E tempo di ordine e di fondamenta solide (carta)",270,1225,708,1510,4.5),
 ("passaporto_05","Custode e Cuore. Il terzo arriva con l'ora (carta Angeli)",302,395,700,600,4.5),
 ("passaporto_05","Tocca per fare il Test Archetipo (carta)",210,790,585,950,4.5),
 ("passaporto_05","Per ora il Sole e il suo segno... (carta natale)",210,1275,700,1555,4.5),
 ("natale_01","Per la mappa completa dei pianeti... (riquadro)",103,335,795,615,4.5),
 ("natale_01","AGGIUNGI IL LUOGO DI NASCITA (pulsante oro)",135,685,608,765,4.5),
 ("natale_01","Tocca per rivedere il cielo autentico (carta)",297,1058,695,1150,4.5),
 ("natale_01","IL TUO FUOCO ARDE IN GEMELLI (titolo)",72,1250,830,1460,3.0),
 ("natale_01","Senza l'ora di nascita l'Ascendente... (corpo)",80,1515,822,1705,4.5),
 ("luogo_01","Cerca la tua citta (segnaposto)",62,1445,338,1482,4.5),
 ("luogo_01","Serve alla carta natale... (nota)",62,1565,730,1720,4.5),
 ("eventi_01","Le date che il cielo ha gia deciso",62,385,690,510,4.5),
 ("eventi_01","DAI AL CERCHIO LA TUA NASCITA (pulsante)",163,968,650,1052,4.5),
 ("eventi_01","SATURNO RETROGRADO (titolo carta)",188,1215,520,1310,3.0),
 ("eventi_01","Saturno sembra tornare indietro... (carta)",185,1345,755,1495,4.5),
 ("eventi_01","OGGI (carta)",695,1250,800,1282,4.5),
 ("passaporto_sigillo","IL TUO SIGILLO DEL CERC... (titolo barra)",183,235,830,280,3.0),
 ("passaporto_sigillo","Gemelli . Elemento Aria . Numero 4",165,1262,735,1305,4.5),
 ("passaporto_sigillo","Prova, guarda: il Sole si posa nel tuo segno...",180,1392,745,1490,4.5),
 ("passaporto_sigillo","CONDIVIDI IL SIGILLO . +15... (pulsante)",180,1602,792,1640,4.5),
 ("passaporto_animale","RICONOSCIUTO NEL VIAGGIO DELLO SCIAMANO... (oro sul viola)",122,1362,778,1500,4.5),
 ("passaporto_animale","Il veggente della notte (corsivo)",275,1303,628,1340,4.5),
 ("passaporto_animale","LA SUA NATURA (etichetta oro)",102,1620,345,1650,4.5),
 ("passaporto_animale","Il Gufo e il veggente della notte... (corpo)",100,1690,765,1850,4.5),
 ("passaporto_cielo_nascita","SATURNO (etichetta sul cielo)",518,362,703,395,4.5),
 ("passaporto_cielo_nascita","LA LUNA / Sotto l'orizzonte: sorge alle 15:50",455,1000,880,1160,4.5),
 ("passaporto_cielo_nascita","Per il cielo della tua nascita servono la data e il luogo (riquadro)",70,1625,792,1730,4.5),
 ("passaporto_cielo_nascita","AGGIUNGI I DATI DI NASCITA",213,1768,800,1800,4.5),
 ("passaporto_archetipo_dopo","Il Giullare (carta Archetipo)",250,255,412,295,4.5),
 ("passaporto_archetipo_dopo","SCOPERTO IL 21/10/2026 (oro)",252,315,748,350,4.5),
 ("passaporto_archetipo_dopo","Non l'hai data: l'Ascendente resta fuori",333,1368,780,1470,4.5),
 ("passaporto_archetipo_dopo","AGGIUNGI L'ORA (oro)",335,1492,648,1522,4.5),
 ("archetipo_01_aperto","QUALE DEI DODICI ARCHETIPI TI GUIDA? (titolo)",62,475,830,620,3.0),
 ("archetipo_01_aperto","Dodici domande, una alla volta... (corpo)",60,672,762,835,4.5),
 ("archetipo_01_aperto","LEGA AL CIELO DI OGGI (titolo riquadro)",103,945,490,1030,3.0),
 ("archetipo_01_aperto","I transiti del giorno si accostano... (riquadro)",100,1068,602,1230,4.5),
 ("archetipo_01_aperto","COMINCIA (pulsante verde)",165,1375,380,1415,4.5),
 ("archetipo_03_domanda2","UNA GIORNATA LIBERA DAVANTI A TE (domanda)",62,597,748,795,4.5),
 ("archetipo_03_domanda2","Parto senza meta (risposta)",100,920,365,960,4.5),
 ("archetipo_06_risultato","NON LEGATO AI TRANSITI ASTROLOGICI",73,398,826,430,4.5),
 ("archetipo_06_risultato","INNOCENTE (etichetta del cerchio)",381,977,520,1000,4.5),
 ("archetipo_06_risultato","REALISTA (etichetta del cerchio)",397,1707,505,1730,4.5),
 ("archetipo_06_risultato","IL GIULLARE (titolo)",212,1825,690,1885,3.0),
 ("archetipo_09_fine","Saggio 7% (riga)",205,440,810,480,4.5),
 ("archetipo_09_fine","La tua figura e nel Passaporto, con la data di oggi",60,1175,840,1215,4.5),
 ("archetipo_09_fine","CONDIVIDI . +15 EOS (pulsante)",190,1285,695,1330,4.5),
 ("archetipo_09_fine","SEGNA NEL DIARIO (pulsante)",205,1438,680,1478,4.5),
 ("archetipo_09_fine","PARLANE CON AURA (pulsante verde)",190,1590,692,1630,4.5),
 ("archetipo_13_riaperto","LA LETTURA DI OGGI (etichetta)",102,697,520,730,4.5),
 ("archetipo_13_riaperto","La Gibbosa crescente semina... (corpo)",100,772,797,935,4.5),
 ("archetipo_13_riaperto","Il cielo di oggi non ti cambia... (corpo)",100,990,785,1140,4.5),
 ("archetipo_13_riaperto","Potrai rifare il test fra 90 giorni... (nota)",62,1692,768,1795,4.5),
 ("cuore_01","Quest'arte non e ancora viva (messaggio)",62,1810,498,1850,4.5),
 ("chat_aura_02","Hai chiesto a Caligo... (carta in cima)",103,490,770,645,4.5),
 ("chat_aura_02","Ti restano... domande (riga d'intestazione)",115,347,630,420,4.5),
 ("chat_aura_02","Anima del Cerchio, prenditi un respiro... (benvenuto sul ritratto)",62,780,838,1030,4.5),
 ("chat_aura_02","PARLAGLI COME PARLERESTI A UNA PERSONA (suggerimento)",185,1082,585,1215,4.5),
 ("chat_aura_02","Non servono parole giuste... (suggerimento)",183,1240,665,1460,4.5),
 ("chat_aura_02","Il mio archetipo e il Giullare... (campo)",213,1620,600,1820,4.5),
 ("chat_aura_03_risposta","Il mio archetipo e... (messaggio della persona)",163,740,672,865,4.5),
 ("chat_aura_06_scorso","Risposta di Aura (corpo)",188,805,735,1600,4.5),
 ("chat_aura_06_scorso","Porta una mano sulla pancia... (azione oro)",235,1650,705,1690,4.5),
 ("chat_aura_06_scorso","Ti restano 2 domande... Non ti resta nessun approfondimento",115,345,630,415,4.5),
 ("chat_caligo_02_benvenuto","Anima del Cerchio, la soglia e aperta... (benvenuto)",70,1390,832,1635,4.5),
 ("chat_caligo_02_benvenuto","Ti resta 1 domanda... (riga d'intestazione)",115,347,630,415,4.5),
 ("chat_caligo_04_fine","Risposta di Caligo (corpo bianco su rosso)",188,715,735,1290,4.5),
 ("chat_caligo_05_fine","Chiedi al consulente finanziario... (azione oro)",235,1560,722,1700,4.5),
 ("chat_caligo_05_fine","Vai piu a fondo",243,1460,497,1500,4.5),
 ("chat_caligo_05_fine","Chiedi anche agli altri",343,1550,713,1590,4.5),
 ("chat_caligo_06_piu_a_fondo","Puoi riscattare un approfondimento... (foglio)",63,990,825,1190,4.5),
 ("chat_caligo_06_piu_a_fondo","RISCATTA UN APPROFONDIMENTO . 60 EOS (pulsante)",170,1275,720,1355,4.5),
 ("chat_caligo_06_piu_a_fondo","NON ORA",300,1450,478,1480,4.5),
 ("chat_caligo_06_piu_a_fondo","VEDI I PIANI",570,1450,805,1480,4.5),
 ("chat_caligo_07_altri","Puoi riscattare un confronto... (foglio)",63,965,825,1170,4.5),
 ("chat_caligo_07_altri","RISCATTA UN CONFRONTO DI SINASTRIA . 150 EOS (pulsante)",170,1240,730,1365,4.5),
 ("chat_caligo_01_aperta","LE ARTI DI CALIGO (titolo sul ritratto)",142,562,610,602,3.0),
 ("chat_caligo_01_aperta","Il suo dominio, dalle arti vive... (sul ritratto)",60,632,690,730,4.5),
 ("chat_caligo_01_aperta","CONSULTA CALIGO (etichetta)",62,1205,472,1245,4.5),
 ("chat_medora_01","LE ARTI DI MEDORA (titolo sul ritratto)",143,745,630,780,3.0),
 ("chat_medora_01","Il suo dominio, dalle arti vive... (sul ritratto)",60,812,690,905,4.5),
 ("chat_medora_01","CONSULTA MEDORA (etichetta)",62,1388,492,1425,4.5),
 ("chat_medora_02_aperta","Hai chiesto a Caligo... (carta sul volto)",103,490,770,645,4.5),
 ("chat_medora_02_aperta","Anima del Cerchio, il cielo di oggi ti parla (benvenuto)",77,1390,822,1630,4.5),
 ("chat_medora_05_dopo_suggerimento","Il tuo cielo ha detto le sue cose per oggi (risposta limite)",188,1020,690,1590,4.5),
 ("chat_medora_07_dopo_nuova","Anima del Cerchio, il cielo di oggi ti parla (benvenuto, chat nuova)",77,1390,822,1630,4.5),
 ("live_01","Dal vivo ci guardiamo in viso... (foglio LIVE)",63,985,835,1205,4.5),
 ("live_01","SCOPRI IL PIANO DELL'ADEPTO (pulsante)",160,1308,742,1345,4.5),
 ("live_01","NON ORA",357,1450,545,1482,4.5),
 ("diario_01_da_chat","IL CAMMINO (scheda non scelta)",155,408,410,442,4.5),
 ("diario_01_da_chat","Cerca fra le tue domande (segnaposto)",170,580,582,620,4.5),
 ("diario_01_da_chat","MEDORA (chip)",85,750,258,782,4.5),
 ("diario_01_da_chat","GEN (mese)",126,980,210,1012,4.5),
 ("diario_01_da_chat","0 (conteggio del mese)",153,1048,182,1088,4.5),
 ("diario_03_ottobre","TORNA ALL'ANNO (viola su nero)",245,945,652,985,4.5),
 ("diario_03_ottobre","Con l'Iniziato, ogni mese il tuo Maestro dominante... (corpo)",40,1070,850,1230,4.5),
 ("diario_03_ottobre","DAL 28 AL 4 (riga)",82,1308,368,1350,4.5),
 ("diario_03_ottobre","Niente (riga)",82,1370,190,1405,4.5),
 ("diario_05_giorno","TORNA AL MESE (viola su nero)",260,945,635,985,4.5),
 ("diario_05_giorno","5 momenti, 0 traguardi (riga)",82,1490,445,1527,4.5),
 ("diario_06_quel_giorno","5 momenti, 1 Dono su 4... (riga)",42,1075,850,1205,4.5),
 ("diario_06_quel_giorno","La tua gettata: Le tre Norne",180,1285,640,1325,4.5),
 ("diario_06_quel_giorno","09:24 (ora)",180,1345,272,1385,4.5),
 ("diario_06_quel_giorno","TORNA ALLA SETTIMANA (viola su nero)",170,948,725,985,4.5),
 ("diario_08_riaperto","Ho 8000 euro di risparmi... (domanda)",60,405,798,530,4.5),
 ("diario_08_riaperto","Turno conv.caligo.c1792571121221 (riga tecnica)",60,590,628,640,4.5),
 ("diario_09_guarda_oltre","21/10/2026 (data)",62,400,252,440,4.5),
 ("diario_09_guarda_oltre","I segni del viaggio ti danno una direzione... (corpo)",60,505,840,780,4.5),
 ("cammino_01","COSTELLAZIONE PERSONALE (titolo)",183,550,578,645,3.0),
 ("cammino_01","Ogni gesto che compi accende una stella... (corpo)",180,665,660,885,4.5),
 ("sentiero_01_costellazione","I TRAGUARDI DI MEDORA (titolo foglio)",222,1235,680,1350,3.0),
 ("sentiero_01_costellazione","I TRAGUARDI RAGGIUNTI (etichetta)",183,1395,715,1430,4.5),
 ("sentiero_01_costellazione","1 PERLE ACCESE SU 55 (oro)",110,1450,790,1545,4.5),
 ("sentiero_01_costellazione","IL TUO PROSSIMO TRAGUARDO (etichetta)",123,1595,775,1632,4.5),
 ("sentiero_01_costellazione","L'OROSCOPO (pulsante)",345,1708,600,1745,4.5),
 ("sentiero_02_mappa","Uno stelle accese su cinquantacinque (oro sul cielo)",62,1322,655,1360,4.5),
 ("sentiero_02_mappa","Nessun altro cielo ha questa figura... (corpo)",62,1385,830,1480,4.5),
 ("sentiero_02_mappa","Ogni traguardo porta Eos. Condividerlo ne porta altri.",62,1505,835,1600,4.5),
 ("sentiero_02_mappa","Vai al punto in cui sei (oro)",310,1675,637,1710,4.5),
 ("sentiero_03_elenco","IL TUO RITORNO SOLARE (titolo riga)",193,495,592,585,3.0),
 ("sentiero_03_elenco","55 di 55 (riga)",192,610,318,650,4.5),
 ("sentiero_03_elenco","130 (premio)",745,498,808,538,4.5),
 ("sentiero_03_elenco","TRECENTOQUARANT A STESE (titolo riga)",192,725,685,815,3.0),
 ("sentiero_03_elenco","54 di 55 (riga)",192,842,318,880,4.5),
 ("sentiero_04_dove_sei","Il cielo dell'istante: Eos in attesa",215,1575,408,1615,4.5),
 ("sentiero_04_dove_sei","Hai dato al Cerchio la carta natale... (riga)",192,1650,680,1810,4.5),
 ("sentiero_05_traguardo","STELLA (etichetta)",125,428,282,462,4.5),
 ("sentiero_05_traguardo","IL CIELO DELL'ISTANTE (titolo carta)",125,500,610,645,3.0),
 ("sentiero_05_traguardo","Hai dato al Cerchio la carta natale (carta)",123,695,715,800,4.5),
 ("sentiero_05_traguardo","Obiettivo raggiunto il 20/10/2026 (oro)",123,845,730,945,4.5),
 ("sentiero_05_traguardo","150 Eos quando il tuo amico entra nel Cerchio. In attesa. (sopra altro testo)",80,1288,825,1385,4.5),
 ("sentiero_05_traguardo","30 Eos a condivisione avvenuta (sopra altro testo)",213,1545,708,1580,4.5),
 ("sentiero_05_traguardo","15 Eos a condivisione avvenuta (sopra altro testo)",213,1745,708,1780,4.5),
 ("riapri_01","TOCCA PER ENTRARE (sul bordo del video)",232,1738,670,1775,4.5),
]
out = []
for cap, nome, x0,y0,x1,y1, soglia in R:
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
    if lbg < ltx:
        sel = L[d < 0.5*d.max()]
        lw = np.percentile(sel, 98) if len(sel) else lbg
    else:
        sel = L[d < 0.5*d.max()]
        lw = np.percentile(sel, 2) if len(sel) else lbg
    r1 = ratio(ltx,lbg); r2 = ratio(ltx,lw)
    esito = "OK" if min(r1,r2) >= soglia else "SOTTO"
    print(f"{cap}|{nome}|modale {r1:.2f}|peggiore {r2:.2f}|soglia {soglia}|{esito}|bg {bg.astype(int).tolist()} tx {tx.astype(int).tolist()}")
