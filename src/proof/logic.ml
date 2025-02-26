(* This file is free software, part of Archsat. See file "LICENSE" for more details. *)

let section = Section.make ~parent:Proof.section "logic"

let tag ?dk ?coq ?lp id =
  CCOpt.iter (fun s -> Expr.Id.tag id Dedukti.Print.name @@ Pretty.Exact s) dk;
  CCOpt.iter (fun s -> Expr.Id.tag id Lambdapi.Print.name @@ Pretty.Exact s) lp;
  CCOpt.iter (fun s -> Expr.Id.tag id Coq.Print.name @@ Pretty.Exact s) coq;
  ()

(* Logic preludes *)
(* ************************************************************************ *)

let classical_id = Expr.Id.mk_new "classical" ()
let classical = Proof.Prelude.require classical_id

let () = tag classical_id ~dk:"classical" ~coq:"Coq.Logic.Classical" ~lp:"classical"

(* Useful constants *)
(* ************************************************************************ *)

let true_proof_id =
  Term.declare "I" Term.true_term

let true_proof =
  Term.id true_proof_id

let exfalso_id =
  let p = Term.var "P" Term._Prop in
  Term.declare "exfalso" (Term.forall p (
      Term.arrow Term.false_term (Term.id p)))

let nnpp_id =
  let p = Term.var "P" Term._Prop in
  let p_t = Term.id p in
  let nnp = Term.app Term.not_term (Term.app Term.not_term p_t) in
  Term.declare "NNPP" (Term.forall p (Term.arrow nnp p_t))

let and_intro_id =
  let a = Term.var "A" Term._Prop in
  let b = Term.var "B" Term._Prop in
  let () = Term.coq_implicit a in
  let () = Term.coq_implicit b in
  let a_t = Term.id a in
  let b_t = Term.id b in
  let a_and_b = Term.(apply and_term [a_t; b_t]) in
  Term.declare "conj"
    (Term.foralls [a; b] (Term.arrows [a_t; b_t] a_and_b))

let and_ind =
  let a = Term.var "A" Term._Prop in
  let b = Term.var "B" Term._Prop in
  let p = Term.var "P" Term._Prop in
  let () = Term.coq_implicit a in
  let () = Term.coq_implicit b in
  let () = Term.coq_implicit p in
  let a_t = Term.id a in
  let b_t = Term.id b in
  let p_t = Term.id p in
  let a_and_b = Term.(apply and_term [a_t; b_t]) in
  let a_to_b_to_p = Term.arrows [a_t; b_t] p_t in
  Term.declare "and_ind"
    (Term.foralls [a; b; p] (
        Term.arrows [a_to_b_to_p; a_and_b]
          p_t
      )
    )

let and_elim_id, and_elim_alias =
  let a = Term.var "A" Term._Prop in
  let b = Term.var "B" Term._Prop in
  let p = Term.var "P" Term._Prop in
  let a_t = Term.id a in
  let b_t = Term.id b in
  let p_t = Term.id p in
  let a_and_b = Term.(apply and_term [a_t; b_t]) in
  let a_to_b_to_p = Term.arrows [a_t; b_t] p_t in
  let o = Term.var "o" a_and_b in
  let f = Term.var "f" a_to_b_to_p in
  let t =
    Term.lambdas [a; b; p; o; f] (
      Term.(apply (id and_ind) [a_t; b_t; p_t; id f; id o])
    ) in
  let id = Term.define "and_elim" t in
  id, Proof.Prelude.alias id (function
      | Proof.Coq -> Some t | Proof.Dot | Proof.Dedukti | Proof.Lambdapi -> None)

let or_introl_id =
  let a = Term.var "A" Term._Prop in
  let b = Term.var "B" Term._Prop in
  let () = Term.coq_implicit a in
  let () = Term.coq_implicit b in
  let a_t = Term.id a in
  let b_t = Term.id b in
  let a_or_b = Term.apply Term.or_term [a_t; b_t] in
  Term.declare "or_introl"
    (Term.foralls [a; b] (Term.arrow a_t a_or_b))

let or_intror_id =
  let a = Term.var "A" Term._Prop in
  let b = Term.var "B" Term._Prop in
  let () = Term.coq_implicit a in
  let () = Term.coq_implicit b in
  let a_t = Term.id a in
  let b_t = Term.id b in
  let a_or_b = Term.apply Term.or_term [a_t; b_t] in
  Term.declare "or_intror"
    (Term.foralls [a; b] (Term.arrow b_t a_or_b))

