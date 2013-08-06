@test "check confluence is running" {
  sv status confluence
}

@test "check confluence setup wizard" {
  export license_string="<title>Confluence Setup Wizard - Confluence</title>"
  wget -O - http://localhost:8081 | grep "${license_string}"
}
