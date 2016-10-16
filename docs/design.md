Key app design questions: 
1. Model
2. Msg
3. Urls


# Model
{ string: String
, replacements: Dict String (List String)
, seed: Int
}

# Msg
SetString String
AddReplacement

Concerns: 
1. Losing data (that's hard to input)
 - maybe have an easy-copy operation -> just fork this
 - maybe separate the logic of sentence creation from replacements. 
 - have a separate logic, with some helpers to automatically generate replacement tags
2. Having mobile-first application
3. Simplicity - what one or two features would make this work well? 

User stories: 
1. Start with a sentence, and some replacements. 
2. Open app, type in sentence
3. Type in replacements


1. What are current messages in this application? 
  - SetSeedString String
  - SetSearchString Int String
  - SetReplaceStringList Int (List String)
  - ComputeSubstitutions
  - Animate Float
  - Help
  - NoOp

2. Current model: 
type alias Model =
  { seedString : String
  , searchStrings : Array String
  , replaceStringLists : Array (List String)
  , results : List String
  , seed : Random.Seed
  , t : Float
  , help : Bool
  }


initialModel : Model
initialModel =
  { seedString = "A #noun should be treated with #kindness."
  , searchStrings = initialGroups |> List.map fst |> Array.fromList
  , replaceStringLists = initialGroups |> List.map snd |> Array.fromList
  , results = helpText
  , seed = Random.initialSeed 2024121836
  , t = 0
  , help = False
  }

---
I'm going to go with a simpler app for now. I think that having a sentence to replace things is actually an advanced feature that can come later. I think the simpler option is to simply have some lists, and allow people to mix them. 

So, the new model is: 

{ lists: Dict String (List String)
, activeLists: Set String
}

This is the simplest model to start with. The immediately-following features will be: 
1. Shuffle
2. Delete list
3. Create list
4. Edit list
5. Persistence, accounts ...

