//
//  LoginClient.swift
//  LearnAsync
//
//  Created by Cong Le on 09/03/2024.
//

import Foundation
import Combine

enum LoginStatus {
	case notStarted
	case inProgress
	case success
	case failure
}

protocol LoginProviding {
	func login(email: String, password: String) async -> AsyncStream<LoginStatus>
}

class LoginNetworkClient: LoginProviding {
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

