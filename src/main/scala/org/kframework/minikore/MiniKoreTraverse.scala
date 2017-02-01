package org.kframework.minikore

import org.kframework.minikore.{MiniKoreInterface => i}

/**
  * Created by daejunpark on 1/31/17.
  */
abstract class MiniKoreTraverse {

  def c[P <: i.Pattern, V <: i.Variable]: i.Constructor[P,V]

//  def pre(p: i.Pattern): i.Pattern
//  def post(p: i.Pattern): i.Pattern
//  def postv(p: i.Variable): i.Variable
//  def map2(p: i.Pattern): i.Pattern = pre(p) match {
//    case p:i.Variable => postv(c.Variable(p.name, p.sort))
//    case p:i.Application => post(c.Application(p.label, p.args.map(map)))
//    case p:i.DomainValue => post(c.DomainValue(p.label, p.value))
//    case p:i.True => post(c.True())
//    case p:i.False => post(c.False())
//    case p:i.And => post(c.And(map(p.p), map(p.q)))
//    case p:i.Or => post(c.Or(map(p.p), map(p.q)))
//    case p:i.Not => post(c.Not(map(p.p)))
//    case p:i.Implies => post(c.Implies(map(p.p), map(p.q)))
//    case p:i.Exists => post(c.Exists(postv(p.v), map(p.p)))
//    case p:i.ForAll => post(c.ForAll(postv(p.v), map(p.p)))
//    case p:i.Next => post(c.Next(map(p.p)))
//    case p:i.Rewrite => post(c.Rewrite(map(p.p), map(p.q)))
//    case p:i.Equal => post(c.Equal(map(p.p), map(p.q)))
//  }

  def map(f: i.Pattern => i.Pattern)(p: i.Pattern): i.Pattern = p match {
    case p:i.Variable    => f(c.Variable(p.name, p.sort))
    case p:i.Application => f(c.Application(p.label, p.args.map(map(f))))
    case p:i.DomainValue => f(c.DomainValue(p.label, p.value))
    case p:i.True        => f(c.True())
    case p:i.False       => f(c.False())
    case p:i.And         => f(c.And     (map(f)(p.p), map(f)(p.q)))
    case p:i.Or          => f(c.Or      (map(f)(p.p), map(f)(p.q)))
    case p:i.Not         => f(c.Not     (map(f)(p.p))             )
    case p:i.Implies     => f(c.Implies (map(f)(p.p), map(f)(p.q)))
    case p:i.Exists      => f(c.Exists  (       p.v , map(f)(p.p)))
    case p:i.ForAll      => f(c.ForAll  (       p.v , map(f)(p.p)))
    case p:i.Next        => f(c.Next    (map(f)(p.p))             )
    case p:i.Rewrite     => f(c.Rewrite (map(f)(p.p), map(f)(p.q)))
    case p:i.Equal       => f(c.Equal   (map(f)(p.p), map(f)(p.q)))
  }

  def fi(p: i.Pattern): Unit
  def iter(p: i.Pattern): Unit = p match {
    case p:i.Variable    => fi(p)
    case p:i.Application => fi(p); p.args.foreach(iter)
    case p:i.DomainValue => fi(p)
    case p:i.True        => fi(p)
    case p:i.False       => fi(p)
    case p:i.And         => fi(p); iter(p.p); iter(p.q)
    case p:i.Or          => fi(p); iter(p.p); iter(p.q)
    case p:i.Not         => fi(p); iter(p.p)
    case p:i.Implies     => fi(p); iter(p.p); iter(p.q)
    case p:i.Exists      => fi(p); iter(p.v); iter(p.p)
    case p:i.ForAll      => fi(p); iter(p.v); iter(p.p)
    case p:i.Next        => fi(p); iter(p.p)
    case p:i.Rewrite     => fi(p); iter(p.p); iter(p.q)
    case p:i.Equal       => fi(p); iter(p.p); iter(p.q)
  }

//  def apply(v: i.Variable): i.Variable = {
//    case _:i.Variable =>
//  }

  def size(p: i.Pattern): Int = p match {
    case p:i.Leaf => 1
    case p:i.Node[i.Pattern] => p.args.map(size).sum
    case p:i.Node1[i.Pattern] => size(p.p)
    case p:i.Node2[i.Pattern] => size(p.p) + size(p.q)
    case p:i.NodeV[i.Pattern, i.Variable] => size(p.p)
  }

  def subst(m: Map[i.Variable, i.Pattern])(p: i.Pattern): i.Pattern = {
    p match {
      case p:i.Variable => if (m.contains(p)) m(p) else p
      case p:i.Exists => val x = fresh(p.v); c.Exists(x, subst(m + (p.v -> x))(p.p))
      case p:i.ForAll => val x = fresh(p.v); c.ForAll(x, subst(m + (p.v -> x))(p.p))
      case _ => map(subst(m))(p)
    }
  }
  def fresh(x: i.Variable): i.Variable = {
    c.Variable(x.name + "!new!", x.sort) // TODO: make it really fresh
  }

}
