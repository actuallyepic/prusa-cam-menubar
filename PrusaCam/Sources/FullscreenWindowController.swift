import AppKit

@MainActor
final class FullscreenWindowController: NSWindowController, NSWindowDelegate {
	var isVisible: Bool { window?.isVisible == true }
	var onClose: (@MainActor () -> Void)?

	private let playerController: StreamPlayerController
	private let playerViewController: LargePlayerViewController

	init(playerController: StreamPlayerController) {
		self.playerController = playerController
		self.playerViewController = LargePlayerViewController(playerController: playerController)

		let window = NSWindow(contentViewController: playerViewController)
		window.title = "PrusaCam"
		window.setContentSize(NSSize(width: 1200, height: 800))
		window.styleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
		window.titleVisibility = .hidden
		window.titlebarAppearsTransparent = true
		window.isReleasedWhenClosed = false
		window.collectionBehavior = [.managed]
		window.backgroundColor = .black

		super.init(window: window)
		self.window?.delegate = self
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func show() {
		guard let window else { return }
		if window.isMiniaturized {
			window.deminiaturize(nil)
		}
		window.makeKeyAndOrderFront(nil)
		NSApp.activate(ignoringOtherApps: true)
		playerController.ensurePlaying()
	}

	func windowWillClose(_ notification: Notification) {
		playerViewController.releaseOutput()
		onClose?()
	}
}
