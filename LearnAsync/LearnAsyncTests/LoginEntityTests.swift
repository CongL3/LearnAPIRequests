//
//  LoginEntityTests.swift
//  LearnAsyncTests
//
//  Created by Cong Le on 09/03/2024.
//

import XCTest
@testable import LearnAsync

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

final class LoginEntityTest: XCTestCase {
	
	private let mockLoginProvider = MockLoginProvider.create()
	private var sut: LoginEntity!

	private func verify(file: StaticString = #file,
						line: UInt = #line) {
		mockLoginProvider.verify(file: file, line: line)
	}
	
	func createSUT() {
		sut = LoginEntity(loginClient: mockLoginProvider)
	}
	
	func testLoginEntityOverlayText() {
		
		// given
		let expectedEmail = "email"
		let expectedPassword = "password"
		mockLoginProvider.statuses = [.notStarted, .inProgress, .success]

		// create
		createSUT()
		
		// expect
		mockLoginProvider.expect { mock in
			mock.login(email: expectedEmail, password: expectedPassword)
		}
		
		// when
		sut.login(email: expectedEmail, password: expectedPassword)
		
		// then
		verify()
	}
}
