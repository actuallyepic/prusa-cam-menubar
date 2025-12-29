import SwiftUI
import VLCKit

final class VLCVideoContainerView: VLCVideoView {
	private weak var playerController: StreamPlayerController?

	init(playerController: StreamPlayerController) {
		self.playerController = playerController
		super.init(frame: .zero)
		backColor = .black
		fillScreen = true
		wantsLayer = true
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()
		if window != nil {
			attachIfNeeded()
		}
	}

	override func viewDidMoveToSuperview() {
		super.viewDidMoveToSuperview()
		attachIfNeeded()
	}

	private func attachIfNeeded() {
		guard window != nil else { return }
		Task { @MainActor [weak self] in
			guard let self, let playerController else { return }
			playerController.attachDrawable(self)
			playerController.ensurePlaying()
		}
	}
}

struct VLCVideoViewRepresentable: NSViewRepresentable {
	final class Coordinator {
		let playerController: StreamPlayerController

		init(playerController: StreamPlayerController) {
			self.playerController = playerController
		}
	}

	let playerController: StreamPlayerController

	func makeCoordinator() -> Coordinator {
		Coordinator(playerController: playerController)
	}

	func makeNSView(context: Context) -> VLCVideoContainerView {
		let view = VLCVideoContainerView(playerController: context.coordinator.playerController)
		context.coordinator.playerController.attachDrawable(view)
		return view
	}

	func updateNSView(_ nsView: VLCVideoContainerView, context: Context) {
		context.coordinator.playerController.attachDrawable(nsView)
	}

	static func dismantleNSView(_ nsView: VLCVideoContainerView, coordinator: Coordinator) {
		coordinator.playerController.detachDrawable(nsView)
	}
}
