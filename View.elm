module View exposing (..)

import Html exposing (Html, text, div, span, a, img, p, i, input)
import Html.App as Html
import Html.Events exposing (onClick, onInput, onBlur, onFocus)
import Html.Attributes exposing (..)
import Maybe exposing (withDefault)
import Set exposing (Set)
import Dict exposing (Dict)
import String

import Types exposing (..)
import Util

app: Model -> Html Msg
app model =
  div
    [ class "app" ]
    [ case model.mode of
        Viewing -> viewingBody model
        Editing -> editingBody model
    ]

    --[ logo
    --, intro
    --, case model.mode of
    --    Viewing -> viewingBody model
    --    Editing _ -> editingBody model
    --]


viewingBody: Model -> Html Msg
viewingBody model = 
  let lists = 
        model.selected
          |> Set.toList
          |> List.map (\listId -> Dict.get listId model.lists)
          |> Util.getJusts
          |> List.map .items
          |> List.filter (\x -> (List.length x) > 0)
      listNames = 
        model.lists 
          |> Dict.values
          |> List.map .name
      listLengths = 
        model.lists
         |> Dict.values
         |> List.map .items
         |> List.map List.length
      reorder = 
        if model.shuffle then
          Util.shuffle
        else
          identity
      combinations = 
        reorder (Util.combinations lists)
          |> List.filter (\list -> List.length list > 0)
  in 
    div
      [ class "body" ]
      [ div 
          [ class "button-container" ]
          [ div
              [ class "lists-title" ]
              [ text "Lists" ]
          , div 
              [ class "list-names" ]
              (List.map
                (listName model.selected) 
                (Dict.values model.lists)
              )
          , i 
              [ class "fa fa-pencil button edit"
              , onClick (SetMode Editing)
              ]
              []
          ]
      , div
          [ class "combinations-header" ]
          [ div 
              [ class "title" ]
              [ text (Util.labelWithCount "Combinations" (List.length combinations))]
          , div 
              [ classList
                  [ ("shuffle", True)
                  , ("button", True)
                  , ("active", model.shuffle)
                  ]
              , onClick ToggleShuffle
              ]
              [ text "shuffle" ]   
          ]         
      , div
          [ class "combinations" ]
          (List.map combination combinations)
      ]


editingBody: Model -> Html Msg
editingBody model = 
  div
    [ class "body editing" ]
    [ div 
        [ class "button-container" ]
        [ div
            [ class "lists-title" ]
            [ text "Edit lists" ]
        , div 
            [ class "list-names" ]
            (( model.lists
                |> Dict.values
                |> List.sortBy .created
                |> List.map listNameEditing
             ) ++ 
            [ i
                [ class "fa fa-plus new-list button"
                , onClick (Edit Util.emptyList)
                ]
                []
            ])
        , i
            [ class "fa fa-reply done button"
            , onClick (SetMode Viewing)
            ]
            []
        ]
    , div 
        [ class "input-container" ]
        [ div
            [ class "input-title"]
            [ text "List name" ]
        , input
            [ class "list-name"
            , id "list-name-input"
            , placeholder "(e.g. favorite bands, apps, friends)"
            , onInput SetListName
            , onFocus (RecordFocus ListName)
            , onBlur (RecordFocus NoFocus)
            ]
            []
        , div
            [ classList
                [ ("input-title", True)
                , ("hide", (List.length model.editList.items) < 1)
                ]
            ]
            [ text "Items" ]
        , div
            [ classList
                [ ("items-container", True)
                , ("hide", (List.length model.editList.items) < 1) 
                ]
            ]
            ( List.indexedMap item model.editList.items )
        , div 
            [ class "new-item field"]
            [ div
                [ class "input-title"]
                [ text "New item" ]            
            , input
                [ class "item"
                , id "list-item-input"
                , placeholder "(e.g. Rush, Twitter, Norm)"
                , onInput SetItem
                , onFocus (RecordFocus ListItem)
                , onBlur (RecordFocus NoFocus)                
                ]
                []
            , i
                [ class "fa fa-plus add-item button"
                , onClick AddItem
                ]
                []
            ]
        , div 
            [ class "save button" 
            , onClick Save
            ] 
            [ text "save list" ]
        , div 
            [ classList
                [ ("delete button", True)
                , ("hide", not (Dict.member model.editList.id model.lists)) -- only show if list exists in model.lists
                ] 
            , onClick Delete
            ] 
            [ text "delete list" ]
        ]
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
    , img [ src "assets/img/equation.svg" ] []
    , p [] [text p4]
    ]


p1 = "Want some business ideas? List two hobbies, two business models, and all their combinations. That's four potentially-useful ideas!"
p2 = "What if you list ten of each? That's a hundred ideas! Since it's tedious to write out all those combinations, we'll do that."
p3 = "Here's another quick example. We'll take a list of letters, like A and Z, and combine it with a list of numbers, like 1, 2, and 3. Here are all the combinations."
p4 = "Check out the example below. There are four lists you can mix and match. Feel free to edit them too (just click on the pencil icon)."


listName: Set ListId -> List' -> Html Msg
listName selected list = 
  div
    [ classList
        [ ("list-name", True)
        , ("button", True)
        , ("selected", Set.member list.id selected)  
        ]
    , onClick (ToggleSelected list.id)
    ]
    [ text (Util.labelWithCount list.name (List.length list.items)) ]  


listNameEditing: List' -> Html Msg
listNameEditing list = 
  div
    [ classList
        [ ("list-name", True)
        , ("button", True)
        ]
    , onClick (Edit list)
    ]
    [ text list.name ]      


combination items =
  div
    [ class "combination" ]  
    [ items
        |> String.join ", "
        |> text
    ]

item: Int -> String -> Html Msg
item i' item' = 
  div
    [ class "item" ]
    [ i
        [ class "fa fa-times remove-item button"
        , onClick (RemoveItem i')
        ]
        []
    , text item'
    ]