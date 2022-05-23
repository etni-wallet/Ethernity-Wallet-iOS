// Copyright © 2019 Stormbird PTE. LTD.

import Foundation
import UIKit

class SuccessOverlayView: UIView {
    
    static func show(message: String? = nil) {
        let view = SuccessOverlayView(frame: UIScreen.main.bounds)
        view.show(message: message)
    }

    private let imageView = UIImageView(image: R.image.ethCloudSuccessOverlay()!)
    private let messageLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

//        let blurEffect = UIBlurEffect(style: .extraLight)
//        let blurView = UIVisualEffectView(effect: blurEffect)
//        blurView.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(blurView)
//        blurView.alpha = 0.3
        backgroundColor = .white
        alpha = 0.7
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(messageLabel)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hide))
        addGestureRecognizer(tapGestureRecognizer)

        NSLayoutConstraint.activate([
//            blurView.anchorsConstraint(to: self),

            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            messageLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 21),
            messageLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func hide() {
        removeFromSuperview()
    }

    func show(message: String? = nil) {
        messageLabel.attributedText = getAttributedStringFor(message: message)
        
        imageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        messageLabel.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        UIApplication.shared.firstKeyWindow?.addSubview(self)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 7, options: .curveEaseInOut, animations: {
            self.imageView.transform = .identity
            self.messageLabel.transform = .identity
            self.alpha = 1.0
        })

        UINotificationFeedbackGenerator.show(feedbackType: .success)

        hideAfterAWhile()
    }

    private func hideAfterAWhile() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let strongSelf = self else { return }
            guard strongSelf.superview != nil else { return }
            UIView.animate(withDuration: 0.3, animations: {
                strongSelf.alpha = 0
            }, completion: { _ in
                strongSelf.hide()
            })
        }
    }
    
    fileprivate func getAttributedStringFor(message: String?) -> NSAttributedString {
        guard let string = message else {return NSAttributedString()}
        let attributeString = NSMutableAttributedString(string: string)
        let style = NSMutableParagraphStyle()
        style.alignment = .center

        attributeString.addAttributes([
            .paragraphStyle: style,
            .font: Screen.Backup.subtitleFont,
            .foregroundColor: R.color.electricBlueLightest()!
        ], range: NSRange(location: 0, length: string.count))
        
        return attributeString
    }
}
