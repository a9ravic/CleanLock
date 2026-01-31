#!/usr/bin/env swift

import AppKit
import Foundation

// MARK: - Design System Colors (matching the app)

struct Colors {
    // Brand colors (blue)
    static let brand = NSColor(red: 0.35, green: 0.58, blue: 1.0, alpha: 1.0)
    static let brandLight = NSColor(red: 0.55, green: 0.73, blue: 1.0, alpha: 1.0)

    // Background colors (dark)
    static let controlBackground = NSColor(red: 0.16, green: 0.16, blue: 0.18, alpha: 1.0)
    static let windowBackground = NSColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0)
}

// MARK: - Icon Generator

func generateAppIcon(pixelSize: Int) -> NSImage {
    let size = CGFloat(pixelSize)

    // Create bitmap with exact pixel dimensions
    guard let bitmapRep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixelSize,
        pixelsHigh: pixelSize,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        return NSImage(size: NSSize(width: pixelSize, height: pixelSize))
    }

    // Set the size to match pixels (1:1 scale, not Retina)
    bitmapRep.size = NSSize(width: pixelSize, height: pixelSize)

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)

    guard let context = NSGraphicsContext.current?.cgContext else {
        NSGraphicsContext.restoreGraphicsState()
        return NSImage(size: NSSize(width: pixelSize, height: pixelSize))
    }

    let rect = CGRect(x: 0, y: 0, width: size, height: size)
    let cornerRadius = size * 0.22 // macOS icon corner radius

    // Create rounded rect path
    let path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)

    // 1. Draw white background
    context.saveGState()
    context.addPath(path)
    context.clip()

    let colorSpace = CGColorSpaceCreateDeviceRGB()

    // White background
    context.setFillColor(NSColor.white.cgColor)
    context.fill(rect)
    context.restoreGState()

    // 2. Draw subtle border
    context.saveGState()
    context.addPath(path)
    context.setStrokeColor(NSColor(white: 0.85, alpha: 1.0).cgColor)
    context.setLineWidth(max(0.5, size * 0.006))
    context.strokePath()
    context.restoreGState()

    // 3. Draw keyboard symbol with blue gradient
    let symbolPointSize = size * 0.50
    let symbolConfig = NSImage.SymbolConfiguration(pointSize: symbolPointSize, weight: .medium)

    if let keyboardSymbol = NSImage(systemSymbolName: "keyboard.fill", accessibilityDescription: nil)?
        .withSymbolConfiguration(symbolConfig) {

        // Get actual symbol size
        let symbolWidth = keyboardSymbol.size.width
        let symbolHeight = keyboardSymbol.size.height
        let symbolX = (size - symbolWidth) / 2
        let symbolY = (size - symbolHeight) / 2
        let symbolRect = NSRect(x: symbolX, y: symbolY, width: symbolWidth, height: symbolHeight)

        // Create gradient bitmap
        guard let gradientRep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: pixelSize,
            pixelsHigh: pixelSize,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        ) else {
            NSGraphicsContext.restoreGraphicsState()
            let image = NSImage(size: NSSize(width: pixelSize, height: pixelSize))
            image.addRepresentation(bitmapRep)
            return image
        }
        gradientRep.size = NSSize(width: pixelSize, height: pixelSize)

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: gradientRep)

        if let gradCtx = NSGraphicsContext.current?.cgContext {
            let brandColors = [
                Colors.brand.cgColor,
                Colors.brandLight.cgColor
            ] as CFArray
            if let brandGradient = CGGradient(colorsSpace: colorSpace, colors: brandColors, locations: [0, 1]) {
                gradCtx.drawLinearGradient(
                    brandGradient,
                    start: CGPoint(x: 0, y: size),
                    end: CGPoint(x: size, y: 0),
                    options: []
                )
            }
        }
        NSGraphicsContext.restoreGraphicsState()

        let gradientImage = NSImage(size: NSSize(width: pixelSize, height: pixelSize))
        gradientImage.addRepresentation(gradientRep)

        // Create mask bitmap with symbol
        guard let maskRep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: pixelSize,
            pixelsHigh: pixelSize,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        ) else {
            NSGraphicsContext.restoreGraphicsState()
            let image = NSImage(size: NSSize(width: pixelSize, height: pixelSize))
            image.addRepresentation(bitmapRep)
            return image
        }
        maskRep.size = NSSize(width: pixelSize, height: pixelSize)

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: maskRep)

        // Tint symbol to white and draw
        if let tintedSymbol = keyboardSymbol.copy() as? NSImage {
            tintedSymbol.lockFocus()
            NSColor.white.set()
            let imgRect = NSRect(origin: .zero, size: tintedSymbol.size)
            imgRect.fill(using: .sourceAtop)
            tintedSymbol.unlockFocus()
            tintedSymbol.draw(in: symbolRect, from: .zero, operation: .sourceOver, fraction: 1.0)
        }
        NSGraphicsContext.restoreGraphicsState()

        let maskImage = NSImage(size: NSSize(width: pixelSize, height: pixelSize))
        maskImage.addRepresentation(maskRep)

        // Create result bitmap
        guard let resultRep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: pixelSize,
            pixelsHigh: pixelSize,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        ) else {
            NSGraphicsContext.restoreGraphicsState()
            let image = NSImage(size: NSSize(width: pixelSize, height: pixelSize))
            image.addRepresentation(bitmapRep)
            return image
        }
        resultRep.size = NSSize(width: pixelSize, height: pixelSize)

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: resultRep)

        gradientImage.draw(in: rect, from: rect, operation: .sourceOver, fraction: 1.0)
        maskImage.draw(in: rect, from: rect, operation: .destinationIn, fraction: 1.0)

        NSGraphicsContext.restoreGraphicsState()

        let resultImage = NSImage(size: NSSize(width: pixelSize, height: pixelSize))
        resultImage.addRepresentation(resultRep)

        // Draw result onto main context
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
        resultImage.draw(in: rect, from: rect, operation: .sourceOver, fraction: 1.0)
    }

    NSGraphicsContext.restoreGraphicsState()

    let finalImage = NSImage(size: NSSize(width: pixelSize, height: pixelSize))
    finalImage.addRepresentation(bitmapRep)
    return finalImage
}

