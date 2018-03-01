package org.kframework.kore

import org.kframework.{kore => i}

object implementation {

  private object ConcreteClasses {

    case class Definition(att: i.Attributes, module: i.Module) extends i.Definition

    case class Module(name: String, decls: Seq[i.Declaration], att: i.Attributes) extends i.Module

    // case class Import(name: i.ModuleName, att: i.Attributes) extends i.Import

    case class SortDeclaration(params: Seq[i.SortVariable], sort: i.Sort, att: i.Attributes) extends i.SortDeclaration

    case class SymbolDeclaration(symbol: i.Symbol, argSorts: Seq[i.Sort], returnSort: i.Sort, att: i.Attributes) extends i.SymbolDeclaration

    case class AliasDeclaration(alias: i.Alias, argSorts: Seq[i.Sort], returnSort: i.Sort, att: i.Attributes) extends i.AliasDeclaration

    case class AxiomDeclaration(params: Seq[i.SortVariable], pattern: i.Pattern, att: i.Attributes) extends i.AxiomDeclaration

    case class Attributes(patterns: Seq[i.Pattern]) extends i.Attributes

    case class Variable(name: String, sort: i.Sort) extends i.Variable

    case class Application(head: i.SymbolOrAlias, args: Seq[i.Pattern]) extends i.Application

    case class Top(s: i.Sort) extends i.Top

    case class Bottom(s: i.Sort) extends i.Bottom

    case class And(s: i.Sort, _1: i.Pattern, _2: i.Pattern) extends i.And

    case class Or(s: i.Sort, _1: i.Pattern, _2: i.Pattern) extends i.Or

    case class Not(s: i.Sort, _1: i.Pattern) extends i.Not

    case class Implies(s: i.Sort, _1: i.Pattern, _2: i.Pattern) extends i.Implies

    case class Iff(s: i.Sort, _1: i.Pattern, _2: i.Pattern) extends i.Iff

    case class Exists(s: i.Sort, v: i.Variable, p: i.Pattern) extends i.Exists

    case class Forall(s: i.Sort, v: i.Variable, p: i.Pattern) extends i.Forall

    // case class Next(s: i.Sort, _1: i.Pattern) extends i.Next

    // case class Rewrites(s: Sort, rs: Sort, _1: i.Pattern, _2: i.Pattern) extends i.Rewrites

    case class Ceil(s: i.Sort, rs: i.Sort, p: i.Pattern) extends i.Ceil

    case class Floor(s: i.Sort, rs: i.Sort, p: i.Pattern) extends i.Floor

    case class Equals(s: i.Sort, rs: i.Sort, _1: i.Pattern, _2: i.Pattern) extends i.Equals

    case class Mem(s: i.Sort, rs: i.Sort, p: i.Pattern, q: i.Pattern) extends i.Mem

    // case class Subset(s: i.Sort, rs: i.Sort,_1: i.Pattern,_2: i.Pattern) extends i.Subset

    case class StringLiteral(str: String) extends i.StringLiteral

    // case class DomainValue(sortStr: String, valueStr: String) extends i.DomainValue

    case class SortVariable(name: String) extends i.SortVariable

    case class CompoundSort(ctr: String, params: Seq[i.Sort]) extends i.CompoundSort

    case class SymbolOrAlias(ctr: String, params: Seq[i.Sort]) extends i.SymbolOrAlias

    case class Symbol(ctr: String, params: Seq[i.Sort]) extends i.Symbol

    case class Alias(ctr: String, params: Seq[i.Sort]) extends i.Alias
  }

  object DefaultBuilders extends i.Builders {

    import org.kframework.kore.implementation.{ConcreteClasses => d}

    def Definition(att: i.Attributes, module: i.Module): i.Definition = d.Definition(att, module)

    def Module(name: String, decls: Seq[i.Declaration], att: i.Attributes): i.Module = d.Module(name, decls, att)

    // def Import(name: i.ModuleName, att: i.Attributes): i.Declaration = d.Import(name, att)

