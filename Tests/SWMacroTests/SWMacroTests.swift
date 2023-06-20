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

    func testMacroWithStringLiteral() {
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
                static let shared = MySingleTone ()
            }
            """,
            macros: ["SingleTon": SingleTonMacro.self]
        )
    }
}
