module Buggy.Views.Util (
    getBuggyCookie
) where

import Happstack.Server (Cookie)

getBuggyCookie :: [(String, Cookie)] -> Maybe Cookie
getBuggyCookie cookies
    | search == [] = Nothing
    | otherwise = Just $ snd (head search)
    where search = filter (\x -> fst x == "buggy-user") cookies
