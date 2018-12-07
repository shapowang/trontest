package cn.bc.rockgame;

public class WinLoseStats {
    private int continueWinTimes;
    private int sameCount;
    private int totalCount;
    private int userWinCount;
    private int gameWinCount;

    public WinLoseStats() {
    }

    public WinLoseStats(int continueWinTimes) {
        this.continueWinTimes = continueWinTimes;
    }

    public int getContinueWinTimes() {
        return continueWinTimes;
    }

    public void setContinueWinTimes(int continueWinTimes) {
        this.continueWinTimes = continueWinTimes;
    }

    public void addTotalCount(int count) {
        totalCount += count;
    }

    public void addSameCount(int count) {
        sameCount += count;
    }

    public void addUserWinCount(int count) {
        userWinCount += count;
    }

    public void addGameWinCount(int count) {
        gameWinCount += count;
    }

    public int getSameCount() {
        return sameCount;
    }

    public int getTotalCount() {
        return totalCount;
    }

    public int getUserWinCount() {
        return userWinCount;
    }

    public int getGameWinCount() {
        return gameWinCount;
    }

    @Override
    public String toString() {
        return "WinLoseStats{" +
                "continueWinTimes=" + continueWinTimes +
                ", sameCount=" + sameCount +
                ", totalCount=" + totalCount +
                ", userWinCount=" + userWinCount +
                ", gameWinCount=" + gameWinCount +
                '}';
    }
}