let or_ind =
  let a = Term.var "A" Term._Prop in
  let b = Term.var "B" Term._Prop in
  let p = Term.var "P" Term._Prop in
  let () = Term.coq_implicit a in
  let () = Term.coq_implicit b in
  let () = Term.coq_implicit p in
  let a_t = Term.id a in
  let b_t = Term.id b in
  let p_t = Term.id p in
  let a_or_b = Term.(apply or_term [a_t; b_t]) in
  let a_to_p = Term.arrows [a_t] p_t in
  let b_to_p = Term.arrows [b_t] p_t in
  Term.declare "or_ind"
    (Term.foralls [a; b; p] (
        Term.arrows [a_to_p; b_to_p; a_or_b]
          p_t
      )
    )

let or_elim_id, or_elim_alias =
  let a = Term.var "A" Term._Prop in
  let b = Term.var "B" Term._Prop in
  let p = Term.var "P" Term._Prop in
  let a_t = Term.id a in
  let b_t = Term.id b in
  let p_t = Term.id p in
  let a_or_b = Term.(apply or_term [a_t; b_t]) in
  let a_to_p = Term.arrow a_t p_t in
  let b_to_p = Term.arrow b_t p_t in
  let o = Term.var "o" a_or_b in
  let f = Term.var "f" a_to_p in
  let g = Term.var "g" b_to_p in
  let t =
    Term.lambdas [a; b; p; o; f; g] (
      Term.(apply (id or_ind) [a_t; b_t; p_t; id f; id g; id o])
    ) in
  let id = Term.define "or_elim" t in
  id, Proof.Prelude.alias id (function
      | Proof.Coq -> Some t | Proof.Dot | Proof.Dedukti | Proof.Lambdapi -> None)

let equiv_refl_id =
  let p = Term.var "P" Term._Prop in
  let p_t = Term.id p in
  Term.declare "equiv_refl" @@
  Term.forall p @@
  Term.apply Term.equiv_term [p_t; p_t]

let equiv_not_id =
  let p = Term.var "P" Term._Prop in
  let q = Term.var "Q" Term._Prop in
  let () = Term.coq_implicit q in
  let () = Term.coq_implicit p in
  let p_t = Term.id p in
  let q_t = Term.id q in
  Term.declare "equiv_not" @@
  Term.foralls [p; q] @@
  Term.arrow
    (Term.apply Term.equiv_term [p_t; q_t])
    (Term.apply Term.equiv_term [
        Term.app Term.not_term p_t;
        Term.app Term.not_term q_t;
      ])

let equiv_trans_id =
  let p = Term.var "P" Term._Prop in
  let q = Term.var "Q" Term._Prop in
  let r = Term.var "R" Term._Prop in
  let p_t = Term.id p in
  let q_t = Term.id q in
  let r_t = Term.id r in
  Term.declare "equiv_trans" @@
  Term.foralls [p; q; r] @@
  Term.arrows [
    Term.apply Term.equiv_term [p_t; q_t];
    Term.apply Term.equiv_term [q_t; r_t];
  ] (Term.apply Term.equiv_term [p_t; r_t])

let nnpp_term = Term.id nnpp_id
let exfalso_term = Term.id exfalso_id
let or_elim_term = Term.id or_elim_id
let and_elim_term = Term.id and_elim_id
let or_introl_term = Term.id or_introl_id
let or_intror_term = Term.id or_intror_id
let and_intro_term = Term.id and_intro_id
let equiv_not_term = Term.id equiv_not_id
let equiv_refl_term = Term.id equiv_refl_id
let equiv_trans_term = Term.id equiv_trans_id

