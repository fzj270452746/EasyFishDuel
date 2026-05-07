import UIKit

// MARK: - GlintButton

class GlintButton: UIButton {

    private let normalAlpha: CGFloat = 0.25
    private let disabledAlpha: CGFloat = 0.3

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = UIColor(white: 1.0, alpha: normalAlpha)
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        layer.shadowColor = UIColor.white.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.6
        layer.shadowRadius = 8
        setTitleColor(.white, for: .normal)
        setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .disabled)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }

    override var isEnabled: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                if self.isEnabled {
                    self.alpha = 1.0
                    self.backgroundColor = UIColor(white: 1.0, alpha: self.normalAlpha)
                    self.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
                    self.layer.shadowOpacity = 0.6
                } else {
                    self.alpha = 0.3
                    self.backgroundColor = UIColor(white: 0.0, alpha: self.disabledAlpha)
                    self.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
                    self.layer.shadowOpacity = 0.0
                }
            }
        }
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {
                self.transform = self.isHighlighted
                    ? CGAffineTransform(scaleX: 0.92, y: 0.92)
                    : .identity
                self.alpha = self.isHighlighted ? 0.8 : 1.0
            }
        }
    }

    func pulseOnce() {
        UIView.animate(withDuration: 0.18, animations: {
            self.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
        }, completion: { _ in
            UIView.animate(withDuration: 0.18) {
                self.transform = .identity
            }
        })
    }
}

// MARK: - Badge Label (reserved for notification counts)

class BadgeLabel: UILabel {

    var badgeValue: Int = 0 {
        didSet {
            text = badgeValue > 0 ? "\(badgeValue)" : nil
            isHidden = badgeValue <= 0
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        backgroundColor = .systemRed
        textColor = .white
        font = UIFont.boldSystemFont(ofSize: 11)
        textAlignment = .center
        isHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        clipsToBounds = true
    }
}
