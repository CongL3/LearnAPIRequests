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

Task {
	let jwksClient = JWKSClient()
	let keyExchangeClient = KeyExchangeClient()
	let viewCardClient = ViewCardClient()
	
	let jwks = try await jwksClient.fetchJWKS()
	let jws = try await keyExchangeClient.exchange(key: OKP(value: "key"))
	let card = try await viewCardClient.getCardDetails()
	
	print("card \(card)")
}

