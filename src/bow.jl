import Base: +, -, *, /, ==, transpose, zero
import LinearAlgebra: dot, norm, normalize!
import SimilaritySearch: cosine_distance, angle_distance
export BOW, compute_bow, add!

# const BOW = Dict{Symbol,Int}
const BOW = Dict{Symbol,Float64}

"""
    compute_bow(tokenlist::AbstractVector{Symbol}, voc::BOW)::Tuple{BOW,Float64}

Updates a BOW using the given list of tokens
"""
function compute_bow(tokenlist::AbstractVector{Symbol}, voc::BOW)
    maxfreq = 0.0
    for sym in tokenlist
        m = get(voc, sym, 0.0) + 1.0
        voc[sym] = m
        maxfreq = max(m, maxfreq)
    end

    voc, maxfreq
end

# these are needed to call `compute_bow` for symbol's list but also for simplicity of the API
compute_bow(tokenlist::AbstractVector{Symbol}) = compute_bow(tokenlist, BOW())

"""
    normalize!(bow::BOW)

Inplace normalization of `bow`
"""
function normalize!(bow::BOW)
    s = 1.0 / norm(bow)
    for (k, v) in bow
        bow[k] = v * s
    end

    bow
end

function normalize!(matrix::AbstractVector{BOW})
    for bow in matrix
        normalize!(bow)
    end
end

function dot(a::BOW, b::BOW)
    if length(b) < length(a)
        a, b = b, a  # a must be the smallest bow
    end
    
    s = 0.0
    for (k, v) in a
        w = get(b, k, 0.0)
        s += v * w
    end

    s
end

function norm(a::BOW)::Float64
    s = 0.0
    for w in values(a)
        s += w * w
    end

    sqrt(s)
end

function zero(::Type{BOW})
    BOW()
end

## inplace sum
function add!(a::BOW, b::BOW)
    for (k, w) in b
        if w != 0.0
            a[k] = get(a, k, 0.0) + w
        end
    end

    a
end

function add!(a::BOW, b::Pair)
    k, w = b
    a[k] = get(a, k, 0.0) + w
    a
end

## sum
function +(a::BOW, b::BOW)
    if length(a) < length(b) 
        a, b = b, a  # a must be the largest bow
    end
    
    c = copy(a)
    for (k, w) in b
        if w != 0.0
            c[k] = get(c, k, 0.0) + w 
        end
    end

    c
end

function +(a::BOW, b::Pair)
    c = copy(a)
    add!(c, b)
end

## definitions for substraction
function -(a::BOW, b::BOW)    
    c = copy(a)
    for (k, w) in b
        if w != 0.0
            c[k] = get(c, k, 0.0) - w 
        end
    end

    c
end

## definitions for product

function *(a::BOW, b::BOW)
    if length(b) < length(a)
        a, b = b, a  # a must be the smallest bow
    end
    
    c = copy(a)
    for k in keys(a)
        w = get(b, k, 0.0)
        if w == 0.0
            delete!(c, k)
        else
            c[k] *= w
        end
    end

    c
end

function *(a::BOW, b::F) where F <: Real
    c = copy(a)
    for (k, v) in a
        c[k] = v * b
    end

    c
end

function *(b::F, a::BOW) where F <: Real
    a * b
end

function /(a::BOW, b::F) where F <: Real
    c = copy(a)
    for (k, v) in a
        c[k] = v / b
    end

    c
end

"""
cosine_distance

Computes the cosine_distance between two weighted bags

It supposes that bags are normalized (see `normalize!` function)

"""
function cosine_distance(a::BOW, b::BOW)::Float64
    return 1.0 - dot(a, b)
end

"""
angle_distance

Computes the angle  between two weighted bags

It supposes that all bags are normalized (see `normalize!` function)

"""
function angle_distance(a::BOW, b::BOW)
    d = dot(a, b)

    if d <= -1.0
        return π
    elseif d >= 1.0
        return 0.0
    elseif d == 0  # turn around for zero vectors, in particular for denominator=0
        return π_2
    else
        return acos(d)
    end
end

function cosine(a::BOW, b::BOW)::Float64
    return dot(a, b) # * a.invnorm * b.invnorm # it is already normalized
end