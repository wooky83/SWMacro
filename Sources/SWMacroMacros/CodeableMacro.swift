import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct CodeableMacro {}

extension CodeableMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let cases: [String] = declaration.memberBlock.members.compactMap { member in
            guard let variableDecl = member.decl.as(VariableDeclSyntax.self) else { return nil }
            guard let property = variableDecl.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else { return nil }
            if let attributedElement = variableDecl.attributes.getAttributedElement("CodingKey"), let expression = attributedElement.getExprSyntax() {
                return "case \(property) = \(expression)"
            } else {
                return "case \(property)"
            }
        }
        let codingKeysDecl: DeclSyntax = """
        enum CodingKeys: String, CodingKey {
          \(raw: cases.joined(separator: "\n  "))
        }
        """
        return [codingKeysDecl]
    }

}

extension CodeableMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let inheritanceClause: InheritanceClauseSyntax? =
        if let classDeclaration = declaration.as(ClassDeclSyntax.self) {
            classDeclaration.inheritanceClause
        } else if let structDeclaration = declaration.as(StructDeclSyntax.self) {
            structDeclaration.inheritanceClause
        } else {
            throw MacroError.invalidInputType
        }

        if let inheritedTypes = inheritanceClause?.inheritedTypes,
           inheritedTypes.contains(where: { inherited in inherited.type.trimmedDescription == "Codable" }) {
            return []
        }

        let codableExtension: DeclSyntax =
        """
        extension \(type.trimmed): Codable {}
        """
        guard let extensionDecl = codableExtension.as(ExtensionDeclSyntax.self) else { return [] }

        return [extensionDecl]
    }
}

public struct CodingKeyMacro: PeerMacro {
    public static func expansion(of node: AttributeSyntax,
                                 providingPeersOf declaration: some DeclSyntaxProtocol,
                                 in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        []
    }
}
