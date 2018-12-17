const TronWeb = require('tronweb');
const dice = require('./build/contracts/CraftDice.json');
const slots = require('./build/contracts/CraftSlots.json');
const token = require('./build/contracts/CraftToken.json');
const HttpProvider = TronWeb.providers.HttpProvider;

let fullNode;
let solidityNode;
let eventServer;
let processEnv = {
    dev: "testnet",
    dice: "TCY2squ2SubQLyn76h3K7EgM8FThwnSyEE",
    token: "TJEH8xmvGHZLsgxiEizLftLfDBKB6hckas",
    slots: "THZqhWzTAzRUxb6J5knqUqZxurZG7C3qjz"
};

if (processEnv.dev == 'local') {
    fullNode = new HttpProvider('http://127.0.0.1:8090');
    solidityNode = new HttpProvider('http://127.0.0.1:8091');
    eventServer = 'http://127.0.0.1:8092';
} else if (processEnv.dev == 'testnet') {
    fullNode = new HttpProvider('https://api.shasta.trongrid.io');
    solidityNode = new HttpProvider('https://api.shasta.trongrid.io');
    eventServer = 'https://api.shasta.trongrid.io';
}

//abi
const craftDiceAbi = dice.abi;
const craftSlotsAbi = slots.abi;
const craftTokenAbi = token.abi;


//address
const craftDiceAddr = processEnv.dice;
const craftSlotsAddr = processEnv.slots;
const craftTokenAddr = processEnv.token;


const userKey = "ecf8b21fb49c20851f85d66e9f51ff2f56248a9af6bb9456cece36186782e473";
const userAddr = "TNx43yPrp5mitcnTwUmcVgpuRK7GniAhJT"; //用户


const tronWeb = new TronWeb(
    fullNode,
    solidityNode,
    eventServer,
    userKey
);

let tIdArray = {};

//monitor or res
var monitor = processEnv.monitor;

async function updateMinerAddr() {
    let craftDice = await tronWeb.contract(craftDiceAbi, craftDiceAddr);
    let craftSlots = await tronWeb.contract(craftSlotsAbi, craftSlotsAddr);

    console.log("修改MinerAddr");
    await craftDice.updateMinerCFTAddr(cftMinerAddr).send({shouldPollResponse: true});
    await craftSlots.updateMinerCFTAddr(cftMinerAddr).send({shouldPollResponse: true});
    console.log("+++++++++++++++++++++++++++++++++++");
}

async function bet() {
    let craftDice = await tronWeb.contract(craftDiceAbi, craftDiceAddr);
    let craftToken = await tronWeb.contract(craftTokenAbi, craftTokenAddr);
    console.log("掷骰子：用户开始下注TRX");
    let balance = await tronWeb.trx.getBalance(userAddr);
    console.log('用户下注前TRX:', tronWeb.fromSun(balance));
    let cft = await craftToken.balanceOf(userAddr).call();
    console.log('用户下注前CFT:', tronWeb.fromSun(cft.toNumber()));
    // let approveCFT = await craftToken.allowance(cftMinerAddr,craftDiceAddr).call();
    // console.log("掷骰子合约被授权平台币数量：",approveCFT.toNumber());
    let result;
    if (monitor == 0) {
        result = await craftDice.bet(80).send({
            callValue: tronWeb.toSun(210),
            shouldPollResponse: true
        }).catch(function (err) {
            console.log(err);
            process.exit();
        });
        console.log("掷骰子TRX下注：", result);
    } else {
        result = await craftDice.bet(80).send({
            callValue: tronWeb.toSun(210)
        }).catch(function (err) {
            console.log(err);
            process.exit();
        });
        console.log("掷骰子TRX下注：", result);
        tIdArray._bet = result;
    }
    balance = await tronWeb.trx.getBalance(userAddr);
    console.log('用户下注后TRX:', tronWeb.fromSun(balance));
    cft = await craftToken.balanceOf(userAddr).call();
    console.log('用户下注后CFT:', tronWeb.fromSun(cft.toNumber()));
}


