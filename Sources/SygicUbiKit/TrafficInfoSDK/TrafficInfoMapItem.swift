//
//  TrafficInfoMapItem.swift
//  TrafficInfoSDK
//
//  Created by Juraj Antas on 25/10/2022.
//

import MapKit

final class TrafficInfoMapItem: MKPointAnnotation {
    var type: TrafficInfoType
    var index: Int
    
    init(coordinate: CLLocationCoordinate2D, type: TrafficInfoType, index: Int) {
        self.type = type
        self.index = index
        super.init()
        self.coordinate = coordinate
    }

    class func imageForType(type: TrafficInfoType) -> UIImage {
        var image: UIImage?
        switch type {
        case .roadworks:
            image = UIImage(named: "roadWorkIcon", in: .module, compatibleWith: nil)
        case .congestion:
            image = UIImage(named: "congestionIcon", in: .module, compatibleWith: nil)
        case .accident:
            image = UIImage(named: "roadAccidentIcon", in: .module, compatibleWith: nil)
        case .trafficIncident:
            image = UIImage(named: "accidentsIcon", in: .module, compatibleWith: nil)
        case .roadCamera:
            image = UIImage(named: "roadCameraIcon", in: .module, compatibleWith: nil)
        case .wind:
            image = UIImage(named: "windIcon", in: .module, compatibleWith: nil)
        }
        
        if image == nil {
            image = UIImage()
        }
        
        return image!
    }
    
    class func imageViewForType(type: TrafficInfoType) -> UIImageView {
        let image = self.imageForType(type: type)
        return UIImageView(image: image)
    }
}

final class TrafficInfoMapItemAnnotationView: MKAnnotationView {
    
