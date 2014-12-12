 (** * Univalent Basics. Vladimir Voevodsky. Feb. 2010 - Sep. 2011. Port to coq trunk (8.4-8.5) in
 March 2014. The third part of the original uu0 file, created on Dec. 3, 2014.

One one usniverse is used and never as a type. 
The only axiom we use is [ funextempty ] which is the functional extensionality
 axiom for functions with values in the empty type. *)


(** ** Preambule *)

(** Settings *)

Unset Automatic Introduction. (* This line has to be removed for the file to compile with 
Coq8.2 *)

(** Imports *)

Require Export Foundations.Generalities.uu0b.






(** *** Functional extensionality for functions to the empty type *)

Axiom funextempty : forall ( X : UU ) ( f g : X -> empty ) , paths f g . 



(** *** More results on propositions *)


Theorem isapropneg (X:UU): isaprop (X -> empty).
Proof. intro.  apply invproofirrelevance . intros x x' .   apply ( funextempty X x x' ) . Defined .  

(** See also [ isapropneg2 ] *) 


Corollary isapropdneg (X:UU): isaprop (dneg X).
Proof. intro. apply (isapropneg (neg X)). Defined.


Definition isaninvprop (X:UU) := isweq  (todneg X).

Definition invimpl (X:UU) (is: isaninvprop X) : (dneg X) -> X:= invmap  ( weqpair (todneg X) is ) . 


Lemma isapropaninvprop (X:UU): isaninvprop X -> isaprop X.
Proof. intros X X0. 
apply (isofhlevelweqb (S O) ( weqpair (todneg X) X0 ) (isapropdneg X)). Defined. 


Theorem isaninvpropneg (X:UU): isaninvprop (neg X).
Proof. intros. 
set (f:= todneg (neg X)). set (g:= negf  (todneg X)). set (is1:= isapropneg X). set (is2:= isapropneg (dneg X)). apply (isweqimplimpl  f g is1 is2).  Defined.


Theorem isapropdec (X:UU): (isaprop X) -> (isaprop (coprod X (X-> empty))).
Proof. intros X X0. 
assert (X1: forall (x x': X), paths x x'). apply (proofirrelevance _ X0).  
assert (X2: forall (x x': coprod X (X -> empty)), paths x x'). intros.  
induction x as  [ x0 | y0 ].  induction x' as [ x | y ].   apply (maponpaths (fun x:X => ii1  x)  (X1 x0 x)).    
apply (fromempty (y x0)).
induction x' as [ x | y ].   apply (fromempty (y0 x)). 
assert (e: paths y0 y). apply (proofirrelevance _ (isapropneg X) y0 y). apply (maponpaths (fun f: X -> empty => ii2  f)  e).
apply (invproofirrelevance _ X2).  Defined. 



(** *** Inclusions - functions of h-level 1 *)


Definition isincl { X Y : UU } (f : X -> Y ) := isofhlevelf 1 f .

Definition incl ( X Y : UU ) := total2 ( fun f : X -> Y => isincl f ) .
Definition inclpair { X Y : UU } ( f : X -> Y ) ( is : isincl f ) : incl X Y := tpair _ f is . 
Definition pr1incl ( X Y : UU ) : incl X Y -> ( X -> Y ) := @pr1 _ _ .
Coercion pr1incl : incl >-> Funclass .

Lemma isinclweq ( X Y : UU ) ( f : X -> Y ) : isweq f -> isincl f .
Proof . intros X Y f is . apply ( isofhlevelfweq 1 ( weqpair _ is ) ) .  Defined .
Coercion isinclweq : isweq >-> isincl .

Lemma isofhlevelfsnincl (n:nat) { X Y : UU } (f:X -> Y)(is: isincl  f): isofhlevelf (S n)  f.
Proof. intros. unfold isofhlevelf.  intro y . apply isofhlevelsnprop. apply (is y). Defined.  

Definition weqtoincl ( X Y : UU ) : weq X Y -> incl X Y :=  fun w => inclpair ( pr1weq w ) ( pr2 w ) .  
Coercion weqtoincl : weq >-> incl . 

Lemma isinclcomp { X Y Z : UU } ( f : incl X Y ) ( g : incl Y Z ) : isincl ( funcomp ( pr1 f ) ( pr1 g ) ) .
Proof . intros . apply ( isofhlevelfgf 1 f g ( pr2 f ) ( pr2 g ) ) . Defined .

Definition inclcomp { X Y Z : UU } ( f : incl X Y ) ( g : incl Y Z ) : incl X Z := inclpair ( funcomp ( pr1 f ) ( pr1 g ) ) ( isinclcomp f g ) . 

Lemma isincltwooutof3a { X Y Z : UU } ( f : X -> Y ) ( g : Y -> Z ) ( isg : isincl g ) ( isgf : isincl ( funcomp f g ) ) : isincl f .
Proof . intros . apply ( isofhlevelff 1 f g isgf ) .  apply ( isofhlevelfsnincl 1 g isg ) . Defined .

Lemma isinclgwtog { X Y Z : UU } ( w : weq X Y ) ( g : Y -> Z ) ( is : isincl ( funcomp w g ) ) : isincl g .
Proof . intros . apply ( isofhlevelfgwtog 1 w g is ) .  Defined . 

Lemma isinclgtogw { X Y Z : UU }  ( w : weq X Y ) ( g : Y -> Z ) ( is : isincl g ) : isincl ( funcomp w g ) .
Proof . intros . apply  ( isofhlevelfgtogw 1 w g is ) . Defined . 


Lemma isinclhomot { X Y : UU } ( f g : X -> Y ) ( h : homot f g ) ( isf : isincl f ) : isincl g .
Proof . intros . apply ( isofhlevelfhomot ( S O ) f g h isf ) . Defined . 



Definition isofhlevelsninclb (n:nat) { X Y : UU } (f:X -> Y)(is: isincl  f) : isofhlevel (S n) Y -> isofhlevel (S n) X:= isofhlevelXfromfY (S n)  f (isofhlevelfsnincl n  f is).  

Definition  isapropinclb { X Y : UU } ( f : X -> Y ) ( isf : isincl f ) : isaprop Y ->  isaprop X := isofhlevelXfromfY 1 _ isf .


Lemma iscontrhfiberofincl { X Y : UU } (f:X -> Y): isincl  f -> (forall x:X, iscontr (hfiber  f (f x))).
Proof. intros X Y f X0 x. unfold isofhlevelf in X0. set (isy:= X0 (f x)).  apply (iscontraprop1 isy (hfiberpair  f _ (idpath (f x)))). Defined.


Lemma isweqonpathsincl { X Y : UU } (f:X -> Y) (is: isincl  f)(x x':X): isweq (@maponpaths _ _ f x x').
Proof. intros. apply (isofhlevelfonpaths O  f x x' is). Defined.

Definition weqonpathsincl  { X Y : UU } (f:X -> Y) (is: isincl  f)(x x':X) := weqpair _ ( isweqonpathsincl f is x x' ) .

Definition invmaponpathsincl { X Y : UU } (f:X -> Y) (is: isincl  f)(x x':X): paths (f x) (f x') -> paths x x':= invmap  ( weqonpathsincl  f is x x') .


Lemma isinclweqonpaths { X Y : UU } (f:X -> Y): (forall x x':X, isweq (@maponpaths _ _ f x x')) -> isincl  f.
Proof. intros X Y f X0.  apply (isofhlevelfsn O  f X0). Defined.


Definition isinclpr1 { X : UU } (P:X -> UU)(is: forall x:X, isaprop (P x)): isincl  (@pr1 X P):= isofhlevelfpr1 (S O) P is.

Lemma total2_paths_isaprop (A : UU) (B : A -> UU) (is : forall a, isaprop (B a))
    (s s' : total2 (fun x => B x)) : pr1 s = pr1 s' -> s = s'.
Proof.
  intros A B H s s'.
  apply invmaponpathsincl.
  apply isinclpr1.
  apply H.
Defined.

Theorem total2_paths_isaprop_equiv {A : UU} (B : A -> UU) (hB: forall a, isaprop (B a))
   (x y : total2 (fun x => B x)): weq (x = y) (pr1 x = pr1 y).
Proof.
  intros.
  exists (maponpaths pr1).
  apply isweqonpathsincl.
  apply isinclpr1.
  assumption.
Defined.


Theorem samehfibers { X Y Z : UU } (f: X -> Y) (g: Y -> Z) (is1: isincl  g) ( y: Y): weq ( hfiber f y ) ( hfiber ( fun x => g ( f x ) ) ( g y ) ) .
Proof. intros. split with (@hfibersftogf  _ _ _ f g (g y) (hfiberpair  g y (idpath _ ))) .

set (z:= g y). set (ye:= hfiberpair  g y (idpath _ )).  unfold isweq. intro xe.  
set (is3:= isweqezmap1 _ _ _ ( fibseqhf f g z ye ) xe). 
assert (w1: weq (paths (hfibersgftog f g z xe) ye) (hfiber  (hfibersftogf  f g z ye) xe)). split with (ezmap (d1 (hfibersftogf f g z ye) (hfibersgftog f g z) ye ( fibseqhf f g z ye ) xe) (hfibersftogf f g z ye) xe ( fibseq1 (hfibersftogf f g z ye) (hfibersgftog f g z) ye ( fibseqhf f g z ye ) xe) ). apply is3. apply (iscontrweqf w1 ). 
assert (is4: iscontr (hfiber g z)). apply iscontrhfiberofincl. assumption.
apply ( isapropifcontr is4  ). Defined.








(** *** Basics about types of h-level 2 - "sets" *)

Definition isaset ( X : UU ) : UU := forall x x' : X , isaprop ( paths x x' ) .

(* Definition isaset := isofhlevel 2 . *)

Notation isasetdirprod := ( isofhleveldirprod 2 ) .

Lemma isasetunit : isaset unit .
Proof . apply ( isofhlevelcontr 2 iscontrunit ) . Defined .

Lemma isasetempty : isaset empty .
Proof. apply ( isofhlevelsnprop 1 isapropempty ) .  Defined . 

Lemma isasetifcontr { X : UU } ( is : iscontr X ) : isaset X .
Proof . intros . apply ( isofhlevelcontr 2 is ) . Defined .

Lemma isasetaprop { X : UU } ( is : isaprop X ) : isaset X .
Proof . intros . apply ( isofhlevelsnprop 1 is ) . Defined . 

(** The following lemma assert "uniqueness of identity proofs" (uip) for sets. *)

Lemma uip { X : UU } ( is : isaset X ) { x x' : X } ( e e' : paths x x' ) : paths e e' .
Proof. intros . apply ( proofirrelevance _ ( is x x' ) e e' ) . Defined .  

(** For the theorem about the coproduct of two sets see [ isasetcoprod ] below. *)


Lemma isofhlevelssnset (n:nat) ( X : UU ) ( is : isaset X ) : isofhlevel ( S (S n) ) X.
Proof. intros n X X0. simpl. unfold isaset in X0.   intros x x' . apply isofhlevelsnprop. set ( int := X0 x x'). assumption . Defined. 

Lemma isasetifiscontrloops (X:UU): (forall x:X, iscontr (paths x x)) -> isaset X.
Proof. intros X X0. unfold isaset. unfold isofhlevel. intros x x' x0 x0' .   induction x0. set (is:= X0 x). apply isapropifcontr. assumption.  Defined. 

Lemma iscontrloopsifisaset (X:UU): (isaset X) -> (forall x:X, iscontr (paths x x)).
Proof. intros X X0 x. unfold isaset in X0. unfold isofhlevel in X0.  change (forall (x x' : X) (x0 x'0 : paths x x'), iscontr (paths x0 x'0))  with (forall (x x':X),  isaprop (paths x x')) in X0.  apply (iscontraprop1 (X0 x x) (idpath x)). Defined.



(**  A monic subtype of a set is a set. *)

Theorem isasetsubset { X Y : UU } (f: X -> Y) (is1: isaset Y) (is2: isincl  f): isaset X.
Proof. intros. apply  (isofhlevelsninclb (S O)  f is2). apply is1. Defined. 



(** The morphism from hfiber of a map to a set is an inclusion. *)

Theorem isinclfromhfiber { X Y : UU } (f: X -> Y) (is : isaset Y) ( y: Y ) : @isincl (hfiber  f y) X ( @pr1 _ _  ).
Proof. intros. apply isofhlevelfhfiberpr1. assumption. Defined. 


(** Criterion for a function between sets being an inclusion.  *)


Theorem isinclbetweensets { X Y : UU } ( f : X -> Y ) ( isx : isaset X ) ( isy : isaset Y ) ( inj : forall x x' : X , ( paths ( f x ) ( f x' ) -> paths x x' ) ) : isincl f .
Proof. intros .  apply isinclweqonpaths .  intros x x' .  apply ( isweqimplimpl ( @maponpaths _ _ f x x' ) (  inj x x' ) ( isx x x' ) ( isy ( f x ) ( f x' ) ) ) . Defined .   

(** A map from [ unit ] to a set is an inclusion. *)

Theorem isinclfromunit { X : UU } ( f : unit -> X ) ( is : isaset X ) : isincl f .
Proof. intros . apply ( isinclbetweensets f ( isofhlevelcontr 2 ( iscontrunit ) )  is ) .  intros .  induction x . induction x' . apply idpath . Defined . 




(** ** Isolated points and types with decidable equality. *)


(** *** Basic results on complements to a point *)


Definition compl ( X : UU ) ( x : X ):= total2 (fun x':X => neg (paths x x' ) ) .
Definition complpair ( X : UU ) ( x : X ) := tpair (fun x':X => neg (paths x x' ) ) .
Definition pr1compl ( X : UU ) ( x : X ) := @pr1 _ (fun x':X => neg (paths x x' ) ) .


