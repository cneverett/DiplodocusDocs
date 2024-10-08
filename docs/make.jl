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


#= deploydocs(
    repo="github.com/cneverett/DiplodocusDocs",    
    target = "build",
    branch = "gh-pages",
    devbranch = "main"
    #devurl = "dev",
    #versions = ["stable" => "v^", "v#.#"]
) =#

if "deploy" in ARGS
    @warn "Deploying to GitHub" ARGS
    gitroot = normpath(joinpath(@__DIR__, ".."))
    run(`git pull`)
    outbranch = "gh-pages"
    has_outbranch = true
    if !success(`git checkout $outbranch`)
        has_outbranch = false
        if !success(`git switch --orphan $outbranch`)
            @error "Cannot create new orphaned branch $outbranch."
            exit(1)
        end
    end
    for file in readdir(gitroot; join = true)
        endswith(file, ".git") && continue
        rm(file; force = true, recursive = true)
    end
    for file in readdir(outpath)
        cp(joinpath(outpath, file), joinpath(gitroot, file))
    end
    run(`git add .`)
    if success(`git commit -m 'Aggregate documentation'`)
        @info "Pushing updated documentation."
        if has_outbranch
            run(`git push`)
        else
            run(`git push -u origin $outbranch`)
        end
        run(`git checkout main`)
    else
        @info "No changes to aggregated documentation."
    end
else
    @info "Skipping deployment, 'deploy' not passed. Generated files in docs/out." ARGS
    cp(outpath, joinpath(@__DIR__, "out"), force = true)
end