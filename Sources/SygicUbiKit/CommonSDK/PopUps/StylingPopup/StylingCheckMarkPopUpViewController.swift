import UIKit

// MARK: - StylingCheckMarkPopUpViewModelDataType

public protocol StylingCheckMarkPopUpViewModelDataType: StylingPopUpViewModelDataType {
    var checkmarkIsOn: Bool { get set }
}

// MARK: - StylingCheckMarkPopUpViewModel

public class StylingCheckMarkPopUpViewModel: StylingPopUpViewModel, StylingCheckMarkPopUpViewModelDataType {
    public var checkmarkIsOn: Bool = false
}

// MARK: - StylingCheckMarkPopUpViewController

open class StylingCheckMarkPopUpViewController: StylingPopupViewController {
    public lazy var checkmarkView: CheckmarkView = {
        let view = CheckmarkView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let labelCheckContainerView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    override open func configure(with viewModel: StylingPopUpViewModelDataType?) {
        super.configure(with: viewModel)
        guard let vm = viewModel as? StylingCheckMarkPopUpViewModelDataType else {
            return
        }
        checkmarkView.isSelected = vm.checkmarkIsOn
        toggleActionButton(enabled: vm.checkmarkIsOn)
    }

    override open func setupLayout(on baseView: UIView) {
        //super.setupLayout(on: baseView)
        
        
        //TODO: pre kratkost casu prenasam z base view constrainty tu. a vyhadzujem tie ktore netreba. tato zdedena trieda nemohla nikdy fungovat spravne bez layout warningov. to nikomu nikdy nevadilo?
        
        baseView.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        bubble.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.setContentCompressionResistancePriority(UILayoutPriority(900), for: .vertical)
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        subtitleLabel.setContentHuggingPriority(.required, for: .vertical)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        

        buttonsStack.axis = .vertical
        buttonsStack.spacing = 16
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        if let viewModel = viewModel {
            if viewModel.actionButtonTitle != nil {
                buttonsStack.addArrangedSubview(settingsButton)
            }
            if viewModel.cancelButtonTitle != nil {
                buttonsStack.addArrangedSubview(cancelButton)
            }
        } else {
            buttonsStack.addArrangedSubview(settingsButton)
            buttonsStack.addArrangedSubview(cancelButton)
        }

        baseView.addSubview(bubble)
        bubble.addSubview(imageView)
        bubble.addSubview(titleLabel)
        bubble.addSubview(subtitleLabel)
        bubble.addSubview(buttonsStack)

        //Portrait Constraints
        var constraints = [NSLayoutConstraint]()
        constraints.append(bubble.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 30))
        constraints.append(bubble.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -30))
        constraints.append(bubble.centerYAnchor.constraint(equalTo: baseView.centerYAnchor))
        constraints.append(bubble.topAnchor.constraint(greaterThanOrEqualTo: baseView.topAnchor, constant: 56))
        constraints.append(bubble.bottomAnchor.constraint(lessThanOrEqualTo: baseView.bottomAnchor, constant: -56))
        
        constraints.append(imageView.topAnchor.constraint(equalTo: bubble.topAnchor, constant: imageView.image == nil ? 0 : 32))
        constraints.append(imageView.leadingAnchor.constraint(greaterThanOrEqualTo: bubble.leadingAnchor, constant: 20))
        constraints.append(imageView.trailingAnchor.constraint(greaterThanOrEqualTo: bubble.trailingAnchor, constant: -20))
        constraints.append(imageView.centerXAnchor.constraint(equalTo: bubble.centerXAnchor))
        imageHeightConstraint = imageView.heightAnchor.constraint(greaterThanOrEqualToConstant: imageView.image == nil ? 0 : 100)
        constraints.append(imageHeightConstraint!)
        constraints.append(imageViewTitleConstraint)
        
        constraints.append(titleLabel.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 32))
        constraints.append(titleLabel.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -32))
//        constraints.append(titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -20))
        
//        constraints.append(subtitleLabel.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 43))
//        constraints.append(subtitleLabel.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -43))
//        constraints.append(subtitleLabel.bottomAnchor.constraint(equalTo: buttonsStack.topAnchor, constant: -20))
//        constraints.append(subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bubble.bottomAnchor, constant: -32))
        
        constraints.append(buttonsStack.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 43))
        constraints.append(buttonsStack.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -43))
        constraints.append(buttonsStack.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -30))
    
        
        //---nove---
        subtitleLabel.textAlignment = .left
        labelCheckContainerView.addSubview(checkmarkView)
        labelCheckContainerView.addSubview(subtitleLabel)
        bubble.addSubview(labelCheckContainerView)
        
        constraints.append(checkmarkView.leadingAnchor.constraint(equalTo: labelCheckContainerView.leadingAnchor))
        constraints.append(checkmarkView.topAnchor.constraint(equalTo: labelCheckContainerView.topAnchor))
    
        checkmarkView.setContentCompressionResistancePriority(.required, for: .horizontal)
        subtitleLabel.setContentCompressionResistancePriority(.defaultHigh-1, for: .horizontal)
        
        constraints.append(subtitleLabel.leadingAnchor.constraint(equalTo: checkmarkView.trailingAnchor, constant: 12))
        constraints.append(subtitleLabel.trailingAnchor.constraint(equalTo: labelCheckContainerView.trailingAnchor))
        constraints.append(subtitleLabel.topAnchor.constraint(equalTo: labelCheckContainerView.topAnchor))
        constraints.append(subtitleLabel.bottomAnchor.constraint(equalTo: labelCheckContainerView.bottomAnchor))
        constraints.append(titleLabel.bottomAnchor.constraint(equalTo: labelCheckContainerView.topAnchor, constant: -24))
        constraints.append(labelCheckContainerView.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 30))
        constraints.append(labelCheckContainerView.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -30))
        constraints.append(labelCheckContainerView.bottomAnchor.constraint(equalTo: buttonsStack.topAnchor, constant: -24))
        NSLayoutConstraint.activate(constraints)
        checkmarkView.addTarget(self, action: #selector(StylingCheckMarkPopUpViewController.toggleCheckMark), for: .touchUpInside)
        
        //----------
        
        portraitConstraints = constraints
        NSLayoutConstraint.activate(portraitConstraints)
        if buttonsStack.arrangedSubviews.count == 0 {
            buttonsStack.removeFromSuperview()
        }
        
        baseView.setNeedsLayout()
    }

    @objc
private func toggleCheckMark() {
        guard var viewModel = self.viewModel as? StylingCheckMarkPopUpViewModelDataType else {
            return
        }

        viewModel.checkmarkIsOn = !viewModel.checkmarkIsOn
        toggleActionButton(enabled: viewModel.checkmarkIsOn)
    }

    private func toggleActionButton(enabled: Bool) {
        settingsButton.isEnabled = enabled
    }
}
