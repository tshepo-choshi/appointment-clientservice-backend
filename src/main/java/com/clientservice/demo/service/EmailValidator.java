package com.clientservice.demo.service;
import org.springframework.stereotype.Service;
import java.util.function.Predicate;
import java.util.regex.Pattern;

@Service
public class EmailValidator implements Predicate<String> {
    String emailRegex = "^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$";
    @Override
    public boolean test(String emailAddress) {
        return Pattern.compile(emailRegex)
                .matcher(emailAddress)
                .matches();
    }
}
