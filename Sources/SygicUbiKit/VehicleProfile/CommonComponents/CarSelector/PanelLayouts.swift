import Foundation
import UIKit
import FloatingPanel

// MARK: - FloatingPanelBottomLayout

class FloatingPanelBottomLayout: FloatingPanelLayout {
    public var position: FloatingPanelPosition { .bottom }
    public var initialState: FloatingPanelState { .half }

    private var rowHeight: CGFloat
    private var numberOfItems: Int
    private let extraPadding: CGFloat
    init(with rowHeight: CGFloat, numberOfItems: Int, extrapadding: CGFloat) {
        self.extraPadding = extrapadding
        self.rowHeight = rowHeight
        self.numberOfItems = numberOfItems
    }

    public var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        let absoluteHeight = CGFloat(numberOfItems) * rowHeight + 150
        if absoluteHeight > (UIApplication.shared.windows.first?.bounds.height)! {
            return [
                .full: FloatingPanelLayoutAnchor(absoluteInset: 64, edge: .top, referenceGuide: .safeArea),
                .half: FloatingPanelLayoutAnchor(absoluteInset: 64, edge: .top, referenceGuide: .safeArea),
                .tip: FloatingPanelLayoutAnchor(absoluteInset: 60, edge: .bottom, referenceGuide: .safeArea),
            ]
        } else {
            return [
                .half: FloatingPanelLayoutAnchor(absoluteInset: absoluteHeight + extraPadding, edge: .bottom, referenceGuide: .safeArea),
                .tip: FloatingPanelLayoutAnchor(absoluteInset: 150, edge: .bottom, referenceGuide: .safeArea),
            ]
        }
    }

    public func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        switch state {
        case .full, .half: return 0.5
        default: return 0.3
        }
    }
}
