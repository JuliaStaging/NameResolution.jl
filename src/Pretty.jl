function PrettyPrint.pprint_impl(io, v::LocalVar, indent, newline)
    print(io, "LocalVar($(v.sym), is_mutable=$(v.is_mutable.x), is_shared=$(v.is_shared.x))")
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
