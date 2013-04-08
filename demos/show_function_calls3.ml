(*s: show_function_calls3.ml *)
(*s: basic pfff modules open *)
open Common
open Ast_php
(*e: basic pfff modules open *)
module V = Visitor_php

(*s: show_function_calls v3 *)
let show_function_calls file = 
  let (asts2, _stat) = Parse_php.parse file in
  let asts = Parse_php.program_of_program2 asts2 in

  (*s: initialize hfuncs *)
    let hfuncs = Common2.hash_with_default (fun () ->
      Common2.hash_with_default (fun () -> 0)
    )
    in
  (*e: initialize hfuncs *)

  (*s: iter on asts using visitor, updating hfuncs *)
    let visitor = V.mk_visitor  { V.default_visitor with
       V.klvalue = (fun (k, _) var ->
        match var with
        | FunCallSimple (funcname, args) ->

            (*s: print funcname and nbargs *)
            let f = Ast_php.name funcname in
            let nbargs = List.length (Ast_php.unparen args) in
            pr2 (spf "Call to %s with %d arguments" f nbargs);
            (*e: print funcname and nbargs *)

            (*s: update hfuncs for name with nbargs *)
            (* hfuncs[f][nbargs]++ *)
            hfuncs#update f (fun hcount -> 
              hcount#update nbargs (fun x -> x + 1);
              hcount
            )
            (*e: update hfuncs for name with nbargs *)
            
        | _ -> 
            k var
      );
    }
    in
    visitor (Program asts);
  (*e: iter on asts using visitor, updating hfuncs *)

  (*s: display hfuncs to user *)
    (* printing statistics *)
    hfuncs#to_list +> List.iter (fun (f, hcount) ->
      pr2 (spf "statistics for %s" f);
      hcount#to_list +> Common.sort_by_key_highfirst
        +> List.iter (fun (nbargs, nbcalls_at_nbargs) ->
          pr2 (spf " when # of args is %d: found %d call sites" 
                  nbargs nbcalls_at_nbargs)
        )
    )
  (*e: display hfuncs to user *)
(*e: show_function_calls v3 *)

let main = 
  show_function_calls Sys.argv.(1)

(*e: show_function_calls3.ml *)
