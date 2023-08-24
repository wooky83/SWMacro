import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SWMacroMacros

let testMacros: [String: Macro.Type] = [
    "stringify": StringifyMacro.self,
]

final class SWMacroTests: XCTestCase {
    func testMacro() {
        assertMacroExpansion(
            """
            #stringify(a + b)
            """,
            expandedSource: """
            (a + b, "a + b")
            """,
            macros: testMacros
        )
    }

    func testStringLiteralMacro() {
        assertMacroExpansion(
            #"""
            #stringify("Hello, \(name)")
            """#,
            expandedSource: #"""
            ("Hello, \(name)", #""Hello, \(name)""#)
            """#,
            macros: testMacros
        )
    }

    func testUnwrapMacro() {
        assertMacroExpansion(
            #"""
            let xx: Int? = 6
            let x = #unwrap(xx, message: "fail")
            """#,
            expandedSource: #"""
            let xx: Int? = 6
            let x = { [wrappValue = xx] in
                guard let wrappValue else {
                    preconditionFailure("fail")
                }
                return wrappValue
            }()
            """#,
            macros: ["unwrap": UnwrapMacro.self]
        )
    }

    func testSingleTonMacro() {
        assertMacroExpansion(
            """
            @SingleTon
            class MySingleTone {
                var variable1: Int?
                var variable2: Int?
            }
            """,
            expandedSource: """

            class MySingleTone {
                var variable1: Int?
                var variable2: Int?

                private init() {
                }

                static let shared = MySingleTone()
            }
            """,
            macros: ["SingleTon": SingleTonMacro.self]
        )
    }

    func testPublicSingleTonMacro() {
        assertMacroExpansion(
            #"""
            @SingleTon
            public struct MySingleTone {
                var variable1: Int?
                var variable2: Int?
            }
            """#,
            expandedSource: #"""

            public struct MySingleTone {
                var variable1: Int?
                var variable2: Int?

                private init() {
                }

                public static let shared = MySingleTone()
            }
            """#,
            macros: ["SingleTon": SingleTonMacro.self]
        )
    }

    func testPublicMemberwiseInitMacro() {
        assertMacroExpansion(
            """
            @publicMemberwiseInit
            class MemberWiseInit {
                let intType: Int
            }
            """,
            expandedSource: """
            
            class MemberWiseInit {
                let intType: Int

                public init(intType: Int) {
                    self.intType = intType
                }
            }
            """,
            macros: ["publicMemberwiseInit": PublicMemberwiseInitMacro.self]
        )
    }

    func testURLMacro() {
        assertMacroExpansion(
            #"""
            #URL("http://www.naver.com")
            """#,
            expandedSource: #"""
            URL(string: "http://www.naver.com")!
            """#,
            macros: ["URL": URLMacro.self]
        )
    }

    func testAssociatedObjectMacro() {
        assertMacroExpansion(
            #"""
            class AssociatedClass { }
            extension AssociatedClass {
                @AssociatedObject(.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                var intValue: Int
                @AssociatedObject(.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                var StringValue: String = "Hello World!!"
            }
            """#,
            expandedSource: #"""
            class AssociatedClass { }
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
                var StringValue: String = "Hello World!!" {
                    get {
                      if let associatedObject = objc_getAssociatedObject(
                          self,
                          &Self.__associated_StringValueKey
                      ) as? String  {
                          return associatedObject
                      }
                      let variable = "Hello World!!"
                      objc_setAssociatedObject(
                          self,
                          &Self.__associated_StringValueKey,
                          variable,
                          .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                      )
                      return variable
                    }
                    set {
                      objc_setAssociatedObject(
                          self,
                          &Self.__associated_StringValueKey,
                          newValue,
                          .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                      )
                    }
                }

                fileprivate static var __associated_StringValueKey: UInt8 = 0
            }
            """#,
            macros: ["AssociatedObject": AssociatedObjectMacro.self]
        )
    }

    func testDictionaryStorageMacro() {
        assertMacroExpansion(
            #"""
            @DictionaryStorage
            struct MyPoint {
                var a: Int? = nil
                var x: Int = 1
                var y: String = "2"
                var z: Bool = true
            }
            """#,
            expandedSource: #"""

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
            """#,
            macros: ["DictionaryStorage": DictionaryStorageMacro.self, "DictionaryAccessor": DictionaryAccessorMacro.self]
        )
    }

    func testCodingKeysMacro() {
        assertMacroExpansion(
            #"""
            @Codable
            struct Coding {
                let id: String
                @CodingKey(key: "birth_day")
                let birthDay: Int
            }
            """#,
            expandedSource: #"""
            struct Coding {
                let id: String
                let birthDay: Int

                enum CodingKeys: String, CodingKey {
                  case id
                  case birthDay = "birth_day"
                }
            }
            
            extension Coding: Codable {
            }
            """#,
            macros: ["Codable": CodeableMacro.self, "CodingKey": CodingKeyMacro.self]
        )
    }
}
