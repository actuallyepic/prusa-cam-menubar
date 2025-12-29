import Foundation
import VLCKit

@MainActor
final class StreamPlayerController: NSObject, ObservableObject, VLCMediaPlayerDelegate {
	enum PlaybackState: Equatable {
		case idle
		case connecting
		case buffering
		case playing
		case paused
		case ended
		case error(message: String?)
	}

	@Published private(set) var state: PlaybackState = .idle
	@Published private(set) var streamURLString: String
	@Published private(set) var isVideoReady = false
	@Published var keepAliveSeconds: Double {
		didSet {
			UserDefaults.standard.set(keepAliveSeconds, forKey: keepAliveSecondsKey)
			if usageCount == 0 {
				scheduleIdleStop()
			}
		}
	}

	private let player: VLCMediaPlayer
	private let windowPlayer: VLCMediaPlayer
	private let userDefaultsKey = "PrusaCam.streamURL"
	private let keepAliveSecondsKey = "PrusaCam.keepAliveSeconds"
	private var usageCount = 0
	private var idleStopTimer: Timer?
	private var videoProbeTimer: Timer?
	private var playbackStartTime: Date?
	private let videoReadyTimeout: TimeInterval = 2.5

	override init() {
		self.player = VLCMediaPlayer()
		self.windowPlayer = VLCMediaPlayer()
		self.streamURLString = UserDefaults.standard.string(forKey: userDefaultsKey) ?? ""
		if UserDefaults.standard.object(forKey: keepAliveSecondsKey) == nil {
			self.keepAliveSeconds = 30
		} else {
			self.keepAliveSeconds = UserDefaults.standard.double(forKey: keepAliveSecondsKey)
		}
		super.init()
		self.player.delegate = self
		self.player.audio?.isMuted = true
		self.windowPlayer.audio?.isMuted = true
	}

	func preconnect() {
		guard hasConfiguredURL else { return }
		ensurePlaying()
		scheduleIdleStop()
	}

	func beginUsage() {
		usageCount += 1
		cancelIdleStop()
		startVideoMonitoring()
		ensurePlaying()
	}

	func endUsage() {
		usageCount = max(0, usageCount - 1)
		scheduleIdleStop()
		if usageCount == 0 {
			stopVideoMonitoring()
		}
	}

	func setStreamURL(_ urlString: String) {
		let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)

		streamURLString = trimmed
		UserDefaults.standard.set(trimmed, forKey: userDefaultsKey)

		restart()
		stopWindowPlayback()
	}

	func ensurePlaying() {
		guard hasConfiguredURL else {
			state = .idle
			isVideoReady = false
			return
		}

		if !isVideoReady {
			playbackStartTime = Date()
		}

		if player.isPlaying {
			state = .playing
			return
		}

		switch state {
		case .playing, .connecting, .buffering:
			return
		default:
			break
		}

		guard ensureMedia() else { return }

		state = .connecting
		player.play()
	}

	func restart() {
		stop()
		ensurePlaying()
		scheduleIdleStop()
	}

	func stop() {
		cancelIdleStop()
		player.stop()
		state = .idle
		isVideoReady = false
	}

	nonisolated func mediaPlayerStateChanged(_ aNotification: Notification) {
		Task { @MainActor [weak self] in
			self?.updateStateFromPlayer()
		}
	}

	private func updateStateFromPlayer() {
		if player.state == .stopped || player.state == .error {
			isVideoReady = false
		}

		if player.isPlaying {
			state = .playing
			return
		}

		let newState = player.state
		switch newState {
		case .stopped:
			state = .idle
		case .opening:
			state = .connecting
		case .buffering:
			state = .buffering
		case .playing:
			state = .playing
		case .paused:
			state = .paused
		case .ended:
			state = .ended
		case .error:
			state = .error(message: "Playback error")
		default:
			break
		}
	}

	private func cancelIdleStop() {
		idleStopTimer?.invalidate()
		idleStopTimer = nil
	}

	private func scheduleIdleStop() {
		guard usageCount == 0 else { return }

		cancelIdleStop()

		guard keepAliveSeconds > 0 else {
			stop()
			return
		}

		idleStopTimer = Timer.scheduledTimer(withTimeInterval: keepAliveSeconds, repeats: false) { [weak self] _ in
			Task { @MainActor in
				self?.stop()
			}
		}
	}

	private func startVideoMonitoring() {
		guard videoProbeTimer == nil else { return }
		playbackStartTime = Date()
		videoProbeTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
			Task { @MainActor in
				self?.probeVideoReady()
			}
		}
	}

	private func stopVideoMonitoring() {
		videoProbeTimer?.invalidate()
		videoProbeTimer = nil
		playbackStartTime = nil
		isVideoReady = false
	}

	private func probeVideoReady() {
		if isVideoReady {
			return
		}

		let hasOutput = player.hasVideoOut
		let size = player.videoSize
		let hasSize = size.width > 0 && size.height > 0
		let hasTime = player.time.intValue > 0

		if hasOutput || hasSize || hasTime {
			isVideoReady = true
			return
		}

		if player.isPlaying, let start = playbackStartTime, Date().timeIntervalSince(start) >= videoReadyTimeout {
			isVideoReady = true
		}
	}

	private func ensureMedia() -> Bool {
		if player.media != nil {
			return true
		}

		guard let media = makeMedia() else {
			state = .error(message: "Set RTSP URL in Settings")
			return false
		}

		player.media = media
		return true
	}

	private func makeMedia() -> VLCMedia? {
		guard let url = URL(string: streamURLString) else { return nil }

		let media = VLCMedia(url: url)
		media.addOption(":rtsp-tcp")
		media.addOption(":network-caching=200")
		media.addOption(":live-caching=200")
		return media
	}

	var hasConfiguredURL: Bool {
		!streamURLString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
	}

	func attachDrawable(_ drawable: AnyObject) {
		_ = ensureMedia()
		let currentDrawable = player.drawable as AnyObject?
		if currentDrawable !== drawable {
			player.drawable = drawable
		}
	}

	func detachDrawable(_ drawable: AnyObject) {
		let currentDrawable = player.drawable as AnyObject?
		if currentDrawable === drawable {
			player.drawable = nil
		}
	}

	func startWindowPlayback(on drawable: AnyObject) {
		player.stop()
		state = .idle

		guard let media = makeMedia() else { return }
		windowPlayer.media = media
		windowPlayer.drawable = drawable
		windowPlayer.play()
	}

	func stopWindowPlayback() {
		windowPlayer.stop()
		windowPlayer.drawable = nil
		windowPlayer.media = nil
	}
}
