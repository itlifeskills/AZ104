#Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
#Install-Module Microsoft.Entra -AllowClobber
#Connect-Entra -Scopes "User.ReadWrite.All“
sleep (10)
#Import employees from the list and exclude the CEO whose account had been created
$Employees = Import-Csv -Path "C:\PowerShell\AZ104\CreateUsers\Data\EmployeeList.csv" | where {$_.Manager -ne $null}

#Set the intial password as "ITLifeskills!AZ104" and force the users to change the password at logon
$passwordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$passwordProfile.Password = "ITLifeskills!AZ104"
$passwordProfile.ForceChangePasswordNextLogin = $true


foreach($employee in $Employees){
    
    #Read each employee's attribute from the EmployeeList.csv file and store it in a variable.
    $givenName = $employee.GivenName
    $surName = $employee.Surname
    $displayName = $givenName + " " + $surName
    $mailNickName = $givenName + "." + $surName
    $userPrincipalName = $mailNickName + "@" + "itlifeskills.com"
    $department = $employee.Department
    $jobTitle = $employee.JobTitle
    $phone = $employee.PhoneNumber
    $office = $employee.Office
    $country = $employee.Country
    $manager = $employee.Manager

    #Construct a hash table of $userParams containing all the attributes
    $userParams = @{
        GivenName         = $givenName
        Surname           = $surName
        DisplayName       = $displayName
        UserPrincipalName = $userPrincipalName
        MailNickName      = $mailNickName
        PasswordProfile   = $passwordProfile
        AccountEnabled    = $true
        Department        = $department
        JobTitle          = $jobTitle
        Country           = $country
        TelephoneNumber   = $phone
        UsageLocation     = $country   
    
    }
    
    #Create a new user with the hash table of all attributes    
    New-EntraUser @userParams

    #Set office location for the new user
    Set-EntraUser -UserId $userPrincipalName -OfficeLocation $office

    #Get the object Id of the manager and store it to $managerObjId
    $managerObjId = (Get-EntraUser -Filter "DisplayName eq '$manager'").Id

    #Then set the manager for the user
    Set-EntraUserManager -UserId $userPrincipalName -ManagerId $managerObjId

}