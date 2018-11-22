module Test.Kore.Step.Function.UserDefined (test_userDefinedFunction) where

import Test.Tasty
       ( TestTree )
import Test.Tasty.HUnit
       ( testCase )

import           Data.Default
                 ( def )
import qualified Data.Functor.Foldable as Functor.Foldable
import           Data.List
                 ( sort )
import qualified Data.Set as Set

import qualified Test.Kore.IndexedModule.MockMetadataTools as Mock

import           Kore.AST.Common
import           Kore.AST.MetaOrObject
import           Kore.ASTHelpers
                 ( ApplicationSorts (..) )
import           Kore.ASTUtils.SmartConstructors
                 ( mkTop )
import           Kore.ASTUtils.SmartPatterns
import           Kore.Implicit.ImplicitSorts
import           Kore.IndexedModule.MetadataTools
                 ( MetadataTools (..), SymbolOrAliasSorts )
import qualified Kore.IndexedModule.MetadataTools as HeadType
                 ( HeadType (..) )
import           Kore.Predicate.Predicate
                 ( makeFalsePredicate, makeTruePredicate )
import           Kore.Step.BaseStep
                 ( AxiomPattern (..) )
import           Kore.Step.ExpandedPattern as ExpandedPattern
                 ( Predicated (..), bottom )
import           Kore.Step.Function.Data as AttemptedFunction
                 ( AttemptedFunction (..) )
import           Kore.Step.Function.Data
                 ( CommonAttemptedFunction )
import           Kore.Step.Function.UserDefined
                 ( axiomFunctionEvaluator )
import qualified Kore.Step.OrOfExpandedPattern as OrOfExpandedPattern
                 ( make )
import           Kore.Step.Pattern
import           Kore.Step.Simplification.Data
                 ( CommonStepPatternSimplifier, SimplificationProof (..),
                 evalSimplifier )
import           Kore.Step.StepperAttributes
import qualified SMT

import           Test.Kore
import           Test.Kore.Comparators ()
import qualified Test.Kore.Step.MockSimplifiers as Mock
import           Test.Kore.Step.Simplifier
                 ( mockSimplifier )
import           Test.Tasty.HUnit.Extensions

