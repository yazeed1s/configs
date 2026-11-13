; Odin highlights for emacs tree-sitter
; Adapted from tree-sitter-grammars/tree-sitter-odin for emacs tree-sitter-hl-mode

; Preprocs / Attributes

[
  (calling_convention)
  (tag)
] @attribute

; Keywords

[
  "import"
  "package"
  "foreign"
  "using"
  "struct"
  "enum"
  "union"
  "defer"
  "cast"
  "transmute"
  "auto_cast"
  "map"
  "bit_set"
  "matrix"
  "bit_field"
  "proc"
  "return"
  "or_return"
  "distinct"
  "dynamic"
  "if"
  "else"
  "when"
  "switch"
  "case"
  "where"
  "break"
  "for"
  "do"
  "continue"
  "or_else"
  "in"
  "not_in"
  (fallthrough_statement)
] @keyword

; Variables

(identifier) @variable

; Namespaces

(package_declaration (identifier) @type)

(import_declaration alias: (identifier) @type)

(foreign_block (identifier) @type)

(using_statement (identifier) @type)

; Parameters

(parameter (identifier) @variable.parameter ":")

(default_parameter (identifier) @variable.parameter ":=")

(named_type (identifier) @variable.parameter)

; Functions

(procedure_declaration (identifier) @function (procedure (block)))

(procedure_declaration (identifier) @function (procedure (uninitialized)))

(overloaded_procedure_declaration (identifier) @function)

(call_expression function: (identifier) @function.call)

; Types

(type (identifier) @type)

"..." @type.builtin

(struct_declaration (identifier) @type "::")

(enum_declaration (identifier) @type "::")

(union_declaration (identifier) @type "::")

(bit_field_declaration (identifier) @type "::")

(struct . (identifier) @type)

(field_type . (identifier) @type "." (identifier) @type)

(bit_set_type (identifier) @type ";")

(procedure_type (parameters (parameter (identifier) @type)))

(polymorphic_parameters (identifier) @type)

; Fields

(member_expression "." (identifier) @property)

(struct_type "{" (identifier) @property)

(struct_field (identifier) @property)

(field (identifier) @property)

; Constants

(member_expression . "." (identifier) @constant)

(enum_declaration "{" (identifier) @constant)

; Attributes

(attribute (identifier) @attribute)

; Labels

(label_statement (identifier) @label ":")

; Literals

(number) @number

(float) @number

(string) @string

(character) @string

(escape_sequence) @escape

(boolean) @constant.builtin

[
  (uninitialized)
  (nil)
] @constant.builtin

; Operators

[
  ":="
  "="
  "+"
  "-"
  "*"
  "/"
  "%"
  "%%"
  ">"
  ">="
  "<"
  "<="
  "=="
  "!="
  "~="
  "|"
  "~"
  "&"
  "&~"
  "<<"
  ">>"
  "||"
  "&&"
  "!"
  "^"
  ".."
  "+="
  "-="
  "*="
  "/="
  "%="
  "&="
  "|="
  "^="
  "<<="
  ">>="
  "||="
  "&&="
  "&~="
  "..="
  "..<"
  "?"
] @operator

; Punctuation

[ "{" "}" ] @punctuation.bracket

[ "(" ")" ] @punctuation.bracket

[ "[" "]" ] @punctuation.bracket

[
  "::"
  "->"
  "."
  ","
  ":"
  ";"
] @punctuation.delimiter

[
  "@"
  "$"
] @punctuation.special

; Comments

[
  (comment)
  (block_comment)
] @comment

; Errors

(ERROR) @error
