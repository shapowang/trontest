const HttpProvider = TronWeb.providers.HttpProvider;

// let nodeURL = 'https://api.trongrid.io';
let nodeURL = 'https://api.shasta.trongrid.io';
const fullNode = new HttpProvider(nodeURL);
const solidityNode = new HttpProvider(nodeURL);
const eventServer = nodeURL;
const privateKey = 'ecf8b21fb49c20851f85d66e9f51ff2f56248a9af6bb9456cece36186782e473';
const UNIT = 1e6;
let newContract;
const app = async () => {
    const tronWeb = new TronWeb(
        fullNode,
        solidityNode,
        eventServer,
        privateKey
    );

    tronWeb.setDefaultBlock('latest');

    const nodes = await tronWeb.isConnected();
    const connected = !Object.entries(nodes).map(([name, connected]) => {
        if (!connected) {
            console.error(`Error: ${name} is not connected`);
        }
        return connected;
    }).includes(false);
    if (!connected) {
        return;
    }

    $("#name").text(tronWeb.defaultAddress.base58);

    tronWeb.trx.getBalance(tronWeb.defaultAddress.base58).then(balance => {
        $("#balance").text(tronWeb.fromSun(balance));
    }).catch(err => console.error(err));

    tronWeb.trx.getBandwidth(tronWeb.defaultAddress.base58).then(bandwidth => {
        $("#bandwidth").text(bandwidth);
    }).catch(err => console.error(err));

    // tronWeb.trx.getBandwidth(tronWeb.defaultAddress.base58).then(bandwidth => {
    //     $("#bandwidth").text(bandwidth);
    // }).catch(err => console.error(err));

    $("#transferBtn").click(function () {
        const toAddress = 'TRjgMk3Z8vvuf5wQcaGkQiRWrzoQS4ymNz';
        tronWeb.trx.sendTransaction(toAddress, 1 * UNIT, (err, result) => {
            if (err)
                return console.error(err);
            console.group('Send TRX transaction');
            console.log('- Result:\n' + JSON.stringify(result, null, 2), '\n');
            console.groupEnd();
        });
    });

    $("#lockBtn").click(function () {
        tronWeb.trx.freezeBalance(30000 * UNIT, (err, result) => {
            if (err)
                return console.error(err);
            console.log('- Result:\n' + JSON.stringify(result, null, 2), '\n');
        });
    });

    $("#getContract").click(function () {
        const contractAddress = 'TYvvUMDjLMFHdgmRcS3p8Pjh9Zhj37JGp5';
        tronWeb.trx.getContract(contractAddress).then(contract => {
            console.group('Contract from node');
            console.log('- Contract Address: TYvvUMDjLMFHdgmRcS3p8Pjh9Zhj37JGp5');
            console.log('- Origin Address:', contract.origin_address);
            console.log('- Bytecode:', contract.bytecode);
            console.log('- ABI:\n' + JSON.stringify(contract.abi, null, 2), '\n');
            console.groupEnd();
        }).catch(err => console.error(err));
    });

    $("#deployContract").click(function () {

        tronWeb.transactionBuilder.createSmartContract({
            abi: [{"constant": false, "inputs": [], "name": "add", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function"}, {
                "constant": false,
                "inputs": [],
                "name": "subtract",
                "outputs": [],
                "payable": false,
                "stateMutability": "nonpayable",
                "type": "function"
            }],
            bytecode: '6080604052600560005534801561001557600080fd5b5060c9806100246000396000f3006080604052600436106049576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680634f2be91f14604e5780636deebae3146062575b600080fd5b348015605957600080fd5b5060606076565b005b348015606d57600080fd5b5060746089565b005b6000808154809291906001019190505550565b6000808154809291906001900391905055505600a165627a7a723058206f99daf0981439d56ad42ecbcf1d432ea709c081b3af8646ae086bfb7273d5930029',
            feeLimit: 30000
        }, '41c2d52f2511808307c848b808649595f631527111', (err, transaction) => {
            if (err) {
                return console.error(err);
            }
            console.group('Unsigned create smart contract transaction');
            console.log('- Issuer Address: 41c2d52f2511808307c848b808649595f631527111');
            console.log('- Transaction:\n' + JSON.stringify(transaction, null, 2), '\n');
            console.groupEnd();
        });

    });

    $("#triggerContract").click(function () {
        tronWeb.transactionBuilder.triggerSmartContract(
            '413c8143e98b3e2fe1b1a8fb82b34557505a752390',
            'multiply(int256,int256)',
            30000,
            0,
            [
                {type: 'int256', value: 1},
                {type: 'int256', value: 1}
            ],
            (err, transaction) => {
                if (err) {
                    return console.error(err);
                }
                console.group('Unsigned trigger smart contract transaction');
                console.log('- Contract Address: 413c8143e98b3e2fe1b1a8fb82b34557505a752390');
                console.log('- Transaction:\n' + JSON.stringify(transaction, null, 2), '\n');
                console.groupEnd();
            });
    });

};
app();