/*
代币相关测试命令
*/
var config = require('./config.js');
var $ = require('jquery');
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
    case 'userList':
        res = config.gameContract.getLotteryUserList().call().then(function (e) {
            console.log(e);
        }).catch(function (e) {
            console.log(e);
        });
        console.log(res);
        break;
    case 'cursor':
        res = config.gameContract.getRecentAddressCursor().call().then(function (e) {
            console.log(e);
        }).catch(function (e) {
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
    case 'betList':
        res = config.gameContract.getBetList().call().then(function (e) {
            console.log(e);
        }).catch(function (e) {
            console.log(e);
        });
        console.log(res);
        break;
    case 'va':
        res = config.gameContract.getVA().call().then(function (e) {
            console.log(e);
        }).catch(function (e) {
            console.log(e);
        });
        console.log(res);
        break;
    case 'vb':
        res = config.gameContract.getVB().call().then(function (e) {
            console.log(e);
        }).catch(function (e) {
            console.log(e);
        });
        console.log(res);
        break;
    case 'listen':
        res = config.gameContract.getEventResult(
            contractAddress = config.gameContract.address,
            sinceTimestamp = 1545639755835,
            eventName = "LogBet",
            size = 20, page = 1).then(function (e) {
            console.log(e);
        }).catch(function (e) {
            console.log(e);
        });
        console.log(res);
        break;
    case 'betDetail':
        res = config.gameContract.getEventByTransactionID("af467673f9b56c9dbcdd00311b71e119471af957364867e7ac7293e357830a74").then(function (e) {
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
        let result = config.gameContract.updateMinerCFTAddr("TVdX435jKc6KjoYYdTF4ZjiHizj14U4LX6").send({shouldPollResponse: true}).then(function (e) {
            console.log(e);
        });
        console.log(result);
        break;
}
var a  = config.tronWeb.trx.getTransactionInfo("850b49cadc44421e644b408ad364ef2344cd5c891ff6e55c81ea6db040dc1d8a").then(function (e) {
    console.log(e);
});
console.log(a);