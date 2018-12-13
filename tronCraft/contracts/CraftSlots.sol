pragma solidity ^0.4.23;


import "./openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";


contract CraftSlots is Ownable {
    using SafeMath for uint256;

    uint256 constant CAPMININGTOKEN = 5600000000;
    uint256 constant MININGREWARD = 10;
    uint256 constant MININGFALLOFF = 1;
    uint256 constant DECIMALS = 6;

    uint256[7] private odds = [2364, 1182, 1182, 788, 591, 473, 338];
    uint256[24] private order = [0, 5, 6, 1, 5, 3, 4, 6, 2, 6, 5, 4, 3, 5, 6, 1, 6, 3, 4, 6, 2, 6, 5, 4];

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

    function destroy() onlyOwner public {
        craftToken.renounceContracter();
        // transferTRXToTeam(address(this).balance);
        transferCFTToTeam(craftToken.balanceOf(address(this)));
        selfdestruct(team);
    }

    modifier isSumOk(uint256[7] _arr, uint256 _amount) {
        uint256 _sum = 0;
        bool _judge = false;
        for (uint8 i = 0; i < 7; i++) {
            if (_arr[i] == 0) {
                _judge = true;
            }
            _sum = _sum + _arr[i];
        }
        require(_amount == _sum && _judge);
        _;
    }

    constructor (address _craft, address _minerCFTAddr) public {
        craftToken = IERC20(_craft);
        minerCFTAddr = _minerCFTAddr;
    }

    function updateMinerCFTAddr(address _addr) onlyOwner public {
        minerCFTAddr = _addr;
    }

    event LogSlots(address indexed userAddr, uint256 amount, string bitRecord, uint256 randType, uint256 bonus, bool res, uint256 timeStamp);

    event LogSlotsByCFT(address indexed userAddr, uint256 amount, string bitRecord, uint256 randType, uint256 bonus, bool res, uint256 timeStamp);

    function bet(uint256[7] _stakeArray, string _bitRecord) payable isSumOk(_stakeArray, msg.value) public returns (uint256 _randType, bool _res){
        uint256 randNum = uint256(sha256(abi.encodePacked(block.difficulty, msg.sender))) % 24;
        uint256 curType = order[randNum];

        //distributed CFT
        uint256 cftReward = curCFTReward().mul(msg.value).div(10);
        craftToken.transferFrom(minerCFTAddr, msg.sender, cftReward);

        //distributed bonus
        if (_stakeArray[curType] != 0) {
            uint256 bonus = odds[curType].mul(_stakeArray[curType]).div(100);
            require(bonus < address(this).balance, "Greater than contract money");
            msg.sender.transfer(bonus * 1 sun);
            emit LogSlots(msg.sender, msg.value, _bitRecord, curType, bonus, true, now);
            _res = true;
        } else {
            emit LogSlots(msg.sender, msg.value, _bitRecord, curType, 0, false, now);
            _res = false;
        }
        _randType = randNum;
        return;
    }

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

    function betByCFT(uint256 _cftAmount, uint256[7] _stakeArray, string _bitRecord) isSumOk(_stakeArray, _cftAmount) public returns (uint256 _randType, bool _res){
        uint256 cm = _cftAmount;
        uint256 randNum = uint256(sha256(abi.encodePacked(block.difficulty, msg.sender))) % 24;
        uint256 curType = order[randNum];

        //distributed bonus
        if (_stakeArray[curType] != 0) {
            uint256 bonus = odds[curType].mul(_stakeArray[curType]).div(100);
            require(craftToken.transferFromByCraft(msg.sender, address(this), cm, bonus));
            craftToken.transfer(msg.sender, bonus);
            emit LogSlotsByCFT(msg.sender, cm, _bitRecord, curType, bonus, true, now);
            _res = true;
        } else {
            require(craftToken.transferFromByCraft(msg.sender, address(this), cm, 0));
            emit LogSlotsByCFT(msg.sender, cm, _bitRecord, curType, 0, false, now);
            _res = false;
        }
        _randType = randNum;
        return;
    }

    function() payable public {}

    function payMoney() payable public {}
}

