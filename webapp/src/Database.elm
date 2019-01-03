port module Database exposing
    ( NewTransaction
    , Transaction
    , TransactionChange(..)
    , Uuid
    , createTransaction
    , transactionChange
    )

import Json.Decode as Decode exposing (Decoder, int, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as E


type alias Uuid =
    String


uuidDecode : Decoder Uuid
uuidDecode =
    string


type alias Transaction =
    { id : Uuid, rev : Uuid, from : Uuid, to : Uuid, points : Int }


type TransactionChange
    = Upserted Transaction
    | Deleted Uuid


transactionDecoder : Decoder Transaction
transactionDecoder =
    Decode.succeed Transaction
        |> required "_id" uuidDecode
        |> required "_rev" uuidDecode
        |> required "from" uuidDecode
        |> required "to" uuidDecode
        |> required "points" int


deletedDecoder : Decoder Uuid
deletedDecoder =
    Decode.at [ "deleted", "id" ] uuidDecode


upsertedDecoder : Decoder Transaction
upsertedDecoder =
    Decode.at [ "upserted" ] transactionDecoder


transactionChangeDecoder : Decoder TransactionChange
transactionChangeDecoder =
    Decode.oneOf
        [ Decode.map Upserted upsertedDecoder
        , Decode.map Deleted deletedDecoder
        ]


port transactionChangeInternal : (E.Value -> msg) -> Sub msg


transactionChange : (Result Decode.Error TransactionChange -> msg) -> Sub msg
transactionChange mapper =
    transactionChangeInternal (mapper << Decode.decodeValue transactionChangeDecoder)


type alias NewTransaction =
    { from : Uuid
    , to : Uuid
    , points : Int
    }


newTransactionEncode : NewTransaction -> E.Value
newTransactionEncode t =
    E.object
        [ ( "from", E.string t.from )
        , ( "to", E.string t.to )
        , ( "points", E.int t.points )
        ]


createTransaction : NewTransaction -> Cmd msg
createTransaction =
    createTransactionInternal << newTransactionEncode


port createTransactionInternal : E.Value -> Cmd msg
