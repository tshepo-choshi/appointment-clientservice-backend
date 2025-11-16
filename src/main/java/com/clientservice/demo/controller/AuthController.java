package com.clientservice.demo.controller;

import com.clientservice.demo.dto.LoginRequest;
import com.clientservice.demo.dto.UserResponse;
import com.clientservice.demo.service.LoginService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(path = "api/v1/auth")
public class AuthController {

    private final LoginService loginService;

    public AuthController(LoginService loginService){
        this.loginService = loginService;
    }

    @PostMapping("/login")
    public ResponseEntity<UserResponse> login(@Valid @RequestBody LoginRequest loginRequest){
        return loginService.login(loginRequest);
    }

}
