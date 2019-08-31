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
   PrettyPrint.pprint_for_seq(io, "globals{", "}", collect(scope.globals), indent + 2, true)
end


@testset "NameResolution.jl" begin
    ann = NR.top_analyzer()
    println("""
    function f(x)
        y = 1 + x
        g -> y + g
    end
    """)

    assign!(ann, :f)
    assign!(ann, :x)
    assign!(ann, :y)
    require!(ann, :y)
    lambda = NR.child_analyzer!(ann)
    assign!(lambda, :g)
    require!(lambda, :y)
    is_global!(lambda, :y)
    NR.resolve_scope!(ann)
    pprint(ann.solved.x)
    println()
    pprint(lambda.solved.x)
    println()

    # Write your own tests here.
end
