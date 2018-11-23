eosnetwork = "mainnet";
projectName = "";
network_account_url = "https://jungle.bloks.io/account/";

function load() {
    var path = "/accounts";
    if (projectName === "team") {
        path = "/teamaccounts";
    } else if (projectName === "alert") {
        path = "/alert";
    }
    var oldList = localStorage.getItem("additional_accounts");
    path += "?network=" + eosnetwork + "&" + "accounts=" + (oldList ? oldList : "");
    $.ajax(path, {
        success: function (arg) {
            var $target = $('#target');
            $target.empty();
            console.log(arg);
            var totalRam = 0;
            var totalEOS = 0;
            for (var i = 0; i < arg.result.length; i++) {
                var account = JSON.parse(arg.result[i]);
                if (account.core_liquid_balance !== undefined && account.core_liquid_balance !== null) {
                    totalEOS += parseFloat(account.core_liquid_balance);
                }
                if (account.self_delegated_bandwidth !== undefined && account.self_delegated_bandwidth !== null) {
                    totalEOS += parseFloat(account.self_delegated_bandwidth.cpu_weight);
                    totalEOS += parseFloat(account.self_delegated_bandwidth.net_weight);
                }
                if (account.refund_request !== undefined && account.refund_request !== null) {
                    totalEOS += parseFloat(account.refund_request.net_amount);
                    totalEOS += parseFloat(account.refund_request.cpu_amount);
                }
                account.cpu_percent = 100 * account.cpu_limit.used / account.cpu_limit.max;
                account.net_percent = 100 * account.net_limit.used / account.net_limit.max;
                account.ram_percent = 100 * account.ram_usage / account.ram_quota;
                totalRam += account.ram_quota;
                account.total_resources.cpu_weight = account.total_resources.cpu_weight.replace(".0000", "");
                account.total_resources.net_weight = account.total_resources.net_weight.replace(".0000", "");
                if (account.account_name.indexOf("ico") != -1) {
                    account.account_name_zh = "ICO收款账号";
                } else if (account.account_name.indexOf("mine") != -1) {
                    account.account_name_zh = "挖矿合约账号";
                } else if (account.account_name.indexOf("game111") != -1) {
                    account.account_name_zh = "石头剪刀布游戏合约账号";
                } else if (account.account_name.indexOf("gamea11") != -1) {
                    account.account_name_zh = "FOMO游戏合约账号";
                } else if (account.account_name.indexOf("admin") != -1) {
                    account.account_name_zh = "管理账号";
                } else if (account.account_name.indexOf("token") != -1) {
                    account.account_name_zh = "发币合约账号";
                } else if (account.account_name.indexOf("wallet") != -1) {
                    account.account_name_zh = "团队钱包";
                } else if (account.account_name.indexOf("pro") != -1) {
                    account.account_name_zh = "分红合约账号";
                } else if (account.account_name.indexOf("team") != -1) {
                    account.account_name_zh = "团队锁仓合约账号";
                }
                for (var j = 0; j < account.permissions.length; j++) {
                    var permission = account.permissions[j];
                    var required_auth_str = "";
                    if (permission.required_auth.waits.length === 0 && permission.required_auth.threshold === 1) {
                        for (var k = 0; k < permission.required_auth.accounts.length; k++) {
                            var permAccount = permission.required_auth.accounts[k];
                            required_auth_str += permAccount.permission.actor + "@" + permAccount.permission.permission;
                        }
                        for (var k = 0; k < permission.required_auth.keys.length; k++) {
                            var permKey = permission.required_auth.keys[k];
                            required_auth_str += permKey.key;
                        }
                    } else {
                        required_auth_str = JSON.stringify(permission.required_auth);
                    }
                    permission.required_auth_str = required_auth_str;
                }
                if (localStorage.getItem("additional_accounts") !== null && localStorage.getItem("additional_accounts").indexOf(account.account_name) !== -1) {
                    account.localAdd = true;
                }
                account.network_account_url = network_account_url;
                var rendered = Mustache.render(template, account);
                $target.append(rendered);
                console.log(account);
                setEvtBalance(account.account_name);
            }
            $("#totalRAM").text(totalRam);
            //https://bloks.io/account/vagasadmin11,cpu stake to other
            $("#totalEOS").text(totalEOS + totalRam * 0.072 / 1000 + 16);
        }
    });
}

function setEvtBalance(accountName) {
    $.ajax("/evt_balance?account=" + accountName + "&network=" + eosnetwork, {
        success: function (arg) {
            $("#" + accountName + "_evt").text("EVT:" + arg.result);
        }
    });
}

function refresh() {
    var countdown = 20000;
    setInterval(function () {
        countdown -= 1000;
        $("#countDown").text(countdown / 1000 + "秒钟之后刷新");
        if (countdown <= 0) {
            countdown = 20000;
            load();
        }
    }, 1000);
}

function addAccountName() {
    var name = $("#account_to_monitor").val();
    var oldList = localStorage.getItem("additional_accounts");
    if (oldList.indexOf(name) === -1) {
        localStorage.setItem("additional_accounts", oldList ? oldList + "," + name : name);
        load();
    }
    $.toast({
        text: "添加成功，请等待数据加载完成~",
        textAlign: "center",
        position: "top-center"
    });
}

function removeLocal(accountName) {
    var oldList = localStorage.getItem("additional_accounts");
    if (oldList) {
        oldList = oldList.replace(accountName + ",", "");
        oldList = oldList.replace(accountName, "");
    }
    localStorage.setItem("additional_accounts", oldList);
    $("#" + accountName + "_node").remove();
}

function changeNetwork(network) {
    eosnetwork = network;
    if (eosnetwork === "mainnet") {
        network_account_url = "https://www.bloks.io/account/";
    } else if (eosnetwork === "kylin") {
        network_account_url = "https://tools.cryptokylin.io/#/tx/";
    } else if (eosnetwork === "jungle") {
        network_account_url = "https://jungle.bloks.io/account/";
    }
    load();
}

function changeRequestProject(name) {
    projectName = name;
}

function showWXGroup() {
    $(".pcCodeBox").css('display', 'block');
    $(".pcCodeBox").click(function () {
        $(".pcCodeBox").css('display', 'none');
    })
}