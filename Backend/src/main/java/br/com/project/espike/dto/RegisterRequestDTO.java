package br.com.project.espike.dto;

public record RegisterRequestDTO(String name, String email, String password, String cpf, String phone, String user_type) {
}
