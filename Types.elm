module Types exposing (..)

import Set exposing (Set)
import Dict exposing (Dict)
import Dom
import Random.Pcg

type alias Model = 
  { lists: Dict ListId List'
  , selected: Set ListId
  , shuffle: Bool
  , mode: Mode
  , editList: List'
  , editItem: String
  , focus: Focus
  , seed: Random.Pcg.Seed
  , t: Float
  }


type alias List' = 
  { id: ListId
  , name: String
  , items: List String
  , created: Float -- millisecond timestamp
  }

type alias ListId =
  String


-- Split into view and edit msgs
type Msg
  = ToggleSelected String
  | ToggleShuffle
  | SetMode Mode
  | SetListName String
  | AddItem
  | RemoveItem Int
  | SetItem String
  | Save
  | RecordFocus Focus
  | SetFocus Focus
  | KeyUp Int
  | NoMsg
  | ErrorMsg Dom.Error
  | SuccessMsg ()
  | ClearField Focus
  | SetInitialSeed Int
  | Edit List'
  | SetInputValue Focus String
  | SetTime Float
  | Delete


type Mode 
  = Viewing
  | Editing


type Focus 
  = NoFocus
  | ListName 
  | ListItem