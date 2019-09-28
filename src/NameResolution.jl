module NameResolution
using PrettyPrint
export Scope, LocalVar, GlobalVar
export is_global!, is_local!, enter!, require!, abs_interp_on_scopes, VarMap, run_analyzer
export child_analyzer!, new_analyzer, top_analyzer, new_scope, is_top_analyzer

include("Variable.jl")
VarMap = Dict{Symbol, LocalVar}
include("Analyzer.jl")

function is_global!(analyzer :: Analyzer, sym :: Symbol)
    push!(analyzer.globals, sym) ;nothing
end
function is_global!(:: Nothing, sym :: Symbol) end

function is_local!(analyzer :: Analyzer, sym :: Symbol)
    push!(analyzer.locals, sym) ;nothing
end
function is_local!(:: Nothing, sym :: Symbol) end

function enter!(analyzer :: Analyzer, sym::Symbol)
    if haskey(analyzer.entered, sym)
        analyzer.entered[sym] = true
    else
        analyzer.entered[sym] = false # has mutating sites
    end ;nothing
end
function enter!(:: Nothing, sym::Symbol) end

function require!(analyzer :: Analyzer, sym::Symbol)
    push!(analyzer.required, sym) ;nothing
end
function require!(:: Nothing, sym::Symbol) end

function request_freevar!(ana::Analyzer, var :: LocalVar)

    scope = ana.solved
    sym = var.sym
    bound = get(scope.bounds, var.sym, nothing)
    if bound === nothing
        getter = if ana.is_physical_scope
            var.is_shared.x = true
            get!
        else
            get
        end
        bound = getter(scope.freevars, sym) do
            # if 'var' is in free variables,
            request_freevar!(ana.parent, var)
            var
        end
    end
    @assert bound === var
    nothing
end

function abs_interp_on_scopes(analyzer::Analyzer, inherited::D) where {
    D <: AbstractDict{Symbol, LocalVar}
}
    scope    = analyzer.solved
    freevars = scope.freevars
    bounds   = scope.bounds

    entered  = analyzer.entered
    required = analyzer.required
    globals  = analyzer.globals
    locals   = analyzer.locals
    is_physical_scope = analyzer.is_physical_scope

    both_local_and_global = intersect(globals, locals)
    if !isempty(both_local_and_global)
        vars = join([string(x) for x in both_local_and_global], ", ")
        error("syntax: variable \"$vars\" declared both local and global")
    end

    for (sym, assign_twice) in entered
        if sym in globals
            @goto when_marked_global
        elseif sym in locals
            @goto when_bound
        elseif haskey(inherited, sym)
            @goto when_avaiable_outside
        else
            @goto when_bound
        end
        @label when_marked_global
            continue
        @label when_avaiable_outside
            var = inherited[sym]
            var.is_mutable.x = true
            if is_physical_scope
                freevars[sym] = var
            end
            request_freevar!(analyzer.parent, var)
            continue
        @label when_bound
            var = get(bounds, sym, nothing)
            if var === nothing
                bounds[sym] = LocalVar(Ref(assign_twice), Ref(false), sym)
            else
                bounds[sym].is_mutable.x = true
            end
        continue # for good-looking
    end

    for sym in required
        if sym in globals
            continue
        elseif sym in locals
            continue
        elseif haskey(inherited, sym)
            # case for free variable
        elseif sym in globals && haskey(entered, sym)
            error("Writing global variable $sym without specifying the scope explicitly.\n"*
                  "Try to add 'global $sym' in that scope.")
        else
            continue
        end
        # is free variable
        var = inherited[sym]
        if is_physical_scope
            freevars[sym] = var
        end
        request_freevar!(analyzer.parent, var)
    end
    inherited = VarMap(inherited..., bounds...)
    for child in analyzer.children
        abs_interp_on_scopes(child, inherited)
    end
end

run_analyzer(ana :: Analyzer) = abs_interp_on_scopes(ana, VarMap())
include("Pretty.jl")

end # module