let () =
  tag true_proof_id   ~dk:"logic.true_intro"    ~coq:"I"                ~lp:"true_intro";
  tag exfalso_id      ~dk:"logic.false_elim"    ~coq:"False_ind"        ~lp:"false_elim";
  tag nnpp_id         ~dk:"classical.nnpp"      ~coq:"NNPP"             ~lp:"nnpp";
  tag and_intro_id    ~dk:"logic.and_intro"     ~coq:"conj"             ~lp:"and_intro";
  tag and_ind         ~dk:"logic.and_ind"       ~coq:"and_ind"          ~lp:"and_ind";
  tag and_elim_id     ~dk:"logic.and_elim"      ?coq:None               ~lp:"and_elim";
  tag or_introl_id    ~dk:"logic.or_introl"     ~coq:"or_introl"        ~lp:"or_introl";
  tag or_intror_id    ~dk:"logic.or_intror"     ~coq:"or_intror"        ~lp:"or_intror";
  tag or_ind          ~dk:"logic.or_ind"        ~coq:"or_ind"           ~lp:"or_ind";
  tag or_elim_id      ~dk:"logic.or_elim"       ?coq:None               ~lp:"or_elim";
  tag equiv_not_id    ~dk:"logic.equiv_not"     ~coq:"not_iff_compat"   ~lp:"equiv_not";
  tag equiv_refl_id   ~dk:"logic.equiv_refl"    ~coq:"iff_refl"         ~lp:"equiv_refl";
  tag equiv_trans_id  ~dk:"logic.equiv_trans"   ~coq:"@iff_trans"       ~lp:"equiv_trans";
  ()


(* Some generic tactic manipulations *)
(* ************************************************************************ *)

let extract_open pos =
  match Proof.extract @@ Proof.get pos with
  | Proof.Open sequent -> sequent
  | Proof.Proof _ -> assert false

let ctx f pos =
  let seq = extract_open pos in
  f seq pos

let find t f pos =
  let seq = extract_open pos in
  let env = Proof.env seq in
  let t' = Proof.Env.find env t in
  f t' pos

(* Ensure a bool-returning tactic succeeeds *)
let ensure tactic pos =
  let b = tactic pos in
  if not b then
    raise (Proof.Failure ("Tactic didn't close the proof as expected", pos))

(** Iterate a tactic n times *)
let rec iter tactic n pos =
  if n <= 0 then pos
  else iter tactic (n - 1) (tactic pos)

let rec fold tactic l pos =
  match l with
  | [] -> pos
  | x :: r -> fold tactic r (tactic x pos)

(* Standard tactics *)
(* ************************************************************************ *)

(** Introduce the head term, and return
    the new position to continue the proof. *)
let intro ?(post=(fun _ x -> x)) prefix pos =
  match Proof.apply_step pos Proof.intro prefix with
  | v, [| res |] -> post v.Expr.id_type res
  | _ -> assert false

let introN ?post prefix n = iter (intro ?post prefix) n

let name prefix pos =
  match Proof.apply_step pos Proof.intro prefix with
  | id, [| res |] -> id, res
  | _ -> assert false

(** Letin *)
let letin preludes prefix t pos =
  match Proof.apply_step pos Proof.letin (preludes, prefix, t) with
  | _, [| res |] -> res
  | _ -> assert false

(** Cut *)
let cut ~f s t pos =
  match Proof.apply_step pos Proof.cut (s, t) with
  | id, [| aux ; main |] ->
    let () = f aux in
    id, main
  | _ -> assert false

(** Fixed arity applications *)
let applyN t n preludes pos =
  snd @@ Proof.apply_step pos Proof.apply (t, n, preludes)

let exact preludes t pos =
  match applyN t 0 preludes pos with
  | [| |] -> ()
  | _ -> assert false

let apply1 preludes t pos =
  match applyN t 1 preludes pos with
  | [| res |] -> res
  | _ -> assert false

let apply2 preludes t pos =
  match applyN t 2 preludes pos with
  | [| res1; res2 |] -> res1, res2
  | _ -> assert false

let apply3 preludes t pos =
  match applyN t 3 preludes pos with
  | [| res1; res2; res3 |] -> res1, res2, res3
  | _ -> assert false

let apply preludes t pos =
  let l, _ = Proof.match_arrows @@ Term.ty t in
  applyN t (List.length l) preludes pos

(* Splits for easy interaction with pipe operators *)
let split ~left ~right (p1, p2) =
  let () = left p1 in
  let () = right p2 in
  ()

let split3 ~first ~second ~third (p1, p2, p3) =
  let () = first p1 in
  let () = second p2 in
  let () = third p3 in
  ()

(** Apply exfalso if needed in order to get a goal of the form
    Gamma |- False *)
let exfalso pos =
  let ctx = extract_open pos in
  let g = Proof.goal ctx in
  try
    let _ = Term.pmatch ~pat:(Term.false_term) g in
    pos
  with Term.Match_Impossible _ ->
    apply1 [] (Term.app exfalso_term g) pos

