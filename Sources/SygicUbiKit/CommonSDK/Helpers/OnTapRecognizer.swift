import UIKit

typealias OnTapClosure = (UITapGestureRecognizer) -> Void

enum VoidResult {
    case success
    case failure
}

extension Result where Success == Void {
    static var success: Result {
        return .success(())
    }
}

@objc class ClosureSleeve: NSObject {
    let closure: (UIView) -> Void
    let sender: UIView
    init(_ closure: @escaping (UIView) -> Void, sender: UIView) {
        self.closure = closure
        self.sender = sender
    }
    @objc func invoke() {
        closure(sender)
    }
}

final class OnTapGestureRecognizer: UITapGestureRecognizer {
    private var closure: OnTapClosure
    var event: UIEvent?
    var touches: Set<UITouch>?
    
    init(closure: @escaping OnTapClosure) {
        self.closure = closure
        super.init(target: nil, action: nil)
        self.addTarget(self, action: #selector(execute))
    }
    
    @objc private func execute() {
        closure(self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        self.touches = touches
        self.event = event
    }
}

extension UISwitch {
    private func addAction(for controlEvent: UIControl.Event = .touchUpInside, _ closure: @escaping (UIView) -> Void) {
        
        let sleeve = ClosureSleeve(closure, sender: self)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvent)
        objc_setAssociatedObject(self, "\(UUID())", sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
    
    public func onValueChanged(closure: @escaping (UIView) -> Void) {
        addAction(for: .valueChanged, closure)
    }
    
}

extension UIPageControl {
    private func addAction(for controlEvent: UIControl.Event = .touchUpInside, _ closure: @escaping (UIView) -> Void) {
        let sleeve = ClosureSleeve(closure, sender: self)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvent)
        objc_setAssociatedObject(self, "\(UUID())", sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
    
    func onValueChanged(closure: @escaping (UIView) -> Void) {
        addAction(for: .valueChanged, closure)
    }
    
}

extension UIView {
    public func onTapped(_ closure: @escaping (UITapGestureRecognizer) -> Void) {
        let tapHandler = OnTapGestureRecognizer{
            closure($0)
        }
        self.addGestureRecognizer(tapHandler)
    }
    
    public func onTapped(_ closure: @escaping () -> Void) {
        let tapHandler = OnTapGestureRecognizer{ _ in
            closure()
        }
        self.addGestureRecognizer(tapHandler)
    }
    
}

