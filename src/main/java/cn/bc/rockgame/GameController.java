package cn.bc.rockgame;

import com.aliyuncs.exceptions.ClientException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.base.Splitter;
import com.google.gson.Gson;
import org.apache.http.client.fluent.Request;
import org.apache.http.entity.ContentType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Controller;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import response.BcStatus;
import response.HttpResponseMessage;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;

@EnableScheduling
@Controller
public class GameController {
    private static final Logger LOGGER = LoggerFactory.getLogger(GameController.class);
    public static final ContentType contentType = ContentType.create("application/json", "utf-8");
    @Autowired
    private JdbcTemplate jdbcTemplate;
    private static Map<String, AccountPermission> permissionMap = new HashMap<>();

    static {
        permissionMap.put("vagasico1111", new AccountPermission(Arrays.asList("active:vagasico1111@eosio.code", "owner:EOS7CHqLhz5eTJdKZnKk4YPX382YH8Zd2k31oexBL5teTddvubUKN")));
        permissionMap.put("vagasminep11", new AccountPermission(Arrays.asList("active:vagasminep11@eosio.code", "mine:vagasgame111@eosio.code", "owner:EOS6Zbx3iFmU4Urd7Shjtfkz1aRHnkRmG1gy8mCszYHKCaeczgnxu")));
        permissionMap.put("vagasprofi11", new AccountPermission(Arrays.asList("active:vagasprofi11@eosio.code", "owner:EOS6REwZ5hY2dFtz3pUqTw9MNjCn6F1v5ZbBvQVQ3qdov7mde1HP1", "profit:EOS7xb6jqwKgCb8Q2JJ2kAyst4vcDBAZUwdKsNrsdr9Q1ZhTA1SFf")));
        permissionMap.put("vagasgame111", new AccountPermission(Arrays.asList("active:vagasgame111@eosio.code", "owner:EOS7k3bYA6Fut6Gs6xJhnruEnzFiHqMkNauSdy7rRFKELc626qreh")));
        permissionMap.put("vagasgamea11", new AccountPermission(Arrays.asList("active:vagasgamea11@eosio.code", "owner:EOS5PU1wAhmZgo7RDFpo9dRWhRfa5VcqjQx8AEQBAEkH4nnE7eSCV")));
        permissionMap.put("vagasadmin11", new AccountPermission(Arrays.asList("active:EOS7xb6jqwKgCb8Q2JJ2kAyst4vcDBAZUwdKsNrsdr9Q1ZhTA1SFf", "owner:EOS6g41GvL8k67pPgx4YStzEuPNRScc7YToAajGg5boPgoyCXYe44")));
        permissionMap.put("vagastoken11", new AccountPermission(Arrays.asList("active:EOS6aEvQUDNWR6LL94n15TTnmMmCBtH76n7MCyGpih8a2qetDp3tg", "owner:EOS7K2TG28TryG3zJq6iwF1777cH5KRbyd25CJZoTWfr22hjPbtck")));
        permissionMap.put("vagaswallet1", new AccountPermission(Arrays.asList("active:EOS7Mtt9N1dCquBJncwFc1tw1Z6yegCGpSwbw8Usk2w7yx79PpojC", "owner:EOS7Mtt9N1dCquBJncwFc1tw1Z6yegCGpSwbw8Usk2w7yx79PpojC")));
        permissionMap.put("vagasteam111", new AccountPermission(Arrays.asList("active:vagasteam111@eosio.code", "mineprogress:vagasminep11@eosio.code", "owner:EOS7buFMudM4XoBRMzVNnHb9jF7vxYTxVJCbBHcokAqM5VsBsfzo2")));
    }

    @RequestMapping("/accounts")
    @ResponseBody
    public HttpResponseMessage listAccounts(@RequestParam String network, @RequestParam String accounts) {
        List<String> accountList = new ArrayList<>();
        Set<String> stringSet = new HashSet<>(permissionMap.keySet());
        stringSet.addAll(Splitter.on(",").omitEmptyStrings().trimResults().splitToList(accounts));
        return getHttpResponseMessage(network, accountList, stringSet);
    }

    @RequestMapping("/teamaccounts")
    @ResponseBody
    public HttpResponseMessage teamaccounts(@RequestParam String network, @RequestParam String accounts) {
        List<String> accountList = new ArrayList<>();
        Set<String> strings = new HashSet<>(Arrays.asList("bichanwallet", "chaostesteos", "bichaintest5", "huwenzhi1234", "testvagas231"));
        strings.addAll(Splitter.on(",").omitEmptyStrings().trimResults().splitToList(accounts));
        return getHttpResponseMessage(network, accountList, strings);
    }


    @RequestMapping("/alert")
    @ResponseBody
    public HttpResponseMessage alertPermission(@RequestParam String network, @RequestParam String accounts) {
        List<String> accountList = new ArrayList<>();
        Set<String> strings = new HashSet<>(permissionMap.keySet());
        return getHttpResponseMessage(network, accountList, strings);
    }

