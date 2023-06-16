import UIKit

class CongratulationsViewCell: UITableViewCell, TripCongratulationsViewCellProtocol {
    static var cellHeight: CGFloat { 180 }

    var viewModel: TripDetailCongratulationsViewModelProtocol? {
        willSet {
            label1.text = newValue?.titleText
            label2.text = newValue?.score
            label3.text = newValue?.majorText
        }
    }

    private var mainStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 8
        view.alignment = .center
        view.distribution = .fillProportionally
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let cupContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return view
    }()
    
    private let lineView1: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundTertiary
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 1),
        ])
        return view
    }()
    
    private let lineView2: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundTertiary
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 1),
        ])
        return view
    }()
    
    private var cupImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "congratulations", in: .module, compatibleWith: nil))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        imageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return imageView
    }()
    
    private var label1: UILabel = {
        let label = UILabel()
        label.font = .stylingFont(.regular, with: 16)
        label.textColor = .foregroundPrimary
        label.textAlignment = .center
        return label
    }()

    private var label2: UILabel = {
        let label = UILabel()
        label.font = .stylingFont(.bold, with: 60)
        label.textColor = .foregroundPrimary
        label.textAlignment = .center
        return label
    }()

    private var label3: UILabel = {
        let label = UILabel()
        label.font = .stylingFont(.regular, with: 20)
        label.textColor = .foregroundPrimary
        label.textAlignment = .center
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        isUserInteractionEnabled = false
        contentView.cover(with: mainStackView)
        cupContainer.addSubview(lineView1)
        cupContainer.addSubview(cupImageView)
        cupContainer.addSubview(lineView2)
        
        mainStackView.addArrangedSubview(cupContainer)
        mainStackView.addArrangedSubview(label1)
        mainStackView.addArrangedSubview(label2)
        mainStackView.addArrangedSubview(label3)
        
        NSLayoutConstraint.activate([
            cupImageView.centerYAnchor.constraint(equalTo: cupContainer.centerYAnchor),
            cupImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            lineView1.centerYAnchor.constraint(equalTo: cupContainer.centerYAnchor),
            lineView1.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            lineView1.trailingAnchor.constraint(equalTo: cupImageView.leadingAnchor, constant: -12),
            lineView2.centerYAnchor.constraint(equalTo: cupContainer.centerYAnchor),
            lineView2.leadingAnchor.constraint(equalTo: cupImageView.trailingAnchor, constant: 12),
            lineView2.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
