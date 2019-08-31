module NameResolution
using MLStyle
using MLStyle.Record
using DataStructures
ODict = OrderedDict

export Scope, Variable
export is_global!, is_local!, assign!, require!, resolve_scope!

include("Variable.jl")
VarMap = ODict{Symbol, Variable}
include("Analyzer.jl")

function is_global!(analyzer :: Analyzer, sym :: Symbol)
    looked = get(analyzer.used, sym, nothing)
    @when nothing = looked begin
        var = global_var(sym)
        used!(analyzer, sym, var)
        var
    @otherwise
        is_global!(looked)
        looked
    end
end

function is_local!(analyzer :: Analyzer, sym :: Symbol)
    looked = get(analyzer.used, sym, nothing)
    @when nothing = looked begin
        var = readable_var(sym)
        used!(analyzer, sym, var)
        var
    @otherwise
        not_global!(looked)
        looked
    end
end

function assign!(analyzer :: Analyzer, sym::Symbol)
    looked =  lookup(analyzer, sym)
    @when nothing = looked begin
        # when assigning an unknown symbol, treat it as a bound
        var = readable_var(sym)
        enter!(analyzer, var)
        used!(analyzer, sym, var)
        var
    @otherwise
        # found. it's got written, in other words it's mutable.
        is_mutable!(looked)
        looked
    end
end

function bind!(analyzer :: Analyzer, sym::Symbol)
    looked = get(analyzer.used, sym, nothing)
    @when nothing = looked begin
        # when assigning an unknown symbol, treat it as a bound
        var = readable_var(sym)
        enter!(analyzer, var)
        used!(analyzer, sym, var)
        var
    @otherwise
        # found. it's got written, in other words it's mutable.
        is_mutable!(looked)
        looked
    end
end

function require!(analyzer :: Analyzer, sym)
    trace = Analyzer[]
    looked =  lookup!(analyzer, sym, trace)
    @when nothing = looked begin
        # when requiring an unknown symbol, treat it as global
        var = global_var(sym)
        for analyzer in trace
            used!(analyzer, sym, var)
        end
        var
    @otherwise
        looked
    end
end

function resolve_scope!(analyzer :: Analyzer)
    scope    = analyzer.solved.x
    freevars = scope.freevars
    bounds   = scope.bounds
    globals  = scope.globals
    foreach(resolve_scope!, analyzer.childs)
    for (k, v) in analyzer.used
        if v ∈ analyzer.entered
            bounds[k] = v
        elseif v.is_global.x
            globals[k] = v
        else
            freevars[k] = v
        end
    end
    nothing
end

struct Solver{Solve}
    solve :: Solve
end

end # module
