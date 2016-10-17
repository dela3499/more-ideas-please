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
import Types exposing (..)


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


labelWithCount: String -> Int -> String
labelWithCount string number = 
  string ++ " (" ++ (toString number) ++ ")"    


isJust: Maybe a -> Bool
isJust x = 
  case x of
    Just _ -> True
    Nothing -> False


getJusts: List (Maybe a) -> List a
getJusts maybes = 
  let prependJust maybe justs = 
        case maybe of
          Just x -> x::justs
          Nothing -> justs
  in
    List.foldl prependJust [] maybes


emptyList: List'
emptyList = 
  { name = ""
  , items = []
  , created = 0.0
  , id = ""
  }


dropNth list n = 
  let keep i x = 
        if i == n then
          []
        else 
          [x]
  in 
    list
      |> List.indexedMap keep
      |> List.concat


--getNewList time =
  