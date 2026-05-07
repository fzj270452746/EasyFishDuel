import UIKit

// MARK: - Screen Metrics

let ScreenWidth  = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height
let DesignWidth: CGFloat = 375.0
let DesignHeight: CGFloat = 812.0

let ScaleFactor: CGFloat = min(ScreenWidth / DesignWidth, 1.5)
let HeightScaleFactor: CGFloat = min(ScreenHeight / DesignHeight, 1.5)

// MARK: - CGFloat scaling

extension CGFloat {
    var scaledW: CGFloat { self * ScaleFactor }
    var scaledF: CGFloat { self * ScaleFactor }
    var scaledH: CGFloat { self * HeightScaleFactor }
}

// MARK: - Int scaling

extension Int {
    var scaledW: CGFloat { CGFloat(self) * ScaleFactor }
    var scaledF: CGFloat { CGFloat(self) * ScaleFactor }
    var scaledH: CGFloat { CGFloat(self) * HeightScaleFactor }
}

// MARK: - Double scaling

extension Double {
    var scaledW: CGFloat { CGFloat(self) * ScaleFactor }
    var scaledF: CGFloat { CGFloat(self) * ScaleFactor }
    var scaledH: CGFloat { CGFloat(self) * HeightScaleFactor }
}

// MARK: - Device helpers (reserved for future adaptive layout)

enum DeviceClass {
    case compact
    case regular
    case large

    static var current: DeviceClass {
        if ScreenWidth >= 428 { return .large }
        if ScreenWidth >= 375 { return .regular }
        return .compact
    }

    var baseSpacing: CGFloat {
        switch self {
        case .compact: return 12
        case .regular: return 16
        case .large:   return 20
        }
    }
}

extension CGFloat {
    var adaptiveSpacing: CGFloat {
        self * DeviceClass.current.baseSpacing / 16
    }
}
