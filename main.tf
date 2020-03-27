resource "null_resource" "dependencies" {
  triggers = {
    dependencies = join(",", var.dependencies)
  }
}

resource "random_string" "recovery_password" {
  length      = 16
  special     = false
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
}

locals {
  recovery_password = var.domain_recovery_password == null ? random_string.recovery_password.result : var.domain_recovery_password
}

resource "null_resource" "adds" {
  depends_on = [null_resource.dependencies]

  connection {
    type     = "winrm"
    host     = var.host
    user     = var.username
    password = var.password
  }

  provisioner "remote-exec" {
    inline = [
      "powershell -ExecutionPolicy Unrestricted -Command Install-WindowsFeature –Name AD-Domain-Services -IncludeManagementTools",
      "powershell -ExecutionPolicy Unrestricted -Command $rp = ConvertTo-SecureString -AsPlainText ${local.recovery_password} -Force; Install-ADDSForest -DomainName ${var.domain_name} -DomainNetbiosName ${var.domain_netbios_name} -DomainMode ${var.domain_mode} -ForestMode ${var.forest_mode} -SafeModeAdministratorPassword $rp -InstallDns -Force"
    ]
  }
}

resource "null_resource" "adduser" {
  depends_on = [null_resource.adds]

  connection {
    type     = "winrm"
    host     = var.host
    user     = var.username
    password = var.password
  }

  provisioner "file" {
    content     = var.ad_users_csv == null ? templatefile("${path.module}/templates/adusers.csv.tmpl", { domain_name = var.domain_name }) : var.ad_users_csv
    destination = "c:\\temp\\adusers.csv"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/adusers.ps1"
    destination = "c:\\temp\\adusers.ps1"
  }

  provisioner "remote-exec" {
    inline = [
      "powershell -ExecutionPolicy Unrestricted -File c:\\temp\\adusers.ps1"
    ]
  }
}
