using NameResolution
using Test
using PrettyPrint

NR = NameResolution

function PrettyPrint.pprint_impl(io, v::Variable, indent, newline)
    print(io, "Variable($(v.sym), is_mutable=$(v.is_mutable.x), is_global=$(v.is_global.x)")
end

function PrettyPrint.pprint_impl(io, p::Pair, indent, newline)
    pprint(io, p.first, indent, newline)
    print(io, "=>")
    pprint(io, p.second, indent + 2, false)
end
const s_empty = Symbol("")

function PrettyPrint.pprint_impl(io, scope::Scope, indent, newline)
   pprint(io, Symbol("Scope:"), indent, newline)
   pprint(io, s_empty, indent + 2, true)
   PrettyPrint.pprint_for_seq(io, "freevars{", "}", collect(scope.freevars), indent + 2, true)
   pprint(io, s_empty, indent + 2, true)
   PrettyPrint.pprint_for_seq(io, "bounds{", "}", collect(scope.bounds), indent + 2, true)
   pprint(io, s_empty, indent + 2, true)
   PrettyPrint.pprint_for_seq(io, "cells{", "}", collect(scope.cells), indent + 2, true)
end


@testset "NameResolution.jl" begin
    ann = NR.top_analyzer()
    println("""
    function f(x)
        y = 1 + x
        g -> begin
            y = 2
            y + g
        end
    end
    """)

    enter!(ann, :f)
    is_local!(ann, :x)
    enter!(ann, :x)

    enter!(ann, :y)
    require!(ann, :x)
    lambda = NR.child_analyzer!(ann)

    is_local!(lambda, :g)
    enter!(lambda, :g)

    enter!(lambda, :y)
    require!(lambda, :y)
    require!(lambda, :g)

    abs_interp_on_scopes(ann, VarMap(), VarMap())
    pprint(ann.solved.x)
    println()
    pprint(lambda.solved.x)
    println()

    # Write your own tests here.
end
