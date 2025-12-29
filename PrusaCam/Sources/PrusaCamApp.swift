import SwiftUI

@main
struct PrusaCamApp: App {
	@NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

	var body: some Scene {
		Settings {
			EmptyView()
		}
	}
}