Lemma isinclpr1compl ( X : UU ) ( x : X ) : isincl ( pr1compl X x ) .
Proof. intros . apply ( isinclpr1 _ ( fun x' : X => isapropneg _ ) ) . Defined. 


Definition recompl ( X : UU ) (x:X): coprod (compl X x) unit -> X := fun u:_ =>
match u with
ii1 x0 => pr1  x0|
ii2 t => x
end.

Definition maponcomplincl { X Y : UU } (f:X -> Y)(is: isincl f)(x:X): compl X x -> compl Y (f x):= fun x0':_ =>
match x0' with
tpair _ x' neqx => tpair _ (f x') (negf  (invmaponpathsincl  _ is x x' ) neqx)
end.

Definition maponcomplweq { X Y : UU } (f : weq X Y ) (x:X):= maponcomplincl  f (isofhlevelfweq (S O) f ) x.


Theorem isweqmaponcompl { X Y : UU } ( f : weq X Y ) (x:X): isweq (maponcomplweq  f x).
Proof. intros.  set (is1:= isofhlevelfweq (S O)  f).   set (map1:= totalfun (fun x':X => neg (paths x x' )) (fun x':X => neg (paths (f x) (f x'))) (fun x':X => negf  (invmaponpathsincl  _ is1 x x' ))). set (map2:= fpmap  f (fun y:Y => neg (paths (f x) y ))). 
assert (is2: forall x':X, isweq  (negf  (invmaponpathsincl  _ is1 x x'))). intro. 
set (invimpll:= (negf  (@maponpaths _ _ f x x'))). apply (isweqimplimpl  (negf  (invmaponpathsincl  _ is1 x x')) (negf  (@maponpaths _ _ f x x')) (isapropneg _) (isapropneg _)). 
assert (is3: isweq map1).  unfold map1 . apply ( isweqfibtototal  _ _  (fun x':X => weqpair _  ( is2 x' )) ) .  
assert (is4: isweq map2). apply (isweqfpmap  f  (fun y:Y => neg (paths (f x) y )) ).
assert (h: forall x0':_, paths (map2 (map1 x0')) (maponcomplweq  f x x0')). intro.  simpl. induction x0'. simpl. apply idpath.
apply (isweqhomot _ _ h (twooutof3c _ _ is3 is4)).
Defined.


Definition weqoncompl { X Y : UU } (w: weq X Y) ( x : X ) : weq (compl X x) (compl Y (w x)):= weqpair  _ (isweqmaponcompl w x).

Definition homotweqoncomplcomp { X Y Z : UU } ( f : weq X Y ) ( g : weq Y Z ) ( x : X ) : homot ( weqcomp ( weqoncompl f x ) ( weqoncompl g ( f x ) ) ) ( weqoncompl  ( weqcomp f g ) x ) .
Proof . intros . intro x' . induction x' as [ x' nexx' ] . apply ( invmaponpathsincl _ ( isinclpr1compl Z _ ) _ _ ) . simpl .  apply idpath .    Defined . 





(** *** Basic results on types with an isolated point. *)




Definition isisolated (X:UU)(x:X):= forall x':X, coprod (paths x x' ) (paths x x' -> empty).

Definition isolated ( T : UU ) := total2 ( fun t : T => isisolated T t ) .
Definition isolatedpair ( T : UU ) := tpair ( fun t : T => isisolated T t ) . 
Definition pr1isolated ( T : UU )  := fun x : isolated T => pr1 x . 


Theorem isaproppathsfromisolated ( X : UU ) ( x : X ) ( is : isisolated X x ) : forall x' : X, isaprop ( paths x x' ) .
Proof. intros . apply iscontraprop1inv .  intro e .  induction e . 
set (f:= fun e: paths x x => coconusfromtpair _ e). 
assert (is' : isweq f). apply (onefiber (fun x':X => paths x x' ) x (fun x':X => is x' )).
assert (is2: iscontr (coconusfromt _ x)). apply iscontrcoconusfromt. 
apply (iscontrweqb ( weqpair f is' ) ). assumption. Defined. 

Theorem isaproppathstoisolated  ( X : UU ) ( x : X ) ( is : isisolated X x ) : forall x' : X, isaprop ( paths x' x ) .
Proof . intros . apply ( isofhlevelweqf 1 ( weqpathsinv0 x x' ) ( isaproppathsfromisolated X x is x' ) ) . Defined . 


Lemma isisolatedweqf { X Y : UU } (  f : weq X Y ) (x:X) (is2: isisolated _ x) : isisolated _ (f x).
Proof.  intros. unfold isisolated. intro y.  set (g:=invmap  f ). set (x':= g y). induction (is2 x') as [ x0 | y0 ].  apply (ii1  (pathsweq1'  f x y x0) ). 
assert (phi: paths y (f x)  -> empty). 
assert (psi: (paths (g y) x -> empty) -> (paths y (f x) -> empty)). intros X0 X1.  apply (X0  (pathsinv0 (pathsweq1  f x y (pathsinv0 X1)))). apply (psi ( ( negf ( @pathsinv0 _ _ _ ) ) y0) ) . apply (ii2  ( negf ( @pathsinv0 _ _ _ )  phi ) ). Defined.


Theorem isisolatedinclb { X Y : UU } ( f : X -> Y ) ( is : isincl f ) ( x : X ) ( is0 : isisolated _ ( f x ) ) : isisolated _ x .
Proof. intros .  unfold isisolated .  intro x' .  set ( a := is0 ( f x' ) ) .  induction a as [ a1 | a2 ] . apply ( ii1 ( invmaponpathsincl f is _ _ a1 ) ) . apply ( ii2 ( ( negf ( @maponpaths _ _ f _ _ ) ) a2 ) ) .  Defined. 


Lemma disjointl1 (X:UU): isisolated (coprod X unit) (ii2  tt).
Proof. intros.  unfold isisolated. intros x' .  induction x' as [ x | u ] . apply (ii2  (negpathsii2ii1 x tt )).  induction u.  apply (ii1  (idpath _ )). Defined.


(** *** Weak equivalence [ weqrecompl ] from the coproduct of the complement to an isolated point with [ unit ] and the original type *)

Definition invrecompl (X:UU)(x:X)(is: isisolated X x): X -> coprod (compl X x) unit:=
fun x':X => match (is x') with
ii1 e => ii2  tt|
ii2 phi => ii1  (complpair _ _ x' phi)
end.



Theorem isweqrecompl (X:UU)(x:X)(is:isisolated X x): isweq (recompl _ x).
Proof. intros. set (f:= recompl _ x). set (g:= invrecompl X x is). unfold invrecompl in g. simpl in g. 

assert (efg: forall x':X, paths (f (g x')) x'). intro.   induction (is x') as [ x0 | e ].   induction x0. unfold f. unfold g. simpl. unfold recompl. simpl.  induction (is x) as [ x0 | e ] .  simpl. apply idpath. induction (e (idpath x)).  unfold f. unfold g. simpl. unfold recompl. simpl.  induction  (is x') as [ x0 | e0 ].  induction (e x0). simpl. apply idpath. 


assert (egf: forall u: coprod  (compl X x) unit, paths (g (f u)) u). unfold isisolated in is. intro. induction (is (f u)) as [ p | e ] . induction u as [ c | u].    simpl. induction c as [ t x0 ]. simpl in p. induction (x0 p). 

induction u.   
assert (e1: paths  (g (f (ii2 tt))) (g x)). apply (maponpaths g  p). 
assert (e2: paths (g x) (ii2 tt)). unfold g.  induction (is x) as [ i | e ].   apply idpath.  induction (e (idpath x)). apply (pathscomp0   e1 e2). induction u as [ c | u ] .  simpl. induction c as [ t x0 ].  simpl. unfold isisolated in is.  unfold g.  induction (is t) as [ p | e0 ] . induction (x0 p). simpl in g. 
 unfold f. unfold recompl. simpl in e. 
assert (ee: paths e0 x0). apply (proofirrelevance _ (isapropneg (paths x t))). induction ee.  apply idpath. 
unfold f. unfold g. simpl. induction u. induction (is x).  apply idpath. induction (e (idpath x)).
apply (gradth  f g egf efg). Defined.

Definition weqrecompl ( X : UU ) ( x : X ) ( is : isisolated _ x ) : weq ( coprod ( compl X x ) unit ) X := weqpair _ ( isweqrecompl X x is ) .


(** *** Theorem saying that [ recompl ] commutes up to homotopy with [ maponcomplweq ] *)


Theorem homotrecomplnat { X Y : UU } ( w : weq X Y ) ( x : X ) : forall a : coprod ( compl X x ) unit , paths  ( recompl Y ( w x ) ( coprodf ( maponcomplweq w x ) ( fun x: unit => x ) a ) ) ( w ( recompl X x a ) )  .   
Proof . intros . induction a as [ ane | t ] . induction ane as [ a ne ] .  simpl . apply idpath . induction t . simpl . apply idpath .  Defined . 



(** *** Recomplement on functions *)


Definition recomplf { X Y : UU } ( x : X ) ( y : Y ) ( isx : isisolated X x ) ( f : compl X x -> compl Y y )  := funcomp ( funcomp ( invmap ( weqrecompl X x isx ) ) ( coprodf f ( idfun unit ) ) )  ( recompl Y y ) .

Definition weqrecomplf { X Y : UU } ( x : X ) ( y : Y ) ( isx : isisolated X x ) ( isy : isisolated Y y ) ( w : weq ( compl X x ) ( compl Y y ) ) := weqcomp ( weqcomp ( invweq ( weqrecompl X x isx ) ) ( weqcoprodf w ( idweq unit ) ) ) ( weqrecompl Y y isy ) . 

Definition homotrecomplfhomot { X Y : UU } ( x : X ) ( y : Y ) ( isx : isisolated X x ) ( f f' : compl X x -> compl Y y ) ( h : homot f f' ) : homot ( recomplf x y isx f ) ( recomplf x y isx f') .
Proof . intros. intro a . unfold recomplf . apply ( maponpaths ( recompl Y y ) ( homotcoprodfhomot _ _ _ _ h ( fun t : unit => idpath t ) (invmap (weqrecompl X x isx) a) ) ) .  Defined .  

Lemma pathsrecomplfxtoy { X Y : UU } ( x : X ) ( y : Y ) ( isx : isisolated X x ) ( f : compl X x -> compl Y y ) : paths ( recomplf x y isx f x ) y .
Proof .  intros . unfold recomplf . unfold weqrecompl .  unfold invmap .   simpl . unfold invrecompl . unfold funcomp .  induction ( isx x ) as [ i1 | i2 ] .  simpl . apply idpath . induction ( i2 ( idpath _ ) ) .  Defined . 

Definition homotrecomplfcomp { X Y Z : UU } ( x : X ) ( y : Y ) ( z : Z ) ( isx : isisolated X x ) ( isy : isisolated Y y ) ( f :  compl X x -> compl Y y )  ( g :  compl Y y -> compl Z z ) : homot ( funcomp ( recomplf x y isx f ) ( recomplf y z isy g ) ) ( recomplf x z isx ( funcomp f g ) ) .
Proof . intros. intro x' . unfold recomplf . set ( e := homotinvweqweq ( weqrecompl Y y isy ) (coprodf f ( idfun unit) (invmap ( weqrecompl X x isx ) x')) ) . unfold funcomp .   simpl in e .  simpl . rewrite e . set ( e' := homotcoprodfcomp f ( idfun unit ) g ( idfun unit ) (invmap (weqrecompl X x isx) x') ) . unfold funcomp in e' .  rewrite e' .  apply idpath .  Defined . 


