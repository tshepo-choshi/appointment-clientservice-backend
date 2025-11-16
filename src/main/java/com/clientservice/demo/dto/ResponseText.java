package com.clientservice.demo.dto;


public class ResponseText {
    private String message;

    public ResponseText() {
    }

    public ResponseText(String message) {
        this.message = message;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    @Override
    public String toString() {
        return "ResponseText{" +
                "message='" + message + '\'' +
                '}';
    }
}
