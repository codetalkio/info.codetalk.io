{-# LANGUAGE TupleSections, OverloadedStrings #-}
module Handler.Home where

import Import

getHomeR :: Handler RepHtml
getHomeR = do
    defaultLayout $ do
        setTitle "Codetalk IRC"
        $(widgetFile "homepage")
