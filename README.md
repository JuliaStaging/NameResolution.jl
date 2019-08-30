# NameResolution

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://thautwarm.github.io/NameResolution.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://thautwarm.github.io/NameResolution.jl/dev)
[![Build Status](https://travis-ci.com/thautwarm/NameResolution.jl.svg?branch=master)](https://travis-ci.com/thautwarm/NameResolution.jl)
[![Codecov](https://codecov.io/gh/thautwarm/NameResolution.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/thautwarm/NameResolution.jl)


Extensible/Customizable name resolutions(**WIP**).


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
```
