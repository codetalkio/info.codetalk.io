{-# LANGUAGE OverloadedStrings #-}
import Data.Monoid (mappend)
import Hakyll
-- For compressJsCompiler
import Control.Monad (liftM)
import Control.Applicative ((<$>))
import qualified Data.ByteString.Lazy.Char8 as LB
import qualified Data.Text as T
import qualified Data.Text.Encoding as E
import Text.Jasmine


compressJsCompiler :: Compiler (Item String)
compressJsCompiler = fmap jasmin <$> getResourceString

jasmin :: String -> String
jasmin src = LB.unpack $ minify $ LB.fromChunks [E.encodeUtf8 $ T.pack src]

-- | Main defines all the route handling
main :: IO ()
main = hakyll $ do
    -- | Route for all images
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    -- | Compile SCSS to CSS and serve it
    match "scss/app.scss" $ do
        route   $ constRoute "app.css"
        compile $ liftM (fmap compressCss) $
            getResourceString
            >>= withItemBody (unixFilter "sass" [ "-s"
                                                , "--scss"
                                                , "--compass"
                                                , "--style", "compressed"
                                                , "--load-path", "scss"
                                                ])

    -- | Route for all javascript files
    match "js/*" $ do
        route   idRoute
        compile compressJsCompiler

    -- | Load all partial templates
    match "templates/*" $ compile templateCompiler

    -- | Pages: Load all standard pages using the page template
    match (fromList ["index.md"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/index.html" defaultContext
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    -- | Index: Create the index page
    -- create ["index.html"] $ do
    --     route idRoute
    --     compile $ do
    --         makeItem ""
    --             >>= loadAndApplyTemplate "templates/blog.html" defaultContext
    --             >>= loadAndApplyTemplate "templates/default.html" defaultContext
    --             >>= relativizeUrls
