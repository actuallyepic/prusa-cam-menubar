import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController: NSWindowController, NSWindowDelegate {
	init(playerController: StreamPlayerController) {
		let hostingController = NSHostingController(rootView: SettingsView(playerController: playerController))
		let window = NSWindow(contentViewController: hostingController)
		window.title = "PrusaCam Settings"
		window.setContentSize(NSSize(width: 520, height: 220))
		window.styleMask = [.titled, .closable, .miniaturizable]
		window.isReleasedWhenClosed = false
		window.center()

		super.init(window: window)
		self.window?.delegate = self
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func show() {
		guard let window else { return }
		window.makeKeyAndOrderFront(nil)
		NSApp.activate(ignoringOtherApps: true)
	}
}

