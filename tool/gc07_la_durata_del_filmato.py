import subprocess, sys
sys.stdout.reconfigure(encoding='utf-8')
W, H = 54, 120
for f in sys.argv[1:]:
    out = subprocess.run(['ffprobe','-v','error','-select_streams','v','-show_entries','frame=pts_time','-of','csv=p=0',f],capture_output=True,text=True).stdout.split()
    tempi = [float(x) for x in out if x]
    raw = subprocess.run(['ffmpeg','-loglevel','error','-i',f,'-vf','scale=%d:%d'%(W,H),'-f','rawvideo','-pix_fmt','gray','-'],capture_output=True).stdout
    n = len(raw)//(W*H)
    fr = [raw[i*W*H:(i+1)*W*H] for i in range(n)]
    def diff(a,b,y0,y1):
        s=0
        for y in range(y0,y1):
            for x in range(W):
                s+=abs(a[y*W+x]-b[y*W+x])
        return s/((y1-y0)*W)
    # zona della scena: dal 15% al 50% dell'altezza
    y0,y1=int(H*0.15),int(H*0.50)
    d=[diff(fr[i-1],fr[i],y0,y1) for i in range(1,n)]
    inizio=next(i for i,v in enumerate(d) if v>20)  # il cambio di schermata
    fine=max(i for i,v in enumerate(d) if v>0.6)
    print('%s: fotogrammi %d, apertura a %.2f s, ultimo movimento della scena a %.2f s, durata %.2f s' % (f.split('/')[-1], n, tempi[inizio+1], tempi[fine+1], tempi[fine+1]-tempi[inizio+1]))
