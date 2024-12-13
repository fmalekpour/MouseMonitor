//
//  MouseMonitorApp.swift
//  MouseMonitor
//
//  Created by Farhad Malekpour on 12/11/24.
//

import SwiftUI

@main
struct MouseMonitorApp: App {
	@StateObject private var permissionsService = PermissionsService()
	@NSApplicationDelegateAdaptor private var appDelegate: MyAppDelegate
	@Environment(\.openWindow) private var openWindow
	@ObservedObject var model = AppModel()
	
	var body: some Scene {
		
		WindowGroup {
			PermissionCheck(permissionsService: permissionsService)
		}
		
		
		MenuBarExtra("MouseMonitor", systemImage: "computermouse.fill") {
			Button {
				NSApplication.shared.activate(ignoringOtherApps: true)
				openWindow(id: "CONF_WINDOW")
			} label: {
				Text("Show Config")
			}
			Button {
				NSApp.terminate(nil)
			} label: {
				Text("Exit")
			}
		}
		
		
		Window("Mouse Monitor", id: "CONF_WINDOW") {
			MainView()
				.frame(minWidth: 600, maxWidth: 4096,
					   minHeight: 400, maxHeight: 4096)
				.windowMinimizeBehavior(.disabled)
				.environmentObject(model)
		}
		.defaultPosition(.center)
		.windowResizability(.contentMinSize)
		.windowToolbarStyle(.unifiedCompact(showsTitle: true))

		
		
	}
}

class AppSingelton: ObservableObject {
	static let shared = AppSingelton()
	private init() {}
	
	var allMaps: AllMaps = AllMaps.load()
}

class AppModel: ObservableObject {
	@Published var showMouseDetectPad: UUID?
	@Published var showKeyDetectPad: UUID?
}