(** Triviality: the goal is already present in the env *)
let trivial pos =
  let ctx = extract_open pos in
  let env = Proof.env ctx in
  let g = Proof.goal ctx in
  match Proof.Env.find env g with
  | t ->
    let () = exact [] t pos in
    true
  | exception Proof.Env.Not_introduced _ ->
    Util.debug ~section
      "@[<hv>Absurd tactic failed because it couldn't find (%d)@ @[<hov>%a@]@ in env:@ %a@]"
      (Term.Reduced.hash g) Term.print g Proof.Env.print env;
    false

(** Find a contradiction in an environment using the given proposition. *)
let find_absurd pos env atom =
  (** Using [true/false] with absurd is a little bit complicated because
      [~true] and [false] aren't convertible... so just check whether false
      is present. *)
  match Proof.Env.find env Term.false_term with
  | res -> res
  | exception Proof.Env.Not_introduced _ ->
    begin match Proof.Env.find env atom with
      | p ->
        let neg_atom = Term.app Term.not_term atom in
        (* First, try and see wether [neg atom] is in the env *)
        begin match Proof.Env.find env neg_atom with
          | np -> (Term.app np p)
          | exception Proof.Env.Not_introduced _ ->
            Util.debug ~section "@[<hv>Couldn't find in env (%d):@ %a@]"
              (Term.Reduced.hash neg_atom) Term.print neg_atom;
            (* Try and see if [atom = neg q] with q in the context. *)
            begin try
                let q_v = Term.var "q" Term._Prop in
                let pat = Term.app Term.not_term (Term.id q_v) in
                let s = Term.pmatch ~pat atom in
                let q = Proof.Env.find env (Term.S.Id.get q_v s) in
                (Term.app p q)
              with
              | Not_found ->
                Util.warn ~section "Internal error in pattern matching";
                assert false
              | Term.Match_Impossible _
              | Proof.Env.Not_introduced _ ->
                Util.warn ~section
                  "@[<hv>Couldn't find an absurd situation using@ @[<hov>%a@]@ in env:@ %a@]"
                  Term.print p Proof.Env.print env;
                raise (Proof.Failure ("Logic.absurd", pos))
            end
        end
      | exception Proof.Env.Not_introduced _ ->
        Util.warn ~section
          "@[<hv>Absurd tactic failed because it couldn't find@ @[<hov>%a@]@ in env:@ %a@]"
          Term.print atom Proof.Env.print env;
        raise (Proof.Failure ("Logic.absurd", pos))
    end

(** Given a goal of the form Gamma |- False,
    and a term, find its negation in the env, and close the branch *)
let absurd atom pos =
  let ctx = extract_open pos in
  let env = Proof.env ctx in
  pos |> exfalso |> (fun pos -> exact [] (find_absurd pos env atom) pos)

(* Logical connectives patterns *)
(* ************************************************************************ *)

let or_left = Term.var "a" Term._Prop
let or_right = Term.var "b" Term._Prop
let or_pat = Term.(apply or_term [id or_left; id or_right])

let match_or t =
  try
    let s = Term.pmatch ~pat:or_pat t in
    let left_term = Term.S.Id.get or_left s in
    let right_term = Term.S.Id.get or_right s in
    Some (left_term, right_term)
  with
  | Term.Match_Impossible _ -> None
  | Not_found ->
    Util.error ~section "Absent binding after pattern matching";
    assert false

let and_left = Term.var "a" Term._Prop
let and_right = Term.var "b" Term._Prop
let and_pat = Term.(apply and_term [id and_left; id and_right])

let match_and t =
  try
    let s = Term.pmatch ~pat:and_pat t in
    let left_term = Term.S.Id.get and_left s in
    let right_term = Term.S.Id.get and_right s in
    Some (left_term, right_term)
  with
  | Term.Match_Impossible _ -> None
  | Not_found ->
    Util.error ~section "Absent binding after pattern matching";
    assert false

let not_var = Term.var "p" Term._Prop
let not_pat = Term.(apply not_term [id not_var])

let match_not t =
  try
    let s = Term.pmatch ~pat:not_pat t in
    let p = Term.S.Id.get not_var s in
    Some p
  with
  | Term.Match_Impossible _ -> None
  | Not_found ->
    Util.error ~section "Absent binding after pattern matching";
    assert false

let equiv_left = Term.var "p" Term._Prop
let equiv_right = Term.var "q" Term._Prop
let equiv_pat = Term.apply Term.equiv_term
    [Term.id equiv_left; Term.id equiv_right]