Definition homotrecomplfidfun { X : UU } ( x : X ) ( isx : isisolated X x ) : homot ( recomplf x x isx ( idfun ( compl X x ) ) ) ( idfun _ ) .
Proof . intros . intro x' . unfold recomplf . unfold weqrecompl . unfold invmap .   simpl .   unfold invrecompl . unfold funcomp. induction ( isx x' ) as [ e | ne ] .  simpl . apply e .  simpl . apply idpath .  Defined . 



Lemma ishomotinclrecomplf { X Y : UU } ( x : X ) ( y : Y ) ( isx : isisolated X x ) ( f : compl X x -> compl Y y ) ( x'n : compl X x ) ( y'n : compl Y y ) ( e : paths ( recomplf x y isx f ( pr1 x'n ) ) ( pr1 y'n ) ) : paths ( f x'n ) y'n .
Proof . intros . induction x'n as [ x' nexx' ] . induction y'n as [ y' neyy' ] . simpl in e  . apply ( invmaponpathsincl _ ( isinclpr1compl _ _ ) ) .   simpl .  rewrite ( pathsinv0 e ) . unfold recomplf. unfold invmap . unfold coprodf .   simpl .  unfold funcomp .  unfold invrecompl . induction ( isx x' ) as [ exx' | nexx'' ] .   induction ( nexx' exx' ) .  simpl . assert ( ee : paths nexx' nexx'' ) .    apply ( proofirrelevance _ ( isapropneg _ ) ) .   rewrite ee . apply idpath .  Defined . 
 




(** *** Standard weak equivalence between [ compl T t1 ] and [ compl T t2 ] for isolated [ t1 t2 ] *) 

Definition funtranspos0 { T : UU } ( t1 t2 : T ) ( is2 : isisolated T t2 ) ( x :compl T t1 ) : compl T t2  :=  match ( is2 ( pr1 x ) ) with 
ii1 e => match ( is2 t1 ) with ii1 e' => fromempty ( pr2 x ( pathscomp0 ( pathsinv0 e' ) e ) ) | ii2 ne' => complpair T t2 t1 ne' end | 
ii2 ne => complpair T t2 ( pr1 x ) ne end .

Definition homottranspos0t2t1t1t2 { T : UU } ( t1 t2 : T ) ( is1 : isisolated T t1 ) ( is2 : isisolated T t2 ) : homot ( funcomp ( funtranspos0 t1 t2 is2 ) ( funtranspos0 t2 t1 is1 ) ) ( idfun _ ) .
Proof. intros. intro x . unfold funtranspos0 . unfold funcomp . induction x as [ t net1 ] .  simpl .  induction ( is2 t ) as [ et2 | net2 ] . induction ( is2 t1 ) as [ et2t1 | net2t1 ] . induction (net1 (pathscomp0 (pathsinv0 et2t1) et2)) .  simpl . induction ( is1 t1 ) as [ e | ne ] .  induction ( is1 t2 ) as [ et1t2 | net1t2 ] .  induction (net2t1 (pathscomp0 (pathsinv0 et1t2) e)) . apply ( invmaponpathsincl _ ( isinclpr1compl _ _ ) _ _ ) . simpl . apply et2 . induction ( ne ( idpath _ ) ) .  simpl . induction ( is1 t ) as [ et1t | net1t ] .   induction ( net1 et1t ) .  apply ( invmaponpathsincl _ ( isinclpr1compl _ _ ) _ _ ) . simpl .  apply idpath . Defined . 

Definition weqtranspos0 { T : UU } ( t1 t2 : T ) ( is1 : isisolated T t1 ) ( is2 : isisolated T t2 ) : weq ( compl T t1 ) ( compl T t2 ) . 
Proof . intros . set ( f := funtranspos0 t1 t2 is2 ) . set ( g := funtranspos0 t2 t1 is1 ) . split with f .
assert ( egf : forall x : _ , paths ( g ( f x ) ) x ) . intro x . apply ( homottranspos0t2t1t1t2 t1 t2 is1 is2 ) . 
assert ( efg : forall x : _ , paths ( f ( g x ) ) x ) . intro x . apply ( homottranspos0t2t1t1t2 t2 t1 is2 is1 ) . 
apply ( gradth _ _ egf efg ) . Defined .


(** *** Transposition of two isolated points *)


Definition funtranspos { T : UU } ( t1 t2 : isolated T )  : T -> T := recomplf ( pr1 t1 ) ( pr1 t2 ) ( pr2 t1 ) ( funtranspos0 ( pr1 t1 ) ( pr1 t2 ) ( pr2 t2 ) ) .

Definition homottranspost2t1t1t2  { T : UU } ( t1 t2 : T ) ( is1 : isisolated T t1 ) ( is2 : isisolated T t2 ) : homot ( funcomp ( funtranspos ( tpair _ t1 is1 ) ( tpair _ t2 is2 ) ) ( funtranspos ( tpair _ t2 is2 ) ( tpair _ t1 is1 ) ) ) ( idfun _ ) .
Proof. intros. intro t . unfold funtranspos .  rewrite ( homotrecomplfcomp t1 t2 t1 is1 is2 _ _  t ) . set ( e:= homotrecomplfhomot t1 t1 is1 _ ( idfun _ ) ( homottranspos0t2t1t1t2 t1 t2 is1 is2 ) t ) . set ( e' := homotrecomplfidfun t1 is1 t ) .   apply ( pathscomp0 e e' ) .  Defined . 


Theorem weqtranspos { T : UU } ( t1 t2 : T ) ( is1 : isisolated T t1 ) ( is2 : isisolated T t2 ) : weq T T .
Proof . intros . set ( f := funtranspos ( tpair _ t1 is1) ( tpair _ t2 is2 ) ) . set ( g := funtranspos ( tpair _ t2 is2 ) ( tpair _ t1 is1 ) ) . split with f .
assert ( egf : forall t : T , paths ( g ( f t ) ) t ) . intro . apply homottranspost2t1t1t2 .
assert ( efg : forall t : T , paths ( f ( g t ) ) t ) . intro .  apply homottranspost2t1t1t2 .
apply ( gradth _ _ egf efg ) . Defined .  


Lemma pathsfuntransposoft1 { T : UU } ( t1 t2 : T ) ( is1 : isisolated T t1  ) ( is2 : isisolated T t2 ) : paths ( funtranspos ( tpair _ t1 is1 ) ( tpair _ t2 is2 ) t1 ) t2 .
Proof . intros . unfold funtranspos . rewrite ( pathsrecomplfxtoy t1 t2 is1 _ ) . apply idpath .  Defined .

Lemma pathsfuntransposoft2 { T : UU } ( t1 t2 : T ) ( is1 : isisolated T t1 ) ( is2 : isisolated T t2 ) : paths ( funtranspos ( tpair _ t1 is1 ) ( tpair _ t2 is2 ) t2 ) t1 .
Proof . intros .  unfold funtranspos . simpl . unfold funtranspos0 .   unfold recomplf .  unfold funcomp .  unfold coprodf . unfold invmap .  unfold weqrecompl .  unfold recompl .   simpl .  unfold invrecompl . induction ( is1 t2 ) as [ et1t2 | net1t2 ] . apply ( pathsinv0 et1t2 ) .  simpl . induction ( is2 t2 ) as [ et2t2 | net2t2 ] .  induction ( is2 t1 ) as [ et2t1 | net2t1 ] . induction (net1t2 (pathscomp0 (pathsinv0 et2t1) et2t2) ).  simpl . apply idpath . induction ( net2t2 ( idpath _ ) ) .  Defined .  

