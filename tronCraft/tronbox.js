module.exports = {
  networks: {
    development: {
// For trontools/quickstart docker image
      privateKey: 'da146374a75310b9666e834ee4ad0866d6f4035967bfc76217c5a495fff9f0d0',
      consume_user_resource_percent: 1,
      origin_energy_limit: 1e7,
      fee_limit: 1e9,

      // Requires TronBox 2.1.9+ and Tron Quickstart 1.1.16+
      // fullHost: "http://127.0.0.1:9090",

      // The three settings below for TronBox < 2.1.9
      fullNode: "http://127.0.0.1:8090",
      solidityNode: "http://127.0.0.1:8091",
      eventServer: "http://127.0.0.1:8092",

      network_id: "*"
    },
    mainnet: {
// Don't put your private key here:
      privateKey: process.env.PK,
      /*
      Create a .env file (it must be gitignored) containing something like

        export PK=4E7FECCB71207B867C495B51A9758B104B1D4422088A87F4978BE64636656243

      Then, run the migration with:

        source .env && tronbox migrate --network mainnet

      */
      consume_user_resource_percent: 1,
      // userFeePercentage:0,
      origin_energy_limit: 1e7,
      fee_limit: 1e9,

      // tronbox 2.1.9+
      fullHost: "https://api.trongrid.io",

      // tronbox < 2.1.9
      // fullNode: "https://api.trongrid.io",
      // solidityNode: "https://api.trongrid.io",
      // eventServer: "https://api.trongrid.io",

      network_id: "*"
    },
    shasta: {
      privateKey: "ecf8b21fb49c20851f85d66e9f51ff2f56248a9af6bb9456cece36186782e473",
      consume_user_resource_percent: 1,
      origin_energy_limit: 1e7,
      fee_limit: 1e9,
      // tronbox 2.1.9+
      fullHost: "https://api.shasta.trongrid.io",
      network_id: "*"
    }
  }
}
