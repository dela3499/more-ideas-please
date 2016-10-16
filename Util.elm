module Util exposing (..)

import Html exposing (Html, text, div, span, a, img)
import Html.App as Html
import Html.Events exposing (onClick)
import Html.Attributes exposing (..)
import Maybe exposing (withDefault)
import Set exposing (Set)
import Dict exposing (Dict)
import Random.Array
import Random
import Array


toggleMember: String -> Set String -> Set String
toggleMember value set = 
  if Set.member value set then
    Set.remove value set
  else
    Set.insert value set


prependToAll: List (List a) -> a -> List (List a)
prependToAll xs y = 
  List.map (\x -> y::x) xs


combinations: List (List a) -> List (List a)
combinations lists = 
  let combine lists accum = 
        case lists of
          head::tail -> 
            combine tail (List.concatMap (prependToAll accum) head)
          [] -> 
            accum
  in 
    combine (List.reverse lists) [[]] 


shuffle x = 
  let generator = 
        Random.Array.shuffle (Array.fromList x)
      (x', seed) = 
        Random.step generator (Random.initialSeed 123)
  in 
    Array.toList x'       