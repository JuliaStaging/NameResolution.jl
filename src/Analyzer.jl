struct Scope
    bounds   :: VarMap
    freevars :: VarMap
    parent   :: Union{Nothing, Scope}
end

function Base.getindex(scope :: Scope, sym :: Symbol)
    get(scope.bounds, sym) do
    get(scope.freevars, sym) do
    scope.parent === nothing && return sym
    scope.parent[sym]
    end
    end
end

# for def-use analysis
struct Analyzer
    entered   :: Dict{Symbol, Bool}
    required  :: Set{Symbol}
    globals   :: Set{Symbol}
    locals    :: Set{Symbol}

    children          :: Vector
    parent            :: Any
    solved            :: Scope
    is_physical_scope :: Bool
    # decide whether to do closure conversion
    # for Julia, let-bindings need 'is_physical_scope = false',
    # while for Python, we can always have 'is_physical_scope = true'.
end

new_scope(scope) = Scope(VarMap(), VarMap(), scope)
new_analyzer(parent::Union{Nothing, Analyzer}, is_physical_scope::Bool) = Analyzer(
    Dict{Symbol, Bool}(),
    Set{Symbol}(),
    Set{Symbol}(),
    Set{Symbol}(),

    [],
    parent,
    new_scope(if nothing === parent; nothing else parent.solved end),
    is_physical_scope
)

is_top_analyzer(ana::Analyzer) = ana.parent === nothing
top_analyzer() = new_analyzer(nothing, true)

function child_analyzer!(ana::Analyzer, is_physical_scope::Bool=true)::Analyzer
    child_analyzer = new_analyzer(ana, is_physical_scope)
    push!(ana.children, child_analyzer)
    child_analyzer
end

function child_analyzer!(ana::Nothing, is_physical_scope::Bool=true)::Analyzer
    new_analyzer(ana, is_physical_scope)
end