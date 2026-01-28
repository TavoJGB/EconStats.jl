module EconStats

    BASE_FOLDER = dirname(@__DIR__)

    # External dependencies
    using StatsBase         # weighted mean etc.
    using StatsBase: dot
        export mean, std, median, dot, quantile

    # Package dependencies
    include(joinpath(BASE_FOLDER, "src", "dep", "stats.jl"))
        export weighted_sum, weighted_mean, weighted_std, get_share
    
end
