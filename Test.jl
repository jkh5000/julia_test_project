include("NetworkDef.jl")
using .NetworkDef

function main()
    nodes = [   Node("n1", 1000, 0, Production(10, 0, 25)),
                Node("n2", 0, 50000, nothing),
                Node("n3", 0, 50000, nothing)]

    nw1 = Network(nodes, [], [], 0)

    c1 = Contract(nodes[1], nodes[2], 20, 50, 10, 100)
    c2 = Contract(nodes[1], nodes[3], 10, 20, 20, 200)

    add_contract!(nw1, c1)
    add_contract!(nw1, c2)

    @time begin
        for i in 1:5e2
            update!(nw1)
        end
    end

    println("done")
end

main()