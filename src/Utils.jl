function split_args_kwargs(args)
    @match args begin
        [Expr(:parameters, kwargs...), args...] => begin
                (args, kwargs)
            end
        _ => (args, [])
    end
end