    def SortDeclaration(params: Seq[i.SortVariable], sort: i.Sort, att: i.Attributes): i.Declaration = d.SortDeclaration(params, sort, att)

    def SymbolDeclaration(symbol: i.Symbol, argSorts: Seq[i.Sort], returnSort: i.Sort, att: i.Attributes): i.Declaration = d.SymbolDeclaration(symbol, argSorts, returnSort, att)

    def AliasDeclaration(alias: i.Alias, argSorts: Seq[i.Sort], returnSort: i.Sort, att: i.Attributes): i.Declaration = d.AliasDeclaration(alias, argSorts, returnSort, att)

    def AxiomDeclaration(params: Seq[i.SortVariable], _1: i.Pattern, att: i.Attributes): i.Declaration = d.AxiomDeclaration(params, _1, att)

    def Attributes(patterns: Seq[Pattern]): i.Attributes = d.Attributes(patterns)

    def Variable(name: String, sort: i.Sort): i.Variable = d.Variable(name, sort)

    def Application(head: i.SymbolOrAlias, args: Seq[i.Pattern]): i.Pattern = d.Application(head, args)

    def Top(s: i.Sort): i.Pattern = d.Top(s)

    def Bottom(s: i.Sort): i.Pattern = d.Bottom(s)

    def And(s: i.Sort, _1: i.Pattern, _2: i.Pattern): i.Pattern = d.And(s, _1, _2)

    def Or(s: i.Sort, _1: i.Pattern, _2: i.Pattern): i.Pattern = d.Or(s, _1, _2)

    def Not(s: i.Sort, _1: i.Pattern): i.Pattern = d.Not(s, _1)

    def Implies(s: i.Sort, _1: i.Pattern, _2: i.Pattern): i.Pattern = d.Implies(s, _1, _2)

    def Iff(s: i.Sort, _1: i.Pattern, _2: i.Pattern): i.Pattern = d.Iff(s, _1, _2)

    def Exists(s: i.Sort, v: Variable, p: Pattern): i.Pattern = d.Exists(s, v, p)

    def Forall(s: i.Sort, v: Variable, p: Pattern): i.Pattern = d.Forall(s, v, p)

    // def Next(s: i.Sort, _1: i.Pattern): i.Pattern = d.Next(s, _1)

    // def Rewrites(s: i.Sort, rs: i.Sort, _1: i.Pattern, _2: i.Pattern): i.Pattern = d.Rewrites(s, rs, _1, _2)

    def Ceil(s: i.Sort, rs: i.Sort, p: Pattern): i.Pattern = d.Ceil(s, rs, p)

    def Floor(s: i.Sort, rs: i.Sort, p: Pattern): i.Pattern = d.Floor(s, rs, p)

    def Equals(s: i.Sort, rs: i.Sort, _1: i.Pattern, _2: i.Pattern): i.Pattern = d.Equals(s, rs, _1, _2)

    def Mem(s: i.Sort, rs: i.Sort, p: i.Pattern, q: i.Pattern): i.Pattern = d.Mem(s, rs, p, q)

    // def Subset(s: i.Sort, rs: i.Sort, _1: Pattern, _2: Pattern): i.Pattern = d.Subset(s, rs, _1, _2)

    def StringLiteral(str: String): i.Pattern = d.StringLiteral(str)

    // def DomainValue(sortStr: String, valueStr: String): Pattern = d.DomainValue(sortStr, valueStr)

    def SortVariable(name: String): i.SortVariable = d.SortVariable(name)

    def CompoundSort(ctr: String, params: Seq[i.Sort]): i.CompoundSort = d.CompoundSort(ctr, params)

    def SymbolOrAlias(ctr: String, params: Seq[i.Sort]): i.SymbolOrAlias = d.SymbolOrAlias(ctr, params)

    def Symbol(ctr: String, params: Seq[i.Sort]): i.Symbol = d.Symbol(ctr, params)

    def Alias(ctr: String, params: Seq[i.Sort]): i.Alias = d.Alias(ctr, params)
  }
}
