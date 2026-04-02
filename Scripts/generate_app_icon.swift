import AppKit

let assetOutputPath = "/Users/malik/Documents/Laboratoire 🧪/TagYourCar/TagYourCar/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"
let previewOutputPath = "/Users/malik/Documents/Laboratoire 🧪/TagYourCar/docs/app-icon-preview-2026-04-02.png"
let outputPaths = [assetOutputPath, previewOutputPath]

let size: CGFloat = 1024

let bgTop = NSColor(calibratedRed: 0.976, green: 0.984, blue: 0.992, alpha: 1)
let bgBottom = NSColor(calibratedRed: 0.933, green: 0.957, blue: 0.984, alpha: 1)
let nightBlue = NSColor(calibratedRed: 0.118, green: 0.184, blue: 0.420, alpha: 1)
let accentBlue = NSColor(calibratedRed: 0.039, green: 0.424, blue: 0.949, alpha: 1)
let white = NSColor.white

func fill(_ color: NSColor, _ path: NSBezierPath) {
    color.setFill()
    path.fill()
}

func stroke(_ color: NSColor, lineWidth: CGFloat, lineCap: NSBezierPath.LineCapStyle = .round, _ build: (NSBezierPath) -> Void) {
    let path = NSBezierPath()
    path.lineWidth = lineWidth
    path.lineCapStyle = lineCap
    path.lineJoinStyle = .round
    build(path)
    color.setStroke()
    path.stroke()
}

func roundedRect(_ rect: CGRect, radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
}

func pointRotatedAroundCenter(_ point: CGPoint, center: CGPoint, angle: CGFloat) -> CGPoint {
    let translatedX = point.x - center.x
    let translatedY = point.y - center.y
    let cosA = cos(angle)
    let sinA = sin(angle)

    return CGPoint(
        x: center.x + translatedX * cosA - translatedY * sinA,
        y: center.y + translatedX * sinA + translatedY * cosA
    )
}

let image = NSImage(size: NSSize(width: size, height: size))
image.lockFocus()

guard let ctx = NSGraphicsContext.current?.cgContext else {
    fatalError("Impossible d'obtenir le contexte graphique")
}

ctx.interpolationQuality = .high
ctx.setAllowsAntialiasing(true)

let backgroundPath = roundedRect(CGRect(x: 0, y: 0, width: size, height: size), radius: 0)
NSGradient(starting: bgTop, ending: bgBottom)?.draw(in: backgroundPath, angle: -90)

ctx.saveGState()
ctx.setShadow(offset: .zero, blur: 70, color: white.withAlphaComponent(0.85).cgColor)
fill(white.withAlphaComponent(0.22), NSBezierPath(ovalIn: CGRect(x: 180, y: 180, width: 664, height: 664)))
ctx.restoreGState()

let tagCenter = CGPoint(x: 695, y: 470)
let tagRect = CGRect(x: tagCenter.x - 148, y: tagCenter.y - 192, width: 296, height: 384)
let tagAngle = -CGFloat.pi / 4.4

ctx.saveGState()
ctx.translateBy(x: tagCenter.x, y: tagCenter.y)
ctx.rotate(by: tagAngle)

let localTagRect = CGRect(x: -148, y: -192, width: 296, height: 384)
let localTagPath = roundedRect(localTagRect, radius: 44)
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -10), blur: 30, color: accentBlue.withAlphaComponent(0.28).cgColor)
fill(accentBlue, localTagPath)
ctx.restoreGState()
fill(accentBlue, localTagPath)

let hole = NSBezierPath(ovalIn: CGRect(x: -104, y: 106, width: 42, height: 42))
fill(bgTop, hole)

let paragraph = NSMutableParagraphStyle()
paragraph.alignment = .center
let hashtag = NSAttributedString(string: "#", attributes: [
    .font: NSFont.systemFont(ofSize: 240, weight: .black),
    .foregroundColor: white,
    .paragraphStyle: paragraph,
])
hashtag.draw(in: CGRect(x: -100, y: -105, width: 200, height: 220))

