module App exposing (..)

import Html exposing (Html, text, div, span, a, img, p, i, input)
import Html.App as Html
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Attributes exposing (..)
import Maybe exposing (withDefault)
import Set exposing (Set)
import Dict exposing (Dict)
import String

import Types exposing (..)
import Util exposing (dummyList)


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
        [ ("1", 
            { id = "1"
            , name = "Places"
            , items = ["home", "work", "school", "pool"]
            }
          )
        , ("2", 
            { id = "2"
            , name = "Hobbies"
            , items = ["swimming", "playing guitar", "badminton"]
            }
          )
        , ("3", 
            { id = "3"
            , name = "Foods"
            , items = ["burgers", "bacon", "sandwiches", "pizza"]
            }
          )
        , ("4", 
            { id = "4"
            , name = "Companies"
            , items = ["Uber", "Google", "Facebook", "Apple"]
            }
          )
        ]
  , selected = 
      Set.fromList
        [ "1", "2" ]
  , shuffle = False
  , mode = Viewing--Editing NewList
  , editList = 
      { name = ""
      , items = []
      , item = ""
      }
  }


update: Msg -> Model -> (Model, Cmd Msg)
update msg model = 
  case msg of
    ToggleSelected listId -> 
      let selected' = 
            Util.toggleMember listId model.selected
      in
        ({ model | selected = selected' }, Cmd.none)

    ToggleShuffle -> 
      ({ model | shuffle = not model.shuffle }, Cmd.none)

    SetMode mode -> 
      ({ model | mode = mode }, Cmd.none)

    SetListName name -> 
      let editList = model.editList
          editList' = { editList | name = name}
      in 
        ({ model | editList = editList' }, Cmd.none)

    AddItem -> 
      let editList = model.editList
          editList' = 
            { editList 
              | items = editList.items ++ [editList.item]
              , item = ""
            }
      in 
        ({ model | editList = editList' }, Cmd.none)        

    RemoveItem i -> 
      let editList = model.editList
          editList' = 
            { editList 
              | items = Util.dropNth editList.items i
            }
      in 
        ({ model | editList = editList' }, Cmd.none)        

    SetItem string -> 
      let editList = model.editList
          editList' = 
            { editList 
              | item = string
            }
      in 
        ({ model | editList = editList' }, Cmd.none)           

    Save -> 
      let newList = 
            { id = model.editList.name -- hack
            , name = model.editList.name
            , items = model.editList.items
            }
          editList = 
            { name = ""
            , items = []
            , item = ""
            }

          lists = Dict.insert newList.id newList model.lists
      in 
        ({ model 
            | lists = lists
            , editList = editList
         }, Cmd.none)



view: Model -> Html Msg
view model =
  div
    [ class "app" ]
    --[ case model.mode of
    --    Viewing -> viewingBody model
    --    Editing _ -> editingBody model
    --]

    [ logo
    , intro
    , case model.mode of
        Viewing -> viewingBody model
        Editing _ -> editingBody model
    ]


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
              , onClick (SetMode (Editing NewList))
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
            (List.map listNameEditing (Dict.values model.lists))
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
            , placeholder "(e.g. favorite bands, apps, friends)"
            , onInput SetListName
            ]
            []
        , div
            [ class "input-title"]
            [ text "Items" ]
        , div
            [ class "items-container" ]
            ( List.indexedMap item model.editList.items )
        , div 
            [ class "new-item field"]
            [ div
                [ class "input-title"]
                [ text "New item" ]            
            , input
                [ class "item"
                , placeholder "(e.g. Rush, Twitter, Norm)"
                , onInput SetItem
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

