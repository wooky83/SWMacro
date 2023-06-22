import Foundation
// The Swift Programming Language
// https://docs.swift.org/swift-book

/// A macro that produces both a value and a string containing the
/// source code that generated the value. For example,
///
///     #stringify(x + y)
///
/// produces a tuple `(x + y, "x + y")`.
@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "SWMacroMacros", type: "StringifyMacro")

// The #unwrap expression macro
/// Force-unwraps the optional value passed to `expr`.
/// - Parameter message: Failure message, followed by `expr` in single quotes
@freestanding(expression)
public macro unwrap<Wrapped>(_ expr: Wrapped?, message: String) -> Wrapped = #externalMacro(module: "SWMacroMacros", type: "UnwrapMacro")

@attached(member, names: named(init), named(shared))
public macro SingleTon() = #externalMacro(module: "SWMacroMacros", type: "SingleTonMacro")

@attached(member, names: named(init))
public macro publicMemberwiseInit() = #externalMacro(module: "SWMacroMacros", type: "PublicMemberwiseInitMacro")

@freestanding(expression)
public macro URL(_ stringLiteral: String) -> URL = #externalMacro(module: "SWMacroMacros", type: "URLMacro")