let match_equiv t =
  try
    let s = Term.pmatch ~pat:equiv_pat t in
    let left_term = Term.S.Id.get equiv_left s in
    let right_term = Term.S.Id.get equiv_right s in
    Some (left_term, right_term)
  with
  | Term.Match_Impossible _ -> None
  | Not_found ->
    Util.error ~section "Absent binding after pattern matching";
    assert false

let match_equiv_not t =
  match match_equiv t with
  | Some (a, b) ->
    begin match match_not a, match_not b with
      | Some c, Some d -> Some (c, d)
      | _ -> None
    end
  | None -> None

let match_not_not t = CCOpt.(match_not t >>= match_not)

let shortcut_not_not t =
  match match_not_not t with Some t' -> t' | None -> t

(* True/False congruence *)
(* ************************************************************************ *)

let coercion_f t =
  if not (Term.Reduced.equal Term._Prop (Term.ty t)) then []
  else begin
    if Term.Reduced.equal Term.true_term t then
      [ Proof.Env.Cst true_proof ]
    else if Term.Reduced.equal Term.false_term t then
      [ Proof.Env.( Wrapped {
            term = Term.app Term.not_term Term.true_term;
            wrap = (fun e -> Term.app e true_proof);
          } ) ]
    else
      match match_not t with
      | Some t' when Term.Reduced.equal Term.true_term t' ->
        [ Proof.Env.( Wrapped {
              term = Term.false_term;
              wrap = (fun e ->
                  let x = Term.var "x" Term.true_term in
                  Term.lambda x e);
            } ) ]
      | Some t' when Term.Reduced.equal Term.false_term t' ->
        [ Proof.Env.Cst (
              let x = Term.var "x" Term.false_term in
              Term.lambda x (Term.id x)
            ) ]
      | _ -> []
  end

let () = Proof.Env.register ("true/false", coercion_f)

(* Logical connective creation *)
(* ************************************************************************ *)

let rec and_intro ~f pos =
  let ctx = extract_open pos in
  let goal = Proof.goal ctx in
  match match_and goal with
  | None -> f goal pos
  | Some (left, right) ->
    let t' = Term.apply and_intro_term [left; right] in
    apply2 [] t' pos |> split ~left:(and_intro ~f) ~right:(and_intro ~f)

let rec find_or x t =
  if Term.Reduced.equal x t then Some []
  else match match_or t with
    | None -> None
    | Some (left, right) ->
      begin match find_or x left with
        | Some path -> Some ((`Left, left, right) :: path)
        | None ->
          begin match find_or x right with
            | Some path -> Some ((`Right, left, right) :: path)
            | None -> None
          end
      end

let rec or_intro_aux l pos =
  match l with
  | [] -> pos
  | (`Left, left, right) :: r ->
    let t = Term.apply or_introl_term [left; right] in
    pos |> apply1 [] t |> or_intro_aux r
  | (`Right, left, right) :: r ->
    let t = Term.apply or_intror_term [left; right] in
    pos |> apply1 [] t |> or_intro_aux r

let or_intro t pos =
  let ctx = extract_open pos in
  let goal = Proof.goal ctx in
  match find_or t goal with
  | Some path -> or_intro_aux path pos
  | None ->
    raise (Proof.Failure ("Couldn't find the given atom in disjunction", pos))

let equiv_refl t pos =
  let goal = Proof.goal @@ extract_open pos in
  match match_equiv goal with
  | None -> raise (Proof.Failure ("expected en equivalence as goal", pos))
  | Some (a, b) when Term.Reduced.equal a b ->
    exact [] (Term.app equiv_refl_term t) pos
  | Some _ ->
    and_intro pos
      ~f:(fun _ pos -> pos |> intro "E" |> ensure trivial)

let equiv_not pos =
  let goal = Proof.goal @@ extract_open pos in
  match match_equiv_not goal with
  | Some (p, q) -> apply1 [] (Term.apply equiv_not_term [p; q]) pos
  | None -> raise (Proof.Failure ("Expected a goal of the form equiv-not", pos))

