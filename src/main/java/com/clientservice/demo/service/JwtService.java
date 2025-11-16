package com.clientservice.demo.service;

import com.clientservice.demo.appuser.AppUser;
import com.clientservice.demo.repository.AppUserRepository;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import java.util.Date;
import java.util.Optional;

@Service
public class JwtService {

    private final AppUserRepository appUserRepository;

    public JwtService(AppUserRepository appUserRepository){
        this.appUserRepository = appUserRepository;
    }

    @Value("${spring.jwt.secret}")
    private String secret;

    public String generateToken(String email){
        Optional<AppUser> appUser = appUserRepository.findByEmail(email);
        if(appUser.isPresent()) {
            final long tokenExpiration = 86400; //1 day
            return Jwts.builder()
                    .subject(email)
                    .claim("email", appUser.get().getUsername())
                    .claim("Firstname", appUser.get().getFirstName())
                    .claim("Lastname", appUser.get().getLastName())
                    .issuedAt(new Date())
                    .expiration(new Date(System.currentTimeMillis() + 1000 * tokenExpiration))
                    .signWith(Keys.hmacShaKeyFor(secret.getBytes()))
                    .compact();
        }
        return null;
    }

    public boolean validateToken(String token){
        try {
            var claims = Jwts.parser()
                    .verifyWith(Keys.hmacShaKeyFor(secret.getBytes()))
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();

           return claims.getExpiration().after(new Date());
        }catch(JwtException e){
            return false;
        }
    }

}
