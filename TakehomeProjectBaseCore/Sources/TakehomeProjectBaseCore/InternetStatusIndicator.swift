import Network
import Dependencies
import ComposableArchitecture

@Reducer
public struct InternetStatusIndicator {
  public struct State: Equatable {
    // TODO: Need to conform this type to Codable
    public var status: NWPath.Status
    @EquatableNoop var monitor: NWPathMonitor?
  }
  
  public enum Action: Equatable {
    case start
    case stop
    case newStatus(NWPath.Status)
  }
  
  @Dependency(\.networkStatus) var networkStatus
  
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
  static var liveValue: () -> (monitor: NWPathMonitor, stream: AsyncStream<NWPath.Status>) = {
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
  
  static var testValue: () -> (monitor: NWPathMonitor, stream: AsyncStream<NWPath.Status>) = unimplemented("network status")
}

extension DependencyValues {
  var networkStatus: () -> (monitor: NWPathMonitor, stream: AsyncStream<NWPath.Status>) {
    get { self[NetworkStatusMonitor.self] }
    set { self[NetworkStatusMonitor.self] = newValue }
  }
}
