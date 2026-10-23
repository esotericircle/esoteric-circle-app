# Misura del contrasto WCAG sulle catture renderizzate (GA.10).
# Per ogni rettangolo: sfondo = colore piu' frequente (modale) e, per scene variabili,
# il punto piu' chiaro dello sfondo (98 percentile della luminanza dei pixel sul lato dello sfondo);
# testo = media dei pixel piu' lontani dallo sfondo modale (top 3 per cento per distanza).
import sys, os
import numpy as np
from PIL import Image
D = os.path.dirname(os.path.abspath(__file__))
K = 1.0  # coordinate date a risoluzione piena 1080x2400
def lin(c):
    c = c/255.0
    return np.where(c <= 0.03928, c/12.92, ((c+0.055)/1.055)**2.4)
def lum(rgb):
    r,g,b = lin(rgb[...,0]), lin(rgb[...,1]), lin(rgb[...,2])
    return 0.2126*r+0.7152*g+0.0722*b
def ratio(l1,l2):
    a,b = max(l1,l2), min(l1,l2)
    return (a+0.05)/(b+0.05)
# (cattura, testo, x0,y0,x1,y1 in pixel pieni 1080x2400, soglia)
R = [
 # Meditazione
 ("med_01_aperta","PREMI PLAY (sul fiore giallo)",414,914,666,950,4.5),
 ("med_01_aperta","Con le cuffie l'ascolto si fa piu pieno",297,1539,995,1584,4.5),
 ("med_01_aperta","Oggi e acceso il fuoco (Manipura)... (corpo)",99,1656,981,1980,4.5),
 ("med_01_aperta","SCEGLI IL SINTOMO (pulsante)",297,2088,783,2128,4.5),
 ("med_02_giu","Cornice di benessere, non cura (nota in fondo)",135,2034,990,2205,4.5),
 ("med_15_lista2","12 pratiche, tutte pronte (aiuto)",144,1305,936,1386,4.5),
 ("med_17_pronta","Agitazione improvvisa: Dodici respiri, 2 minuti (sotto il fiore)",90,1692,990,1728,4.5),
 ("med_04_lista","FREQUENZA: QUELLA SCELTA, 528 HZ (scheda)",126,1000,882,1098,4.5),
 ("med_04_lista","Dodici respiri, 2 minuti... (scheda)",122,1152,891,1341,4.5),
 ("med_04_lista","Paul Lehrer e Richard Gevirtz... (fonte, oro)",122,1368,936,1710,4.5),
 ("med_18_inizio_2min","INSPIRA 4 sul fiore",450,882,621,981,4.5),
 ("med_07_scroll_in_play","INSPIRA 3 sul fiore (fiore ridotto)",459,513,621,612,4.5),
 ("med_18_inizio_2min","MANCANO 1:57",282,1692,792,1746,4.5),
 ("med_07_scroll_in_play","MANCANO 1:27",279,1323,801,1386,4.5),
 ("med_21_fine_a","IL RESPIRO E COMPIUTO (sul fiore)",360,520,630,610,4.5),
 ("med_21_fine_a","La meditazione e portata a compimento (corpo)",144,1881,918,2124,4.5),
 ("med_20_fine_giu","TRATTIENI 2 (sul fiore)",423,513,657,621,4.5),
 # Aura (hub)
 ("aura_02","SCOPRI ALTRE ARTI DEL CERCHIO (sul ritratto)",171,990,882,1098,3.0),
 ("aura_02","Le arti degli altri Maestri, oltre il tuo dominio",72,1130,945,1179,4.5),
 ("aura_01","ENERGIA (titolo di riga sul ritratto)",77,1305,351,1354,3.0),
 ("aura_01","CONSULTA AURA (sul ritratto)",76,1090,567,1150,3.0),
 ("aura_03_arti_di_aura","Il suo dominio, dalle arti vive a quelle in cammino",72,1764,828,1881,4.5),
 ("aura_04_fisiognomica_sul_ritratto","FISIOGNOMICA (titolo di riga sul ritratto)",77,949,558,1008,3.0),
 ("aura_04_fisiognomica_sul_ritratto","MAPPA DEL VISO (etichetta)",68,1791,513,1840,4.5),
 # Mappa del Viso
 ("viso_01_aperta","I TRATTI DEL TUO VOLTO, UNA COSTELLAZIONE (titolo)",72,1395,837,1674,3.0),
 ("viso_01_aperta","La fotocamera legge la geometria... (corpo)",72,1737,990,1998,4.5),
 ("viso_02_giu","Prima di cominciare togli cappello e occhiali (riquadro)",216,837,927,1449,4.5),
 ("viso_04_negato","CENTRA IL VISO NELL'OVALE (titolo)",153,509,927,720,3.0),
 ("viso_04_negato","CATTURA LA COSTELLAZIONE (pulsante spento)",207,1908,927,1953,4.5),
 ("viso_04_negato","PREFERISCI SCEGLIERE A MANO? TOCCA QUI",108,2057,891,2160,4.5),
 ("viso_06_a_mano","Guarda il tuo viso allo specchio... (corpo)",72,612,1008,801,4.5),
 ("viso_09_risultato","CONGRATULAZIONI (titolo)",72,621,999,702,3.0),
 ("viso_09_risultato","Obiettivo raggiunto il 21 ottobre",130,855,950,900,4.5),
 ("viso_10_lettura","NON LEGATO AI TRANSITI ASTROLOGICI",90,472,990,518,4.5),
 ("viso_10_lettura","IL CUORE APERTO ALLE EMOZIONI (titolo)",153,1530,927,1710,3.0),
 ("viso_12_altro","ELEMENTO ACQUA (riquadro)",122,531,900,1152,4.5),
 ("viso_13_piu_giu","Il cielo di oggi si accosta alla tua lettura",72,1062,670,1179,4.5),
 # Rune
 ("rune_01_aperta","Sono Caligo, custode delle soglie... (intro)",81,513,999,711,4.5),
 ("rune_01_aperta","RUNA DI ODINO / UNA RUNA (chip)",108,1197,540,1305,4.5),
 ("rune_02_norne_domanda","Puoi anche gettare senza domanda...",72,1044,954,1170,4.5),
 ("rune_02_norne_domanda","Oggi hai 1 gettata di rune",333,1431,810,1476,4.5),
 ("rune_02_norne_domanda","SCUOTI IL TELEFONO, OPPURE TOCCA...",130,1886,972,1994,4.5),
 ("rune_06_gesto","Non ti resta nessuna gettata di rune, oggi",180,2174,963,2223,4.5),
 ("rune_07_risposta","UN NUOVO GIORNO: CAMBIA STATO CON LUI (titolo)",122,1395,963,1512,3.0),
 ("rune_07_risposta","Le rune non danno consigli su risparmi... (corpo)",122,1560,954,2232,4.5),
 ("rune_09_azione","COSA FARE ADESSO (etichetta oro)",175,1170,612,1230,4.5),
 ("rune_09_azione","Pensa all'ultima volta che hai difeso un amico (corpo)",171,1278,900,1998,4.5),
 ("rune_08_testo","La risposta lunga: Caligo approfondisce... (riquadro bloccato)",229,1404,954,1593,4.5),
 ("rune_08_testo","Il filo parte dal pozzo di cio che fu (corsivo)",122,1764,783,1809,4.5),
 ("rune_15_lunga_bloccata","LA RISPOSTA LUNGA DELLE RUNE E DELL'INIZIATO (foglio)",179,1512,637,1706,3.0),
 ("rune_13_getta_ancora","LE GETTATE DI OGGI SONO FINITE (foglio)",179,1335,825,1469,3.0),
 ("rune_13_getta_ancora","La gettata del giorno e stata fatta... (foglio)",76,1523,896,1771,4.5),
 ("rune_13_getta_ancora","NON ORA",361,2074,572,2117,4.5),
 # Viaggio
 ("viaggio_01_aperto","IL GUFO",421,1238,659,1296,3.0),
 ("viaggio_01_aperto","Il Gufo resta con te... (corpo)",76,1519,896,1814,4.5),
 ("viaggio_gufo_prima","IL VIAGGIO DELLO SCIAMANO (titolo sul video)",248,233,572,410,3.0),
 ("viaggio_gufo_prima","TORNA (sul prato)",455,2097,626,2142,4.5),
 ("viaggio_gufo_dopo","Il Gufo si volta. Non hai ancora compreso... (sul prato)",86,1750,994,2000,4.5),
 ("viaggio_04_domanda_segno","CHIEDI UN SEGNO AL GUFO (titolo sul video)",140,1411,940,1465,3.0),
 ("viaggio_04_domanda_segno","Il Gufo non parla: risponde con un gesto.",146,1506,925,1560,4.5),
 ("viaggio_10_discesa_tieni_premuto","TIENI PREMUTO PER SCENDERE (sulle radici)",175,2024,907,2063,4.5),
 ("viaggio_10_discesa_tieni_premuto","SALTA LA DISCESA (sulle radici)",330,2116,750,2150,4.5),
 ("viaggio_11_dopo_pressione","PASSA LA MANO (sul grigio)",356,2121,724,2160,4.5),
 ("viaggio_12_nebbia_tolta","Viene in piena luce.",309,2128,769,2182,4.5),
 ("viaggio_13_dopo_tocco","I segni del viaggio ti danno una direzione... (corpo)",76,1976,1004,2225,4.5),
 # Sigillo
 ("sigillo_01_aperto","Un sigillo e un'intenzione trasformata... (intro)",99,477,981,675,4.5),
 ("sigillo_01_aperto","SCEGLI LA VIA",347,783,729,828,3.0),
 ("sigillo_01_aperto","Prima di scrivere: la via dice che cosa vuoi muovere",144,873,936,990,4.5),
 ("sigillo_01_aperto","VIA ROSSA / il cuore e il desiderio",207,1089,603,1215,4.5),
 ("sigillo_01_aperto","Scrivi la tua intenzione (pulsante spento)",261,1953,819,2002,4.5),
 ("sigillo_01_aperto","Il metodo viene da Austin Osman Spare... (fonte)",99,2169,981,2268,4.5),
 ("sigillo_04_scrivi","Scrivo qui cosa voglio, al presente... (segnaposto)",122,1026,814,1071,4.5),
 ("sigillo_04_scrivi","Chiedo chiarezza sulla mia strada (chip)",126,1426,747,1472,4.5),
 ("sigillo_05_salute","Su salute, figli, denaro e cause legali...",90,1755,986,1872,4.5),
 ("sigillo_09_giu","Caligo non ha trovato una forma migliore...",115,1220,961,1330,4.5),
 ("sigillo_07_normale","Il giorno: 21 novembre 2026",76,1875,616,1923,4.5),
 ("sigillo_10_altra_data","IL GIORNO IN CUI CALIGO TI CHIE... (titolo del selettore, troncato)",123,449,983,492,4.5),
 ("sigillo_10_altra_data","ANNULLA / OK (selettore di sistema)",529,1998,907,2041,4.5),
 ("sigillo_13_giu","La data: 21 novembre 2026 (verde)",276,1329,799,1372,4.5),
 ("sigillo_13_giu","Adesso lascialo lavorare... (corpo)",89,1091,989,1285,4.5),
 ("libro_01","Qui stanno i tuoi sigilli... (intro)",97,454,983,572,4.5),
 ("libro_01","Voglio trovare il coraggio... (scheda)",385,832,950,1188,4.5),
 ("libro_02_tocco","Ripassa il segno col dito... (sulle stelle)",86,1274,998,1400,4.5),
 ("libro_03_fondo","PRIMA DELLA DATA",76,1361,579,1404,4.5),
 ("libro_03_fondo","Porta alla data (Demo)",281,2078,795,2128,4.5),
 ("libro_04_cambia_data","Il segno riparte spento... (foglio)",76,1436,1004,1480,4.5),
 # Soffio
 ("soffio_01_chiuso","SI APRE ALLE 13:00",205,1112,875,1328,3.0),
 ("soffio_01_chiuso","Il tuo destino del momento, con la tensione sciolta...",130,1404,950,1555,4.5),
 ("soffio_05_attesa","IL PERMESSO RESTA CHIUSO (etichetta)",126,960,720,996,4.5),
 ("soffio_05_attesa","Il sistema non mostrera piu la richiesta... (corpo)",124,1038,954,1290,4.5),
 ("soffio_05_attesa","APRI LE IMPOSTAZIONI",174,1380,694,1418,4.5),
 ("soffio_07_dopo_spazzata_lenta","PREPARATI A RESPIRARE (pillola)",220,1050,858,1212,3.0),
 ("soffio_07_dopo_spazzata_lenta","Oggi Aura ti accompagna nel respiro (verde)",210,1536,918,1578,4.5),
 ("soffio_09_respiro","Primo giorno (verde sul grigio)",258,1462,576,1514,4.5),
 ("soffio_10_fine_respiro","DA DOVE NASCE (verde)",318,1266,686,1304,4.5),
 ("soffio_12_da_dove","Perche questo rito... (corpo)",198,1500,870,2090,4.5),
 # Tramonto
 ("tramonto_02_aperto","Ora stimata delle 17:05, la posizione non e attiva",42,1728,1038,1878,4.5),
 ("tramonto_02_aperto","Attiva la posizione",322,1956,758,2010,4.5),
 ("tramonto_02_aperto","Scuoti il telefono, oppure tocca.",190,2112,888,2160,4.5),
 ("tramonto_02_aperto","GETTA LA RUNA",270,1200,814,1254,3.0),
 ("tramonto_02_aperto","LA RUNA DEL TRAMONTO (titolo sul cielo)",342,240,762,372,3.0),
 ("tramonto_04_runa","Tieni premuto sulla pietra e scopri il simbolo",252,2028,828,2154,4.5),
 ("tramonto_06_dopo","Oggi Caligo ha tracciato il tuo presagio",78,552,894,600,4.5),
 ("tramonto_06_dopo","ALGIZ . PROTEZIONE",252,1212,828,1258,4.5),
 ("tramonto_06_dopo","RIALZA LA GUARDIA E RIASCOLTA CIO CHE SENTI (titolo)",214,1296,866,1680,3.0),
 ("tramonto_06_dopo","VERSO D'OMBRA",366,1732,716,1766,4.5),
 ("tramonto_06_dopo","COSA LASCI FUORI / Lascia sulla soglia...",126,1962,870,2256,4.5),
 ("tramonto_08_fondo","LA PRIMA DI SETTE SERE DI FILA... (didascalia)",86,1290,994,1398,4.5),
 ("tramonto_09_da_dove","Algiz in merkstave... Old English Rune Poem (fonte)",74,684,991,1512,4.5),
]
out = []
for cap, nome, x0,y0,x1,y1, soglia in R:
    p = os.path.join(D, cap+".png")
    if not os.path.exists(p) or x1-x0 < 5 or y1-y0 < 5: continue
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
    # sfondo piu' chiaro sul lato dello sfondo
    if lbg < ltx:   # testo chiaro su fondo scuro: peggior caso = punto piu' chiaro dello sfondo (non testo)
        sel = L[d < 0.5*d.max()]
        lw = np.percentile(sel, 98) if len(sel) else lbg
    else:
        sel = L[d < 0.5*d.max()]
        lw = np.percentile(sel, 2) if len(sel) else lbg
    r1 = ratio(ltx,lbg); r2 = ratio(ltx,lw)
    esito = "OK" if min(r1,r2) >= soglia else "SOTTO"
    print(f"{cap}|{nome}|modale {r1:.2f}|peggiore {r2:.2f}|soglia {soglia}|{esito}|bg {bg.astype(int).tolist()} tx {tx.astype(int).tolist()}")
