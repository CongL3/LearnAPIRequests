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
//		accept(args: [email, password])
		accept()
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
	
	func testLoginEntityOverlayText() async {
		// given
		let expectedEmail = "email"
		let expectedPassword = "password"
		mockLoginProvider.statuses = [.notStarted, .inProgress, .success]
		
		// create
		createSUT()
		
		// expect
		mockLoginProvider.expectAsync { mock in
			await mock.login(email: expectedEmail, password: expectedPassword)
		}
		
		// when
		await sut.login(email: expectedEmail, password: expectedPassword)
		
		// Assert or verify the outcome if needed
	}

	func testFooLogin() {
		
		// given
		let expectedEmail = "email"
		let expectedPassword = "password"
		let mockFoo = MockFoo.create()
		
		// create
		let sut = FooLoginEntity(foo: mockFoo)
		
		// expect
		mockFoo.expect { mock in
			mock.login(email: expectedEmail, password: expectedPassword)
		}
		
		// when
		sut.login(email: expectedEmail, password: expectedPassword)
		
		verify()
	}

	func testFooLoginWithResponse() {
		
		// given
		let expectedEmail = "email"
		let expectedPassword = "password"
		let expectedResult = "Success"
		let mockFoo = MockFoo.create()
		
		// create
		let sut = FooLoginEntity(foo: mockFoo)
		
		// expect
		mockFoo.expect { mock in
			mock.loginWithResponse(email: expectedEmail, password: expectedPassword)
		}.returning(expectedResult)
		
		// when
		let result = sut.loginWithResponse(email: expectedEmail, password: expectedPassword)
		
		verify()
		XCTAssertEqual(result, expectedResult)
	}

}

class FooLoginEntity {
	
	let foo: Foo
	
	init(foo: Foo) {
		self.foo = foo
	}
	
	func login(email: String, password: String) {
		foo.login(email: email, password: password)
	}
	
	func loginWithResponse(email: String, password: String) -> String {
		return foo.loginWithResponse(email: email, password: password)
	}

}

protocol Foo {
	func login(email: String, password: String)
	func loginWithResponse(email: String, password: String) -> String

}

class MockFoo: Mock<Foo>, Foo {
	
	func login(email: String, password: String) {
		accept(args: [email, password])
	}

	func loginWithResponse(email: String, password: String) -> String {
		return accept() as! String
	}

}
