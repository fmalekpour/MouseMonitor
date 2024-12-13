//
//  PermissionsService.swift
//  MouseMonitor
//
//  Created by Farhad Malekpour on 12/11/24.
//

import Foundation
import Cocoa
import SwiftUI

final class PermissionsService: ObservableObject {
	@Published var permissionsGranted: Bool = AXIsProcessTrusted()
	
	func checkAccessibilityPrivileges() {
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
			self.permissionsGranted = AXIsProcessTrusted()
			
			if !self.permissionsGranted {
				self.checkAccessibilityPrivileges()
			}
		}
	}
	
	static func askForAccessibilityPrivileges() {
		let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
		let _ = AXIsProcessTrustedWithOptions(options)
	}
}


struct PermissionCheck: View {
	var permissionsService: PermissionsService
	@Environment(\.dismissWindow) var dismissWindow
	var body: some View {
		ZStack{
			if !self.permissionsService.permissionsGranted {
				PermissionsView()
			}
			else
			{
				Color.clear
					.onAppear {
						dismissWindow()
					}
				
			}
		}
		.onAppear(perform: self.permissionsService.checkAccessibilityPrivileges)

	}
}
