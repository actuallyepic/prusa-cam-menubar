import AppKit
import SwiftUI

struct SettingsView: View {
	@ObservedObject var playerController: StreamPlayerController
	@State private var urlText: String
	@State private var keepAliveSeconds: Double

	init(playerController: StreamPlayerController) {
		self.playerController = playerController
		_urlText = State(initialValue: playerController.streamURLString)
		_keepAliveSeconds = State(initialValue: playerController.keepAliveSeconds)
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack {
				Text("Settings")
					.font(.headline)
				Spacer()
				Button("Quit") { NSApp.terminate(nil) }
					.controlSize(.small)
			}

			VStack(alignment: .leading, spacing: 6) {
				Text("RTSP URL")
					.font(.caption)
					.foregroundStyle(.secondary)
				TextField("rtsp://…", text: $urlText)
					.textFieldStyle(.roundedBorder)
					.font(.system(size: 12, design: .monospaced))
			}

			HStack(spacing: 10) {
				Button("Apply") {
					playerController.setStreamURL(urlText)
				}
				Button("Reconnect") {
					playerController.restart()
				}
				.controlSize(.regular)

				Spacer()

				Text(statusText)
					.font(.caption)
					.foregroundStyle(.secondary)
			}

			Stepper(value: $keepAliveSeconds, in: 0...300, step: 5) {
				Text("Keep-alive after closing: \(Int(keepAliveSeconds))s")
			}
			.onChange(of: keepAliveSeconds) { newValue in
				playerController.keepAliveSeconds = newValue
			}
		}
		.padding(16)
		.frame(width: 520)
		.onChange(of: playerController.streamURLString) { newValue in
			urlText = newValue
		}
	}

	private var statusText: String {
		switch playerController.state {
		case .idle:
			return "Idle"
		case .connecting:
			return "Connecting…"
		case .buffering:
			return "Buffering…"
		case .playing:
			return "Playing"
		case .paused:
			return "Paused"
		case .ended:
			return "Ended"
		case .error:
			return "Error"
		}
	}
}

