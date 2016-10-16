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


---
So, now the question is how to implement the combinations. 

Given a list of lists, like this: 

[ [1,2,3]
, [10,20]
, [100,200]
]

I'd like to generate the following: 
[ [1,10,100]
, [1,10,200]
, [1,20,100]
, [1,20,200]
, [2,10,100]
, [2,10,200]
, [2,20,100]
, [2,20,200]
, [3,10,100]
, [3,10,200]
, [3,20,100]
, [3,20,200]
]

There are a few ideas that occur to me: 
1. Cycling - each value cycles with some frequency
2. Array indexes - you can specify what should happen at location directly with indexes
3. Some kind of recursive function. 

I like the idea of having a generator. 
The first list is a generator. Maybe that doesn't make sense. 

So, what about a recursive thing? 

What's the simplest case? 

combining a single value with a list. It's what I called zipOne before. Maybe prepend to all makes more sense. 

prependToAll: List a -> a -> List (List a)
prependToAll xs y = 
  List.map (\x -> [y, x]) xs

prependToAll [10,20,30] 1 == 
  [ [1, 10]
  , [1, 20]
  , [1, 30]
  ]

That seems like a good first step to addressing the problem. I suppose I'd map prependToAll over all the elements of a list: 

a = [1,2]
b = [10,20,30]

List.map (prependToAll b) a ==
  [ [ [1, 10]
    , [1, 20]
    , [1, 30]
    ]
  , [ [2, 10]
    , [2, 20]
    , [2, 30]
    ]
  ]

If I use concatMap, I'll get: 

List.concatMap (prependToAll b) a ==
  [ [1, 10]
  , [1, 20]
  , [1, 30]
  , [2, 10]
  , [2, 20]
  , [2, 30]
  ]

Then, I'd want to use something like prependToAll to do the next list. I think prependToAll should actually use a list of lists as its first argument. 

prependToAll: List (List a) -> a -> List (List a)
prependToAll xs y = 
  List.map (\x -> y::x) xs

This is actually truer to the name, and will work for all cases. 

So, now I should be able to take the result of the previous call to prependToAll, and use it as the first argument to the next call. 

result = 
  [ [1, 10]
  , [1, 20]
  , [1, 30]
  , [2, 10]
  , [2, 20]
  , [2, 30]
  ]

List.concatMap (prependToAll result) [100,200] ==
 ---

So, I think this will work. What's the full, general implementation going to look like? 

combinations lists = 
  let combine lists accum = 
        case lists of
          head::tail -> 
            combine tail (List.concatMap (prependToAll accum) head)
          [] -> 
            accum
  in 
    combine lists [[]]

  