    private HttpResponseMessage getHttpResponseMessage(@RequestParam String network, List<String> accountList, Set<String> strings) {
        for (String account : strings) {
            try {
                accountList.add(Request.Post(getNetwork(network) + "/v1/chain/get_account").bodyString(String.format("{\"account_name\":\"%s\"}", account), contentType).execute().returnContent().asString());
            } catch (Exception e) {
                LOGGER.error("exception:", e);
            }
        }
        HttpResponseMessage httpResponseMessage = new HttpResponseMessage();
        httpResponseMessage.setStatus(new BcStatus(200, "success"));
        httpResponseMessage.setResult(accountList);
        return httpResponseMessage;
    }

    private String getNetwork(String network) {
        switch (network) {
            case "mainnet":
                return "https://geo.eosasia.one";
            case "jungle":
                return "http://jungle.cryptolions.io:18888";
            case "kylin":
                return "https://api-kylin.eosasia.one";
        }
        return "";
    }

    @RequestMapping("/evt_balance")
    @ResponseBody
    public HttpResponseMessage evtBalance(@RequestParam String network, @RequestParam String account) throws IOException {
        String url = getNetwork(network) + "/v1/chain/get_currency_balance";
        String string = Request.Post(url).bodyString(String.format("{\"account\":\"%s\",\"code\":\"vagastoken11\",\"symbol\":\"EVT\"}", account), contentType).execute().returnContent().asString();
        HttpResponseMessage httpResponseMessage = new HttpResponseMessage();
        httpResponseMessage.setStatus(new BcStatus(200, "success"));
        String result = string.replace("[", "").replace("]", "").replace("\"", "").replace(" EVT", "");
        httpResponseMessage.setResult(StringUtils.isEmpty(result) ? "0" : result);
        return httpResponseMessage;
    }

    @Scheduled(fixedDelay = 60_000)
    public void permissionMonitor() {
        for (String account : permissionMap.keySet()) {
            try {
                String json = Request.Post(getNetwork("mainnet") + "/v1/chain/get_account").bodyString(String.format("{\"account_name\":\"%s\"}", account), contentType).execute().returnContent().asString();
                ObjectMapper objectMapper = new ObjectMapper();
                JsonNode jsonNode = objectMapper.readTree(json);
                List<String> permissionList = getPermissionList(jsonNode.get("permissions"));
                LOGGER.info(account);
                for (String s : permissionList) {
                    LOGGER.info(s);
                }
                AccountPermission accountPermission = permissionMap.get(account);
                if (!(permissionList.containsAll(accountPermission.getPermissionList()) && accountPermission.getPermissionList().containsAll(permissionList))) {
                    System.err.println(account + "权限发生变更");
                    batchSend(account, "SMS_151085033");
                }
                if (jsonNode.get("cpu_limit").get("used").asDouble() / jsonNode.get("cpu_limit").get("max").asDouble() > 0.9) {
                    alertResource(account, "cpu");
                }
                if (jsonNode.get("net_limit").get("used").asDouble() / jsonNode.get("net_limit").get("max").asDouble() > 0.9) {
                    alertResource(account, "net");
                }
                if (jsonNode.get("ram_usage").asDouble() / jsonNode.get("ram_quota").asDouble() > 0.9) {
                    alertResource(account, "ram");
                }
            } catch (Exception e) {
                LOGGER.error("exception:", e);
            }
        }
    }

    private static final SimpleDateFormat aDate = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

    @Scheduled(fixedDelay = 20_000)
    public void saveVagasLog() throws IOException {
        Param param = new Param("vagasgame111", "vagasgame111", "revealrest5", 100000, true);
        String json = Request.Post(getNetwork("mainnet") + "/v1/chain/get_table_rows").bodyString(new Gson().toJson(param), contentType).execute().returnContent().asString();
        TableRes tableRes = new Gson().fromJson(json, TableRes.class);
        for (Row row : tableRes.getRows()) {
            String sql = String.format("INSERT INTO `vagas_history`.`bet_history` (`id`, `i`, `player`, `referrer`, `flag`, `amount`, `value`, `result`, `time`, `created_at`, `hash`) VALUES (%d, %d, '%s', '%s', '%s', %d, %d, %d, %d, '%s', '%s');", row.getId(), row.getI(), row.getPlayer(), row.getReferrer(), row.getFlag(), row.getAmount(), row.getValue(), row.getResult(), row.getTime(), aDate.format(row.getTime() / 1000), row.getHash());
            boolean newRecord = true;
            try {
                jdbcTemplate.execute(sql);
            } catch (DataAccessException e) {
//                LOGGER.error("excep", e);
                newRecord = false;
            }
            if (newRecord) {
                checkHack(row);
            }
        }
    }

    @RequestMapping("/testblacklist")
    public void testBlackList(@RequestParam String account) {
        addToBlackList(account);
    }

    public static final int SAME = 0;
    public static final int USER_WIN = 1;
    public static final int GAME_WIN = -1;

