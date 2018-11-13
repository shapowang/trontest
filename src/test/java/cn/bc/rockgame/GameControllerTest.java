package cn.bc.rockgame;

import org.apache.http.client.fluent.Request;
import org.junit.Test;

import java.io.IOException;

public class GameControllerTest {

    @Test
    public void listAccounts() {
    }

    @Test
    public void evtBalance() throws IOException {
        String string = Request.Get("http://127.0.0.1:8080/evt_balance?account=vagaswallet1").execute().returnContent().asString();
        System.out.println(string);
    }
}