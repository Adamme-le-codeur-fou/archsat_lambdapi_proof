
(** Typechecking of terms from Dolmen.Term.t
    This module provides functions to parse terms from the untyped syntax tree
    defined in Dolmen, and generate formulas as defined in the Expr module. *)

exception Typing_error of string * Dolmen.Term.t

val section : Util.Section.t
(** Debug section used in typechecking. *)

val stack : Backtrack.Stack.t
(** The undo stack used for storing globals during typechecking. *)

(** {2 Type definitions} *)

type env
(** The type of environments for typechecking. *)

type res =
  | Ttype
  | Ty of Expr.ty
  | Term of Expr.term
  | Formula of Expr.formula (**)
(* The results of parsing an untyped term.  *)

type 'a typer = env -> Dolmen.Term.t -> 'a
(** A general type for typers. Takes a local environment and the current untyped term,
    and return a value. The typer may need additional information for parsing,
    in which case the return value will be a function. *)

type builtin_symbols = (Dolmen.Term.id -> Dolmen.Term.t list -> res option) typer
(** The type of a typer for builtin symbols. Takes the name of the symbol and the arguments
    applied to it, and can return a typechecking result.
    Can be useful for extensions to define overloaded operators such as addition in arithmetic,
    since the exact function symbol returned can depend on the arguments (or even be different
    between two calls with the same arguments). *)

(** {2 Parsing helpers} *)

val ty_apply :
  (Expr.ttype Expr.function_descr Expr.id -> Expr.ty list -> Expr.ty) typer
val term_apply :
  (Expr.ty Expr.function_descr Expr.id -> Expr.ty list -> Expr.term list -> Expr.term) typer
(** Wrappers for making applications, so that it raises the right exceptions. *)

(** {2 Parsing functions} *)

val parse_expr : res typer
(** Main parsing function. *)

val parse_ty : Expr.ty typer
val parse_term : Expr.term typer
val parse_formula : Expr.formula typer
(** Wrappers around {parse_expr} to unwrap an expected result. *)

val parse_app_ty : (Expr.ttype Expr.function_descr Expr.id -> Dolmen.Term.t list -> res) typer
val parse_app_term : (Expr.ty Expr.function_descr Expr.id -> Dolmen.Term.t list -> res) typer
(** Function used for parsing applications. The first dolmen term given
    is the application term being parsed (used for reporting errors). *)

(** {2 High-level functions} *)

val new_decl : builtin:builtin_symbols -> Dolmen.Term.id -> Dolmen.Term.t -> unit

val new_def  : builtin:builtin_symbols -> Dolmen.Term.id -> Dolmen.Term.t -> unit

