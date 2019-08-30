using Documenter, NameResolution

makedocs(;
    modules=[NameResolution],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/thautwarm/NameResolution.jl/blob/{commit}{path}#L{line}",
    sitename="NameResolution.jl",
    authors="thautwarm",
    assets=String[],
)

deploydocs(;
    repo="github.com/thautwarm/NameResolution.jl",
)