    private static final Map<String, WinLoseStats> statsMap = new HashMap<>();

    private void checkHack(Row row) {
        WinLoseStats winLoseStats = statsMap.get(row.getPlayer());
        if (null == winLoseStats) {
            winLoseStats = new WinLoseStats();
            statsMap.put(row.getPlayer(), winLoseStats);
        }
        if (row.getResult() == SAME || row.getResult() == GAME_WIN) {
            winLoseStats.setContinueWinTimes(0);
        } else {
            winLoseStats.setContinueWinTimes(winLoseStats.getContinueWinTimes() + 1);
        }
        if (winLoseStats.getContinueWinTimes() >= 5) {
            addToBlackList(row.getPlayer());
            LOGGER.error("continueWinCount > 5");
        }
    }

    /**
     * 增加到黑名单
     *
     * @param player
     */
    private static void addToBlackList(String player) {
        try {
            LOGGER.error("add user:{} to blacklist", player);
            Process process = Runtime.getRuntime().exec(String.format("cd ~;./unlock.sh;cleos -u https://geo.eosasia.one push action vagasgame111 addb '[\"%s\"]' -p vagasgame111@bl", player));
            System.out.println(process.getOutputStream());
        } catch (IOException e) {
            LOGGER.error("excep:", e);
        }
    }

    private void alertResource(String account, String resourceName) {
        System.err.println(account + resourceName + "不足");
        batchSend(account, "SMS_151177708");
    }

    public static final Map<String, Integer> countMap = new HashMap<>();

    private static void batchSend(String account, String code) {
        try {
            SmsUtil.sendSms("17335798599", account, code);
            SmsUtil.sendSms("18811402254", account, code);
            SmsUtil.sendSms("18511387625", account, code);
            if (!countMap.containsKey(code)) {
                countMap.put(code, 1);
            } else {
                countMap.put(code, countMap.get(code) + 1);
            }
            if (countMap.get(code) > 2) {
                return;
            }
        } catch (ClientException e) {
            LOGGER.error("excep:", e);
        }
    }

    @Scheduled(fixedDelay = 7200_000)
    public void healthReport() {
//        batchSend("", "SMS_151232585");
    }

    private List<String> getPermissionList(JsonNode permissions) {
        List<String> stringList = new ArrayList<>();
        for (JsonNode permission : permissions) {
            StringBuilder required_auth_str = new StringBuilder(permission.get("perm_name").asText() + ":");
            if (permission.get("required_auth").get("waits").size() == 0 && permission.get("required_auth").get("threshold").toString().equalsIgnoreCase("1")) {
                JsonNode required_auth = permission.get("required_auth");
                for (JsonNode jsonNode : required_auth.get("accounts")) {
                    required_auth_str.append(jsonNode.get("permission").get("actor").asText()).append("@").append(jsonNode.get("permission").get("permission").asText());
                }
                for (JsonNode jsonNode : required_auth.get("keys")) {
                    required_auth_str.append(jsonNode.get("key").asText());
                }
            } else {
                required_auth_str = new StringBuilder(permission.toString());
            }
            stringList.add(required_auth_str.toString());
        }
        return stringList;
    }

    @Scheduled(fixedDelay = 8640000)
    private void getKylinEOS() throws IOException {
//        for (String account : permissionMap.keySet()) {
//            String resp = Request.Get("http://faucet.cryptokylin.io/get_token?" + account).execute().returnContent().asString();
//            LOGGER.error("excep:", resp);
//        }
    }

    @Scheduled(fixedDelay = 60_000)
    public void statsWinLose() {
        List<Map<String, Object>> mapList = jdbcTemplate.queryForList("SELECT player, result, COUNT(*) as count FROM vagas_history.bet_history WHERE created_at > DATE_SUB(NOW(), INTERVAL 10000 MINUTE) GROUP BY player , result;");
        Map<String, WinLoseStats> winLoseStatsMap = new HashMap<>();
        for (Map<String, Object> map : mapList) {
            String player = map.get("player").toString();
            if (!winLoseStatsMap.containsKey(player)) {
                winLoseStatsMap.put(player, new WinLoseStats());
            }
            WinLoseStats winLoseStats = winLoseStatsMap.get(player);
            int count = Integer.parseInt(map.get("count").toString());
            int result = Integer.parseInt(map.get("result").toString());
            winLoseStats.addTotalCount(count);
            if (result == SAME) {
                winLoseStats.addSameCount(count);
            } else if (result == USER_WIN) {
                winLoseStats.addUserWinCount(count);
            } else if (result == GAME_WIN) {
                winLoseStats.addGameWinCount(count);
            }
        }
        for (String player : winLoseStatsMap.keySet()) {
            WinLoseStats winLoseStats = winLoseStatsMap.get(player);
            if (winLoseStats.getTotalCount() > 6 && (double) (winLoseStats.getUserWinCount()) / (double) winLoseStats.getTotalCount() > 0.9) {
                addToBlackList(player);
            }
        }
    }
}