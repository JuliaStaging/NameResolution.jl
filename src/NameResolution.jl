module NameResolution
using MLStyle
using MLStyle.Record
using DataStructures

ODict = OrderedDict
struct Variable
    is_mutable  :: Ref{Bool} # mutability
    is_global   :: Ref{Bool}
    sym         :: Symbol
end
@as_record Variable

readable_var(sym::Symbol) = Variable(Ref(false), Ref(false), sym)
VarMap = ODict{Symbol, Variable}

struct Scope
    bounds   :: VarMap
    freevars :: VarMap
    globals  :: VarMap
end

# for def-use analysis
struct Analyzer
    used      :: VarMap
    entered   :: Vector{Variable}
    childs    :: Vector
    parent    :: Any
    solved    :: Ref{Scope}
end

function is_mutable!(var :: Variable)
    var.is_mutable.x = true; nothing
end
function is_global!(var :: Variable)
    var.is_global.x = true; nothing
end
function enter!(analyzer::Analyzer, var::Variable)
    push!(analyzer.entered, var); nothing
end
function used!(analyzer, sym::Symbol, var::Variable)
    analyzer.used[sym] = var; nothing
end
function lookup!(analyzer::Analyzer, sym::Symbol, trace::Vector{Analyzer})
    push!(trace, analyzer)
    @match get(analyzer.used, sym, nothing) begin
       nothing => lookup!(analyzer.parent, sym, trace)
       var     => var
    end
end
lookup!(::Nothing, sym::Symbol, _) = nothing

function assign!(analyzer :: Analyzer, sym::Symbol)
    looked =  lookup!(analyzer, sym, Analyzer[])
    @when nothing = looked begin
        # when assigning an unknown symbol, treat it as a bound
        var = readable_var(sym)
        enter!(analyzer, sym, var)
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
    looked =  lookup(analyzer, sym, trace)
    @when nothing = looked begin
        # when requiring an unknown symbol, treat it as global
        var = readable_var(sym)
        is_global!(var)
        for analyzer in trace
            used!(analyzer, sym, var)
        end
        var
    @otherwise
        is_mutable!(looked)
        looked
    end
end

function resolve_scope!(analyzer :: Analyzer)
    scope    = analyzer.solved
    freevars = scope.freevars
    bounds   = scope.bounds
    globals  = scope.globals
    foreach(resolve_scope!, analyzer.childs)
    for (k, v) in analyzer.used
        if v ∉ analyzer.entered
            bounds[k] = v
        elseif v.is_global.x
            globals[k] = v
        else
            freevars[k] = v
        end
    end
    nothing
end

struct Solver
end

function solve(solver :: Solver, a, analyzer :: Analyzer)
    error("not impl yet")
end

end # module