let equiv_replace ~equiv ~by:q r pos =
  let ctx = extract_open pos in
  let goal = Proof.goal ctx in
  match match_equiv goal with
  | None ->
    Util.error ~section
      "@[<hov>Tried to apply tactic equiv_trans but the goal is not an equivalence:@ %a@]"
      Term.print goal;
    raise (Proof.Failure ("Expected an equivalence", pos))
  | Some (p, b) when Term.Reduced.equal r b ->
    let pos1, pos2 = apply2 [] (Term.apply equiv_trans_term [p; q; r]) pos in
    let () = equiv pos2 in
    pos1
  | Some (a, p) when Term.Reduced.equal r a ->
    let pos1, pos2 = apply2 [] (Term.apply equiv_trans_term [r; q; p]) pos in
    let () = equiv pos1 in
    pos2
  | Some (a, b) ->
    Util.error ~section "@[<v 2>equiv_replace:@ q: %a@ r: %a@ left: %a@ right: %a@ goal: %a@]"
      Term.print q Term.print r Term.print a Term.print b Term.print goal;
    raise (Proof.Failure ("Expected to find q on one side of the equivalence", pos))


(* Logical connective elimination *)
(* ************************************************************************ *)

let rec or_elim_aux ~shallow ~f t pos =
  let ctx = extract_open pos in
  let goal = Proof.goal ctx in
  match match_or @@ Term.ty t with
  | None ->
    let pos' =
      if shallow && not (Proof.Env.mem (Proof.env ctx) @@ Term.ty t)
      then letin [] "O" t pos
      else pos
    in
    Util.debug ~section "Couldn't split %a: %a" Term.print t Term.print (Term.ty t);
    f (Term.ty t) pos'
  | Some (left_term, right_term) ->
    let t' = Term.apply or_elim_term [left_term; right_term; goal; t] in
    apply2 [or_elim_alias] t' pos |> split
      ~left:(fun p -> p |> intro "O" |> find left_term (or_elim_aux ~shallow:false ~f))
      ~right:(fun p -> p |> intro "O" |> find right_term (or_elim_aux ~shallow:false ~f))

let or_elim = or_elim_aux ~shallow:true

let rec and_elim t pos =
  let ctx = extract_open pos in
  let goal = Proof.goal ctx in
  match match_and @@ Term.ty t with
  | None -> pos
  | Some (left_term, right_term) ->
    let t' = Term.apply and_elim_term [left_term; right_term; goal; t] in
    apply1 [and_elim_alias] t' pos
    |> introN "A" 2
    |> find left_term and_elim
    |> find right_term and_elim

(** Eliminate double negations when the goal is [False] *)
let not_not_simpl prefix t pos =
  let seq = extract_open pos in
  if not (Term.Reduced.equal Term.false_term (Proof.goal seq)) then
    raise (Proof.Failure ("Double negation elimination is only possible when the goal is [False]", pos));
  pos
  |> find t @@ apply1 []
  |> intro prefix

let not_not_elim prefix t pos =
  let t' = Term.app Term.not_term (Term.app Term.not_term t) in
  not_not_simpl prefix t' pos

(** Eliminate double negation if necessary. *)
let normalize prefix t pos =
  let t = shortcut_not_not t in
  let seq = extract_open pos in
  try
    let _ = Proof.Env.find (Proof.env seq) t in
    pos
  with Proof.Env.Not_introduced _ ->
    not_not_elim prefix t pos

(* When the goal is [~ ~ t], reduce it to [t] *)
let not_not_intro ?(prefix="N") pos =
  let id, pos' = name prefix pos in
  apply1 [] (Term.id id) pos'

(* Resolution tactics *)
(* ************************************************************************ *)

let clause_type l =
  List.fold_right (fun lit acc ->
      Term.arrow (Term.app Term.not_term lit) acc
    ) l Term.false_term

