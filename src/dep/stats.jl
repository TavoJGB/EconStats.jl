#==========================================================================
    DEALING WITH MISSING VALUES
==========================================================================#

function _missing_as_zeros(v::AbstractVector, func::Function, args...)
    v_clean = @. ifelse(ismissing(v) | isnan(v), 0, v)
    return func(v_clean, args...)
end


#==========================================================================
    WEIGHTED SUM
==========================================================================#
_weighted_sum(v::AbstractVector, weights::AbstractVector) = dot(v, weights)

function weighted_sum_nonmissing(v::AbstractVector, weights::AbstractVector)
    keep = @. !(ismissing(v) | ismissing(weights) | isnan(v) | isnan(weights))
    return _weighted_sum(v[keep], weights[keep])
end
function weighted_sum(
    v::AbstractVector, weights::AbstractVector;
    skipmissing::Bool=false, missing_as_zeros::Bool=false)
    if skipmissing
        return weighted_sum_nonmissing(v, weights)
    elseif missing_as_zeros
        return _missing_as_zeros(v, _weighted_sum, weights)
    else
        return _weighted_sum(v, weights)
    end
end



#==========================================================================
    WEIGHTED AVERAGE
==========================================================================#

_weighted_mean(v::AbstractVector, weights::AbstractVector) = dot(v, weights) / sum(weights)
function weighted_mean_nomissing(v::AbstractVector, weights::AbstractVector)
    keep = @. !(ismissing(v) | ismissing(weights) | isnan(v) | isnan(weights))
    return _weighted_mean(v[keep], weights[keep])
end
function weighted_mean(v::AbstractVector, weights::AbstractVector; skipmissing::Bool=false, missing_as_zeros::Bool=false)
    if skipmissing
        return weighted_mean_nomissing(v, weights)
    elseif missing_as_zeros
        return _missing_as_zeros(v, _weighted_mean, weights)
    else
        return _weighted_mean(v, weights)
    end
end



#==========================================================================
    WEIGHTED MEDIAN
==========================================================================#

function _weighted_median(v::AbstractVector, weights::AbstractVector)
    isempty(v) && return missing
    sorted_indices = sortperm(v)
    x_sorted = v[sorted_indices]
    w_sorted = weights[sorted_indices]
    cum_weights = cumsum(w_sorted)
    half_total_weight = sum(w_sorted) / 2
    median_index = findfirst(cum_weights .>= half_total_weight)
    return x_sorted[median_index]
end
function weighted_median_nomissing(v::AbstractVector, weights::AbstractVector)
    keep = @. !(ismissing(v) | ismissing(weights) | isnan(v) | isnan(weights))
    return _weighted_median(v[keep], weights[keep])
end
function weighted_median(v::AbstractVector, weights::AbstractVector; skipmissing::Bool=false, missing_as_zeros::Bool=false)
    if skipmissing
        return weighted_median_nomissing(v, weights)
    elseif missing_as_zeros
        return _missing_as_zeros(v, _weighted_median, weights)
    else
        return _weighted_median(v, weights)
    end
end



#==========================================================================
    WEIGHTED STANDARD DEVIATION
==========================================================================#

function _weighted_std(v::AbstractVector, weights::AbstractVector)
    isempty(v) && return missing
    μ = _weighted_mean(v, weights)
    return sqrt(dot(weights, (v .- μ).^2) / sum(weights))
end

function weighted_std_nomissing(v::AbstractVector, weights::AbstractVector)
    keep = @. !(ismissing(v) | ismissing(weights) | isnan(v) | isnan(weights))
    return _weighted_std(v[keep], weights[keep])
end
function weighted_std(v::AbstractVector, weights::AbstractVector; skipmissing::Bool=false, missing_as_zeros::Bool=false)
    if skipmissing
        return weighted_std_nomissing(v, weights)
    elseif missing_as_zeros
        return _missing_as_zeros(v, _weighted_std, weights)
    else
        return _weighted_std(v, weights)
    end
end



#==========================================================================
    WEIGHTED SHARE
==========================================================================#

weighted_share(v::AbstractVector, condition::Function, weights::AbstractVector; kwargs...) = weighted_mean(condition.(v), weights; kwargs...)
weighted_share(v::AbstractVector, condition, weights::AbstractVector; kwargs...) = weighted_share(v, x -> x == condition, weights; kwargs...)