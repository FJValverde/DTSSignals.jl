using Documenter
using DTSSignals

push!(LOAD_PATH,"../src/")
makedocs(
    sitename = "DTSSignals -- Package Documentation",
    pages = [
            "Index" => "index.md",
            "An other page" => "anotherPage.md",# FVA: Why this page specifically
    ],
    format = Documenter.HTML(prettyurls = false),
    modules = [DTSSignals]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo ="github.com/FJValverde/DTSSignals.jl.git",
    devbranch = "main"
)
