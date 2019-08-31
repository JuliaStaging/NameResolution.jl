using NameResolution
using Test
using PrettyPrint

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
    lambda = child_analyzer!(ana)

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
    lambda = child_analyzer!(ana)

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
    lambda = child_analyzer!(ana)

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
