Connect-MgGraph -Scopes "Directory.Read.All", "User.Read.All"


$P2SkuId = (Get-MgSubscribedSku | Select * | where {$_.SkuPartNumber -eq "AAD_PREMIUM_P2"}).SkuId

Set-MgUserLicense -UserId "6ed9dfc0-b1c7-40dd-adfc-9b208fe05828" -RemoveLicenses @($P2SkuId) -AddLicenses @()
