//: [Previous](@previous)

import Foundation

extension Task where Success == Never, Failure == Never {
	static func sleep(seconds: Double) async throws {
		let duration = UInt64(seconds * 1_000_000_000)
		try await Task.sleep(nanoseconds: duration)
	}
}

struct JWK {
	let value: String
}

struct JWS {
	let value: String
}

struct OKP {
	let value: String
}

struct Card {
	let pan: String
	let cvv: String
}


protocol JWKSClientProviding {
	func fetchJWKS() async throws -> [JWK]
}

class JWKSClient: JWKSClientProviding {
	func fetchJWKS() async throws -> [JWK] {
		try await Task.sleep(seconds: 2)
		return [JWK(value: "JWK1"), JWK(value: "JWK2")]
	}
}

class MockJWKSClient: JWKSClientProviding {
	var stub = [JWK(value: "JWK1"), JWK(value: "JWK2")]
	func fetchJWKS() async throws -> [JWK] {
		try await Task.sleep(seconds: 2)
		return stub
	}
}

protocol KeyExchangeProviding {
	func exchange(key: OKP) async throws -> JWS
}

class KeyExchangeClient: KeyExchangeProviding {
	func exchange(key: OKP) async throws -> JWS {
		try await Task.sleep(seconds: 2)
		return JWS(value: "JWS1")
	}
}

protocol ViewCardProviding {
	func getCardDetails() async throws -> Card
}

class ViewCardClient: ViewCardProviding {
	func getCardDetails() async throws -> Card {
		try await Task.sleep(seconds: 2)
		return Card(pan: "pan", cvv: "cvv")
	}
}


class Entity {
	
	let jwksClient: JWKSClientProviding
	let keyExchangeClient: KeyExchangeProviding
	let viewCardClient: ViewCardProviding
	
	init(jwksClient: JWKSClientProviding,
		 keyExchangeClient: KeyExchangeProviding,
		 viewCardClient: ViewCardProviding) {
		self.jwksClient = jwksClient
		self.keyExchangeClient = keyExchangeClient
		self.viewCardClient = viewCardClient
	}
	
	func getCardDetails() async throws -> Card {
//		let jwks = try await jwksClient.fetchJWKS()
//		let jws = try await keyExchangeClient.exchange(key: OKP(value: "key"))
		let card = try await viewCardClient.getCardDetails()
		return card
	}
}

let entity = Entity(jwksClient: MockJWKSClient(),
					keyExchangeClient: KeyExchangeClient(),
					viewCardClient: ViewCardClient())

Task {
	do {
		let card = try await entity.getCardDetails()
		print(card)
	} catch {
		print("Error: \(error)")
	}
}
