//
//  StateConstant.swift
//  Sweechat
//
//  Created by Christian James Welly on 20/3/21.
//

struct StateConstant {
    static let LoggedOutAppStates: Set<AppState> = [.onboarding, .entry, .login, .registration]
    static let LoggedInAppStates: Set<AppState> = [.home, .module, .settings, .chatRoom]
    static let DefaultLoggedOutAppState: AppState = .entry
    static let DefaultLoggedInAppState: AppState = .home

    static let DefaultLoggedInAppStateMessage: StaticString = """
        User is already logged in. Switching to default LoggedIn AppState.
        """
    static let DefaultLoggedOutAppStateMessage: StaticString = """
        User is not yet logged in. Switching to default LoggedOut AppState.
        """
}
