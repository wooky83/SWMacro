import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct AssociatedObjectMacro {}

extension AssociatedObjectMacro: PeerMacro {
    public static func expansion(of node: AttributeSyntax,
                                 providingPeersOf declaration: some DeclSyntaxProtocol,
                                 in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier else {
            throw MacroError.message("`@AssociatedObject` must be appended to the property declaration.")
        }

        let keyDecl = VariableDeclSyntax(
            bindingKeyword: .identifier("fileprivate static var"),
            bindings: PatternBindingListSyntax {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: .identifier("__associated_\(identifier)Key")),
                    typeAnnotation: .init(type: SimpleTypeIdentifierSyntax(name: .identifier("UInt8"))),
                    initializer: InitializerClauseSyntax(value: ExprSyntax(stringLiteral: "0"))
                )
            }
        ).formatted().as(VariableDeclSyntax.self)!

        return [DeclSyntax(keyDecl)]
    }

}

extension AssociatedObjectMacro: AccessorMacro {
    public static func expansion(of node: AttributeSyntax,
                                 providingAccessorsOf declaration: some DeclSyntaxProtocol,
                                 in context: some MacroExpansionContext) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier else {
            throw MacroError.message("`@AssociatedObject` must be appended to the property declaration.")
        }
        
        guard let type = binding.typeAnnotation?.type else {
            throw MacroError.message("Specify a type explicitly")
        }

        if binding.accessor != nil{
            throw MacroError.message("`accessor should not be specified.")
        }
        
        guard case let .argumentList(arguments) = node.argument,
              let firstElement = arguments.first?.expression,
              let policy = firstElement.as(MemberAccessExprSyntax.self) else {
            throw MacroError.message("`must be objc_AssociationPolicy specified.")
        }
        
        let defaultValue = binding.initializer?.value ?? "\(type)()"

        let getAccessor: AccessorDeclSyntax =
          """
          get {
            if let associatedObject = objc_getAssociatedObject(
                self,
                &Self.__associated_\(identifier)Key
            ) as? \(type) {
                return associatedObject
            }
            let variable = \(raw: defaultValue)
            objc_setAssociatedObject(
                self,
                &Self.__associated_\(identifier)Key,
                variable,
                \(policy)
            )
            return variable
          }
          """

        let setAccessor: AccessorDeclSyntax =
          """
          set {
            objc_setAssociatedObject(
                self,
                &Self.__associated_\(identifier)Key,
                newValue,
                \(policy)
            )
          }
          """

        return [getAccessor, setAccessor]
    }

}
