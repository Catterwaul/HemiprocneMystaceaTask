# Mapping Methods

##

These are, with the exceptions detailed below, asynchronous versions of exactly what you'll find in [HemiprocneMystaceaResult](https://catterwaul.github.io/HemiprocneMystaceaResult/documentation/hmresult/mapping-methods).

### flatMap / map

With a synchronous wrapper, like `Result`, a success-mapping transformation can throw a different type of error than the wrapper's own error type. 

You can still throw two different error types, when mapping `Task`s. But there's no way to preserve either of the error types, in the resulting `Task`, in doing so. 

Mapping a `Task` is synchronous—it's just storing a transformation function for later use. But waiting for a `Task` to be evaluated, to see if it throws an error, is asynchronous. Mapping methods have to handle the possibility of the `Task` failing, or the transformation failing. You've got to be able to deal with both the unmapped, and mapped, error types. This requires the transformed `Task`'s error type to be `any Error`.

**There is an exception:**

If the original `Task`'s error type is `Never`, the `Error` type of the transformation could, in theory, match the transformed `Task`'s. 

In practice, this is possible, but only when the transformation also *doesn't* throw. `Never` can be preserved in the transformed `Task`.

The reason for this is that, unfortunately, while `Task`s technically can use any type of error, there is no way to create a `Task` whose `Failure` is anything except `Never` or `any Error`. Hopefully this limitation will be lifted soon.

### flatMapAndMergeError / mapAndMergeError

In theory, these would also be exceptions. An error type should be able to be preserved, if only one is used across the transformation.

But for now, "merging error" overloads are not possible. You can perform the transformation, but the error type will be erased.

### flatMapFailure / mapFailure

In the future, these may be able to provide a true mapping to new `Task` type, with a typed `Failure`. For now, it at least can still transform an error—the result just needs to be erased to `any Error`.

### mapFailureToSuccess / mapFailureToSuccessAndErrorToFailure

Only an overload with a non-throwing transformation is provided, for `mapFailureToSuccess`. Unlike with `Result`, the only other option for handling transformation errors is `mapFailureToSuccessAndErrorToFailure`.

## Topics

- ``_Concurrency/Task/flatMap(_:)->Task<NewSuccess,Error>``
- ``_Concurrency/Task/map(_:)->Task<NewSuccess,Error>``

### Failure == Never

- ``_Concurrency/Task/flatMap(_:)->Task<NewSuccess,Never>``
- ``_Concurrency/Task/map(_:)->Task<NewSuccess,Never>``

### Failure != Never

These compile when Failure == Never, but will generate warnings, and can't actually do anything there, because a `Never` cannot be transformed. 

- ``_Concurrency/Task/flatMapFailure(_:)``
- ``_Concurrency/Task/mapFailure(_:)``
- ``_Concurrency/Task/mapFailureToSuccess(_:)``
- ``_Concurrency/Task/mapFailureToSuccessAndErrorToFailure(_:)``
