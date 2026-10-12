#!/usr/bin/env python3
"""HERCULE - fondos de pantalla, iconos de escritorio y modo undercover."""
import os, numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter

GREEN=(57,255,20); GREEN_DK=(31,168,11); ORANGE=(255,106,0)
BG=(10,14,10); GRID=(22,32,26); TEXT=(200,214,200)
HERE=os.path.dirname(os.path.abspath(__file__))
SIL=Image.open(os.path.join(HERE,"..","identidad-visual","_fuentes_svg","hercule-silueta-fuente.png")).convert("RGBA")
FDIR="/usr/share/fonts/truetype/dejavu/"
def font(sz,kind="monob"):
    f={"monob":"DejaVuSansMono-Bold.ttf","mono":"DejaVuSansMono.ttf","serifi":"DejaVuSerif-Italic.ttf"}[kind]
    return ImageFont.truetype(FDIR+f,sz)

def tint(img, color):
    a=np.asarray(img).astype(float); out=a.copy()
    out[:,:,0]=color[0]; out[:,:,1]=color[1]; out[:,:,2]=color[2]
    return Image.fromarray(out.astype("uint8"),"RGBA")

def grid(im,step,col=GRID,op=255):
    g=Image.new("RGBA",im.size,(0,0,0,0)); d=ImageDraw.Draw(g)
    w,h=im.size
    for x in range(0,w,step): d.line([(x,0),(x,h)],fill=col+(op,))
    for y in range(0,h,step): d.line([(0,y),(w,y)],fill=col+(op,))
    return Image.alpha_composite(im,g)

def vignette(im, strength=0.55):
    w,h=im.size
    v=Image.new("L",(w,h),0); d=ImageDraw.Draw(v)
    d.ellipse([-w*0.25,-h*0.25,w*1.25,h*1.25],fill=255)
    v=v.filter(ImageFilter.GaussianBlur(w*0.12))
    dark=Image.new("RGBA",(w,h),(0,0,0,int(255*strength)))
    mask=Image.eval(v,lambda p:255-p)
    return Image.composite(Image.alpha_composite(im,dark),im,mask)

def fit(sil,bw,bh):
    r=min(bw/sil.width,bh/sil.height)
    return sil.resize((int(sil.width*r),int(sil.height*r)),Image.LANCZOS)

