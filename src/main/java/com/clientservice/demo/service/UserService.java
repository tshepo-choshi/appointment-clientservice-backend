package com.clientservice.demo.service;

import com.clientservice.demo.repository.AppUserRepository;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Collections;

@Service
public class UserService implements UserDetailsService {

    private final AppUserRepository appUserRepository;

    public UserService(AppUserRepository appUserRepository){
        this.appUserRepository = appUserRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        UserDetails user = appUserRepository.findByEmail(email).orElseThrow(() -> new UsernameNotFoundException("User not found"));

        return new User(user.getUsername(), user.getPassword(), Collections.emptyList());
    }

}
