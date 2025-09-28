import HMTask
import Testing
import Thrappture

struct TaskTests {
  @Test func `?? operator`() async {
    struct Failure: Error { }
    let task = Task<String, _> { throw Failure() }

    `non-throwing`: do {
      let success = "🥇"
      #expect(await task ?? success == success)
    }

    `throwing`: do {
      var error: String {
        get throws(Failure) { throw .init() }
      }
      await #expect(throws: Failure.self) {
        try await task ?? { try error }
      }
    }
  }

  @Test func reduce() async {
    enum Failure: Error { case failure }
    var task = Task<Int, _> { throw Failure.failure }
    func reduce() async -> Int { await task.reduce(1, +) }
    #expect(await reduce() == 1)
    task = .init { 2 }
    #expect(await reduce() == 3)
  }

  struct Duplicates {
    struct NeverFailure {
      @Test func zip() async {
        let jenies = (Task { "👖" }, Task { "🧞‍♂️" })
        #expect(
          await Task.zip(jenies).value == ("👖", "🧞‍♂️")
        )
      }
    }

    struct anyErrorFailure {
      @Test func zip() async throws {
        let jenies = (
          Task<_, any Error> { "👖" },
          Task { throw nil as String?.Nil }
        )
        await #expect(throws: String?.Nil.self) {
          try await Task.zip(jenies).value
        }
      }
    }
  }
}
