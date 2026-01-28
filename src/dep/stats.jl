#==========================================================================
    WEIGHTED SUM
==========================================================================#

function weighted_sum_nonmissing(v::AbstractVector, weights::AbstractVector)
    keep = @. !(ismissing(v) | ismissing(weights) | isnan(v) | isnan(weights))
    dot(v[keep], weights[keep])
end
weighted_sum(v::AbstractVector, weights::AbstractVector; skipmissing::Bool=false) = skipmissing ? weighted_sum_nonmissing(v, weights) : dot(v, weights)



#==========================================================================
    WEIGHTED AVERAGE
==========================================================================#

function weighted_mean_nomissing(v::AbstractVector, weights::AbstractVector)
    keep = @. !(ismissing(v) | ismissing(weights) | isnan(v) | isnan(weights))
    dot(v[keep], weights[keep]) / sum(weights[keep])
end
weighted_mean(v::AbstractVector, weights::AbstractVector; skipmissing::Bool=false) = skipmissing ? weighted_mean_nomissing(v, weights) : dot(v, weights) / sum(weights)



#==========================================================================
    WEIGHTED STANDARD DEVIATION
==========================================================================#

function weighted_std_nomissing(v::AbstractVector, weights::AbstractVector)
    keep = @. !(ismissing(v) | ismissing(weights) | isnan(v) | isnan(weights))
    x = v[keep]
    w = weights[keep]
    isempty(x) && return missing
    μ = weighted_mean(x, w)
    return sqrt(dot(w, (x .- μ).^2) / sum(w))
end
function weighted_std(v::AbstractVector, weights::AbstractVector; skipmissing::Bool=false)
    isempty(v) && return missing
    if skipmissing
        return weighted_std_nomissing(v, weights)
    else
        μ = weighted_mean(v, weights)
        return sqrt(dot(weights, (v .- μ).^2) / sum(weights))
    end
end



#==========================================================================
    WEIGHTED SHARE
==========================================================================#

weighted_share(v::AbstractVector, condition::Function, weights::AbstractVector; kwargs...) = weighted_mean(condition.(v), weights; kwargs...)
weighted_share(v::AbstractVector, condition, weights::AbstractVector; kwargs...) = weighted_share(v, x -> x == condition, weights; kwargs...)