//
//  TrafficInfoFilterRow.swift
//  TrafficInfoSDK
//
//  Created by Juraj Antas on 03/11/2022.
//

import UIKit

protocol TrafficInfoFilterRowDelegate: AnyObject {
    func trafficInfoFilterRowStateChanged(type: TrafficInfoType, state: Bool)
}

class TrafficInfoFilterRow: UIView {
    weak var delegate: TrafficInfoFilterRowDelegate?
    let title: String
    let type: TrafficInfoType
    var selected: Bool
    
    var stackView: UIStackView!
    var titleLabel: UILabel!
    var switchView: UISwitch!
    var icon: UIImageView!
    
    required init(title: String, selected: Bool, type: TrafficInfoType, delegate: TrafficInfoFilterRowDelegate) {
        self.title = title
        self.delegate = delegate
        self.type = type
        self.selected = selected
        
        super.init(frame: .zero)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 16
        
        switchView = UISwitch()
        switchView.isOn = selected
        switchView.translatesAutoresizingMaskIntoConstraints = false
        switchView.onValueChanged { [weak self] view in
            guard let self = self else { return }
            self.delegate?.trafficInfoFilterRowStateChanged(type: self.type, state: self.switchView.isOn)
        }
        
        switch type {
        case .roadworks:
            icon = UIImageView(image: UIImage(named: "roadWorkIcon", in: .module, compatibleWith: nil))
        case .congestion:
            icon = UIImageView(image: UIImage(named: "congestionIcon", in: .module, compatibleWith: nil))
        case .accident:
            icon = UIImageView(image: UIImage(named: "roadAccidentIcon", in: .module, compatibleWith: nil))
        case .trafficIncident:
            icon = UIImageView(image: UIImage(named: "accidentsIcon", in: .module, compatibleWith: nil))
        case .roadCamera:
            icon = UIImageView(image: UIImage(named: "roadCameraIcon", in: .module, compatibleWith: nil))
        case .wind:
            icon = UIImageView(image: UIImage(named: "windIcon", in: .module, compatibleWith: nil))
        }
        
        let font = UIFont.stylingFont(.regular, with: 16)
        let color: UIColor = .foregroundPrimary
        
        titleLabel = UILabel.trConstructLabel(text: title, font: font, color: color, alignment: .left)
        
        icon.setContentHuggingPriority(.required, for: .horizontal)
        icon.setContentHuggingPriority(.required, for: .vertical)
        icon.setContentCompressionResistancePriority(.required, for: .horizontal)
        icon.setContentCompressionResistancePriority(.required, for: .vertical)
        
        stackView.addArrangedSubviews([icon, titleLabel, switchView])
        
        addSubviews([stackView])
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    func setSelected(_ selected: Bool) {
        if selected {
            self.switchView.isSelected = true
        }
        else {
            self.switchView.isSelected = false
        }
    }

}
