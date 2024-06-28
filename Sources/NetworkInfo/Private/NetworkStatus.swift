import Network
import Foundation

public final class NetworkStatus: NetworkStatusProtocol {
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue.global(qos: .background)
    private var isMonitoring = false
    
    public var connectionStatusChangeHandler: ((Bool, String) -> Void)?

    public init() {
        monitor = NWPathMonitor()
    }

    public func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            let isConnected = path.status == .satisfied
            let connectionType = self.getConnectionType(from: path)
            self.connectionStatusChangeHandler?(isConnected, connectionType)
        }
    }

    private func getConnectionType(from path: NWPath) -> String {
        if path.usesInterfaceType(.wifi) {
            return "WiFi"
        } else if path.usesInterfaceType(.cellular) {
            return "Cellular"
        } else if path.usesInterfaceType(.wiredEthernet) {
            return "Wired Ethernet"
        } else {
            return "Other"
        }
    }

    public func getCurrentConnectionType() -> String {
        return getConnectionType(from: monitor.currentPath)
    }
}