ctx.restoreGState()

stroke(nightBlue, lineWidth: 24) { path in
    path.move(to: CGPoint(x: 512, y: 292))
    path.line(to: CGPoint(x: 512, y: 742))
}

let holeCenter = pointRotatedAroundCenter(
    CGPoint(x: tagRect.minX + 65, y: tagRect.maxY - 65),
    center: tagCenter,
    angle: tagAngle
)

stroke(nightBlue, lineWidth: 18) { path in
    path.move(to: CGPoint(x: 512, y: 618))
    path.line(to: CGPoint(x: holeCenter.x - 6, y: holeCenter.y + 4))
}

stroke(nightBlue, lineWidth: 22) { path in
    path.move(to: CGPoint(x: 512, y: 660))
    path.curve(to: CGPoint(x: 360, y: 648),
               controlPoint1: CGPoint(x: 450, y: 660),
               controlPoint2: CGPoint(x: 402, y: 658))
    path.curve(to: CGPoint(x: 292, y: 565),
               controlPoint1: CGPoint(x: 332, y: 636),
               controlPoint2: CGPoint(x: 310, y: 594))
    path.curve(to: CGPoint(x: 244, y: 498),
               controlPoint1: CGPoint(x: 272, y: 545),
               controlPoint2: CGPoint(x: 246, y: 528))
    path.curve(to: CGPoint(x: 242, y: 356),
               controlPoint1: CGPoint(x: 238, y: 474),
               controlPoint2: CGPoint(x: 238, y: 412))
    path.line(to: CGPoint(x: 314, y: 356))
}

stroke(nightBlue, lineWidth: 18) { path in
    path.move(to: CGPoint(x: 326, y: 560))
    path.line(to: CGPoint(x: 512, y: 560))
}

stroke(nightBlue, lineWidth: 18) { path in
    path.move(to: CGPoint(x: 278, y: 482))
    path.curve(to: CGPoint(x: 422, y: 470),
               controlPoint1: CGPoint(x: 320, y: 470),
               controlPoint2: CGPoint(x: 374, y: 464))
    path.curve(to: CGPoint(x: 512, y: 474),
               controlPoint1: CGPoint(x: 456, y: 474),
               controlPoint2: CGPoint(x: 482, y: 474))
}

stroke(nightBlue, lineWidth: 18) { path in
    path.move(to: CGPoint(x: 290, y: 382))
    path.line(to: CGPoint(x: 512, y: 382))
}

stroke(nightBlue, lineWidth: 16) { path in
    path.move(to: CGPoint(x: 264, y: 582))
    path.curve(to: CGPoint(x: 304, y: 578),
               controlPoint1: CGPoint(x: 276, y: 588),
               controlPoint2: CGPoint(x: 294, y: 590))
}

stroke(nightBlue, lineWidth: 18) { path in
    path.move(to: CGPoint(x: 240, y: 356))
    path.curve(to: CGPoint(x: 242, y: 276),
               controlPoint1: CGPoint(x: 236, y: 332),
               controlPoint2: CGPoint(x: 236, y: 300))
    path.line(to: CGPoint(x: 314, y: 276))
    path.curve(to: CGPoint(x: 314, y: 356),
               controlPoint1: CGPoint(x: 314, y: 300),
               controlPoint2: CGPoint(x: 314, y: 330))
}

image.unlockFocus()

guard let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: Int(size),
    pixelsHigh: Int(size),
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .calibratedRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
) else {
    fatalError("Impossible de creer le bitmap d'export")
}

bitmap.size = NSSize(width: size, height: size)

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
image.draw(in: CGRect(x: 0, y: 0, width: size, height: size), from: .zero, operation: .copy, fraction: 1)
NSGraphicsContext.restoreGraphicsState()

guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Impossible de generer le PNG")
}

for path in outputPaths {
    try pngData.write(to: URL(fileURLWithPath: path), options: .atomic)
    print("Icone generee → \(path)")
}
