port module Database exposing (Transaction, TransactionChange(..), Uuid, transactionChange)

import Json.Decode as Decode exposing (Decoder, int, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as E


type alias Uuid =
    String


type alias Transaction =
    { id : Uuid, rev : Uuid, from : Uuid, to : Uuid, points : Int }


type TransactionChange
    = Upserted Transaction
    | Deleted Uuid


uuidDecode : Decoder Uuid
uuidDecode =
    string


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
