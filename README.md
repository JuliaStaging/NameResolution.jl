# NameResolution

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://thautwarm.github.io/NameResolution.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://thautwarm.github.io/NameResolution.jl/dev)
[![Build Status](https://travis-ci.com/thautwarm/NameResolution.jl.svg?branch=master)](https://travis-ci.com/thautwarm/NameResolution.jl)
[![Codecov](https://codecov.io/gh/thautwarm/NameResolution.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/thautwarm/NameResolution.jl)


Cross-language name resolutions.

To solve the scope of following codes,

```julia
function f(x) # enter f, enter x, x is local
    y = 1 + x # enter y, require x
    g -> begin
      y = 2 # enter g, g is local
      y + g # require y, require g
    end
end
```

we can use `NameResolution.jl` to achieve this,
check [test/runtests.jl](https://github.com/thautwarm/NameResolution.jl/blob/master/test/runtests.jl)
for more details.

```julia
ana = top_analyzer()
enter!(ana, :f)
is_local!(ana, :x)
enter!(ana, :x)

enter!(ana, :y)
require!(ana, :x)
lambda = child_analyzer!(ana)

is_local!(lambda, :g)
enter!(lambda, :g)

enter!(lambda, :y)
require!(lambda, :y)
require!(lambda, :g)

run_analyzer(ana)
println("f ", ana.solved)
println("lambda ", lambda.solved)
```

outputs:

```julia
julia> println("f ", ana.solved.x)
f Scope(
  bounds={
    f=>LocalVar(f, is_mutable=false, is_shared=false),

    y=>LocalVar(y, is_mutable=true, is_shared=true),

    x=>LocalVar(x, is_mutable=false, is_shared=false),
  },
  freevars={},
  parent=nothing,
)



julia> println("lambda ", lambda.solved.x)
lambda Scope(
  bounds={
    g=>LocalVar(g, is_mutable=false, is_shared=false),
  },
  freevars={
    y=>LocalVar(y, is_mutable=true, is_shared=true),
  },
  parent=Scope(
    bounds={
      f=>LocalVar(f, is_mutable=false, is_shared=false),

      y=>LocalVar(y, is_mutable=true, is_shared=true),

      x=>LocalVar(x, is_mutable=false, is_shared=false),
    },
    freevars={},
    parent=nothing,
  ),
)



```

<!--
1. Transform `Symbol`s in ASTs into `Variable`s.

```julia
struct Variable
    is_mutable  :: Ref{Bool} # mutability
    is_global   :: Ref{Bool}
    sym         :: Symbol
end
```

2. Transform functions with free variables into closures.

```julia
struct Closure
    freevars :: OrderedDict{Symbol, Variable}
    fn_exp   :: Expr
end
``` -->
