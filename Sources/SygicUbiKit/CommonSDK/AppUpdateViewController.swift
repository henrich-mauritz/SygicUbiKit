import UIKit

// MARK: - AppUpdateViewController

public class AppUpdateViewController: UIViewController {
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func loadView() {
        self.view = AppUpdateView(frame: .zero)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        guard let view = self.view as? AppUpdateView else {
            return
        }
        view.updateButton.addTarget(self, action: #selector(AppUpdateViewController.goToStore), for: .touchUpInside)
    }
    
    @objc private func goToStore() {
        guard let appStoreUrl = UIApplication.appStoreUrl else { return }
        UIApplication.shared.canOpenURL(appStoreUrl)
        UIApplication.shared.open(appStoreUrl)
    }
    
}

// MARK: - AppUpdateView

class AppUpdateView: UIView {
    private lazy var imageView: UIImageView = {
        let image = UIImage(named: "update", in: .module, compatibleWith: nil)
        let iv = UIImageView(image: image)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        return iv
    }()

     lazy var updateButton: StylingButton = {
        let button = StylingButton.button(with: .normal)
         button.titleLabel.text = "common.appUpdate.buttonUpdate".localized
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 230).isActive = true
        return button
    }()

    private lazy var descriptionText: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.regular, with: 14)
        label.numberOfLines = 0
        label.textColor = .foregroundPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "common.appUpdate.description".localized
        label.textAlignment = .center
        return label
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.thin, with: 30)
        label.numberOfLines = 1
        label.textColor = .foregroundPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "common.appUpdate.title".localized
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        backgroundColor = .backgroundPrimary
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(imageView)
        addSubview(updateButton)
        addSubview(descriptionText)
        addSubview(titleLabel)
        var constraints: [NSLayoutConstraint] = []
        constraints.append(imageView.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(imageView.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(imageView.topAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.topAnchor, constant: 100))
        constraints.append(imageView.topAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.topAnchor, constant: 10))
        constraints.append(updateButton.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(updateButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -64))
        constraints.append(descriptionText.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 60))
        constraints.append(descriptionText.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -60))
        constraints.append(descriptionText.bottomAnchor.constraint(equalTo: updateButton.topAnchor, constant: -27))
        constraints.append(titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(titleLabel.bottomAnchor.constraint(equalTo: descriptionText.topAnchor, constant: -27))
        let titleTopConstraint = titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -27)
        titleTopConstraint.priority = .defaultLow
        constraints.append(titleTopConstraint)
        NSLayoutConstraint.activate(constraints)
        imageView.addConstraint(NSLayoutConstraint(item: imageView,
                                                   attribute: .height,
                                                   relatedBy: .equal,
                                                   toItem: imageView,
                                                   attribute: .width,
                                                   multiplier: imageView.bounds.width / imageView.bounds.height,
                                                   constant: 0))
    }
    
}