test_userDefinedFunction :: [TestTree]
test_userDefinedFunction =
    [ testCase "Applies one step" $ do
        let expect =
                AttemptedFunction.Applied $ OrOfExpandedPattern.make
                    [ Predicated
                        { term =
                            asApplication $ metaG (Var_ $ x patternMetaSort)
                        , predicate = makeTruePredicate
                        , substitution = []
                        }
                    ]
        actual <-
            evaluateWithAxiom
                mockMetadataTools
                AxiomPattern
                    { axiomPatternLeft =
                        asApplication $ metaF (Var_ $ x patternMetaSort)
                    , axiomPatternRight =
                        asApplication $ metaG (Var_ $ x patternMetaSort)
                    , axiomPatternRequires = makeTruePredicate
                    , axiomPatternAttributes = def
                    }
                (mockSimplifier [])
                (metaF (Var_ $ x patternMetaSort))
        assertEqualWithExplanation "f(x) => g(x)" expect actual

    , testCase "Cannot apply step with unsat axiom pre-condition" $ do
        let expect =
                AttemptedFunction.Applied (OrOfExpandedPattern.make [])
        actual <-
            evaluateWithAxiom
                mockMetadataTools
                AxiomPattern
                    { axiomPatternLeft =
                        asApplication $ metaF (Var_ $ x patternMetaSort)
                    , axiomPatternRight =
                        asApplication $ metaG (Var_ $ x patternMetaSort)
                    , axiomPatternRequires = makeFalsePredicate
                    , axiomPatternAttributes = def
                    }
                (mockSimplifier [])
                (metaF (Var_ $ x patternMetaSort))
        assertEqualWithExplanation "f(x) => g(x) requires false" expect actual

    , testCase "Cannot apply step with unsat condition" $ do
        let expect =
                AttemptedFunction.Applied
                $ OrOfExpandedPattern.make [ ExpandedPattern.bottom ]
        actual <-
            evaluateWithAxiom
                mockMetadataTools
                AxiomPattern
                    { axiomPatternLeft =
                        asApplication $ metaF (Var_ $ x patternMetaSort)
                    , axiomPatternRight =
                        asApplication $ metaG (Var_ $ x patternMetaSort)
                    , axiomPatternRequires = makeTruePredicate
                    , axiomPatternAttributes = def
                    }
                (mockSimplifier
                    -- Evaluate Top to Bottom.
                    [ (mkTop, ([], SimplificationProof)) ]
                )
                (metaF (Var_ $ x patternMetaSort))
        assertEqualWithExplanation "" expect actual

    , testCase "Reevaluates the step application" $ do
        let expect =
                AttemptedFunction.Applied $ OrOfExpandedPattern.make
                    [ Predicated
                        { term =
                            asApplication $ metaH (Var_ $ x patternMetaSort)
                        , predicate = makeTruePredicate
                        , substitution = []
                        }
                    ]
        actual <-
            evaluateWithAxiom
                mockMetadataTools
                AxiomPattern
                    { axiomPatternLeft =
                        asApplication $ metaF (Var_ $ x patternMetaSort)
                    , axiomPatternRight =
                        asApplication $ metaG (Var_ $ x patternMetaSort)
                    , axiomPatternRequires = makeTruePredicate
                    , axiomPatternAttributes = def
                    }
                (mockSimplifier
                    [   (   asApplication $ metaG (Var_ $ x patternMetaSort)
                        ,   (   [ Predicated
                                    { term =
                                        asApplication
                                        $ metaH (Var_ $ x patternMetaSort)
                                    , predicate = makeTruePredicate
                                    , substitution = []
                                    }
                                ]
                            , SimplificationProof
                            )
                        )
                    ]
                )
                (metaF (Var_ $ x patternMetaSort))
        assertEqualWithExplanation "f(x) => g(x) and g(x) => h(x)" expect actual

    , testCase "Does not reevaluate the step application with incompatible condition" $ do
        let expect =
                AttemptedFunction.Applied $ OrOfExpandedPattern.make
                    [ExpandedPattern.bottom]
        actual <-
            evaluateWithAxiom
                mockMetadataTools
                AxiomPattern
                    { axiomPatternLeft =
                        asApplication $ metaF (Var_ $ x patternMetaSort)
                    , axiomPatternRight =
                        asApplication $ metaG (Var_ $ x patternMetaSort)
                    , axiomPatternRequires = makeTruePredicate
                    , axiomPatternAttributes = def
                    }
                (mockSimplifier
                    [   (   asApplication $ metaG (Var_ $ x patternMetaSort)
                        ,   (   [ Predicated
                                    { term =
                                        asApplication
                                        $ metaH (Var_ $ x patternMetaSort)
                                    , predicate = makeFalsePredicate
                                    , substitution = []
                                    }
                                ]
                            , SimplificationProof
                            )
                        )
                    ]
                )
                (metaF (Var_ $ x patternMetaSort))
        assertEqualWithExplanation
            "f(x) => g(x) and g(x) => h(x) + false"
            expect
            actual

    , testCase "Preserves step substitution" $ do
        let expect =
                AttemptedFunction.Applied $ OrOfExpandedPattern.make
                    [ Predicated
                        { term =
                            asApplication $ metaG (Var_ $ b patternMetaSort)
                        , predicate = makeTruePredicate
                        , substitution =
                            [(a patternMetaSort, Var_ $ b patternMetaSort)]
                        }
                    ]
        actual <-
            evaluateWithAxiom
                mockMetadataTools
                AxiomPattern
                    { axiomPatternLeft  =
                        asApplication $ metaSigma
                            (Var_ $ x patternMetaSort)
                            (Var_ $ x patternMetaSort)
                    , axiomPatternRight =
                        asApplication $ metaG (Var_ $ x patternMetaSort)
                    , axiomPatternRequires = makeTruePredicate
                    , axiomPatternAttributes = def
                    }
                (mockSimplifier [])
                (metaSigma
                    (Var_ $ a patternMetaSort)
                    (Var_ $ b patternMetaSort)
                )
        assertEqualWithExplanation "sigma(x,x) => g(x) vs sigma(a, b)" expect actual

    , testCase "Merges the step substitution with the reevaluation one" $ do
        let expect =
                AttemptedFunction.Applied $ OrOfExpandedPattern.make
                    [ Predicated
                        { term =
                            asApplication $ metaH (Var_ $ c patternMetaSort)
                        , predicate = makeTruePredicate
                        , substitution =
                            [   ( a patternMetaSort
                                -- TODO(virgil): Do we want normalization here?
                                , Var_ $ c patternMetaSort
                                )
                            ,   ( b patternMetaSort
                                , Var_ $ c patternMetaSort
                                )
                            ]
                        }
                    ]
        actual <-
            evaluateWithAxiom
                mockMetadataTools
                AxiomPattern
                    { axiomPatternLeft  =
                        asApplication $ metaSigma
                            (Var_ $ x patternMetaSort)
                            (Var_ $ x patternMetaSort)
                    , axiomPatternRight =
                        asApplication $ metaG (Var_ $ x patternMetaSort)
                    , axiomPatternRequires = makeTruePredicate
                    , axiomPatternAttributes = def
                    }
                (mockSimplifier
                    [   (   asApplication $ metaG (Var_ $ b patternMetaSort)
                        ,   (   [ Predicated
                                    { term =
                                        asApplication
                                        $ metaH (Var_ $ c patternMetaSort)
                                    , predicate = makeTruePredicate
                                    , substitution =
                                        [   ( b patternMetaSort
                                            , Var_ $ c patternMetaSort
                                            )
                                        ]
                                    }
                                ]
                            , SimplificationProof
                            )
                        )
                    ]
                )
                (metaSigma
                    (Var_ $ a patternMetaSort)
                    (Var_ $ b patternMetaSort)
                )
        assertEqualWithExplanation
            "sigma(x,x) => g(x) vs sigma(a, b) and g(b) => h(c) + a=c,b=c"
            expect
            actual
    -- TODO: Add a test for StepWithAxiom returning a condition.
    -- TODO: Add a test for the stepper giving up
    ]

