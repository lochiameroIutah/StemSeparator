#!/usr/bin/env python3
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os, math

W, H = 960, 540  # @2x retina → displayed 480x270

BG     = (14, 6, 4)
ORANGE = (255, 107, 20)
AMBER  = (255, 176, 26)
CRIMSON= (255, 45,  0)

img  = Image.new("RGBA", (W, H), BG + (255,))
draw = ImageDraw.Draw(img, "RGBA")

# ── Radial glow top-center ─────────────────────────────────────────
glow = Image.new("RGBA", (W, H), (0,0,0,0))
gd   = ImageDraw.Draw(glow, "RGBA")
for r in range(400, 0, -3):
    a = int(40 * (1 - r/400)**1.8)
    gd.ellipse([W//2-r, -r, W//2+r, r], fill=(255,80,10,a))
img = Image.alpha_composite(img, glow)

# second smaller glow bottom
glow2 = Image.new("RGBA", (W, H), (0,0,0,0))
gd2   = ImageDraw.Draw(glow2, "RGBA")
for r in range(260, 0, -3):
    a = int(22 * (1 - r/260)**2)
    gd2.ellipse([W//2-r, H-r//2, W//2+r, H+r//2*3], fill=(200,40,0,a))
img = Image.alpha_composite(img, glow2)
draw = ImageDraw.Draw(img, "RGBA")

# ── Subtle dot grid ────────────────────────────────────────────────
for x in range(0, W, 48):
    for y in range(0, H, 48):
        draw.ellipse([x-1,y-1,x+1,y+1], fill=(255,255,255,14))

# ── Fonts ─────────────────────────────────────────────────────────
def font(size, bold=False):
    paths = [
        "/System/Library/Fonts/HelveticaNeue.ttc",
        "/System/Library/Fonts/Helvetica.ttc",
        "/System/Library/Fonts/SFNSText.ttf",
    ]
    for p in paths:
        try: return ImageFont.truetype(p, size, index=1 if bold else 0)
        except: pass
    return ImageFont.load_default()

fnt_title  = font(30, bold=True)
fnt_sub    = font(22)
fnt_label  = font(24, bold=True)
fnt_version= font(19)
fnt_brand  = font(19)

def cx_text(d, cx, y, text, fnt, color):
    bb = d.textbbox((0,0), text, font=fnt)
    d.text((cx-(bb[2]-bb[0])//2, y), text, font=fnt, fill=color)

# ── Top instruction ────────────────────────────────────────────────
cx_text(draw, W//2, 44,
        "Drag Stems Shortcut to Applications to install",
        fnt_sub, (255,255,255,100))

# thin separator
draw.line([(W//2-200, 90),(W//2+200, 90)], fill=(255,255,255,20), width=1)

# ── App icon (left) ────────────────────────────────────────────────
ICON_SZ = 128
APP_CX, APP_CY = 250, 290

icon_path = "StemSeparator/Assets.xcassets/AppIcon.appiconset/icon_256.png"
if os.path.exists(icon_path):
    icon = Image.open(icon_path).convert("RGBA").resize((ICON_SZ*2, ICON_SZ*2), Image.LANCZOS)
    # soft drop shadow
    shadow = Image.new("RGBA", (W, H), (0,0,0,0))
    for offset, alpha in [(12,30),(8,50),(4,70),(2,50)]:
        sx = APP_CX - ICON_SZ + offset
        sy = APP_CY - ICON_SZ + offset
        shadow_patch = Image.new("RGBA", (ICON_SZ*2, ICON_SZ*2), (0,0,0,alpha))
        shadow_patch.putalpha(icon.split()[3].point(lambda p: p * alpha // 255))
        shadow.paste(shadow_patch, (sx, sy), shadow_patch)
    img = Image.alpha_composite(img, shadow)
    img.paste(icon, (APP_CX-ICON_SZ, APP_CY-ICON_SZ), icon)
    draw = ImageDraw.Draw(img, "RGBA")

# App label
cx_text(draw, APP_CX, APP_CY+ICON_SZ+18, "Stems Shortcut", fnt_label, (255,255,255,210))
cx_text(draw, APP_CX, APP_CY+ICON_SZ+48, "Version 1.0", fnt_version, (255,255,255,70))

# ── Applications folder (right) ───────────────────────────────────
APPS_CX, APPS_CY = W - 250, 290

# Draw folder icon using system icon if available
apps_icon_path = "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericApplicationsFolder.icns"
folder_drawn = False
if os.path.exists(apps_icon_path):
    try:
        from PIL import IcnsImagePlugin
        fi = Image.open(apps_icon_path)
        fi.size  # trigger load
        fi = fi.convert("RGBA").resize((ICON_SZ*2, ICON_SZ*2), Image.LANCZOS)
        # tint it slightly warm to match theme
        r,g,b,a = fi.split()
        fi = Image.merge("RGBA",[r,g,b,a])
        img.paste(fi, (APPS_CX-ICON_SZ, APPS_CY-ICON_SZ), fi)
        draw = ImageDraw.Draw(img, "RGBA")
        folder_drawn = True
    except:
        pass

if not folder_drawn:
    # Stylized folder fallback
    fw, fh = 120, 96
    # tab
    draw.rounded_rectangle([APPS_CX-fw//2, APPS_CY-fh//2-18,
                             APPS_CX-fw//2+fw//2, APPS_CY-fh//2+4],
                            radius=8, fill=(255,255,255,50))
    # body
    draw.rounded_rectangle([APPS_CX-fw//2, APPS_CY-fh//2,
                             APPS_CX+fw//2, APPS_CY+fh//2],
                            radius=12, fill=(255,255,255,40))
    cx_text(draw, APPS_CX, APPS_CY-20, "A", font(64, bold=True), (255,255,255,130))

cx_text(draw, APPS_CX, APPS_CY+ICON_SZ+18, "Applications", fnt_label, (255,255,255,210))

# ── Arrow (center, animated-look with gradient) ────────────────────
AX1 = APP_CX + ICON_SZ + 30
AX2 = APPS_CX - ICON_SZ - 30
AY  = APP_CY

arrow_w = AX2 - AX1
arrow_h = 6

# Gradient line via horizontal band
for i in range(arrow_w):
    t  = i / arrow_w
    r  = int(ORANGE[0] + t*(AMBER[0]-ORANGE[0]))
    g  = int(ORANGE[1] + t*(AMBER[1]-ORANGE[1]))
    b  = int(ORANGE[2] + t*(AMBER[2]-ORANGE[2]))
    a  = int(160 + t*90)
    draw.line([(AX1+i, AY-arrow_h//2),(AX1+i, AY+arrow_h//2)],
               fill=(r,g,b,a), width=1)

# Glow around arrow
glow_arrow = Image.new("RGBA", (W, H), (0,0,0,0))
gda = ImageDraw.Draw(glow_arrow, "RGBA")
for offset in range(12, 0, -2):
    a = int(18 * (1 - offset/12))
    gda.line([(AX1, AY-offset),(AX2, AY-offset)], fill=AMBER+(a,), width=1)
    gda.line([(AX1, AY+offset),(AX2, AY+offset)], fill=AMBER+(a,), width=1)
img = Image.alpha_composite(img, glow_arrow)
draw = ImageDraw.Draw(img, "RGBA")

# Arrowhead triangle
tip = AX2 + 2
pts = [(tip, AY), (tip-22, AY-12), (tip-22, AY+12)]
draw.polygon(pts, fill=AMBER+(240,))

# ── Bottom branding ────────────────────────────────────────────────
draw.line([(W//2-200, H-90),(W//2+200, H-90)], fill=(255,255,255,18), width=1)
cx_text(draw, W//2, H-72, "Made by Weero  ·  @doitweero", fnt_brand, (255,255,255,50))

# ── Flatten & save ─────────────────────────────────────────────────
final = Image.new("RGB", (W, H), BG)
final.paste(img, mask=img.split()[3])
os.makedirs("build", exist_ok=True)
final.save("build/dmg_background.png", "PNG", dpi=(144,144))
print("Saved build/dmg_background.png")
