push!(LOAD_PATH,"../src/")
using Documenter, DiplodocusDocs

makedocs(
    sitename = "DiplodocusDocs",
    authors = "Christopher Everett",
    modules  = Module[],
    pages=["Home" => "index.md"]
)


deploydocs(
    repo="github.com/cneverett/DiplodocusDocs.git",    
    target = "build",
    branch = "gh-pages",
    devbranch = "main",
    devurl = "dev",
    versions = ["stable" => "v^", "v#.#"]
)