import UIKit

class CopyrightFooterView: UIView {
    let label: UITextView = {
        let discreetColor = UIColor.foregroundPrimary.withAlphaComponent(0.4)
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.font = UIFont.stylingFont(.regular, with: 10)
        view.textColor = discreetColor
        view.tintColor = discreetColor
        view.isEditable = false
        view.isScrollEnabled = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.translatesAutoresizingMaskIntoConstraints = false
        cover(with: label, insets: NSDirectionalEdgeInsets(top: 20, leading: 32, bottom: 20, trailing: 32))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
