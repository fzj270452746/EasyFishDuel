import UIKit

/// 屏幕宽度
let kScreenWidth = UIScreen.main.bounds.width
/// 屏幕高度
let kScreenHeight = UIScreen.main.bounds.height
/// 设计稿宽度 (以 iPhone 8/X/11 Pro 为基准)
let kDesignWidth: CGFloat = 375.0

/// 屏幕缩放比例，做最大限制防止在 iPad 上元素过大
let kScaleFactor: CGFloat = min(kScreenWidth / kDesignWidth, 1.5)

/// 屏幕适配工具扩展，模拟 flutter_screenutil 的 .w 和 .sp
extension CGFloat {
    /// 宽度适配
    var w: CGFloat {
        return self * kScaleFactor
    }
    /// 字体大小适配 (通常与宽度适配一致)
    var sp: CGFloat {
        return self * kScaleFactor
    }
}

extension Int {
    /// 宽度适配
    var w: CGFloat {
        return CGFloat(self) * kScaleFactor
    }
    /// 字体大小适配
    var sp: CGFloat {
        return CGFloat(self) * kScaleFactor
    }
}

extension Double {
    /// 宽度适配
    var w: CGFloat {
        return CGFloat(self) * kScaleFactor
    }
    /// 字体大小适配
    var sp: CGFloat {
        return CGFloat(self) * kScaleFactor
    }
}
