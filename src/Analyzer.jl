struct Scope
    bounds   :: VarMap
    freevars :: VarMap
    cells    :: VarMap
end

# for def-use analysis
struct Analyzer
    entered   :: ODict{Symbol, Bool}
    required  :: OSet{Symbol}
    globals   :: OSet{Symbol}
    locals    :: OSet{Symbol}

    childs    :: Vector
    parent    :: Any
    solved    :: Ref{Scope}
end

new_scope() = Scope(VarMap(), VarMap(), VarMap())
new_analyzer(parent::Union{Nothing, Analyzer}) = Analyzer(
    ODict{Symbol, Bool}(),
    OSet{Symbol}(),
    OSet{Symbol}(),
    OSet{Symbol}(),

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
