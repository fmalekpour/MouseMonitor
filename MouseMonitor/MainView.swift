//
//  ContentView.swift
//  MouseMonitor
//
//  Created by Farhad Malekpour on 12/11/24.
//

import SwiftUI

struct MainView: View {
	var body: some View {
		MainViewList(allMaps: AppSingelton.shared.allMaps)
	}
}

struct MainViewList: View {
	@ObservedObject var allMaps: AllMaps
	@EnvironmentObject var model: AppModel
	
	var body: some View {
		ZStack{
			ScrollView{
				Grid{
					GridRow {
						Text("Is Active")
						Text("Mouse Button")
						Text("Target Key")
						Text("Target Modifiers")
					}
					
					ForEach(allMaps.maps.indices, id: \.self){ index in
						GridRow {
							MainViewItem(map: Binding(get: {
								allMaps.maps[index]
							}, set: { value in
								allMaps.maps[index] = value
								allMaps.save()
							}))
						}
					}
					
				}
				.padding()
			}
			
			if model.showMouseDetectPad != nil
			{
				MouseDetectPad()
			}
			
			if model.showKeyDetectPad != nil
			{
				KeyDetectPad()
			}
			
		}
	}
}

struct MainViewItem: View {
	@Binding var map: KeyMap
	@EnvironmentObject var model: AppModel
	var body: some View{
		Toggle(isOn: $map.isActive, label: {})
		
		Button {
			model.showMouseDetectPad = map.id
		} label: {
			Text(map.mouseButton != -1 ? "\(map.mouseButton)" : "n/a")
			Spacer()
			Text("Detect")
		}
		
		Button {
			model.showKeyDetectPad = map.id
		} label: {
			Text(map.key != 0 ? "\(map.key)" : "n/a")
			Spacer()
			Text("Detect")
		}
		

		HStack{
			Button {
				if map.modifiers.contains(CGEventFlags.maskShift.rawValue) { map.modifiers.removeAll(where: { $0 == CGEventFlags.maskShift.rawValue}) }
				else { map.modifiers.append(CGEventFlags.maskShift.rawValue) }
			} label: {
				Image(systemName: "shift")
			}
			.modifier(ModifierButtonStyle(isActive: map.modifiers.contains(CGEventFlags.maskShift.rawValue)))
			
			
			Button {
				if map.modifiers.contains(CGEventFlags.maskControl.rawValue) { map.modifiers.removeAll(where: { $0 == CGEventFlags.maskControl.rawValue}) }
				else { map.modifiers.append(CGEventFlags.maskControl.rawValue) }
			} label: {
				Image(systemName: "control")
			}
			.modifier(ModifierButtonStyle(isActive: map.modifiers.contains(CGEventFlags.maskControl.rawValue)))
			
			Button {
				if map.modifiers.contains(CGEventFlags.maskCommand.rawValue) { map.modifiers.removeAll(where: { $0 == CGEventFlags.maskCommand.rawValue}) }
				else { map.modifiers.append(CGEventFlags.maskCommand.rawValue) }
			} label: {
				Image(systemName: "command")
			}
			.modifier(ModifierButtonStyle(isActive: map.modifiers.contains(CGEventFlags.maskCommand.rawValue)))

			Button {
				if map.modifiers.contains(CGEventFlags.maskAlternate.rawValue) { map.modifiers.removeAll(where: { $0 == CGEventFlags.maskAlternate.rawValue}) }
				else { map.modifiers.append(CGEventFlags.maskAlternate.rawValue) }
			} label: {
				Image(systemName: "option")
			}
			.modifier(ModifierButtonStyle(isActive: map.modifiers.contains(CGEventFlags.maskAlternate.rawValue)))

		}
	}
}

struct PermissionsView: View {
	var body: some View {
		Text("Please grant Accessibility Permission to this app in System Settings -> Privacy -> Accessibility")
	}
}

private struct MouseDetectPad: View {
	@EnvironmentObject var model: AppModel
	@State var listener: Any?

	var body: some View {
		ZStack {
			Text("Click Here")
		}
		.frame(width: 200, height: 200)
		.background(Color.blue)
		.clipShape(RoundedRectangle(cornerRadius: 15))
		.overlay(alignment: .topTrailing, content: {
			Button {
				model.showMouseDetectPad = nil
			} label: {
				Image(systemName: "multiply.circle.fill")
			}
			.padding(10)
			
		})
		.onAppear {
			listener = NSEvent.addLocalMonitorForEvents(matching: .otherMouseDown) { event in
				if let itemId = model.showMouseDetectPad, let idx = AppSingelton.shared.allMaps.maps.firstIndex(where: { $0.id == itemId })
				{
					AppSingelton.shared.allMaps.maps[idx].mouseButton = event.buttonNumber
				}
				
				model.showMouseDetectPad = nil
				return event
			}
		}
		.onDisappear {
			if let listener
			{
				NSEvent.removeMonitor(listener)
			}
		}
	}
}

private struct KeyDetectPad: View {
	@EnvironmentObject var model: AppModel
	@State var listener: Any?
	
	var body: some View {
		ZStack {
			VStack{
				Text("Press a Key")
				Text("If key is assigned to a shortcut, try with some modifieers, like Command + Option + Shift. This detector olny detect the key code, not the modifiers.")
					.font(.caption2)
			}
			.padding()
		}
		.frame(width: 200, height: 200)
		.background(Color.blue)
		.clipShape(RoundedRectangle(cornerRadius: 15))
		.overlay(alignment: .topTrailing, content: {
			Button {
				model.showKeyDetectPad = nil
			} label: {
				Image(systemName: "multiply.circle.fill")
			}
			.padding(10)
			
		})
		.onAppear {
			listener = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
				if let itemId = model.showKeyDetectPad, let idx = AppSingelton.shared.allMaps.maps.firstIndex(where: { $0.id == itemId })
				{
					AppSingelton.shared.allMaps.maps[idx].key = event.keyCode
				}
				
				model.showKeyDetectPad = nil
				return nil
			}
		}
		.onDisappear {
			if let listener
			{
				NSEvent.removeMonitor(listener)
			}
		}
	}
}

private struct ModifierButtonStyle: ViewModifier {
	var isActive: Bool
	func body(content: Content) -> some View {
		if isActive{
			content
				.buttonStyle(.borderedProminent)
		}
		else
		{
			content
				.buttonStyle(.bordered)
		}
	}
}

#Preview {
	MainView()
}
