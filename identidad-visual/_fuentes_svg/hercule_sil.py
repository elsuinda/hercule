#!/usr/bin/env python3
"""
HERCULE — identidad visual basada en la SILUETA de Poirot (bombin + mostacho + monio).
Recolorea la silueta de referencia a verde fosforo y compone logos, iconos y redes.
Fuente: hercule-silueta-fuente.png (silueta verde, fondo transparente).
"""
import os, numpy as np
from PIL import Image, ImageDraw, ImageFont

GREEN=(57,255,20); GREEN_DK=(31,168,11); ORANGE=(255,106,0)
BG=(10,14,10); GRID=(22,32,26); TEXT=(200,214,200)
FDIR="/usr/share/fonts/truetype/dejavu/"
def font(sz,kind="monob"):
    f={"monob":"DejaVuSansMono-Bold.ttf","mono":"DejaVuSansMono.ttf",
       "serifi":"DejaVuSerif-Italic.ttf"}[kind]
    return ImageFont.truetype(FDIR+f,sz)

HERE=os.path.dirname(os.path.abspath(__file__))
BASE=os.path.dirname(HERE)
SIL=Image.open(os.path.join(HERE,"hercule-silueta-fuente.png")).convert("RGBA")

def rbg(size, color=BG, radius=None):
    im=Image.new("RGBA",(size,size),(0,0,0,0))
    d=ImageDraw.Draw(im)
    r=radius if radius is not None else int(size*0.14)
    d.rounded_rectangle([0,0,size-1,size-1],radius=r,fill=color+(255,))
    return im

def add_grid(im, step, rounded=True):
    w,h=im.size
    g=Image.new("RGBA",(w,h),(0,0,0,0)); d=ImageDraw.Draw(g)
    for x in range(0,w,step): d.line([(x,0),(x,h)],fill=GRID+(255,))
    for y in range(0,h,step): d.line([(0,y),(w,y)],fill=GRID+(255,))
    if rounded:
        m=Image.new("L",(w,h),0)
        ImageDraw.Draw(m).rounded_rectangle([0,0,w-1,h-1],radius=int(min(w,h)*0.14),fill=255)
        return Image.composite(Image.alpha_composite(im,g),im,m)
    return Image.alpha_composite(im,g)

def fit(sil, box_w, box_h):
    r=min(box_w/sil.width, box_h/sil.height)
    return sil.resize((max(1,int(sil.width*r)),max(1,int(sil.height*r))),Image.LANCZOS)

def ctext(d,xy,txt,fnt,fill,anchor=None):
    d.text(xy,txt,font=fnt,fill=fill,anchor=anchor)

