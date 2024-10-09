# taken from juliamanifolds repo

if "--help" ∈ ARGS
    println(
        """
docs/make.jl

Render the `JuliaManifolds` GitHub Organisation Multidocumenter with optional arguments

Arguments
* `--deploy`       - deploy docs to GitHub pages (e.g. on CI)
* `--help`         - print this help and exit without rendering the documentation
* `--serve`        - use `LiveServer.jl` to serve the current docs, also launches the browser
* `--temp`         – clone the other repositories into a temp folder – otherwise use clones/
""",
    )
    exit(0)
end

# ## if docs is not the current active environment, switch to it 
if Base.active_project() != joinpath(@__DIR__, "Project.toml")
    using Pkg
    Pkg.activate(@__DIR__)
    Pkg.resolve()
    Pkg.instantiate()
end

clonedir = ("--temp" in ARGS) ? mktempdir() : joinpath(@__DIR__, "clones")
outpath =  ("--temp" in ARGS) ? mktempdir() : joinpath(@__DIR__, "out")

@info """
Cloning packages into: $(clonedir)
Building aggregate site into: $(outpath)
"""

using MultiDocumenter
using LiveServer
using Documenter
#using DiplodocusDocs


# build local docs but don't deploy
makedocs(
    sitename = "DiplodocusDocs",
    authors = "Christopher Everett",
    modules  = Module[],
    pages=["Home" => "index.md"]
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
        path = "boltzmanncollisionintegral",
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

if "--deploy" in ARGS
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