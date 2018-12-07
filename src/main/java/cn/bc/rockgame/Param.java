package cn.bc.rockgame;

public class Param {
    String scope;
    String code;
    String table;
    String table_key;
    boolean json;
    String lower_bound;
    String upper_bound;
    int limit;
    String index_position;
    String key_type;
    String encode_type;

    public Param(String scope, String code, String table, int limit, boolean json) {
        this.scope = scope;
        this.code = code;
        this.table = table;
        this.limit = limit;
        this.json = json;
    }
}
