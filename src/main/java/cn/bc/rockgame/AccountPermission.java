package cn.bc.rockgame;

import java.util.List;

public class AccountPermission {
    private final List<String> permissionList;

    public AccountPermission(List<String> permissionList) {
        this.permissionList = permissionList;
    }

    public List<String> getPermissionList() {
        return permissionList;
    }

    @Override
    public String toString() {
        return "AccountPermission{" +
                "permissionList=" + permissionList +
                '}';
    }

}