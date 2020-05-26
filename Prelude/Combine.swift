import Combine
import Foundation
import SwiftUI

/// Collection of publisher extensions for working with SwiftUI
public extension Publisher {
  /// toggles the loading binding on/off when publisher completes
  func activity(_ loading: Binding<Bool>) -> AnyPublisher<Output, Failure> {
    loading.wrappedValue = true
    return handleEvents(receiveCompletion: { _ in
      loading.wrappedValue = false
    }).eraseToAnyPublisher()
  }

  /// set error binding when publisher completes
  func error(_ error: Binding<Error?>) -> AnyPublisher<Output, Failure> {
    handleEvents(receiveCompletion: { completion in
      switch completion {
      case .finished:
        error.wrappedValue = nil
      case let .failure(failure):
        error.wrappedValue = failure as NSError
      }
    }).eraseToAnyPublisher()
  }
}
