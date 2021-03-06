port module Main exposing (main)

import Browser
import Html exposing (Html, button, div, h2, hr, img, li, p, span, text, ul)
import Html.Attributes exposing (class, src, style)
import Html.Events exposing (onClick)
import Html.Keyed as Keyed
import Time


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type alias Item =
    { name : String
    , imageUrl : String
    }


type alias Pokemon =
    { id : String
    , name : String
    , imageUrl : String
    , ability : String
    , moves : List String
    , types : List String
    , item : Item
    }


type alias TeamMember =
    { id : String
    , pokemon : Pokemon
    }


type alias BattleTeamMember =
    { id : String
    , living : Bool
    , order : Int
    , teamMember : TeamMember
    }


type PokemonDetailCategory
    = Abstruct
    | Moves


type alias Model =
    { battleTeamMembers : List BattleTeamMember
    , teamMembers : List TeamMember
    , pokemons : List Pokemon
    , pickIndex : Int
    , pokemonDetail : PokemonDetailCategory
    }


battleTeamMemberPlaceHolder : String -> Int -> BattleTeamMember
battleTeamMemberPlaceHolder id order =
    { id = id
    , living = True
    , order = order
    , teamMember =
        { id = ""
        , pokemon =
            { id = ""
            , name = "???"
            , imageUrl = "[VITE_PLUGIN_ELM_ASSET:/assets/pokeball.svg]"
            , ability = "???"
            , moves = [ "???", "???", "???", "???" ]
            , types = [ "???" ]
            , item =
                { name = ""
                , imageUrl = ""
                }
            }
        }
    }


battleTeamMemberPlaceHolders : List BattleTeamMember
battleTeamMemberPlaceHolders =
    [ battleTeamMemberPlaceHolder "1" 999
    , battleTeamMemberPlaceHolder "2" 999
    , battleTeamMemberPlaceHolder "3" 999
    ]


