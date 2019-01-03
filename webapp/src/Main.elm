module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Database exposing (NewTransaction, Transaction, TransactionChange(..), createTransaction, transactionChange)
import Html exposing (Html, button, div, h1, img, li, text, ul)
import Html.Attributes exposing (src)
import Html.Events exposing (onClick)
import Json.Decode as Decode



---- MODEL ----


type alias Model =
    { transactions : List Transaction }


init : ( Model, Cmd Msg )
init =
    ( { transactions = [] }, Cmd.none )



---- UPDATE ----


type Msg
    = CreateTransaction NewTransaction
    | Change (Result Decode.Error TransactionChange)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Change res ->
            case res of
                Ok change ->
                    ( { model | transactions = applyChange change model.transactions }, Cmd.none )

                Err e ->
                    let
                        a =
                            Debug.log "WARN: failed to parse change message:" e
                    in
                    ( model, Cmd.none )

        CreateTransaction trans ->
            ( model, createTransaction trans )


applyChange : TransactionChange -> List Transaction -> List Transaction
applyChange change transactions =
    case change of
        Deleted id ->
            List.filter (\x -> x.id /= id) transactions

        Upserted new ->
            if List.any (\x -> x.id == new.id) transactions then
                List.map
                    (\x ->
                        if x.id == new.id then
                            new

                        else
                            x
                    )
                    transactions

            else
                transactions ++ [ new ]



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ img [ src "/logo.svg" ] []
        , h1 [] [ text "Your Elm App is working!" ]
        , viewTransactions model.transactions
        , viewAddTransaction
        ]


viewTransactions : List Transaction -> Html Msg
viewTransactions transactions =
    let
        mapper t =
            li [] [ text <| String.fromInt t.points ++ " points from " ++ t.from ++ " to " ++ t.to ]
    in
    ul [] <| List.map mapper transactions


viewAddTransaction : Html Msg
viewAddTransaction =
    button [ onClick <| CreateTransaction { from = "daan", to = "frits", points = 1000 } ] [ text "Add transaction" ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always <| transactionChange Change
        }
