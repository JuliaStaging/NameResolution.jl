function PrettyPrint.pp_impl(io, v::LocalVar, indent)
    repr = "LocalVar($(v.sym), is_mutable=$(v.is_mutable.x), is_shared=$(v.is_shared.x))"
    print(io, repr)
    length(repr) + indent
end

Base.show(io::IO, scope :: Scope) = pprint(io, scope)
