package cn.bc.rockgame;

public class Row {
    int i;
    int id;
    String player;
    String referrer;
    String flag;
    int amount;
    int value;
    int result;
    long time;
    String hash;

    public Row(int i, int id, String player, String referrer, String flag, int amount, int value, int result, long time, String hash) {
        this.i = i;
        this.id = id;
        this.player = player;
        this.referrer = referrer;
        this.flag = flag;
        this.amount = amount;
        this.value = value;
        this.result = result;
        this.time = time;
        this.hash = hash;
    }

    public int getI() {
        return i;
    }

    public int getId() {
        return id;
    }

    public String getPlayer() {
        return player;
    }

    public String getReferrer() {
        return referrer;
    }

    public String getFlag() {
        return flag;
    }

    public int getAmount() {
        return amount;
    }

    public int getValue() {
        return value;
    }

    public int getResult() {
        return result;
    }

    public long getTime() {
        return time;
    }

    public String getHash() {
        return hash;
    }
}
