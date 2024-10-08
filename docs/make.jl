push!(LOAD_PATH,"../src/")

clonedir = ("--temp" in ARGS) ? mktempdir() : joinpath(@__DIR__, "clones")
outpath =  ("--temp" in ARGS) ? mktempdir() : joinpath(@__DIR__, "out")

@info """
Cloning packages into: $(clonedir)
Building aggregate site into: $(outpath)
"""

using Documenter
using DiplodocusDocs
using MultiDocumenter


# build local docs but don't deploy
makedocs(
    sitename = "DiplodocusDocs",
    authors = "Christopher Everett",
    modules  = Module[],
    clean = true,
    doctest = false,
    pages=["Home" => "index.md"],
    checkdocs = :export
)

# build MultiDocs - one for each package
docs = [
    MultiDocumenter.MultiDocRef(
        upstream = joinpath(@__DIR__,"build"),
        path = "diplodocusdocs",
        name = "Home",
        fix_canonical_url = false,
    ),
    MultiDocumenter.MultiDocRef(
        upstream = joinpath(clonedir, "BoltzmannCollisionIntegral.jl"),
        path = "boltzmanncollisionintegrale",
        name = "BoltzmannCollisionIntegral.jl",
        giturl = "https://github.com/cneverett/BoltzmannCollisionIntegral.jl.git",
    )
]

# build docs
MultiDocumenter.make(
    outpath,
    docs;
    assets_dir = "docs/src/assets",
    search_engine = MultiDocumenter.SearchConfig(
        index_versions = ["stable"],
        engine = MultiDocumenter.FlexSearch
    ),
)


deploydocs(
    repo="github.com/cneverett/DiplodocusDocs",    
    target = "build",
    branch = "gh-pages",
    devbranch = "main"
    #devurl = "dev",
    #versions = ["stable" => "v^", "v#.#"]
)