// Copyright (c) 2014-2018 K Team. All Rights Reserved.
module FIND-SPEC
  imports KERNELC

rule
  <struct>... STRUCT:Map ...</struct>
  <fun>... FUN:Map ...</fun>
  <k>
    find(tv(int, V:Int), tv(struct treeNode *, TP:Pointer))
  =>
    tv(int, bool2Int(V inIntSet tree_keys(T)))
  ...</k>
  <heap>...
    tree(TP)(T:Tree)
  ...</heap>
endmodule
