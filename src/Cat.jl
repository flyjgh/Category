import Base: +, :, *
# -----------------------------------------------------------------
# Type Algebra
+(αs::Vararg{Type}) = Union{αs...}
*(αs::Vararg{Type}) = Tuple{αs...}
×(α::Tuple{Vararg{Type}},β) = (α...,β)
→(α::Type,β::Type) = Tuple{α,β}
→(α::Type,ρ::Type{γ}) where {γ<:Tuple} = Tuple{α,fieldtypes(ρ)...}
const _₀ = Any

# -----------------------------------------

(⇀)(ƒ,x...) = (y...) -> ƒ(x..., y...)

# -----------------------------------------
# f : A → B
struct Arrow{α,β}
    λ
end

Arrow(ƒ, A::α, B::β) where {α,β} = Arrow{A,B}(ƒ)
Arrow(ƒ, A) = Arrow(ƒ, *(fieldtypes(A)[begin:end-1]...), fieldtypes(A)[end])

(ƒ::Arrow{α,β})(x::α) where {α,β} = ƒ.λ(x)::β
(ƒ::Arrow{α,β})(x::γ) where {α<:Tuple,β,γ<:α} = ƒ.λ(x...)::β
(ƒ::Arrow{α,β})(x...) where {α,β} = ƒ(x::α)

function(ƒ::Arrow{α,β})(x) where {α<:Tuple,β}
    x::fieldtypes(α)[begin]
    length(x) == length(fieldtypes(α)) && return ƒ.λ(x...)::β
    length(x) == length(fieldtypes(α)) - 1 ?
        Arrow(⇀(ƒ,x), fieldtypes(α)[end], β) :
        Arrow(⇀(ƒ,x), *(fieldtypes(α)[begin+1:end]...), β)
end

function (ƒ::Arrow{α,β})(x...) where {α<:Tuple,β}
    x::*(fieldtypes(α)[begin:length(x)]...)
    length(x) == length(fieldtypes(α)) && return ƒ(x)
    length(x) == length(fieldtypes(α)) - 1 ?
        Arrow(⇀(ƒ,x...), fieldtypes(α)[end], β) :
        Arrow(⇀(ƒ,x...), *(fieldtypes(α)[length(x)+1:end]...), β)
end

Base.show(io::IO, x::Arrow{α,β}) where {α,β} = print(io, string(α) * " → " * string(β))
Base.show(io::IO, x::Arrow{α,β}) where {α<:Tuple,β} = print.(Ref(io), .*(string.(fieldtypes(α)), " → ")..., string(β))

(:)(ƒ,α::Type{γ}) where {γ <: Tuple} = Arrow(ƒ,α)
(:)(α::Type{γ},ƒ) where {γ <: Tuple} = Arrow(ƒ,α)
(:)(α::Arrow{ρ,σ},ƒ) where {ρ,σ} = Arrow{ρ,σ}(ƒ)

↑(α,ρ::Type) = α(ρ)
↑(α,ρ::Type{γ}) where {γ<:Tuple} = Tuple{α.(fieldtypes(ρ))...}
↑(α,ρ::Arrow{β,γ}) where {β,γ} = Arrow{Tuple{α.(fieldtypes(β))...},α(γ)}(ρ.λ)

# -----------------------------------------

Maybe(α::Type) = α + Nothing
Either(α::Type,β::Type) = α + β

# -----------------------------------------

