// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var profileService: ProfileService

    var body: some View {
        if profileService.profile.isOnboardingComplete {
            HomeView()
        } else {
            OnboardingView()
        }
    }
}
