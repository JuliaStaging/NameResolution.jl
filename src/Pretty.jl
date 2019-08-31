function PrettyPrint.pprint_impl(io, v::Variable, indent, newline)
    print(io, "Variable($(v.sym), is_mutable=$(v.is_mutable.x), is_global=$(v.is_global.x))")
end

function PrettyPrint.pprint_impl(io, p::Pair, indent, newline)
    pprint(io, p.first, indent, newline)
    print(io, "=>")
    pprint(io, p.second, indent + 2, false)
end

function PrettyPrint.pprint_impl(io, d::Dict, indent, newline)
   PrettyPrint.pprint_for_seq(io, "{", "}", collect(d), indent, newline)
end

Base.show(io::IO, scope :: Scope) = pprint(io, scope)
