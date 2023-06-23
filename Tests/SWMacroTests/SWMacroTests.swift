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
                var stringType: Bool
            }
            """,
            expandedSource: """
            
            class MemberWiseInit {
                let intType: Int
                var stringType: Bool
                public init(intType: Int, stringType: Bool) {
                    self.intType = intType
                    self.stringType = stringType
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

}
