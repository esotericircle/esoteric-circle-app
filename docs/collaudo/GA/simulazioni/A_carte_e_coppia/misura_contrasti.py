# Misura del contrasto WCAG sulle catture renderizzate (GA.10).
# Per ogni rettangolo: sfondo = colore piu' frequente (modale) e, per scene variabili,
# il punto piu' chiaro dello sfondo (98 percentile della luminanza dei pixel sul lato dello sfondo);
# testo = media dei pixel piu' lontani dallo sfondo modale (top 3 per cento per distanza).
import sys, os
import numpy as np
from PIL import Image
D = os.path.dirname(os.path.abspath(__file__))
K = 1.2  # coordinate date sullo schermo ridotto 900x2000
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
 ("alba_08_giu","La parola di oggi",120,385,500,435,4.5),
 ("alba_08_giu","LENTEZZA (titolo grande)",100,452,600,552,3.0),
 ("alba_08_giu","Tienila a mente",100,570,810,730,4.5),
 ("alba_08_giu","Il gesto di oggi (titolo)",140,805,500,855,4.5),
 ("alba_08_giu","Lava i piatti...",140,870,770,1110,4.5),
 ("alba_08_giu","Rallentare in una faccenda...",140,1200,770,1440,4.5),
 ("stesa_19_dopo","Qui serve un consulente (titolo)",120,1415,780,1615,3.0),
 ("stesa_19_dopo","Domanda citata",60,1655,840,1765,4.5),
 ("stesa_19_dopo","Etichetta PASSATO/PRESENTE/FUTURO",40,1300,860,1345,4.5),
 ("r1","Passato Due di Bastoni, frase",55,410,700,540,4.5),
 ("r1","Consiglio di Medora, testo",100,990,800,1600,4.5),
 ("r2","Cosa fare adesso, testo",140,180,760,860,4.5),
 ("r3","Cosa fare adesso, testo",140,880,760,1560,4.5),
 ("stesa_02_aperta_ferma","Oggi hai 1 stesa",300,1690,610,1740,4.5),
 ("stesa_02_aperta_ferma","Scegli tre carte dal ventaglio",110,1625,790,1665,4.5),
 ("oracolo_15_nuova","Scrivi la tua domanda agli angeli (segnaposto)",70,415,610,460,4.5),
 ("oracolo_15_nuova","chip AMORE",110,520,310,575,3.0),
 ("oracolo_15_nuova","L'angelo di quest'ora",80,1685,580,1730,4.5),
 ("oracolo_15_nuova","dalle 07:40 alle 08:00",80,1805,430,1855,4.5),
 ("s1","Alla tua domanda le carte rispondono",40,1250,860,1850,4.5),
 ("s2","Rifai la domanda... (cosa fare)",80,330,830,770,4.5),
 ("s2","Oggi ti risponde... (corsivo)",40,860,850,1090,4.5),
 ("s3","Il suo messaggio per te",80,550,820,1070,4.5),
 ("oracolo_14_condividi","(vedi sotto)",0,0,1,1,4.5),
 ("passaporto_03","Gibbosa calante in Pesci",270,690,780,800,3.0),
 ("passaporto_03","Senti con empatia e sogno",270,830,800,1050,4.5),
 ("passaporto_03","FASE LUNARE DI NASCITA (etichetta)",270,580,620,670,4.5),
 ("angelo_01_aperto","Il suo coro veglia...",95,975,780,1075,4.5),
 ("angelo_01_aperto","La tradizione ne assegna tre",70,380,830,500,4.5),
 ("angelo_01_aperto","Salmo 8,2",95,1565,790,1870,4.5),
 ("vip_03","La tua compatibilita' con un VIP (titolo)",110,470,790,590,3.0),
 ("vip_03","Oggi hai 3 sinastrie",110,645,420,695,4.5),
 ("vip_03","Aggiungi la tua foto",90,1190,370,1360,4.5),
 ("vip_03","SCEGLI IL VIP (etichetta)",520,1195,820,1245,4.5),
 ("vip_09_b","Vi guardate come si guarda...",120,1300,780,1500,3.0),
 ("v1","Testo interpretazione",100,340,820,800,4.5),
 ("v2","Manda questa a chi giura",100,1110,800,1210,4.5),
 ("v2","Pulsante SOLE OPPOSIZIONE VENERE",60,620,840,740,4.5),
 ("evo_02","Con chi leggo il tuo cielo? (titolo)",70,1505,830,1555,3.0),
 ("evo_02","Scrivi la sua nascita...",90,1575,810,1690,4.5),
 ("evo_10","Le vostre ore di nascita... (corsivo)",40,725,860,885,4.5),
 ("evo_10","Oggi fra voi, testo",240,1335,800,1700,4.5),
 ("e1","L'attrazione, testo",40,570,860,1090,4.5),
 ("e2","Da dove viene (corsivo)",40,360,860,700,4.5),
 ("evo_04_codice_sbagliato","Questo codice non vale piu'",60,805,730,915,4.5),
 ("evo_03_persona","Leggi (pulsante spento)",680,695,820,740,3.0),
 ("evo_03_persona","Continua (spento)",120,1750,345,1790,3.0),
 ("alba_06_a","Oggi Medora guarda con te il cielo di oggi (azzurro)",150,1290,760,1400,4.5),
 ("alba_06_a","Scegli fra i ventidue arcani",60,615,840,830,4.5),
 ("oracolo_14_condividi","x",0,0,0,0,4.5),
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
