module NameResolution
using MLStyle
using MLStyle.Record
using DataStructures
ODict = OrderedDict
OSet = OrderedSet

export Scope, Variable
export is_global!, is_local!, enter!, require!, abs_interp_on_scopes, VarMap

include("Variable.jl")
VarMap = ODict{Symbol, Variable}
include("Analyzer.jl")

function is_global!(analyzer :: Analyzer, sym :: Symbol)
    push!(analyzer.globals, sym) ;nothing
end

function is_local!(analyzer :: Analyzer, sym :: Symbol)
    push!(analyzer.locals, sym) ;nothing
end

function enter!(analyzer :: Analyzer, sym::Symbol)
    if haskey(analyzer.entered, sym)
        analyzer.entered[sym] = true
    else
        analyzer.entered[sym] = false # has mutating sites
    end ;nothing
end

function require!(analyzer :: Analyzer, sym::Symbol)
    push!(analyzer.required, sym) ;nothing
end

function request_freevar!(ana::Analyzer, var :: Variable)
    scope = ana.solved.x
    sym = var.sym
    bound = get(scope.bounds, var.sym, nothing)
    if bound === nothing
        get!(scope.freevars, sym) do
            # if 'var' is in free variables,
            # it must be a cell of parent scope.
            request_freevar(ana.parent, var)
            var
        end
    end
    get!(scope.cells, sym) do
        var
    end
    nothing
end

function abs_interp_on_scopes(analyzer::Analyzer, inherited::D1, global_vars::D2) where {
        D1 <: AbstractDict{Symbol, Variable},
        D2 <: AbstractDict{Symbol, Variable}
    }
    scope    = analyzer.solved.x
    freevars = scope.freevars
    cells    = scope.cells
    bounds   = scope.bounds

    entered  = analyzer.entered
    required = analyzer.required
    globals  = analyzer.globals
    locals   = analyzer.locals

    both_local_and_global = intersect(globals, locals)
    if !isempty(both_local_and_global)
        vars = join(map(string, both_local_and_global), ", ")
        error("syntax: variable \"$vars\" declared both local and global")
    end

    for sym in globals
        get!(global_vars, sym) do
            Variable(Ref(false), Ref(true), sym)
        end
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
            global_vars[sym].is_global.x = true
            continue
        @label when_avaiable_outside
            var = inherited[sym]
            var.is_mutable.x = true
            freevars[sym] = var
            request_freevar!(analyzer.parent, var)
            continue
        @label when_bound
            var = get(bounds, sym, nothing)
            if var === nothing
                bounds[sym] = Variable(Ref(assign_twice), Ref(false), sym)
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
        elseif haskey(global_vars, sym) && haskey(entered, sym)
            error("Writing global variable $sym without specifying the scope explicitly.\n"*
                  "Try to add 'global $sym' in that scope.")
        else
            continue
        end
        # is free variable
        var = inherited[sym]
        freevars[sym] = var
        request_freevar!(analyzer, var)
    end
    inherited = Dict(inherited..., bounds...)
    for child in analyzer.childs
        abs_interp_on_scopes(child, inherited, global_vars)
    end
end

struct Solver{Solve}
    solve :: Solve
end

end # module
