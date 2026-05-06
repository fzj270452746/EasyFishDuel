import UIKit

/// 自定义带有点击动画和发光效果的按钮
class EasyButton: UIButton {
    
    /// 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    /// 初始化
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    /// 设置UI，玻璃质感发光效果
    private func setupUI() {
        self.backgroundColor = UIColor(white: 1.0, alpha: 0.25)
        self.layer.borderWidth = 1.5
        self.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        
        // 阴影发光效果
        self.layer.shadowColor = UIColor.white.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 0.6
        self.layer.shadowRadius = 8
        
        self.setTitleColor(.white, for: .normal)
        self.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .disabled)
    }
    
    /// 圆角处理
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.height / 2
    }
    
    /// 可用状态改变时，更新UI，使得不可点击状态区别更大
    override var isEnabled: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                if self.isEnabled {
                    self.alpha = 1.0
                    self.backgroundColor = UIColor(white: 1.0, alpha: 0.25)
                    self.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
                    self.layer.shadowOpacity = 0.6
                } else {
                    // 不可用状态：降低透明度，修改背景色更暗，去掉边框亮度和阴影发光
                    self.alpha = 0.3
                    self.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
                    self.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
                    self.layer.shadowOpacity = 0.0
                }
            }
        }
    }
    
    /// 点击缩放动画
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.92, y: 0.92) : .identity
                self.alpha = self.isHighlighted ? 0.8 : 1.0
            }
        }
    }
}
