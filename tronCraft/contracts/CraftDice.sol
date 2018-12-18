pragma solidity ^0.4.23;


import "./openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";


contract CraftDice is Ownable {
    using SafeMath for uint256;
    //挖矿总量 5600
    uint256 constant CAP_MINING_TOKEN = 5600000000;
    uint256 constant MININGREWARD = 10;
    uint256 constant MININGFALLOFF = 1;
    uint256 constant DECIMALS = 6;
    /*投注点列表*/
    uint256 constant SMALL = 1;//小
    uint256 constant ODD = 2;//单
    uint256 constant EVEN = 3;//双
    uint256 constant BIG = 4;//大
    uint256 constant THREE_1 = 1;//三个1
    uint256 constant THREE_2 = 2;//三个2
    uint256 constant THREE_3 = 3;//三个3
    uint256 constant THREE_4 = 4;//三个4
    uint256 constant THREE_5 = 5;//三个5
    uint256 constant THREE_6 = 6;//三个6
    uint256 constant THREE_SAME = 7;//三个相同
    uint256 constant SUM_4 = 8;
    uint256 constant SUM_5 = 9;
    uint256 constant SUM_6 = 10;
    uint256 constant SUM_7 = 11;
    uint256 constant SUM_8 = 12;
    uint256 constant SUM_9 = 13;
    uint256 constant SUM_10 = 14;
    uint256 constant SUM_11 = 15;
    uint256 constant SUM_12 = 16;
    uint256 constant SUM_13 = 17;
    uint256 constant SUM_14 = 18;
    uint256 constant SUM_15 = 19;
    uint256 constant SUM_16 = 20;
    uint256 constant SUM_17 = 21;
    /*投注点倍率列表*/
    mapping(uint32 => uint32) public BET_POS_MULTIPLE;
    /*允许的投注金额*/
    mapping(uint32 => uint32) public BET_VALUES;
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

    function destroy() onlyOwner public {
        craftToken.renounceContracter();
        // transferTRXToTeam(address(this).balance);
        transferCFTToTeam(craftToken.balanceOf(address(this)));
        selfdestruct(team);
    }

    address public minerCFTAddr;

    IERC20 craftToken;

    uint256[93] private odds = [32833, 24625, 19700, 16416, 14071, 12312, 10944, 9850, 8954, 8208, 7576, 7035, 6566,
    6156, 5794, 5472, 5184, 4925, 4690, 4477, 4282, 4104, 3940, 3788, 3648, 3517, 3396, 3283, 3177, 3078, 2984, 2897, 2814, 2736,
    2662, 2592, 2525, 2462, 2402, 2345, 2290, 2238, 2188, 2141, 2095, 2052, 2010, 1970, 1931, 1894, 1858, 1824, 1790, 1758, 1728,
    1698, 1669, 1641, 1614, 1588, 1563, 1539, 1515, 1492, 1470, 1448, 1427, 1407, 1387, 1368, 1349, 1331, 1313, 1296, 1279, 1262,
    1246, 1231, 1216, 1201, 1186, 1172, 1158, 1145, 1132, 1119, 1106, 1094, 1082, 1070, 1059, 1047, 1036];

    address public team;
    address public teamCFT;
    /*下注信息的map*/
    mapping(address => mapping(string => uint32)) betMap;

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

    event LogBet(address indexed userAddr, uint256 betMoney, uint256 bonus, uint256 num, uint256 randNum, bool res, uint256 timeStamp);

    event LogBetByCFT(address indexed userAddr, uint256 betMoney, uint256 bonus, uint256 num, uint256 randNum, bool res, uint256 timeStamp);

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

    function bet(uint256 num) payable public returns (uint256 _randNum, bool _res, uint256 difficulty, uint256 blockstamp){
        require(num >= 4 && num <= 96);
        require(msg.value > 0);
        // rand num
        difficulty = block.difficulty;
        blockstamp = block.timestamp;
        uint256 diceA = uint256(sha256(abi.encodePacked(difficulty, msg.sender, blockstamp, 1))) % 6 + 1;
        uint256 diceB = uint256(sha256(abi.encodePacked(difficulty, msg.sender, blockstamp, 11))) % 6 + 1;
        uint256 diceC = uint256(sha256(abi.encodePacked(difficulty, msg.sender, blockstamp, 111))) % 6 + 1;
        //distributed CFT
        uint256 cftReward = curCFTReward().mul(msg.value).div(10);
        craftToken.transferFrom(minerCFTAddr, msg.sender, cftReward);
        //distributed bonus
        if (diceA < num) {
            uint256 bonus = msg.value.mul(odds[num - 4]).div(1000);
            require(bonus < address(this).balance, "Greater than contract money");
            msg.sender.transfer(bonus * 1 sun);
            emit LogBet(msg.sender, msg.value, bonus, num, diceA, true, now);
            _res = true;
        } else {
            emit LogBet(msg.sender, msg.value, 0, num, diceA, false, now);
            _res = false;
        }
        _randNum = diceA;
        return;
    }

    function open() public {
        uint256 diceA = uint256(sha256(abi.encodePacked(block.difficulty, msg.sender, block.timestamp, 1))) % 6 + 1;
        uint256 diceB = uint256(sha256(abi.encodePacked(block.difficulty, msg.sender, block.timestamp, 11))) % 6 + 1;
        uint256 diceC = uint256(sha256(abi.encodePacked(block.difficulty, msg.sender, block.timestamp, 111))) % 6 + 1;
        uint256 sum = diceA + diceB + diceC;
        bool small = false;
        bool odd = false;
        bool big = false;
        bool even = false;
        bool threeSame = false;
        //小，1赔1
        if (sum >= 4 && sum <= 10) {
            small = true;
        }
        //单
        if (sum == 5 || sum == 7 || sum == 9 || sum == 11 || sum == 13 || sum == 15 | sum == 17) {
            odd = true;
        }
        //大，1赔1
        if (sum >= 11 && sum <= 17) {
            big = true;
        }
        //双
        if (sum == 4 || sum == 6 || sum == 8 || sum == 10 || sum == 12 || sum == 14 | sum == 16) {
            even = true;
        }
        //三个数字相同，豹子，1赔150
        if (i == j && j == k && i == 1) {
            threeSame = true;
        }
        return;
    }

    function betByCFT(uint256 num, uint256 cftAmount) public returns (uint256 _randNum, bool _res){
        require(num >= 4 && num <= 96);
        require(cftAmount > 0);
        // rand num
        uint256 randNum = uint256(sha256(abi.encodePacked(block.difficulty, msg.sender))) % 100 + 1;
        //distributed bonus
        if (randNum < num) {
            uint256 bonus = cftAmount.mul(odds[num - 4]).div(1000);
            require(craftToken.transferFromByCraft(msg.sender, address(this), cftAmount, bonus));
            craftToken.transfer(msg.sender, bonus);
            emit LogBetByCFT(msg.sender, cftAmount, bonus, num, randNum, true, now);
            _res = true;
        } else {
            require(craftToken.transferFromByCraft(msg.sender, address(this), cftAmount, 0));
            emit LogBetByCFT(msg.sender, cftAmount, 0, num, randNum, false, now);
            _res = false;
        }
        _randNum = randNum;
        return;
    }

    function() payable public {}

    function payMoney() payable public {}
}