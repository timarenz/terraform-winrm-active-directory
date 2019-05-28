$ADUsers = Import-Csv $PSScriptRoot\adusers.csv

do {
  $NotReady = $false
  try {
    Get-ADDomainController
  }
  catch {
    $NotReady = $true
    Start-Sleep -Seconds 5
  }
} while ($NotReady)

foreach ($User in $ADUsers) {
  try {
    Get-ADUser -Identity $User.username
  }
  catch {
    $UserPassword = ConvertTo-SecureString -AsPlainText $User.password -Force
    New-ADUser -Name $User.username -UserPrincipalName $User.upn -ChangePasswordAtLogon $false -Enabled $true -PasswordNeverExpires $true -AccountPassword $UserPassword
  }
  try {
    Get-ADGroup -Identity $User.group
  }
  catch {
    New-ADGroup -Name $User.group -GroupCategory Security -GroupScope Global
  }
  Add-ADGroupMember -Identity $User.group -Members $User.username
}