let resolve_clause_aux c1 c2 res pos =
  let n = List.length res in
  pos
  |> iter (intro "l") n
  |> apply [] (Term.id c1)
  |> Array.iter (fun p ->
      if not (trivial p) then begin
        p
        |> intro "r"
        |> apply [] (Term.id c2)
        |> Array.iter (fun p' ->
            if not (trivial p') then begin
              let a = Proof.goal (extract_open p') in
              p' |> intro "r" |> absurd (shortcut_not_not a)
            end
          )
      end
    )

let resolve_clause c1 c2 res =
  let e = Proof.Env.empty in
  let e = Proof.Env.add e c1 in
  let e = Proof.Env.add e c2 in
  let goal = clause_type res in
  let p = Proof.mk (Proof.mk_sequent e goal) in
  let () =
    try resolve_clause_aux c1 c2 res (Proof.pos @@ Proof.root p)
    with exn ->
      let f = Filename.temp_file "archsat_dot" ".gv"
          ~temp_dir:(Sys.getcwd ()) in
      let ch = open_out f in
      let fmt = Format.formatter_of_out_channel ch in
      Dot.proof_context (Proof.print ~lang:Proof.Dot) fmt p;
      close_out ch;
      raise exn
  in
  Proof.elaborate p

let resolve_step =
  let compute seq (c, c', res) =
    let t = resolve_clause c c' res in
    let id, e = Proof.Env.intro ~hide:true (Proof.env seq) "R" @@ Term.ty t in
    (c, c', id, t), [| Proof.mk_sequent e (Proof.goal seq) |]
  in
  let elaborate (_, _, id, t) = function
    | [| body |] -> Term.letin id t body
    | _ -> assert false
  in
  let coq = Proof.Last_but_not_least, (fun fmt (l, r, id, t) ->
      Format.fprintf fmt
        "(* Resolution %a/%a -> %a *)@\n@[<hv 2>pose proof (@,%a@;<0 -2>) as %a.@]"
        Coq.Print.id l Coq.Print.id r Coq.Print.id id
        Coq.Print.term t Coq.Print.id id
    ) in
  let dot = Proof.Branching, (fun fmt (c, c', id, _) ->
      Format.fprintf fmt "%a = %a:%a"
        Dot.Print.Proof.id id
        Dot.Print.Proof.id c
        Dot.Print.Proof.id c'
    ) in
  Proof.mk_step ~coq ~dot ~compute ~elaborate "resolve"

let resolve c c' res pos =
  match Proof.apply_step pos resolve_step (c, c', res) with
  | (_, _, id, _), [| pos' |] -> id, pos'
  | _ -> assert false

let remove_duplicate_clause c res =
  let e = Proof.Env.empty in
  let e = Proof.Env.add e c in
  let goal = clause_type res in
  let p = Proof.mk (Proof.mk_sequent e goal) in
  let () = resolve_clause_aux c c res (Proof.pos @@ Proof.root p) in
  Proof.elaborate p

let duplicate_step =
  let compute seq (c, res) =
    let t = remove_duplicate_clause c res in
    let id, e = Proof.Env.intro ~hide:true (Proof.env seq) "R" @@ Term.ty t in
    (c, id, t), [| Proof.mk_sequent e (Proof.goal seq) |]
  in
  let elaborate (_, id, t) = function
    | [| body |] -> Term.letin id t body
    | _ -> assert false
  in
  let coq = Proof.Last_but_not_least, (fun fmt (c, id, t) ->
      Format.fprintf fmt
        "(* Duplicate elimination %a -> %a *)@\n@[<hv 2>pose proof (@,%a@;<0 -2>) as %a.@]"
        Coq.Print.id c Coq.Print.id id
        Coq.Print.term t Coq.Print.id id
    ) in
  let dot = Proof.Branching, (fun fmt (c, id, _) ->
      Format.fprintf fmt "%a = %a::"
        Dot.Print.Proof.id id
        Dot.Print.Proof.id c
    ) in
  Proof.mk_step ~coq ~dot ~compute ~elaborate "duplicate"

let remove_duplicates c res pos =
  match Proof.apply_step pos duplicate_step (c, res) with
  | (_, id, _), [| pos' |] -> id, pos'
  | _ -> assert false

(* Classical tactics *)
(* ************************************************************************ *)

(** Apply NNPP if needed, in order to turn any sequent
    Gamma |- F, into a sequent of the form Gamma' |- False. *)
let nnpp ?(handle=(fun _ -> ())) pos =
  let ctx = extract_open pos in
  let goal = Proof.goal ctx in
  try
    (* If the goal is [ False], nothing to do *)
    let _ = Term.pmatch ~pat:Term.false_term goal in
    pos
  with Term.Match_Impossible _ ->
    let id, res =
      try
        (* If the goal is a negation, directly use an intro,
           to stay intuitionistic as much as possible *)
        let p = Term.var "p" Term._Prop in
        let pat = Term.app Term.not_term @@ Term.id p in
        let _ = Term.pmatch ~pat goal in
        pos |> name "G"
      with Term.Match_Impossible _ ->
        (* Else, apply NNPP, then intro to get the negation of the original goal
           as an hypothesis in the context *)
        pos
        |> apply1 [classical] (Term.app nnpp_term goal)
        |> name "G"
    in
    handle id;
    res


