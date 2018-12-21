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

    itmapInner tmp;

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

    struct itmap
    {
        mapping(address => IndexValue) data;
        KeyFlag[] keys;
        uint size;
    }

    struct IndexValue {uint keyIndex; itmapInner value;}

    struct KeyFlag {address key; bool deleted;}

    function insert(itmap storage self, address key, itmapInner value) private view returns (bool replaced)
    {
        uint keyIndex = self.data[key].keyIndex;
        self.data[key].value = value;
        if (keyIndex > 0) {
            return true;
        }
        else
        {
            keyIndex = self.keys.length++;
            self.data[key].keyIndex = keyIndex + 1;
            self.keys[keyIndex].key = key;
            self.size++;
            return false;
        }
    }

    function contains(itmap storage self, address key) private view returns (bool)
    {
        return self.data[key].keyIndex > 0;
    }

    function iterate_start(itmap storage self) private view returns (uint keyIndex)
    {
        return iterate_next(self, uint(- 1));
    }

    function iterate_valid(itmap storage self, uint keyIndex) private view returns (bool)
    {
        return keyIndex < self.keys.length;
    }

    function iterate_next(itmap storage self, uint keyIndex) private view returns (uint r_keyIndex)
    {
        keyIndex++;
        while (keyIndex < self.keys.length && self.keys[keyIndex].deleted) {
            keyIndex++;
        }
        return keyIndex;
    }

    function iterate_get(itmap storage self, uint keyIndex) private view returns (address key, itmapInner value)
    {
        key = self.keys[keyIndex].key;
        value = self.data[key].value;
    }

    struct itmapInner
    {
        mapping(uint => IndexValueInner) data;
        KeyFlagInner[] keys;
        uint size;
    }

    struct IndexValueInner {uint keyIndex; uint value;}

    struct KeyFlagInner {uint key; bool deleted;}

    function insertInner(itmapInner storage self, uint key, uint value) private view returns (bool replaced)
    {
        uint keyIndex = self.data[key].keyIndex;
        self.data[key].value = value;
        if (keyIndex > 0) {
            return true;
        }
        else
        {
            keyIndex = self.keys.length++;
            self.data[key].keyIndex = keyIndex + 1;
            self.keys[keyIndex].key = key;
            self.size++;
            return false;
        }
    }

    function containsInner(itmapInner storage self, uint key) private view returns (bool)
    {
        return self.data[key].keyIndex > 0;
    }

    function iterate_startInner(itmapInner storage self) private view returns (uint keyIndex)
    {
        return iterate_nextInner(self, uint(- 1));
    }

    function iterate_validInner(itmapInner storage self, uint keyIndex) private view returns (bool)
    {
        return keyIndex < self.keys.length;
    }

    function iterate_nextInner(itmapInner storage self, uint keyIndex) private view returns (uint r_keyIndex)
    {
        keyIndex++;
        while (keyIndex < self.keys.length && self.keys[keyIndex].deleted) {
            keyIndex++;
        }
        return keyIndex;
    }

    function iterate_getInner(itmapInner storage self, uint keyIndex) private view returns (uint key, uint value)
    {
        key = self.keys[keyIndex].key;
        value = self.data[key].value;
    }

    address public minerCFTAddr;

    IERC20 craftToken;

    address public team;
    address public teamCFT;
    /*下注信息的map*/
    itmap betMap;

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

    /*
    玩家投注
    */
    function bet(uint8 betPos) payable public {
        require(betPos >= SMALL && betPos <= SUM_17, "bet pos should in [1,21]");
        require(msg.value > 0);
        itmapInner storage userBetMap = betMap.data[address(msg.sender)].value;
        (uint keyInner, uint valueInner) = iterate_getInner(userBetMap, betPos);
        userBetMap.data[betPos].value = userBetMap.data[betPos].value + msg.value;
        insertInner(userBetMap, betPos, msg.value + valueInner);
        emit LogBet(msg.sender, msg.value, betPos, now);
        return;
    }

    /*
    开奖
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
        for (uint i = iterate_start(betMap); iterate_valid(betMap, i); i = iterate_next(betMap, i))
        {
            (address key,itmapInner memory value) = iterate_get(betMap, i);
            tmp = value;
            for (uint j = iterate_startInner(tmp); iterate_validInner(tmp, j); j = iterate_nextInner(tmp, j))
            {
                (uint betPos,uint betAmount) = iterate_getInner(tmp, j);
            }
        }
        return;
    }

}