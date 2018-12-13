pragma solidity ^0.4.23;


import "./openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";


contract CraftDice is Ownable {
    using SafeMath for uint256;
    //挖矿总量
    uint256 constant CAPMININGTOKEN = 5600000000;
    uint256 constant MININGREWARD = 10;
    uint256 constant MININGFALLOFF = 1;
    uint256 constant DECIMALS = 6;

    address public minerCFTAddr;

    IERC20 craftToken;

    uint256[93] private odds = [32833, 24625, 19700, 16416, 14071, 12312, 10944, 9850, 8954, 8208, 7576, 7035, 6566,
    6156, 5794, 5472, 5184, 4925, 4690, 4477, 4282, 4104, 3940, 3788, 3648, 3517, 3396, 3283, 3177, 3078, 2984, 2897, 2814, 2736,
    2662, 2592, 2525, 2462, 2402, 2345, 2290, 2238, 2188, 2141, 2095, 2052, 2010, 1970, 1931, 1894, 1858, 1824, 1790, 1758, 1728,
    1698, 1669, 1641, 1614, 1588, 1563, 1539, 1515, 1492, 1470, 1448, 1427, 1407, 1387, 1368, 1349, 1331, 1313, 1296, 1279, 1262,
    1246, 1231, 1216, 1201, 1186, 1172, 1158, 1145, 1132, 1119, 1106, 1094, 1082, 1070, 1059, 1047, 1036];

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

    function destroy() onlyOwner public {
        craftToken.renounceContracter();
        // transferTRXToTeam(address(this).balance);
        transferCFTToTeam(craftToken.balanceOf(address(this)));
        selfdestruct(team);
    }

    constructor (address _craft, address _minerCFTAddr) public {
        craftToken = IERC20(_craft);
        minerCFTAddr = _minerCFTAddr;
    }

    function updateMinerCFTAddr(address _addr) onlyOwner public {
        minerCFTAddr = _addr;
    }

    event LogBet(address indexed userAddr, uint256 betMoney, uint256 bonus, uint256 num, uint256 randNum, bool res, uint256 timeStamp);

    event LogBetByCFT(address indexed userAddr, uint256 betMoney, uint256 bonus, uint256 num, uint256 randNum, bool res, uint256 timeStamp);

    function curCFTReward() public view returns (uint256) {
        uint256 curMiningToken = CAPMININGTOKEN.sub(craftToken.balanceOf(minerCFTAddr).div(10 ** DECIMALS));
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
        } else if (curMiningToken < CAPMININGTOKEN) {
            return MININGREWARD - MININGFALLOFF * 5;
        } else {
            return 0;
        }
    }

    function bet(uint256 num) payable public returns (uint256 _randNum, bool _res){
        require(num >= 4 && num <= 96);
        require(msg.value > 0);
        // rand num
        uint256 randNum = uint256(sha256(abi.encodePacked(block.difficulty, msg.sender))) % 100 + 1;
        //distributed CFT
        uint256 cftReward = curCFTReward().mul(msg.value).div(10);
        craftToken.transferFrom(minerCFTAddr, msg.sender, cftReward);
        //distributed bonus
        if (randNum < num) {
            uint256 bonus = msg.value.mul(odds[num - 4]).div(1000);
            require(bonus < address(this).balance, "Greater than contract money");
            msg.sender.transfer(bonus * 1 sun);
            emit LogBet(msg.sender, msg.value, bonus, num, randNum, true, now);
            _res = true;
        } else {
            emit LogBet(msg.sender, msg.value, 0, num, randNum, false, now);
            _res = false;
        }
        _randNum = randNum;
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