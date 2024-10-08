push!(LOAD_PATH,"../src/")
using Documenter
using DiplodocusDocs

makedocs(
    sitename = "DiplodocusDocs",
    authors = "Christopher Everett",
    modules  = Module[],
    pages=["Home" => "index.md"],
    checkdocs = :export
)


deploydocs(
    repo="github.com/cneverett/DiplodocusDocs",    
    target = "build",
    branch = "gh-pages",
    devbranch = "main"
    #devurl = "dev",
    #versions = ["stable" => "v^", "v#.#"]
)