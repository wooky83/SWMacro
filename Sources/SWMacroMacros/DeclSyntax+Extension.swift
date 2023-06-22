import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros


internal enum MacroError: Swift.Error, CustomStringConvertible {
    case invalidInputType

    var description: String {
        "@PublicMemberwiseInitMacro is only applicable to structs or classes"
    }
}

extension VariableDeclSyntax {
    var isStoredProperty: Bool {
        guard let biding = bindings.first, bindings.count == 1, !isLazyProperty, !isConstant else {
            return false
        }

        switch biding.accessor {
        case .none:
            return true
        case .accessors(let node):
            for accessor in node.accessors {
                switch accessor.accessorKind.tokenKind {
                case .keyword(.willSet), .keyword(.didSet):
                    break
                default:
                    return false
                }
            }
            return true
        case .getter:
            return false
        }
    }

    var isLazyProperty: Bool {
        modifiers?.contains { $0.name.tokenKind == .keyword(Keyword.lazy) } ?? false
    }

    var isConstant: Bool {
        bindingKeyword.tokenKind == .keyword(Keyword.let) && bindings.first?.initializer != nil
    }

    var getNameAndType: (name: String, type: String)? {
        guard let patternBinding = bindings.first?.as(PatternBindingSyntax.self) else { return nil }
        guard let name = patternBinding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
              let type = patternBinding.typeAnnotation?.as(TypeAnnotationSyntax.self)?.type.as(SimpleTypeIdentifierSyntax.self)?.name else {
            return nil
        }
        return (name: name.text, type: type.text)
    }
}


extension DeclGroupSyntax {
    /// Get the stored properties from the declaration based on syntax.
    func storedProperties() -> [VariableDeclSyntax] {
        memberBlock.members.compactMap { member in
            guard let variable = member.decl.as(VariableDeclSyntax.self),
                  variable.isStoredProperty else {
                return nil
            }
            return variable
        }
    }
}