    static var reuseIdentifier: String {
        return "TrafficInfoMapItemAnnotationView"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
            
            if selected {
                // animate the annotation view
                if animated {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
                    })
                } else {
                    self.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
                }
            } else {
                // return to the original state
                if animated {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.transform = CGAffineTransform.identity
                    })
                } else {
                    self.transform = CGAffineTransform.identity
                }
            }
        }

}
final class TrafficInfoClusterAnnotationView: MKAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        displayPriority = .defaultHigh
        collisionMode = .circle
        centerOffset = CGPoint(x: 0, y: -10) // Offset center point to animate better with marker annotations
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static var reuseIdentifier: String {
        return "TrafficInfoClusterAnnotationView"
    }
        
    override var annotation: MKAnnotation? {
        willSet {
            if let cluster = newValue as? MKClusterAnnotation {
//                let counts = cluster.memberAnnotations.reduce(into: [:]) { counts, object in
//                    counts[(object as! TrafficInfoMapItem).type, default: 0] += 1
//                }
                let count = cluster.memberAnnotations.count
                
                
                let renderSize: CGSize
                
                if count == 3 || count == 2 {
                    renderSize = CGSize(width: 75, height: 75)
                }
                else if count > 3 {
                    renderSize = CGSize(width: 56, height: 56)
                }
                else {
                    //pre uplnost, ale realne sa toto nesmie stat, lebo cluster nemoze mat 1 polozku.
                    //ale clovek nikdy nevie, a aj apple sa moze utat.
                    renderSize = CGSize(width: 75, height: 75)
                }
                
                let renderer = UIGraphicsImageRenderer(size: renderSize)
                
                image = renderer.image { _ in
                    //kresli 56x56 biely s cervenym cislom v strede
                    if count > 3 {
                        //okraj
                        UIColor.black.withAlphaComponent(0.15).setFill()
                        UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: renderSize.width, height: renderSize.height)).fill()
                        //biely stred
                        UIColor.white.setFill()
                        UIBezierPath(ovalIn: CGRect(x: 1, y: 1, width: renderSize.width-2, height: renderSize.height-2)).fill()
                        // Finally draw count text vertically and horizontally centered
                        let attributes = [ NSAttributedString.Key.foregroundColor: UIColor.actionPrimary,
                                           NSAttributedString.Key.font: UIFont.stylingFont(.bold, with: 16)]
                        let text = "\(count)"
                        let size = text.size(withAttributes: attributes)
                        let rect = CGRect(x: (renderSize.width - size.width) / 2, y: (renderSize.height - size.height) / 2, width: size.width, height: size.height)
                        text.draw(in: rect, withAttributes: attributes)
                    }
                    else {
                        //kresli 75x75, a ikony v strede podla typu
                        UIColor.black.withAlphaComponent(0.15).setFill()
                        UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: renderSize.width, height: renderSize.height)).fill()
                        //biely stred
                        UIColor.white.setFill()
                        UIBezierPath(ovalIn: CGRect(x: 1, y: 1, width: renderSize.width-2, height: renderSize.height-2)).fill()
                        //ikony
                        //mozu byt 2 varianty..2 ikony a 3 ikony
                        if count == 3 {
                            //prvy obrazok
                            let i1 = cluster.memberAnnotations[0]
                            let image = TrafficInfoMapItem.imageForType(type: (i1 as! TrafficInfoMapItem).type)
                            
                            UIColor.white.setFill()
                            UIBezierPath(ovalIn: CGRect(x: 6, y: 11, width: 34, height: 34)).fill()
                            
                            image.draw(in: CGRect(origin: CGPoint(x: 8, y: 13), size: CGSize(width: 30, height: 30)), blendMode: .normal, alpha: 1.0)
                            
                            //druhy obrazok
                            let i2 = cluster.memberAnnotations[1]
                            let image2 = TrafficInfoMapItem.imageForType(type: (i2 as! TrafficInfoMapItem).type)
                            
                            UIColor.white.setFill()
                            UIBezierPath(ovalIn: CGRect(x: 35, y: 11, width: 34, height: 34)).fill()
            
                            image2.draw(in: CGRect(origin: CGPoint(x: 37, y: 13), size: CGSize(width: 30, height: 30)), blendMode: .normal, alpha: 1.0)
                            
                            //treti obrazok
                            let i3 = cluster.memberAnnotations[2]
                            let image3 = TrafficInfoMapItem.imageForType(type: (i3 as! TrafficInfoMapItem).type)
                            
                            UIColor.white.setFill()
                            UIBezierPath(ovalIn: CGRect(x: 20, y: 37, width: 34, height: 34)).fill()
                            
                            image3.draw(in: CGRect(origin: CGPoint(x: 22, y: 39), size: CGSize(width: 30, height: 30)), blendMode: .normal, alpha: 1.0)
                        }
                    }
                    
                    if count == 2 {
                        //prvy obrazok
                        let i1 = cluster.memberAnnotations[0]
                        let image = TrafficInfoMapItem.imageForType(type: (i1 as! TrafficInfoMapItem).type)
                        
                        UIColor.white.setFill()
                        UIBezierPath(ovalIn: CGRect(x: 6, y: 21, width: 34, height: 34)).fill()
                        
                        image.draw(in: CGRect(origin: CGPoint(x: 8, y: 23), size: CGSize(width: 30, height: 30)), blendMode: .normal, alpha: 1.0)
                        //druhy obrazok
                        let i2 = cluster.memberAnnotations[1]
                        let image2 = TrafficInfoMapItem.imageForType(type: (i2 as! TrafficInfoMapItem).type)
                        
                        UIColor.white.setFill()
                        UIBezierPath(ovalIn: CGRect(x: 35, y: 21, width: 34, height: 34)).fill()
                        
                        image2.draw(in: CGRect(origin: CGPoint(x: 37, y: 23), size: CGSize(width: 30, height: 30)), blendMode: .normal, alpha: 1.0)
                    }
                    else
                    {
                        //tu sa dostanem dost casto, nie je mi jasne preco.
                    }
                    
                }
            }
        }
    }
    
}