async function betSlots() {
    let craftSlots = await tronWeb.contract(craftSlotsAbi, craftSlotsAddr);
    let craftToken = await tronWeb.contract(craftTokenAbi, craftTokenAddr);

    console.log("水果机游戏：用户开始下注TRX");
    let balance = await tronWeb.trx.getBalance(userAddr);
    console.log('用户下注前TRX:', tronWeb.fromSun(balance));
    let cft = await craftToken.balanceOf(userAddr).call();
    console.log('用户下注前CFT:', tronWeb.fromSun(cft.toNumber()));

    var stakeArray = [0, 0, tronWeb.toSun(1), 0, 0, tronWeb.toSun(1), 0];
    var bitRecord = "0,0,1,0,0,1,0";

    let result;
    if (monitor == 0) {
        result = await craftSlots.bet(stakeArray, bitRecord).send({
            callValue: tronWeb.toSun(2),
            shouldPollResponse: true
        }).catch(function (err) {
            console.log(err);
            process.exit();
        });
        console.log("水果机TRX下注：", result);
        console.log("下注结果-索引", result._randType.toNumber());
        console.log("下注结果", result._res);
    } else {
        result = await craftSlots.bet(stakeArray, bitRecord).send({
            callValue: tronWeb.toSun(2)
        }).catch(function (err) {
            console.log(err);
            process.exit();
        });
        console.log("水果机TRX下注：", result);
        tIdArray._betSlots = result;
    }


    balance = await tronWeb.trx.getBalance(userAddr);
    console.log('用户下注后TRX:', tronWeb.fromSun(balance));
    cft = await craftToken.balanceOf(userAddr).call();
    console.log('用户下注后CFT:', tronWeb.fromSun(cft.toNumber()));
}

async function betByCFT() {
    let craftDice = await tronWeb.contract(craftDiceAbi, craftDiceAddr);
    let craftToken = await tronWeb.contract(craftTokenAbi, craftTokenAddr);

    console.log("掷骰子：用户开始下注CFT");
    let balance = await tronWeb.trx.getBalance(userAddr);
    console.log('用户下注前TRX:', tronWeb.fromSun(balance));
    let cft = await craftToken.balanceOf(userAddr).call();
    console.log('用户下注前CFT:', tronWeb.fromSun(cft.toNumber()));
    cft = await craftToken.balanceOf(craftDiceAddr).call();
    console.log("掷骰子合约下注前CFT:", tronWeb.fromSun(cft.toNumber()));

    let result;
    if (monitor == 0) {
        result = await craftDice.betByCFT(30, tronWeb.toSun(1)).send({
            shouldPollResponse: true
        }).catch(function (err) {
            console.log(err);
            process.exit();
        });
        console.log("掷骰子CFT下注：", result);
    } else {
        result = await craftDice.betByCFT(30, tronWeb.toSun(1)).send({}).catch(function (err) {
            console.log(err);
            process.exit();
        });
        console.log("掷骰子CFT下注：", result);
        tIdArray._betByCFT = result;
    }

    balance = await tronWeb.trx.getBalance(userAddr);
    console.log('用户下注后TRX:', tronWeb.fromSun(balance));
    cft = await craftToken.balanceOf(userAddr).call();
    console.log('用户下注后CFT:', tronWeb.fromSun(cft.toNumber()));
    cft = await craftToken.balanceOf(craftDiceAddr).call();
    console.log("掷骰子合约下注后CFT:", tronWeb.fromSun(cft.toNumber()));

}

