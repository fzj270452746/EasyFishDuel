import UIKit

// MARK: - Common UI Factory

enum UIViewFactory {

    static func makeBackgroundImageView() -> UIImageView {
        let v = UIImageView()
        v.image = UIImage(named: "easyImage")
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        return v
    }

    static func makeBackButton(target: Any?, action: Selector) -> UIButton {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor(white: 1.0, alpha: 0.25)
        b.layer.cornerRadius = 20.scaledW
        b.layer.borderWidth = 1.5
        b.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        b.layer.shadowColor = UIColor.white.cgColor
        b.layer.shadowOpacity = 0.5
        b.layer.shadowOffset = .zero
        b.layer.shadowRadius = 5
        b.addTarget(target, action: action, for: .touchUpInside)
        return b
    }

    static func makePageTitleLabel(text: String, size: CGFloat = 30) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = UIFont.systemFont(ofSize: size.scaledF, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        l.shadowColor = .black
        l.shadowOffset = CGSize(width: 1, height: 1)
        return l
    }

    static func makeGlassContainer(cornerRadius: CGFloat = 20, alpha: CGFloat = 0.6) -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(alpha)
        v.layer.cornerRadius = cornerRadius.scaledW
        v.layer.borderWidth = 1.5
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return v
    }

    static func makeEmptyHintLabel(text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = UIFont.systemFont(ofSize: 20.scaledF, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.8)
        l.textAlignment = .center
        l.numberOfLines = 0
        l.isHidden = true
        return l
    }
}

// MARK: - Layout Helpers

extension UIView {

    func pinEdgesToSuperview(insets: UIEdgeInsets = .zero) {
        guard let sv = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: sv.topAnchor, constant: insets.top),
            bottomAnchor.constraint(equalTo: sv.bottomAnchor, constant: -insets.bottom),
            leadingAnchor.constraint(equalTo: sv.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: sv.trailingAnchor, constant: -insets.right)
        ])
    }

    func centerInSuperview() {
        guard let sv = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: sv.centerXAnchor),
            centerYAnchor.constraint(equalTo: sv.centerYAnchor)
        ])
    }

    func applyGlowBorder(color: UIColor = .white, width: CGFloat = 1.5, shadowRadius: CGFloat = 5) {
        layer.borderWidth = width
        layer.borderColor = color.withAlphaComponent(0.8).cgColor
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = .zero
        layer.shadowRadius = shadowRadius
    }
}

// MARK: - Animation Helpers (reserved for future use)

enum AnimationPreset {
    case springEntrance
    case fadeIn
    case slideUp

    var duration: TimeInterval {
        switch self {
        case .springEntrance: return 0.5
        case .fadeIn:         return 0.3
        case .slideUp:        return 0.4
        }
    }

    var damping: CGFloat {
        switch self {
        case .springEntrance: return 0.7
        case .fadeIn:         return 1.0
        case .slideUp:        return 0.8
        }
    }
}

extension UIView {
    func playPreset(_ preset: AnimationPreset, delay: TimeInterval = 0) {
        switch preset {
        case .springEntrance:
            transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            alpha = 0
            UIView.animate(withDuration: preset.duration, delay: delay,
                           usingSpringWithDamping: preset.damping,
                           initialSpringVelocity: 0.5, options: .curveEaseOut) {
                self.transform = .identity
                self.alpha = 1
            }
        case .fadeIn:
            alpha = 0
            UIView.animate(withDuration: preset.duration, delay: delay) {
                self.alpha = 1
            }
        case .slideUp:
            transform = CGAffineTransform(translationX: 0, y: 60)
            alpha = 0
            UIView.animate(withDuration: preset.duration, delay: delay,
                           usingSpringWithDamping: preset.damping,
                           initialSpringVelocity: 0.5, options: .curveEaseOut) {
                self.transform = .identity
                self.alpha = 1
            }
        }
    }
}
