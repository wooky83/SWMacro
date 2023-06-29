import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct CodingKeysMacro {}

extension CodingKeysMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let cases: [String] = declaration.memberBlock.members.compactMap { member in
            guard let variableDecl = member.decl.as(VariableDeclSyntax.self) else { return nil }
            guard let property = variableDecl.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else { return nil }
            if let attributedElement = variableDecl.attributes?.getAttributedElement("CodingKeys"), let expression = attributedElement.getExprSyntax() {
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

extension CodingKeysMacro: ConformanceMacro {
    public static func expansion(of node: AttributeSyntax, providingConformancesOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [(TypeSyntax, GenericWhereClauseSyntax?)] {
        let inheritanceClause: TypeInheritanceClauseSyntax? =
        if let classDeclaration = declaration.as(ClassDeclSyntax.self) {
            classDeclaration.inheritanceClause
        } else if let structDeclaration = declaration.as(StructDeclSyntax.self) {
            structDeclaration.inheritanceClause
        } else {
            throw MacroError.invalidInputType
        }
        
        if let inheritedTypes = inheritanceClause?.inheritedTypeCollection,
           inheritedTypes.contains(where: { inherited in inherited.typeName.trimmedDescription == "Codable" }) {
          return []
        }
        
        return [("Codable", nil)]
    }
}