Lemma pathsfuntransposofnet1t2 { T : UU } ( t1 t2 : T ) ( is1 : isisolated T t1 ) ( is2 : isisolated T t2 ) ( t : T ) ( net1t : neg ( paths t1 t ) ) ( net2t : neg ( paths t2 t ) ) : paths ( funtranspos ( tpair _ t1 is1 ) ( tpair _ t2 is2 ) t ) t .
Proof . intros .  unfold funtranspos . simpl . unfold funtranspos0 .   unfold recomplf .  unfold funcomp .  unfold coprodf . unfold invmap .  unfold weqrecompl .  unfold recompl .   simpl .  unfold invrecompl . induction ( is1 t ) as [ et1t | net1t' ] . induction ( net1t et1t ) .  simpl .  induction ( is2 t ) as [ et2t | net2t' ] . induction ( net2t et2t ) . simpl . apply idpath . Defined . 

Lemma homotfuntranspos2 { T : UU } ( t1 t2 : T ) ( is1 : isisolated T t1 ) ( is2 : isisolated T t2 ) : homot ( funcomp ( funtranspos ( tpair _ t1 is1 ) ( tpair _ t2 is2 ) ) ( funtranspos ( tpair _ t1 is1 ) ( tpair _ t2 is2 ) ) ) ( idfun _ ) .
Proof . intros . intro t .   unfold funcomp . unfold idfun .   
induction ( is1 t ) as [ et1t | net1t ] .  rewrite ( pathsinv0 et1t ) .  rewrite ( pathsfuntransposoft1 _ _ ) .   rewrite ( pathsfuntransposoft2 _ _ ) .  apply idpath . 
induction ( is2 t ) as [ et2t | net2t ] .  rewrite ( pathsinv0 et2t ) .  rewrite ( pathsfuntransposoft2 _ _ ) .   rewrite ( pathsfuntransposoft1 _ _ ) .  apply idpath .
rewrite ( pathsfuntransposofnet1t2 _ _ _ _ _ net1t net2t ) . rewrite ( pathsfuntransposofnet1t2 _ _ _ _ _ net1t net2t ) . apply idpath . Defined . 





(** *** Types with decidable equality *)


Definition isdeceq (X:UU) : UU :=  forall (x x':X), coprod (paths x x' ) (paths x x' -> empty).

Lemma isdeceqweqf { X Y : UU } ( w : weq X Y ) ( is : isdeceq X ) : isdeceq Y .
Proof. intros . intros y y' . set ( w' := weqonpaths ( invweq w ) y y' ) .  set ( int := is ( ( invweq w ) y ) ( ( invweq w ) y' ) ) . induction int as [ i | ni ] .    apply ( ii1 ( ( invweq w' ) i ) ) . apply ( ii2 ( ( negf w' ) ni ) ) .  Defined . 

Lemma isdeceqweqb { X Y : UU } ( w : weq X Y ) ( is : isdeceq Y ) : isdeceq X .
Proof . intros . apply ( isdeceqweqf ( invweq w ) is ) . Defined . 

Theorem isdeceqinclb { X Y : UU } ( f : X -> Y ) ( is : isdeceq Y ) ( is' : isincl f ) : isdeceq X .
Proof.  intros .  intros x x' . set ( w := weqonpathsincl f is' x x' ) .  set ( int := is ( f x ) ( f x' ) ) . induction int as [ i | ni ] . apply ( ii1 ( ( invweq w ) i ) ) .   apply ( ii2 ( ( negf w ) ni ) ) .  Defined . 
 
Lemma isdeceqifisaprop ( X : UU ) : isaprop X -> isdeceq X .
Proof. intros X is . intros x x' . apply ( ii1 ( proofirrelevance _ is x x' ) ) .  Defined .

Theorem isasetifdeceq (X:UU): isdeceq X -> isaset X.
Proof. intro X . intro is. intros x x' . apply ( isaproppathsfromisolated X x ( is x ) ) .   Defined . 



Definition booleq { X : UU } ( is : isdeceq X ) ( x x' : X ) : bool .
Proof . intros . induction ( is x x' ) . apply true . apply false . Defined .    


Lemma eqfromdnegeq (X:UU)(is: isdeceq X)(x x':X): dneg ( paths x x' ) -> paths x x'.
Proof. intros X is x x' X0. induction ( is x x' ) as [ y | n ] . assumption .   induction ( X0 n ) . Defined .




(** *** [ bool ] is a [ deceq ] type and a set *)


Theorem isdeceqbool: isdeceq bool.
Proof. unfold isdeceq. intros x' x . induction x. induction x'. apply (ii1  (idpath true)). apply (ii2  nopathsfalsetotrue). induction x'.  apply (ii2  nopathstruetofalse). apply (ii1  (idpath false)). Defined. 

Theorem isasetbool: isaset bool.
Proof. apply (isasetifdeceq _ isdeceqbool). Defined. 




(** *** Splitting of [ X ] into a coproduct defined by a function [ X -> bool ] *)


Definition subsetsplit { X : UU } ( f : X -> bool ) ( x : X ) : coprod ( hfiber f true ) ( hfiber f false ) .
Proof . intros . induction ( boolchoice ( f x ) ) as [ a | b ] .  apply ( ii1 ( hfiberpair f x a ) ) . apply ( ii2 ( hfiberpair f x b ) ) .  Defined . 

Definition subsetsplitinv { X : UU } ( f : X -> bool ) ( ab : coprod (hfiber f true) (hfiber f false) )  : X :=  match ab with ii1 xt => pr1  xt | ii2 xf => pr1  xf end.


Theorem weqsubsetsplit { X : UU } ( f : X -> bool ) : weq X (coprod ( hfiber f true) ( hfiber f false) ) .
Proof . intros . set ( ff := subsetsplit f ) . set ( gg := subsetsplitinv f ) . split with ff .
assert ( egf : forall a : _ , paths ( gg ( ff a ) ) a ) . intros .   unfold ff .  unfold subsetsplit . induction ( boolchoice ( f a ) ) as [ et | ef ] . simpl .  apply idpath .  simpl .  apply idpath . 
assert ( efg : forall a : _ , paths ( ff ( gg a ) ) a ) . intros . induction a as [ et | ef ] .  induction et as [ x et' ] .  simpl . unfold ff . unfold subsetsplit . induction ( boolchoice ( f x ) ) as [ e1 | e2 ] .   apply ( maponpaths ( @ii1 _ _  ) ) .  apply ( maponpaths ( hfiberpair f x ) ) .  apply uip . apply isasetbool . induction ( nopathstruetofalse ( pathscomp0 ( pathsinv0 et' ) e2 ) ) .    induction ef as [ x et' ] .  simpl . unfold ff . unfold subsetsplit . induction ( boolchoice ( f x ) ) as [ e1 | e2 ] . induction ( nopathsfalsetotrue ( pathscomp0 ( pathsinv0 et' ) e1 ) ) .     apply ( maponpaths ( @ii2 _ _  ) ) .  apply ( maponpaths ( hfiberpair f x ) ) .  apply uip . apply isasetbool . 
apply ( gradth _ _ egf efg ) . Defined . 




(** ** Semi-boolean hfiber of functions over isolated points *)


Definition eqbx ( X : UU ) ( x : X ) ( is : isisolated X x ) : X -> bool .
Proof. intros X x is x' . induction ( is x' ) . apply true . apply false . Defined .

