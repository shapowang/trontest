let cft = tokenContract.mint(miningPoolAddr, 1000000000000000).send().then(function (e) {
    console.log(e);
});
console.log(cft);

let cft = tokenContract.balanceOf(miningPoolAddr).call().then(function (e) {
    console.log(e);
});
console.log(cft);

cft = tokenContract.balanceOf(processEnv.tokenAddr).call().then(function (e) {
    console.log(e);
});
console.log(cft);