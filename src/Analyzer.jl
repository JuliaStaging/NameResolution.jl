struct Scope
    bounds   :: VarMap
    freevars :: VarMap
    cells    :: VarMap
end

# for def-use analysis
struct Analyzer
    entered   :: Dict{Symbol, Bool}
    required  :: Set{Symbol}
    globals   :: Set{Symbol}
    locals    :: Set{Symbol}

    children    :: Vector
    parent    :: Any
    solved    :: Ref{Scope}
end

new_scope() = Scope(VarMap(), VarMap(), VarMap())
new_analyzer(parent::Union{Nothing, Analyzer}) = Analyzer(
    Dict{Symbol, Bool}(),
    Set{Symbol}(),
    Set{Symbol}(),
    Set{Symbol}(),

    [],
    parent,
    new_scope()
)

is_top_analyzer(ana::Analyzer) = ana.parent === nothing
top_analyzer() = new_analyzer(nothing)

function child_analyzer!(ana::Analyzer)::Analyzer
    child_analyzer = new_analyzer(ana)
    push!(ana.children, child_analyzer)
    child_analyzer
end
