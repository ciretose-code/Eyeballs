import AppKit

guard CommandLine.arguments.count > 1 else {
    print("Usage: swift generate_icon.swift <sf-symbol-name>")
    print("Example: swift generate_icon.swift eye")
    exit(1)
}

let symbolName = CommandLine.arguments[1]
let size = NSSize(width: 1024, height: 1024)
let config = NSImage.SymbolConfiguration(pointSize: 420, weight: .medium)

guard let symbol = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)?
    .withSymbolConfiguration(config) else {
    print("Error: SF Symbol '\(symbolName)' not found")
    exit(1)
}

let colors: [(name: String, color: NSColor)] = [
    ("black", .black),
    ("white", .white),
]

for (colorName, color) in colors {
    let image = NSImage(size: size, flipped: false) { _ in
        let symbolSize = symbol.size
        let symbolRect = NSRect(
            x: (size.width - symbolSize.width) / 2,
            y: (size.height - symbolSize.height) / 2,
            width: symbolSize.width,
            height: symbolSize.height
        )

        let tinted = NSImage(size: symbolSize, flipped: false) { tintRect in
            symbol.draw(in: tintRect)
            color.set()
            tintRect.fill(using: .sourceAtop)
            return true
        }
        tinted.draw(in: symbolRect, from: .zero, operation: .sourceOver, fraction: 1.0)
        return true
    }

    guard let tiffData = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
        print("Failed to create \(colorName) PNG")
        exit(1)
    }

    let filename = "\(symbolName)_\(colorName)_1024.png"
    try! pngData.write(to: URL(fileURLWithPath: filename))
    print("Saved \(filename)")
}