# ---------- piezas ----------
def emblema(size=512, grid=True, rounded=True, pad=0.15):
    bg=rbg(size) if rounded else Image.new("RGBA",(size,size),BG+(255,))
    if grid: bg=add_grid(bg,size//16,rounded)
    s=fit(SIL,int(size*(1-2*pad)),int(size*(1-2*pad)))
    bg.alpha_composite(s,((size-s.width)//2,(size-s.height)//2))
    return bg

def horizontal(w=1400,h=440):
    im=rbg_rect(w,h); d=ImageDraw.Draw(im)
    s=fit(SIL,int(h*0.72),int(h*0.80)); im.alpha_composite(s,(int(h*0.14),(h-s.height)//2))
    tx=int(h*0.92)
    ctext(d,(tx,int(h*0.30)),"HERCULE",font(int(h*0.26)),GREEN,anchor="lm")
    ctext(d,(tx,int(h*0.56)),"les petites cellules grises",font(int(h*0.115),"serifi"),ORANGE,anchor="lm")
    ctext(d,(tx,int(h*0.74)),"OSINT  ·  CIBERINTELIGENCIA  ·  HACKING ETICO",font(int(h*0.068),"mono"),TEXT,anchor="lm")
    return im

def vertical(w=820,h=1000):
    im=rbg_rect(w,h); d=ImageDraw.Draw(im)
    s=fit(SIL,int(w*0.55),int(h*0.52)); im.alpha_composite(s,((w-s.width)//2,int(h*0.06)))
    ctext(d,(w//2,int(h*0.72)),"HERCULE",font(int(w*0.17)),GREEN,anchor="mm")
    ctext(d,(w//2,int(h*0.80)),"les petites cellules grises",font(int(w*0.058),"serifi"),ORANGE,anchor="mm")
    ctext(d,(w//2,int(h*0.865)),"OSINT · CIBERINTELIGENCIA · HACKING ETICO",font(int(w*0.033),"mono"),TEXT,anchor="mm")
    return im

def rbg_rect(w,h,color=BG,radius=28):
    im=Image.new("RGBA",(w,h),(0,0,0,0))
    ImageDraw.Draw(im).rounded_rectangle([0,0,w-1,h-1],radius=radius,fill=color+(255,))
    im=add_grid_rect(im,h//10)
    return im

def add_grid_rect(im,step):
    w,h=im.size; g=Image.new("RGBA",(w,h),(0,0,0,0)); d=ImageDraw.Draw(g)
    for x in range(0,w,step): d.line([(x,0),(x,h)],fill=GRID+(255,))
    for y in range(0,h,step): d.line([(0,y),(w,y)],fill=GRID+(255,))
    m=Image.new("L",(w,h),0)
    ImageDraw.Draw(m).rounded_rectangle([0,0,w-1,h-1],radius=28,fill=255)
    return Image.composite(Image.alpha_composite(im,g),im,m)

def avatar(size=1000):
    im=Image.new("RGBA",(size,size),BG+(255,)); im=add_grid(im,size//14,rounded=False)
    d=ImageDraw.Draw(im)
    d.ellipse([size*0.04,size*0.04,size*0.96,size*0.96],outline=GREEN_DK+(255,),width=int(size*0.012))
    s=fit(SIL,int(size*0.60),int(size*0.64)); im.alpha_composite(s,((size-s.width)//2,int(size*0.11)))
    ctext(d,(size//2,int(size*0.90)),"HERCULE",font(int(size*0.085)),GREEN,anchor="mm")
    return im

def banner(w,h,sub=True):
    im=Image.new("RGBA",(w,h),BG+(255,)); im=add_grid_plain(im,h//9); d=ImageDraw.Draw(im)
    s=fit(SIL,int(h*0.72),int(h*0.86)); im.alpha_composite(s,(int(h*0.22),(h-s.height)//2))
    tx=int(h*0.95)
    ctext(d,(tx,int(h*0.40)),"HERCULE",font(int(h*0.24)),GREEN,anchor="lm")
    ctext(d,(tx,int(h*0.60)),"les petites cellules grises",font(int(h*0.098),"serifi"),ORANGE,anchor="lm")
    if sub:
        ctext(d,(tx,int(h*0.74)),"OSINT  ·  CIBERINTELIGENCIA  ·  HACKING ETICO",font(int(h*0.055),"mono"),TEXT,anchor="lm")
    return im

def add_grid_plain(im,step):
    w,h=im.size; d=ImageDraw.Draw(im)
    for x in range(0,w,step): d.line([(x,0),(x,h)],fill=GRID+(255,))
    for y in range(0,h,step): d.line([(0,y),(w,y)],fill=GRID+(255,))
    return im

def main():
    LOGO=os.path.join(BASE,"logo"); ICON=os.path.join(BASE,"iconos"); REDE=os.path.join(BASE,"redes")
    for dd in (LOGO,ICON,REDE): os.makedirs(dd,exist_ok=True)
    # silueta transparente (fuente lista para usar)
    SIL.save(os.path.join(LOGO,"hercule-silueta.png"))
    # emblema / app
    emblema(512).save(os.path.join(LOGO,"hercule-emblema.png"))
    emblema(1024).save(os.path.join(ICON,"app-icon-1024.png"))
    emblema(512).save(os.path.join(ICON,"app-icon-512.png"))
    # favicon (sin grilla, cuadrado)
    fav=emblema(256,grid=False,rounded=False,pad=0.08)
    for sz in (16,32,48,64,128,256):
        fav.resize((sz,sz),Image.LANCZOS).save(os.path.join(ICON,f"favicon-{sz}.png"))
    imgs=[Image.open(os.path.join(ICON,f"favicon-{s}.png")).convert("RGBA") for s in (16,32,48,64,128,256)]
    imgs[0].save(os.path.join(ICON,"favicon.ico"),format="ICO",sizes=[(s,s) for s in (16,32,48,64,128,256)])
    # logos
    horizontal().save(os.path.join(LOGO,"hercule-horizontal.png"))
    vertical().save(os.path.join(LOGO,"hercule-vertical.png"))
    # redes
    av=avatar(1000); av.save(os.path.join(REDE,"avatar-1000.png")); av.resize((400,400),Image.LANCZOS).save(os.path.join(REDE,"avatar-400.png"))
    banner(1500,500).save(os.path.join(REDE,"banner-x-1500x500.png"))
    banner(1584,396,sub=False).save(os.path.join(REDE,"banner-linkedin-1584x396.png"))
    banner(1920,1080).save(os.path.join(REDE,"banner-cover-1920x1080.png"))
    print("OK silueta -> identidad visual")

if __name__=="__main__":
    main()
