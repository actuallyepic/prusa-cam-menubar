import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
	private var statusItem: NSStatusItem?
	private let popover = NSPopover()
	private var fullscreenWindowController: FullscreenWindowController?
	private var settingsWindowController: SettingsWindowController?
	private let playerController = StreamPlayerController()
	private var popoverActive = false
	private var fullscreenActive = false

	func applicationDidFinishLaunching(_ notification: Notification) {
		NSApp.setActivationPolicy(.accessory)
		setUpStatusItem()
		setUpPopover()
		playerController.preconnect()
	}

	private func setUpStatusItem() {
		let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
		if let button = item.button {
			button.image = NSImage(systemSymbolName: "video.fill", accessibilityDescription: "PrusaCam")
			button.imagePosition = .imageOnly
			button.action = #selector(handleStatusItemClick(_:))
			button.target = self
		}
		self.statusItem = item
	}

	private func setUpPopover() {
		popover.delegate = self
		popover.behavior = .transient
		popover.animates = true
		popover.contentViewController = NSHostingController(rootView: PopoverContentView(
			playerController: playerController,
			onFullscreen: { [weak self] in self?.presentFullscreenFromPopover() },
			onSettings: { [weak self] in self?.showSettings() }
		))
	}

	@objc
	private func handleStatusItemClick(_ sender: Any?) {
		guard let button = statusItem?.button else { return }

		if fullscreenWindowController?.isVisible == true {
			hideFullscreen()
		}

		if popover.isShown {
			popover.performClose(sender)
			return
		}

		showPopover(relativeTo: button.bounds, of: button)
	}

	private func showPopover(relativeTo rect: NSRect, of view: NSView) {
		popover.show(relativeTo: rect, of: view, preferredEdge: .minY)
	}

	private func showFullscreen() {
		if fullscreenWindowController?.isVisible == true {
			return
		}

		if fullscreenWindowController == nil {
			fullscreenWindowController = FullscreenWindowController(playerController: playerController)
			fullscreenWindowController?.onClose = { [weak self] in
				guard let self else { return }
				if self.fullscreenActive {
					self.fullscreenActive = false
					self.playerController.endUsage()
					if self.popoverActive {
						self.playerController.ensurePlaying()
					}
				}
			}
		}

		if !fullscreenActive {
			fullscreenActive = true
			playerController.beginUsage()
		}
		fullscreenWindowController?.show()
	}

	private func hideFullscreen() {
		fullscreenWindowController?.close()
	}

	private func presentFullscreenFromPopover() {
		showFullscreen()
		popover.performClose(nil)
	}

	private func showSettings() {
		if settingsWindowController == nil {
			settingsWindowController = SettingsWindowController(playerController: playerController)
		}
		settingsWindowController?.show()
	}

	func popoverWillShow(_ notification: Notification) {
		if !popoverActive {
			popoverActive = true
			playerController.beginUsage()
		}
	}

	func popoverDidClose(_ notification: Notification) {
		if popoverActive {
			popoverActive = false
			playerController.endUsage()
		}
	}
}
