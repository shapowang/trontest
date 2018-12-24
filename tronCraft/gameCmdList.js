/*
代币相关测试命令
*/
var config = require('./config.js');
let res;
switch (process.argv[2]) {
    case 'start':
        res = config.gameContract.betStart().send().then(function (e) {
            console.log(e);
        });
        console.log(res);
        break;
    case 'getRunning':
        res = config.gameContract.getRunning().call().then(function (e) {
            console.log(e);
        });
        console.log(res);
        break;
    case 'stop':
        res = config.gameContract.betStop().send().then(function (e) {
            console.log(e);
        });
        console.log(res);
        break;
    case 'bet':
        res = config.gameContract.bet(1).send({
            callValue: 1000000,
            shouldPollResponse: false
        }).then(function (e) {
            console.log(e);
        }).catch(function (e) {
            console.log(e);
        });
        console.log(res);
        break;
    case 'open':
        res = config.gameContract.open().send().then(function (e) {
            console.log(e);
        });
        console.log(res);
        break;
    case 'lottery':
        res = config.gameContract.lotteryOpen(5).send().then(function (e) {
            console.log(e);
        });
        console.log(res);
        break;
    case 'updateMinerCFTAddr':
        let result = tokenContract.updateMinerCFTAddr("TVdX435jKc6KjoYYdTF4ZjiHizj14U4LX6").send({shouldPollResponse: true}).then(function (e) {
            console.log(e);
        });
        console.log(result);
        break;
}