import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros


internal enum MacroError: Swift.Error, CustomStringConvertible {
    case invalidInputType
    case message(String)

    var description: String {
      switch self {
      case .invalidInputType:
          return "only applicable to structs or classes"
      case .message(let text):
        return text
      }
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

extension AttributeListSyntax {
    func getAttributedElement(_ macroName: String) -> AttributeListSyntax.Element? {
        self.first {
            $0.as(AttributeSyntax.self)?
                .attributeName
                .as(SimpleTypeIdentifierSyntax.self)?
                .description == macroName
        }
    }
}

extension AttributeListSyntax.Element {
    func getExprSyntax(_ argumentName: String? = nil) -> ExprSyntax? {
        if let argumentName {
            self
                .as(AttributeSyntax.self)?
                .argument?
                .as(TupleExprElementListSyntax.self)?
                .first(where: {
                    $0.label?.text == argumentName
                })?
                .expression
        } else {
            self
                .as(AttributeSyntax.self)?
                .argument?
                .as(TupleExprElementListSyntax.self)?
                .first?
                .expression
        }
    }
}

