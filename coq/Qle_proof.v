Require Import Coq.Unicode.Utf8.
Require Import NArith ArithRing.

Fixpoint nsum max f :=
  match max with
  | O => f 0
  | S max' => f max + nsum max' f
  end.

Require Import Coq.Unicode.Utf8.
Require Import Coq.QArith.QArith Coq.QArith.Qring Coq.QArith.Qfield.
Infix "≤" := Qle.

Lemma Qmult_Qdiv_fact :
  ∀ a b c, not (c == 0) → a * (b / c) == (a * b) / c.
Proof. intros; field; assumption. Qed.

Lemma Qdiv_1 :
  ∀ a, a / 1 == a.
Proof. intros; field. Qed.

Lemma Qplus_le_0 :
  ∀ a b, 0 ≤ a → 0 ≤ b → 0 ≤ a + b.
Proof.
  intros a b Ha Hb.
  pose proof (Qplus_le_compat _ _ _ _ Ha Hb) as Hab.
  ring_simplify in Hab; assumption.
Qed.

Lemma Qplus_lt_0 :
  ∀ a b, 0 < a → 0 ≤ b → 0 < a + b.
Proof.
  intros a b Ha Hb.
  pose proof (Qplus_lt_le_compat _ _ _ _ Ha Hb) as Hab.
  ring_simplify in Hab; assumption.
Qed.

Lemma Qmult_0 :
  ∀ a b, 0 < a → 0 < b → 0 < a * b.
Proof.
  intros a b Ha Hb.
  rewrite <- (Qmult_lt_l _ _ _ Ha), Qmult_0_r in Hb; assumption.
Qed.

Lemma Qsqr_0 :
  ∀ a, 0 ≤ a ^ 2.
Proof.
  intros [n d].
  simpl; unfold Qmult, Qle; simpl.
  rewrite Z.mul_1_r; apply Z.ge_le, Zcomplements.sqr_pos.
Qed.

Lemma Qgt_0_Qneq_0 :
  ∀ a, 0 < a → not (a == 0).
Proof.
  intros [n d].
  unfold Qeq, Qlt; simpl.
  rewrite !Z.mul_1_r, Z.neg_pos_cases; intuition.
Qed.

Require Import Coq.micromega.Lra.
Require Import Psatz.

Lemma Qminus_le_l {x y: Q} (z: Q): x - z <= y - z <-> x <= y.
Proof. lra. Qed.

Hint Resolve Qplus_le_0 Qmult_le_0_compat Qmult_0
     Qgt_0_Qneq_0 Qlt_le_weak Qplus_lt_0 : Q.

Hint Extern 0 => repeat match goal with
                       | [ H: _ ∧ _ |- _ ] => destruct H
                       end : Q.

Ltac Qeauto := eauto 10 with Q.
Tactic Notation "Qeauto" "using" constr(lemma) :=
  eauto 10 using lemma with Q.

Arguments Qmult_le_l {x y} z.
Arguments Qplus_le_l {x y} z.

Module LatexNotations.
  Infix "\wedge" := and (at level 190, right associativity).
  Notation "A \Rightarrow{} B" := (∀ (_ : A), B) (at level 200, right associativity).
  Notation "'\ccForall{' x .. y '}{' P '}'" := (∀ x, .. (∀ y, P) ..) (at level 200, x binder, y binder, right associativity, format "'\ccForall{' x .. y '}{' P '}'").
  Notation "'\ccNat{}'" := nat.
  Notation "'\ccSucc{' n '}'" := (S n).
  Infix "\times" := mult (at level 30).
  Notation "\ccNot{ x }" := (not x) (at level 100).

  Notation "'\ccQ{}'" := Q.
  Notation "\ccPow{  x }{ y }" := (Qpower x y).
  Notation "'\ccFrac{' x '}{' y '}'" := (Qdiv x y)  : Q_scope.
  Infix "\le" := Qle (at level 100).
  Infix "\equiv" := Qeq (at level 100).
  Infix "\times" := Qmult (at level 30).

  Notation "'\ccNsum{' x '}{' max '}{' f '}'" :=
    (nsum max (fun x => f))
      (format "'\ccNsum{' x '}{' max '}{' f '}'").
End LatexNotations.

Module Expanded.
  Lemma Qle_pairwise :
    ∀ a b c d,
      0 < a ∧ 0 < b ∧ 0 < c ∧ 0 < d →
      (a + c)/(b + d) ≤ a/b + c/d.
  Proof with Qeauto.
    intros a b c d H.
    (* (a + c) / (b + d) ≤ a / b + c / d *)
    field_simplify...
    (* (a + c) / (b + d) ≤ (a * d + c * b) / (b * d) *)
    rewrite <- (Qmult_le_l (b + d)), Qmult_div_r, Qmult_Qdiv_fact...
    (* a + c ≤ (b + d) * (a * d + c * b) / (b * d) *)
    rewrite <- (Qmult_le_l (b * d)), Qmult_div_r...
    (* b * d * (a + c) ≤ (b + d) * (a * d + c * b) *)
    field_simplify.
    (* b * d * a + b * d * c ≤ b ^ 2 * c + b * d * a + b * d * c + d ^ 2 * a *)
    rewrite <- (Qminus_le_l (b * d * a)); ring_simplify.
    (* b * d * c ≤ b ^ 2 * c + b * d * c + d ^ 2 * a *)
    rewrite <- (Qminus_le_l (b * d * c)); ring_simplify.
    (* 0 ≤ b ^ 2 * c + d ^ 2 * a *)
    Qeauto using Qsqr_0.
  Qed.
End Expanded.



Lemma Qle_pairwise : ∀ a b c d, 0 < a ∧ 0 < b ∧ 0 < c ∧ 0 < d →
  (a + c)/(b + d) ≤ a/b + c/d.
Proof with Qeauto.
  intros a b c d H.
  field_simplify...
  rewrite <- (Qmult_le_l (b + d)), 
    Qmult_div_r, Qmult_Qdiv_fact...
  rewrite <- (Qmult_le_l (b * d)),
    Qmult_div_r...
  field_simplify.
  rewrite <- (Qminus_le_l (b * d * a)); ring_simplify.
  rewrite <- (Qminus_le_l (b * d * c)); ring_simplify.
  Qeauto using Qsqr_0.
Qed.


















