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
function not_global!(var :: Variable)
    var.is_global.x = false; nothing
end
function enter!(analyzer::Analyzer, var::Variable)
    push!(analyzer.entered, var); nothing
end
function used!(analyzer, sym::Symbol, var::Variable)
    analyzer.used[sym] = var; nothing
end

function lookup(analyzer::Analyzer, sym::Symbol)
    @match get(analyzer.used, sym, nothing) begin
       nothing => lookup(analyzer.parent, sym)
       var     => var
    end
end

function lookup!(analyzer::Analyzer, sym::Symbol, trace::Vector{Analyzer})
    push!(trace, analyzer)
    @match get(analyzer.used, sym, nothing) begin
       nothing => lookup!(analyzer.parent, sym, trace)
       var     => var
    end
end

lookup(::Nothing, ::Symbol) = nothing
lookup!(::Nothing, ::Symbol, _) = nothing

new_scope() = Scope(VarMap(), VarMap(), VarMap())
new_analyzer(parent::Union{Nothing, Analyzer}) = Analyzer(
    VarMap(),
    [],
    [],
    parent,
    new_scope()
)

is_top_analyzer(ana::Analyzer) = ana.parent === nothing
top_analyzer() = new_analyzer(nothing)

function child_analyzer!(ana::Analyzer)::Analyzer
    child_analyzer = new_analyzer(ana)
    push!(ana.childs, child_analyzer)
    child_analyzer
end
