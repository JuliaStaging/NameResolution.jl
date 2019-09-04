using NameResolution
using Test
using PrettyPrint

@testset "share freevar" begin
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

    run_analyzer(ana)
    print("f ")
    pprint(ana.solved)
    println()
    print("lambda ")
    pprint(lambda.solved)
    println()

    @test lambda.solved.freevars[:y] === ana.solved.bounds[:y]
    @test lambda.solved.freevars[:y].is_mutable.x === true
    @test lambda.solved[:kk] === :kk
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

    run_analyzer(ana)
    print("f ")
    pprint(ana.solved)
    println()
    print("lambda ")
    pprint(lambda.solved)
    println()

    @test haskey(lambda.solved.bounds, :y)
    @test lambda.solved.bounds[:y].is_mutable.x === false
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

    run_analyzer(ana)
    print("f ")
    pprint(ana.solved)
    println()
    print("lambda ")
    pprint(lambda.solved)
    println()

    @test haskey(lambda.solved.bounds, :y)
    @test lambda.solved.bounds[:y].is_mutable.x === true
    @test lambda.solved[:y].is_mutable.x === true
end
