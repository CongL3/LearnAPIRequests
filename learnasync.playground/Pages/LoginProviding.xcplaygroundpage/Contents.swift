//: [Previous](@previous)

import Foundation
import Combine

var greeting = "Hello, playground"

enum LoginStatus {
	case notStarted
	case inProgress
	case success
	case failure
}

protocol LoginProviding {
	func login(email: String, password: String) async -> AsyncStream<LoginStatus>
}

class LoginClient: LoginProviding {
	func login(email: String, password: String) async -> AsyncStream<LoginStatus> {
		let subject = PassthroughSubject<LoginStatus, Never>()
		
		subject.send(.notStarted)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			subject.send(.inProgress)
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
				subject.send(.success)
				
				subject.send(completion: .finished)
			}
		}
		
		return AsyncStream { continuation in
			let subscription = subject.sink { status in
				continuation.yield(status)
			}
			
			continuation.onTermination = { @Sendable _ in
				subscription.cancel()
			}
		}
	}
}

class LoginEntity {
	let loginClient: LoginProviding
	
	init(loginClient: LoginProviding) {
		self.loginClient = loginClient
	}
	
	func login() {
		Task {
			do {
				for await status in await loginClient.login(email: "test@example.com", password: "password") {
					switch status {
					case .notStarted:
						print("Login not started")
					case .inProgress:
						print("Login in progress")
					case .success:
						print("Login successful")
					case .failure:
						print("Login failed")
					}
				}
			} catch {
				print("Error: \(error)")
			}
		}
	}
}

class TestLoginProvider: LoginProviding {
	var statuses: [LoginStatus] = []
	private var currentIndex = 0
	
	func login(email: String, password: String) async -> AsyncStream<LoginStatus> {
		return AsyncStream { continuation in
			for status in statuses {
				continuation.yield(status)
			}
			continuation.finish()
		}
	}
}


let testProvider = TestLoginProvider()
testProvider.statuses = [.notStarted, .inProgress, .success]

let entity = LoginEntity(loginClient: testProvider)
entity.login()

