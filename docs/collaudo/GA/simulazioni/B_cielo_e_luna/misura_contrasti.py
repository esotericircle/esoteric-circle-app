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
# (cattura, testo, x0,y0,x1,y1 su 900x2000, soglia, nota)
R = [
 # Oroscopo
 ("oro_A2","Gemelli (titolo grande)",312,408,768,504,3.0),
 ("oro_A2","OROSCOPO DEL GIORNO (titolo)",252,1356,828,1416,3.0),
 ("oro_A2","21 ottobre 2026",384,1435,696,1483,4.5),
 ("oro_A2","Oroscopo per",84,1584,348,1637,4.5),
 ("oro_A2","SETTIMANA (linguetta con lucchetto)",324,1764,564,1812,4.5),
 ("oro_B1","Con la tua ora e il tuo luogo (riquadro)",204,1200,840,1380,4.5),
 ("oro_B1","Questa lettura parla al tuo segno (riquadro)",204,1536,948,1920,4.5),
 ("oro_B2_occ_giorno","Il tuo segno vedico e Kumbha",144,816,936,876,4.5),
 ("oro_B2_occ_giorno","Qui vedi il tuo segno vedico...",132,1836,948,2016,4.5),
 ("oro_B3_cinese","Il tuo segno cinese e il Cavallo",252,816,828,869,4.5),
 ("oro_C3","Le ore migliori (testo piccolo)",120,1056,900,1370,4.5),
 ("oro_C3","Ciao Prova (corsivo oro)",144,1440,840,1680,4.5),
 ("oro_C3","Oggi la giornata e propizia (responso)",144,1750,900,2250,4.5),
 ("oro_C4","Giornata propizia in amore (responso)",150,960,960,1830,4.5),
 ("oro_C4","Cosa fare adesso (etichetta oro)",195,1990,645,2070,4.5),
 ("oro_D2_lunga","L'oroscopo completo di oggi (foglio)",75,400,1005,720,4.5),
 ("oro_D2_lunga","Spiegare a qualcuno (anteprima sfumata)",75,820,1005,1060,4.5),
 ("oro_F2_aggiungi","L'oroscopo per gli amici si apre con l'Iniziato",75,1560,1005,1830,3.0),
 ("oro_G2_celtica","Il tuo albero celtico e la Quercia",240,1035,840,1095,4.5),
 ("oro_G2_celtica","I Celti leggevano il cielo negli alberi (riquadro)",204,1620,930,1680,4.5),
 ("oro_G2_celtica","La lettura della tradizione Celtica e in arrivo",84,1896,990,2016,4.5),
 # Cielo reale
 ("cielo_01_partenza","IL CIELO DI ADESSO (titolo)",156,276,780,336,3.0),
 ("cielo_01_partenza","La Luna (etichetta)",396,859,624,900,4.5),
 ("cielo_01_partenza","Sotto l'orizzonte: sorge alle 15:50",283,931,804,1044,4.5),
 ("cielo_01_partenza","Roma 41.9028",84,1279,564,1327,4.5),
 ("cielo_01_partenza","Cielo calcolato su Roma...",84,1555,960,1740,4.5),
 ("cielo_01_partenza","USA LA MIA POSIZIONE",403,1788,960,1836,4.5),
 ("cielo_01_partenza","La Luna adesso non c'e",84,1932,852,1980,4.5),
 ("cielo_07_arrivo","La Luna di quel giorno (card)",82,1002,994,1071,4.5),
 ("cielo_07_arrivo","La Luna / Sotto l'orizzonte (sul cielo)",527,821,1058,942,4.5),
 ("cielo_10_sole","Non guardare il Sole direttamente",313,476,793,583,4.5),
 # Respiro
 ("resp_03_respiro","GIBBOSA CRESCENTE (titolo)",188,514,881,581,3.0),
 ("resp_03_respiro","SCEGLI DOVE GUARDI LA LUNA",75,405,994,465,4.5),
 ("resp_03_respiro","TIENI PREMUTO SULLA LUNA, POI LASCIA",56,1125,1013,1190,4.5),
 ("resp_03_respiro","GIRO 1 DI 8",394,1200,694,1256,4.5),
 ("resp_06_scroll","Rudhyar legge la Luna gibbosa...",181,1190,918,1455,4.5),
 ("resp_06_scroll","TIENI PREMUTO PER INSPIRARE (oro)",200,1633,880,1815,4.5),
 ("resp_08_collana","La perla di oggi e ancora spenta",64,1618,990,1776,4.5),
 ("resp_08_collana","Alla Luna nuova del 9 novembre",64,1826,990,1995,4.5),
 ("resp_08_collana","OTTOBRE (sul medaglione)",348,775,745,843,3.0),
 ("resp_13_avvisi","Gli avvisi della Luna arrivano...",136,1353,722,1480,4.5),
 # Calendario lunare
 ("cal_01","OTTOBRE 2026 (titolo, sull'alone di Medora)",315,637,754,693,3.0),
 ("cal_01","LU MA ME GI VE SA DO (intestazioni)",68,720,990,770,4.5),
 ("cal_01","numeri 5-11 (sui dischi lunari)",68,950,990,995,4.5),
 ("cal_01","numeri 26-31",68,1485,855,1530,4.5),
 ("cal_01","ritorno della tua Luna... (testo)",74,1705,972,1755,4.5),
 ("cal_01","AGGIUNGI L'ORA DI NASCITA",112,1811,805,1856,4.5),
 ("cal_06_giorno","GIBBOSA CRESCENTE IN PESCI (titolo)",128,709,952,860,3.0),
 ("cal_06_giorno","E il giorno lunare 13... (corpo)",76,934,945,1811,4.5),
 ("cal_17","TAGLIO PER RINFORZARLI (pulsante)",130,1739,747,1789,4.5),
 ("cal_17","I giorni d'oro per taglio... (testo)",74,2018,940,2137,4.5),
 # Eventi cosmici
 ("ev_01","Venere sembra tornare indietro... (card)",225,799,945,979,4.5),
 ("ev_01","fra 2 giorni",225,1267,428,1305,4.5),
 ("ev_01","OGGI (data)",833,680,945,716,4.5),
 # Sigillo del Sogno
 ("sogno_07","UNISCI LE STELLE (titolo)",255,1050,825,1110,3.0),
 ("sogno_07","La costellazione di Pesci...",75,1155,1005,1665,4.5),
 ("sogno_07","Muovi il telefono... (oro)",135,1725,900,1950,4.5),
 ("sogno_08","Saturno e retrogrado: tu eri qui",90,1035,990,1155,4.5),
 ("sogno_08","150 Eos quando il tuo amico entra",90,1524,990,1620,4.5),
 ("sogno_09","Stamattina la tua parola era",75,1206,945,1395,4.5),
 ("sogno_09","LASCIA SCIOGLIERE I CONFINI (titolo)",75,1575,1020,2070,3.0),
 ("sogno_09","Oggi Medora ti indica (blu)",75,1056,945,1104,4.5),
 ("sogno_10","Se guardi indietro... (corpo)",75,960,1005,1410,4.5),
 ("sogno_11","Stanotte la Luna torna... (corpo)",75,1050,1005,1395,4.5),
 ("sogno_11","LUNA IN PESCI, GIBBOSA CRESCENTE (oro)",75,1440,855,1494,4.5),
 ("sogno_11","CONDIVIDI +15 EOS (pulsante)",285,1680,840,1734,4.5),
 ("sogno_12_info","Da dove nasce questo dono (testo)",75,450,1005,2070,4.5),
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
