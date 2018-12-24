/*
代币相关测试命令
*/
var config = require('./config.js');
let res;
switch (process.argv[2]) {
    case 'mint':
        res = config.tokenContract.mint(config.miningPoolAddr, 1000000000000000).send().then(function (e) {
            console.log(e);
        });
        console.log(res);
        break;
    case 'bp':
        res = config.tokenContract.balanceOf(config.miningPoolAddr).call().then(function (e) {
            console.log(e);
        });
        console.log(res);
        break;
    case 'bt':
        res = config.tokenContract.balanceOf(config.processEnv.tokenAddr).call().then(function (e) {
            console.log(e);
        });
        console.log(res);
        break;
}