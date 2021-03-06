Require Import Overture types.Universe FunextVarieties Equivalences types.Paths types.Unit.

Generalizable All Variables.
Set Implicit Arguments.

(** * Univalence Implies Functional Extensionality *)

(** Here we prove that univalence implies function extensionality. *)

Section UnivalenceImpliesFunext.
  Context `{Univalence}.

  (** Exponentiation preserves equivalences, i.e., if [e] is an equivalence then so is post-composition by [e]. *)

  (* Should this go somewhere else? *)

  Theorem univalence_isequiv_postcompose `{H0 : IsEquiv A B w} C : IsEquiv (@compose C A B w).
  Proof.
    refine (isequiv_adjointify
              (@compose C A B w)
              (@compose C B A w^-1)%equiv
              _
              _);
    intro;
    pose (BuildEquiv _ _ w _) as w';
    change H0 with (@equiv_isequiv _ _ w');
    change w with (@equiv_fun _ _ w');
    clearbody w'; clear H0 w;
    rewrite <- (@eisretr _ _ _ (@isequiv_equiv_path _ A B) w');
    generalize ((equiv_path A B)^-1 w')%equiv;
    intro p;
    clear w';
    destruct p;
    reflexivity.
  Defined.

  (** We are ready to prove functional extensionality, starting with the naive non-dependent version. *)

  Local Instance isequiv_src_compose A B
  : @IsEquiv (A -> {xy : B * B & fst xy = snd xy})
             (A -> B)
             (compose (fst o pr1)).
  Proof.
    apply @univalence_isequiv_postcompose.
    refine (isequiv_adjointify
              (fst o pr1) (fun x => ((x, x); idpath))
              (fun _ => idpath)
              _);
      let p := fresh in
      intros [[? ?] p];
        simpl in p; destruct p;
        reflexivity.
  Defined.


  Local Instance isequiv_tgt_compose A B
  : @IsEquiv (A -> {xy : B * B & fst xy = snd xy})
             (A -> B)
             (compose (snd o pr1)).
  Proof.
    apply @univalence_isequiv_postcompose.
    refine (isequiv_adjointify
              (snd o pr1) (fun x => ((x, x); idpath))
              (fun _ => idpath)
              _);
      let p := fresh in
      intros [[? ?] p];
        simpl in p; destruct p;
        reflexivity.
  Defined.

  Theorem Univalence_implies_FunextNondep (A B : Type)
  : forall f g : A -> B, f == g -> f = g.
  Proof.
    intros f g p.
    (** Consider the following maps. *)
    pose (d := fun x : A => existT (fun xy => fst xy = snd xy) (f x, f x) (idpath (f x))).
    pose (e := fun x : A => existT (fun xy => fst xy = snd xy) (f x, g x) (p x)).
    (** If we compose [d] and [e] with [free_path_target], we get [f] and [g], respectively. So, if we had a path from [d] to [e], we would get one from [f] to [g]. *)
    change f with ((snd o pr1) o d).
    change g with ((snd o pr1) o e).
    apply ap.
    (** Since composition with [src] is an equivalence, we can freely compose with [src]. *)
    pose (fun A B x y=> @equiv_inv _ _ _ (@isequiv_ap _ _ _ (@isequiv_src_compose A B) x y)) as H'.
    apply H'.
    reflexivity.
  Defined.
End UnivalenceImpliesFunext.

Section UnivalenceImpliesWeakFunext.
  Context `{ua1 : Univalence, ua2 : Univalence}.
  (** Now we use this to prove weak funext, which as we know implies (with dependent eta) also the strong dependent funext. *)

  Theorem Univalence_implies_WeakFunext : WeakFunext.
  Proof.
    intros A P allcontr.
    (** We are going to replace [P] with something simpler. *)
    pose (U := (fun (_ : A) => Unit)).
    assert (p : P = U).
    - apply Univalence_implies_FunextNondep.
      intro x.
      apply (@path_universe_uncurried ua1).
      apply equiv_contr_unit.
    - (** Now this is much easier. *)
      rewrite p.
      unfold U; simpl.
      exists (fun _ => tt).
      intro f.
      apply (@Univalence_implies_FunextNondep ua2).
      intro x.
      exact (@contr Unit _ _).
  Qed.
End UnivalenceImpliesWeakFunext.

Definition Univalence_implies_Funext `{ua1 : Univalence, ua2 : Univalence} : Funext
  := WeakFunext_implies_Funext (@Univalence_implies_WeakFunext ua1 ua2).

Hint Immediate Univalence_implies_Funext : typeclass_instances.
