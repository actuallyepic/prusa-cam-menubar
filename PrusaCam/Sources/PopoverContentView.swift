import SwiftUI

struct PopoverContentView: View {
	@ObservedObject var playerController: StreamPlayerController
	let onFullscreen: () -> Void
	let onSettings: () -> Void

	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			HStack {
				Text("PrusaCam")
					.font(.headline)

				Spacer()

				Button(action: onSettings) {
					Image(systemName: "gearshape")
				}
				.buttonStyle(.plain)
				.help("Settings")

				Button(action: onFullscreen) {
					Image(systemName: "arrow.up.left.and.arrow.down.right")
				}
				.buttonStyle(.plain)
				.help("Fullscreen")
			}

			ZStack {
				VLCVideoViewRepresentable(playerController: playerController)
					.clipped()
					.cornerRadius(10)

				statusOverlay
					.padding(8)
			}
			.frame(height: 220)

			Text("Use ⤢ for the larger window.")
				.font(.caption)
				.foregroundStyle(.secondary)
		}
		.padding(14)
		.frame(width: 360)
	}

	@ViewBuilder
	private var statusOverlay: some View {
		switch playerController.state {
		case .idle:
			if playerController.hasConfiguredURL {
				loadingOverlay("Starting…")
			} else {
				configOverlay
			}
		case .connecting:
			loadingOverlay("Connecting…")
		case .buffering:
			loadingOverlay("Buffering…")
		case .paused:
			overlayLabel("Paused")
		case .ended:
			overlayLabel("Ended")
		case .error(let message):
			VStack(spacing: 4) {
				Text("Error")
					.font(.caption.bold())
				if let message, !message.isEmpty {
					Text(message)
						.font(.caption2)
				}
			}
			.foregroundStyle(.white.opacity(0.95))
			.padding(.horizontal, 10)
			.padding(.vertical, 8)
			.background(.black.opacity(0.6))
			.clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
		case .playing:
			if playerController.isVideoReady {
				EmptyView()
			} else {
				loadingOverlay("Starting video…")
			}
		}
	}

	private func overlayLabel(_ text: String) -> some View {
		Text(text)
			.font(.caption)
			.foregroundStyle(.white.opacity(0.95))
			.padding(.horizontal, 10)
			.padding(.vertical, 6)
			.background(.black.opacity(0.55))
			.clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
	}

	private func loadingOverlay(_ text: String) -> some View {
		VStack(spacing: 6) {
			ProgressView()
				.progressViewStyle(.circular)
				.controlSize(.small)
			Text(text)
				.font(.caption)
		}
		.foregroundStyle(.white.opacity(0.95))
		.padding(.horizontal, 12)
		.padding(.vertical, 10)
		.background(.black.opacity(0.6))
		.clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
	}

	private var configOverlay: some View {
		VStack(spacing: 8) {
			Text("No RTSP URL set")
				.font(.caption.bold())
			Button("Open Settings") { onSettings() }
				.controlSize(.small)
		}
		.foregroundStyle(.white.opacity(0.95))
		.padding(.horizontal, 12)
		.padding(.vertical, 10)
		.background(.black.opacity(0.6))
		.clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
	}
}
