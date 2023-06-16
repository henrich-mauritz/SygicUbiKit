
import Foundation

public class ReachabilityManager {
    public var rechability: Reachability?

    public static let shared = ReachabilityManager()

    public var status: Network.Status {
        guard let rechability = self.rechability else {
            return .unreachable
        }
        return rechability.status
    }

    public func setupReachability() {
        guard rechability == nil else { return }
        do {
            rechability = try Reachability(hostname: "www.google.com")
        } catch {
            print("Couldn't initialize reachability")
        }
    }
}
