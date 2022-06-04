port module Main exposing (main)

import Browser
import Html exposing (Html, button, div, h2, hr, li, text, ul)
import Html.Attributes exposing (style)
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


type alias Pokemon =
    { id : String
    , name : String
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


battleTeamMembersDisplayList : List BattleTeamMember -> List (Html msg)
battleTeamMembersDisplayList battleTeamMembers =
    [ ul
        []
        (List.map
            (\battleTeamMember ->
                li
                    [ style "text-decoration-line"
                        (if battleTeamMember.living then
                            "none"

                         else
                            "line-through"
                        )
                    ]
                    [ text battleTeamMember.teamMember.pokemon.name ]
            )
            battleTeamMembers
        )
    ]


battleTeamMembersControlList : List BattleTeamMember -> List (Html Msg)
battleTeamMembersControlList battleTeamMembers =
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


teamMembersControlList : List TeamMember -> List (Html Msg)
teamMembersControlList teamMembers =
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


pokemonsControlList : List Pokemon -> List (Html Msg)
pokemonsControlList pokemons =
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
        [ div []
            (battleTeamMembersDisplayList model.battleTeamMembers)
        , hr [] []
        , div []
            (battleTeamMembersControlList model.battleTeamMembers)
        , hr [] []
        , div []
            (teamMembersControlList model.teamMembers)
        , hr [] []
        , div []
            (pokemonsControlList model.pokemons)
        ]
