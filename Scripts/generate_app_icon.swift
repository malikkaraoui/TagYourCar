// TagYourCar App Icon v4 — composition propre
// NSImage: y=0 en BAS, y=1024 en HAUT (visuel haut = y élevé)
import AppKit

let outputPath = "/Users/malik/Documents/Laboratoire 🧪/TagYourCar/TagYourCar/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"
let S: CGFloat = 1024

// Palette
let bgTop    = NSColor(calibratedRed: 0.19, green: 0.11, blue: 0.35, alpha: 1)
let bgBot    = NSColor(calibratedRed: 0.30, green: 0.20, blue: 0.50, alpha: 1)
let white    = NSColor(calibratedRed: 0.98, green: 0.98, blue: 1.00, alpha: 1)
let purple   = NSColor(calibratedRed: 0.27, green: 0.18, blue: 0.47, alpha: 1)
let purpleSoft = NSColor(calibratedRed: 0.58, green: 0.46, blue: 0.84, alpha: 1)
let blueEU   = NSColor(calibratedRed: 0.11, green: 0.24, blue: 0.70, alpha: 1)
let red      = NSColor(calibratedRed: 0.91, green: 0.38, blue: 0.28, alpha: 1)
let redHi    = NSColor(calibratedRed: 1.00, green: 0.58, blue: 0.50, alpha: 1)
let plateBg  = NSColor(calibratedRed: 0.99, green: 0.99, blue: 0.97, alpha: 1)
let plateBorder = NSColor(calibratedRed: 0.24, green: 0.16, blue: 0.42, alpha: 0.15)

func rr(_ r: CGRect, _ rx: CGFloat) -> NSBezierPath { NSBezierPath(roundedRect: r, xRadius: rx, yRadius: rx) }
func f(_ c: NSColor, _ p: NSBezierPath) { c.setFill(); p.fill() }

let img = NSImage(size: NSSize(width: S, height: S))
img.lockFocus()
guard let ctx = NSGraphicsContext.current?.cgContext else { fatalError() }
ctx.interpolationQuality = .high; ctx.setAllowsAntialiasing(true)

// 1. Fond dégradé
let bg = rr(CGRect(x: 0, y: 0, width: S, height: S), 220)
NSGradient(starting: bgBot, ending: bgTop)!.draw(in: bg, angle: 90)

// 2. Halos d'ambiance
func halo(_ cx: CGFloat, _ cy: CGFloat, _ rx: CGFloat, _ ry: CGFloat, _ c: NSColor, blur: CGFloat) {
    let p = NSBezierPath(ovalIn: CGRect(x: cx-rx, y: cy-ry, width: rx*2, height: ry*2))
    ctx.saveGState()
    ctx.setShadow(offset: .zero, blur: blur, color: c.withAlphaComponent(0.9).cgColor)
    f(c.withAlphaComponent(0.4), p)
    ctx.restoreGState()
}
halo(512, 780, 350, 160, purpleSoft, blur: 120)
halo(512, 240, 280, 120, purpleSoft, blur: 100)

// 3. Carte blanche principale
let card = CGRect(x: 112, y: 112, width: 800, height: 800)
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -20), blur: 50, color: NSColor.black.withAlphaComponent(0.22).cgColor)
f(white, rr(card, 200))
ctx.restoreGState()
f(white, rr(card, 200))
plateBorder.setStroke(); let cardPath = rr(card, 200); cardPath.lineWidth = 5; cardPath.stroke()

// 4. Silhouette voiture — zone haute de la carte
// Corps bas de la voiture (rectangle arrondi)
let bodyY: CGFloat = 590
let bodyH: CGFloat = 110
let bodyRect = CGRect(x: 220, y: bodyY, width: 584, height: bodyH)
f(purple, rr(bodyRect, bodyH/2))

// Toit (bezier simple formant une bulle)
let roof = NSBezierPath()
roof.move(to: CGPoint(x: 295, y: bodyY + bodyH - 4))
roof.curve(to: CGPoint(x: 345, y: bodyY + bodyH + 148),
           controlPoint1: CGPoint(x: 295, y: bodyY + bodyH + 80),
           controlPoint2: CGPoint(x: 315, y: bodyY + bodyH + 140))
roof.curve(to: CGPoint(x: 678, y: bodyY + bodyH + 148),
           controlPoint1: CGPoint(x: 400, y: bodyY + bodyH + 175),
           controlPoint2: CGPoint(x: 625, y: bodyY + bodyH + 175))
roof.curve(to: CGPoint(x: 728, y: bodyY + bodyH - 4),
           controlPoint1: CGPoint(x: 708, y: bodyY + bodyH + 140),
           controlPoint2: CGPoint(x: 728, y: bodyY + bodyH + 80))
