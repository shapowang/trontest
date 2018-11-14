package cn.bc.rockgame;

import com.aliyuncs.exceptions.ClientException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.http.client.fluent.Request;
import org.apache.http.entity.ContentType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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
import java.util.*;

@EnableScheduling
@Controller
public class GameController {
    private static final Logger LOGGER = LoggerFactory.getLogger(GameController.class);
    public static final ContentType contentType = ContentType.create("application/json", "utf-8");
    public static final String NETWORK = "http://jungle.cryptolions.io:18888";
    private static Map<String, AccountPermission> permissionMap = new HashMap<>();

    static {
        permissionMap.put("vagasico1111", new AccountPermission(Arrays.asList("active:vagasico1111@eosio.code", "owner:EOS5th5A9doz6fQPCoQrJvuZcFjZTZkAww4KqD4jjWDBg9LMnhJXn")));
        permissionMap.put("vagasminep11", new AccountPermission(Arrays.asList("active:vagasminep11@eosio.code", "mine:vagasgame111@eosio.code", "owner:EOS8FAZ1m6QQ8xLuZ2ZRQLZQehsJ2Jkt11Pkd8tuzq9hY29s4vufJ")));
        permissionMap.put("vagasprofi11", new AccountPermission(Arrays.asList("active:vagasprofi11@eosio.code", "owner:EOS7yfoeSB87JraMtEu6D8YaRme6mSB9dHWhVVVyBgN8MjsawGx67", "profit:EOS7kZo7ynM9cZWoeMu4UqAieHafVNw2wxiuuP3Trg3wiSziKPX9N")));
        permissionMap.put("vagasgame111", new AccountPermission(Arrays.asList("active:vagasgame111@eosio.code", "owner:EOS6aRL2KwdTTHGhqTWdpvJigCNcYyrxjbT5XZ3d2RKuLc6XF6dK2")));
        permissionMap.put("vagasadmin11", new AccountPermission(Arrays.asList("active:EOS5d9poJXy6y2xZujQPWp1nsTvLYybygexfZJFcDHxjBrbA9kMHM", "owner:EOS5uinq76fwmg56D5mNgHh26MwQvedcf7by7wZja3FJAFvVsRTCh")));
        permissionMap.put("vagastoken11", new AccountPermission(Arrays.asList("active:EOS7qqZRptBFXRzeby871hxJBe776HvcgSTjAckS9C4eFZCBTnfkP", "owner:EOS6DQkgRecaa1q9fmJu7qKe26stHERDvYMb4xBHG6o1LX82j4RnP")));
        permissionMap.put("vagaswallet1", new AccountPermission(Arrays.asList("active:EOS5rtwkvGfx68eHLzLyqdr9oKb1DCZrTHaZfWS3mrxr8i3ixf5tf", "owner:EOS6zwxxwMScPunHvjR7mgH71hpAPd1WVirgcKjwWJawg1MhdP662")));
    }

    @RequestMapping("/accounts")
    @ResponseBody
    public HttpResponseMessage listAccounts() {
        List<String> accountList = new ArrayList<>();
        for (String account : permissionMap.keySet()) {
            try {
                accountList.add(Request.Post(NETWORK + "/v1/chain/get_account").bodyString(String.format("{\"account_name\":\"%s\"}", account), contentType).execute().returnContent().asString());
            } catch (Exception e) {
                LOGGER.error("exception:", e);
            }
        }
        HttpResponseMessage httpResponseMessage = new HttpResponseMessage();
        httpResponseMessage.setStatus(new BcStatus(200, "success"));
        httpResponseMessage.setResult(accountList);
        return httpResponseMessage;
    }

    @RequestMapping("/evt_balance")
    @ResponseBody
    public HttpResponseMessage evtBalance(@RequestParam String account) throws IOException {
        String url = NETWORK + "/v1/chain/get_currency_balance";
        String string = Request.Post(url).bodyString(String.format("{\"account\":\"%s\",\"code\":\"vagastoken11\",\"symbol\":\"EVT\"}", account), contentType).execute().returnContent().asString();
        HttpResponseMessage httpResponseMessage = new HttpResponseMessage();
        httpResponseMessage.setStatus(new BcStatus(200, "success"));
        String result = string.replace("[", "").replace("]", "").replace("\"", "").replace(" EVT", "");
        httpResponseMessage.setResult(StringUtils.isEmpty(result) ? "0" : result);
        return httpResponseMessage;
    }

    @Scheduled(fixedDelay = 10_000)
    public void permissionMonitor() {
        for (String account : permissionMap.keySet()) {
            try {
                String json = Request.Post(NETWORK + "/v1/chain/get_account").bodyString(String.format("{\"account_name\":\"%s\"}", account), contentType).execute().returnContent().asString();
                ObjectMapper objectMapper = new ObjectMapper();
                JsonNode jsonNode = objectMapper.readTree(json);
                List<String> permissionList = getPermissionList(jsonNode.get("permissions"));
                System.out.println(account);
                for (String s : permissionList) {
                    System.out.println(s);
                }
                AccountPermission accountPermission = permissionMap.get(account);
                if (!(permissionList.containsAll(accountPermission.getPermissionList()) && accountPermission.getPermissionList().containsAll(permissionList))) {
                    alert(account);
                }
            } catch (Exception e) {
                LOGGER.error("exception:", e);
            }
        }
    }

    private void alert(String account) throws ClientException {
        String x = account + "权限发生变更，请立即检查";
        System.err.println(x);
        SmsUtil.sendSms("17335798599", x);
        SmsUtil.sendSms("18811402254", x);
        SmsUtil.sendSms("18511387625", x);
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
}