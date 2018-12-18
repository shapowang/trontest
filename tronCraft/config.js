const TronWeb = require('tronweb');
const tokenJson = require('./build/contracts/CraftToken.json');
const processEnv = {
    diceAddr: "TCY2squ2SubQLyn76h3K7EgM8FThwnSyEE",
    tokenAddr: "TJEH8xmvGHZLsgxiEizLftLfDBKB6hckas",
    slotsAddr: "THZqhWzTAzRUxb6J5knqUqZxurZG7C3qjz"
};

const fullNode = new TronWeb.providers.HttpProvider('https://api.shasta.trongrid.io');
const userKey = "ecf8b21fb49c20851f85d66e9f51ff2f56248a9af6bb9456cece36186782e473";
const userAddr = "TNx43yPrp5mitcnTwUmcVgpuRK7GniAhJT"; //用户
const miningPoolAddr = "TVdX435jKc6KjoYYdTF4ZjiHizj14U4LX6"; //用户

const tronWeb = new TronWeb(
    fullNode, fullNode, fullNode,
    userKey
);

let tokenContract = tronWeb.contract(tokenJson.abi, processEnv.tokenAddr);

// let cft = tokenContract.mint(miningPoolAddr, 1000000000000000).send().then(function (e) {
//     console.log(e);
// });
// console.log(cft);

let cft = tokenContract.balanceOf(miningPoolAddr).call().then(function (e) {
    console.log(e);
});
console.log(cft);

cft = tokenContract.balanceOf(processEnv.tokenAddr).call().then(function (e) {
    console.log(e);
});
console.log(cft);
//
// async function transfer() {
//     await tokenContract.transferFromByCraft(userAddr, miningPoolAddr, 1000000, 1000000).send().then(function (e) {
//         console.log(e);
//     });
//     let cft = await tokenContract.balanceOf(userAddr).call();
//     console.log(cft);
//     let cft1 = await tokenContract.balanceOf(miningPoolAddr).call();
//     console.log(cft1);
// }
//
// transfer();