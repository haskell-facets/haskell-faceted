{-# LANGUAGE GADTs,RankNTypes,DeriveFunctor #-}

module Faceted.FIORef (
  FIORef,
  newFIORef,
  readFIORef,
  writeFIORef,
  ) where

import Faceted.Internal

import Data.IORef

-- | Variables of type 'FIORef a' are faceted 'IORef's
data FIORef a = FIORef (IORef a)

-- | Allocate a new 'FIORef'
newFIORef :: Faceted a -> FIO (FIORef (Faceted a))
newFIORef init = FIO newFIORefForPC
  where newFIORefForPC pc = do
        putStrLn "Making new IORef"
        var <- newIORef (pcF pc init Bottom)
        return (FIORef var)

-- | Read an 'FIORef'
readFIORef :: FIORef (Faceted a) -> FIO (Faceted a)
readFIORef (FIORef var) = FIO readFIORefForPC
  where readFIORefForPC pc = do
        putStrLn "Reading an IORef"
        faceted <- readIORef var
        return faceted 

-- | Write an 'FIORef'
writeFIORef :: FIORef (Faceted a) -> Faceted a -> FIO (Faceted ())
writeFIORef (FIORef var) newValue = FIO writeFIORefForPC
  where writeFIORefForPC pc = do
        putStrLn "Writing an IORef"
        oldValue <- readIORef var
        writeIORef var (pcF pc newValue oldValue)
        return $ return ()
