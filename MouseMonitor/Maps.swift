//
//  Maps.swift
//  MouseMonitor
//
//  Created by Farhad Malekpour on 12/12/24.
//

import Foundation
import Cocoa

struct KeyMap: Identifiable, Codable {
	var id: UUID = UUID()
	var isActive: Bool
	var mouseButton: Int = -1
	var key: UInt16 = 0
	var modifiers: [uint64] = []
}

class AllMaps: Codable, ObservableObject {
	@Published var maps: [KeyMap] = []
	@Published var lastUpdate: TimeInterval = Date.now.timeIntervalSince1970
	
	enum CodingKeys: String, CodingKey {
		case maps
		case lastUpdate
	}
	init(){}
	
	required init(from decoder: any Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		maps = try values.decode([KeyMap].self, forKey: .maps)
		lastUpdate = try values.decode(TimeInterval.self, forKey: .lastUpdate)
	}
	
	func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(maps, forKey: .maps)
		try container.encode(lastUpdate, forKey: .lastUpdate)
	}
	
	static func load() -> AllMaps {
		if let data = UserDefaults.standard.data(forKey: "AllMaps"), let mp = try? JSONDecoder().decode(AllMaps.self, from: data)
		{
			mp.maps.append(contentsOf: Array(repeating: KeyMap(isActive: false), count: 10))
			mp.maps = Array(mp.maps.prefix(10))
			return mp
		}
		
		let mp = AllMaps()
		for _ in 0..<10 {
			mp.maps.append(KeyMap(isActive: false))
		}
		return mp
	}
	func save() {
		self.lastUpdate = Date.now.timeIntervalSince1970
		if let data = try? JSONEncoder().encode(self)
		{
			UserDefaults.standard.set(data, forKey: "AllMaps")
		}
	}
}
