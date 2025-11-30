import Foundation

final class DependencyContainer {
    static let shared = DependencyContainer()

    func makeFocusViewModel() -> FocusViewModel {
        FocusViewModel()
    }
}
