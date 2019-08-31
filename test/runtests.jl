using NameResolution
using Test
using PrettyPrint

NR = NameResolution

function PrettyPrint.pprint_impl(io, v::Variable, indent, newline)
    print(io, "Variable($(v.sym), is_mutable=$(v.is_mutable.x), is_global=$(v.is_global.x))")
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


@testset "freevar" begin
    println("""test case:
    function f(x)
        y = 1 + x
        g -> begin
            y = 2
            y + g
        end
    end
    """)
    ana = top_analyzer()
    enter!(ana, :f)
    is_local!(ana, :x)
    enter!(ana, :x)

    enter!(ana, :y)
    require!(ana, :x)
    lambda = NR.child_analyzer!(ana)

    is_local!(lambda, :g)
    enter!(lambda, :g)

    enter!(lambda, :y)
    require!(lambda, :y)
    require!(lambda, :g)

    abs_interp_on_scopes(ana, VarMap(), VarMap())
    print("f ")
    pprint(ana.solved.x)
    println()
    print("lambda ")
    pprint(lambda.solved.x)
    println()

    @test lambda.solved.x.freevars[:y] === ana.solved.x.cells[:y]
    @test lambda.solved.x.freevars[:y].is_mutable.x === true
end


@testset "local" begin
    println("""test case:
    function f(x)
        y = 1 + x
        g -> begin
            local y = 2
            y + g
        end
    end
    """)
    ana = top_analyzer()
    enter!(ana, :f)
    is_local!(ana, :x)
    enter!(ana, :x)

    enter!(ana, :y)
    require!(ana, :x)
    lambda = NR.child_analyzer!(ana)

    is_local!(lambda, :g)
    enter!(lambda, :g)

    is_local!(lambda, :y)
    enter!(lambda, :y)
    require!(lambda, :y)
    require!(lambda, :g)

    abs_interp_on_scopes(ana, VarMap(), VarMap())
    print("f ")
    pprint(ana.solved.x)
    println()
    print("lambda ")
    pprint(lambda.solved.x)
    println()

    @test haskey(lambda.solved.x.bounds, :y)
    @test lambda.solved.x.bounds[:y].is_mutable.x === false
end


@testset "local + mutable" begin
    println("""test case:
    function f(x)
        y = 1 + x
        g -> begin
            local y = 2
            y += 1
            y + g
        end
    end
    """)
    ana = top_analyzer()
    enter!(ana, :f)
    is_local!(ana, :x)
    enter!(ana, :x)

    enter!(ana, :y)
    require!(ana, :x)
    lambda = NR.child_analyzer!(ana)

    is_local!(lambda, :g)
    enter!(lambda, :g)

    is_local!(lambda, :y)
    enter!(lambda, :y)
    enter!(lambda, :y)
    require!(lambda, :y)
    require!(lambda, :g)

    abs_interp_on_scopes(ana, VarMap(), VarMap())
    print("f ")
    pprint(ana.solved.x)
    println()
    print("lambda ")
    pprint(lambda.solved.x)
    println()

    @test haskey(lambda.solved.x.bounds, :y)
    @test lambda.solved.x.bounds[:y].is_mutable.x === true
end