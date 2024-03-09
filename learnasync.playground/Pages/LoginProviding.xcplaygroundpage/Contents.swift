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


class MockLoginProvider: Mock<LoginProviding>, LoginProviding {
	var statuses: [LoginStatus] = []
	private var currentIndex = 0
	
	func login(email: String, password: String) async -> AsyncStream<LoginStatus> {
		accept(args: [email, password])
		return AsyncStream { continuation in
			for status in statuses {
				continuation.yield(status)
			}
			continuation.finish()
		}
	}
}


class LoginEntity {
	let loginClient: LoginProviding
	
	var overlayText: String = ""
	
	init(loginClient: LoginProviding) {
		self.loginClient = loginClient
	}
	
	func login() {
		Task {
			for await status in await loginClient.login(email: "test@example.com", password: "password") {
				switch status {
				case .notStarted:
					overlayText = "Login not started"
				case .inProgress:
					overlayText = "Login in progress"
				case .success:
					overlayText = "Login successful"
				case .failure:
					overlayText = "Login failed"
				}
				print(overlayText)
			}
		}
	}
}

//let entity = LoginEntity(loginClient: mockLoginClient)
//entity.login()

import XCTest

class LoginEntityTest: XCTestCase {
	
	private let mockLoginProvider = MockLoginProvider.create()
	
	private func verify(file: StaticString = #file,
						line: UInt = #line) {
		mockLoginProvider.verify(file: file, line: line)
	}

	func testLoginEntityOverlayText() {
		
		let entity = LoginEntity(loginClient: mockLoginProvider)
		
		mockLoginProvider.statuses = [.notStarted, .inProgress, .success]
		
		entity.login()
		
		verify()
	}
}

let test = LoginEntityTest()
test.testLoginEntityOverlayText()
