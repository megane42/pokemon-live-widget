port module Main exposing (main)

import Browser
import Html exposing (Html, button, div, h2, hr, img, li, p, text, ul)
import Html.Attributes exposing (class, src, style)
import Html.Events exposing (onClick)
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
            ( { model | battleTeamMembers = newBattleTeamMembers }, Cmd.none )

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


pokemonLiveness : Bool -> String
pokemonLiveness living =
    if living then
        "pokemonLiving"

    else
        "pokemonDead"


pokemonDetailActiveness : PokemonDetailCategory -> PokemonDetailCategory -> String
pokemonDetailActiveness expected actual =
    if expected == actual then
        "pokemonDetailActive"

    else
        "pokemonDetailHidden"


battleTeamMembersDisplay : PokemonDetailCategory -> List BattleTeamMember -> List (Html msg)
battleTeamMembersDisplay pokemonDetail battleTeamMembers =
    [ div
        [ class "battleTeamMembersDisplay" ]
        (battleTeamMembers
            |> List.sortBy .order
            |> List.map
                (battleTeamMembersDisplayItem pokemonDetail)
        )
    ]


battleTeamMembersDisplayItem : PokemonDetailCategory -> BattleTeamMember -> Html msg
battleTeamMembersDisplayItem pokemonDetail battleTeamMember =
    div
        [ class "battleTeamMembersDisplayItem" ]
        [ div
            [ class "pokemonImage", class (pokemonLiveness battleTeamMember.living) ]
            [ img [ src battleTeamMember.teamMember.pokemon.imageUrl ] [] ]
        , div
            [ class "pokemonDetail" ]
            [ div
                [ class "pokemonAbstruct"
                , class (pokemonDetailActiveness Abstruct pokemonDetail)
                ]
                [ div [ class "pokemonName" ] [ text battleTeamMember.teamMember.pokemon.name ]
                , div [ class "pokemonAbility" ] [ text battleTeamMember.teamMember.pokemon.ability ]
                , div [ class "pokemonItemName" ] [ text battleTeamMember.teamMember.pokemon.item.name ]
                ]
            , div
                [ class "pokemonMoves"
                , class (pokemonDetailActiveness Moves pokemonDetail)
                ]
                (List.map
                    (\move ->
                        div [ class "pokemonMove" ] [ text move ]
                    )
                    battleTeamMember.teamMember.pokemon.moves
                )
            ]
        ]


battleTeamMembersControl : List BattleTeamMember -> List (Html Msg)
battleTeamMembersControl battleTeamMembers =
    [ h2 [] [ text "選出パーティ管理" ]
    , ul
        []
        (battleTeamMembers
            |> List.sortBy .order
            |> List.map
                (\battleTeamMember ->
                    li []
                        [ text battleTeamMember.teamMember.pokemon.name
                        , button [ onClick (FaintBattleTeamMember battleTeamMember) ] [ text "ひんしにする" ]
                        , button [ onClick (ReviveBattleTeamMember battleTeamMember) ] [ text "げんきにする" ]
                        ]
                )
        )
    , button [ onClick ResetBattleTeamMember ] [ text "選出しなおす" ]
    ]


teamMembersControl : List TeamMember -> List (Html Msg)
teamMembersControl teamMembers =
    [ h2 [] [ text "パーティ管理" ]
    , ul
        []
        (List.map
            (\teamMember ->
                li []
                    [ text teamMember.pokemon.name
                    , button [ onClick (PickTeamMemberAsBattleTeamMember teamMember) ] [ text "選出する" ]
                    ]
            )
            teamMembers
        )
    ]


pokemonsControl : List Pokemon -> List (Html Msg)
pokemonsControl pokemons =
    [ h2 [] [ text "ポケモン管理" ]
    , ul
        []
        (List.map
            (\pokemon ->
                li []
                    [ text pokemon.name
                    , button [ onClick (PickPokemonAsTeamMember pokemon) ] [ text "パーティに入れる" ]
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
