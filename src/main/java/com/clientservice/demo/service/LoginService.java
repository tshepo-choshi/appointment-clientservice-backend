package com.clientservice.demo.service;

import com.clientservice.demo.appuser.AppUser;
import com.clientservice.demo.dto.LoginRequest;
import com.clientservice.demo.dto.UserResponse;
import com.clientservice.demo.repository.AppUserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class LoginService {

    private final AppUserRepository appUserRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public LoginService(AppUserRepository appUserRepository, PasswordEncoder passwordEncoder, JwtService jwtService){
        this.appUserRepository = appUserRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    public ResponseEntity<UserResponse> login(LoginRequest loginRequest){
        AppUser appUser = appUserRepository.findByEmail(loginRequest.getEmail()).orElse(null);

        if(appUser == null){
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        if(!passwordEncoder.matches(loginRequest.getPassword(), appUser.getPassword())){
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        String token =  jwtService.generateToken(loginRequest.getEmail());

        UserResponse userResponse = new UserResponse();
        if(token != null){
            userResponse.setId(appUser.getId());
            userResponse.setToken(token);
            userResponse.setEmail(appUser.getUsername());
            userResponse.setFullName(appUser.getFirstName());
            userResponse.setLastname(appUser.getLastName());
            userResponse.setRole(appUser.getAppUserRole().name());
        }
        return ResponseEntity.ok(userResponse);
    }

}
