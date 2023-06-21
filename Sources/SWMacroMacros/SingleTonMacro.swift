import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct SingleTonMacro: MemberMacro {
    public static func expansion<Declaration, Context>(of node: SwiftSyntax.AttributeSyntax, providingMembersOf declaration: Declaration, in context: Context) throws -> [SwiftSyntax.DeclSyntax] where Declaration : SwiftSyntax.DeclGroupSyntax, Context : SwiftSyntaxMacros.MacroExpansionContext {
        guard let clsDecl = declaration.as(ClassDeclSyntax.self) else {
            return []
        }

        let initializer = try InitializerDeclSyntax("private init()") { }
        return [DeclSyntax(initializer),
                "static let shared = \(clsDecl.identifier)()"
        ]
    }
}
