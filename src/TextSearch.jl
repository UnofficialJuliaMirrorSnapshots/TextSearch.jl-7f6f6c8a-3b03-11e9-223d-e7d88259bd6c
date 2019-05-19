module TextSearch
    import Base: broadcastable
    include("textconfig.jl")
    include("bow.jl")
    include("svec.jl")
    include("io.jl")
    include("basicmodels.jl")
    include("distmodel.jl")
    include("entmodel.jl")
    include("invindex.jl")
    include("rocchio.jl")
end
