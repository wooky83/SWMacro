import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct PublicMemberwiseInitMacro: MemberMacro {
    public static func expansion(
           of attribute: AttributeSyntax,
           providingMembersOf declaration: some DeclGroupSyntax,
           in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let storedProperties: [VariableDeclSyntax] = try {
            if let classDeclaration = declaration.as(ClassDeclSyntax.self) {
                return classDeclaration.storedProperties()
            } else if let structDeclaration = declaration.as(StructDeclSyntax.self) {
                return structDeclaration.storedProperties()
            } else {
                throw MacroError.invalidInputType
            }
        }()

        let initArguments = storedProperties.compactMap(\.getNameAndType)

        let initBody: ExprSyntax = "\(raw: initArguments.map { "self.\($0.name) = \($0.name)" }.joined(separator: "\n"))"

        let initDeclSyntax = try InitializerDeclSyntax(
            PartialSyntaxNodeString(stringLiteral: "public init(\(initArguments.map { "\($0.name): \($0.type)" }.joined(separator: ", ")))"),
            bodyBuilder: {
                initBody
            }
        )

        let finalDeclaration = DeclSyntax(initDeclSyntax)

        return [finalDeclaration]
    }
}
