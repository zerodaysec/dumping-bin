{
    "RequireUppercaseCharacters": "${required_uppercase}",
    "RequireLowercaseCharacters": "${required_lowercase}",
    "RequireSymbols": "${required_symbols}",
    "RequireNumbers": "${required_numbers}",
    "MinimumPasswordLength": "${min_length}",
    "PasswordReusePrevention": "${number_of_passwords_tracked}"
    %{ if check_password_expires ~}
    ,"MaxPasswordAge": "${max_age_in_days}"
    %{ endif ~}
}
