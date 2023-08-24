[![SWMacro SPM Build and Test](https://github.com/wooky83/SWMacro/actions/workflows/swift.yml/badge.svg)](https://github.com/wooky83/SWMacro/actions/workflows/swift.yml)
[![Xcode 15.0](https://img.shields.io/badge/Xcode-15.0-147EFB?style=flat-square&logo=xcode&link=https%3A%2F%2Fdeveloper.apple.com%2Fxcode%2F)](https://developer.apple.com/xcode/)
# Swift Macros :rocket:

## Learning Resources :books:

### **Tools**
- [Swift AST Explorer](https://swift-ast-explorer.com/)
  - This is extremely helpful when working with [SwiftSyntax](https://github.com/apple/swift-syntax), I used this when writing [Sourcery](https://github.com/krzysztofzablocki/Sourcery) parser and you can leverage it to build your own Macros. 

### **Apple:**

Dive into Swift Macros with these WWDC sessions:

- [Write Swift Macros](https://developer.apple.com/videos/play/wwdc2023-10166): An introductory session on Macros, their roles, and workings with a basic example.
- [Expand Swift Macros](https://developer.apple.com/videos/play/wwdc2023-10167): A deeper exploration into crafting your Macros and testing their functionality.

### Swift Macros Dashboard

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

---

## Usage :computer:
### unwrap 
* macro
```swift
let optionalValue: Int? = 5
let unwrapValue = #unwrap(optionalValue, message: "❌")
```
* expand Macro
```swift
let optionalValue: Int? = 5
let unwrapValue = #unwrap(optionalValue, message: "❌")
{ [wrappValue = optionalValue] in
    guard let wrappValue else {
        preconditionFailure("❌")
    }
    return wrappValue
}()
```
### SingleTon
* macro
```swift
@SingleTon
class MySingleTone {
    var variable1: Int?
    var variable2: Int?
}
```
* expand Macro
```swift
@SingleTon
class MySingleTone {
    var variable1: Int?
    var variable2: Int?
    private init() {}
    static let shared = MySingleTone()
}
```

### publicMemberwiseInit
* macro
```swift
@publicMemberwiseInit
class MemberWiseInit {
    let intType: Int
    var stringType: Bool
}
```
* expand Macro
```swift
@publicMemberwiseInit
class MemberWiseInit {
    let intType: Int
    var stringType: Bool
    public init(intType: Int, stringType: Bool) {
        self.intType = intType
        self.stringType = stringType
    }
}
```

### URL
* macro
```swift
let url = #URL("http://www.naver.com")
```
* expand Macro
```swift
let url = #URL("http://www.naver.com")
URL(string: "http://www.naver.com")!
```

### AssociatedObject
* macro
```swift
class AssociatedClass { }
extension AssociatedClass {
    @AssociatedObject(.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    var intValue: Int
}
```
* expand Macro
```swift
class AssociatedClass {
}
extension AssociatedClass {
    var intValue: Int {
        get {
            if let associatedObject = objc_getAssociatedObject(
                self,
                &Self.__associated_intValueKey
            ) as? Int {
                return associatedObject
            }
            let variable = Int()
            objc_setAssociatedObject(
                self,
                &Self.__associated_intValueKey,
                variable,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            return variable
        }
        set {
            objc_setAssociatedObject(
                self,
                &Self.__associated_intValueKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    fileprivate static var __associated_intValueKey: UInt8 = 0
}
```

### DictionaryStorage
* macro
```swift
@DictionaryStorage
struct MyPoint {
    var a: Int? = nil
    var x: Int = 1
    var y: String = "2"
    var z: Bool = true
}
```
* expand Macro
```swift
struct MyPoint {
    var a: Int? = nil {
        get {
            _storage["a"] as! Int?
        }
        set {
            _storage["a"] = newValue
        }
    }
    var x: Int = 1 {
        get {
            _storage["x", default: 1] as! Int
        }
        set {
            _storage["x"] = newValue
        }
    }
    var y: String = "2" {
        get {
            _storage["y", default: "2"] as! String
        }
        set {
            _storage["y"] = newValue
        }
    }
    var z: Bool = true {
        get {
            _storage["z", default: true] as! Bool
        }
        set {
            _storage["z"] = newValue
        }
    }
    var _storage: [String: Any] = ["x": 1, "y": "2", "z": true]
}
```

### CodingKeys
* macro
```swift
@CodingKeys
struct MyPerson {
    let id: String
    @CodingKeys(key: "_age")
    let age: Int
}
```
* expand Macro
```swift
struct MyPerson {
    let id: String
    let age: Int
    enum CodingKeys: String, CodingKey {
        case id
        case age = "_age"
    }
}
extension MyPerson : Codable {

}
```

## OS Macro
```swift 
@OptionSet<UInt>
```
```swift
#warning("Warning👆")
```
```swift 
#error("Error")
```
