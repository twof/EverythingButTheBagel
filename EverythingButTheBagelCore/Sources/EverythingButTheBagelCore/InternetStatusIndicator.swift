import Network
import Dependencies
import ComposableArchitecture

extension NWPath.Status: RawRepresentable {
  public init?(rawValue: String) {
    switch rawValue {
    case "satisfied":
      self = .satisfied
    case "unsatisfied":
      self = .unsatisfied
    case "requiresConnection":
      self = .requiresConnection
    default:
      return nil
    }
  }

  public var rawValue: String {
    switch self {
    case .satisfied:
      return "satisfied"
    case .unsatisfied:
      return "unsatisfied"
    case .requiresConnection:
      return "requiresConnection"
    @unknown default:
      return "unknown"
    }
  }
}

extension NWPath.Status: Codable {}

@Reducer
public struct InternetStatusIndicator {
  public struct State: Equatable, Codable {
    public var status: NWPath.Status = .satisfied
    @EquatableNoop var monitor: NWPathMonitor?

    enum CodingKeys: CodingKey {
      case status
    }

    public init(status: NWPath.Status = .satisfied, monitor: NWPathMonitor? = nil) {
      self.status = status
      self.monitor = monitor
    }
  }

  public enum Action: Equatable {
    case start
    case stop
    case newStatus(NWPath.Status)
  }

  @Dependency(\.networkStatus) var networkStatus

  public init() {}

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .start:
        let (monitor, networkStatus) = networkStatus()
        state.monitor = monitor
        return .run { send in
          for await status in networkStatus {
            await send(.newStatus(status))
          }
        }
      case .stop:
        state.monitor?.cancel()
        state.monitor = nil
        return .none

      case let .newStatus(status):
        state.status = status
        return .none
      }
    }
  }
}

struct NetworkStatusMonitor: DependencyKey {
  static let liveValue: @Sendable () -> (monitor: NWPathMonitor, stream: AsyncStream<NWPath.Status>) = {
    let monitor = NWPathMonitor()
    let stream = AsyncStream<NWPath.Status> { continuation in
      monitor.pathUpdateHandler = { path in
        continuation.yield(path.status)
      }
    }
    let queue = DispatchQueue(label: "Monitor")
    monitor.start(queue: queue)

    return (monitor, stream)
  }

  static let testValue: @Sendable () -> (monitor: NWPathMonitor, stream: AsyncStream<NWPath.Status>)
    = unimplemented("network status")
}

extension DependencyValues {
  var networkStatus: @Sendable () -> (monitor: NWPathMonitor, stream: AsyncStream<NWPath.Status>) {
    get { self[NetworkStatusMonitor.self] }
    set { self[NetworkStatusMonitor.self] = newValue }
  }
}
