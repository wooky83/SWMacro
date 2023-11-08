import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct DictionaryStorageMacro { }

extension DictionaryStorageMacro: MemberMacro {
    public static func expansion<Declaration, Context>(of node: SwiftSyntax.AttributeSyntax, providingMembersOf declaration: Declaration, in context: Context) throws -> [SwiftSyntax.DeclSyntax] where Declaration : SwiftSyntax.DeclGroupSyntax, Context : SwiftSyntaxMacros.MacroExpansionContext {
        guard let structDeclaration = declaration.as(StructDeclSyntax.self) else { return [] }
        let values = structDeclaration.storedProperties()
        
        let resultValues = values.compactMap { value -> String? in
            guard let patternBinding = value.bindings.first?.as(PatternBindingSyntax.self) else { return nil }
            guard let name = patternBinding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
                  let _ = patternBinding.typeAnnotation?.as(TypeAnnotationSyntax.self)?.type.as(IdentifierTypeSyntax.self),
                    let value = patternBinding.initializer?.as(InitializerClauseSyntax.self)?.value else { return nil }
            return """
                    "\(name)": \(value)
                    """
        }.joined(separator: ",")

        let storage: DeclSyntax = "var _storage: [String: Any] = [\(raw: resultValues)]"
        return [storage.with(\.leadingTrivia, [.newlines(1), .spaces(2)])]
    }
}

extension DictionaryStorageMacro: MemberAttributeMacro {
    public static func expansion<Declaration, MemberDeclaration, Context>(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: Declaration, providingAttributesFor member: MemberDeclaration, in context: Context) throws -> [SwiftSyntax.AttributeSyntax] where Declaration : SwiftSyntax.DeclGroupSyntax, MemberDeclaration : SwiftSyntax.DeclSyntaxProtocol, Context : SwiftSyntaxMacros.MacroExpansionContext {
        guard let property = member.as(VariableDeclSyntax.self), property.isStoredProperty else { return [] }

        return [
            AttributeSyntax(
                attributeName: IdentifierTypeSyntax(
                    name: .identifier("DictionaryAccessor")
                )
            )
            .with(\.leadingTrivia, [.newlines(1), .spaces(2)])
        ]
    }

}

public struct DictionaryAccessorMacro { }

extension DictionaryAccessorMacro: AccessorMacro {
    public static func expansion(of node: AttributeSyntax,
                                 providingAccessorsOf declaration: some DeclSyntaxProtocol,
                                 in context: some MacroExpansionContext) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
              binding.accessorBlock == nil,
              let type = binding.typeAnnotation?.type else {
            return []
        }

        if identifier.text == "_storage" {
            return []
        }

        guard let defaultValue = binding.initializer?.value else {
            throw MacroError.message("stored property must have an initializer")
        }

        let dictionaryDefaultValue: ExprSyntax =
            if binding.typeAnnotation?.as(TypeAnnotationSyntax.self)?.type.as(IdentifierTypeSyntax.self) != nil {
                ", default: \(defaultValue)"
            } else {
                ""
            }

        return [
            """

            get {
                _storage[\(literal: identifier.text)\(dictionaryDefaultValue)] as! \(type)
            }
            """,
            """

            set {
                _storage[\(literal: identifier.text)] = newValue
            }
            """
        ]
    }
}
