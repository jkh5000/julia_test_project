module NetworkDef

    export Production, Node, Contract, Network, add_node!, remove_node!, add_contract!, remove_contract!, update!
    import Base.println

    # Production
    struct Production
        goods::Int
        money::Int
        interval::Int
    end

    # Node
    mutable struct Node
        name::String
        goods::Int
        money::Int
        production::Union{Production, Nothing}
    end

    println(node::Node) = println("Node $(node.name): goods = $(node.goods), money = $(node.money)")

    update_node!(node::Node, goods::Int, money::Int) = begin
        node.goods += goods
        node.money += money
        #println("Node $(node.name) updated: goods = $(goods), money = $(money)")
        println(node)
    end

    # Contract
    struct Contract
        from::Node
        to::Node
        interval::Int
        time::Int
        amount::Int
        cost::Int
    end

    println(contract::Contract) = println("Contract: from = $(contract.from.name), to = $(contract.to.name), interval = $(contract.interval), time = $(contract.time), amount = $(contract.amount), cost = $(contract.cost)")

    # Transfer
    struct Transfer
        time0::Int
        #position::String
        contract::Contract
    end

    # Network
    mutable struct Network
        nodes::Array{Node, 1}
        contracts::Array{Contract, 1}
        transfers::Array{Transfer, 1}
        clock::Int
    end

    add_node!(network::Network, node::Node) = push!(network.nodes, node)
    remove_node!(network::Network, node::Node) = filter!(x -> x != node, network.nodes)

    add_contract!(network::Network, contract::Contract) = push!(network.contracts, contract)
    remove_contract!(network::Network, contract::Contract) = filter!(x -> x != contract, network.contracts)

    add_transfer!(network::Network, transfer::Transfer) = push!(network.transfers, transfer)
    remove_transfer!(network::Network, transfer::Transfer) = filter!(x -> x != transfer, network.transfers)

    function update!(network::Network)
        println("Clock: $(network.clock)")

        # update nodes (production)
        for node in network.nodes
            if !isnothing(node.production)
                if network.clock % node.production.interval == 0
                    update_node!(node, node.production.goods, node.production.money)
                end
            end
        end

        # update contracts
        for contract in network.contracts
            if network.clock % contract.interval == 0
                transfer = Transfer(network.clock, contract)
                add_transfer!(network, transfer)
                println("Transfer started")
                println(transfer.contract)
            end
        end

        # update transfers
        for transfer in network.transfers
            if network.clock == (transfer.time0 + transfer.contract.time) % typemax(network.clock)
                println("Transfer completed")
                println(transfer.contract)
                update_node!(transfer.contract.from, -transfer.contract.amount, transfer.contract.cost)
                update_node!(transfer.contract.to, transfer.contract.amount, -transfer.contract.cost)
                remove_transfer!(network, transfer)
            end
        end

        network.clock += 1
        network.clock %= typemax(network.clock)
    end

end