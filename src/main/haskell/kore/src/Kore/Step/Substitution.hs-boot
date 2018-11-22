module Kore.Step.Substitution where

import Control.Monad.Except
       ( ExceptT )

import Control.Monad.Counter
       ( MonadCounter )
import Kore.AST.Common
       ( SortedVariable )
import Kore.AST.MetaOrObject
import Kore.IndexedModule.MetadataTools
       ( MetadataTools )
import Kore.Predicate.Predicate
       ( Predicate )
import Kore.Step.ExpandedPattern
       ( PredicateSubstitution )
import Kore.Step.Simplification.Data
       ( PredicateSubstitutionSimplifier )
import Kore.Step.StepperAttributes
       ( StepperAttributes )
import Kore.Substitution.Class
       ( Hashable )
import Kore.Unification.Data
       ( UnificationProof, UnificationSubstitution )
import Kore.Unification.Error
       ( UnificationOrSubstitutionError )
import Kore.Variables.Fresh
       ( FreshVariable )

mergePredicatesAndSubstitutionsExcept
    :: ( Show (variable level)
       , SortedVariable variable
       , MetaOrObject level
       , Ord (variable level)
       , OrdMetaOrObject variable
       , ShowMetaOrObject variable
       , FreshVariable variable
       , MonadCounter m
       , Hashable variable
       )
    => MetadataTools level StepperAttributes
    -> PredicateSubstitutionSimplifier level m
    -> [Predicate level variable]
    -> [UnificationSubstitution level variable]
    -> ExceptT
          ( UnificationOrSubstitutionError level variable )
          m
          ( PredicateSubstitution level variable
          , UnificationProof level variable
          )