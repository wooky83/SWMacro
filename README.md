# Swift Macros Dashboard

Macros are a power feature in a number of programming languages that make the language more extensible. Swift has always sought to enable expressive libraries through its use of type inference, generics, and general approach toward clarity of use. Macros in Swift are intended to improve expressiveness without sacrificing clarity.

This gist provides a "dashboard" with links to the various documents and example projects that are part of the Swift Macros effort. Head on over to the [Swift Forums](https://forums.swift.org) if you have questions!

Overview and examples:
* [Macros vision document](https://github.com/apple/swift-evolution/blob/main/visions/macros.md): lays out the overall motivation, goals, and approach we're taking in the implementation of macros in Swift.
* [Example macros repository](https://github.com/DougGregor/swift-macro-examples): contains a number of example macros that demonstrate the capabilities of the macro system and how it integrates into the language. This requires a [nightly snapshot](https://www.swift.org/download/#snapshots) of the Swift toolchain.
* [Power assertions](https://github.com/kishikawakatsumi/swift-power-assert): contains an implementation of "power asserts" (also called "diagrammed asserts") using macros.

Proposal documents:
* (Accepted) [SE-0382: Expression macros](https://github.com/DougGregor/swift-evolution/blob/se-0382-expression-macros-updates/proposals/0382-expression-macros.md): the first of the macro proposals, introducing the ability to use a macro anywhere that an expression is allowed. Macro expansions are written as something like `#powerAssert(x > y)` in the source code.
* (Accepted) [SE-0389: Attached Macros](https://github.com/apple/swift-evolution/blob/main/proposals/0389-attached-macros.md): extends the custom attribute syntax so that macros can create new code that extends existing code, such as `@AddCompletionHandler` to add a completion-handler version of an `async` function or `@DictionaryStorage` to rewrite the stored properties of a type into accesses to a shared storage dictionary.
* [SE-0394 Package Manager Support for Custom Macros](https://github.com/apple/swift-evolution/blob/main/proposals/0394-swiftpm-expression-macros.md): extends the Swift Package Manager manifest format to define macro targets, making macros easy to build and use.
* [Freestanding macros](https://github.com/DougGregor/swift-evolution/blob/freestanding-macros/proposals/nnnn-freestanding-macros.md): extends the syntax introduced by expression macros to enable macros that create statements and declarations. 

The proposals above are mostly implemented as of the April 11, 2023 [Swift toolchain snapshots](https://www.swift.org/download/#snapshots).
