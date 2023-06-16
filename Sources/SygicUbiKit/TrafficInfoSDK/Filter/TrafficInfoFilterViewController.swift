//
//  TrafficInfoFilterViewController.swift
//  TrafficInfoSDK
//
//  Created by Juraj Antas on 02/11/2022.
//

import UIKit

protocol TrafficInfoFilterViewControllerDelegate: AnyObject {
    func filterSelectionChanged()
}

class TrafficInfoFilterViewController: UIViewController, TrafficInfoFilterRowDelegate {
    var stackView: UIStackView!
    var applyButton: UIButton!
    weak var delegate: TrafficInfoFilterViewControllerDelegate?
    var rows: [TrafficInfoFilterRow] = []
    var viewModel: TrafficInfoFilterModel
    
    required init(model: TrafficInfoFilterModel, delegate: TrafficInfoFilterViewControllerDelegate) {
        self.delegate = delegate
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
        stackView.spacing = 16
        stackView.backgroundColor = .clear
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 32, left: 16, bottom: 16, right: 16)
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
        
        let titleLabel = UILabel.trConstructLabel(text: "trafficInfo.filter.title".localized, font: .stylingFont(.bold, with: 16), color: .foregroundPrimary, alignment: .left)
        stackView.addArrangedSubview(titleLabel)
        
        let separator = UIView.trCreateSeparatorView(color: .backgroundTertiary)
        stackView.addArrangedSubview(separator)
        
        for (index, item) in viewModel.model.enumerated() {
            let row = TrafficInfoFilterRow(title: item.title, selected: item.state, type: item.type, delegate: self)
            stackView.addArrangedSubview(row)
            if index != viewModel.model.count-1 {
                stackView.setCustomSpacing(12, after: row)
            }
        }
    }
    
    //MARK: Branch row delegate
    func trafficInfoFilterRowStateChanged(type: TrafficInfoType, state: Bool) {
        viewModel.updateModel(type: type, state: state)
        delegate?.filterSelectionChanged()
    }
    
}