mockSymbolOrAliasSorts :: SymbolOrAliasSorts Meta
mockSymbolOrAliasSorts = const ApplicationSorts
    { applicationSortsOperands = [patternMetaSort, patternMetaSort]
    , applicationSortsResult = patternMetaSort
    }

mockMetadataTools :: MetadataTools Meta StepperAttributes
mockMetadataTools = MetadataTools
    { symAttributes = const Mock.constructorFunctionalAttributes
    , symbolOrAliasType = const HeadType.Symbol
    , sortAttributes = const Mock.constructorFunctionalAttributes
    , symbolOrAliasSorts  = mockSymbolOrAliasSorts
    , isSubsortOf = const $ const False
    , subsorts = Set.singleton
    }

x, a, b, c :: Sort Meta -> Variable Meta
x = Variable (testId "#x")
a = Variable (testId "#a")
b = Variable (testId "#b")
c = Variable (testId "#c")

fSymbol :: SymbolOrAlias Meta
fSymbol = SymbolOrAlias
    { symbolOrAliasConstructor = testId "#f"
    , symbolOrAliasParams = []
    }

metaF
    :: CommonPurePattern Meta dom
    -> Application Meta (CommonPurePattern Meta dom)
metaF p = Application fSymbol [p]


gSymbol :: SymbolOrAlias Meta
gSymbol = SymbolOrAlias
    { symbolOrAliasConstructor = testId "#g"
    , symbolOrAliasParams = []
    }

metaG
    :: CommonPurePattern Meta dom
    -> Application Meta (CommonPurePattern Meta dom)
metaG p = Application gSymbol [p]

hSymbol :: SymbolOrAlias Meta
hSymbol = SymbolOrAlias
    { symbolOrAliasConstructor = testId "#h"
    , symbolOrAliasParams = []
    }

metaH
    :: CommonPurePattern Meta dom
    -> Application Meta (CommonPurePattern Meta dom)
metaH p = Application hSymbol [p]


sigmaSymbol :: SymbolOrAlias Meta
sigmaSymbol = SymbolOrAlias
    { symbolOrAliasConstructor = testId "#sigma"
    , symbolOrAliasParams = []
    }

metaSigma
    :: CommonPurePattern Meta dom
    -> CommonPurePattern Meta dom
    -> Application Meta (CommonPurePattern Meta dom)
metaSigma p1 p2 = Application sigmaSymbol [p1, p2]

asApplication
    :: Functor dom
    => Application Meta (CommonPurePattern Meta dom)
    -> CommonPurePattern Meta dom
asApplication = Functor.Foldable.embed . ApplicationPattern

evaluateWithAxiom
    :: MetaOrObject level
    => MetadataTools level StepperAttributes
    -> AxiomPattern level
    -> CommonStepPatternSimplifier level
    -> Application level (CommonStepPattern level)
    -> IO (CommonAttemptedFunction level)
evaluateWithAxiom
    metadataTools
    axiom
    simplifier
    app
  =
    evaluated >>= return . \case
        AttemptedFunction.Applied orPattern ->
            AttemptedFunction.Applied (fmap sortSubstitution orPattern)
        result -> result
  where
    sortSubstitution Predicated {term, predicate, substitution} =
        Predicated
            { term = term
            , predicate = predicate
            , substitution = sort substitution
            }
    evaluated =
        (<$>) fst
        $ SMT.runSMT SMT.defaultConfig
        $ evalSimplifier
        $ axiomFunctionEvaluator
            axiom
            metadataTools
            (Mock.substitutionSimplifier metadataTools)
            simplifier
            app