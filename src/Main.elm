port module Main exposing (main)

import Browser
import Html exposing (Html, button, div, h2, hr, img, li, p, text, ul)
import Html.Attributes exposing (class, src, style)
import Html.Events exposing (onClick)


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


type alias Model =
    { battleTeamMembers : List BattleTeamMember
    , teamMembers : List TeamMember
    , pokemons : List Pokemon
    , pickIndex : Int
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { battleTeamMembers = []
      , teamMembers = []
      , pokemons = []
      , pickIndex = 1
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
        ]



-- VIEW


battleTeamMembersDisplay : List BattleTeamMember -> List (Html msg)
battleTeamMembersDisplay battleTeamMembers =
    [ div
        [ class "battleTeamMembersDisplay" ]
        (List.map
            battleTeamMembersDisplayItem
            battleTeamMembers
        )
    ]


battleTeamMembersDisplayItem : BattleTeamMember -> Html msg
battleTeamMembersDisplayItem battleTeamMember =
    div
        [ class "battleTeamMembersDisplayItem" ]
        [ div
            [ class "pokemonImage" ]
            [ img [ src battleTeamMember.teamMember.pokemon.imageUrl ] [] ]
        , div
            [ class "pokemonDetail" ]
            [ div
                [ class "pokemonAbstruct" ]
                [ div [ class "pokemonName" ] [ text battleTeamMember.teamMember.pokemon.name ]
                , div [ class "pokemonAbility" ] [ text battleTeamMember.teamMember.pokemon.ability ]
                , div [ class "pokemonItemName" ] [ text battleTeamMember.teamMember.pokemon.item.name ]
                ]
            ]
        ]


battleTeamMembersControl : List BattleTeamMember -> List (Html Msg)
battleTeamMembersControl battleTeamMembers =
    [ h2 [] [ text "選出パーティ管理" ]
    , ul
        []
        (List.map
            (\battleTeamMember ->
                li []
                    [ text battleTeamMember.teamMember.pokemon.name
                    , button [ onClick (FaintBattleTeamMember battleTeamMember) ] [ text "ひんしにする" ]
                    , button [ onClick (ReviveBattleTeamMember battleTeamMember) ] [ text "げんきにする" ]
                    ]
            )
            battleTeamMembers
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
            (battleTeamMembersDisplay model.battleTeamMembers)
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
