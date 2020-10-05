# For once you have the sensitivity by two methods (e.g  both finite-differencing and  AD)
# the code here checks it is correct.
# Goal is to only call `@isapprox` on things that render well

"""
    check_equal(actual, expected; kwargs...)

`@test`'s  that `actual ≈ expected`, but breaks up data such that human readable results
are shown on failures.
All keyword arguments are passed to `isapprox`.
"""
function check_equal(
    actual::Union{AbstractArray{<:Number}, Number},
    expected::Union{AbstractArray{<:Number}, Number};
    kwargs...
)
    @test isapprox(actual, expected; kwargs...)
end

function check_equal(actual::AbstractThunk, expected; kwargs...)
    check_equal(unthunk(actual), expected; kwargs...)
end


function check_equal(
    actual::Union{Composite, AbstractArray},
    expected;
    kwargs...
)
    @test length(actual) == length(expected)
    @testset "$ii" for ii in keys(actual)  # keys works on all Composites
        check_equal(actual[ii], expected[ii]; kwargs...)
    end
end

"""
    check_results(accumulant, actual, expected; kwargs...)

`@test`'s the value of `actual` is approximately equal the `expected`, and that accumulating
it with `ChainRulesCore.add!(accumulant, actual)` also gives correct answer.
All keyword arguments are passed to `isapprox`.
"""
function check_result(accumulant, actual, expected; kwargs...)
    #result
    check_equal(actual, expected; kwargs...)
    # result accumulation
    check_equal(add!!(deepcopy(accumulant), actual), (accumulant + expected); kwargs...)
    # Note, we don't test that the accumulant is actually mutated because it doesn't have to
    # be. e.g. if it is immutable. But we do test that `add!!` returns the right result
    # and that is what people should rely on. The mutation is just to save allocations.
end
