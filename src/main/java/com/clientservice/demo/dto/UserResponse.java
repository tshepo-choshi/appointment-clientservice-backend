package com.clientservice.demo.dto;

import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class UserResponse {

    private Long id;
    private String email;
    private String fullName;
    private String Lastname;
    private String token;
    private String role;


}
