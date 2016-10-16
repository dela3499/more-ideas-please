module Types exposing (..)

import Set exposing (Set)
import Dict exposing (Dict)


type alias Model = 
  { lists: Dict ListId List'
  , selected: Set ListId
  , shuffle: Bool
  , mode: Mode
  , editList: EditList
  }


type alias List' = 
  { id: ListId
  , name: String
  , items: List String
  }


type alias EditList = 
  { name: String
  , items: List String
  , item: String
  }


type alias ListId =
  String


type Msg
  = ToggleSelected String
  | ToggleShuffle
  | SetMode Mode
  | SetListName String
  | AddItem
  | RemoveItem Int
  | SetItem String
  | Save


type Mode 
  = Viewing
  | Editing EditState


type EditState
 = NewList
 | ExistingList ListId