module.exports = {
    networks: {
        development: {
		    host: "10.1.1.50", // BlockChain Server Host
            port: 6789, // RPC_Port
            network_id: "*",
            from: "atp1zkrxx6rf358jcvr7nruhyvr9hxpwv9uncjmns0", //deployer address
            gas: 4612388,
            gasPrice: 1000000000
        }
    },

    // Set default mocha options here, use special reporters etc.
    mocha: {
        // timeout: 100000
    },

    // Configure your compilers
    compilers: {
        solc: {
            version: "0.5.17", // Fetch exact version from solc-bin (default: truffle's version)
            // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
            settings: { // See the solidity docs for advice about optimization and evmVersion
                optimizer: {
                    enabled: true,
                    runs: 200
                },
                //  evmVersion: "byzantium"
            }
        }
    }
}
