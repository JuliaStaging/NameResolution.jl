Base.show(io::IO, v::LocalVar) = begin
    print(io, "LocalVar($(v.sym), is_mutable=$(v.is_mutable.x), is_shared=$(v.is_shared.x))")
end

PrettyPrint.is_atom_t(::Type{LocalVar}) = true

Base.show(io::IO, scope :: Scope) = pprint(io, scope)
