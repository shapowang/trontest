var CraftToken = artifacts.require("./CraftToken.sol");
var CraftDice = artifacts.require("./MapInMap.sol");
var cftMinerAddr = "TVdX435jKc6KjoYYdTF4ZjiHizj14U4LX6";

module.exports = function (deployer) {
    deployer.deploy(CraftToken, "CraftToken", "CFT", 6, "10000000000000000").then(function () {
       // console.dir(CraftToken);
        deployer.deploy(CraftDice, CraftToken.address, cftMinerAddr, {
            fee_limit: 1e9,
            userFeePercentage: 1,
            originEnergyLimit: 1e7
        }).catch(function (e) {
            console.log(e);
        });
    });
};