func saveImage(_ image: NSImage, to path: String, pixelSize: Int) {
    // Get the bitmap representation
    guard let rep = image.representations.first as? NSBitmapImageRep,
          let pngData = rep.representation(using: .png, properties: [:]) else {
        print("Failed to create PNG data for \(path)")
        return
    }

    do {
        try pngData.write(to: URL(fileURLWithPath: path))
        print("Generated: \(path) (\(pixelSize)x\(pixelSize))")
    } catch {
        print("Failed to write \(path): \(error)")
    }
}

// MARK: - Main

let scriptPath = CommandLine.arguments[0]
let scriptDir = (scriptPath as NSString).deletingLastPathComponent
let projectRoot = (scriptDir as NSString).deletingLastPathComponent
let iconsetPath = "\(projectRoot)/CleanLock/Resources/Assets.xcassets/AppIcon.appiconset"

print("Generating App Icons...")
print("Output directory: \(iconsetPath)")

// Icon sizes for macOS (actual pixel dimensions)
let sizes: [(name: String, pixels: Int, scale: String, displaySize: String)] = [
    ("icon_16x16", 16, "1x", "16x16"),
    ("icon_16x16@2x", 32, "2x", "16x16"),
    ("icon_32x32", 32, "1x", "32x32"),
    ("icon_32x32@2x", 64, "2x", "32x32"),
    ("icon_128x128", 128, "1x", "128x128"),
    ("icon_128x128@2x", 256, "2x", "128x128"),
    ("icon_256x256", 256, "1x", "256x256"),
    ("icon_256x256@2x", 512, "2x", "256x256"),
    ("icon_512x512", 512, "1x", "512x512"),
    ("icon_512x512@2x", 1024, "2x", "512x512")
]

// Generate icons
for (name, pixels, _, _) in sizes {
    let image = generateAppIcon(pixelSize: pixels)
    let path = "\(iconsetPath)/\(name).png"
    saveImage(image, to: path, pixelSize: pixels)
}

// Generate Contents.json
let contentsJson: [String: Any] = [
    "images": sizes.map { (name, _, scale, displaySize) in
        [
            "filename": "\(name).png",
            "idiom": "mac",
            "scale": scale,
            "size": displaySize
        ]
    },
    "info": [
        "author": "xcode",
        "version": 1
    ]
]

if let jsonData = try? JSONSerialization.data(withJSONObject: contentsJson, options: [.prettyPrinted, .sortedKeys]),
   let jsonString = String(data: jsonData, encoding: .utf8) {
    let contentsPath = "\(iconsetPath)/Contents.json"
    try? jsonString.write(toFile: contentsPath, atomically: true, encoding: .utf8)
    print("Generated: \(contentsPath)")
}

print("\nApp Icon generation complete!")
