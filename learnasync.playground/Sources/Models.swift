import Foundation

public struct Pokemon: Codable {
	public let name: String
	public let id: Int
	public let sprites: Sprites
}

public struct Sprites: Codable {
	public let frontDefault: URL
	
	public enum CodingKeys: String, CodingKey {
		case frontDefault = "front_default"
	}
}

