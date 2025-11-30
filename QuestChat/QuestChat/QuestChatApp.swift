//
//  QuestChatApp.swift
//  QuestChat
//
//  Created by Anthony Gagliardo on 11/30/25.
//

import SwiftUI

@main
struct QuestChatApp: App {
    private let coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            coordinator.rootView
        }
    }
}
