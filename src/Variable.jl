struct Variable
    is_mutable  :: Ref{Bool} # mutability
    is_global   :: Ref{Bool}
    sym         :: Symbol
end

MLStyle.Record.@as_record Variable
readable_var(sym::Symbol) = Variable(Ref(false), Ref(false), sym)
global_var(sym::Symbol) = Variable(Ref(false), Ref(true), sym)
