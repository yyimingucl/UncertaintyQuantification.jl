###
#   Computing the probabilty of failure of the cantilever beam.
#
#       Before running you must:
#       julia:> include("src/UncertaintyQuantification.jl")
#       julia:> using Main.UncertaintyQuantification
#
###


l = Parameter(1.8, "l")
b = Parameter(0.12, "b")

h = RandomVariable(Normal(0.24, 0.01), "h")
E = RandomVariable(
    LogNormal(
        log(10e9^2 / sqrt(1.6e9 + 10e9^2)),
        sqrt(log(1.6e9 / 10e9^2 + 1)),
    ),
    "E",
)

P = RandomVariable(
    LogNormal(log(5000^2 / sqrt(400 + 5000^2)), sqrt(log(400 / 5000^2 + 1))),
    "P",
)
rho = RandomVariable(
    LogNormal(log(600^2 / sqrt(140 + 600^2)), sqrt(log(140 / 600^2 + 1))),
    "rho",
)

rvset = RandomVariableSet([P rho], [1 0.8; 0.8 1])

inertia = Model(df -> df.b .* df.h .^ 3 / 12, "I")

displacement = Model(
    df -> (df.rho .* 9.81 .* df.b .* df.h .* df.l .^ 4) ./
          (8 .* df.E .* df.I) .+ (df.P .* df.l .^ 3) ./ (3 .* df.E .* df.I),
    "w",
)

mc = MonteCarlo(100000)
max_displacement = 0.01

pf, samples = probabilityOfFailure(
    [inertia, displacement],
    df -> max_displacement .- df.w,
    [l, b, h, E, rvset],
    mc,
)

println("Probability of failure: ", pf)
