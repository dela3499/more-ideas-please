module App exposing (..)

import Html exposing (Html, text, div, span, a, img, p)
import Html.App as Html
import Html.Events exposing (onClick)
import Html.Attributes exposing (..)
import Maybe exposing (withDefault)
import Set exposing (Set)
import Dict exposing (Dict)
import String

import Types exposing (..)
import Util 


main = 
  Html.program
    { init = ( initModel, Cmd.none )
    , update = update
    , view = view
    , subscriptions = subscriptions
    }


subscriptions: Model -> Sub Msg
subscriptions model = 
  Sub.none


initModel: Model
initModel = 
  { lists = 
      Dict.fromList
        [ ("Places", ["home", "work", "school", "pool"])
        , ("Hobbies", ["swimming", "playing guitar", "badminton"])
        , ("Foods", ["burgers", "bacon", "sandwiches", "pizza"])
        , ("Companies", ["Uber", "Google", "Facebook", "Apple"])
        ]
  , selected = 
      Set.fromList
        [ "Places", "Foods" ]
  , shuffle = False
  }


update: Msg -> Model -> (Model, Cmd Msg)
update msg model = 
  case msg of
    ToggleSelected listName -> 
      let selected' = 
            Util.toggleMember listName model.selected
      in
        ({ model | selected = selected' }, Cmd.none)
    ToggleShuffle -> 
       ({ model | shuffle = not model.shuffle }, Cmd.none)


view: Model -> Html Msg
view model =
  let getList name = 
        Dict.get name model.lists
          |> withDefault []
      lists = 
        model.selected
          |> Set.toList
          |> List.map getList
          |> List.filter (\x -> (List.length x) > 0)
      reorder = 
        if model.shuffle then
          Util.shuffle
        else
          identity
      combinations = 
        reorder (Util.combinations lists)
  in 
    div
      [ class "app" ]
      [ logo
      , intro
      , div 
          [ class "button-container" ]
          [ div
              [ class "lists-title" ]
              [ text "Lists" ]
          , div 
              [ class "list-names" ]
              (List.map (listName model.selected) (Dict.keys model.lists))
          , div 
              [ classList
                  [ ("shuffle", True)
                  , ("button", True)
                  , ("active", model.shuffle)
                  ]
              , onClick ToggleShuffle
              ]
              [ text "Shuffle" ]          
          ]
      , div 
          [ class "combinations-title" ]
          [ text "Combinations" ]
      , div
          [ class "combinations" ]
          (List.map combination combinations)
      ]


logo: Html Msg
logo = 
  div
    [ class "logo" ]
    (List.map 
      (\word -> div [class word] [text word]) 
      ["more", "ideas", "please"]
    )


intro: Html Msg
intro = 
  div
    [ class "intro" ]
    [ p [] [text p1]
    , p [] [text p2]
    , p [] [text p3]
    , img [ src "img/equation.svg" ] []
    , p [] [text p4]
    ]


p1 = "Want some business ideas? List two hobbies, two business models, and all their combinations. That's four potentially-useful ideas!"
p2 = "What if you list ten of each? That's a hundred ideas! Since it's tedious to write out all those combinations, we'll do that."
p3 = "Here's another quick example. We'll take a list of letters, like A and Z, and combine it with a list of numbers, like 1, 2, and 3. Here are all the combinations."
p4 = "Check out the example below. There are four lists you can mix and match. Feel free to edit them too (just click on the pencil icon)."


listName: Set String -> String -> Html Msg
listName selected name = 
  div
    [ classList
        [ ("list-name", True)
        , ("button", True)
        , ("selected", Set.member name selected)  
        ]
    , onClick (ToggleSelected name)
    ]
    [ text name ]  


combination items =
  div
    [ class "combination" ]  
    [ items
        |> String.join ", "
        |> text
    ]

