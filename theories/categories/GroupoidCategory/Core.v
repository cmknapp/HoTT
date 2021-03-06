(** * Groupoids *)
Require Import Category.Core Category.Morphisms Category.Strict.
Require Import Trunc.

Set Universe Polymorphism.
Set Implicit Arguments.
Generalizable All Variables.
Set Asymmetric Patterns.

Local Open Scope equiv_scope.
Local Open Scope category_scope.

(** A groupoid is a precategory where every morphism is an isomorphism.  Since 1-types are 1-groupoids, we can construct the category corresponding to the 1-groupoid of a 1-type. *)

(** We don't want access to all of the internals of a groupoid category at top level. *)
Module GroupoidCategoryInternals.
  Section groupoid_category.
    Variable X : Type.
    Context `{IsTrunc 1 X}.

    Local Notation morphism := (@paths X).

    Definition compose s d d' (m : morphism d d') (m' : morphism s d)
    : morphism s d'
      := transitivity s d d' m' m.

    Definition identity x : morphism x x
      := reflexivity _.

    Global Arguments compose [s d d'] m m' / .
    Global Arguments identity x / .
  End groupoid_category.
End GroupoidCategoryInternals.

(** ** Categorification of the groupoid of a 1-type *)
Definition groupoid_category X `{IsTrunc 1 X} : PreCategory.
Proof.
  refine (@Build_PreCategory X
                             (@paths X)
                             (@GroupoidCategoryInternals.identity X)
                             (@GroupoidCategoryInternals.compose X)
                             _
                             _
                             _
                             _);
  simpl; intros; path_induction; reflexivity.
Defined.

Arguments groupoid_category X {_}.

(** ** 0-types give rise to strict (groupoid) categories *)
Lemma isstrict_groupoid_category X `{IsHSet X}
: IsStrictCategory (groupoid_category X).
Proof.
  typeclasses eauto.
Defined.
