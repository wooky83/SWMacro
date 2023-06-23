import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct SingleTonMacro: MemberMacro {
    public static func expansion<Declaration: DeclGroupSyntax,
                                 Context: MacroExpansionContext>(of node: AttributeSyntax,
                                                                 providingMembersOf declaration: Declaration,
                                                                 in context: Context) throws -> [DeclSyntax] {
        let singleToneKeyword =
        if let clsDecl = declaration.as(ClassDeclSyntax.self) {
            clsDecl.identifier
        } else if let strDecl = declaration.as(StructDeclSyntax.self) {
            strDecl.identifier
        } else {
            throw MacroError.invalidInputType
        }

        let publicACL: TokenSyntax =
        if let modifiers = declaration.modifiers,
           modifiers.map(\.name.tokenKind).contains(where: {
               if case .keyword(.public) = $0 {
                   return true
               }
               return false
           }) {
            "public "
        } else {
            ""
        }

        let sharedVariable: DeclSyntax =
        """
        \(publicACL)static let shared = \(raw: singleToneKeyword.text)()
        """

        let initializer = try InitializerDeclSyntax("private init()") { }
        return [DeclSyntax(initializer), sharedVariable]
    }
}
