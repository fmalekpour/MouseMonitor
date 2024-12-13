//
//  AppDelegate.swift
//  MouseMonitor
//
//  Created by Farhad Malekpour on 12/11/24.
//

import Foundation

import Cocoa

final class MyAppDelegate: NSObject, NSApplicationDelegate {

	func applicationDidFinishLaunching(_ notification: Notification) {
		PermissionsService.askForAccessibilityPrivileges()
		
		NSEvent.addGlobalMonitorForEvents(matching: [.otherMouseDown]) { event in
			for map in AppSingelton.shared.allMaps.maps {
				if map.isActive, map.key > 0,  map.mouseButton == event.buttonNumber {

					let evd = CGEvent(keyboardEventSource: nil, virtualKey: map.key, keyDown: true)
					evd?.flags = CGEventFlags(map.modifiers.map({CGEventFlags(rawValue: $0)}))
					evd?.post(tap: .cghidEventTap)
					
					let evu = CGEvent(keyboardEventSource: nil, virtualKey: map.key, keyDown: false)
					evu?.flags = CGEventFlags(map.modifiers.map({CGEventFlags(rawValue: $0)}))
					evu?.post(tap: .cghidEventTap)

				}
			}
		}
	}
}
