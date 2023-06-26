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

/// SingleTone init
@attached(member, names: named(init), named(shared))
public macro SingleTon() = #externalMacro(module: "SWMacroMacros", type: "SingleTonMacro")


/// Struct or Class automate Init
@attached(member, names: named(init))
public macro publicMemberwiseInit() = #externalMacro(module: "SWMacroMacros", type: "PublicMemberwiseInitMacro")


/// URL init
@freestanding(expression)
public macro URL(_ stringLiteral: String) -> URL = #externalMacro(module: "SWMacroMacros", type: "URLMacro")


// Creating a store property in an extension
@attached(peer, names: arbitrary)
@attached(accessor)
public macro AssociatedObject(_ policy: objc_AssociationPolicy) = #externalMacro(module: "SWMacroMacros", type: "AssociatedObjectMacro")


/// Wrap up the stored properties of the given type in a dictionary,
/// turning them into computed properties
@attached(accessor)
@attached(member, names: named(_storage))
@attached(memberAttribute)
public macro DictionaryStorage() = #externalMacro(module: "SWMacroMacros", type: "DictionaryStorageMacro")
