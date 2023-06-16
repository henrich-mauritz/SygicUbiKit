//
//  TrafficInfoListMapItemsVC.swift
//  TrafficInfoSDK
//
//  Created by Juraj Antas on 03/05/2023.
//

import UIKit

class TrafficInfoListMapItemsViewController: BaseViewController {
    var stackView: UIStackView!
    
    var viewModel: [TrafficInfoData]
    
    var onCloseBlock: (() -> Void)?
    var onPresentDetail: ((_ model: TrafficInfoData) -> Void)?
    
    required init(model: [TrafficInfoData]) {
        self.viewModel = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let radius = 20.0
        let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [UIRectCorner.topLeft, UIRectCorner.topRight], cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        stackView.layer.mask = mask
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .clear
        
        stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 18
        stackView.backgroundColor = .clear
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 32, left: 0, bottom: 16, right: 0)
        stackView.backgroundColor = .backgroundPrimary
        view.addSubview(stackView)
        
        let handleView = UIView()
        handleView.translatesAutoresizingMaskIntoConstraints = false
        handleView.backgroundColor = .foregroundPrimary
        handleView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        handleView.heightAnchor.constraint(equalToConstant: 3).isActive = true
        handleView.layer.cornerRadius = 2
        view.addSubview(handleView)
        
        NSLayoutConstraint.activate([
            handleView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 6),
            handleView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        let topTitleLabel = UILabel.trConstructLabel(text: "Road events", font: .stylingFont(.bold, with: 16), color: .foregroundPrimary, alignment: .left)
        stackView.addArrangedSubview(topTitleLabel.embedInView(align: .center, padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)))
        
        let separator = UIView.trCreateSeparatorView(color: .backgroundTertiary)
        stackView.addArrangedSubview(separator.embedInView(align: .center, padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)))
        
        viewModel.forEach { data in
            let title = data.type.localizedString()
            let titleLabel = UILabel.trConstructLabel(text: title, font: .stylingFont(.bold, with: 16), color: .foregroundPrimary, alignment: .left)
            
            let stackRow1 = UIStackView()
            stackRow1.translatesAutoresizingMaskIntoConstraints = false
            stackRow1.axis = .horizontal
            stackRow1.spacing = 12
            
            let image = TrafficInfoMapItem.imageViewForType(type: data.type)
            image.setContentHuggingPriority(.required, for: .horizontal)
            image.setContentHuggingPriority(.required, for: .vertical)
            stackRow1.addArrangedSubview(image)
            stackRow1.addArrangedSubview(titleLabel)
            let model = data
            
            stackRow1.onTapped { [weak self] in
                guard let self = self else {return}
                self.closeAndPresent(model: model)
            }
            
            stackView.addArrangedSubview(stackRow1.embedInView(align: .center, padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)))
        }
        
        let closeButton = UIButton(type: .custom)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("trafficInfo.detail.close".localized.uppercased(), for: .normal)
        closeButton.titleLabel?.font = UIFont.stylingFont(.bold, with: 16)
        closeButton.setTitleColor(.foregroundSecondary, for: .normal)
        closeButton.backgroundColor = .backgroundSecondary
        closeButton.layer.cornerRadius = 16
        closeButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        closeButton.onTapped { [weak self] in
            guard let self = self else {return}
            self.dismiss(animated: true) {
                self.onCloseBlock?()
            }
        }
        
        stackView.addArrangedSubview(closeButton.embedInView(align: .natural, padding: UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)))
    }
    
    override func swipeDownDissmisEnded() -> Bool {
        self.onCloseBlock?()
        return true
    }
    
    func closeAndPresent(model: TrafficInfoData) {
        self.dismiss(animated: false) { [weak self] in
            guard let self = self else {return}
            self.onCloseBlock?()
            self.onPresentDetail?(model)
        }
    }
    
}

