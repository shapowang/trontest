var CraftDice = artifacts.require("../contracts/CraftDice");
var CraftToken = artifacts.require("../contracts/CraftToken");

contract('Dice测试', function(accounts) {
		var diceInstance = CraftDice.deployed();
        var craftInstance = CraftToken.deployed();


        var payAddr = accounts[1]; //account3
        var teamForCFT = accounts[2]; //account4
        var userAddr = accounts[3]; //account5
        var adminAddr = accounts[0]; //account5

        it("下注前Craft调用",async function() {
            let craft = await craftInstance;
            let dice = await diceInstance;
            let diceAddr = tronWeb.address.fromHex(dice.address);

            var cap = await craft.cap.call();
            
            //TODO:部署合约后需手动触发
            await craft.mint(teamForCFT,400000000,{from:adminAddr});
            await craft.mint(dice.address,600000000,{from:adminAddr});

            var teamCFT = await craft.balanceOf(teamForCFT);
            var diceCFT = await craft.balanceOf(diceAddr);
            var userCFT = await craft.balanceOf(userAddr);

            console.log("team团队账户CFT: ",teamCFT.toNumber());
            console.log("dice合约账户CFT: ",diceCFT.toNumber());
            console.log("用户账户CFT: ",userCFT.toNumber());
        });

        it("下注测试", async function() {       
            let dice = await diceInstance;

            let diceAddr = tronWeb.address.fromHex(dice.address);

            console.log("合约地址",diceAddr);
            console.log("账户地址",userAddr);

            var curMiningCFT = await dice.curMiningToken.call();
            console.log("合约下注前挖出CFT",curMiningCFT.toNumber());

            await dice.bet2(42,{callValue:1000000,from:userAddr});

            var curMiningCFT = await dice.curMiningToken.call();
            console.log("合约下注后挖出CFT",curMiningCFT.toNumber());

        });

        it("下注后Craft测试",async function() {
            let craft = await craftInstance;
            let dice = await diceInstance;
            let diceAddr = tronWeb.address.fromHex(dice.address);

            var teamCFT = await craft.balanceOf(teamForCFT);
            var diceCFT = await craft.balanceOf(diceAddr);
            var userCFT = await craft.balanceOf(userAddr);

            console.log("team团队账户CFT: ",teamCFT.toNumber());
            console.log("dice合约账户CFT: ",diceCFT.toNumber());
            console.log("用户账户CFT: ",userCFT.toNumber());
        });

		// diceInstance.then(dice => {        
  //           dice["LogBet"]().watch(function(err, res) {
  //               console.log("LogBet event detected: " + res); 
  //               if (!err) {
  //                   var result = res.result;   
  //                   console.log("   下注用户地址: " + result.args.userAddr);
  //                   console.log("   下注金额: " + tronWeb.fromSun(result.args.betMoney, 'trx'));
  //                   console.log("   获得奖金: " + tronWeb.fromSun(result.args.bonus, 'trx'));
  //                   console.log("   下注数值: " + result.args.num);
  //                   console.log("   结果数值: " + result.args.randNum);
  //                   console.log("   结果: " + result.args.res);
  //                   console.log("   时间戳: " + result.args.timeStamp);
  //               } else {
  //                   console.log("Error occurred while watching events.");
  //               }
  //               console.log(res);
  //           });
  //       });

        it('延迟结束，为event捕获预留时间函数', function() {
            setTimeout(function(){}, 10000);
        });
    
        after(async function() {
            console.log("Test finished.")
        });
});