# ---------- FONDO PRINCIPAL (branded) ----------
def wallpaper(w,h,minimal=False):
    im=Image.new("RGBA",(w,h),BG+(255,))
    im=grid(im,max(40,w//48),op=120)
    # silueta centrada, arriba del centro
    sil=fit(SIL,int(h*0.62),int(h*0.62))
    sx=(w-sil.width)//2; sy=int(h*0.14)
    # glow sutil detras de la silueta
    glow=tint(sil,GREEN); glow=glow.filter(ImageFilter.GaussianBlur(18))
    go=Image.new("RGBA",im.size,(0,0,0,0)); go.alpha_composite(glow,(sx,sy))
    go.putalpha(go.getchannel("A").point(lambda p:int(p*0.35)))
    im=Image.alpha_composite(im,go)
    im.alpha_composite(sil,(sx,sy))
    d=ImageDraw.Draw(im)
    if not minimal:
        cy=sy+sil.height+int(h*0.06)
        d.text((w//2,cy),"H E R C U L E",font=font(int(h*0.075)),fill=GREEN,anchor="mm")
        d.text((w//2,cy+int(h*0.075)),"les petites cellules grises",font=font(int(h*0.030),"serifi"),fill=ORANGE,anchor="mm")
        d.text((w//2,cy+int(h*0.115)),"OSINT  ·  CIBERINTELIGENCIA  ·  HACKING ETICO",font=font(int(h*0.018),"mono"),fill=TEXT,anchor="mm")
    # marco fino
    m=int(h*0.03)
    d.rectangle([m,m,w-m,h-m],outline=GREEN_DK+(160,),width=2)
    im=vignette(im,0.5)
    return im.convert("RGB")

# ---------- ICONO DE ESCRITORIO / LAUNCHER ----------
def icono(size, rounded=True, grid_on=True):
    im=Image.new("RGBA",(size,size),(0,0,0,0))
    d=ImageDraw.Draw(im)
    r=int(size*0.18)
    d.rounded_rectangle([0,0,size-1,size-1],radius=r,fill=BG+(255,))
    if grid_on:
        g=grid(Image.new("RGBA",(size,size),(0,0,0,0)),size//12,op=160)
        m=Image.new("L",(size,size),0)
        ImageDraw.Draw(m).rounded_rectangle([0,0,size-1,size-1],radius=r,fill=255)
        im=Image.composite(Image.alpha_composite(im,g),im,m)
    sil=fit(SIL,int(size*0.72),int(size*0.76))
    im.alpha_composite(sil,((size-sil.width)//2,int(size*0.11)))
    # borde verde
    ImageDraw.Draw(im).rounded_rectangle([1,1,size-2,size-2],radius=r,outline=GREEN+(255,),width=max(2,size//100))
    return im

# ---------- AVATAR DE LOGIN (circular) ----------
def avatar_login(size=512):
    im=Image.new("RGBA",(size,size),BG+(255,))
    im=grid(im,size//14,op=130)
    d=ImageDraw.Draw(im)
    d.ellipse([size*0.04,size*0.04,size*0.96,size*0.96],outline=GREEN+(255,),width=int(size*0.015))
    sil=fit(SIL,int(size*0.64),int(size*0.68))
    im.alpha_composite(sil,((size-sil.width)//2,int(size*0.14)))
    # recorte circular
    mask=Image.new("L",(size,size),0)
    ImageDraw.Draw(mask).ellipse([0,0,size-1,size-1],fill=255)
    out=Image.new("RGBA",(size,size),(0,0,0,0))
    out.paste(im,(0,0),mask)
    return out

# ---------- UNDERCOVER (discreto) ----------
def undercover(w,h,variant="slate",watermark=False):
    # fondo neutro, profesional, sin verde ni Poirot evidente
    if variant=="slate":
        top=(26,30,38); bot=(12,14,18)   # azul pizarra oscuro
    else:
        top=(30,30,30); bot=(14,14,14)   # gris grafito
    base=Image.new("RGB",(w,h),bot)
    # degrade vertical suave
    grad=Image.new("L",(1,h))
    for y in range(h): grad.putpixel((0,y),int(255*(y/h)))
    grad=grad.resize((w,h))
    topimg=Image.new("RGB",(w,h),top)
    base=Image.composite(base,topimg,grad)
    im=base.convert("RGBA")
    # textura geometrica muy sutil (lineas diagonales tenues)
    ov=Image.new("RGBA",(w,h),(0,0,0,0)); d=ImageDraw.Draw(ov)
    for x in range(-h,w,70):
        d.line([(x,0),(x+h,h)],fill=(255,255,255,5),width=1)
    im=Image.alpha_composite(im,ov)
    # guino Hercule: solo en la variante 'guino', y casi imperceptible (~2.2%)
    if watermark:
        sil=fit(SIL,int(h*0.34),int(h*0.34))
        gh=tint(sil,(255,255,255))
        gh.putalpha(gh.getchannel("A").point(lambda p:int(p*0.022)))
        im.alpha_composite(gh,(w-sil.width-int(w*0.03),h-sil.height-int(h*0.05)))
    im=vignette(im,0.4)
    return im.convert("RGB")

def main():
    F=os.path.join(HERE,"fondos"); I=os.path.join(HERE,"iconos-escritorio"); U=os.path.join(HERE,"undercover")
    for dd in (F,I,U): os.makedirs(dd,exist_ok=True)
    # fondos branded
    wallpaper(1920,1080).save(os.path.join(F,"hercule-fondo-1920x1080.png"))
    wallpaper(3840,2160).save(os.path.join(F,"hercule-fondo-3840x2160.png"))
    wallpaper(1920,1080,minimal=True).save(os.path.join(F,"hercule-fondo-minimal-1920x1080.png"))
    wallpaper(1080,1920).save(os.path.join(F,"hercule-fondo-vertical-1080x1920.png"))
    # iconos
    for s in (128,256,512): icono(s).save(os.path.join(I,f"hercule-icono-{s}.png"))
    avatar_login(512).save(os.path.join(I,"hercule-usuario-login-512.png"))
    # undercover (limpios, pasan por fondo corporativo cualquiera)
    undercover(1920,1080,"slate").save(os.path.join(U,"hercule-undercover-slate-1920x1080.png"))
    undercover(3840,2160,"slate").save(os.path.join(U,"hercule-undercover-slate-3840x2160.png"))
    undercover(1920,1080,"grafito").save(os.path.join(U,"hercule-undercover-grafito-1920x1080.png"))
    # variante con guino casi invisible (solo vos sabes que esta)
    undercover(1920,1080,"slate",watermark=True).save(os.path.join(U,"hercule-undercover-guino-1920x1080.png"))
    print("OK escritorio generado")

if __name__=="__main__":
    main()
