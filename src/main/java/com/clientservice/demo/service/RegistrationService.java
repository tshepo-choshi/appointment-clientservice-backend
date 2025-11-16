package com.clientservice.demo.service;

import com.clientservice.demo.appuser.AppUser;
import com.clientservice.demo.dto.ResponseText;
import com.clientservice.demo.repository.AppUserRepository;
import com.clientservice.demo.appuser.AppUserRole;
import com.clientservice.demo.dto.RegistrationRequest;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class RegistrationService {

    private final PasswordEncoder passwordEncoder;
    private final EmailValidator emailValidator;
    private final AppUserRepository appUserRepository;

    public RegistrationService(EmailValidator emailValidator, PasswordEncoder passwordEncoder, AppUserRepository appUserRepository) {
        this.emailValidator = emailValidator;
        this.passwordEncoder = passwordEncoder;
        this.appUserRepository = appUserRepository;
    }

    public ResponseText register(RegistrationRequest request){
        boolean isValidEmail = emailValidator.test(request.getEmail());
        if(!isValidEmail){
            throw new IllegalStateException("Email is not valid");
        }
        String password = passwordEncoder.encode(request.getPassword());

        appUserRepository.save(new AppUser(
                request.getFirstName(), request.getLastName(),request.getEmail(), password, AppUserRole.USER
        ));
        ResponseText response = new ResponseText();
        response.setMessage("Registered Successfully");
        return response;
    }
}
