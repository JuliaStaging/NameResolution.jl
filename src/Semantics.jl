
#=
=#

function solve_type_param(t, inner_ctx, outer_ctx)
    @match t begin
        Expr(:comparison, a::Symbol, _, b) => begin
            is_local!(inner_ctx, a)
            solve(b, outer_ctx, outer_ctx)
            end

        Expr(:comparison, a, _, b::Symbol, _, c) => begin
            is_local!(inner_ctx, b)
            solve(a, outer_ctx, outer_ctx)
            solve(c, outer_ctx, outer_ctx)
            end
        a => error("syntax: invalid variable expression in $a")
    end
end

function solve_func_sig(func_sig, inner_ctx, outer_ctx)
    @match func_sig begin
        :($a where {$(ts...)}) => begin
            for t in ts
                solve_type_param(t, inner_ctx, outer_ctx)
            end
            solve_func_sig(a, inner_ctx, outer_ctx)
        end
        :($f($(args...))) =>
            let (args, kwargs) = split_args_kwargs(args)
                for t in args
                    solve(t, inner_ctx, outer_ctx)
                end
                for t in kwargs
                    solve(t, inner_ctx, outer_ctx)
                end
                solve_func_name(f, inner_ctx, outer_ctx)
            end
        :($(args...), ) =>
            let (args, kwargs) = split_args_kwargs(args)
                for t in args
                    solve(t, inner_ctx, outer_ctx)
                end
                for t in kwargs
                    solve(t, inner_ctx, outer_ctx)
                end
            end
        :($sig :: $ret_ty) => begin
            solve(ret_ty, outer_ctx, outer_ctx)
            solve_func_sig(sig, inner_ctx, outer_ctx)
        end
        # decl
        head => solve_func_name(head, inner_ctx, outer_ctx)
    end
end

function solve_func_name(name, inner_ctx, outer_ctx)
    @match name begin
        ::Symbol => begin
            assign!(outer_ctx, name)
            assign!(inner_ctx, name)
        end
    end
end

function solve(ast, lhs_ctx, rhs_ctx)
    @match ast begin
        Expr(:function, func_sig, body) => begin
            !body in analyzer
        end
    end
end