roof.close()
f(purple, roof)

// Fenêtres (blanc transparent pour donner du détail)
let winY = bodyY + bodyH + 34
let windows = NSBezierPath(roundedRect: CGRect(x: 350, y: winY, width: 320, height: 96), xRadius: 18, yRadius: 18)
white.withAlphaComponent(0.20).setFill(); windows.fill()

// Roues
for wx: CGFloat in [326, 692] {
    let wr: CGFloat = 72
    let wheelO = NSBezierPath(ovalIn: CGRect(x: wx - wr, y: bodyY - wr + 30, width: wr*2, height: wr*2))
    f(purple, wheelO)
    let wheelI = NSBezierPath(ovalIn: CGRect(x: wx - 30, y: bodyY - 30 + 30, width: 60, height: 60))
    f(white.withAlphaComponent(0.35), wheelI)
    let hub = NSBezierPath(ovalIn: CGRect(x: wx - 10, y: bodyY - 10 + 30, width: 20, height: 20))
    f(white.withAlphaComponent(0.70), hub)
}

// 5. Plaque d'immatriculation — zone basse
let plateW: CGFloat = 610; let plateH: CGFloat = 200
let plateX = (S - plateW) / 2
let plate = CGRect(x: plateX, y: 196, width: plateW, height: plateH)
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -6), blur: 18, color: purple.withAlphaComponent(0.12).cgColor)
f(plateBg, rr(plate, 60))
ctx.restoreGState()
f(plateBg, rr(plate, 60))
plateBorder.setStroke(); let pp = rr(plate, 60); pp.lineWidth = 4; pp.stroke()

// Bande EU bleue
let band = CGRect(x: plate.minX + 14, y: plate.minY + 14, width: 76, height: plate.height - 28)
f(blueEU, rr(band, 28))

// Étoiles EU + F
let ps = NSMutableParagraphStyle(); ps.alignment = .center
let euText = NSAttributedString(string: "★\nF", attributes: [
    .font: NSFont.systemFont(ofSize: 26, weight: .bold),
    .foregroundColor: NSColor.white,
    .paragraphStyle: ps
])
euText.draw(in: CGRect(x: band.minX, y: band.minY + 36, width: band.width, height: 120))

// Vis de plaque
for vx: CGFloat in [plate.minX + 106, plate.maxX - 28] {
    let vs = NSBezierPath(ovalIn: CGRect(x: vx - 10, y: plate.maxY - 36, width: 20, height: 20))
    f(NSColor(calibratedWhite: 0.82, alpha: 1), vs)
    let vi = NSBezierPath(ovalIn: CGRect(x: vx - 4, y: plate.maxY - 30, width: 8, height: 8))
    f(NSColor(calibratedWhite: 0.65, alpha: 1), vi)
}

// 6. Badge alerte (coin supérieur droit de la carte)
let bCX: CGFloat = 840; let bCY: CGFloat = 830; let bR: CGFloat = 90
let badge = NSBezierPath(ovalIn: CGRect(x: bCX-bR, y: bCY-bR, width: bR*2, height: bR*2))
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -10), blur: 24, color: red.withAlphaComponent(0.40).cgColor)
NSGradient(starting: redHi, ending: red)!.draw(in: badge, angle: -90)
ctx.restoreGState()

let bp = NSMutableParagraphStyle(); bp.alignment = .center
let bt = NSAttributedString(string: "!", attributes: [
    .font: NSFont.systemFont(ofSize: 118, weight: .black),
    .foregroundColor: NSColor.white,
    .paragraphStyle: bp
])
bt.draw(in: CGRect(x: bCX-bR, y: bCY-bR+8, width: bR*2, height: bR*2))

img.unlockFocus()

// Forcer un export exactement 1024×1024 pixels (NSImage est @2x sur Retina → 2048 sinon)
let pixelSize = 1024
guard let bmpExport = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: pixelSize,
    pixelsHigh: pixelSize,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .calibratedRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
) else { fatalError("Impossible de créer le bitmap d'export") }

bmpExport.size = NSSize(width: pixelSize, height: pixelSize)
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bmpExport)
img.draw(in: NSRect(x: 0, y: 0, width: pixelSize, height: pixelSize),
         from: .zero,
         operation: .copy,
         fraction: 1.0)
NSGraphicsContext.restoreGraphicsState()

guard let png = bmpExport.representation(using: .png, properties: [:]) else {
    fatalError("Impossible d'encoder en PNG")
}

try png.write(to: URL(fileURLWithPath: outputPath), options: .atomic)
print("Icône générée → \(outputPath) (\(pixelSize)×\(pixelSize) px)")
