// TagYourCar App Icon v5 — Automotive Signal
// NSImage: y=0 en BAS, y=1024 en HAUT
import AppKit

let outputPath = "/Users/malik/Documents/Laboratoire 🧪/TagYourCar/TagYourCar/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"
let S: CGFloat = 1024

// Palette Automotive Signal
let slateTop  = NSColor(calibratedRed: 0.059, green: 0.090, blue: 0.165, alpha: 1)  // #0F172A
let slateBot  = NSColor(calibratedRed: 0.118, green: 0.161, blue: 0.231, alpha: 1)  // #1E293B
let orange    = NSColor(calibratedRed: 0.976, green: 0.451, blue: 0.086, alpha: 1)  // #F97316
let orangeHi  = NSColor(calibratedRed: 0.984, green: 0.573, blue: 0.235, alpha: 1)  // #FB923C
let white     = NSColor(calibratedRed: 0.973, green: 0.980, blue: 0.988, alpha: 1)  // #F8FAFC
let slate600  = NSColor(calibratedRed: 0.278, green: 0.333, blue: 0.412, alpha: 1)  // #475569
let blueEU    = NSColor(calibratedRed: 0.11, green: 0.24, blue: 0.70, alpha: 1)
let plateBg   = NSColor(calibratedRed: 0.99, green: 0.99, blue: 0.97, alpha: 1)
let plateBdr  = NSColor(calibratedRed: 0.200, green: 0.255, blue: 0.333, alpha: 0.25)

func rr(_ r: CGRect, _ rx: CGFloat) -> NSBezierPath { NSBezierPath(roundedRect: r, xRadius: rx, yRadius: rx) }
func f(_ c: NSColor, _ p: NSBezierPath) { c.setFill(); p.fill() }

let img = NSImage(size: NSSize(width: S, height: S))
img.lockFocus()
guard let ctx = NSGraphicsContext.current?.cgContext else { fatalError() }
ctx.interpolationQuality = .high; ctx.setAllowsAntialiasing(true)

// 1. Fond degrade slate
let bg = rr(CGRect(x: 0, y: 0, width: S, height: S), 220)
NSGradient(starting: slateBot, ending: slateTop)!.draw(in: bg, angle: 90)

// 2. Halo orange subtil en haut
func halo(_ cx: CGFloat, _ cy: CGFloat, _ rx: CGFloat, _ ry: CGFloat, _ c: NSColor, blur: CGFloat) {
    let p = NSBezierPath(ovalIn: CGRect(x: cx-rx, y: cy-ry, width: rx*2, height: ry*2))
    ctx.saveGState()
    ctx.setShadow(offset: .zero, blur: blur, color: c.withAlphaComponent(0.8).cgColor)
    f(c.withAlphaComponent(0.15), p)
    ctx.restoreGState()
}
halo(512, 750, 300, 140, orange, blur: 140)
halo(512, 300, 200, 100, orangeHi, blur: 100)

// 3. Carte blanche principale
let card = CGRect(x: 112, y: 112, width: 800, height: 800)
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -20), blur: 50, color: NSColor.black.withAlphaComponent(0.35).cgColor)
f(white, rr(card, 200))
ctx.restoreGState()
f(white, rr(card, 200))

// 4. Silhouette voiture slate
let bodyY: CGFloat = 590
let bodyH: CGFloat = 110
let bodyRect = CGRect(x: 220, y: bodyY, width: 584, height: bodyH)
f(slateTop, rr(bodyRect, bodyH/2))

// Toit
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
f(slateTop, roof)

// Fenetres
let winY = bodyY + bodyH + 34
let windows = NSBezierPath(roundedRect: CGRect(x: 350, y: winY, width: 320, height: 96), xRadius: 18, yRadius: 18)
slate600.withAlphaComponent(0.30).setFill(); windows.fill()

// Roues
for wx: CGFloat in [326, 692] {
    let wr: CGFloat = 72
    f(slateTop, NSBezierPath(ovalIn: CGRect(x: wx-wr, y: bodyY-wr+30, width: wr*2, height: wr*2)))
    f(slate600.withAlphaComponent(0.40), NSBezierPath(ovalIn: CGRect(x: wx-30, y: bodyY-30+30, width: 60, height: 60)))
    f(white.withAlphaComponent(0.55), NSBezierPath(ovalIn: CGRect(x: wx-10, y: bodyY-10+30, width: 20, height: 20)))
}

// 5. Plaque d'immatriculation
let plateW: CGFloat = 610; let plateH: CGFloat = 200
let plateX = (S - plateW) / 2
let plate = CGRect(x: plateX, y: 196, width: plateW, height: plateH)
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -6), blur: 18, color: slateTop.withAlphaComponent(0.15).cgColor)
f(plateBg, rr(plate, 60))
ctx.restoreGState()
f(plateBg, rr(plate, 60))
plateBdr.setStroke(); let pp = rr(plate, 60); pp.lineWidth = 4; pp.stroke()

// Bande EU bleue
let band = CGRect(x: plate.minX + 14, y: plate.minY + 14, width: 76, height: plate.height - 28)
f(blueEU, rr(band, 28))

let ps = NSMutableParagraphStyle(); ps.alignment = .center
let euText = NSAttributedString(string: "★\nF", attributes: [
    .font: NSFont.systemFont(ofSize: 26, weight: .bold),
    .foregroundColor: NSColor.white,
    .paragraphStyle: ps
])
euText.draw(in: CGRect(x: band.minX, y: band.minY + 36, width: band.width, height: 120))

// Vis de plaque
for vx: CGFloat in [plate.minX + 106, plate.maxX - 28] {
    f(NSColor(calibratedWhite: 0.82, alpha: 1), NSBezierPath(ovalIn: CGRect(x: vx-10, y: plate.maxY-36, width: 20, height: 20)))
    f(NSColor(calibratedWhite: 0.65, alpha: 1), NSBezierPath(ovalIn: CGRect(x: vx-4, y: plate.maxY-30, width: 8, height: 8)))
}

// 6. Badge alerte ORANGE (coin superieur droit)
let bCX: CGFloat = 840; let bCY: CGFloat = 830; let bR: CGFloat = 90
let badge = NSBezierPath(ovalIn: CGRect(x: bCX-bR, y: bCY-bR, width: bR*2, height: bR*2))
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -10), blur: 30, color: orange.withAlphaComponent(0.50).cgColor)
NSGradient(starting: orangeHi, ending: orange)!.draw(in: badge, angle: -90)
ctx.restoreGState()

let bp = NSMutableParagraphStyle(); bp.alignment = .center
let bt = NSAttributedString(string: "!", attributes: [
    .font: NSFont.systemFont(ofSize: 118, weight: .black),
    .foregroundColor: NSColor.white,
    .paragraphStyle: bp
])
bt.draw(in: CGRect(x: bCX-bR, y: bCY-bR+8, width: bR*2, height: bR*2))

img.unlockFocus()

// Export 1024x1024
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
) else { fatalError() }

bmpExport.size = NSSize(width: pixelSize, height: pixelSize)
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bmpExport)
img.draw(in: NSRect(x: 0, y: 0, width: pixelSize, height: pixelSize),
         from: .zero,
         operation: .copy,
         fraction: 1.0)
NSGraphicsContext.restoreGraphicsState()

guard let png = bmpExport.representation(using: .png, properties: [:]) else { fatalError() }
try png.write(to: URL(fileURLWithPath: outputPath), options: .atomic)
print("Icone generee → \(outputPath) (\(pixelSize)×\(pixelSize) px)")
