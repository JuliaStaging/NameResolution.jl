struct LocalVar
    is_mutable  :: Ref{Bool} # mutability
    is_shared   :: Ref{Bool} # shared between different physical scopes/actual functions.
    sym         :: Symbol
end

GlobalVar = Symbol

readable_var(sym::Symbol) = LocalVar(Ref(false), Ref(false), sym)
global_var(sym::Symbol) = sym