init : () -> ( Model, Cmd Msg )
init _ =
    ( { battleTeamMembers = []
      , teamMembers = []
      , pokemons = []
      , pickIndex = 1
      , pokemonDetail = Abstruct
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = GetBattleTeamMembers (List BattleTeamMember)
    | GetTeamMembers (List TeamMember)
    | GetPokemons (List Pokemon)
    | FaintBattleTeamMember BattleTeamMember
    | ReviveBattleTeamMember BattleTeamMember
    | ResetBattleTeamMember
    | PickTeamMemberAsBattleTeamMember TeamMember
    | PickPokemonAsTeamMember Pokemon
    | SwitchPokemonDetail Time.Posix


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetBattleTeamMembers newBattleTeamMembers ->
            ( { model
                | battleTeamMembers =
                    battleTeamMemberPlaceHolders
                        |> List.append newBattleTeamMembers
                        |> List.take 3
              }
            , Cmd.none
            )

        GetTeamMembers newTeamMembers ->
            ( { model | teamMembers = newTeamMembers }, Cmd.none )

        GetPokemons newPokemons ->
            ( { model | pokemons = newPokemons }, Cmd.none )

        FaintBattleTeamMember battleTeamMember ->
            ( model, setBattleTeamMember { battleTeamMember | living = False } )

        ReviveBattleTeamMember battleTeamMember ->
            ( model, setBattleTeamMember { battleTeamMember | living = True } )

        ResetBattleTeamMember ->
            ( { model | pickIndex = 1 }, deleteBattleTeamMember () )

        PickTeamMemberAsBattleTeamMember teamMember ->
            ( { model | pickIndex = model.pickIndex + 1 }, setBattleTeamMember (BattleTeamMember "__RANDOM_ID__" True model.pickIndex teamMember) )

        PickPokemonAsTeamMember pokemon ->
            ( model, setTeamMember (TeamMember "__RANDOM_ID__" pokemon) )

        SwitchPokemonDetail _ ->
            if model.pokemonDetail == Abstruct then
                ( { model | pokemonDetail = Moves }, Cmd.none )

            else
                ( { model | pokemonDetail = Abstruct }, Cmd.none )



-- PORTS


port getBattleTeamMembers : (List BattleTeamMember -> msg) -> Sub msg


port getTeamMembers : (List TeamMember -> msg) -> Sub msg


port getPokemons : (List Pokemon -> msg) -> Sub msg


port setBattleTeamMember : BattleTeamMember -> Cmd msg


port deleteBattleTeamMember : () -> Cmd msg


port setTeamMember : TeamMember -> Cmd msg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ getBattleTeamMembers GetBattleTeamMembers
        , getTeamMembers GetTeamMembers
        , getPokemons GetPokemons
        , Time.every 5000 SwitchPokemonDetail
        ]



-- VIEW


convertPokemonLivenessToClass : Bool -> String
convertPokemonLivenessToClass living =
    if living then
        "pokemonLiving"

    else
        "pokemonDead"


convertPokemonDetailCategoryToClass : PokemonDetailCategory -> PokemonDetailCategory -> String
convertPokemonDetailCategoryToClass expected actual =
    if expected == actual then
        "pokemonDetailActive"

    else
        "pokemonDetailHidden"


convertPokemonTypeToClass : String -> String
convertPokemonTypeToClass pokemonType =
    if pokemonType == "????????????" then
        "normal"

    else if pokemonType == "?????????" then
        "fire"

    else if pokemonType == "??????" then
        "water"

    else if pokemonType == "??????" then
        "grass"

    else if pokemonType == "?????????" then
        "electric"

    else if pokemonType == "?????????" then
        "ice"

    else if pokemonType == "????????????" then
        "fighting"

    else if pokemonType == "??????" then
        "poison"

    else if pokemonType == "?????????" then
        "ground"

    else if pokemonType == "?????????" then
        "flying"

    else if pokemonType == "????????????" then
        "psychic"

    else if pokemonType == "??????" then
        "bug"

    else if pokemonType == "??????" then
        "rock"

    else if pokemonType == "????????????" then
        "ghost"

    else if pokemonType == "????????????" then
        "dragon"

    else if pokemonType == "??????" then
        "dark"

    else if pokemonType == "?????????" then
        "steel"

    else if pokemonType == "???????????????" then
        "fairy"

    else
        "default"


battleTeamMembersDisplay : PokemonDetailCategory -> List BattleTeamMember -> List (Html msg)
battleTeamMembersDisplay pokemonDetail battleTeamMembers =
    [ Keyed.node "div"
        [ class "battleTeamMembersDisplay" ]
        (battleTeamMembers
            |> List.sortBy .order
            |> List.map
                (battleTeamMembersDisplayItem pokemonDetail)
            |> List.intersperse ( "", div [ class "battleTeamMembersDisplayItemSepareter" ] [] )
        )
    ]


battleTeamMembersDisplayItem : PokemonDetailCategory -> BattleTeamMember -> ( String, Html msg )
battleTeamMembersDisplayItem pokemonDetail battleTeamMember =
    ( battleTeamMember.id
    , div
        [ class "battleTeamMembersDisplayItem" ]
        [ div
            [ class "pokemonImage", class (convertPokemonLivenessToClass battleTeamMember.living) ]
            [ img [ src battleTeamMember.teamMember.pokemon.imageUrl ] [] ]
        , div
            [ class "pokemonDetail" ]
            [ div
                [ class "pokemonAbstruct"
                , class (convertPokemonDetailCategoryToClass Abstruct pokemonDetail)
                ]
                [ div [ class "pokemonName" ] [ text battleTeamMember.teamMember.pokemon.name ]
                , div [ class "pokemonTypes" ]
                    (List.map
                        (\pokemonType -> span [ class "pokemonType", class (convertPokemonTypeToClass pokemonType) ] [ text pokemonType ])
                        battleTeamMember.teamMember.pokemon.types
                    )
                , div [ class "pokemonAbility" ] [ text battleTeamMember.teamMember.pokemon.ability ]
                , div [ class "pokemonItemName" ] [ text battleTeamMember.teamMember.pokemon.item.name ]
                ]
            , div
                [ class "pokemonMoves"
                , class (convertPokemonDetailCategoryToClass Moves pokemonDetail)
                ]
                (List.map
                    (\move ->
                        div [ class "pokemonMove" ] [ text move ]
                    )
                    battleTeamMember.teamMember.pokemon.moves
                )
            ]
        ]
    )


battleTeamMembersControl : List BattleTeamMember -> List (Html Msg)
battleTeamMembersControl battleTeamMembers =
    [ h2 [] [ text "????????????????????????" ]
    , ul
        []
        (battleTeamMembers
            |> List.sortBy .order
            |> List.map
                (\battleTeamMember ->
                    li []
                        [ text battleTeamMember.teamMember.pokemon.name
                        , button [ onClick (FaintBattleTeamMember battleTeamMember) ] [ text "??????????????????" ]
                        , button [ onClick (ReviveBattleTeamMember battleTeamMember) ] [ text "??????????????????" ]
                        ]
                )
        )
    , button [ onClick ResetBattleTeamMember ] [ text "??????????????????" ]
    ]


teamMembersControl : List TeamMember -> List (Html Msg)
teamMembersControl teamMembers =
    [ h2 [] [ text "??????????????????" ]
    , ul
        []
        (List.map
            (\teamMember ->
                li []
                    [ text teamMember.pokemon.name
                    , button [ onClick (PickTeamMemberAsBattleTeamMember teamMember) ] [ text "????????????" ]
                    ]
            )
            teamMembers
        )
    ]


pokemonsControl : List Pokemon -> List (Html Msg)
pokemonsControl pokemons =
    [ h2 [] [ text "??????????????????" ]
    , ul
        []
        (List.map
            (\pokemon ->
                li []
                    [ text pokemon.name
                    , button [ onClick (PickPokemonAsTeamMember pokemon) ] [ text "????????????????????????" ]
                    ]
            )
            pokemons
        )
    ]


view : Model -> Html Msg
view model =
    div []
        [ div [ class "battleTeamMembersDisplayContainer" ]
            (battleTeamMembersDisplay model.pokemonDetail model.battleTeamMembers)
        , hr [] []
        , div []
            (battleTeamMembersControl model.battleTeamMembers)
        , hr [] []
        , div []
            (teamMembersControl model.teamMembers)
        , hr [] []
        , div []
            (pokemonsControl model.pokemons)
        ]
