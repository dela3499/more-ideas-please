module Update exposing (..)

import Html exposing (Html, text, div, span, a, img, p, i, input)
import Html.App as Html
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Attributes exposing (..)
import Maybe exposing (withDefault)
import Set exposing (Set)
import Dict exposing (Dict)
import String
import Task exposing (Task)
import Dom

import Types exposing (..)
import Util
import Cmd.Extra
import Ports
import Random.Pcg 
import Uuid.Barebones

app: Msg -> Model -> (Model, Cmd Msg)
app msg model = 
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
            if (String.length model.editItem) > 0 then
              { editList 
                | items = editList.items ++ [model.editItem]
                
              }
            else
              editList
      in 
        ({ model 
            | editList = editList'
            , editItem = "" 
         }, Ports.clearField "list-item-input"
        )

    RemoveItem i -> 
      let editList = model.editList
          editList' = 
            { editList 
              | items = Util.dropNth editList.items i
            }
      in 
        ({ model | editList = editList' }, Cmd.none)        

    SetItem string -> 
      ({ model | editItem = string }, Cmd.none)           

    Save -> 
      let editList = model.editList
          newTime = 
            if editList.created >= 1 then
              editList.created -- keep original times if they're real (should be a maybe!)
            else
              model.t
          saveList =
            { editList | created = newTime }

          lists = 
            Dict.insert saveList.id saveList model.lists

          cmds = 
            Cmd.batch
              [ Cmd.Extra.message (SetFocus ListName)
              , Cmd.Extra.message (ClearField ListName)
              , Cmd.Extra.message (ClearField ListItem)
              ]
          (id, seed') = Random.Pcg.step Uuid.Barebones.uuidStringGenerator model.seed
          editList' = 
            { name = ""
            , items = []
            , id = id
            , created = 0.0
            }
      in 
        ({ model 
            | lists = lists
            , editList = editList'
            , seed = seed'
         }, cmds)

    RecordFocus focus -> 
      ({ model | focus = focus}, Cmd.none)

    SetFocus focus -> 
      let _ = Debug.log "SetFocus" focus
      in
      case focus of 
        NoFocus -> 
          (model, Cmd.none)

        ListName -> 
          --(model, Ports.setFocus "list-name-input")
          (model, Task.perform ErrorMsg SuccessMsg (Dom.focus "list-name-input"))

        ListItem -> 
          --(model, Ports.setFocus "list-item-input")
          (model, Task.perform ErrorMsg SuccessMsg (Dom.focus "list-item-input"))

    ClearField focus -> 
      case focus of
        ListName -> 
          (model, Ports.clearField "list-name-input")

        ListItem -> 
          (model, Ports.clearField "list-item-input")

        _ -> 
          (model, Cmd.none)

    KeyUp key -> 
      let state = (model.focus, key)
      in case state of
        (NoFocus, _) -> 
          (model, Cmd.none)

        (ListName, 13) -> 
          (model, Cmd.Extra.message (SetFocus ListItem))

        (ListItem, 13) ->   
          (model, Cmd.Extra.message AddItem)
            
        _ -> 
          (model, Cmd.none)

    NoMsg -> 
      (model, Cmd.none)

    ErrorMsg string -> 
      let _ = Debug.log "ErrorMsg" string
      in 
        (model, Cmd.none)

    SuccessMsg string -> 
      let _ = Debug.log "SuccessMsg" string
      in 
        (model, Cmd.none)

    SetInitialSeed int -> 
      let seed = Random.Pcg.initialSeed int
          (id, seed') = Random.Pcg.step Uuid.Barebones.uuidStringGenerator seed
          editList = model.editList
          editList' = 
            { editList 
              | id = id
              , created = model.t
            }
      in 
        ({ model 
            | seed = seed' 
            , editList = editList'
         }, Cmd.none)

    Edit list -> 
      if list.id == "" then
        let (id, seed') = Random.Pcg.step Uuid.Barebones.uuidStringGenerator model.seed
            editList = 
              { list | id = id }
            cmds = 
              Cmd.batch 
                [ Cmd.Extra.message (SetFocus ListName)
                , Cmd.Extra.message (ClearField ListName)
                , Cmd.Extra.message (ClearField ListItem)
                ]
        in 
          ({ model | editList = editList, seed = seed' }, cmds)
      else   
        ({ model | editList = list }
        , Cmd.Extra.message (SetInputValue ListName list.name))

    SetInputValue input value -> 
      case input of 
        ListName -> 
          (model, Ports.setInputValue ("list-name-input", value))

        ListItem ->   
          (model, Ports.setInputValue ("list-item-input", value))

        _ -> 
          (model, Cmd.none)

    SetTime t ->
      ({ model | t = t }, Cmd.none)

    Delete -> 
      let lists' = Dict.remove model.editList.id model.lists
      in 
        ({ model | lists = lists' }
         , Cmd.Extra.message (Edit Util.emptyList 
        ))