Lemma iscontrhfibereqbx ( X : UU ) ( x : X ) ( is : isisolated X x ) : iscontr ( hfiber ( eqbx X x is ) true ) .
Proof. intros . assert ( b : paths  ( eqbx X x is x ) true ) . unfold eqbx .   induction ( is x ) as [ e | ne ] .  apply idpath .  induction ( ne ( idpath _ ) ) .  set ( i := hfiberpair ( eqbx X x is ) x b ) .  split with i . 
unfold eqbx . induction ( boolchoice ( eqbx X x is x ) ) as [ b' | nb' ] .  intro t .  induction t as [ x' e ] .  assert ( e' : paths x' x ) .  induction ( is x' ) as [ ee | nee ] .  apply ( pathsinv0 ee ) . induction ( nopathsfalsetotrue e )  . apply ( invmaponpathsincl _ ( isinclfromhfiber ( eqbx X x is ) isasetbool true ) ( hfiberpair _ x' e ) i e' ) .  induction ( nopathstruetofalse ( pathscomp0 ( pathsinv0 b ) nb' ) ) . Defined . 

Definition bhfiber { X Y : UU } ( f : X -> Y ) ( y : Y ) ( is : isisolated Y y ) := hfiber ( fun x : X => eqbx Y y is ( f x ) ) true .

Lemma weqhfibertobhfiber { X Y : UU } ( f : X -> Y ) ( y : Y ) ( is : isisolated Y y ) : weq ( hfiber f y ) ( bhfiber f y is ) .
Proof . intros . set ( g := eqbx Y y is ) . set ( ye := pr1 ( iscontrhfibereqbx Y y is ) ) . split with ( hfibersftogf f g true ye ) . apply ( isofhlevelfffromZ 0 _ _ ye ( fibseqhf f g true ye ) ) .  apply ( isapropifcontr ) . apply ( iscontrhfibereqbx _ y is ) . Defined .  















(** *** h-fibers of [ ii1 ] and [ ii2 ] *)


Theorem isinclii1 (X Y:UU): isincl  (@ii1 X Y).
Proof. intros. set (f:= @ii1 X Y). set (g:= coprodtoboolsum X Y). set (gf:= fun x:X => (g (f x))). set (gf':= fun x:X => tpair (boolsumfun X Y) true x). 
assert (h: forall x:X , paths (gf' x) (gf x)). intro. apply idpath. 
assert (is1: isofhlevelf (S O)  gf'). apply (isofhlevelfsnfib O (boolsumfun X Y) true (isasetbool true true)).
assert (is2: isofhlevelf (S O)  gf). apply (isofhlevelfhomot (S O)  gf' gf h is1).  
apply (isofhlevelff (S O) _ _ is2  (isofhlevelfweq (S (S O) )  (weqcoprodtoboolsum X Y))). Defined. 


Corollary iscontrhfiberii1x ( X Y : UU ) ( x : X ) : iscontr ( hfiber ( @ii1 X Y ) ( ii1 x ) ) .
Proof. intros . set ( xe1 :=  hfiberpair ( @ii1 _ _ ) x ( idpath ( @ii1 X Y x ) ) ) . apply ( iscontraprop1 ( isinclii1 X Y ( ii1 x ) ) xe1 ) .  Defined .

Corollary neghfiberii1y ( X Y : UU ) ( y : Y ) : neg ( hfiber ( @ii1 X Y ) ( ii2 y ) ) .
Proof. intros . intro xe . induction xe as [ x e ] . apply ( negpathsii1ii2 _ _ e ) .  Defined. 





Theorem isinclii2 (X Y:UU): isincl  (@ii2 X Y).
Proof. intros. set (f:= @ii2 X Y). set (g:= coprodtoboolsum X Y). set (gf:= fun y:Y => (g (f y))). set (gf':= fun y:Y => tpair (boolsumfun X Y) false y). 
assert (h: forall y:Y , paths (gf' y) (gf y)). intro. apply idpath. 
assert (is1: isofhlevelf (S O)  gf'). apply (isofhlevelfsnfib O (boolsumfun X Y) false (isasetbool false false)).
assert (is2: isofhlevelf (S O)  gf). apply (isofhlevelfhomot (S O)  gf' gf h is1).  
apply (isofhlevelff (S O)  _ _ is2 (isofhlevelfweq (S (S O)) ( weqcoprodtoboolsum X Y))). Defined. 


Corollary iscontrhfiberii2y ( X Y : UU ) ( y : Y ) : iscontr ( hfiber ( @ii2 X Y ) ( ii2 y ) ) .
Proof. intros . set ( xe1 :=  hfiberpair ( @ii2 _ _ ) y ( idpath ( @ii2 X Y y ) ) ) . apply ( iscontraprop1 ( isinclii2 X Y ( ii2 y ) ) xe1 ) .  Defined .

Corollary neghfiberii2x ( X Y : UU ) ( x : X ) : neg ( hfiber ( @ii2 X Y ) ( ii1 x ) ) .
Proof. intros . intro ye . induction ye as [ y e ] . apply ( negpathsii2ii1 _ _ e ) .  Defined. 




Lemma negintersectii1ii2 { X Y : UU } (z: coprod X Y): hfiber  (@ii1 X Y) z -> hfiber  (@ii2 _ _) z -> empty.
Proof. intros X Y z X0 X1. induction X0 as [ t x ]. induction X1 as [ t0 x0 ].  
set (e:= pathscomp0   x (pathsinv0 x0)). apply (negpathsii1ii2 _ _  e). Defined. 


(** *** [ ii1 ] and [ ii2 ] map isolated points to isoloated points *)

Lemma isolatedtoisolatedii1 (X Y:UU)(x:X)(is:isisolated _ x): isisolated ( coprod X Y ) (ii1 x).
Proof. intros. unfold isisolated .   intro x' .  induction x' as [ x0 | y ] . induction (is x0) as [ p | e ] .  apply (ii1  (maponpaths (@ii1 X Y)  p)). apply (ii2  (negf  (invmaponpathsincl  (@ii1 X Y) (isinclii1 X Y) _ _ ) e)). apply (ii2  (negpathsii1ii2  x y)). Defined. 


Lemma isolatedtoisolatedii2 (X Y:UU)(y:Y)(is:isisolated _ y): isisolated ( coprod X Y ) (ii2 y).
Proof. intros.  intro x' .  induction x' as [ x | y0 ] . apply (ii2  (negpathsii2ii1  x y)). induction (is y0) as [ p | e ] .  apply (ii1  (maponpaths (@ii2 X Y)  p)). apply (ii2  (negf  (invmaponpathsincl  (@ii2 X Y) (isinclii2 X Y) _ _ ) e)).  Defined. 























(** *** h-fibers of [ coprodf ] of two functions *)


Theorem weqhfibercoprodf1 { X Y X' Y' : UU } (f: X -> X')(g:Y -> Y')(x':X'): weq (hfiber  f x') (hfiber  (coprodf   f g) (ii1  x')).
Proof. intros.  set ( ix := @ii1 X Y ) . set ( ix' := @ii1 X' Y' ) . set ( fpg := coprodf f g ) . set ( fpgix := fun x : X => ( fpg ( ix x ) ) ) .

assert ( w1 : weq ( hfiber f x' ) ( hfiber fpgix ( ix' x' ) ) ) . apply ( samehfibers f ix' ( isinclii1 _ _ ) x' ) .
assert ( w2 : weq ( hfiber fpgix ( ix' x' ) ) ( hfiber fpg ( ix' x' ) ) ) . split with (hfibersgftog  ix fpg ( ix' x' ) ) . unfold isweq. intro y .  

set (u:= invezmaphf ix fpg ( ix' x' ) y).
assert (is: isweq u). apply isweqinvezmaphf. 

apply  (iscontrweqb  ( weqpair u is ) ) . induction y as [ xy e ] .  induction xy as [ x0 | y0 ] . simpl .  apply iscontrhfiberofincl . apply ( isinclii1 X Y ) .  apply ( fromempty ( ( negpathsii2ii1 x' ( g y0 ) ) e ) ) .

apply ( weqcomp w1 w2 ) .
Defined.


Theorem weqhfibercoprodf2 { X Y X' Y' : UU } (f: X -> X')(g:Y -> Y')(y':Y'): weq (hfiber  g y') (hfiber  (coprodf   f g) (ii2  y')).
Proof. intros.  set ( iy := @ii2 X Y ) . set ( iy' := @ii2 X' Y' ) . set ( fpg := coprodf f g ) . set ( fpgiy := fun y : Y => ( fpg ( iy y ) ) ) .

assert ( w1 : weq ( hfiber g y' ) ( hfiber fpgiy ( iy' y' ) ) ) . apply ( samehfibers g iy' ( isinclii2 _ _ ) y' ) .
assert ( w2 : weq ( hfiber fpgiy ( iy' y' ) ) ( hfiber fpg ( iy' y' ) ) ) . split with (hfibersgftog  iy fpg ( iy' y' ) ) . unfold isweq. intro y .  

set (u:= invezmaphf iy fpg ( iy' y' ) y).
assert (is: isweq u). apply isweqinvezmaphf. 

apply  (iscontrweqb  ( weqpair u is ) ) . induction y as [ xy e ] .  induction xy as [ x0 | y0 ] . simpl .   apply ( fromempty ( ( negpathsii1ii2 ( f x0 ) y' ) e ) ) .  simpl. apply iscontrhfiberofincl . apply ( isinclii2 X Y ) . 

apply ( weqcomp w1 w2 ) .
Defined.

 



(** *** Theorem saying that coproduct of two functions of h-level n is of h-level n *)



Theorem isofhlevelfcoprodf (n:nat) { X Y Z T : UU } (f : X -> Z ) ( g : Y -> T )( is1 : isofhlevelf n  f ) ( is2 : isofhlevelf n  g ) : isofhlevelf n (coprodf f g).
Proof. intros. unfold isofhlevelf .  intro y .  induction y as [ z | t ] .  apply (isofhlevelweqf n (weqhfibercoprodf1  f g z) ). apply ( is1 z ) . apply (isofhlevelweqf n (weqhfibercoprodf2  f g t )). apply ( is2 t ) . Defined. 





(** *** Theorems about h-levels of coproducts and their component types *)


Theorem isofhlevelsnsummand1 ( n : nat ) ( X Y : UU ) : isofhlevel ( S n ) ( coprod X Y ) -> isofhlevel ( S n ) X .
Proof. intros n X Y is . apply ( isofhlevelXfromfY ( S n ) ( @ii1 X Y ) ( isofhlevelfsnincl n _ ( isinclii1 _ _ ) ) is ) .  Defined.


Theorem isofhlevelsnsummand2 ( n : nat ) ( X Y : UU ) : isofhlevel ( S n ) ( coprod X Y ) -> isofhlevel ( S n ) Y .
Proof. intros n X Y is . apply ( isofhlevelXfromfY ( S n ) ( @ii2 X Y ) ( isofhlevelfsnincl n _ ( isinclii2 _ _ ) ) is ) .  Defined.


Theorem isofhlevelssncoprod ( n : nat ) ( X Y : UU ) ( isx : isofhlevel ( S ( S n ) ) X ) ( isy : isofhlevel ( S ( S n ) ) Y ) : isofhlevel ( S ( S n ) ) ( coprod X Y ) .
Proof. intros . apply isofhlevelfromfun .  set ( f := coprodf ( fun x : X => tt ) ( fun y : Y => tt ) ) . assert ( is1 : isofhlevelf ( S ( S n ) ) f ) . apply ( isofhlevelfcoprodf ( S ( S n ) ) _ _ ( isofhleveltofun _ X isx ) ( isofhleveltofun _ Y isy ) ) .  assert ( is2 : isofhlevel ( S ( S n ) ) ( coprod unit unit ) ) .  apply ( isofhlevelweqb ( S ( S n ) ) boolascoprod ( isofhlevelssnset n _ ( isasetbool ) ) ) . apply ( isofhlevelfgf ( S ( S n ) ) _ _ is1 ( isofhleveltofun _ _ is2 ) ) .  Defined . 


Lemma isasetcoprod ( X Y : UU ) ( isx : isaset X ) ( isy : isaset Y ) : isaset ( coprod X Y ) .
Proof. intros . apply ( isofhlevelssncoprod 0 _ _ isx isy ) . Defined . 



(** *** h-fibers of the sum of two functions [ sumofmaps f g ] *)


Lemma coprodofhfiberstohfiber { X Y Z : UU } ( f : X -> Z ) ( g : Y -> Z ) ( z : Z ) : coprod ( hfiber f z ) ( hfiber g z ) -> hfiber ( sumofmaps f g ) z .
Proof. intros X Y Z f g z hfg .  induction hfg as [ hf | hg ] .  induction hf as [ x fe ] . split with ( ii1 x ) . simpl .  assumption .  induction hg as [ y ge ] .  split with ( ii2 y ) . simpl .  assumption .  
Defined.

Lemma hfibertocoprodofhfibers { X Y Z : UU } ( f : X -> Z ) ( g : Y -> Z ) ( z : Z ) :  hfiber ( sumofmaps f g ) z ->  coprod ( hfiber f z ) ( hfiber g z ) .
Proof. intros X Y Z f g z hsfg . induction hsfg as [ xy e ] .  induction xy as [ x | y ] .  simpl in e .  apply ( ii1 ( hfiberpair _ x e ) ) .  simpl in e .  apply ( ii2 ( hfiberpair _ y e ) ) .  Defined .

Theorem weqhfibersofsumofmaps { X Y Z : UU } ( f : X -> Z ) ( g : Y -> Z ) ( z : Z ) : weq ( coprod ( hfiber f z ) ( hfiber g z ) ) ( hfiber ( sumofmaps f g ) z ) .
Proof. intros . set ( ff := coprodofhfiberstohfiber f g z ) . set ( gg := hfibertocoprodofhfibers f g z ) . split with ff .  
assert ( effgg : forall hsfg : _ , paths ( ff ( gg hsfg ) ) hsfg ) . intro .  induction hsfg as [ xy e ] . induction xy as [ x | y ] . simpl .  apply idpath .  simpl . apply idpath . 
assert ( eggff : forall hfg : _ , paths ( gg ( ff hfg ) ) hfg ) . intro . induction hfg as [ hf | hg ] . induction hf as [ x fe ] . simpl .  apply idpath .  induction hg as [ y ge ] . simpl . apply idpath .
apply ( gradth _ _ eggff effgg ) . Defined .  




(** *** Theorem saying that the sum of two functions of h-level ( S ( S n ) ) is of hlevel ( S ( S n ) ) *)


Theorem isofhlevelfssnsumofmaps ( n : nat ) { X Y Z : UU } ( f : X -> Z ) ( g : Y -> Z ) ( isf : isofhlevelf ( S ( S n ) ) f ) ( isg : isofhlevelf ( S ( S n ) ) g ) : isofhlevelf ( S ( S n ) ) ( sumofmaps f g ) .
Proof . intros . intro z .  set ( w := weqhfibersofsumofmaps f g z ) .  set ( is := isofhlevelssncoprod n _ _ ( isf z ) ( isg z ) ) .  apply ( isofhlevelweqf _ w is ) .  Defined . 



(** *** Theorem saying that the sum of two functions of h-level n with non-intersecting images is of h-level n *)


Lemma noil1 { X Y Z : UU } ( f : X -> Z ) ( g : Y -> Z ) ( noi : forall ( x : X ) ( y : Y ) , neg ( paths ( f x ) ( g y ) ) ) ( z : Z ) : hfiber f z -> hfiber g z -> empty .
Proof. intros X Y Z f g noi z hfz hgz . induction hfz as [ x fe ] . induction hgz as [ y ge ] . apply ( noi x y ( pathscomp0 fe ( pathsinv0 ge ) ) ) .   Defined . 


Lemma weqhfibernoi1  { X Y Z : UU } ( f : X -> Z ) ( g : Y -> Z ) ( noi : forall ( x : X ) ( y : Y ) , neg ( paths ( f x ) ( g y ) ) ) ( z : Z ) ( xe : hfiber f z ) : weq ( hfiber ( sumofmaps f g ) z ) ( hfiber f z ) .
Proof. intros . set ( w1 := invweq ( weqhfibersofsumofmaps f g z ) ) .  assert ( a : neg ( hfiber g z ) ) . intro ye . apply ( noil1 f g noi z xe ye ) .    set ( w2 := invweq ( weqii1withneg ( hfiber f z ) a ) ) .  apply ( weqcomp w1 w2 ) . Defined .  

Lemma weqhfibernoi2  { X Y Z : UU } ( f : X -> Z ) ( g : Y -> Z ) ( noi : forall ( x : X ) ( y : Y ) , neg ( paths ( f x ) ( g y ) ) ) ( z : Z ) ( ye : hfiber g z ) : weq ( hfiber ( sumofmaps f g ) z ) ( hfiber g z ) .
Proof. intros . set ( w1 := invweq ( weqhfibersofsumofmaps f g z ) ) .  assert ( a : neg ( hfiber f z ) ) . intro xe . apply ( noil1 f g noi z xe ye ) .    set ( w2 := invweq ( weqii2withneg ( hfiber g z ) a ) ) .  apply ( weqcomp w1 w2 ) . Defined .  



Theorem isofhlevelfsumofmapsnoi ( n : nat ) { X Y Z : UU } ( f : X -> Z ) ( g : Y -> Z ) ( isf : isofhlevelf n f ) ( isg : isofhlevelf n g ) ( noi : forall ( x : X ) ( y : Y ) , neg ( paths ( f x ) ( g y ) ) ) : isofhlevelf n ( sumofmaps f g ) .
Proof. intros .  intro z .  induction n as [ | n ] .   set ( zinx := invweq ( weqpair _ isf ) z ) . set ( ziny := invweq ( weqpair _ isg ) z ) . assert ( ex : paths ( f zinx ) z ) .  apply ( homotweqinvweq ( weqpair _ isf ) z ) . assert ( ey : paths ( g ziny ) z ) . apply ( homotweqinvweq ( weqpair _ isg ) z ) .   induction ( ( noi zinx ziny ) ( pathscomp0 ex ( pathsinv0 ey ) ) ) . 
apply isofhlevelsn . intro hfgz .  induction ( ( invweq ( weqhfibersofsumofmaps f g z ) hfgz ) ) as [ xe | ye ] .   apply ( isofhlevelweqb _ ( weqhfibernoi1 f g noi z xe ) ( isf z ) ) .   apply ( isofhlevelweqb _ ( weqhfibernoi2 f g noi z ye ) ( isg z ) ) . Defined . 







(** *** Coproducts and complements *)


Definition tocompltoii1x (X Y:UU)(x:X): coprod (compl X x) Y -> compl (coprod X Y) (ii1  x).
Proof. intros X Y x X0. induction X0 as [ c | y ] .  split with (ii1  (pr1  c)). 
assert (e: neg(paths x (pr1 c) )). apply (pr2  c). apply (negf  (invmaponpathsincl  ( @ii1 _ _ ) (isinclii1 X Y) _ _) e). 
split with (ii2  y). apply (negf  (pathsinv0 ) (negpathsii2ii1 x y)). Defined.


Definition fromcompltoii1x (X Y:UU)(x:X): compl (coprod X Y) (ii1  x) ->  coprod (compl X x) Y.
Proof. intros X Y x X0. induction X0 as [ t x0 ].  induction t as [ x1 | y ]. 
assert (ne: neg (paths x x1 )). apply (negf  (maponpaths ( @ii1 _ _ ) ) x0). apply (ii1  (complpair _ _ x1 ne )). apply (ii2  y). Defined. 


Theorem isweqtocompltoii1x (X Y:UU)(x:X): isweq (tocompltoii1x X Y x).
Proof. intros. set (f:= tocompltoii1x X Y x). set (g:= fromcompltoii1x X Y x).
assert (egf:forall nexy:_ , paths (g (f nexy)) nexy). intro. induction nexy as [ c | y ]. induction c as [ t x0 ]. simpl. 
assert (e: paths (negf (maponpaths (@ii1 X Y)) (negf (invmaponpathsincl  (@ii1 X Y) (isinclii1 X Y) x t) x0)) x0). apply (isapropneg (paths x t) ). 
apply (maponpaths (fun ee: neg (paths x t ) => ii1  (complpair X x t ee))  e). apply idpath.

assert (efg: forall neii1x:_, paths (f (g neii1x)) neii1x). intro.  induction neii1x as [ t x0 ]. induction t as [ x1 | y ].  simpl. 
assert (e: paths  (negf (invmaponpathsincl (@ii1 X Y) (isinclii1 X Y) x x1 ) (negf (maponpaths (@ii1 X Y) ) x0)) x0). apply (isapropneg (paths _ _ )  ).
apply (maponpaths (fun ee: (neg (paths (ii1 x) (ii1 x1))) => (complpair _ _ (ii1 x1) ee))  e). simpl. 
assert (e: paths (negf pathsinv0 (negpathsii2ii1 x y)) x0). apply (isapropneg (paths _ _ ) ).
apply (maponpaths   (fun ee: (neg (paths (ii1 x) (ii2 y) )) => (complpair _ _ (ii2 y) ee))  e). 
apply (gradth  f g egf efg). Defined.


Definition tocompltoii2y (X Y:UU)(y:Y): coprod X (compl Y y) -> compl (coprod X Y) (ii2  y).
Proof. intros X Y y X0. induction X0 as [ x | c ]. split with (ii1  x). apply (negpathsii2ii1 x y ). 
split with (ii2  (pr1  c)). assert (e: neg(paths y (pr1  c) )). apply (pr2  c). apply (negf  (invmaponpathsincl  ( @ii2 _ _ ) (isinclii2 X Y) _ _ ) e). 
Defined.



Definition fromcompltoii2y (X Y:UU)(y:Y): compl (coprod X Y) (ii2  y) ->  coprod X (compl Y y).
Proof. intros X Y y X0. induction X0 as [ t x ].  induction t as [ x0 | y0 ]. apply (ii1  x0). 
assert (ne: neg (paths y y0 )). apply (negf  (maponpaths ( @ii2 _ _ ) ) x). apply (ii2  (complpair _ _ y0 ne)). Defined. 


Theorem isweqtocompltoii2y (X Y:UU)(y:Y): isweq (tocompltoii2y X Y y).
Proof. intros. set (f:= tocompltoii2y X Y y). set (g:= fromcompltoii2y X Y y).
assert (egf:forall nexy:_ , paths (g (f nexy)) nexy). intro. induction nexy as [ x | c ]. 
apply idpath. induction c as [ t x ]. simpl. 
assert (e: paths (negf (maponpaths (@ii2 X Y) ) (negf (invmaponpathsincl (@ii2 X Y) (isinclii2 X Y) y t) x)) x). apply (isapropneg (paths y t ) ). 
apply (maponpaths (fun ee: neg ( paths y t ) => ii2  (complpair _ y t ee))  e). 

assert (efg: forall neii2x:_, paths (f (g neii2x)) neii2x). intro.  induction neii2x as [ t x ]. induction t as [ x0 | y0 ].  simpl. 
assert (e: paths (negpathsii2ii1 x0 y) x). apply (isapropneg (paths _ _ ) ).
apply (maponpaths   (fun ee: (neg (paths (ii2 y) (ii1 x0)  )) => (complpair _ _ (ii1 x0) ee))  e). simpl.
assert (e: paths  (negf (invmaponpathsincl _ (isinclii2 X Y) y y0 ) (negf (maponpaths (@ii2 X Y) ) x)) x). apply (isapropneg (paths _ _ )  ).
apply (maponpaths (fun ee: (neg (paths (ii2 y) (ii2 y0)  )) => (complpair _ _ (ii2 y0) ee))  e). 
apply (gradth f g egf efg). Defined.







Definition tocompltodisjoint (X:UU): X -> compl (coprod X unit) (ii2  tt) := fun x:_ => complpair _ _ (ii1  x) (negpathsii2ii1 x tt).

Definition fromcompltodisjoint (X:UU): compl (coprod X unit) (ii2  tt) -> X.
Proof. intros X X0. induction X0 as [ t x ].  induction t as [ x0 | u ] . assumption.  induction u. apply (fromempty (x (idpath (ii2 tt)))). Defined.


Lemma isweqtocompltodisjoint (X:UU): isweq (tocompltodisjoint X).
Proof. intros. set (ff:= tocompltodisjoint X). set (gg:= fromcompltodisjoint X). 
assert (egf: forall x:X, paths (gg (ff x)) x).  intro.  apply idpath.
assert (efg: forall xx:_, paths (ff (gg xx)) xx). intro. induction xx as [ t x ].  induction t as [ x0 | u ] .   simpl.  unfold ff. unfold tocompltodisjoint. simpl. assert (ee: paths  (negpathsii2ii1 x0 tt) x).  apply (proofirrelevance _ (isapropneg _) ). induction ee. apply idpath. induction u.  simpl. apply (fromempty (x (idpath _))). apply (gradth  ff gg egf efg).  Defined. 


Definition weqtocompltodisjoint ( X : UU ) := weqpair _ ( isweqtocompltodisjoint X ) .

Corollary isweqfromcompltodisjoint (X:UU): isweq (fromcompltodisjoint X).
Proof. intros. apply (isweqinvmap  ( weqtocompltodisjoint X ) ). Defined. 














(** ** Decidable propositions and decidable inclusions *)

(** *** Decidable propositions [ isdecprop ] *)

Definition isdecprop ( X : UU ) := iscontr ( coprod X ( neg X ) ) .


Lemma isdecproptoisaprop ( X : UU ) ( is : isdecprop X ) : isaprop X .
Proof. intros X is . apply ( isofhlevelsnsummand1 0 _ _ ( isapropifcontr is ) ) . Defined .  
Coercion isdecproptoisaprop : isdecprop >-> isaprop .

Lemma isdecpropif ( X : UU ) : isaprop X -> ( coprod X ( neg X ) ) -> isdecprop X .
Proof. intros X is a . assert ( is1 : isaprop ( coprod X ( neg X ) ) ) . apply isapropdec . assumption .   apply ( iscontraprop1 is1 a ) . Defined.

Lemma isdecpropfromiscontr { X : UU } ( is : iscontr X ) : isdecprop X .
Proof. intros . apply ( isdecpropif _ (  is ) ( ii1 ( pr1 is ) ) ) . Defined.

Lemma isdecpropempty : isdecprop empty .
Proof. apply ( isdecpropif _ isapropempty ( ii2 ( fun a : empty => a ) ) ) . Defined.

Lemma isdecpropweqf { X Y : UU } ( w : weq X Y ) ( is : isdecprop X ) : isdecprop Y .
Proof. intros . apply  isdecpropif . apply ( isofhlevelweqf 1 w ( isdecproptoisaprop _ is ) ) . induction ( pr1 is ) as [ x | nx ] . apply ( ii1 ( w x ) ) .  apply ( ii2 ( negf ( invweq w ) nx ) ) . Defined .

Lemma isdecpropweqb { X Y : UU } ( w : weq X Y ) ( is : isdecprop Y ) : isdecprop X .
Proof. intros . apply  isdecpropif . apply ( isofhlevelweqb 1 w ( isdecproptoisaprop _ is ) ) . induction ( pr1 is ) as [ y | ny ] . apply ( ii1 ( invweq w y ) ) .  apply ( ii2 ( ( negf w ) ny ) ) . Defined .

Lemma isdecproplogeqf { X Y : UU } ( isx : isdecprop X ) ( isy : isaprop Y ) ( lg : X <-> Y ) : isdecprop Y .
Proof . intros. set ( w := weqimplimpl ( pr1 lg ) ( pr2 lg ) isx isy ) . apply ( isdecpropweqf w isx ) . Defined .

Lemma isdecproplogeqb { X Y : UU } ( isx : isaprop X ) ( isy : isdecprop Y ) ( lg : X <-> Y ) : isdecprop X .
Proof . intros. set ( w := weqimplimpl ( pr1 lg ) ( pr2 lg ) isx isy ) . apply ( isdecpropweqb w isy ) . Defined .    



Lemma isdecpropfromneg { X : UU } ( ne : neg X ) : isdecprop X .
Proof. intros . apply ( isdecpropweqb ( weqtoempty ne ) isdecpropempty ) . Defined .  

Lemma isdecproppaths { X : UU } ( is : isdeceq X ) ( x x' : X ) : isdecprop ( paths x x' ) .
Proof. intros . apply ( isdecpropif _ ( isasetifdeceq _ is x x' ) ( is x x' ) ) .  Defined .

Lemma isdeceqif { X : UU } ( is : forall x x' : X , isdecprop ( paths x x' ) ) : isdeceq X .
Proof . intros . intros x x' . apply ( pr1 ( is x x' ) ) . Defined . 

Lemma isaninv1 (X:UU): isdecprop X  -> isaninvprop X.
Proof. intros X is1. unfold isaninvprop. set (is2:= pr1  is1). simpl in is2. 
assert (adjevinv: dneg X -> X). intro X0.  induction is2 as [ a | b ].  assumption. induction (X0 b). 
assert (is3: isaprop (dneg X)). apply (isapropneg (X -> empty)). apply (isweqimplimpl  (todneg X) adjevinv is1 is3). Defined. 


Theorem isdecpropfibseq1 { X Y Z : UU } ( f : X -> Y ) ( g : Y -> Z ) ( z : Z ) ( fs : fibseqstr f g z ) : isdecprop X -> isaprop Z -> isdecprop Y .
Proof . intros X Y Z f g z fs isx isz .  assert ( isc : iscontr Z ) . apply ( iscontraprop1 isz z ) .  assert ( isweq f ) . apply ( isweqfinfibseq f g z fs isc ) .  apply ( isdecpropweqf ( weqpair _ X0 ) isx ) . Defined .

Theorem isdecpropfibseq0 { X Y Z : UU } ( f : X -> Y ) ( g : Y -> Z ) ( z : Z ) ( fs : fibseqstr f g z ) : isdecprop Y -> isdeceq Z -> isdecprop X .
Proof . intros X Y Z f g z fs isy isz . assert ( isg : isofhlevelf 1 g ) . apply ( isofhlevelffromXY 1 g ( isdecproptoisaprop _ isy ) ( isasetifdeceq _ isz ) ) . 
assert ( isp : isaprop X ) . apply ( isofhlevelXfromg 1 f g z fs isg ) . 
induction ( pr1 isy ) as [ y | ny ] .  apply ( isdecpropfibseq1 _ _ y ( fibseq1 f g z fs y ) ( isdecproppaths isz ( g y ) z ) ( isdecproptoisaprop _ isy ) ) . 
apply ( isdecpropif _ isp ( ii2  ( negf f ny ) ) ) . Defined. 

Theorem isdecpropdirprod { X Y : UU } ( isx : isdecprop X ) ( isy : isdecprop Y ) : isdecprop ( dirprod X Y ) .
Proof. intros . assert ( isp : isaprop ( dirprod X Y ) ) . apply ( isofhleveldirprod 1 _ _ ( isdecproptoisaprop _ isx ) ( isdecproptoisaprop _ isy ) ) .  induction ( pr1 isx ) as [ x | nx ] . induction ( pr1 isy ) as [ y | ny ] .  apply ( isdecpropif _ isp ( ii1 ( dirprodpair x y ) ) ) . assert ( nxy : neg ( dirprod X Y ) ) . intro xy . induction xy as [ x0  y0 ] . apply ( ny y0 ) .  apply ( isdecpropif _ isp ( ii2 nxy ) ) .  assert ( nxy : neg ( dirprod X Y ) ) . intro xy . induction xy as [ x0  y0 ] . apply ( nx x0 ) .  apply ( isdecpropif _ isp ( ii2 nxy ) ) . Defined.

Lemma fromneganddecx { X Y : UU } ( isx : isdecprop X ) ( nf : neg ( dirprod X Y ) ) : coprod ( neg X ) ( neg Y ) .
Proof . intros .  induction ( pr1 isx ) as [ x | nx ] .  set ( ny := negf ( fun y : Y => dirprodpair x y ) nf ) . apply ( ii2 ny ) .   apply ( ii1 nx ) . Defined .

Lemma fromneganddecy { X Y : UU } ( isy : isdecprop Y ) ( nf : neg ( dirprod X Y ) ) : coprod ( neg X ) ( neg Y ) .
Proof . intros .  induction ( pr1 isy ) as [ y | ny ] .  set ( nx := negf ( fun x : X => dirprodpair x y ) nf ) . apply ( ii1 nx ) . apply ( ii2 ny ) .   Defined .


(** *** Paths to and from an isolated point form a decidable proposition *)

Lemma isdecproppathsfromisolated ( X : UU ) ( x : X ) ( is : isisolated X x ) ( x' : X ) : isdecprop ( paths x x' ) .
Proof. intros . apply isdecpropif . apply isaproppathsfromisolated .   assumption .  apply ( is x' ) .  Defined .

Lemma isdecproppathstoisolated  ( X : UU ) ( x : X ) ( is : isisolated X x ) ( x' : X ) : isdecprop ( paths x' x ) .
Proof . intros . apply ( isdecpropweqf ( weqpathsinv0 x x' ) ( isdecproppathsfromisolated X x is x' ) ) . Defined .  


(** *** Decidable inclusions *)



Definition isdecincl {X Y:UU} (f :X -> Y) := forall y:Y, isdecprop ( hfiber f y ). 
Lemma isdecincltoisincl { X Y : UU } ( f : X -> Y ) : isdecincl f -> isincl f .
Proof. intros X Y f is . intro y . apply ( isdecproptoisaprop _ ( is y ) ) . Defined.
Coercion isdecincltoisincl : isdecincl >-> isincl .

Lemma isdecinclfromisweq { X Y : UU } ( f : X -> Y ) : isweq f -> isdecincl f .
Proof. intros X Y f iswf .  intro y .  apply ( isdecpropfromiscontr ( iswf y ) ) . Defined .

Lemma isdecpropfromdecincl { X Y : UU } ( f : X -> Y ) : isdecincl f -> isdecprop Y -> isdecprop X .
Proof. intros X Y f isf isy .  induction ( pr1 isy ) as [ y | n ] . assert ( w : weq ( hfiber f y ) X ) . apply ( weqhfibertocontr f y ( iscontraprop1 ( isdecproptoisaprop _ isy )  y ) ) . apply ( isdecpropweqf w ( isf y ) ) .  apply isdecpropif . apply ( isapropinclb _ isf isy ) .  apply ( ii2 ( negf f n ) ) .  Defined . 


Lemma isdecinclii1 (X Y: UU): isdecincl ( @ii1 X Y ) .
Proof. intros. intro y . induction y as [ x | y ] . apply ( isdecpropif _ ( isinclii1 X Y ( ii1 x ) ) ( ii1 (hfiberpair  (@ii1 _ _ )  x (idpath _ )) ) ) .   
 apply ( isdecpropif _ ( isinclii1 X Y ( ii2 y ) ) ( ii2 ( neghfiberii1y X Y y ) ) ) .  Defined. 

 
Lemma isdecinclii2 (X Y: UU): isdecincl ( @ii2 X Y ) .
Proof. intros. intro y . induction y as [ x | y ] .  apply ( isdecpropif _ ( isinclii2 X Y ( ii1 x ) ) ( ii2 ( neghfiberii2x X Y x ) ) ) . 
apply ( isdecpropif _ ( isinclii2 X Y ( ii2 y ) ) ( ii1 (hfiberpair  (@ii2 _ _ )  y (idpath _ )) ) ) .   Defined. 


Lemma isdecinclpr1 { X : UU } ( P : X -> UU ) ( is : forall x : X , isdecprop ( P x ) ) : isdecincl ( @pr1 _ P ) .
Proof . intros . intro x . assert ( w : weq ( P x ) ( hfiber (@pr1 _ P )  x ) ) . apply ezweqpr1 .  apply ( isdecpropweqf w ( is x ) ) . Defined . 


Theorem isdecinclhomot { X Y : UU } ( f g : X -> Y ) ( h : forall x : X , paths ( f x ) ( g x ) ) ( is : isdecincl f ) : isdecincl g .
Proof. intros . intro y . apply ( isdecpropweqf ( weqhfibershomot f g h y ) ( is y ) ) . Defined . 


Theorem isdecinclcomp { X Y Z : UU } ( f : X -> Y ) ( g : Y -> Z ) ( isf : isdecincl f ) ( isg : isdecincl g ) : isdecincl ( fun x : X => g ( f x ) ) .
Proof. intros. intro z .  set ( gf := fun x : X => g ( f x ) ) . assert ( wy : forall ye : hfiber g z , weq ( hfiber f ( pr1 ye ) ) ( hfiber ( hfibersgftog f g z ) ye ) ) . apply  ezweqhf .  
assert ( ww : forall y : Y , weq ( hfiber f y ) ( hfiber gf ( g y ) ) ) . intro .  apply ( samehfibers f g ) . apply ( isdecincltoisincl _ isg ) .  
  induction ( pr1 ( isg z ) ) as [ ye | nye ] . induction ye as [ y e ] .  induction e . apply ( isdecpropweqf ( ww y ) ( isf y ) ) .   assert ( wz : weq ( hfiber gf z ) ( hfiber g z ) ) . split with ( hfibersgftog f g z ) . intro ye .   induction ( nye ye ) .  apply ( isdecpropweqb wz ( isg z ) ) .  Defined .

(** The conditions of the following theorem can be weakened by assuming only that the h-fibers of g satisfy [ isdeceq ] i.e. are "sets with decidable equality". *)

Theorem isdecinclf { X Y Z : UU } ( f : X -> Y ) ( g : Y -> Z ) ( isg : isincl g ) ( isgf : isdecincl ( fun x : X => g ( f x ) ) ) : isdecincl f .
Proof. intros . intro y . set ( gf := fun x : _ => g ( f x ) )  .  assert ( ww :  weq ( hfiber f y ) ( hfiber gf ( g y ) ) ) . apply ( samehfibers f g ) . assumption . apply ( isdecpropweqb ww ( isgf ( g y ) ) ) . Defined . 

(** *)


Theorem isdecinclg { X Y Z : UU } ( f : X -> Y ) ( g : Y -> Z ) ( isf : isweq f ) ( isgf : isdecincl ( fun x : X => g ( f x ) ) ) : isdecincl g .
Proof. intros . intro z . set ( gf := fun x : X => g ( f x ) ) . assert ( w : weq ( hfiber gf z ) ( hfiber g z ) ) . split with ( hfibersgftog f g z ) .  intro ye .  assert ( ww : weq ( hfiber f ( pr1 ye ) ) ( hfiber ( hfibersgftog f g z ) ye ) ) . apply  ezweqhf . apply ( iscontrweqf ww ( isf ( pr1 ye ) ) ) .    apply ( isdecpropweqf w ( isgf z ) ) . Defined . 



(** *** Decibadle inclusions and isolated points *)

Theorem isisolateddecinclf { X Y : UU } ( f : X -> Y ) ( x : X ) : isdecincl f -> isisolated X x -> isisolated Y ( f x ) .
Proof .  intros X Y f x isf isx .   assert ( is' : forall y : Y , isdecincl ( d1g  f y x ) ) . intro y .  intro xe .  set ( w := ezweq2g f x xe ) . apply ( isdecpropweqf w ( isdecproppathstoisolated X x isx _ ) ) .  assert ( is'' : forall y : Y , isdecprop ( paths ( f x ) y ) ) . intro .  apply ( isdecpropfromdecincl _ ( is' y ) ( isf y ) ) . intro y' .   apply ( pr1 ( is'' y' ) ) .  Defined . 



(** *** Decidable inclusions and coprojections *)


Definition negimage { X Y : UU } ( f : X -> Y ) := total2 ( fun y : Y => neg ( hfiber f y ) ) .
Definition negimagepair { X Y : UU } ( f : X -> Y ) := tpair ( fun y : Y => neg ( hfiber f y ) ) .

Lemma isinclfromcoprodwithnegimage { X Y : UU } ( f : X -> Y ) ( is : isincl f ) : isincl ( sumofmaps f ( @pr1 _ ( fun y : Y => neg ( hfiber f y ) ) ) ) . 
Proof .  intros . assert ( noi : forall ( x : X ) ( nx : negimage f ) , neg ( paths ( f x ) ( pr1 nx ) ) ) .  intros x nx e .  induction nx as [ y nhf ] .  simpl in e .  apply ( nhf ( hfiberpair _ x e ) ) . assert ( is' : isincl ( @pr1 _ ( fun y : Y => neg ( hfiber f y ) ) ) ) .  apply isinclpr1 .   intro y .  apply isapropneg .  apply ( isofhlevelfsumofmapsnoi 1 f _ is is' noi ) .   Defined . 


Definition iscoproj { X Y : UU } ( f : X -> Y ) := isweq ( sumofmaps f ( @pr1 _ ( fun y : Y => neg ( hfiber f y ) ) ) ) . 

Definition weqcoproj { X Y : UU } ( f : X -> Y ) ( is : iscoproj f ) : weq ( coprod X ( negimage f ) ) Y := weqpair _ is . 

Theorem iscoprojfromisdecincl { X Y : UU } ( f : X -> Y ) ( is : isdecincl f ) : iscoproj f .
Proof. intros . set ( p := sumofmaps f ( @pr1 _ ( fun y : Y => neg ( hfiber f y ) ) ) ) .  assert ( is' : isincl p ) .  apply isinclfromcoprodwithnegimage .   apply ( isdecincltoisincl _ is ) . unfold iscoproj .   intro y . induction ( pr1 ( is y ) ) as [ h | nh ] .   induction h as [ x e ] .  induction e .  change ( f x ) with ( p ( ii1 x ) ) . apply iscontrhfiberofincl .  assumption .  change y with ( p ( ii2 ( negimagepair _ y nh ) ) ) .  apply iscontrhfiberofincl .  assumption .  Defined . 

Theorem isdecinclfromiscoproj { X Y : UU } ( f : X -> Y ) ( is : iscoproj f ) : isdecincl f .
Proof . intros . set ( g := ( sumofmaps f ( @pr1 _ ( fun y : Y => neg ( hfiber f y ) ) ) ) ) . set ( f' :=  fun x : X => g ( ii1 x ) ) . assert ( is' : isdecincl f' ) . apply ( isdecinclcomp _ _ ( isdecinclii1 _ _ ) ( isdecinclfromisweq _ is ) ) .    assumption .  Defined . 

















(** ** Results using full form of the functional extentionality axioms. 

Summary: We consider two axioms which address functional extensionality. The first one is etacorrection  which compensates for the absense of eta-reduction in Coq8.3 Eta-reduction is expected to be included as a  basic property of the language in Coq8.4 which will make this axiom and related lemmas unnecessary. The second axiom [ funcontr ] is the functional extensionality for dependent functions formulated as the condition that the space of section of a family with contractible fibers is contractible.

Note : some of the results above this point in code use a very limitted form of functional extensionality . See [ funextempty ] .  

*)


(** *** Axioms and their basic corollaries *)

(** etacorrection *)

Definition etacorrection: forall T:UU, forall P:T -> UU, forall f: (forall t:T, P t), paths f (fun t:T => f t). 
Proof. reflexivity. Defined.

Lemma isweqetacorrection { T : UU } (P:T -> UU): isweq (fun f: forall t:T, P t => (fun t:T => f t)).
Proof. intros.  apply (isweqhomot  (fun f: forall t:T, P t => f) (fun f: forall t:T, P t => (fun t:T => f t)) (fun f: forall t:T, P t => etacorrection _ P f) (idisweq _)). Defined. 

Definition weqeta { T : UU } (P:T -> UU) := weqpair _ ( isweqetacorrection P ) .

Lemma etacorrectiononpaths { T : UU } (P:T->UU)(s1 s2 :forall t:T, P t) : paths (fun t:T => s1 t) (fun t:T => s2 t)-> paths s1 s2. 
Proof. intros T P s1 s2 X. set (ew := weqeta P). apply (invmaponpathsweq ew s1 s2 X). Defined. 

Definition etacor { X Y : UU } (f:X -> Y) : paths f (fun x:X => f x) := etacorrection _ (fun T:X => Y) f.

Lemma etacoronpaths { X Y : UU } (f1 f2 : X->Y) : paths (fun x:X => f1 x) (fun x:X => f2 x) -> paths f1 f2. 
Proof. intros X Y f1 f2 X0. set (ec:= weqeta (fun x:X => Y) ). apply (invmaponpathsweq  ec f1 f2 X0). Defined.


(** Dependent functions and sections up to homotopy I *)


Definition toforallpaths { T : UU }  (P:T -> UU) (f g :forall t:T, P t) : (paths f g) -> (forall t:T, paths (f t) (g t)).
Proof. intros T P f g X t. induction X. apply (idpath (f t)). Defined. 


Definition sectohfiber { X : UU } (P:X -> UU): (forall x:X, P x) -> (hfiber (fun f:_ => fun x:_ => pr1  (f x)) (fun x:X => x)) := (fun a : forall x:X, P x => tpair _ (fun x:_ => tpair _ x (a x)) (idpath (fun x:X => x))).

Definition hfibertosec  { X : UU } (P:X -> UU):  (hfiber (fun f:_ => fun x:_ => pr1  (f x)) (fun x:X => x)) -> (forall x:X, P x):= fun se:_  => fun x:X => match se as se' return P x with tpair _ s e => (transportf P (toforallpaths (fun x:X => X)  (fun x:X => pr1 (s x)) (fun x:X => x) e x) (pr2  (s x))) end.

Definition sectohfibertosec { X : UU } (P:X -> UU): forall a: forall x:X, P x, paths (hfibertosec _  (sectohfiber _ a)) a := fun a:_ => (pathsinv0 (etacorrection _ _ a)).


(* End of the file uu0c.v *)


