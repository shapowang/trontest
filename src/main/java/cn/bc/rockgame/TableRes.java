package cn.bc.rockgame;

import java.util.List;

public class TableRes {
    List<Row> rows;
    boolean more;

    public TableRes(List<Row> rows, boolean more) {
        this.rows = rows;
        this.more = more;
    }

    public List<Row> getRows() {
        return rows;
    }

    public boolean isMore() {
        return more;
    }
}
