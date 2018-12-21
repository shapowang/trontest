pragma solidity ^0.4.23;


import "./openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";


contract Sicbo is Ownable {
    using SafeMath for uint256;
    //挖矿总量 5600
    uint256 constant CAP_MINING_TOKEN = 5600000000;
    uint256 constant MININGREWARD = 10;
    uint256 constant MININGFALLOFF = 1;
    uint256 constant DECIMALS = 6;
    /*投注点列表*/
    uint8 constant SMALL = 1;//小
    uint8 constant ODD = 2;//单
    uint8 constant EVEN = 3;//双
    uint8 constant BIG = 4;//大
    uint8 constant THREE_1 = 1;//三个1
    uint8 constant THREE_2 = 2;//三个2
    uint8 constant THREE_3 = 3;//三个3
    uint8 constant THREE_4 = 4;//三个4
    uint8 constant THREE_5 = 5;//三个5
    uint8 constant THREE_6 = 6;//三个6
    uint8 constant THREE_SAME = 7;//三个相同
    uint8 constant SUM_4 = 8;
    uint8 constant SUM_5 = 9;
    uint8 constant SUM_6 = 10;
    uint8 constant SUM_7 = 11;
    uint8 constant SUM_8 = 12;
    uint8 constant SUM_9 = 13;
    uint8 constant SUM_10 = 14;
    uint8 constant SUM_11 = 15;
    uint8 constant SUM_12 = 16;
    uint8 constant SUM_13 = 17;
    uint8 constant SUM_14 = 18;
    uint8 constant SUM_15 = 19;
    uint8 constant SUM_16 = 20;
    uint8 constant SUM_17 = 21;
    /*投注点倍率列表*/
    mapping(uint8 => uint32) public BET_POS_MULTIPLE;

    constructor (address _craft, address _minerCFTAddr) public {
        craftToken = IERC20(_craft);
        minerCFTAddr = _minerCFTAddr;
        BET_POS_MULTIPLE[SMALL] = 1;
        BET_POS_MULTIPLE[ODD] = 1;
        BET_POS_MULTIPLE[EVEN] = 1;
        BET_POS_MULTIPLE[BIG] = 1;
        BET_POS_MULTIPLE[THREE_1] = 150;
        BET_POS_MULTIPLE[THREE_2] = 150;
        BET_POS_MULTIPLE[THREE_3] = 150;
        BET_POS_MULTIPLE[THREE_4] = 150;
        BET_POS_MULTIPLE[THREE_5] = 150;
        BET_POS_MULTIPLE[THREE_6] = 150;
        BET_POS_MULTIPLE[THREE_SAME] = 24;
        BET_POS_MULTIPLE[SUM_4] = 50;
        BET_POS_MULTIPLE[SUM_5] = 18;
        BET_POS_MULTIPLE[SUM_6] = 14;
        BET_POS_MULTIPLE[SUM_7] = 12;
        BET_POS_MULTIPLE[SUM_8] = 8;
        BET_POS_MULTIPLE[SUM_9] = 6;
        BET_POS_MULTIPLE[SUM_10] = 6;
        BET_POS_MULTIPLE[SUM_11] = 6;
        BET_POS_MULTIPLE[SUM_12] = 6;
        BET_POS_MULTIPLE[SUM_13] = 8;
        BET_POS_MULTIPLE[SUM_14] = 12;
        BET_POS_MULTIPLE[SUM_15] = 14;
        BET_POS_MULTIPLE[SUM_16] = 18;
        BET_POS_MULTIPLE[SUM_17] = 50;
    }

    function destroy() public onlyOwner {
        craftToken.renounceContracter();
        // transferTRXToTeam(address(this).balance);
        transferCFTToTeam(craftToken.balanceOf(address(this)));
        selfdestruct(team);
    }


    address public minerCFTAddr;

    IERC20 craftToken;

    address public team;

    address public teamCFT;

    function updateTeamAddr(address _addr) onlyOwner public {
        team = _addr;
    }

    function updateTeamCFTAddr(address _addr) onlyOwner public {
        teamCFT = _addr;
    }

    function transferTRXToTeam(uint256 _amount) onlyOwner public {
        team.transfer(_amount * 1 sun);
    }

    function transferCFTToTeam(uint256 _amount) onlyOwner public {
        craftToken.transfer(teamCFT, _amount);
    }

    function updateMinerCFTAddr(address _addr) onlyOwner public {
        minerCFTAddr = _addr;
    }

    event LogBet(address indexed userAddr, uint256 betMoney, uint256 betPos, uint256 timeStamp);

    event Lottery(address indexed userAddr, uint256 timeStamp);

    struct Bet {
        address user;
        uint8 betPos;
        uint betAmount;
    }

    function curCFTReward() public view returns (uint256) {
        uint256 curMiningToken = CAP_MINING_TOKEN.sub(craftToken.balanceOf(minerCFTAddr).div(10 ** DECIMALS));
        if (curMiningToken < 600000000) {
            return MININGREWARD;
        } else if (curMiningToken < 1600000000) {
            return MININGREWARD - MININGFALLOFF;
        } else if (curMiningToken < 2600000000) {
            return MININGREWARD - MININGFALLOFF * 2;
        } else if (curMiningToken < 3600000000) {
            return MININGREWARD - MININGFALLOFF * 3;
        } else if (curMiningToken < 4600000000) {
            return MININGREWARD - MININGFALLOFF * 4;
        } else if (curMiningToken < CAP_MINING_TOKEN) {
            return MININGREWARD - MININGFALLOFF * 5;
        } else {
            return 0;
        }
    }
    /*本局投注信息列表*/
    Bet[] betList;
    /*最近玩儿游戏的玩家列表*/
    address[] recentAddressList;
    /*最近玩儿游戏的玩家列表的指针*/
    uint8 recentAddressCursor;
    /*false则游戏不可投注*/
    bool running;

    function getRunning() public view returns (bool){
        return running;
    }

    function betStart() public onlyOwner {
        running = true;
    }

    function betStop() public onlyOwner {
        running = false;
    }

    /*
    玩家投注
    */
    function bet(uint8 betPos) payable public {
        require(running, "can't bet at this time");
        require(betPos >= SMALL && betPos <= SUM_17, "bet pos should in [1,21]");
        require(msg.value > 0);
        betList.push(Bet({user : msg.sender, betPos : betPos, betAmount : msg.value}));
        emit LogBet(msg.sender, msg.value, betPos, now);
        for (uint i = 0; i < recentAddressList.length; i++) {
            if (recentAddressList[i] == msg.sender) {
                return;
            }
        }
        if (recentAddressCursor == 50) {
            recentAddressCursor = uint8(0);
        }
        recentAddressList[recentAddressCursor++] = msg.sender;
        return;
    }

    /*
    骰宝开奖
    */
    function open() public {
        uint8 diceA = uint8(sha256(abi.encodePacked(block.difficulty, msg.sender, block.timestamp, uint8(1)))) % 6 + 1;
        uint8 diceB = uint8(sha256(abi.encodePacked(block.difficulty, msg.sender, block.timestamp, uint8(11)))) % 6 + 1;
        uint8 diceC = uint8(sha256(abi.encodePacked(block.difficulty, msg.sender, block.timestamp, uint8(111)))) % 6 + 1;
        uint8 sum = diceA + diceB + diceC;
        //小，1赔1
        uint8[] memory results = new uint8[](4);
        uint8 cursor = 0;
        if (sum >= 4 && sum <= 10) {
            results[cursor++] = SMALL;
        }
        //大，1赔1
        else if (sum >= 11 && sum <= 17) {
            results[cursor++] = BIG;
        }
        //单
        if (sum == 5 || sum == 7 || sum == 9 || sum == 11 || sum == 13 || sum == 15 || sum == 17) {
            results[cursor++] = ODD;
        }
        //双
        else if (sum == 4 || sum == 6 || sum == 8 || sum == 10 || sum == 12 || sum == 14 || sum == 16) {
            results[cursor++] = EVEN;
        }
        //三个数字相同，豹子，1赔150
        if (diceA == diceB && diceB == diceC) {
            results[cursor++] = THREE_SAME;
            if (diceA == 1) {
                results[cursor++] = THREE_1;
            } else if (diceA == 2) {
                results[cursor++] = THREE_2;
            } else if (diceA == 3) {
                results[cursor++] = THREE_3;
            } else if (diceA == 4) {
                results[cursor++] = THREE_4;
            } else if (diceA == 5) {
                results[cursor++] = THREE_5;
            } else if (diceA == 6) {
                results[cursor++] = THREE_6;
            }
        }
        sendAward(results);
    }

    /*最近玩家抽奖*/
    function lotteryOpen(uint count) public onlyOwner {
        address[] memory winners = new address[](count);
        uint idx = 0;
        while (true) {
            bool duplicate = false;
            uint8 random = uint8(sha256(abi.encodePacked(block.difficulty, msg.sender, block.timestamp, uint8(111)))) % uint8(recentAddressList.length);
            for (uint8 i = 0; i < winners.length; i++) {
                if (winners[i] == recentAddressList[random]) {
                    duplicate = true;
                    break;
                }
            }
            if (!duplicate) {
                winners[idx++] = recentAddressList[random];
                if (idx >= count) {
                    for (uint8 j = 0; j < winners.length; j++) {
                        emit Lottery(winners[j], now);
                    }
                }
            }
        }
    }

    /*发送骰宝奖励*/
    function sendAward(uint8[] results) public payable {
        uint totalToPay;
        for (uint i = 0; i < results.length; i++)
        {
            uint8 winPos = results[i];
            for (uint j = 0; j < betList.length; j++)
            {
                Bet memory userBet = betList[j];
                if (winPos == userBet.betPos) {
                    uint win = userBet.betAmount * BET_POS_MULTIPLE[userBet.betPos];
                    totalToPay += win;
                }
            }
        }
        require(totalToPay <= address(this).balance, "not enough money to pay");
        for (uint x = 0; x < results.length; x++)
        {
            uint8 winPos1 = results[x];
            for (uint y = 0; y < betList.length; y++)
            {
                Bet memory userBet1 = betList[y];
                if (winPos1 == userBet1.betPos) {
                    uint win1 = userBet1.betAmount * BET_POS_MULTIPLE[userBet1.betPos];
                    emit LogBet(userBet1.user, win1, userBet1.betPos, now);
                    msg.sender.transfer(win1 * 1 sun);
                }
            }
        }
        betList.length = 0;
    }
}