async function betSlotsByCFT() {
    let craftSlots = await tronWeb.contract(craftSlotsAbi, craftSlotsAddr);
    let craftToken = await tronWeb.contract(craftTokenAbi, craftTokenAddr);

    console.log("水果机游戏：用户开始下注CFT");
    let balance = await tronWeb.trx.getBalance(userAddr);
    console.log('用户下注前TRX:', tronWeb.fromSun(balance));
    let cft = await craftToken.balanceOf(userAddr).call();
    console.log('用户下注前CFT:', tronWeb.fromSun(cft.toNumber()));
    cft = await craftToken.balanceOf(craftSlotsAddr).call();
    console.log("水果机合约下注前CFT:", tronWeb.fromSun(cft.toNumber()));

    var stakeArray = [0, 0, tronWeb.toSun(10), 0, 0, tronWeb.toSun(10), 0];
    var bitRecord = "0,0,10,0,0,10,0";
    let result;
    if (monitor == 0) {
        result = await craftSlots.betByCFT(tronWeb.toSun(20), stakeArray, bitRecord).send({
            shouldPollResponse: true
        });
        console.log("水果机CFT下注：", result);
        console.log("下注结果-索引：", result._randType.toNumber());
        console.log("下注结果：", result._res);
    } else {
        result = await craftSlots.betByCFT(tronWeb.toSun(20), stakeArray, bitRecord).send({});
        console.log("水果机CFT下注：", result);
        tIdArray._betSlotsByCFT = result;
    }


    balance = await tronWeb.trx.getBalance(userAddr);
    console.log('用户下注后TRX:', tronWeb.fromSun(balance));
    cft = await craftToken.balanceOf(userAddr).call();
    console.log('用户下注后CFT:', tronWeb.fromSun(cft.toNumber()));
    cft = await craftToken.balanceOf(craftSlotsAddr).call();
    console.log("水果机合约下注后CFT:", tronWeb.fromSun(cft.toNumber()));
}

var bet_ = false;
var betSlot_ = false;
var betByCFT_ = false;
var betSlotByCFT_ = false;

async function startEventListener() {
    let craftDice = await tronWeb.contract(craftDiceAbi, craftDiceAddr);
    let craftSlots = await tronWeb.contract(craftSlotsAbi, craftSlotsAddr);

    craftDice.LogBet().watch((err, {result}) => {
        if (err) {
            return console.error('Failed to bind event listener:', err);
        }
        console.log('掷骰子bet result:\n', result);
        bet_ = true;
    });

    craftDice.LogBetByCFT().watch((err, {result}) => {
        if (err) {
            return console.error('Failed to bind event listener:', err);
        }
        console.log('掷骰子betByCFT result:\n', result);
        betSlot_ = true;
    });

    craftSlots.LogSlots().watch((err, {result}) => {
        if (err) {
            return console.error('Failed to bind event listener:', err);
        }
        console.log('水果机bet result:\n', result);
        betByCFT_ = true;
    });

    craftSlots.LogSlotsByCFT().watch((err, {result}) => {
        if (err) {
            return console.error('Failed to bind event listener:', err);
        }
        console.log('水果机betByCFT result:\n', result);
        betSlotByCFT_ = true;
    });

}

async function statTx(id) {
    let msg = await tronWeb.trx.getTransactionInfo(id);
    let len;
    if (msg.internal_transactions != null) {
        len = msg.internal_transactions.length;
    } else {
        len = 0;
    }
    console.log("fee:" + tronWeb.fromSun(msg.fee) + "\t跨合约调用次数:" + len + "\t带宽fee：" + tronWeb.fromSun(msg.receipt.net_fee) + "\tEnergy fee:" + tronWeb.fromSun(msg.receipt.energy_fee) + "\tEnergy总消耗：" + msg.receipt.energy_usage_total
        + "\t用户消耗Energy：" + msg.receipt.energy_usage + "\t合约消耗Energy:" + msg.receipt.origin_energy_usage + "\t带宽消耗：" + msg.receipt.net_usage);
}

async function record() {
    if (bet_ && betSlot_ && betByCFT_ && betSlotByCFT_) {
        console.log("--------统计数据--------");
        console.log("掷骰子TRX下注：=====");
        await statTx(tIdArray._bet);
        console.log("掷骰子CFT下注：=====");
        await statTx(tIdArray._betByCFT);
        console.log("水果机TRX下注：=====");
        await statTx(tIdArray._betSlots);
        console.log("水果机CFT下注：=====");
        await statTx(tIdArray._betSlotsByCFT);
        console.log("--------finish---------");
    } else {
        setTimeout(async () => {
            await record();
        }, 5000);
    }
}

startEventListener();

async function mainJS() {
    console.log("-------掷骰子游戏-------");
    await bet();
    console.log("-----------------------");
    await betByCFT();
    console.log("=======================");
    console.log("-------水果机游戏-------");
    await betSlots();
    console.log("-----------------------");
    await betSlotsByCFT();
    if (monitor != 0) {
        await record();
    } else {
        console.log("--------finish---------");
    }
}

mainJS();