package response;

import java.io.Serializable;

@SuppressWarnings("serial")
public class BcStatus implements Serializable {

    // 状态码   业务错误 (10000+ )
    private Integer code;

    private String msg;

    public Integer getCode() {
        return code;
    }

    public void setCode(Integer code) {
        this.code = code;
    }

    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }

    public BcStatus(Integer code, String msg) {
        super();
        this.code = code;
        this.msg = msg;
    }

    public BcStatus() {
        super();
    }


}
