import MapKit
import UIKit

// MARK: - TriplogMapView

public class TriplogMapView: UIView, TriplogMapViewProtocol {
    public weak var delegate: TriplogMapViewDelegate?

    private var map: MKMapView

    private var reportAnnotation: TriplogReportAnnotation? {
        didSet {
            guard let annotation = reportAnnotation else { return }
            delegate?.reportAnnotationPlaced(coord: annotation.coordinate)
            guard let oldAnnotation = oldValue else { return }
            map.removeAnnotation(oldAnnotation)
        }
    }

    override public var isUserInteractionEnabled: Bool {
        didSet {
            map.isUserInteractionEnabled = isUserInteractionEnabled
        }
    }

    public var isReportMap: Bool = false
    public var viewModel: TripDetailReportViewModelProtocol?

    override init(frame: CGRect) {
        map = MKMapView(frame: frame)
        super.init(frame: frame)
        map.isUserInteractionEnabled = false
        map.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(mapTapped(_:)))
        map.addGestureRecognizer(tap)
        cover(with: map, toSafeArea: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func addPolyline(with coordinates: [CLLocationCoordinate2D]) {
        let polyline = TriplogPolyline(coordinates: coordinates, count: coordinates.count)
        map.addOverlay(polyline)
    }

    public func setVisibleArea(coordinates: [CLLocationCoordinate2D], margins: UIEdgeInsets, animated: Bool = false) {
        let rects = coordinates.map { MKMapRect(origin: MKMapPoint($0), size: MKMapSize()) }
        let fittingRect = rects.reduce(MKMapRect.null) { $0.union($1) }
        map.setVisibleMapRect(fittingRect,
                              edgePadding: margins,
                              animated: animated)
    }

    public func addStartEndPinsOnMap(coordinates: [CLLocationCoordinate2D]?) {
        guard let coordinates = coordinates,
            let first = coordinates.first,
            let last = coordinates.last else { return }
        let start = TriplogAnnotation(coordinate: first)
        start.annotationType = .start
        start.iconColor = .mapRoute

        let end = TriplogAnnotation(coordinate: last)
        end.annotationType = .end
        end.iconColor = .mapRoute
        map.addAnnotations([start, end])
    }

    public func addEventPins(with type: EventType, items: [TripDetailEvent], withPolyline: Bool, animated: Bool = false) {
        var pins = [MKAnnotation]()
        for item in items {
            if withPolyline {
                let baseline = TriplogPolyline(coordinates: item.coordinates, count: item.coordinates.count)
                baseline.stroke = 4
                baseline.lineColor = .backgroundPrimary
                let eventline = TriplogPolyline(coordinates: item.coordinates, count: item.coordinates.count)
                eventline.stroke = 4
                eventline.lineColor = type.eventColor(with: item.severityLevel)
                eventline.event = item
                eventline.eventType = type
                map.addOverlay(baseline)
                map.addOverlay(eventline)
            }
            if type != .speeding {
                let annotation = TriplogEventAnnotation(eventData: item, type: type)
                annotation.annotationType = .event
                annotation.animate = animated
                pins.append(annotation)
            }
        }
        map.addAnnotations(pins)
    }

    public func removeAllMapObjects() {
        map.removeAnnotations(map.annotations)
        map.removeOverlays(map.overlays)
    }

    @objc
private func mapTapped(_ sender: UITapGestureRecognizer) {
        guard sender.state == .recognized else { return }
        let touchPoint = sender.location(in: map)
        let mapPoint: MKMapPoint = MKMapPoint(map.convert(touchPoint, toCoordinateFrom: map))
        var closest: (polyline: TriplogPolyline, distance: CLLocationDistance, stickedPoint: MKMapPoint)?
        for overlay in map.overlays {
            guard let polyline = overlay as? TriplogPolyline, polyline.eventType == .speeding, let point = closestPointOnPolyline(from: mapPoint, to: polyline) else { continue }
            if closest == nil || closest!.distance > point.distance {
                closest = (polyline: polyline, distance: point.distance, stickedPoint: point.point)
            }
        }
        guard let founded = closest else { return }
        let maxMeters: Double = meters(fromPoints: 20, at: touchPoint)
        if founded.distance <= maxMeters {
            if isReportMap {
                createAnnotation(with: founded.polyline.lineColor, coord: founded.stickedPoint.coordinate)
            } else {
                guard let event = founded.polyline.event, let type = founded.polyline.eventType else { return }
                delegate?.mapView(self, didSelect: event, with: type)
            }
        }
    }

    private func createAnnotation(with color: UIColor, coord: CLLocationCoordinate2D) {
        let annotation = TriplogReportAnnotation(coordinate: coord)
        let eventPoint = viewModel?.getClosestReportPoint(point: coord)
        annotation.speed = Int(eventPoint?.speedKmH ?? viewModel?.speedLimit ?? 0)
        annotation.color = color
        reportAnnotation = annotation
        map.addAnnotation(annotation)
    }

    private func closestPointOnPolyline(from pt: MKMapPoint, to polyline: MKPolyline) -> (point: MKMapPoint, distance: Double)? {
        var closestPoint: (point: MKMapPoint, distance: Double)?
        for n in 0 ..< polyline.pointCount - 1 {
            let ptA = polyline.points()[n]
            let ptB = polyline.points()[n + 1]
            let xDelta: Double = ptB.x - ptA.x
            let yDelta: Double = ptB.y - ptA.y
            if xDelta == 0.0 && yDelta == 0.0 {
                continue
            }
            let u: Double = ((pt.x - ptA.x) * xDelta + (pt.y - ptA.y) * yDelta) / (xDelta * xDelta + yDelta * yDelta)
            var ptClosest: MKMapPoint
            if u < 0.0 {
                ptClosest = ptA
            } else if u > 1.0 {
                ptClosest = ptB
            } else {
                ptClosest = MKMapPoint(x: ptA.x + u * xDelta, y: ptA.y + u * yDelta)
            }
            let ptDistance = ptClosest.distance(to: pt)
            if closestPoint == nil || closestPoint!.distance > ptDistance {
                closestPoint = (point: ptClosest, distance: ptDistance)
            }
        }
        return closestPoint
    }

    private func meters(fromPoints px: Int, at pt: CGPoint) -> Double {
        let ptB = CGPoint(x: pt.x + CGFloat(px), y: pt.y)
        let coordA: CLLocationCoordinate2D = map.convert(pt, toCoordinateFrom: map)
        let coordB: CLLocationCoordinate2D = map.convert(ptB, toCoordinateFrom: map)
        return MKMapPoint(coordA).distance(to: MKMapPoint(coordB))
    }
}

// MARK: MKMapViewDelegate

extension TriplogMapView: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let overlay = overlay as! TriplogPolyline
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = overlay.lineColor
        polylineRenderer.lineWidth = overlay.stroke
        return polylineRenderer
    }

    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? TriplogAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: TriplogEventAnnotationView.reuseIndentifier) as? TriplogEventAnnotationView
            if annotationView == nil {
                annotationView = TriplogEventAnnotationView(annotation: annotation, reuseIdentifier: TriplogEventAnnotationView.reuseIndentifier)
            }
            annotationView?.color = annotation.iconColor
            annotationView?.pinType = annotation.annotationType
            guard annotation.animate else { return annotationView }

            annotationView?.displayPriority = MKFeatureDisplayPriority.required
            annotationView?.priorityZPosition = CGFloat(annotation.priority.rawValue)
            annotationView?.transform = CGAffineTransform(scaleX: 0.0, y: 0.0).concatenating(CGAffineTransform(translationX: 0, y: -80))
            annotationView?.layoutIfNeeded()
            UIView.animate(withDuration: 0.3, animations: {
                annotationView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                annotationView?.layoutIfNeeded()
            })

            return annotationView
        } else if let annotation = annotation as? TriplogReportAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: TriplogReportAnnotationView.reuseIndentifier) as? TriplogReportAnnotationView
            if annotationView == nil {
                annotationView = TriplogReportAnnotationView(annotation: annotation, reuseIdentifier: TriplogReportAnnotationView.reuseIndentifier)
            }
            annotationView?.color = annotation.color
            annotationView?.speed = annotation.speed
            return annotationView
        }
        return nil
    }

    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard !isReportMap else { return }
        mapView.deselectAnnotation(view.annotation, animated: false)
        guard let eventAnnotation = view.annotation as? TriplogEventAnnotation else { return }
        delegate?.mapView(self, didSelect: eventAnnotation.event, with: eventAnnotation.eventType)
    }

    public func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for annotationView in views {
            if let tripLogAnnotation = annotationView as? TriplogEventAnnotationView {
                if tripLogAnnotation.pinType == .start || tripLogAnnotation.pinType == .end {
                    tripLogAnnotation.superview?.bringSubviewToFront(tripLogAnnotation)
                } else {
                    tripLogAnnotation.superview?.sendSubviewToBack(tripLogAnnotation)
                }
            }
        }
    }
    
    public func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        if fullyRendered {
            let renderer = UIGraphicsImageRenderer(size: mapView.bounds.size)
            let image = renderer.image { _ in
                mapView.drawHierarchy(in: mapView.bounds, afterScreenUpdates: true)
            }
            //use the image instead of map..but..this crap is used in preview and also in full view..
            delegate?.mapRenderingFinished(image: image)
        }
    }
}
