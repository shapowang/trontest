const TronWeb = require('tronweb');
const tokenJson = require('./build/contracts/CraftToken.json');
const gameJson = require('./build/contracts/Sicbo.json');
module.exports.processEnv = {
    gameAddr: "TBM4PPXRXyFJU735RgXvkTQtAjFb5j3qKr",
    tokenAddr: "TCa3NAdUMqfWNcNBYtimuTCkXMf2GuGB4D"
};

const fullNode = new TronWeb.providers.HttpProvider('https://api.shasta.trongrid.io');
const userKey = "ecf8b21fb49c20851f85d66e9f51ff2f56248a9af6bb9456cece36186782e473";
module.exports.userAddr = "TNx43yPrp5mitcnTwUmcVgpuRK7GniAhJT"; //用户
module.exports.miningPoolAddr = "TVdX435jKc6KjoYYdTF4ZjiHizj14U4LX6"; //用户

const tronWeb = new TronWeb(
    fullNode, fullNode, fullNode,
    userKey
);

module.exports.tokenContract = tronWeb.contract(tokenJson.abi, module.exports.processEnv.tokenAddr);
module.exports.gameContract = tronWeb.contract(gameJson.abi, module.exports.processEnv.gameAddr);
module.exports.tronWeb = tronWeb;