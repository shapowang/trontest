package response;

public class HttpResponseMessage {

    private BcStatus status;

    private Object result;

    public BcStatus getStatus() {
        return status;
    }

    public void setStatus(BcStatus status) {
        this.status = status;
    }

    public Object getResult() {
        return result;
    }

    public void setResult(Object result) {
        this.result = result;
    }
}