package cn.bc.rockgame;

import org.apache.http.client.fluent.Request;
import org.apache.http.entity.ContentType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import response.BcStatus;
import response.HttpResponseMessage;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@Controller
public class GameController {
    private static final Logger LOGGER = LoggerFactory.getLogger(GameController.class);
    public static final ContentType contentType = ContentType.create("application/json", "utf-8");
    public static final String NETWORK = "http://jungle.cryptolions.io:18888";
    private static List<String> accounts = Arrays.asList("vagasico1111", "vagasminep11", "vagasprofi11", "vagasgame111", "vagasadmin11", "vagastoken11", "vagaswallet1");

    @RequestMapping("/accounts")
    @ResponseBody
    public HttpResponseMessage listAccounts() {
        List<String> accountList = new ArrayList<>();
        for (String account : accounts) {
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
//        String url = String.format("https://api.eospark.com/api?module=account&action=get_token_list&apikey=3d98a5267a43e7b11acd242ef01ea820&account=%s", account);
//        String string = Request.Post(url).execute().returnContent().asString();
        HttpResponseMessage httpResponseMessage = new HttpResponseMessage();
        httpResponseMessage.setStatus(new BcStatus(200, "success"));
        httpResponseMessage.setResult(0);
        return httpResponseMessage;
    }

}