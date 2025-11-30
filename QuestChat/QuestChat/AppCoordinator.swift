import SwiftUI

final class AppCoordinator {
    private let dependencyContainer: DependencyContainer

    init(dependencyContainer: DependencyContainer = .shared) {
        self.dependencyContainer = dependencyContainer
    }

    var rootView: some View {
        ContentView(
            focusViewModel: dependencyContainer.makeFocusViewModel(),
            statsView: makeStatsView()
        )
    }

    func makeStatsView() -> StatsView {
        StatsView(viewModel: dependencyContainer.makeStatsViewModel())
    }
}
