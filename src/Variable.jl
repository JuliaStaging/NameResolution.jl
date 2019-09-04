struct Variable
    is_mutable  :: Ref{Bool} # mutability
    is_global   :: Ref{Bool}
    is_shared   :: Ref{Bool} # shared between different physical scopes/actual functions.
    sym         :: Symbol
end

readable_var(sym::Symbol) = Variable(Ref(false), Ref(false), Ref(false), sym)
global_var(sym::Symbol) = Variable(Ref(false), Ref(true), Ref(false), sym)
