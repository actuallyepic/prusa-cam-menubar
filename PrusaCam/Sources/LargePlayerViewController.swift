import AppKit
import VLCKit

@MainActor
final class LargePlayerViewController: NSViewController {
	private let playerController: StreamPlayerController
	private let videoView = VLCVideoView()

	init(playerController: StreamPlayerController) {
		self.playerController = playerController
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		let container = NSView()
		container.wantsLayer = true
		container.layer?.backgroundColor = NSColor.black.cgColor

		videoView.backColor = .black
		videoView.fillScreen = true
		videoView.translatesAutoresizingMaskIntoConstraints = false

		container.addSubview(videoView)
		NSLayoutConstraint.activate([
			videoView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
			videoView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
			videoView.topAnchor.constraint(equalTo: container.topAnchor),
			videoView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
		])

		self.view = container
	}

	override func viewDidAppear() {
		super.viewDidAppear()
		playerController.startWindowPlayback(on: videoView)
	}

	override func viewWillDisappear() {
		super.viewWillDisappear()
		releaseOutput()
	}

	func releaseOutput() {
		playerController.stopWindowPlayback()
	}
}
