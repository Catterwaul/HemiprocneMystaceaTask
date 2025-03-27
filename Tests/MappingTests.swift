import HMError
import HMTask
import Testing

struct MappingTests { }

extension MappingTests {
  struct Standard {
    @Test func flatMap() async throws {
      try await Self.test { task in
        task.flatMap { string in
            .init { try transform(string) }
        }
      }
    }

    @Test func map() async throws {
      try await Self.test { $0.map(transform) }
    }
  }
}

private extension MappingTests.Standard {
  private typealias Task<Success> = _Concurrency.Task<Success, any Error>

  private static func test(_ map: (Task<String>) -> Task<Int>) async throws {
    successToSuccess: do {
      let task = map(.init { "1" })
      #expect(try await task.value == 1)
    }
    transformThrows: do {
      let task = map(.init { "🏅" })
      await #expect(throws: nil as Int?.Nil) { try await task.value }
    }
    failurePropagates: do {
      let task = map(.init { throw SomeError() })
      await #expect(throws: SomeError()) { try await task.value }
    }
  }

  private func transform(_ string: String) throws -> Int {
    try .init(string).get()
  }
}

extension MappingTests {
  struct FailureIsNever {
    @Test func flatMap() async {
      await Self.test { task in
        task.flatMap { string in
          .init { transform(string) }
        }
      }
    }

    @Test func map() async {
      await Self.test { $0.map(transform) }
    }
  }
}

private extension MappingTests.FailureIsNever {
  private typealias Task<Success> = _Concurrency.Task<Success, Never>

  private static func test(_ map: (Task<String>) -> Task<Int>) async {
    let task = map(.init { "1" })
    #expect(await task.value == 1)
  }

  func transform(_ string: String) -> Int {
    .init(string)!
  }
}

extension MappingTests {
  struct FailureIsNotNever {
    @Test func flatMapFailure() async throws {
      try await Self.testMap { task in
        task.flatMapFailure { error throws(Int?.Nil) in
          .init { throw transform(error) }
        }
      }
    }

    @Test func mapFailure() async throws {
      try await Self.testMap { $0.mapFailure(transform) }
    }

    @Test func mapFailureToSuccess() async {
      typealias Task<Failure: Error> = _Concurrency.Task<String, Failure>
      let original = "😵"
      let transformed = "🧟"
      func map<Failure>(_ task: Task<Failure>) -> Task<Never> {
        task.mapFailureToSuccess { _ in transformed }
      }

      successToSuccess: do {
        let task = map(.init { () throws in original })
        #expect(await task.value == original)
      }
      transformErrorToSuccess: do {
        let task = map(.init { throw SomeError() })
        #expect(await task.value == transformed)
      }
    }

    @Test func mapFailureToSuccessAndErrorToFailure() async throws {
      func map(_ transform: sending @escaping (any Error) throws -> String) -> Task {
        .init { throw SomeError() }.mapFailureToSuccessAndErrorToFailure(transform)
      }

      failureToSuccess: do {
        let success = "🏅"
        let task = map { _ in success }
        #expect(try await task.value == success)
      }
      errorToFailure: do {
        let task = map { error in throw error }
        await #expect(throws: SomeError()) { try await task.value }
      }
    }
  }
}

private extension MappingTests.FailureIsNotNever {
  private typealias Task = _Concurrency.Task<String, any Error>

  private static func testMap(_ mapError: (Task) -> Task) async throws {
    successToSuccess: do {
      let task = mapError(.init { "1" })
      #expect(try await task.value == "1")
    }
    transform: do {
      let task = mapError(.init { throw nil as Int?.Nil })
      await #expect(throws: SomeError()) { try await task.value }
    }
  }

  private func transform(_: some Error) -> SomeError { .init() }
}
